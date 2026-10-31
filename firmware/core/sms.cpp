#include <cstring>
#include <strings.h>
#ifdef NANOBLAST_SMS_LOADER_HOST_TEST
#include "../tests/sms_loader_platform.h"
#else
#include "utils.h"
#include "cores.h"
#include "overlay.h"
#endif

#include "../storage/rom_file.h"

int loadsms(const char *fname) {
    RomFile file;int opened=file.open(fname,5);
    if(opened!=FR_OK){if(file.is_zip())overlay_message(file.error(),1);return opened;}

    const char *extension=std::strrchr(file.name(),'.');
    const bool gear=extension&&!strcasecmp(extension,".gg");
    if(!extension||(strcasecmp(extension,".sms")&&!gear)){
        overlay_message("Choose an SMS .sms or Game Gear .gg",1);return FR_INVALID_NAME;
    }
#if defined(TANG_NANO20K)
    if(gear){
        uint32_t capability=0;
        if(!get_fpga_debug(0,&capability)||capability!=0x53474731){
            overlay_message("Update SMS core for Game Gear",1);return FR_INVALID_PARAMETER;
        }
    }
#endif
    int result=FR_OK;
    const unsigned size=file.size(),header=(size%1024==512)?512:0;
    const unsigned length=size-header;
    // The Nano mapper masks power-of-two cartridge images up to 4MiB.
    if(length<8192||length>4*1024*1024||(length&(length-1))){
        file.close();overlay_message("Unsupported SMS ROM size",1);return FR_INVALID_PARAMETER;
    }
    core_running=false;
    result=file.seek(header);
    if(result!=FR_OK){file.close();return result;}
    set_core_config((get_core_config()&~8u)|(gear?8u:0u));
    set_loading_state(1);
    unsigned total=0;
    while(total<length){
        UINT got=0;unsigned chunk=length-total>1024?1024:length-total;
        result=file.read(fbuf,chunk,&got);
        if(result!=FR_OK||got!=chunk){if(result==FR_OK)result=FR_DISK_ERR;break;}
        send_fbuf_data(got);total+=got;
        if((total&0x3fff)==0)overlay_status(gear?"Loading GG %u/%uK":"Loading SMS %u/%uK",total>>10,length>>10);
    }
    const int closed=file.close();
    if(result==FR_OK)result=closed;
    set_loading_state(0);
    if(result!=FR_OK)return result;
#if defined(TANG_NANO20K)
    // Do not hide the menu or claim success until the FPGA has drained its
    // last write and confirmed that its loader did not overflow or reject it.
    const uint64_t start=bflb_mtimer_get_time_ms();
    bool started=false;
    while(bflb_mtimer_get_time_ms()-start<3000){
        const int state=get_fpga_load_status();
        if(state>=0&&(state&2))return FR_INT_ERR;
        if(state>=0&&(state&1)){started=true;break;}
        delay(10);
    }
    if(!started)return FR_TIMEOUT;
#endif
    core_running=true;overlay(0);return FR_OK;
}
