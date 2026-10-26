// Temporary SD-to-BL616-flash staging, GPL-3.0.
#pragma once
#include <cstdint>
namespace nanoblast {
constexpr uint32_t CacheStart=0x100000,CacheSize=0xdf000,CacheData=CacheStart+4096;
struct StageIO {
 virtual ~StageIO()=default;
 virtual void staging_started(){}
 virtual void progress(unsigned,unsigned){}
 virtual bool source_checksum_matches(uint32_t){return true;}
 virtual uint32_t flash_size()=0;
 virtual bool read_source(uint8_t*,unsigned)=0;
 virtual bool read_flash(uint32_t,uint8_t*,unsigned)=0;
 virtual bool write_flash(uint32_t,const uint8_t*,unsigned)=0;
 virtual bool erase_flash(uint32_t,unsigned)=0;
};
enum class StageResult {Ready,TooLarge,ForeignData,ReadError,FlashError,VerifyError};
StageResult stage_core(StageIO&,uint32_t length);
}
