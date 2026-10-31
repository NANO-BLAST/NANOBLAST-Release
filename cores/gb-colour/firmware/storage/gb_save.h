// Battery RAM and MBC3 clock persistence. GPL-3.0.
#pragma once
#include <cstdint>
bool gb_save_flush();
void gb_save_service();
void gb_save_forget();
bool gb_save_restore(const char *path,uint32_t crc,unsigned length,unsigned type,unsigned ram_code);
const char *gb_save_status();
