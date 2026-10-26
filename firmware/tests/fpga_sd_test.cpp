#define NANOBLAST_SD_HOST_TEST
#include "../storage/fpga_sd.cpp"
#include <cassert>
#include <deque>
#include <vector>
#include <string>
#include <map>
namespace {
bool sem=false,drop=false,bad_frame=false;
uint64_t ticks=0;
unsigned need=0;
unsigned frames=0;
std::vector<uint8_t> outgoing;
std::deque<uint8_t> card;
FATFS_DiskioDriverTypeDef driver;
unsigned forced_cmd0=1;
int writing=-1;unsigned write_sector=0,crc_bytes=0;
std::vector<uint8_t> written;
std::map<unsigned,std::vector<uint8_t>> sectors;
uint8_t write_response=5;bool busy_forever=false;
unsigned write_gap=0;bool early_deselect=false;
bool programming=false;
unsigned program_time_ms=0;uint64_t program_until=0;
unsigned burst_busy_polls=0;
unsigned corrupt_reads=0,read_commands=0;
bool corrupt_fast=false,corrupt_always=false;
unsigned r1_delay=0;
uint16_t card_crc(const std::vector<uint8_t>&data){
 uint16_t c=0;
 for(auto v:data){c^=uint16_t(v)<<8;for(unsigned b=0;b<8;b++)c=uint16_t((c<<1)^((c&0x8000)?0x1021:0));}
 return c;
}
void finish(){
 unsigned n=outgoing.size()-1;
 std::vector<uint8_t> incoming(n,0xff);
 if(outgoing[0]&1){for(auto b:card)if(b==0)early_deselect=true;card.clear();writing=-1;if(!busy_forever)programming=false;}
 else if(writing<0 && (n==6||n==7) && (outgoing[1]&0xc0)==0x40){
  unsigned sector=(unsigned(outgoing[2])<<24)|(unsigned(outgoing[3])<<16)|(unsigned(outgoing[4])<<8)|outgoing[5];
  switch(outgoing[1]&63){
   case 0:card={uint8_t(forced_cmd0)};break;
   case 8:card={1,0,0,1,0xaa};break;
   case 55:card={1};break;
   case 41:card={0};break;
   case 58:card={0,0x40,0,0,0};break;
   case 17:{
    ++read_commands;std::vector<uint8_t> block;
    for(unsigned i=0;i<512;i++)block.push_back(sectors.count(sector)?sectors[sector][i]:uint8_t(i));
    auto crc=card_crc(block);
    if(corrupt_always||(corrupt_fast&&(outgoing[0]&2))||corrupt_reads){block[307]^=0x40;if(corrupt_reads)--corrupt_reads;}
    card={0,0xfe};for(auto b:block)card.push_back(b);card.push_back(crc>>8);card.push_back(crc&255);break;
   }
   case 24:assert(!(outgoing[0]&2));card={0};writing=0;write_gap=0;write_sector=sector;written.clear();crc_bytes=0;break;
   default:assert(false);
  }
  for(unsigned i=0;i<r1_delay;i++)card.push_front(0xff);
  if(n==7){assert(outgoing[7]==0xff);incoming[6]=card.front();card.pop_front();}
 } else if(!(outgoing[0]&1))for(unsigned i=0;i<n;i++){
  bool pending_response=!card.empty();
  if(pending_response){incoming[i]=card.front();card.pop_front();}
  else if(programming&&writing<0&&(busy_forever||ticks<program_until))incoming[i]=0;
  uint8_t sent=outgoing[i+1];
  if(writing==0&&!pending_response&&sent==0xff)++write_gap;
  if(writing==0&&sent==0xfe){assert(write_gap>=1);writing=1;}
  else if(writing==1){written.push_back(sent);if(written.size()==512)writing=2;}
  else if(writing==2&&++crc_bytes==2){
   if(write_response==5)sectors[write_sector]=written;
   programming=true;
   program_until=ticks+program_time_ms;
   card={write_response,0xff,0,0};if(!busy_forever&&!program_time_ms)card.push_back(0xff);writing=-1;
  }
 }
 if(n==32&&programming)++burst_busy_polls;
 if(drop)return;
 fpga_sd_reply_begin(n+1+(bad_frame?1:0));
 if(!bad_frame)for(unsigned i=0;i<n;i++)fpga_sd_reply_byte(i,incoming[i]);
}
}
SemaphoreHandle_t xSemaphoreCreateBinary(){sem=false;return &sem;}
int xSemaphoreTake(SemaphoreHandle_t s,unsigned wait){if(*s){*s=false;return pdTRUE;}ticks+=wait;return 0;}
void xSemaphoreGive(SemaphoreHandle_t s){*s=true;}
void disk_driver_callback_init(int,FATFS_DiskioDriverTypeDef*d){driver=*d;}
void fpga_tx_header(int cmd,int len){++frames;assert(cmd==16);need=len-1;outgoing.clear();}
void fpga_tx_byte(uint8_t b){outgoing.push_back(b);if(outgoing.size()==need)finish();}
uint64_t bflb_mtimer_get_time_ms(){return ticks++;}
void delay(unsigned n){ticks+=n;}
int main(){
 fpga_sd_register();
 drop=true;assert(driver.init()==STA_NOINIT);
 assert(std::string(fpga_sd_diagnostic()).find("timeout")!=std::string::npos);
 drop=false;assert(driver.init()==0);assert(ticks>=1120);
 assert(driver.status()==0);
 assert(block_crc(reinterpret_cast<const uint8_t*>("123456789"),9)==0x31c3);
 assert(card_crc(std::vector<uint8_t>(512,0xff))==0x7fa1);
 BYTE data[1024];unsigned frames_before=frames;assert(driver.read(data,0,2)==RES_OK);
 assert(frames-frames_before==44); // formerly 48 frames for two clean sectors
 std::printf("SD bridge packets per clean 512-byte sector: %u (previously 24)\n",(frames-frames_before)/2);
 for(unsigned i=0;i<sizeof data;i++)assert(data[i]==uint8_t(i));
 // A silent data bit error is retried rather than passed to FatFs.
 auto reads_before=read_commands;corrupt_reads=1;
 assert(driver.read(data,0,1)==RES_OK&&read_commands==reads_before+2&&fast);
 for(unsigned i=0;i<512;i++)assert(data[i]==uint8_t(i));
 // Repeated fast-clock corruption falls back to the slow clock and keeps it.
 reads_before=read_commands;corrupt_fast=true;
 assert(driver.read(data,0,1)==RES_OK&&read_commands==reads_before+3&&!fast);
 assert(std::string(fpga_sd_diagnostic()).find("slow CRC retries 3")!=std::string::npos);
 assert(driver.read(data,1,1)==RES_OK&&!fast);corrupt_fast=false;
 assert(driver.init()==0&&fast);
 reads_before=read_commands;corrupt_always=true;
 assert(driver.read(data,0,1)==RES_ERROR&&read_commands==reads_before+3);
 assert(std::string(fpga_sd_diagnostic()).find("CRC failed")!=std::string::npos);
 corrupt_always=false;assert(driver.init()==0&&fast);
 for(unsigned i=0;i<sizeof data;i++)data[i]=uint8_t((i*17)^0x63);
 assert(driver.write(data,7,2)==RES_OK);
 assert(fast);
 assert(!early_deselect);
 BYTE verify[1024];assert(driver.read(verify,7,2)==RES_OK);
 assert(!std::memcmp(data,verify,sizeof data));
 assert(sectors.count(7)&&sectors.count(8)&&!sectors.count(9));
 // A card that remains busy longer than the old 500ms limit still completes.
 program_time_ms=900;auto before=ticks;
 assert(driver.write(data,11,1)==RES_OK&&ticks-before>=900&&burst_busy_polls);
 assert(driver.read(verify,11,1)==RES_OK&&!std::memcmp(data,verify,512));program_time_ms=0;
 write_response=0x0b;assert(driver.write(data,9,1)==RES_ERROR&&!sectors.count(9));
 write_response=5;busy_forever=true;before=ticks;
 assert(driver.write(data,10,1)==RES_ERROR&&sectors.count(10)&&ticks-before>=2000);
 assert(std::string(fpga_sd_diagnostic()).find("busy 2000ms b00")!=std::string::npos);busy_forever=false;
 assert(fast);
 assert(driver.write(data,0,0)==RES_PARERR);
 forced_cmd0=5;assert(driver.init()==STA_NOINIT);
 assert(std::string(fpga_sd_diagnostic())=="SD CMD0: 05 response");
 assert(driver.read(data,0,1)==RES_NOTRDY);
 forced_cmd0=1;bad_frame=true;assert(driver.init()==STA_NOINIT);
 assert(std::string(fpga_sd_diagnostic()).find("bad frame")!=std::string::npos);
 bad_frame=false;assert(driver.init()==0);
 r1_delay=3;assert(driver.init()==0&&driver.read(data,0,1)==RES_OK);
 r1_delay=64;assert(driver.init()==STA_NOINIT);
 r1_delay=0;assert(driver.init()==0);
 return 0;
}
