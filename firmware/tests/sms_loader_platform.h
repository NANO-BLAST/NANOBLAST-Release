#pragma once
#include <cstdint>
using UINT=unsigned;using FRESULT=int;
constexpr int FR_OK=0,FR_DISK_ERR=1,FR_INT_ERR=2,FR_INVALID_NAME=6,FR_TIMEOUT=15,FR_INVALID_PARAMETER=19,FA_READ=1;
struct FIL{unsigned position=0;};
extern FIL fcore;extern uint8_t fbuf[1024];extern bool core_running;
FRESULT f_open(FIL*,const char*,unsigned);FRESULT f_close(FIL*);FRESULT f_lseek(FIL*,unsigned);
FRESULT f_read(FIL*,void*,unsigned,UINT*);unsigned f_size(FIL*);
void overlay_message(const char*,int);void overlay_status(const char*,...);void overlay(int);
void set_loading_state(int);void send_fbuf_data(unsigned);int get_fpga_load_status();
bool get_fpga_debug(uint8_t,uint32_t*);
uint64_t bflb_mtimer_get_time_ms();void delay(unsigned);

uint32_t get_core_config();void set_core_config(uint32_t);
