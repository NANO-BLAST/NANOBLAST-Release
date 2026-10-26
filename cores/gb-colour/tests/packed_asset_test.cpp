#include <cassert>
#include <fstream>
#include <vector>
#include <cstring>
#include <cstdio>
#include "../firmware/storage/gb_core_asset.h"
#include "../firmware/storage/crc32.h"
#include "../firmware/storage/core_image.h"
std::vector<uint8_t> flash(0x400000,255);
bool reader(uint32_t a,uint8_t*p,unsigned n){if(a>flash.size()||n>flash.size()-a)return false;std::memcpy(p,flash.data()+a,n);return true;}
std::vector<uint8_t> file(const char*p){std::ifstream f(p,std::ios::binary);assert(f);return {std::istreambuf_iterator<char>(f),{}};}
int main(int argc,char**argv){assert(argc==3);auto raw=file(argv[1]),packed=file(argv[2]);assert(packed.size()<=0x58000);
 for(size_t i=0;i<packed.size();++i){auto a=i<0x18000?0xe8000+i:i<0x38000?0x2e0000+i-0x18000:0x3df000+i-0x38000;flash[a]=packed[i];}
 uint32_t length=0,crc=0;assert(nanoblast::gb_core_info(reader,length,crc)&&length==raw.size());assert(crc==(nanoblast::crc32_update(~0u,raw.data(),raw.size())^~0u));
 std::vector<uint8_t>decoded(length);for(unsigned i=0;i<length;i+=257){auto n=std::min(257u,length-i);assert(nanoblast::gb_core_read(reader,i,decoded.data()+i,n));}assert(decoded==raw);
 for(unsigned i=0;i<500;++i){auto off=(uint64_t(i)*7919)%(length-300);uint8_t b[300];assert(nanoblast::gb_core_read(reader,off,b,300));assert(!std::memcmp(b,raw.data()+off,300));}
 nanoblast::CoreImageSource source;assert(nanoblast::builtin_core_source(reader,7,source)&&source.length==length);
 uint8_t b;assert(!nanoblast::gb_core_read(reader,length,&b,1));
 if(!std::memcmp(packed.data(),"NBGBXZ01",8)){
  // Evict page zero before corrupting it; the XZ CRC must reject the payload.
  assert(nanoblast::gb_core_read(reader,65536,&b,1));flash[0xe8000+4096+24]^=1;
  assert(!nanoblast::gb_core_read(reader,0,&b,1));flash[0xe8000+4096+24]^=1;
  assert(nanoblast::gb_core_read(reader,0,&b,1)&&b==raw[0]);
 }
flash[0xe8000+36]^=1;assert(!nanoblast::gb_core_info(reader,length,crc));
 std::puts("PASS production tinf decoder: full read, 500 random reads, scattered flash extents, image/footer/CRC and corrupt metadata rejection");
}
