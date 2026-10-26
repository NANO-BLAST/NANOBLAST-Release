#include "fpga_flash.h"
#ifdef NANOBLAST_FLASH_HOST_TEST
#include "../tests/sd_platform.h"
#else
#include "utils.h"
#endif
#include <cstring>
namespace {
SemaphoreHandle_t semaphore;
uint8_t reply[32];
volatile unsigned expected=0,received=0,expected_command=0;
uint8_t sequence=0;
bool dead=false;
volatile bool accepted=false,ok=false,waiting=false;
bool exchange(unsigned command,bool high,const uint8_t *tx,uint8_t *rx,unsigned n){
 if(!semaphore||n>32||(dead&&command!=0x16))return false;
 if(command==0x15)++sequence;
 while(xSemaphoreTake(semaphore,0)==pdTRUE){}
 expected=n;received=0;expected_command=command;accepted=false;ok=false;waiting=true;
 taskENTER_CRITICAL();
 fpga_tx_header(command,command==0x16?1:n+3);
 if(command!=0x16){fpga_tx_byte((high?1:0)|2);fpga_tx_byte(sequence);for(unsigned i=0;i<n;i++)fpga_tx_byte(tx?tx[i]:0xff);}
 taskEXIT_CRITICAL();
 bool done=xSemaphoreTake(semaphore,pdMS_TO_TICKS(500))==pdTRUE;
 waiting=false;
 if(!done||!ok){dead=true;return false;}
 dead=false;
 if(rx)std::memcpy(rx,reply,n);
 return true;
}
}
void fpga_flash_register(){if(!semaphore)semaphore=xSemaphoreCreateBinary();}
bool fpga_flash_available(){uint8_t signature[4];return exchange(0x16,true,nullptr,signature,4)&&!std::memcmp(signature,"NBF1",4);}
bool fpga_flash_transfer(bool high,const uint8_t *tx,uint8_t *rx,unsigned n){
 if(n==0)return exchange(0x15,high,nullptr,nullptr,0);
 for(unsigned off=0;off<n;){unsigned chunk=n-off>32?32:n-off;
  if(!exchange(0x15,high,tx?tx+off:nullptr,rx?rx+off:nullptr,chunk))return false;
  off+=chunk;
 }
 return true;
}
void fpga_flash_reply_begin(unsigned command,unsigned length){
 accepted=false;received=0;
 if(!waiting||command!=expected_command)return;
 if(length!=expected+(command==0x15?2:1)){ok=false;xSemaphoreGive(semaphore);return;}
 accepted=true;
 if(expected==0&&command!=0x15){accepted=false;ok=true;xSemaphoreGive(semaphore);}
}
void fpga_flash_reply_byte(unsigned index,uint8_t value){
 if(!accepted||!waiting)return;
 if(expected_command==0x15){
  if(index==0){if(value!=sequence)accepted=false;else if(expected==0){accepted=false;ok=true;xSemaphoreGive(semaphore);}return;}
  --index;
 }
 if(index!=received||index>=expected||index>=sizeof reply){accepted=false;ok=false;xSemaphoreGive(semaphore);return;}
 reply[index]=value;++received;
 if(received==expected){accepted=false;ok=true;xSemaphoreGive(semaphore);}
}
