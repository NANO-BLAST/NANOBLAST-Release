// Onboard SD access through the FPGA UART bridge. GPL-3.0.
#pragma once
#include <cstdint>
void fpga_sd_register();
void fpga_sd_reply_begin(unsigned length);
void fpga_sd_reply_byte(unsigned index,uint8_t value);
const char *fpga_sd_diagnostic();
