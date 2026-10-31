// NanoBlast USB ROM transfer protocol. GPL-3.0; see COPYING.NANOBLAST.
#pragma once
#include <cstdint>
#include <cstddef>
namespace nanoblast::usbrom {
constexpr unsigned MaxPayload=1024, MaxPath=160;
constexpr uint32_t MaxRom=64*1024*1024;
struct Entry { char name[MaxPath+1]{}; uint32_t size=0; bool directory=false; };
struct Files {
 virtual ~Files()=default;
 virtual bool list(const char*,uint32_t,Entry&,bool&)=0;
 virtual bool begin(const char*,uint32_t)=0;
 virtual bool append(const uint8_t*,unsigned)=0;
 virtual bool commit(uint32_t,uint32_t)=0;
 virtual void abort()=0;
};
bool valid_path(const char*,bool rom);
uint32_t get32(const uint8_t*);
void put32(uint8_t*,uint32_t);
class Service {
 Files &files_; bool hello_=false,upload_=false; uint32_t size_=0,offset_=0,crc_=0xffffffff,wanted_=0;
 public:
 explicit Service(Files &f):files_(f){}
 void disconnect();
 // Response payload; status 0=ok, 1=invalid, 2=busy/state, 3=filesystem, 4=checksum.
 unsigned request(uint8_t op,const uint8_t*data,unsigned n,uint8_t*out,uint8_t &status);
};
}
