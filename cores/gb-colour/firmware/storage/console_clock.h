// Manual local-time clock. Advances only while powered. GPL-3.0.
#pragma once
#include <cstdint>
namespace nanoblast {
struct ClockDate {unsigned year=2026,month=10,day=25,hour=0,minute=0,second=0;};
bool valid_clock_date(const ClockDate &);
uint64_t clock_seconds(const ClockDate &);
ClockDate clock_date(uint64_t seconds);
uint64_t advance_game_clock(uint64_t rtc,int64_t seconds);
}
uint64_t nanoblast_clock_now();
int64_t nanoblast_clock_adjustment();
bool nanoblast_clock_is_set();
bool nanoblast_clock_checkpoint();
void nanoblast_clock_service(bool force=false);
bool nanoblast_clock_set(const nanoblast::ClockDate &);
nanoblast::ClockDate nanoblast_clock_date();
const char *nanoblast_clock_status();
