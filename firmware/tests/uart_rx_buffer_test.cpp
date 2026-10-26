#include "../utils/uart_rx_buffer.h"
#include <cassert>
#include <thread>
int main(){
    UartRxBuffer rx;
    // A full 32-byte SD reply plus its header exceeds the hardware FIFO.
    // The interrupt queue must retain it even while the parser is asleep.
    for(unsigned i=0;i<37;i++)assert(rx.push(uint8_t(i)));
    for(unsigned i=0;i<37;i++)assert(rx.pop()==int(i));
    assert(rx.pop()==-1&&rx.dropped()==0);
    for(unsigned i=0;i<1023;i++)assert(rx.push(uint8_t(i)));
    assert(!rx.push(0xaa)&&rx.dropped()==1);
    for(unsigned i=0;i<1023;i++)assert(rx.pop()==int(uint8_t(i)));
    assert(rx.pop()==-1);
    for(unsigned round=0;round<20;round++){
        for(unsigned i=0;i<45;i++)assert(rx.push(uint8_t(i+round)));
        for(unsigned i=0;i<45;i++)assert(rx.pop()==int(uint8_t(i+round)));
    }
    UartRxBuffer concurrent;
    std::thread producer([&]{for(unsigned i=0;i<100000;i++)while(!concurrent.push(uint8_t(i)))std::this_thread::yield();});
    for(unsigned i=0;i<100000;i++){
        int value;while((value=concurrent.pop())<0)std::this_thread::yield();
        assert(value==int(uint8_t(i)));
    }
    producer.join();assert(concurrent.pop()==-1);
}
