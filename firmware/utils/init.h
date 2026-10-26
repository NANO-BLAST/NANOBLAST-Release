#pragma once
#include <cstdint>

extern void init_gpio_and_uart();
void start_uart_receive();
void uart_receive_wait();
int uart_receive_byte();
uint32_t uart_receive_count();
uint32_t uart_receive_dropped();
