// BL616 artwork transport. GPL-3.0.
#include "background_runtime.h"
#include "background_upload.h"
#include "background_compression.h"
#include "loading_screen.h"
#include "background_asset.h"
#ifdef NANOBLAST_SD_SETUP_HOST_TEST
#include "../tests/background_runtime_platform.h"
#else
#include "utils.h"
#include "overlay.h"
#endif
#include <initializer_list>
#include <memory>
#include <cstdio>
#include <cstring>
namespace {
const char *background_status="not loaded";
char loaded_status[32];
bool oled_mode=false;
SemaphoreHandle_t ack;
volatile unsigned ack_status;
struct Memory: nanoblast::AssetSource {
 const uint8_t*data;unsigned length,position=0;
 Memory(const uint8_t*p,unsigned n):data(p),length(p?n:0){}
 uint32_t size()override{return length;}
 bool read(uint8_t*out,unsigned n)override{
  if(!data||n>length-position)return false;
  std::memcpy(out,data+position,n);position+=n;return true;
 }
};
struct Transport:nanoblast::BackgroundTransport {
 void enable(bool v)override{taskENTER_CRITICAL();fpga_tx_header(17,2);fpga_tx_byte(v);taskEXIT_CRITICAL();}
 void palette(uint32_t v)override{taskENTER_CRITICAL();fpga_tx_header(18,5);for(int s=24;s>=0;s-=8)fpga_tx_byte(v>>s);taskEXIT_CRITICAL();}
 bool pixels(uint32_t a,const uint8_t*d,unsigned n)override{
  while(xSemaphoreTake(ack,0)==pdTRUE){}
  ack_status=255;
  taskENTER_CRITICAL();fpga_tx_header(19,n+5);for(int s=24;s>=0;s-=8)fpga_tx_byte(a>>s);for(unsigned i=0;i<n;i++)fpga_tx_byte(d[i]);taskEXIT_CRITICAL();
  return xSemaphoreTake(ack,pdMS_TO_TICKS(1000))==pdTRUE&&ack_status==0;
 }
 void progress(unsigned n,unsigned size)override{
  nanoblast_loading_progress(n,size);
 }
};
}
void nanoblast_loading_progress(unsigned loaded,unsigned size){
 unsigned cells=size?(loaded>=size?26:loaded*26/size):0;
 char row[33];row[0]=row[1]=' ';row[2]='[';
 for(unsigned i=0;i<26;i++)row[i+3]=i<cells?'=':' ';
 row[29]=']';row[30]=row[31]=' ';row[32]=0;
 overlay_cursor(0,14);overlay_printf("%s",row);
}
void nanoblast_loading_screen(){
 // Text clearing does not reset the renderer's independent rectangles.
 // Bypass the Debug panel policy while loading; only the bar and label show.
 for(unsigned command:{2u,3u}){
  taskENTER_CRITICAL();fpga_tx_header(14,5);
  fpga_tx_byte(command);fpga_tx_byte(0);fpga_tx_byte(0);fpga_tx_byte(0);
  taskEXIT_CRITICAL();
 }
 overlay_clear();
 nanoblast_loading_progress(0,0);
 overlay_cursor(11,27);overlay_printf("LOADING...");
}
void nanoblast_background_reply(unsigned status){ack_status=status;if(ack)xSemaphoreGive(ack);}
const char *nanoblast_background_status(){return background_status;}
// Kept for the existing Debug layout; embedded artwork has no fallback path.
const char *nanoblast_background_fallback_status(){return "";}
const char *nanoblast_background_fallback_sd(){return "";}
void nanoblast_background_oled(bool enabled){
 if(oled_mode==enabled)return;
 oled_mode=enabled;
 if(enabled){
  taskENTER_CRITICAL();fpga_tx_header(17,2);fpga_tx_byte(2);taskEXIT_CRITICAL();
  background_status="off (OLED Mode)";
 }else nanoblast_load_background();
}
void nanoblast_load_background(){
 if(oled_mode){
  taskENTER_CRITICAL();fpga_tx_header(17,2);fpga_tx_byte(2);taskEXIT_CRITICAL();
  background_status="off (OLED Mode)";return;
 }
 if(!ack)ack=xSemaphoreCreateBinary();
 unsigned length=0;const auto*embedded=nanoblast_builtin_background(length);
 Memory memory(embedded,length);
 Transport transport;
 nanoblast_loading_screen();
 const uint64_t start=bflb_mtimer_get_time_ms();
 std::unique_ptr<nanoblast::CompressedBackground> decoded(new nanoblast::CompressedBackground(memory));
 const auto result=nanoblast::upload_background(*decoded,transport);
 switch(result){
  case nanoblast::BackgroundResult::Ready:
   std::snprintf(loaded_status,sizeof loaded_status,"loaded flash, %lu ms",static_cast<unsigned long>(bflb_mtimer_get_time_ms()-start));
   background_status=loaded_status;break;
  case nanoblast::BackgroundResult::Invalid:background_status="invalid flash artwork";break;
  case nanoblast::BackgroundResult::ReadError:background_status="flash artwork decode failed";break;
  case nanoblast::BackgroundResult::TransportError:background_status="artwork upload failed";break;
 }
 dprint("NANOBLAST artwork flash result=%u ms=%lu\n",unsigned(result),static_cast<unsigned long>(bflb_mtimer_get_time_ms()-start));
}
