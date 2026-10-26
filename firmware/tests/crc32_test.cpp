#include "../storage/crc32.h"
#include <cassert>
#include <vector>
uint32_t reference(uint32_t c,const uint8_t*p,unsigned n){
 while(n--){c^=*p++;for(unsigned i=0;i<8;i++)c=(c>>1)^((c&1)?0xedb88320u:0);}
 return c;
}
int main(){
 const auto*text=reinterpret_cast<const uint8_t*>("123456789");
 assert((nanoblast::crc32_update(~0u,text,9)^~0u)==0xcbf43926);
 std::vector<uint8_t> data(4097);uint32_t rng=0x39abcd67;
 for(auto &v:data){rng=rng*1664525u+1013904223u;v=rng>>24;}
 for(unsigned n=0;n<=data.size();n+=17){
  for(uint32_t start:{0u,~0u,0x12345678u}){
   const auto full=nanoblast::crc32_update(start,data.data(),n);
   assert(full==reference(start,data.data(),n));
   auto split=nanoblast::crc32_update(start,data.data(),n/2);
   assert(nanoblast::crc32_update(split,data.data()+n/2,n-n/2)==full);
  }
 }
}
