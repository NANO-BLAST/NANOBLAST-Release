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
 core_running=true;overlay(0);return FR_OK;
}
