#include "console_clock.h"
#include "save_journal.h"
#ifdef NANOBLAST_CLOCK_HOST_TEST
#include "../tests/clock_platform.h"
#else
#include "utils.h"
#endif
#include <string>
#include <cstring>
extern const char *drv;
#ifndef NANOBLAST_CLOCK_HOST_TEST
extern int nanoblast_sd_mount_result;
#endif
namespace nanoblast {
namespace {
bool leap(unsigned y){return y%4==0&&(y%100!=0||y%400==0);}
unsigned days(unsigned y,unsigned m){static const unsigned n[]={31,28,31,30,31,30,31,31,30,31,30,31};return m==2?n[1]+leap(y):m>=1&&m<=12?n[m-1]:0;}
}
bool valid_clock_date(const ClockDate&d){return d.year>=2000&&d.year<=2099&&d.month>=1&&d.month<=12&&d.day>=1&&d.day<=days(d.year,d.month)&&d.hour<24&&d.minute<60&&d.second<60;}
uint64_t clock_seconds(const ClockDate&d){uint64_t n=0;for(unsigned y=2000;y<d.year;y++)n+=365u+leap(y);for(unsigned m=1;m<d.month;m++)n+=days(d.year,m);return ((n+d.day-1)*24+d.hour)*3600+d.minute*60+d.second;}
ClockDate clock_date(uint64_t s){ClockDate d;if(s>3155759999ull){d.year=2100;return d;}d.second=s%60;s/=60;d.minute=s%60;s/=60;d.hour=s%24;s/=24;d.year=2000;while(s>=365u+leap(d.year)){s-=365u+leap(d.year);d.year++;}d.month=1;while(s>=days(d.year,d.month)){s-=days(d.year,d.month);d.month++;}d.day=s+1;return d;}
uint64_t advance_game_clock(uint64_t rtc,int64_t delta){
 if(rtc&(1ull<<28))return rtc; // MBC3 halt must survive clock corrections.
 int64_t old=int64_t((rtc>>17)&1023)*86400+int64_t((rtc>>12)&31)*3600+int64_t((rtc>>6)&63)*60+(rtc&63);
 const int64_t period=512ll*86400;int64_t total=old+delta,wrapped=(total%period+period)%period;
 uint64_t result=(rtc&(1ull<<27))|((total>=period)?1ull<<27:0);
 result|=uint64_t(wrapped/86400)<<17;wrapped%=86400;result|=uint64_t(wrapped/3600)<<12;wrapped%=3600;result|=uint64_t(wrapped/60)<<6;result|=wrapped%60;return result;
}
}
namespace {
bool initialized=false,configured=false,has_record=false;uint64_t epoch=0,base_ms=0,last_commit=0;int64_t manual_shift=0;nanoblast::SaveRecord record;
const char *status="Clock not set";
std::string prefix(){std::string p=drv;if(p.back()!='/')p+='/';return p+"nanoblast/clock";}
std::string directory(){std::string p=drv;if(p.back()!='/')p+='/';return p+"nanoblast";}
uint64_t load64(const uint8_t*p){uint64_t v=0;for(unsigned i=0;i<8;i++)v|=uint64_t(p[i])<<(i*8);return v;}
void initialize(){if(initialized)return;
#ifndef NANOBLAST_CLOCK_HOST_TEST
 if(nanoblast_sd_mount_result!=0)return;
#endif
 auto scan=nanoblast::save_scan(prefix(),1,0,0,0,record);
 if(scan==nanoblast::SaveScan::Valid){epoch=load64(record.auxiliary);const auto d=nanoblast::clock_date(epoch);if(nanoblast::valid_clock_date(d)){configured=true;has_record=true;status="Clock restored";}else status="Clock record invalid";}
 else if(scan==nanoblast::SaveScan::Damaged){status="Clock record damaged";}
 else {epoch=nanoblast::clock_seconds(nanoblast::ClockDate{});configured=true;status="Clock default: set date/time";}
 base_ms=last_commit=bflb_mtimer_get_time_ms();initialized=true;
}
bool persist(uint64_t value){uint8_t aux[16]={};for(unsigned i=0;i<8;i++)aux[i]=value>>(i*8);
 if(!nanoblast::save_directory(directory())||!nanoblast::save_commit(prefix(),1,0,0,aux,nullptr,0,record,has_record)){status="Clock SD save failed";return false;}has_record=true;return true;}
}
uint64_t nanoblast_clock_now(){initialize();return epoch+(configured?(bflb_mtimer_get_time_ms()-base_ms)/1000:0);}
int64_t nanoblast_clock_adjustment(){initialize();return manual_shift;}
bool nanoblast_clock_is_set(){initialize();return configured;}
nanoblast::ClockDate nanoblast_clock_date(){initialize();return configured?nanoblast::clock_date(nanoblast_clock_now()):nanoblast::ClockDate{};}
const char *nanoblast_clock_status(){initialize();return status;}
bool nanoblast_clock_set(const nanoblast::ClockDate&d){initialize();if(!nanoblast::valid_clock_date(d))return false;const uint64_t value=nanoblast::clock_seconds(d),before=nanoblast_clock_now();if(!persist(value))return false;manual_shift+=int64_t(value)-int64_t(before);epoch=value;base_ms=last_commit=bflb_mtimer_get_time_ms();configured=true;status="Clock set and saved";return true;}
bool nanoblast_clock_checkpoint(){initialize();if(!configured||!persist(nanoblast_clock_now()))return false;last_commit=bflb_mtimer_get_time_ms();status="Clock saved";return true;}
void nanoblast_clock_service(bool force){initialize();const auto now=bflb_mtimer_get_time_ms();if(!configured||(!force&&now-last_commit<10000))return;if(persist(nanoblast_clock_now())){last_commit=bflb_mtimer_get_time_ms();status="Clock saved";}else last_commit=now;}
