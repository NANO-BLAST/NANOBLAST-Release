#pragma once
#include <cstdint>
#include <cstdio>
#include <cstring>
void fpga_tx_header(int,int);
void fpga_tx_byte(uint8_t);
void delay(int);
void get_joypad_states(uint16_t*,uint16_t*,uint16_t*,uint16_t*);
#define taskENTER_CRITICAL() do {} while(0)
#define taskEXIT_CRITICAL() do {} while(0)
