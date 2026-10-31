/*
 * tinflate - tiny inflate
 *
 * Copyright (c) 2003-2019 Joergen Ibsen
 *
 * This software is provided 'as-is', without any express or implied
 * warranty. In no event will the authors be held liable for any damages
 * arising from the use of this software.
 *
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 *
 *   1. The origin of this software must not be misrepresented; you must
 *      not claim that you wrote the original software. If you use this
 *      software in a product, an acknowledgment in the product
 *      documentation would be appreciated but is not required.
 *
 *   2. Altered source versions must be plainly marked as such, and must
 *      not be misrepresented as being the original software.
 *
 *   3. This notice may not be removed or altered from any source
 *      distribution.
 */

#include "tinf.h"
#include "tinf_stream.h"
#include <stdlib.h>
/* Altered for NanoBlast: callback input/output and a bounded 32 KiB history. */

#include <assert.h>
#include <limits.h>

#if defined(UINT_MAX) && (UINT_MAX) < 0xFFFFFFFFUL
#  error "tinf requires unsigned int to be at least 32-bit"
#endif

/* -- Internal data structures -- */

struct tinf_tree {
	unsigned short counts[16]; /* Number of codes with a given length */
	unsigned short symbols[288]; /* Symbols sorted by code */
	int max_sym;
};

struct tinf_reader {
	void *context;
	int (*read_byte)(void *);
	unsigned int tag;
	int bitcount;
	int overflow;

	unsigned char window[32768];
	unsigned produced, limit;
	unsigned stored, match, distance;
	int phase, final;

	struct tinf_tree ltree; /* Literal/length tree */
	struct tinf_tree dtree; /* Distance tree */
};

/* -- Utility functions -- */

/* Build fixed Huffman trees */
static void tinf_build_fixed_trees(struct tinf_tree *lt, struct tinf_tree *dt)
{
	int i;

	/* Build fixed literal/length tree */
	for (i = 0; i < 16; ++i) {
		lt->counts[i] = 0;
	}

	lt->counts[7] = 24;
	lt->counts[8] = 152;
	lt->counts[9] = 112;

	for (i = 0; i < 24; ++i) {
		lt->symbols[i] = 256 + i;
	}
	for (i = 0; i < 144; ++i) {
		lt->symbols[24 + i] = i;
	}
	for (i = 0; i < 8; ++i) {
		lt->symbols[24 + 144 + i] = 280 + i;
	}
	for (i = 0; i < 112; ++i) {
		lt->symbols[24 + 144 + 8 + i] = 144 + i;
	}

	lt->max_sym = 285;

	/* Build fixed distance tree */
	for (i = 0; i < 16; ++i) {
		dt->counts[i] = 0;
	}

	dt->counts[5] = 32;

	for (i = 0; i < 32; ++i) {
		dt->symbols[i] = i;
	}

	dt->max_sym = 29;
}

/* Given an array of code lengths, build a tree */
static int tinf_build_tree(struct tinf_tree *t, const unsigned char *lengths,
                           unsigned int num)
{
	unsigned short offs[16];
	unsigned int i, num_codes, available;

	assert(num <= 288);

	for (i = 0; i < 16; ++i) {
		t->counts[i] = 0;
	}

	t->max_sym = -1;

	/* Count number of codes for each non-zero length */
	for (i = 0; i < num; ++i) {
		assert(lengths[i] <= 15);

		if (lengths[i]) {
			t->max_sym = i;
			t->counts[lengths[i]]++;
		}
	}

	/* Compute offset table for distribution sort */
	for (available = 1, num_codes = 0, i = 0; i < 16; ++i) {
		unsigned int used = t->counts[i];

		/* Check length contains no more codes than available */
		if (used > available) {
			return TINF_DATA_ERROR;
		}
		available = 2 * (available - used);

		offs[i] = num_codes;
		num_codes += used;
	}

	/*
	 * Check all codes were used, or for the special case of only one
	 * code that it has length 1
	 */
	if ((num_codes > 1 && available > 0)
	 || (num_codes == 1 && t->counts[1] != 1)) {
		return TINF_DATA_ERROR;
	}

	/* Fill in symbols sorted by code */
	for (i = 0; i < num; ++i) {
		if (lengths[i]) {
			t->symbols[offs[lengths[i]]++] = i;
		}
	}

	/*
	 * For the special case of only one code (which will be 0) add a
	 * code 1 which results in a symbol that is too large
	 */
	if (num_codes == 1) {
		t->counts[1] = 2;
		t->symbols[1] = t->max_sym + 1;
	}

	return TINF_OK;
}

/* -- Decode functions -- */

static void tinf_refill(struct tinf_reader *d, int num)
{
	assert(num >= 0 && num <= 32);

	/* Read bytes until at least num bits available */
	while (d->bitcount < num) {
		int byte = d->read_byte(d->context);
		if (byte >= 0) {
			d->tag |= (unsigned int) byte << d->bitcount;
		}
		else {
			d->overflow = 1;
		}
		d->bitcount += 8;
	}

	assert(d->bitcount <= 32);
}

static unsigned int tinf_getbits_no_refill(struct tinf_reader *d, int num)
{
	unsigned int bits;

	assert(num >= 0 && num <= d->bitcount);

	/* Get bits from tag */
	bits = d->tag & ((1UL << num) - 1);

	/* Remove bits from tag */
	d->tag >>= num;
	d->bitcount -= num;

	return bits;
}

/* Get num bits from source stream */
static unsigned int tinf_getbits(struct tinf_reader *d, int num)
{
	tinf_refill(d, num);
	return tinf_getbits_no_refill(d, num);
}

/* Read a num bit value from stream and add base */
static unsigned int tinf_getbits_base(struct tinf_reader *d, int num, int base)
{
	return base + (num ? tinf_getbits(d, num) : 0);
}

/* Given a data stream and a tree, decode a symbol */
static int tinf_decode_symbol(struct tinf_reader *d, const struct tinf_tree *t)
{
	int base = 0, offs = 0;
	int len;

	/*
	 * Get more bits while code index is above number of codes
	 *
	 * Rather than the actual code, we are computing the position of the
	 * code in the sorted order of codes, which is the index of the
	 * corresponding symbol.
	 *
	 * Conceptually, for each code length (level in the tree), there are
	 * counts[len] leaves on the left and internal nodes on the right.
	 * The index we have decoded so far is base + offs, and if that
	 * falls within the leaves we are done. Otherwise we adjust the range
	 * of offs and add one more bit to it.
	 */
	for (len = 1; ; ++len) {
		offs = 2 * offs + tinf_getbits(d, 1);

		assert(len <= 15);

		if (offs < t->counts[len]) {
			break;
		}

		base += t->counts[len];
		offs -= t->counts[len];
	}

	assert(base + offs >= 0 && base + offs < 288);

	return t->symbols[base + offs];
}

/* Given a data stream, decode dynamic trees from it */
static int tinf_decode_trees(struct tinf_reader *d, struct tinf_tree *lt,
                             struct tinf_tree *dt)
{
	unsigned char lengths[288 + 32];

	/* Special ordering of code length codes */
	static const unsigned char clcidx[19] = {
		16, 17, 18, 0,  8, 7,  9, 6, 10, 5,
		11,  4, 12, 3, 13, 2, 14, 1, 15
	};

	unsigned int hlit, hdist, hclen;
	unsigned int i, num, length;
	int res;

	/* Get 5 bits HLIT (257-286) */
	hlit = tinf_getbits_base(d, 5, 257);

	/* Get 5 bits HDIST (1-32) */
	hdist = tinf_getbits_base(d, 5, 1);

	/* Get 4 bits HCLEN (4-19) */
	hclen = tinf_getbits_base(d, 4, 4);

	/*
	 * The RFC limits the range of HLIT to 286, but lists HDIST as range
	 * 1-32, even though distance codes 30 and 31 have no meaning. While
	 * we could allow the full range of HLIT and HDIST to make it possible
	 * to decode the fixed trees with this function, we consider it an
	 * error here.
	 *
	 * See also: https://github.com/madler/zlib/issues/82
	 */
	if (hlit > 286 || hdist > 30) {
		return TINF_DATA_ERROR;
	}

	for (i = 0; i < 19; ++i) {
		lengths[i] = 0;
	}

	/* Read code lengths for code length alphabet */
	for (i = 0; i < hclen; ++i) {
		/* Get 3 bits code length (0-7) */
		unsigned int clen = tinf_getbits(d, 3);

		lengths[clcidx[i]] = clen;
	}

	/* Build code length tree (in literal/length tree to save space) */
	res = tinf_build_tree(lt, lengths, 19);

	if (res != TINF_OK) {
		return res;
	}

	/* Check code length tree is not empty */
	if (lt->max_sym == -1) {
		return TINF_DATA_ERROR;
	}

	/* Decode code lengths for the dynamic trees */
	for (num = 0; num < hlit + hdist; ) {
		int sym = tinf_decode_symbol(d, lt);

		if (sym > lt->max_sym) {
			return TINF_DATA_ERROR;
		}

		switch (sym) {
		case 16:
			/* Copy previous code length 3-6 times (read 2 bits) */
			if (num == 0) {
				return TINF_DATA_ERROR;
			}
			sym = lengths[num - 1];
			length = tinf_getbits_base(d, 2, 3);
			break;
		case 17:
			/* Repeat code length 0 for 3-10 times (read 3 bits) */
			sym = 0;
			length = tinf_getbits_base(d, 3, 3);
			break;
		case 18:
			/* Repeat code length 0 for 11-138 times (read 7 bits) */
			sym = 0;
			length = tinf_getbits_base(d, 7, 11);
			break;
		default:
			/* Values 0-15 represent the actual code lengths */
			length = 1;
			break;
		}

		if (length > hlit + hdist - num) {
			return TINF_DATA_ERROR;
		}

		while (length--) {
			lengths[num++] = sym;
		}
	}

	/* Check EOB symbol is present */
	if (lengths[256] == 0) {
		return TINF_DATA_ERROR;
	}

	/* Build dynamic trees */
	res = tinf_build_tree(lt, lengths, hlit);

	if (res != TINF_OK) {
		return res;
	}

	res = tinf_build_tree(dt, lengths + hlit, hdist);

	if (res != TINF_OK) {
		return res;
	}

	return TINF_OK;
}

/* Pull-based state machine. Altered for NanoBlast: callers can pause after
 * any output byte without tasks, queues, files, or a whole-ROM buffer. */
static int tinf_next(struct tinf_reader *d)
{
 static const unsigned short lengths[29]={3,4,5,6,7,8,9,10,11,13,15,17,19,23,27,31,35,43,51,59,67,83,99,115,131,163,195,227,258};
 static const unsigned char length_bits[29]={0,0,0,0,0,0,0,0,1,1,1,1,2,2,2,2,3,3,3,3,4,4,4,4,5,5,5,5,0};
 static const unsigned short distances[30]={1,2,3,4,5,7,9,13,17,25,33,49,65,97,129,193,257,385,513,769,1025,1537,2049,3073,4097,6145,8193,12289,16385,24577};
 static const unsigned char distance_bits[30]={0,0,0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11,12,12,13,13};
 unsigned byte;
 for(;;){
  if(d->phase==4||d->overflow)return -2;
  if(d->phase==3)return d->produced==d->limit?-1:-2;
  if(d->phase==0){
   unsigned type;d->final=tinf_getbits(d,1);type=tinf_getbits(d,2);
   if(d->overflow)goto error;
   if(type==0){
    unsigned inverse;d->tag=0;d->bitcount=0;
    d->stored=tinf_getbits(d,16);inverse=tinf_getbits(d,16);
    if(d->overflow||d->stored!=(~inverse&65535)||d->stored>d->limit-d->produced)goto error;
    d->phase=1;
   }else if(type==1){tinf_build_fixed_trees(&d->ltree,&d->dtree);d->phase=2;}
   else if(type==2){if(tinf_decode_trees(d,&d->ltree,&d->dtree)!=TINF_OK||d->overflow)goto error;d->phase=2;}
   else goto error;
   continue;
  }
  if(d->phase==1){
   int value;if(!d->stored){d->phase=d->final?3:0;continue;}
   value=d->read_byte(d->context);if(value<0)goto error;byte=(unsigned)value;--d->stored;
  }else if(d->match){byte=d->window[(d->produced-d->distance)&32767];--d->match;}
  else{
   int symbol=tinf_decode_symbol(d,&d->ltree);if(d->overflow)goto error;
   if(symbol==256){d->phase=d->final?3:0;continue;}
   if(symbol<256)byte=(unsigned)symbol;
   else{
    int distance;if(symbol>285||symbol>d->ltree.max_sym||d->dtree.max_sym<0)goto error;
    symbol-=257;d->match=tinf_getbits_base(d,length_bits[symbol],lengths[symbol]);
    distance=tinf_decode_symbol(d,&d->dtree);
    if(distance>29||distance>d->dtree.max_sym||d->overflow)goto error;
    d->distance=tinf_getbits_base(d,distance_bits[distance],distances[distance]);
    if(d->overflow||!d->distance||d->distance>32768||d->distance>d->produced||d->match>d->limit-d->produced)goto error;
    continue;
   }
  }
  if(d->produced==d->limit)goto error;
  d->window[d->produced++&32767]=(unsigned char)byte;return (int)byte;
 }
error:d->phase=4;return -2;
}
struct tinf_reader *tinf_reader_open(void *context,int (*read_byte)(void *),unsigned output_limit)
{
 struct tinf_reader *d=(struct tinf_reader *)calloc(1,sizeof *d);
 if(d){d->context=context;d->read_byte=read_byte;d->limit=output_limit;}return d;
}
int tinf_reader_read(struct tinf_reader *d,unsigned char *out,unsigned length)
{
 unsigned i;for(i=0;i<length;++i){int byte=tinf_next(d);if(byte==-1)return (int)i;if(byte<0)return -1;out[i]=(unsigned char)byte;}return (int)i;
}
int tinf_reader_finish(struct tinf_reader *d){return tinf_next(d)==-1?TINF_OK:TINF_DATA_ERROR;}
void tinf_reader_close(struct tinf_reader *d){free(d);}
int tinf_stream(void *context,int (*read_byte)(void *),int (*write_bytes)(void *,const unsigned char *,unsigned),unsigned output_limit)
{
 struct tinf_reader *d=tinf_reader_open(context,read_byte,output_limit);unsigned char block[1024];int n,result=TINF_OK;
 if(!d)return TINF_BUF_ERROR;
 while((n=tinf_reader_read(d,block,sizeof block))>0)if(!write_bytes(context,block,(unsigned)n)){result=TINF_BUF_ERROR;break;}
 if(n<0||tinf_reader_finish(d)!=TINF_OK)result=TINF_DATA_ERROR;
 tinf_reader_close(d);return result;
}
