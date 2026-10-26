#include "crc32.h"
#include "persistent_core.h"
namespace nanoblast {
namespace {
uint32_t crc(uint32_t c,const uint8_t*p,unsigned n){return nanoblast::crc32_update(c,p,n);}
}
bool persist_core(BootFlashIO &io,uint32_t length,uint32_t checksum,bool verify){
 auto fail=[&](BootFlashFailure why,uint32_t offset){io.failure(why,offset);return false;};
 if(length!=907418)return fail(BootFlashFailure::Length,length);
 uint8_t buffer[1024];uint32_t check=0xffffffffu;
 for(uint32_t off=0;off<length;){
  unsigned n=length-off>sizeof buffer?sizeof buffer:length-off;
  if(!io.source(off,buffer,n))return fail(BootFlashFailure::SourceRead,off);check=crc(check,buffer,n);off+=n;
 }
 if((check^0xffffffffu)!=checksum)return fail(BootFlashFailure::SourceCRC,check^0xffffffffu);
 for(uint32_t off=0;off<length;){
  if(off%65536==0)io.progress(off,length,false);
  if(off%65536==0&&!io.erase64k(off))return fail(BootFlashFailure::Erase,off);
  // Page programming remains bounded to the physical flash's 256-byte pages.
  unsigned n=length-off>256?256:length-off;
  if(!io.source(off,buffer,n))return fail(BootFlashFailure::SourceRead,off);
  if(!io.page(off,buffer,n))return fail(BootFlashFailure::Program,off);off+=n;
 }
 io.progress(length,length,false);
 if(!verify)return true;
 check=0xffffffffu;
 for(uint32_t off=0;off<length;){
  if(off%65536==0)io.progress(off,length,true);
  unsigned n=length-off>sizeof buffer?sizeof buffer:length-off;
  if(!io.read(off,buffer,n))return fail(BootFlashFailure::VerifyRead,off);check=crc(check,buffer,n);off+=n;
 }
 io.progress(length,length,true);
 return (check^0xffffffffu)==checksum || fail(BootFlashFailure::VerifyCRC,check^0xffffffffu);
}
}
