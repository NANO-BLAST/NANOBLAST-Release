#pragma once
#include <cstdint>
namespace nanoblast {
// Reflected IEEE CRC32, kept unfinalized for streaming. A small nibble table
// replaces eight conditional shifts per byte without a 1KiB lookup table.
inline uint32_t crc32_update(uint32_t state,const uint8_t*data,unsigned length){
 static constexpr uint32_t table[16]={0x00000000,0x1db71064,0x3b6e20c8,0x26d930ac,
  0x76dc4190,0x6b6b51f4,0x4db26158,0x5005713c,0xedb88320,0xf00f9344,
  0xd6d6a3e8,0xcb61b38c,0x9b64c2b0,0x86d3d2d4,0xa00ae278,0xbdbdf21c};
 while(length--){state^=*data++;state=(state>>4)^table[state&15];state=(state>>4)^table[state&15];}
 return state;
}
}
