#pragma once
#include <cstdint>
#include <string>
using FRESULT=int;
constexpr int FR_OK=0,FR_DISK_ERR=1,FR_NO_PATH=5,AM_DIR=0x10,OSD_KEY_CODE=0x84;
struct DIR {std::string path;unsigned index=0;};
struct FILINFO {char fname[256];unsigned fattrib;};
FRESULT f_opendir(DIR*,const char*);FRESULT f_readdir(DIR*,FILINFO*);FRESULT f_closedir(DIR*);
void overlay_clear();void overlay_status(const char*,...);void overlay_printf(const char*,...);
void overlay_cursor(int,int);void delay(int);
void get_joypad_states(uint16_t*,uint16_t*,uint16_t*,uint16_t*);
int joy_choice(int,int,int*,int,bool=true);
