#define NANOBLAST_NES_LOADER_HOST_TEST
#include "../core/nes.cpp"
#include <vector>
#include <deque>
#include <cassert>
#include <algorithm>
FIL fcore;uint8_t fbuf[1024];bool core_running=false;
std::vector<uint8_t> source,sent;std::vector<int> states,visibility;
std::deque<int> replies;int fallback=0x80;uint64_t ticks=0;unsigned queries=0;bool read_error=false;
FRESULT f_open(FIL*f,const char*,unsigned){f->position=0;return FR_OK;}
FRESULT f_close(FIL*){return FR_OK;}
FRESULT f_lseek(FIL*f,unsigned n){f->position=n;return FR_OK;}
FRESULT f_read(FIL*f,void*p,unsigned n,unsigned*got){if(read_error)return FR_DISK_ERR;*got=std::min(n,unsigned(source.size()-f->position));std::memcpy(p,source.data()+f->position,*got);f->position+=*got;return FR_OK;}
unsigned f_size(FIL*){return source.size();}
void overlay_message(const char*,int){}void overlay_status(const char*,...){}
void overlay(int on){visibility.push_back(on);}
void set_loading_state(int n){states.push_back(n);}
void send_fbuf_data(unsigned n){sent.insert(sent.end(),fbuf,fbuf+n);}
uint64_t bflb_mtimer_get_time_ms(){return ++ticks;}void delay(unsigned n){ticks+=n;}
int get_fpga_load_status(){++queries;if(replies.empty())return fallback;int n=replies.front();replies.pop_front();return n;}
void reset(){source.assign(40976,0xa5);sent.clear();states.clear();visibility.clear();replies.clear();fallback=0x80;ticks=queries=0;core_running=read_error=false;}
int main(){
 reset();replies={0x80,0x81,0x99,0x95,0x85};assert(loadnes("game.nes")==FR_OK&&core_running&&queries==5&&sent==source);assert(states==std::vector<int>({1,0})&&visibility==std::vector<int>({0}));
 reset();replies={1};assert(loadnes("legacy.nes")==FR_OK&&core_running&&queries==1);
 reset();replies={0x82};assert(loadnes("bad.nes")==FR_INT_ERR&&!core_running&&visibility.empty());
 reset();assert(loadnes("timeout.nes")==FR_TIMEOUT&&!core_running&&visibility.empty());
 reset();replies={0x81};fallback=0x99;assert(loadnes("paused.nes")==FR_TIMEOUT&&!core_running&&visibility==std::vector<int>({0,1}));
 reset();read_error=true;assert(loadnes("read-error.nes")==FR_DISK_ERR&&!core_running&&queries==0&&states==std::vector<int>({1,0}));
 puts("PASS NES loader: verified ready/run handoff, old-core support, reject/read/ready-timeout/reset-timeout failures");
}
