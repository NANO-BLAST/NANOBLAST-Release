#include "crc32.h"
#include "core_stage.h"
#include <cstring>
namespace nanoblast {
namespace {
constexpr uint8_t owner[8]={'N','B','C','A','C','H','E','1'};
uint32_t crc(uint32_t c,const uint8_t*p,unsigned n){return nanoblast::crc32_update(c,p,n);}
void put32(uint8_t*p,uint32_t v){for(unsigned i=0;i<4;i++)p[i]=v>>(i*8);}
}
StageResult stage_core(StageIO&io,uint32_t length){
 if(!length||length>CacheSize-4096||io.flash_size()<CacheStart+CacheSize)return StageResult::TooLarge;
 uint8_t buffer[1024];
 if(!io.read_flash(CacheStart,buffer,8))return StageResult::FlashError;
 if(std::memcmp(buffer,owner,8)) {
  // Never overwrite an unrelated image or data in the proposed cache slot.
  for(uint32_t a=CacheStart;a<CacheStart+CacheSize;a+=sizeof buffer){
   if(!io.read_flash(a,buffer,sizeof buffer))return StageResult::FlashError;
   for(uint8_t b:buffer)if(b!=255)return StageResult::ForeignData;
  }
 }
 if(!io.erase_flash(CacheStart,4096))return StageResult::FlashError;
 // Flash writes temporarily disable XIP. The source must live in RAM, even
 // for this short marker; a pointer to constexpr rodata is unsafe here.
 std::memcpy(buffer,owner,8);
 if(!io.write_flash(CacheStart,buffer,8)||!io.read_flash(CacheStart,buffer,8))return StageResult::FlashError;
 if(std::memcmp(buffer,owner,8))return StageResult::VerifyError;
 io.staging_started();
 uint32_t checksum=0xffffffffu;
 for(uint32_t offset=0;offset<length;){
  unsigned n=length-offset>sizeof buffer?sizeof buffer:length-offset;
  if(offset%4096==0 && !io.erase_flash(CacheData+offset,4096))return StageResult::FlashError;
  if(!io.read_source(buffer,n))return StageResult::ReadError;
  checksum=crc(checksum,buffer,n);
  if(!io.write_flash(CacheData+offset,buffer,n))return StageResult::FlashError;
  offset+=n;if(offset%65536==0||offset==length)io.progress(offset,length);
 }
 uint32_t verified=0xffffffffu;
 for(uint32_t offset=0;offset<length;){
  unsigned n=length-offset>sizeof buffer?sizeof buffer:length-offset;
  if(!io.read_flash(CacheData+offset,buffer,n))return StageResult::FlashError;
  verified=crc(verified,buffer,n);offset+=n;
 }
 if(verified!=checksum||!io.source_checksum_matches(checksum^0xffffffffu))return StageResult::VerifyError;
 put32(buffer,length);put32(buffer+4,checksum^0xffffffffu);
 if(!io.write_flash(CacheStart+8,buffer,8))return StageResult::FlashError;
 uint8_t expected[16];
 std::memcpy(expected,owner,8);put32(expected+8,length);put32(expected+12,checksum^0xffffffffu);
 if(!io.read_flash(CacheStart,buffer,sizeof expected))return StageResult::FlashError;
 if(std::memcmp(buffer,expected,sizeof expected))return StageResult::VerifyError;
 return StageResult::Ready;
}
}
