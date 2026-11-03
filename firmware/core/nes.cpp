#include <cstring>
#include <strings.h>
#ifdef NANOBLAST_NES_LOADER_HOST_TEST
#include "../tests/sms_loader_platform.h"
#else
#include "utils.h"
#include "cores.h"
#include "overlay.h"
#endif
#include "../storage/rom_file.h"

int loadnes(const char *fname){
 RomFile file;int result=file.open(fname,1);
 if(result!=FR_OK){if(file.is_zip())overlay_message(file.error(),1);return result;}
 const char*extension=std::strrchr(file.name(),'.');
 if(!extension||strcasecmp(extension,".nes")){overlay_message("Only .nes supported",1);return FR_INVALID_NAME;}
 const unsigned size=file.size();unsigned total=0;core_running=false;set_loading_state(1);
 while(total<size){
  unsigned got=0,n=size-total>1024?1024:size-total;
  result=file.read(fbuf,n,&got);
  if(result!=FR_OK||got!=n){if(result==FR_OK)result=FR_DISK_ERR;break;}
  send_fbuf_data(got);total+=got;
  if(!(total&0xfff))overlay_status("Loading NES %u/%uK",total>>10,size>>10);
 }
 const int closed=file.close();if(result==FR_OK)result=closed;
 set_loading_state(0);if(result!=FR_OK)return result;
 // The loader, menu DMA drain and NES reset release are separate stages.
 // New cores report real status; legacy cores keep their ready-bit protocol.
 const uint64_t started=bflb_mtimer_get_time_ms();int state=-1;
 while(bflb_mtimer_get_time_ms()-started<3000){
  state=get_fpga_load_status();
  if(state>=0&&(state&2)){overlay_message("NES loader rejected ROM",1);return FR_INT_ERR;}
  if(state>=0&&(state&1))break;
  delay(2);
 }
 if(state<0||!(state&1)){overlay_message("NES loader timeout",1);return FR_TIMEOUT;}
 overlay(0);
 if(state&0x80){
  const uint64_t released=bflb_mtimer_get_time_ms();bool running=false;
  while(bflb_mtimer_get_time_ms()-released<1000){
   state=get_fpga_load_status();
   if(state>=0&&(state&2)){overlay(1);return FR_INT_ERR;}
   if(state>=0&&(state&4)&&!(state&0x38)){running=true;break;}
   delay(2);
  }
  if(!running){overlay(1);overlay_message("NES reset handoff timeout",1);return FR_TIMEOUT;}
 }
 core_running=true;return FR_OK;
}
