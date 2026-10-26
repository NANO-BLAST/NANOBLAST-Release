#pragma once
#include <string>
#include <cstdint>
using FRESULT=int;
constexpr int FR_OK=0,FR_DISK_ERR=1,FR_NO_FILE=4,FR_NO_PATH=5,AM_DIR=0x10;
struct FILINFO {unsigned fsize,fattrib;char fname[256]={};};
struct DIR {std::string path;unsigned index=0;};
FRESULT f_stat(const char*,FILINFO*);
FRESULT f_opendir(DIR*,const char*);
FRESULT f_readdir(DIR*,FILINFO*);
FRESULT f_closedir(DIR*);
uint64_t bflb_mtimer_get_time_ms();
