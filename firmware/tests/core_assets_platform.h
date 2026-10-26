#pragma once
#include <cstdint>
#include <string>
using UINT=unsigned;using FRESULT=int;
constexpr int FR_OK=0,FR_DISK_ERR=1,FR_NO_FILE=4,FR_NO_PATH=5,FR_EXIST=8;
constexpr int FA_READ=1,FA_WRITE=2,FA_CREATE_NEW=4;
struct FIL{std::string path;unsigned position=0;};
struct FILINFO{uint32_t fsize;};
FRESULT f_open(FIL*,const char*,unsigned);FRESULT f_close(FIL*);FRESULT f_stat(const char*,FILINFO*);
FRESULT f_read(FIL*,void*,unsigned,UINT*);FRESULT f_write(FIL*,const void*,unsigned,UINT*);
FRESULT f_sync(FIL*);FRESULT f_mkdir(const char*);FRESULT f_rename(const char*,const char*);FRESULT f_unlink(const char*);
uint32_t f_size(FIL*);uint32_t bflb_flash_get_size();int bflb_flash_read(uint32_t,void*,unsigned);
void overlay_clear();void overlay_status(const char*,...);
