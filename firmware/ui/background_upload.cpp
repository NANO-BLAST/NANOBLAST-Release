// NANOBLAST NBBG0001 artwork loader. GPL-3.0.
#include "background_upload.h"
#include "../storage/crc32.h"
#include <cstring>
namespace nanoblast {
static uint32_t u32(const uint8_t*p){return p[0]|uint32_t(p[1])<<8|uint32_t(p[2])<<16|uint32_t(p[3])<<24;}
static uint32_t crc(uint32_t c,const uint8_t*p,unsigned n){return crc32_update(c,p,n);}
BackgroundResult upload_background(AssetSource&s,BackgroundTransport&t){
 t.enable(false);
 uint8_t header[32],colors[768],buffer[1024];
 if(s.size()!=922400)return BackgroundResult::Invalid;
 if(!s.read(header,32))return BackgroundResult::ReadError;
 if(std::memcmp(header,"NBBG0001",8)||u32(header+8)!=((720u<<16)|1280u)||u32(header+12)!=((1u<<16)|256u)||u32(header+16)!=922368||u32(header+24)||u32(header+28))return BackgroundResult::Invalid;
 if(!s.read(colors,768))return BackgroundResult::ReadError;
 uint32_t c=crc(0xffffffffu,colors,768);
 for(unsigned i=0;i<256;i++)t.palette((i<<24)|(uint32_t(colors[i*3])<<16)|(uint32_t(colors[i*3+1])<<8)|colors[i*3+2]);
 unsigned last_progress=0;
 for(unsigned offset=0;offset<921600;offset+=sizeof buffer){
  if(!s.read(buffer,sizeof buffer))return BackgroundResult::ReadError;
  c=crc(c,buffer,sizeof buffer);
  if(!t.pixels(0x00200000u+offset,buffer,sizeof buffer))return BackgroundResult::TransportError;
  unsigned next=(offset+sizeof buffer)*26/921600;
  if(next!=last_progress){t.progress(offset+sizeof buffer,921600);last_progress=next;}
 }
 if((c^0xffffffffu)!=u32(header+20))return BackgroundResult::Invalid;
 t.enable(true);return BackgroundResult::Ready;
}
}
