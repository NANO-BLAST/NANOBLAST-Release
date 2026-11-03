#include <cassert>
#include <deque>
#include <vector>
#include "uart_receive_platform.h"
#define NANOBLAST_UART_RECEIVE_HOST_TEST
#include "../utils/uart_receive.cpp"
Device device{7};Device*uart1_dev=&device;
std::deque<uint8_t> fifo;std::vector<int> order;bool sem=false;unsigned irq_status=0,clears=0;void(*handler)(int,void*);
SemaphoreHandle_t xSemaphoreCreateBinary(){return &sem;}
void xSemaphoreGiveFromISR(SemaphoreHandle_t s,BaseType_t*){*s=true;}
int xSemaphoreTake(SemaphoreHandle_t s,unsigned){bool b=*s;*s=false;return b;}
unsigned bflb_uart_get_intstatus(Device*){return irq_status;}
void bflb_uart_int_clear(Device*,unsigned){order.push_back(3);}
bool bflb_uart_rxavailable(Device*){return !fifo.empty();}
uint8_t bflb_uart_getchar(Device*){auto b=fifo.front();fifo.pop_front();return b;}
int bflb_uart_feature_control(Device*,int cmd,std::size_t){assert(cmd==UART_CMD_CLR_RX_FIFO);order.push_back(2);fifo.clear();++clears;return 0;}
void bflb_uart_rxint_mask(Device*,bool masked){order.push_back(masked?1:5);}
void bflb_irq_attach(int,void(*f)(int,void*),void*){order.push_back(4);handler=f;}
void bflb_irq_enable(int){order.push_back(6);}
int main(){
 fifo={0xaa,0,2};start_uart_receive();assert(fifo.empty()&&clears==1);
 assert((order==std::vector<int>{1,2,3,4,5,6}));assert(uart_receive_byte()==-1);
 fifo={0xaa,0,2,1,5};irq_status=UART_INTSTS_RTO;handler(7,nullptr);
 for(int b:{0xaa,0,2,1,5})assert(uart_receive_byte()==b);assert(uart_receive_byte()==-1);
 fifo={0xaa,0};irq_status=UART_INTSTS_RX_FER;handler(7,nullptr);assert(clears==2&&fifo.empty()&&uart_receive_byte()==-1);
 fifo={0xaa,0,2,1,1};irq_status=UART_INTSTS_RTO;handler(7,nullptr);
 for(int b:{0xaa,0,2,1,1})assert(uart_receive_byte()==b);assert(uart_receive_byte()==-1);
}
