#pragma once
#include <cstdint>
extern "C" {
#include "ff.h"
}
void overlay_clear();void overlay_status(const char*,...);
void overlay_cursor(int,int);void overlay_printf(const char*,...);
const char *fpga_sd_diagnostic();
