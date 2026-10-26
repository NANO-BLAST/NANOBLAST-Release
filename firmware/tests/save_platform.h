#pragma once
#include <cstdint>
#include <string>
using UINT=unsigned;
using FRESULT=int;
constexpr int FR_OK=0,FR_DISK_ERR=1,FR_NO_FILE=4,FR_NO_PATH=5;
constexpr unsigned FA_READ=1,FA_WRITE=2,FA_CREATE_ALWAYS=8,AM_DIR=16;
struct FIL {std::string path;unsigned position=0;};
struct FILINFO {unsigned fattrib=0;};
FRESULT f_open(FIL*,const char*,unsigned);
FRESULT f_close(FIL*);
FRESULT f_read(FIL*,void*,unsigned,UINT*);
FRESULT f_write(FIL*,const void*,unsigned,UINT*);
FRESULT f_sync(FIL*);
FRESULT f_lseek(FIL*,unsigned);
unsigned f_size(FIL*);
FRESULT f_stat(const char*,FILINFO*);
FRESULT f_mkdir(const char*);
