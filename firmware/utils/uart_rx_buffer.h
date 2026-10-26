// Single-producer (UART interrupt), single-consumer (parser task) byte queue.
#pragma once
#include <cstdint>
class UartRxBuffer {
    uint8_t data_[1024]{};
    uint32_t head_=0,tail_=0,dropped_=0,received_=0;
public:
    bool push(uint8_t byte) {
        const auto head=__atomic_load_n(&head_,__ATOMIC_RELAXED);
        const auto next=(head+1)&1023u;
        __atomic_add_fetch(&received_,1u,__ATOMIC_RELAXED);
        if(next==__atomic_load_n(&tail_,__ATOMIC_ACQUIRE)){__atomic_add_fetch(&dropped_,1u,__ATOMIC_RELAXED);return false;}
        data_[head]=byte;
        __atomic_store_n(&head_,next,__ATOMIC_RELEASE);
        return true;
    }
    int pop() {
        const auto tail=__atomic_load_n(&tail_,__ATOMIC_RELAXED);
        if(tail==__atomic_load_n(&head_,__ATOMIC_ACQUIRE))return -1;
        const auto byte=data_[tail];
        __atomic_store_n(&tail_,(tail+1)&1023u,__ATOMIC_RELEASE);
        return byte;
    }
    uint32_t received()const{return __atomic_load_n(&received_,__ATOMIC_RELAXED);}
    uint32_t dropped()const{return __atomic_load_n(&dropped_,__ATOMIC_RELAXED);}
};
