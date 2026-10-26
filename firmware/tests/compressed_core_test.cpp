#include "../storage/compressed_core.h"
#include "../storage/compressed_core_slots.h"
#include "../storage/core_image.h"
#include "../storage/crc32.h"
#include <algorithm>
#include <cassert>
#include <cstdio>
#include <cstring>
#include <fstream>
#include <vector>
#include <string>
using namespace nanoblast;
std::vector<uint8_t> flash,baseline;uint64_t bytes_read=0;bool fail_read=false;
std::vector<uint8_t> file(const std::string&p){std::ifstream f(p,std::ios::binary);assert(f);return {std::istreambuf_iterator<char>(f),{}};}
bool read(uint32_t a,uint8_t*p,unsigned n){if(fail_read)return false;assert(a<flash.size()&&n<=flash.size()-a);assert(a>=CoreBankBegin&&a+n<=CoreBankEnd);bytes_read+=n;std::memcpy(p,flash.data()+a,n);return true;}
void put(unsigned a,uint32_t v){for(unsigned i=0;i<4;i++)flash[a+i]=v>>(i*8);}
uint32_t word(unsigned a){return image_word(flash.data()+a);}
void reset(){flash=baseline;fail_read=false;compressed_core_reset();bytes_read=0;}
int main(int argc,char**argv){assert(argc==3);const std::string pack=argv[1],raw=argv[2];flash.assign(0x400000,255);
 const unsigned ids[]={1,5,7,2};const char*names[]={"nes","sms-gamegear","gb-colour","snes-experimental"};std::vector<uint8_t> originals[4];
 for(unsigned i=0;i<4;i++){auto b=file(pack+"/"+names[i]+".core");unsigned base=CoreSlots[i].base;assert(CoreSlots[i].bytes==b.size());std::copy(b.begin(),b.end(),flash.begin()+base);originals[i]=file(raw+"/"+names[i]+"-nano20k.bin");}baseline=flash;
 for(unsigned i=0;i<4;i++){
  reset();CoreImageSource source;assert(builtin_core_source(read,ids[i],source)&&source.base==(PackedCoreBase|ids[i]));std::vector<uint8_t> out(source.length);
  for(unsigned off=0;off<out.size();){unsigned n=std::min(1024u,unsigned(out.size()-off));assert(core_image_read(read,source.base,off,out.data()+off,n));off+=n;}
  assert(out==originals[i]&&(crc32_update(~0u,out.data(),out.size())^~0u)==source.checksum&&flash==baseline);
  printf("PASS core %u: %zu exact decoded bytes, %llu flash bytes read\n",ids[i],out.size(),static_cast<unsigned long long>(bytes_read));
  assert(bytes_read<CoreSlots[i].bytes+70000);
 }
 // Interleaved random reads must not reuse another core's decoded cache.
 reset();uint32_t rng=0x12345678;uint8_t out[2111];
 for(unsigned k=0;k<100;k++){rng=rng*1664525u+1013904223;unsigned i=(rng>>17)%4,off=rng%(907418-sizeof out);assert(compressed_core_read(read,ids[i],off,out,sizeof out)&&!std::memcmp(out,originals[i].data()+off,sizeof out));}
 uint32_t len,crc;assert(!compressed_core_info(read,99,len,crc));assert(!compressed_core_read(read,1,907419,out,1));assert(!compressed_core_read(read,1,907417,out,2));assert(!compressed_core_read(read,1,0,nullptr,1));
 reset();unsigned base=CoreSlots[0].base;flash[base+8]=5;assert(!compressed_core_info(read,1,len,crc)); // wrong core/header
 reset();base=CoreSlots[0].base;put(base+64,4097);assert(!compressed_core_info(read,1,len,crc)); // invalid block table
 reset();base=CoreSlots[0].base;put(base+40,1);assert(!compressed_core_info(read,1,len,crc)); // reserved/header version
 reset();base=CoreSlots[0].base;flash[base+4096+20]^=1;assert(compressed_core_info(read,1,len,crc));assert(!compressed_core_read(read,1,0,out,sizeof out)); // damaged XZ fails before use
 reset();fail_read=true;assert(!compressed_core_info(read,1,len,crc));
 puts("PASS shared decoder corruption, bounds, metadata CRC, cross-core cache and immutable flash tests");
}
