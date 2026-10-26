// Immutable, contiguous XZ core assets. GPL-3.0.
#pragma once
#include <cstdint>
namespace nanoblast {
using CoreRead=bool(*)(uint32_t,uint8_t*,unsigned);
constexpr uint32_t CoreBankBegin=0x201000,CoreBankEnd=0x3ff000;
constexpr uint32_t PackedCoreBase=0x80000000u;
bool compressed_core_info(CoreRead,unsigned,uint32_t&,uint32_t&);
bool compressed_core_read(CoreRead,unsigned,uint32_t,uint8_t*,unsigned);
void compressed_core_reset();
inline bool core_image_read(CoreRead read,uint32_t base,uint32_t off,uint8_t*p,unsigned n){
 if((base&0xffff0000u)==PackedCoreBase)return compressed_core_read(read,base&0xffff,off,p,n);
 if(base>=0x400000||off>0x400000-base||n>0x400000-base-off)return false;
 return read(base+off,p,n);
}
}
