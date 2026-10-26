// Streaming, lossless artwork decompression. GPL-3.0.
#pragma once
#include "background_upload.h"
namespace nanoblast {
// NBLZ0001: magic[8], decoded size LE32, reserved zero LE32; groups of
// 8 tokens, LSB-first flag (0=literal, 1=LE16 backreference). Backreferences
// encode (distance-1)<<4 | (length-3), window 4096, length 3..18.
class CompressedBackground : public AssetSource {
 AssetSource &source_;
 uint8_t history_[4096]{},input_[512];
 unsigned used_=0,available_=0,consumed_=16,produced_=0;
 unsigned bits_=0,flags_=0,match_=0,distance_=0;
 bool valid_=false;
 const char *failure_="header";
 bool byte(uint8_t&);
public:
 explicit CompressedBackground(AssetSource&);
 uint32_t size()override{return valid_?922400:0;}
 bool read(uint8_t*,unsigned)override;
 uint32_t decoded_bytes()const{return produced_;}
 uint32_t packed_bytes()const{return consumed_;}
 const char *failure_reason()const{return failure_;}
};
}
