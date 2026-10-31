#pragma once
#include <cstdint>
struct Semaphore {unsigned count=0;};
using SemaphoreHandle_t=Semaphore*;
constexpr int pdTRUE=1;
#define pdMS_TO_TICKS(x) (x)
#define taskENTER_CRITICAL() do{}while(0)
#define taskEXIT_CRITICAL() do{}while(0)
SemaphoreHandle_t xSemaphoreCreateBinary();
int xSemaphoreTake(SemaphoreHandle_t,unsigned);
void xSemaphoreGive(SemaphoreHandle_t);
void fpga_tx_header(unsigned,unsigned);
void fpga_tx_byte(uint8_t);
