#pragma once
#include "usb_rom_service.h"
extern "C" {
#include "ff.h"
}
namespace nanoblast::usbrom {
class FatFiles:public Files {
 FIL file_{};bool open_=false,owned_=false;char dest_[MaxPath+5]{},temp_[MaxPath+24]{};
 public:bool list(const char*,uint32_t,Entry&,bool&)override;
 bool begin(const char*,uint32_t)override;
 bool append(const uint8_t*,unsigned)override;
 bool commit(uint32_t,uint32_t)override;
 void abort()override;
};
}
