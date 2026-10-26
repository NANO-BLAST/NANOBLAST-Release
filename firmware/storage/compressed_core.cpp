// One decoder and one bounded buffer pair shared by all four cores. GPL-3.0.
#include "compressed_core.h"
#include "compressed_core_slots.h"
#include "crc32.h"
#include "xz/xz.h"
#include <algorithm>
#include <cstring>
namespace nanoblast {
namespace {
constexpr unsigned BlockBytes=65536,ImageBytes=907418,Blocks=(ImageBytes+BlockBytes-1)/BlockBytes;
uint32_t word(const uint8_t*p){return uint32_t(p[0])|uint32_t(p[1])<<8|uint32_t(p[2])<<16|uint32_t(p[3])<<24;}
bool supported(unsigned id){return id==1||id==5||id==7||id==2;}
struct Header {
 unsigned id;uint32_t base,bytes,crc,meta,directory;
 uint32_t pos[Blocks],size[Blocks];
};
Header current;CoreRead reader=nullptr;bool known=false;uint32_t cached_block=~0u;
uint8_t decoded[BlockBytes],compressed[BlockBytes];
struct xz_dec *decoder=nullptr;
bool load(CoreRead read,unsigned id){
 if(!read||!supported(id))return false;
 Header next{};unsigned seen=0;
 for(unsigned i=0;i<4;i++){
  const CoreSlot &slot=CoreSlots[i];unsigned core=slot.id;uint32_t base=slot.base,bytes=slot.bytes;
  if(!supported(core)||seen&(1u<<core)||base%4096||base<CoreBankBegin||base>=CoreBankEnd||bytes<=4096||bytes>ImageBytes+4096||bytes>CoreBankEnd-base)return false;
  const uint32_t span=(bytes+4095)&~4095u;if(span>CoreBankEnd-base)return false;
  for(unsigned j=0;j<i;j++){
   const uint32_t other=CoreSlots[j].base,end=other+((CoreSlots[j].bytes+4095)&~4095u);
   if(base<end&&other<base+span)return false;
  }
  seen|=1u<<core;
  if(core==id){next.id=id;next.base=base;next.bytes=bytes;next.meta=slot.meta;next.directory=CoreLayoutRevision;}
 }
 if(!next.base)return false;
 uint8_t head[64],table[Blocks*8];
 if(!read(next.base,head,sizeof head)||!read(next.base+64,table,sizeof table))return false;
 if(std::memcmp(head,"NBCRXZ01",8)||word(head+8)!=id||word(head+12)!=ImageBytes||word(head+20)!=0x4b30324e||word(head+24)!=next.bytes-4096||word(head+28)!=Blocks||word(head+32)!=BlockBytes||word(head+36)!=next.meta)return false;
 for(unsigned i=40;i<64;i++)if(head[i])return false;
 uint32_t crc=crc32_update(~0u,head,36);crc=crc32_update(crc,head+40,24);crc=crc32_update(crc,table,sizeof table)^~0u;
 if(crc!=next.meta)return false;
 uint32_t end=4096;
 for(unsigned i=0;i<Blocks;i++){
  const uint8_t*p=table+8*i;const uint32_t start=word(p),encoded=word(p+4),bytes=encoded&0x7fffffffu;
  const unsigned expected=std::min(BlockBytes,ImageBytes-i*BlockBytes);
  if(start!=end||!bytes||bytes>expected||(encoded&0x80000000u&&bytes!=expected)||start>next.bytes||bytes>next.bytes-start)return false;
  next.pos[i]=start;next.size[i]=encoded;end+=bytes;
 }
 if(end!=next.bytes)return false;
 next.crc=word(head+16);
 if(!known||reader!=read||current.id!=id||current.base!=next.base||current.bytes!=next.bytes||current.meta!=next.meta||current.directory!=next.directory)cached_block=~0u;
 current=next;reader=read;known=true;return true;
}
bool block(unsigned index){
 if(index==cached_block)return true;cached_block=~0u;
 if(index>=Blocks)return false;
 const uint32_t encoded=current.size[index],n=encoded&0x7fffffffu;
 const unsigned expected=std::min(BlockBytes,ImageBytes-index*BlockBytes);
 if(!reader(current.base+current.pos[index],compressed,n))return false;
 if(encoded&0x80000000u)std::memcpy(decoded,compressed,expected);
 else {
  if(!decoder){xz_crc32_init();decoder=xz_dec_init(XZ_SINGLE,0);}
  if(!decoder)return false;xz_dec_reset(decoder);
  struct xz_buf b={compressed,0,n,decoded,0,expected};
  if(xz_dec_run(decoder,&b)!=XZ_STREAM_END||b.in_pos!=n||b.out_pos!=expected)return false;
 }
 cached_block=index;return true;
}
}
void compressed_core_reset(){known=false;reader=nullptr;cached_block=~0u;}
bool compressed_core_info(CoreRead read,unsigned id,uint32_t&length,uint32_t&checksum){
 if(!load(read,id)){compressed_core_reset();return false;}
 length=ImageBytes;checksum=current.crc;return true;
}
bool compressed_core_read(CoreRead read,unsigned id,uint32_t off,uint8_t*p,unsigned n){
 if((!p&&n)||!supported(id)||off>ImageBytes||n>ImageBytes-off)return false;
 if((!known||reader!=read||current.id!=id)&&!load(read,id)){compressed_core_reset();return false;}
 while(n){unsigned index=off/BlockBytes,inside=off%BlockBytes,take=std::min(n,BlockBytes-inside);
  if(!block(index))return false;std::memcpy(p,decoded+inside,take);off+=take;p+=take;n-=take;
 }return true;
}
}
