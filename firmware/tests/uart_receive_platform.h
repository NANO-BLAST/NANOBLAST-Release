#pragma once
#include <cstdint>
#include <cstddef>
struct Device{int irq_num;};extern Device*uart1_dev;
using SemaphoreHandle_t=bool*;using BaseType_t=int;
constexpr int pdFALSE=0;constexpr unsigned UART_INTSTS_RX_FER=128,UART_INTSTS_RTO=16,UART_INTCLR_RTO=16,UART_CMD_CLR_RX_FIFO=6;
#define pdMS_TO_TICKS(n) (n)
#define configASSERT(x) assert(x)
#define portYIELD_FROM_ISR(x) do{(void)(x);}while(0)
SemaphoreHandle_t xSemaphoreCreateBinary();
void xSemaphoreGiveFromISR(SemaphoreHandle_t,BaseType_t*);
int xSemaphoreTake(SemaphoreHandle_t,unsigned);
unsigned bflb_uart_get_intstatus(Device*);void bflb_uart_int_clear(Device*,unsigned);
bool bflb_uart_rxavailable(Device*);uint8_t bflb_uart_getchar(Device*);
int bflb_uart_feature_control(Device*,int,std::size_t);
void bflb_uart_rxint_mask(Device*,bool);
void bflb_irq_attach(int,void(*)(int,void*),void*);void bflb_irq_enable(int);
