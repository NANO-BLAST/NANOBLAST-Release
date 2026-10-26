// SD SPI block driver over the NANOBLAST FPGA command bridge. GPL-3.0.
#include "fpga_sd.h"
#ifdef NANOBLAST_SD_HOST_TEST
#include "../tests/sd_platform.h"
#else
#include "utils.h"
extern "C" {
#include "diskio.h"
}
#endif
#include <cstring>
#include <cstdio>
namespace {
SemaphoreHandle_t reply_sem;
uint8_t reply[32];
volatile unsigned expected,received;
volatile bool reply_ok;
volatile bool frame_accepted;
bool initialized=false,sdhc=false,fast=false,transport_dead=false;
const char *stage="not started",*failure="";
unsigned last_command=0,last_response=0xff;
unsigned read_crc_retries=0;
uint32_t busy_elapsed=0;unsigned busy_byte=0xff;
constexpr unsigned WriteBusyTimeoutMs=2000;
uint8_t flags(bool high){return uint8_t((high?1:0)|(fast?2:0));}
bool transfer(bool high,const uint8_t*tx,uint8_t*rx,unsigned n) {
 if(transport_dead)return false;
 if(n>32){
  for(unsigned offset=0;offset<n;){
   unsigned chunk=n-offset>32?32:n-offset;
   if(!transfer(high,tx?tx+offset:nullptr,rx?rx+offset:nullptr,chunk))return false;
   offset+=chunk;
  }
  return true;
 }
 while(xSemaphoreTake(reply_sem,0)==pdTRUE){}
 expected=n;received=0;reply_ok=false;frame_accepted=false;
 taskENTER_CRITICAL();
 fpga_tx_header(0x10,n+2);fpga_tx_byte(flags(high));
 for(unsigned i=0;i<n;i++)fpga_tx_byte(tx?tx[i]:0xff);
 taskEXIT_CRITICAL();
 if(xSemaphoreTake(reply_sem,pdMS_TO_TICKS(1000))!=pdTRUE){transport_dead=true;failure="timeout";return false;}
 if(!reply_ok){failure="bad frame";return false;}
 if(rx)std::memcpy(rx,reply,n);
 return true;
}
bool select(bool high){return transfer(high,nullptr,nullptr,0);}
bool receive(uint8_t &v){return transfer(false,nullptr,&v,1);}
bool wait_ready(){
 uint64_t start=bflb_mtimer_get_time_ms();uint8_t r;
 do{
  if(!receive(r))return false;
  if(r==0xff)return true;
 }while(bflb_mtimer_get_time_ms()-start<WriteBusyTimeoutMs);
 last_response=r;failure="card busy";return false;
}
bool command(unsigned cmd,uint32_t arg,uint8_t &r) {
 last_command=cmd;last_response=0xff;stage="command";failure="response";
 if(!transfer(true,nullptr,nullptr,1))return false;
 if(cmd!=0&&!wait_ready())return false;
 // Asserting CS is part of transfer(). Clock the first R1 response byte in
 // the command packet, saving two bridge round trips per SD command.
 uint8_t packet[7]={uint8_t(0x40|cmd),uint8_t(arg>>24),uint8_t(arg>>16),uint8_t(arg>>8),uint8_t(arg),uint8_t(cmd==0?0x95:cmd==8?0x87:0x01),0xff},response[7];
 if(!transfer(false,packet,response,sizeof packet))return false;
 r=response[6];
 for(unsigned i=0;i<64;i++){last_response=r;if(!(r&0x80))return true;if(i!=63&&!receive(r))return false;}
 return false;
}
bool wait_write_ready(){
 const uint64_t start=bflb_mtimer_get_time_ms();
 uint8_t samples[32];busy_elapsed=0;
 do{
  // Clock complete bursts while the card programs, avoiding a UART round trip
  // after every SPI byte. Idle 0xff clocks cannot start a new card command.
  if(!transfer(false,nullptr,samples,sizeof samples))return false;
  busy_byte=samples[sizeof samples-1];
  busy_elapsed=bflb_mtimer_get_time_ms()-start;
  if(busy_byte==0xff)return true;
 }while(busy_elapsed<WriteBusyTimeoutMs);
 failure="write busy";return false;
}
int status(){return initialized?0:STA_NOINIT;}
int init(){
 // A failed startup must not permanently disable later mount attempts. The
 // bridge finishes within milliseconds; allow the parser's 100ms stale-frame
 // timeout before accepting a fresh request after a transport timeout.
 if(transport_dead)delay(120);
 transport_dead=false;stage="power clocks";failure="";last_command=0;last_response=0xff;
 initialized=false;fast=false;sdhc=false;read_crc_retries=0;
 uint8_t clocks[10];std::memset(clocks,0xff,sizeof clocks);
 if(!transfer(true,clocks,nullptr,10))return STA_NOINIT;
 uint8_t r;
 if(!command(0,0,r)||r!=1)return STA_NOINIT;
 bool v2=false;
 if(!command(8,0x1aa,r))return STA_NOINIT;
 if(r==1){stage="CMD8 echo";uint8_t echo[4];if(!transfer(false,nullptr,echo,4)||echo[2]!=1||echo[3]!=0xaa)return STA_NOINIT;v2=true;}
 else if(r!=5)return STA_NOINIT;
 uint64_t start=bflb_mtimer_get_time_ms();
 do {
  if(!command(55,0,r)||(r!=0&&r!=1))return STA_NOINIT;
  if(!command(41,v2?0x40000000u:0,r))return STA_NOINIT;
  if(r==0)break;
  if(r!=1||bflb_mtimer_get_time_ms()-start>2000)return STA_NOINIT;
  delay(10);
 }while(true);
 if(!command(58,0,r)||r)return STA_NOINIT;
 uint8_t ocr[4];if(!transfer(false,nullptr,ocr,4)||!select(true))return STA_NOINIT;
 sdhc=(ocr[0]&0x40)!=0;
 if(!sdhc && (!command(16,512,r)||r||!select(true)))return STA_NOINIT;
 fast=true;initialized=true;stage="ready";failure="";return 0;
}
uint16_t block_crc(const uint8_t*data,unsigned size){
 uint16_t c=0;
 while(size--){c^=uint16_t(*data++)<<8;for(unsigned bit=0;bit<8;bit++)c=uint16_t((c<<1)^((c&0x8000)?0x1021:0));}
 return c;
}
int read(BYTE*buffer,LBA_t sector,UINT count){
 if(!initialized||!count)return RES_NOTRDY;
 for(UINT i=0;i<count;i++){
  bool valid=false;
  for(unsigned attempt=0;attempt<3;attempt++){
  if(attempt==2)fast=false;
  uint8_t r;if(!command(17,sdhc?sector:sector*512u,r)||r){select(true);return RES_ERROR;}
  uint64_t start=bflb_mtimer_get_time_ms();
  do {if(!receive(r)){select(true);return RES_ERROR;}
   if(r==0xfe)break;
   if(r!=0xff||bflb_mtimer_get_time_ms()-start>500){last_response=r;failure="read token";select(true);return RES_ERROR;}
  }while(true);
  for(unsigned off=0;off<512;off+=128)if(!transfer(false,nullptr,buffer+off,128)){select(true);return RES_ERROR;}
  uint8_t crc[2];if(!transfer(false,nullptr,crc,2)||!select(true))return RES_ERROR;
  // The SD read block carries a CRC16, even when command CRC checking is off.
  // Do not let a corrupt data sector enter FatFs or an artwork/ROM upload.
  if(block_crc(buffer,512)==uint16_t((unsigned(crc[0])<<8)|crc[1])){valid=true;failure="";break;}
  ++read_crc_retries;failure="read CRC";
  }
  if(!valid)return RES_ERROR;
  buffer+=512;sector++;
 }
 return RES_OK;
}
int write(const BYTE*buffer,LBA_t sector,UINT count){
 if(!initialized)return RES_NOTRDY;
 if(!count)return RES_PARERR;
 // Use the already-supported initialization clock for writes. Restore the
 // normal read clock on every exit, including errors; this is one-time setup.
 struct WriteClock {
  bool previous;
  WriteClock():previous(fast){fast=false;}
  ~WriteClock(){fast=previous;}
 } write_clock;
 for(UINT i=0;i<count;i++){
  uint8_t r,token=0xfe,crc[2]={0xff,0xff};
  if(!command(24,sdhc?sector:sector*512u,r)||r){select(true);return RES_ERROR;}
  // Nwr is at least one full clock byte between R1 and the write token.
  // Reference: STMicroelectronics STM32CubeG4 adafruit_802_sd.c WriteBlocks.
  if(!transfer(false,nullptr,nullptr,1)||!transfer(false,&token,nullptr,1)||!transfer(false,buffer,nullptr,512)||
     !transfer(false,crc,nullptr,2)){select(true);return RES_ERROR;}
  unsigned polls=0;
  do {if(!receive(r)){select(true);return RES_ERROR;}}while(r==0xff&&++polls<64);
  last_response=r;
  if((r&0x1f)!=5){failure="write rejected";select(true);return RES_ERROR;}
  // The card may start programming one clock byte after the data response.
  // Clock that byte before testing busy, rather than treating it as ready.
  if(!receive(r)){select(true);return RES_ERROR;}
  if(!wait_write_ready()){select(true);return RES_ERROR;}
  if(!transfer(true,nullptr,nullptr,1))return RES_ERROR;
  buffer+=512;sector++;
 }
 return RES_OK;
}
int ioctl(BYTE cmd,void *buffer){
 if(cmd==CTRL_SYNC)return initialized?RES_OK:RES_NOTRDY;
 if(cmd==GET_SECTOR_SIZE){*static_cast<uint16_t*>(buffer)=512;return RES_OK;}
 if(cmd==GET_BLOCK_SIZE){*static_cast<uint32_t*>(buffer)=1;return RES_OK;}
 return RES_PARERR;
}
}
const char *fpga_sd_diagnostic(){
 static char line[33];
 if(!std::strcmp(failure,"read CRC"))std::snprintf(line,sizeof line,"SD read CRC failed (%u)",read_crc_retries);
 else if(read_crc_retries&&!failure[0])std::snprintf(line,sizeof line,"SD read: %s CRC retries %u",fast?"fast":"slow",read_crc_retries);
 else if(!std::strcmp(failure,"write busy"))std::snprintf(line,sizeof line,"SD24:%02X busy %lums b%02X",last_response,static_cast<unsigned long>(busy_elapsed),busy_byte);
 else if(!std::strcmp(stage,"command"))std::snprintf(line,sizeof line,"SD CMD%u: %02X %s",last_command,last_response,failure);
 else std::snprintf(line,sizeof line,"SD %s %s",stage,failure);
 return line;
}
void fpga_sd_register(){
 reply_sem=xSemaphoreCreateBinary();
 FATFS_DiskioDriverTypeDef driver={status,init,read,write,ioctl,nullptr};
 disk_driver_callback_init(DEV_SD,&driver);
}
void fpga_sd_reply_begin(unsigned length){
 received=0;reply_ok=false;
 frame_accepted=length==expected+1;
 if(!frame_accepted){xSemaphoreGive(reply_sem);return;}
 if(length==1){reply_ok=true;frame_accepted=false;xSemaphoreGive(reply_sem);}
}
void fpga_sd_reply_byte(unsigned index,uint8_t v){
 if(!frame_accepted)return;
 if(index<expected && index<sizeof reply){reply[index]=v;received=index+1;}
 if(received==expected){reply_ok=true;frame_accepted=false;xSemaphoreGive(reply_sem);}
}
