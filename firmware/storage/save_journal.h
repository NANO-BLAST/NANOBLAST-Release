// Alternating, CRC-checked SD records. GPL-3.0; NANOBLAST.
#pragma once
#include <cstdint>
#include <string>
namespace nanoblast {
struct SaveRecord {uint32_t sequence=0;unsigned slot=0;uint8_t auxiliary[16]={};};
enum class SaveScan { Missing, Valid, Damaged };
SaveScan save_scan(const std::string &prefix,uint32_t kind,uint32_t identity,uint32_t identity_size,unsigned bytes,SaveRecord &record);
bool save_read(const std::string &prefix,const SaveRecord &record,uint8_t *data,unsigned bytes);
bool save_commit(const std::string &prefix,uint32_t kind,uint32_t identity,uint32_t identity_size,const uint8_t auxiliary[16],const uint8_t *data,unsigned bytes,SaveRecord &record,bool existing);
bool save_directory(const std::string &path);
}
