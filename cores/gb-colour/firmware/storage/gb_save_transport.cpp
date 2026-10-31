#include "gb_save_transport.h"
#include "crc32.h"
#ifdef NANOBLAST_GB_TRANSPORT_HOST_TEST
#include "../tests/save_transport_platform.h"
#else
#include "utils.h"
#endif
#include <cstring>
namespace {
SemaphoreHandle_t done;
uint8_t response[263];
volatile unsigned frame_bytes=0;
volatile uint16_t pending_sequence=0;
volatile bool waiting=false,valid=false;
uint16_t sequence_number=0;
}
void gb_save_reply_begin(unsigned length){frame_bytes=length>=8&&length<=264?length-1:0;}
void gb_save_reply_byte(unsigned pos,uint8_t value){
 if(!frame_bytes||pos>=frame_bytes)return;
 response[pos]=value;
 if(pos+1!=frame_bytes||!waiting)return;
 const unsigned n=frame_bytes;
 const uint16_t seq=uint16_t(response[0])<<8|response[1];
 const uint32_t crc=uint32_t(response[n-4])<<24|uint32_t(response[n-3])<<16|uint32_t(response[n-2])<<8|response[n-1];
 if(seq!=pending_sequence||(nanoblast::crc32_update(~0u,response,n-4)^~0u)!=crc)return;
 valid=response[2]==0;waiting=false;xSemaphoreGive(done);
}
bool gb_save_request(uint8_t op,unsigned offset,unsigned count,const uint8_t *data,uint8_t *out,unsigned bytes){
 if(count>256||bytes>256||offset>0x1ffff)return false;
 if(!done)done=xSemaphoreCreateBinary();if(!done)return false;
 while(xSemaphoreTake(done,0)==pdTRUE){}
 uint8_t packet[268];const unsigned n=8+(data?count:0);
 const uint16_t seq=++sequence_number;
 packet[0]=op;packet[1]=seq>>8;packet[2]=seq;packet[3]=offset>>16;packet[4]=offset>>8;packet[5]=offset;packet[6]=count>>8;packet[7]=count;
 if(data)std::memcpy(packet+8,data,count);
 const uint32_t crc=nanoblast::crc32_update(~0u,packet,n)^~0u;
 for(unsigned i=0;i<4;i++)packet[n+i]=crc>>(24-8*i);
 pending_sequence=seq;valid=false;waiting=true;
 taskENTER_CRITICAL();fpga_tx_header(0x18,n+5);
 for(unsigned i=0;i<n+4;i++)fpga_tx_byte(packet[i]);taskEXIT_CRITICAL();
 const bool got=xSemaphoreTake(done,pdMS_TO_TICKS(1500))==pdTRUE;
 waiting=false;
 if(!got||!valid||frame_bytes!=bytes+7)return false;
 if(bytes&&out)std::memcpy(out,response+3,bytes);return true;
}
