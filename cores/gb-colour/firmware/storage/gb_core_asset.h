#pragma once
#include <cstdint>
namespace nanoblast {
using CoreRead=bool(*)(uint32_t,uint8_t*,unsigned);
constexpr uint32_t GBPackedBase=0x80000000u;
bool gb_core_info(CoreRead read,uint32_t &length,uint32_t &checksum);
bool gb_core_read(CoreRead read,uint32_t offset,uint8_t *data,unsigned length);
inline bool core_image_read(CoreRead read,uint32_t base,uint32_t off,uint8_t*p,unsigned n){
 return base==GBPackedBase?gb_core_read(read,off,p,n):read(base+off,p,n);
}
}
