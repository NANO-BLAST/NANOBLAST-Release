#include "utils.h"
#include "init.h"
#include "uart_rx_buffer.h"
namespace {
UartRxBuffer received;
SemaphoreHandle_t wake;
void receive_interrupt(int,void*) {
    auto status=bflb_uart_get_intstatus(uart1_dev);
    if(status&UART_INTSTS_RTO)bflb_uart_int_clear(uart1_dev,UART_INTCLR_RTO);
    while(bflb_uart_rxavailable(uart1_dev))received.push(bflb_uart_getchar(uart1_dev));
    BaseType_t task_woken=pdFALSE;
    xSemaphoreGiveFromISR(wake,&task_woken);
    portYIELD_FROM_ISR(task_woken);
}
}
void start_uart_receive(){
    // Called by the receive task after the scheduler starts, before enabling IRQs.
    wake=xSemaphoreCreateBinary();
    configASSERT(wake);
    bflb_irq_attach(uart1_dev->irq_num,receive_interrupt,nullptr);
    bflb_uart_rxint_mask(uart1_dev,false);
    bflb_irq_enable(uart1_dev->irq_num);
}
void uart_receive_wait(){xSemaphoreTake(wake,pdMS_TO_TICKS(10));}
int uart_receive_byte(){return received.pop();}
uint32_t uart_receive_count(){return received.received();}
uint32_t uart_receive_dropped(){return received.dropped();}
