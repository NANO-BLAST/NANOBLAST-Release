#pragma once
#include <cstdint>
#include <cstring>
#include "compressed_core.h"
namespace nanoblast {
inline uint32_t image_word(const uint8_t*p){return uint32_t(p[0])|(uint32_t(p[1])<<8)|(uint32_t(p[2])<<16)|(uint32_t(p[3])<<24);}
inline bool configuration_footer(const uint8_t*p,uint32_t &checksum){
 if(p[0]!=0x0a||p[16]!=0x08)return false;
 for(unsigned i=1;i<6;i++)if(p[i])return false;
 for(unsigned i=8;i<16;i++)if(p[i]!=255)return false;
 for(unsigned i=17;i<20;i++)if(p[i])return false;
 for(unsigned i=20;i<30;i++)if(p[i]!=255)return false;
 checksum=(uint32_t(p[6])<<8)|p[7];return true;
}
struct CoreImageSource {uint32_t base,length,checksum;};
// Validate metadata/footer without copying the immutable auxiliary image.
// Callers must check its full payload CRC before configuring or erasing flash.
template<class Read> bool builtin_core_source(Read read,unsigned id,CoreImageSource &source){
 uint32_t length,checksum;uint8_t footer[30];uint32_t config;
 if(!compressed_core_info(read,id,length,checksum)||!compressed_core_read(read,id,length-30,footer,30)||!configuration_footer(footer,config))return false;
 source={PackedCoreBase|id,length,checksum};return true;
}
}
