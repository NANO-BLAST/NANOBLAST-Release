#include "gb_save.h"
#include "gb_save_transport.h"
#include "save_journal.h"
#include "console_clock.h"
#ifdef NANOBLAST_GB_SAVE_HOST_TEST
#include "../tests/gb_save_platform.h"
#else
#include "utils.h"
#endif
#include <cstring>
#include <cstdio>
#include <algorithm>
extern const char *drv;
namespace {
uint8_t ram[131072];
struct Session {
 bool active=false,rtc=false,existing=false,dirty=false;
 unsigned bytes=0,length=0;uint32_t crc=0,saved_generation=0,observed_generation=0;
 uint64_t retry_after=0,last_poll=0,last_change=0,dirty_since=0,last_save=0;
 int64_t adjustment=0;
 std::string prefix;
 nanoblast::SaveRecord record;
} game;
const char *save_status="GB save: no battery game";
uint64_t read64(const uint8_t*p){uint64_t v=0;for(unsigned i=0;i<8;i++)v|=uint64_t(p[i])<<(8*i);return v;}
void write64(uint8_t*p,uint64_t v){for(unsigned i=0;i<8;i++)p[i]=v>>(8*i);}
uint32_t read32(const uint8_t*p){return uint32_t(p[0])|uint32_t(p[1])<<8|uint32_t(p[2])<<16|uint32_t(p[3])<<24;}
unsigned kind(){return 2|(game.rtc?0x100:0);}
bool release(){return gb_save_request(5,0,0,nullptr,nullptr,0);}
bool acquire(uint32_t &generation,uint64_t &rtc){
 uint8_t b[12];if(!gb_save_request(1,0,0,nullptr,b,12)){release();return false;}
 generation=read32(b);rtc=read64(b+4);return true;
}
bool rtc_write(uint64_t value){uint8_t b[8];write64(b,value);return gb_save_request(4,0,8,b,nullptr,0);}
bool checkpoint(){
 uint32_t generation=0;uint64_t rtc=0;
 if(!acquire(generation,rtc)){save_status="GB save: pause failed";return false;}
 if(!game.rtc&&game.existing&&generation==game.saved_generation){
  if(!release()){save_status="GB save: release failed";return false;}
  save_status="GB save: saved";return true;
 }
 const auto anchor=nanoblast_clock_now();
 const auto adjustment=nanoblast_clock_adjustment();
 bool ok=true;
 if(game.rtc&&adjustment!=game.adjustment){
  rtc=nanoblast::advance_game_clock(rtc,adjustment-game.adjustment);
  ok=rtc_write(rtc);
  // Applied to live cartridge even if a later SD operation fails. Never apply twice.
  if(ok)game.adjustment=adjustment;
 }
 for(unsigned offset=0;offset<game.bytes&&ok&&(!game.existing||generation!=game.saved_generation);offset+=256){
  const auto count=std::min(256u,game.bytes-offset);
  ok=gb_save_request(2,offset,count,nullptr,ram+offset,count);
 }
 const bool resumed=release();
 if(!ok||!resumed){save_status="GB save: transfer failed";return false;}
 if(game.rtc&&!nanoblast_clock_checkpoint()){save_status="GB save: clock SD failed";return false;}
 // Resume gameplay before SD sync. New RAM writes remain dirty for the next save.
 uint8_t aux[16];write64(aux,rtc);write64(aux+8,anchor);
 if(!nanoblast::save_commit(game.prefix,kind(),game.crc,game.length,aux,ram,game.bytes,game.record,game.existing)){
  save_status="GB save: SD write failed";return false;
 }
 game.existing=true;game.saved_generation=generation;game.observed_generation=generation;
 game.dirty=false;game.last_save=bflb_mtimer_get_time_ms();save_status="GB save: saved";return true;
}
}
const char *gb_save_status(){return save_status;}
void gb_save_forget(){game=Session{};save_status="GB save: no battery game";}
bool gb_save_flush(){if(!game.active)return true;return checkpoint();}
void gb_save_service(){
 if(!game.active)return;const auto now=bflb_mtimer_get_time_ms();
 if(now<game.retry_after||now-game.last_poll<250)return;game.last_poll=now;
 uint32_t generation=0;if(!get_fpga_debug(21,&generation)){save_status="GB save: link failed";return;}
 if(generation!=game.saved_generation){
  if(!game.dirty){game.dirty=true;game.dirty_since=now;game.last_change=now;}
  if(generation!=game.observed_generation){game.last_change=now;game.observed_generation=generation;}
 }
 if((game.dirty&&(now-game.last_change>=700||now-game.dirty_since>=3000))||
    (game.rtc&&(now-game.last_save>=10000||nanoblast_clock_adjustment()!=game.adjustment))){
  // Back off after failures rather than holding the menu in repeated retries.
  if(!checkpoint()){game.retry_after=bflb_mtimer_get_time_ms()+1000;game.last_save=bflb_mtimer_get_time_ms();}
 }
}
bool gb_save_restore(const char *path,uint32_t crc,unsigned length,unsigned type,unsigned ram_code){
 gb_save_forget();
 const bool battery=type==3||type==6||type==9||type==0x0f||type==0x10||type==0x13||type==0x1b||type==0x1e;
 if(!battery)return true;
 uint32_t capability=0;if(!get_fpga_debug(20,&capability)||capability!=0x53415631){save_status="GB save: update core required";return false;}
 game.rtc=type==0x0f||type==0x10;
 if(game.rtc&&!nanoblast_clock_is_set()){save_status="Set clock before RTC restore";return false;}
 const unsigned sizes[]={0,2048,8192,32768,131072,65536};
 game.bytes=type==6?512:ram_code<6?sizes[ram_code]:0;
 game.crc=crc;game.length=length;
 std::string directory=drv;if(directory.back()!='/')directory+='/';directory+="gb/saves";
 if(!nanoblast::save_directory(directory)){save_status="GB save: folder failed";return false;}
 const char *base=std::strrchr(path,'/');base=base?base+1:path;
 char name[80];unsigned n=0;
 while(base[n]&&n<48){const char c=base[n];name[n]=(c>='a'&&c<='z')||(c>='A'&&c<='Z')||(c>='0'&&c<='9')?c:'_';n++;}
 std::snprintf(name+n,sizeof name-n,"_%08lX",static_cast<unsigned long>(crc));game.prefix=directory+"/"+name;
 const auto scan=nanoblast::save_scan(game.prefix,kind(),crc,length,game.bytes,game.record);
 if(scan==nanoblast::SaveScan::Damaged){save_status="GB save: damaged records";return false;}
 game.existing=scan==nanoblast::SaveScan::Valid;
 if(game.existing&&!nanoblast::save_read(game.prefix,game.record,ram,game.bytes)){save_status="GB save: SD read failed";return false;}
 uint32_t generation;uint64_t rtc;
 if(!acquire(generation,rtc)){save_status="GB save: pause failed";return false;}
 bool ok=true;const auto now=nanoblast_clock_now();
 if(game.existing){
  for(unsigned offset=0;offset<game.bytes&&ok;offset+=256)ok=gb_save_request(3,offset,std::min(256u,game.bytes-offset),ram+offset,nullptr,0);
  rtc=read64(game.record.auxiliary);const auto then=read64(game.record.auxiliary+8);
  // Reject invalid timestamps/RTC, even if the file CRC is intact.
  if(then>3155759999ull||(rtc>>29)||((rtc>>17)&1023)>511||(rtc&63)>59||((rtc>>6)&63)>59||((rtc>>12)&31)>23)ok=false;
  else if(game.rtc)rtc=nanoblast::advance_game_clock(rtc,int64_t(now)-int64_t(then));
 }else if(game.rtc&&nanoblast_clock_is_set())rtc=nanoblast::advance_game_clock(0,int64_t(now));
 if(ok&&game.rtc)ok=rtc_write(rtc);
 const bool resumed=release();
 if(!ok||!resumed){save_status="GB save: restore failed";return false;}
 game.active=true;game.saved_generation=game.observed_generation=generation;
 game.adjustment=nanoblast_clock_adjustment();game.last_save=game.last_poll=bflb_mtimer_get_time_ms();
 save_status=game.existing?"GB save: restored":"GB save: new game";return true;
}
