// Read-only fourth core. Never writes auxiliary flash or uses the SNES cache.
#include "gb_core_asset.h"
#include "crc32.h"
#include <cstring>
#include <algorithm>
#include "tinf/tinf.h"
#include "xz/xz.h"
namespace nanoblast {
namespace {
uint32_t word(const uint8_t*p){return uint32_t(p[0])|uint32_t(p[1])<<8|uint32_t(p[2])<<16|uint32_t(p[3])<<24;}
bool packed_read(CoreRead read,uint32_t off,uint8_t*p,unsigned n){
 if(off>0x58000||n>0x58000-off)return false;
 while(n){uint32_t base,limit;
  if(off<0x18000){base=0xe8000;limit=0x18000;}
  else if(off<0x38000){base=0x2e0000-0x18000;limit=0x38000;}
  else {base=0x3df000-0x38000;limit=0x58000;}
  unsigned take=std::min(n,unsigned(limit-off));if(!read(base+off,p,take))return false;
  off+=take;p+=take;n-=take;
 }return true;
}
struct Header{uint32_t length,crc,packed,count,meta,block_bytes;bool deflate,xz;};
bool header(CoreRead read,Header&h){
 uint8_t b[64];if(!packed_read(read,0,b,64))return false;
 const bool legacy=!std::memcmp(b,"NBGBPK01",8);
 const bool zp1=!std::memcmp(b,"NBGBZP01",8),zp2=!std::memcmp(b,"NBGBZP02",8);
 const bool xz=!std::memcmp(b,"NBGBXZ01",8);
 const uint32_t block_bytes=word(b+32);
 if((!legacy&&!zp1&&!zp2&&!xz)||word(b+8)!=7||word(b+12)!=907418||word(b+20)!=0x4b30324e||block_bytes!=(xz?65536u:zp2?16384u:4096u))return false;
 h={word(b+12),word(b+16),word(b+24),word(b+28),word(b+36),block_bytes,zp1||zp2,xz};
 if(h.count!=(h.length+h.block_bytes-1)/h.block_bytes||h.packed>0x57000||!h.packed)return false;
 uint32_t crc=crc32_update(~0u,b,36);uint8_t entry[8];uint32_t previous=4096;
 for(unsigned i=0;i<h.count;i++){
  if(!packed_read(read,64+i*8,entry,8))return false;crc=crc32_update(crc,entry,8);
  uint32_t start=word(entry),n=word(entry+4)&0x7fffffffu;
  unsigned expected=std::min(unsigned(h.block_bytes),unsigned(h.length-i*h.block_bytes));
  if(start!=previous||!n||n>expected||(word(entry+4)&0x80000000u&&n!=expected)||start>4096+h.packed||n>4096+h.packed-start)return false;
  previous=start+n;
 }
 return (crc^~0u)==h.meta&&previous==4096+h.packed;
}
uint8_t decoded[65536],compressed[65536];uint32_t cached_block=~0u,cached_meta=0,cached_size=0;CoreRead cached_reader=nullptr;
bool block(CoreRead read,const Header&h,uint32_t index){
 if(cached_block==index&&cached_meta==h.meta&&cached_size==h.block_bytes&&cached_reader==read)return true;
 cached_block=~0u;
 uint8_t entry[8];if(!packed_read(read,64+index*8,entry,8))return false;
 uint32_t pos=word(entry),remaining=word(entry+4)&0x7fffffffu;
 const unsigned expected=std::min(unsigned(h.block_bytes),unsigned(h.length-index*h.block_bytes));unsigned output=0;
 if(word(entry+4)&0x80000000u){if(!packed_read(read,pos,decoded,expected))return false;output=expected;remaining=0;}
 else if(h.xz){
  if(!packed_read(read,pos,compressed,remaining))return false;
  static struct xz_dec *decoder=nullptr;
  if(!decoder){xz_crc32_init();decoder=xz_dec_init(XZ_SINGLE,0);}
  if(!decoder)return false;
  xz_dec_reset(decoder);
  struct xz_buf b={compressed,0,remaining,decoded,0,expected};
  if(xz_dec_run(decoder,&b)!=XZ_STREAM_END||b.in_pos!=remaining||b.out_pos!=expected)return false;
  output=expected;remaining=0;
 }
 else if(h.deflate){
  if(!packed_read(read,pos,compressed,remaining))return false;
  unsigned decoded_length=expected;
  if(tinf_zlib_uncompress(decoded,&decoded_length,compressed,remaining)!=TINF_OK||decoded_length!=expected)return false;
  output=decoded_length;remaining=0;
 }
 else{
  // Small prefetch buffer keeps flash traffic bounded without a second 4KiB buffer.
  uint8_t input[64];unsigned cursor=0,available=0;
  auto byte=[&](uint8_t&v)->bool{
   if(!remaining)return false;
   if(cursor==available){available=std::min(unsigned(remaining),64u);cursor=0;if(!packed_read(read,pos,input,available))return false;}
   v=input[cursor++];pos++;remaining--;return true;
  };
  auto extended=[&](unsigned&n)->bool{if(n!=15)return true;uint8_t v;do{if(!byte(v)||n>8192)return false;n+=v;}while(v==255);return true;};
  while(remaining){
   uint8_t token;if(!byte(token))return false;unsigned literals=token>>4;
   if(!extended(literals)||literals>expected-output)return false;
   while(literals--){uint8_t v;if(!byte(v))return false;decoded[output++]=v;}
   if(!remaining)break;
   uint8_t lo,hi;if(!byte(lo)||!byte(hi))return false;unsigned distance=lo|(unsigned(hi)<<8),match=token&15;
   if(!distance||distance>output||!extended(match)||match+4>expected-output)return false;
   match+=4;while(match--){decoded[output]=decoded[output-distance];output++;}
  }
 }
 if(output!=expected||remaining)return false;
 cached_block=index;cached_meta=h.meta;cached_size=h.block_bytes;cached_reader=read;return true;
}
}
bool gb_core_info(CoreRead read,uint32_t&length,uint32_t&checksum){Header h;if(!header(read,h))return false;length=h.length;checksum=h.crc;return true;}
bool gb_core_read(CoreRead read,uint32_t off,uint8_t*p,unsigned n){
 Header h;if(!header(read,h)||off>h.length||n>h.length-off)return false;
 while(n){unsigned index=off/h.block_bytes,inside=off%h.block_bytes,take=std::min(n,unsigned(h.block_bytes-inside));
  if(!block(read,h,index))return false;std::memcpy(p,decoded+inside,take);off+=take;p+=take;n-=take;
 }return true;
}
}
