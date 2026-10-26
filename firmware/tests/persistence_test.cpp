#define NANOBLAST_SAVE_HOST_TEST
#define NANOBLAST_CLOCK_HOST_TEST
#define NANOBLAST_GB_SAVE_HOST_TEST
#include "../storage/save_journal.cpp"
#include "../storage/console_clock.cpp"
#include "../storage/gb_save.cpp"
#include <map>
#include <vector>
#include <set>
#include <cassert>
#include <iostream>
std::map<std::string,std::vector<uint8_t>> files;
std::set<std::string> directories;
int write_budget=-1;bool sync_fail=false,paused=false;
uint64_t ticks=0,cartridge_rtc=0;uint32_t dirty_generation=0;
uint8_t cartridge_ram[131072];
const char *drv="sd:";
uint64_t bflb_mtimer_get_time_ms(){return ticks;}
FRESULT f_open(FIL*f,const char*p,unsigned flags){f->path=p;f->position=0;if(flags&FA_CREATE_ALWAYS)files[p].clear();return files.count(p)?FR_OK:FR_NO_FILE;}
FRESULT f_close(FIL*){return FR_OK;}
FRESULT f_sync(FIL*){assert(!paused);return sync_fail?FR_DISK_ERR:FR_OK;}
unsigned f_size(FIL*f){return files[f->path].size();}
FRESULT f_lseek(FIL*f,unsigned p){f->position=p;return FR_OK;}
FRESULT f_read(FIL*f,void*data,unsigned n,UINT*got){auto&v=files[f->path];*got=std::min(n,unsigned(v.size()-std::min<size_t>(f->position,v.size())));memcpy(data,v.data()+f->position,*got);f->position+=*got;return FR_OK;}
FRESULT f_write(FIL*f,const void*data,unsigned n,UINT*got){
 *got=write_budget<0?n:std::min(n,unsigned(write_budget));if(write_budget>=0)write_budget-=*got;
 auto&v=files[f->path];v.resize(f->position+*got);memcpy(v.data()+f->position,data,*got);f->position+=*got;return FR_OK;
}
FRESULT f_stat(const char*p,FILINFO*i){i->fattrib=directories.count(p)?AM_DIR:0;return i->fattrib||files.count(p)?FR_OK:FR_NO_FILE;}
FRESULT f_mkdir(const char*p){directories.insert(p);return FR_OK;}
bool get_fpga_debug(uint8_t index,uint32_t*v){*v=index==20?0x53415631:dirty_generation;return true;}
bool gb_save_request(uint8_t op,unsigned offset,unsigned n,const uint8_t*data,uint8_t*out,unsigned bytes){
 if(op==1){paused=true;write64(out,dirty_generation);write64(out+4,cartridge_rtc);assert(bytes==12);return true;}
 if(op==5){paused=false;return true;}
 assert(paused);
 if(op==2){assert(bytes==n);memcpy(out,cartridge_ram+offset,n);}
 else if(op==3)memcpy(cartridge_ram+offset,data,n);
 else if(op==4)cartridge_rtc=read64(data);
 else assert(false);return true;
}
void reset_clock(){initialized=false;configured=false;has_record=false;epoch=base_ms=last_commit=0;manual_shift=0;record={};}
int main(){
 using namespace nanoblast;
 assert(valid_clock_date({2024,2,29,23,59,59}));assert(!valid_clock_date({2023,2,29}));
 assert(clock_seconds({2000,1,1})==0);assert(clock_date(UINT64_MAX).year==2100);
 for(unsigned y=2000;y<2100;y++)for(unsigned m=1;m<=12;m++)for(unsigned d=1;d<=28;d++){
  ClockDate a{y,m,d,23,59,59};auto b=clock_date(clock_seconds(a));assert(a.year==b.year&&a.month==b.month&&a.day==b.day&&a.hour==b.hour&&a.minute==b.minute&&a.second==b.second);
 }
 uint64_t end=(511ull<<17)|(23ull<<12)|(59ull<<6)|59;
 assert(advance_game_clock(end,1)==1ull<<27);
 assert((advance_game_clock(0,-1)&((1ull<<27)-1))==end);
 assert(advance_game_clock((1ull<<28)|end,100)==((1ull<<28)|end));
 // Every interrupted byte position in a new journal record retains the old one.
 SaveRecord r;uint8_t aux[16]={},data[512];memset(data,0x5a,sizeof data);
 assert(save_commit("journal",2,99,32768,aux,data,512,r,false));const auto baseline=files;
 for(int budget=0;budget<576;budget++){
  files=baseline;SaveRecord current=r;write_budget=budget;
  assert(!save_commit("journal",2,99,32768,aux,data,512,current,true));
  SaveRecord found;assert(save_scan("journal",2,99,32768,512,found)==SaveScan::Valid&&found.slot==r.slot&&found.sequence==1);
 }
 files=baseline;write_budget=-1;sync_fail=true;assert(!save_commit("journal",2,99,32768,aux,data,512,r,true));sync_fail=false;
 files=baseline;files["journal.0"][64]^=1;SaveRecord bad;assert(save_scan("journal",2,99,32768,512,bad)==SaveScan::Damaged);
 files.clear();directories.clear();reset_clock();ticks=0;
 assert(nanoblast_clock_set({2026,10,25,12,0,0}));const auto first=nanoblast_clock_now();ticks=5000;assert(nanoblast_clock_now()==first+5);
 nanoblast_clock_service(true);reset_clock();ticks=0;assert(nanoblast_clock_now()==first+5);
 // Battery RAM and independent RTC offset survive service restart and power loss.
 cartridge_rtc=100;memset(cartridge_ram,0,sizeof cartridge_ram);
 assert(gb_save_restore("sd:/gb/Crystal.gbc",0xee6f5188,2097152,0x10,3));
 cartridge_rtc=1000;cartridge_ram[123]=99;dirty_generation=1;
 ticks+=4000;gb_save_service();ticks+=800;gb_save_service();assert(std::string(gb_save_status())=="GB save: saved");
 gb_save_forget();reset_clock();ticks=0;cartridge_rtc=0;memset(cartridge_ram,0,sizeof cartridge_ram);
 assert(gb_save_restore("sd:/gb/Crystal.gbc",0xee6f5188,2097152,0x10,3));assert(cartridge_ram[123]==99&&cartridge_rtc==1000);
 auto newdate=nanoblast_clock_date();newdate.hour++;assert(nanoblast_clock_set(newdate));assert(gb_save_flush());assert(cartridge_rtc==advance_game_clock(1000,3600));
 // A failed SD checkpoint cannot apply the manual time shift twice.
 newdate.hour++;assert(nanoblast_clock_set(newdate));sync_fail=true;assert(!gb_save_flush());assert(cartridge_rtc==advance_game_clock(1000,7200));sync_fail=false;assert(gb_save_flush());assert(cartridge_rtc==advance_game_clock(1000,7200));
 cartridge_rtc|=1ull<<28;newdate.hour++;assert(nanoblast_clock_set(newdate));assert(gb_save_flush());assert(cartridge_rtc==((1ull<<28)|advance_game_clock(1000,7200)));
 // Another ROM identity never inherits this game's battery RAM.
 gb_save_forget();memset(cartridge_ram,0,sizeof cartridge_ram);assert(gb_save_restore("sd:/gb/Other.gb",1234,32768,3,2));assert(cartridge_ram[123]==0);
 for(unsigned code=0;code<6;code++){gb_save_forget();assert(gb_save_restore("sizes.gb",10+code,32768,3,code));assert(gb_save_flush());}
 std::cout<<"PASS clock calendars, RTC offsets/halt, interrupted journals, RAM restore and clock power-cycle\n";
}
