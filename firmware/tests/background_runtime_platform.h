#pragma once
#include "background_setup_platform.h"
using SemaphoreHandle_t=bool*;
constexpr int pdTRUE=1;
SemaphoreHandle_t xSemaphoreCreateBinary();
int xSemaphoreTake(SemaphoreHandle_t,unsigned);
void xSemaphoreGive(SemaphoreHandle_t);
void fpga_tx_header(int,int);void fpga_tx_byte(uint8_t);
uint64_t bflb_mtimer_get_time_ms();void dprint(const char*,...);
#define pdMS_TO_TICKS(n) (n)
#define taskENTER_CRITICAL() do {} while(0)
#define taskEXIT_CRITICAL() do {} while(0)
