// Direct SPI flash transactions through the still-running FPGA. GPL-3.0.
#pragma once
#include <cstdint>
void fpga_flash_register();
void fpga_flash_reply_begin(unsigned command,unsigned length);
void fpga_flash_reply_byte(unsigned index,uint8_t value);
bool fpga_flash_available();
bool fpga_flash_transfer(bool high,const uint8_t *tx,uint8_t *rx,unsigned length);
