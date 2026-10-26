#define TANG_NANO20K
#define NANOBLAST_SMS_LOADER_HOST_TEST
#include "../core/sms.cpp"
#include <vector>
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
uint32_t configuration=0;bool gear_capable=true;
uint32_t get_core_config(){return configuration;}
void set_core_config(uint32_t v){configuration=v;}
bool get_fpga_debug(uint8_t i,uint32_t*v){assert(i==0);*v=gear_capable?0x53474731:0;return true;}
void reset(unsigned size=8192){configuration=4;gear_capable=true;source.resize(size);for(unsigned i=0;i<size;i++)source[i]=(i*7)^(i>>8);sent.clear();states.clear();answers={0,1};closed=polls=hide=read_failure=0;short_read=close_error=false;ticks=0;core_running=false;}
int main(){
 reset();assert(loadsms("game.SMS")==FR_OK&&sent==source&&core_running&&hide==1&&closed==1&&polls==2&&states==std::vector<int>({1,0}));
 reset(8192+512);assert(loadsms("game.sms")==FR_OK&&sent==std::vector<uint8_t>(source.begin()+512,source.end()));
 reset();assert(loadsms("game.gg")==FR_OK&&sent==source&&configuration==12&&core_running);
 reset(32768+512);assert(loadsms("game.GG")==FR_OK&&sent==std::vector<uint8_t>(source.begin()+512,source.end())&&configuration==12);
 answers={1};assert(loadsms("game.sms")==FR_OK&&configuration==4); // Loading SMS clears only the GG flag.
 reset();gear_capable=false;assert(loadsms("game.gg")==FR_INVALID_PARAMETER&&states.empty()&&sent.empty()&&closed==0&&configuration==4);
 reset();assert(loadsms("game.zip")==FR_INVALID_NAME&&states.empty()&&sent.empty());
 reset(8193);assert(loadsms("game.sms")==FR_INVALID_PARAMETER&&states.empty()&&sent.empty()&&closed==1);
 reset(0);assert(loadsms("game.sms")==FR_INVALID_PARAMETER&&states.empty());
 reset(16384);read_failure=8192;assert(loadsms("game.sms")==FR_DISK_ERR&&!core_running&&!hide&&!polls&&states==std::vector<int>({1,0}));
 reset();short_read=true;assert(loadsms("game.sms")==FR_DISK_ERR&&!hide&&!polls);
 reset();close_error=true;assert(loadsms("game.sms")==FR_DISK_ERR&&!hide&&!polls);
 reset();answers={2};assert(loadsms("game.sms")==FR_INT_ERR&&!core_running&&!hide);
 reset();answers.clear();assert(loadsms("game.sms")==FR_TIMEOUT&&!core_running&&!hide&&polls<=15);
 return 0;
}
