// CRC protected GB save bridge client. GPL-3.0.
#pragma once
#include <cstdint>
void gb_save_reply_begin(unsigned length);
void gb_save_reply_byte(unsigned position,uint8_t value);
bool gb_save_request(uint8_t op,unsigned offset,unsigned count,const uint8_t *data,uint8_t *reply,unsigned reply_bytes);
