#define TANG_NANO20K
#define NANOBLAST_GB_LOADER_HOST_TEST
#include "../core/gb.cpp"
#include <vector>
#include <fstream>
#include <iterator>
#include <deque>
#include <cassert>
#include <algorithm>
FIL fcore;uint8_t fbuf[1024];bool core_running=false;
std::vector<uint8_t>source,sent;std::vector<int>states;
std::deque<int>answers;
unsigned closed=0,polls=0,hide=0,read_failure=0;bool short_read=false,close_error=false;uint64_t ticks=0;
FRESULT f_open(FIL*f,const char*,unsigned){f->position=0;return FR_OK;}
FRESULT f_close(FIL*){++closed;return close_error?FR_DISK_ERR:FR_OK;}
FRESULT f_lseek(FIL*f,unsigned p){f->position=p;return FR_OK;}
FRESULT f_read(FIL*f,void*p,unsigned n,UINT*got){
 if(read_failure&&f->position>=read_failure)return FR_DISK_ERR;
 *got=std::min(n,unsigned(source.size()-f->position));if(short_read&&*got)--*got;
 std::memcpy(p,source.data()+f->position,*got);f->position+=*got;return FR_OK;
}
unsigned f_size(FIL*){return source.size();}
void overlay_message(const char*,int){}void overlay_status(const char*,...){}void overlay(int on){if(!on)++hide;}
void set_loading_state(int n){states.push_back(n);}
void send_fbuf_data(unsigned n){sent.insert(sent.end(),fbuf,fbuf+n);}
int get_fpga_load_status(){++polls;ticks+=200;if(answers.empty())return -1;int n=answers.front();answers.pop_front();return n;}
uint64_t bflb_mtimer_get_time_ms(){return ticks;}void delay(unsigned n){ticks+=n;}
void header(unsigned type=0,unsigned rom=0,unsigned ram=0,unsigned cgb=0){
 source[0x143]=cgb;source[0x147]=type;source[0x148]=rom;source[0x149]=ram;
 uint8_t c=0;for(unsigned i=0x134;i<=0x14c;i++)c=c-source[i]-1;source[0x14d]=c;
}
bool bad_crc=false,no_debug=false,color_capability=false,rtc_capability=false;
bool get_fpga_debug(uint8_t index,uint32_t*value){
 if(no_debug)return false;
 if(index==0)*value=0x47423031;
 else if(index==9)*value=color_capability?0x43474231:0;
 else if(index==13)*value=rtc_capability?0x52544331:0;
 else if(index==2||index==3)*value=(nanoblast::crc32_update(~0u,source.data(),source.size())^~0u)^(bad_crc&&index==3?1:0);
 else *value=0;
 return true;
}
void reset(unsigned size=32768){rtc_capability=false;color_capability=false;source.assign(size,0);sent.clear();states.clear();answers={0,1};closed=polls=hide=read_failure=0;short_read=close_error=false;ticks=0;core_running=false;header();}
int main(){
 reset();assert(loadgb("game.GB")==FR_OK&&core_running&&hide==1&&closed==1&&polls==2);
 assert(sent.size()==source.size()+8&&std::equal(source.begin(),source.end(),sent.begin()+8));
 assert(std::vector<uint8_t>(sent.begin(),sent.begin()+8)==std::vector<uint8_t>({'N','B','G','B',0,0,0,0}));
 for(unsigned type:{0u,1u,2u,3u,5u,6u,8u,9u,0x11u,0x12u,0x13u,0x19u,0x1au,0x1bu,0x1cu,0x1du,0x1eu}){
  reset();header(type,0,2);assert(loadgb("game.gb")==FR_OK&&sent[4]==type&&sent[6]==2);
 }
 for(unsigned type:{0x0fu,0x10u}){
  reset(2097152);header(type,6,3,0xc0);color_capability=true;
  assert(loadgb("Crystal.gbc")==FR_INVALID_PARAMETER&&sent.empty()&&states.empty());
  rtc_capability=true;assert(loadgb("Crystal.gbc")==FR_OK&&core_running&&sent[4]==type);
 }
 reset(65536);header(1,1,0);assert(loadgb("game.gb")==FR_OK);
 reset();assert(loadgb("game.gbc")==FR_INVALID_PARAMETER&&sent.empty());
 reset();header(0,0,0,0xc0);color_capability=true;assert(loadgb("game.GBC")==FR_OK&&core_running);
 reset();header(0,0,0,0xc0);color_capability=true;assert(loadgb("game.gb")==FR_OK);
 reset();header(0,0,0,0xc0);assert(loadgb("game.gb")==FR_INVALID_PARAMETER&&sent.empty()&&states.empty());
 reset();header(0,0,0,0x80);assert(loadgb("dual.gb")==FR_OK); // DMG-compatible cartridges still work on old engines.
 for(unsigned type:{0x0fu,0x10u,0x20u}){reset();header(type);assert(loadgb("game.gb")==FR_INVALID_PARAMETER&&states.empty());}
 reset(65536);header(0,1);assert(loadgb("game.gb")==FR_INVALID_PARAMETER&&sent.empty());
 reset(524288);header(5,4);assert(loadgb("game.gb")==FR_INVALID_PARAMETER&&sent.empty());
 reset();source[0x143]=0xc0;assert(loadgb("game.gb")==FR_INVALID_PARAMETER&&states.empty());
 reset();source[0x14d]^=1;assert(loadgb("game.gb")==FR_INVALID_PARAMETER&&states.empty());
 reset();header(0,1);assert(loadgb("game.gb")==FR_INVALID_PARAMETER&&states.empty());
 reset();short_read=true;assert(loadgb("game.gb")==FR_DISK_ERR&&sent.empty());
 reset();read_failure=8192;assert(loadgb("game.gb")==FR_DISK_ERR&&!core_running&&!hide&&!polls&&states==std::vector<int>({1,0}));
 reset();close_error=true;assert(loadgb("game.gb")==FR_DISK_ERR&&!hide);
 reset();answers={2};assert(loadgb("game.gb")==FR_INT_ERR&&!core_running&&!hide);
 reset();answers.clear();assert(loadgb("game.gb")==FR_TIMEOUT&&!core_running&&!hide);
 reset();std::ifstream fixture("outputs/gb-nano-integration/NANOBLAST Test.gb",std::ios::binary);assert(fixture);
 source=std::vector<uint8_t>(std::istreambuf_iterator<char>(fixture),{});assert(source.size()==32768&&loadgb("test.gb")==FR_OK);
 reset();bad_crc=true;assert(loadgb("game.gb")==FR_INT_ERR&&!core_running&&!hide);bad_crc=false;
 reset();no_debug=true;assert(loadgb("game.gb")==FR_INT_ERR&&!core_running&&!hide);no_debug=false;
 return 0;
}
