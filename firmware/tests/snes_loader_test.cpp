#define TANG_NANO20K
#define NANOBLAST_SNES_LOADER_HOST_TEST
#include "../core/snes.cpp"
#include <vector>
#include <deque>
#include <cassert>
#include <algorithm>
FIL fcore;uint8_t fbuf[1024];bool core_running=false;
std::vector<uint8_t>source,sent;std::vector<int>states;
std::deque<int>answers;
unsigned closed=0,polls=0,hide=0,read_failure=0;bool short_read=false,close_error=false;uint64_t ticks=0;
unsigned diag_mode=0,diag_state=2;int diag_timeout=-1;
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
bool get_fpga_debug(uint8_t index,uint32_t *value){
 if(int(index)==diag_timeout)return false;
 if(index<0x20||index==0x80)assert(!states.empty()&&states.back()==1);
 const uint32_t crc=sent.size()>64?~nanoblast::crc32_update(0xffffffffu,sent.data()+64,sent.size()-64):0;
 switch(index){
  case 0:*value=diag_mode==4?0:0x534e3031;break;
  case 1:*value=sent.size()-64-(diag_mode==3?2:0);break;
  case 2:*value=crc^(diag_mode==1?1:0);break;
  case 3:*value=crc^(diag_mode==2?1:0);break;
  case 4:case 0x80:*value=diag_state;break;
  default:*value=0;
 }
 return true;
}
uint64_t bflb_mtimer_get_time_ms(){return ticks;}void delay(unsigned n){ticks+=n;}
void reset(unsigned size=8192){source.resize(size);for(unsigned i=0;i<size;i++)source[i]=(i*7)^(i>>8);sent.clear();states.clear();answers={0,1};closed=polls=hide=read_failure=0;short_read=close_error=false;ticks=0;core_running=false;diag_mode=0;diag_state=2;diag_timeout=-1;}
void rom(unsigned size=32768,unsigned header=0,unsigned mapper=0x20,unsigned type=0) {
 reset(size+header);auto h=source.begin()+header+((mapper&1)?0xffc0:0x7fc0);
 std::fill(h,h+64,0);h[21]=mapper;h[22]=type;h[23]=size>0x200000?12:size>0x100000?11:size>0x80000?10:size>0x40000?9:size>0x20000?8:size>0x10000?7:size>32768?6:5;
 h[60]=0;h[61]=0x80;
}
void success(const char*name,unsigned offset,unsigned pos,bool normalize=false,unsigned expected_polls=2){
 std::vector<uint8_t>expected(source.begin()+offset+pos,source.begin()+offset+pos+64);
 if(normalize)expected[21]=0x20;
 expected.insert(expected.end(),source.begin()+offset,source.end());
 assert(loadsnes(name)==FR_OK&&sent==expected&&core_running&&hide==1&&closed==1&&polls==expected_polls&&states==std::vector<int>({1,0}));
}
int main(){
 rom();success("game.SFC",0,0x7fc0);
 rom(65536,512);success("game.SMC",512,0x7fc0);
 rom(65536,0,0x21);success("hirom.sfc",0,0xffc0);
 rom(65536,0,0x20,3);answers={0xa0};assert(loadsnes("dsp-game.sfc")==FR_INVALID_PARAMETER&&sent.empty()&&states.empty());
 rom(65536,0,0x20,3);answers={0xa4,0,1};success("dsp-game.sfc",0,0x7fc0,false,3);
 // Contra III's overlong title writes 'S' ($53) into the map-mode byte.
 // Only the extra transmitted header may change, never the ROM payload.
 rom(0x100000);std::memcpy(source.data()+0x7fc0,"CONTRA3 THE ALIEN WARS",22);
 success("contra3.sfc",0,0x7fc0,true);
 assert(source[0x7fd5]==0x53);
 // A plausible low header must not hide a stronger real HiROM header,
 // whether the misleading low candidate names a normal or special chip.
 for(unsigned type:{0u,0x13u}){
  rom(65536,0,0x21);
  auto low=source.begin()+0x7fc0;std::fill(low,low+64,0);
  low[21]=0x20;low[22]=type;low[23]=6;low[61]=0x80;
  source[0xffdc]=source[0xffdd]=0xa5;
  source[0xffde]=source[0xffdf]=0x5a;
  success("ambiguous-hirom.sfc",0,0xffc0);
 }
 rom();assert(loadsnes("game.sfc.bad")==FR_INVALID_NAME&&states.empty()&&sent.empty());
 rom();source[0x7fc0+23]=255;assert(loadsnes("bad.sfc")==FR_INVALID_PARAMETER&&states.empty()&&closed==1);
 rom();source[0x7fc0+61]=0x10;assert(loadsnes("bad.sfc")==FR_INVALID_PARAMETER&&states.empty());
 rom(0x400000);assert(loadsnes("too-big.sfc")==FR_INVALID_PARAMETER&&sent.empty()&&closed==1);
 rom(65536,0,0x20,0x13);assert(loadsnes("superfx.sfc")==FR_INVALID_PARAMETER&&sent.empty());
 rom();read_failure=16384;assert(loadsnes("bad.sfc")==FR_INVALID_PARAMETER&&sent.empty());
 rom(65536);read_failure=49152;assert(loadsnes("bad.sfc")==FR_DISK_ERR&&!core_running&&!hide&&!polls&&states==std::vector<int>({1,0}));
 rom();short_read=true;assert(loadsnes("bad.sfc")==FR_INVALID_PARAMETER&&!hide&&!polls);
 rom();close_error=true;assert(loadsnes("bad.sfc")==FR_DISK_ERR&&!hide&&!polls);
 rom();answers={2};assert(loadsnes("game.sfc")==FR_INT_ERR&&!core_running&&!hide);
 rom();answers.clear();assert(loadsnes("game.sfc")==FR_TIMEOUT&&!core_running&&!hide&&polls<=15);
 for(unsigned mode:{1u,2u,3u,4u}){
  rom();diag_mode=mode;assert(loadsnes("game.sfc")==FR_INT_ERR&&!core_running&&!hide&&!polls&&states==std::vector<int>({1,0}));
 }
 rom();diag_state=4;assert(loadsnes("game.sfc")==FR_INT_ERR&&!core_running&&!polls);
 rom();diag_state=1;assert(loadsnes("game.sfc")==FR_TIMEOUT&&!core_running&&!polls);
 rom();diag_timeout=3;assert(loadsnes("game.sfc")==FR_INT_ERR&&!core_running&&!polls);
 return 0;
}
