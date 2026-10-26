#pragma once
#include <cstdint>
namespace nanoblast {
enum class BootFlashFailure {Length,SourceRead,SourceCRC,Erase,Program,VerifyRead,VerifyCRC};
struct BootFlashIO {
 virtual ~BootFlashIO()=default;
 virtual void progress(unsigned,unsigned,bool){}
 virtual void failure(BootFlashFailure,uint32_t){}
 virtual bool source(uint32_t,uint8_t*,unsigned)=0;
 virtual bool read(uint32_t,uint8_t*,unsigned)=0;
 virtual bool erase64k(uint32_t)=0;
 virtual bool page(uint32_t,const uint8_t*,unsigned)=0;
};
// Always validate the complete source before erasing. Readback is optional;
// recovery callers retain the default full verification even if the menu opts out.
// The caller checks the physical flash identity and keeps a known NES recovery source.
bool persist_core(BootFlashIO&,uint32_t length,uint32_t checksum,bool verify=true);
}
