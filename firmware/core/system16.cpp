// NANOBLAST System 16 World set 3 loader. GPL-3.0-or-later.
#ifdef NANOBLAST_SMS_LOADER_HOST_TEST
#include "../tests/sms_loader_platform.h"
#else
#include "utils.h"
#include "cores.h"
#include "overlay.h"
#endif
#include "../storage/rom_file.h"
#include <cstring>
#include <strings.h>
int loads16(const char *fname) {
    RomFile file;
    int result=file.open(fname,16);
    if(result!=FR_OK)return result;
    const char *extension=std::strrchr(file.name(),'.');
    const unsigned length=file.size();
    if(!extension||strcasecmp(extension,".rom")||length<0x444020||length>0x44c020){
        overlay_message("Use merged goldnaxe3 .rom",1);return FR_INVALID_PARAMETER;
    }
    uint32_t capability=0;
    if(!get_fpga_debug(0,&capability)||capability!=0x53313631)return FR_INVALID_PARAMETER;
    UINT got=0;
    result=file.read(fbuf,32,&got);
    if(result!=FR_OK||got!=32)return result==FR_OK?FR_DISK_ERR:result;
    if(fbuf[0x10]!=0||fbuf[0x11]!=1||fbuf[0x12]!=0||fbuf[0x13]!=0||fbuf[0x18]!=0x40){
        overlay_message("Requires Golden Axe World set 3",1);return FR_INVALID_PARAMETER;
    }
    result=file.seek(0);if(result!=FR_OK)return result;
    core_running=false;set_loading_state(1);
    unsigned total=0;
    while(total<length){
        const unsigned chunk=length-total>1024?1024:length-total;
        got=0;result=file.read(fbuf,chunk,&got);
        if(result!=FR_OK||got!=chunk){if(result==FR_OK)result=FR_DISK_ERR;break;}
        send_fbuf_data(got);total+=got;
        if((total&0x3fff)==0)overlay_status("Loading S16 %u/%uK",total>>10,length>>10);
    }
    const int closed=file.close();if(result==FR_OK)result=closed;
    set_loading_state(0);if(result!=FR_OK)return result;
    const uint64_t start=bflb_mtimer_get_time_ms();
    while(bflb_mtimer_get_time_ms()-start<3000){
        const int state=get_fpga_load_status();
        if(state>=0&&(state&2))return FR_INT_ERR;
        if(state>=0&&(state&1)){core_running=true;overlay(0);return FR_OK;}
        delay(10);
    }
    return FR_TIMEOUT;
}
