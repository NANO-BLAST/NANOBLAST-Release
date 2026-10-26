#include <cstring>
#include <strings.h>
#include <cstdio>
#include "../storage/crc32.h"
#ifdef NANOBLAST_SNES_LOADER_HOST_TEST
#include "../tests/sms_loader_platform.h"
#else
#include "utils.h"
#include "cores.h"
#include "overlay.h"
#endif

namespace {
char snes_detail[48]="SNES: no game selected";
char snes_transfer[48]="ROM: not checked",snes_cpu[48]="CPU: no capture",snes_apu[48]="APU: no capture";
// Validate before shifting or using cartridge-controlled sizes. The FPGA
// expects the 64 bytes at the selected internal header before the ROM stream.
int snes_header(FIL *file,unsigned pos,unsigned length,unsigned kind) {
    if(pos>f_size(file)||64>f_size(file)-pos||f_lseek(file,pos)!=FR_OK)return -1;
    UINT got=0;
    if(f_read(file,fbuf,64,&got)!=FR_OK||got!=64)return -1;
    const unsigned mapper=fbuf[21],rom=fbuf[23],ram=fbuf[24];
    const unsigned reset=unsigned(fbuf[60])|(unsigned(fbuf[61])<<8);
    if(rom<5||rom>13||ram>7||reset<0x8000)return -1;
    if(!((kind==0&&((mapper&3)==0||mapper==0x53))||
         (kind==1&&(mapper&3)==1)||(kind==2&&(mapper&3)==2)))return -1;
    const unsigned declared=1024u<<rom;
    // Ignore the title (some valid homebrew titles are not printable), but
    // require a plausible image size and a real reset vector.
    if(declared<length||declared>8*1024*1024)return -1;
    const unsigned complement=unsigned(fbuf[28])|(unsigned(fbuf[29])<<8);
    const unsigned checksum=unsigned(fbuf[30])|(unsigned(fbuf[31])<<8);
    // A checksum pair is strong evidence, but do not reject homebrew with
    // omitted sums. Titles are only a preference, never a validity rule.
    int score=1;
    if((checksum^complement)==0xffff&&checksum!=0&&checksum!=0xffff)score+=16;
    if((mapper&0xe0)==0x20||mapper==0x53)score+=4;
    bool text=true;for(unsigned i=0;i<21;i++)text=text&&fbuf[i]>=32&&fbuf[i]<=126;
    if(text)score+=2;
    if(declared==length)score+=1;
    return score;
}
bool supported_snes_cartridge() {
    const unsigned mapper=fbuf[21],type=fbuf[22];
    // Standard ROM/RAM/battery cartridges, DSP1-4, OBC1 and S-RTC.
    if(type<=2)return (mapper&0x0f)<=1;
    if(type==3||type==5)return mapper==0x20||mapper==0x21||mapper==0x30||mapper==0x31;
    return (mapper==0x30&&type==0x25)||(mapper==0x35&&type==0x55);
}
}
const char *snes_load_diagnostic(){return snes_detail;}
const char *snes_transfer_diagnostic(){return snes_transfer;}
const char *snes_cpu_diagnostic(){
    uint32_t low=0,high=0,bank=0,state=0;
    if(get_fpga_debug(0x26,&low)&&get_fpga_debug(0x27,&high)&&
       get_fpga_debug(0x2d,&bank)&&get_fpga_debug(5,&state))
        std::snprintf(snes_cpu,sizeof snes_cpu,"CPU %02lX:%04lX flags %02lX",
          static_cast<unsigned long>(bank&255),static_cast<unsigned long>(((high&255)<<8)|(low&255)),
          static_cast<unsigned long>(state&255));
    else std::snprintf(snes_cpu,sizeof snes_cpu,"CPU: diagnostic timeout");
    return snes_cpu;
}
const char *snes_apu_diagnostic(){
    uint32_t lo=0,hi=0,i0=0,i1=0,o0=0,o1=0;
    if(get_fpga_debug(0x43,&lo)&&get_fpga_debug(0x44,&hi)&&
       get_fpga_debug(0x60,&i0)&&get_fpga_debug(0x61,&i1)&&
       get_fpga_debug(0x64,&o0)&&get_fpga_debug(0x65,&o1))
        std::snprintf(snes_apu,sizeof snes_apu,"APU %04X I%02X%02X O%02X%02X",
          unsigned(((hi&255)<<8)|(lo&255)),unsigned(i0&255),unsigned(i1&255),unsigned(o0&255),unsigned(o1&255));
    else std::snprintf(snes_apu,sizeof snes_apu,"APU: diagnostic timeout");
    return snes_apu;
}
int loadsnes(const char *fname) {
    const char *ext=std::strrchr(fname,'.');
    if(!ext||(strcasecmp(ext,".sfc")&&strcasecmp(ext,".smc"))){
        overlay_message("Choose a SNES .sfc or .smc",1);return FR_INVALID_NAME;
    }
    FRESULT result=f_open(&fcore,fname,FA_READ);
    if(result!=FR_OK)return result;
    const unsigned size=f_size(&fcore),offset=size%1024,length=size-offset;
    // The Nano's upstream memory map reserves the final 256KiB of banks
    // 0/1 for work/save RAM. Do not silently overwrite it or alias 6MiB ROMs.
#if defined(TANG_NANO20K)
    const unsigned limit=0x3c0000;
#else
    const unsigned limit=0x600000;
#endif
    if((offset!=0&&offset!=512)||length<32768||length>limit){
        f_close(&fcore);overlay_message("Unsupported SNES ROM size",1);return FR_INVALID_PARAMETER;
    }
    std::snprintf(snes_transfer,sizeof snes_transfer,"ROM: not checked");
    uint8_t chosen[64];int best=-1;unsigned selected=0;
    const unsigned positions[]={0x7fc0,0xffc0,0x40ffc0};
    for(unsigned kind=0;kind<3;kind++){
        const int score=snes_header(&fcore,offset+positions[kind],length,kind);
        if(score>best){best=score;selected=positions[kind];std::memcpy(chosen,fbuf,64);}
    }
    const bool found=best>=0;
    if(found)std::memcpy(fbuf,chosen,64);
    // Contra III's 22-character title ends in 'S' at the mapper byte ($53).
    // Normalize only the transmitted LoROM metadata; preserve every ROM byte.
    if(found&&selected==0x7fc0&&fbuf[21]==0x53&&fbuf[22]<=2)fbuf[21]=0x20;
    if(found)std::snprintf(snes_detail,sizeof snes_detail,"SNES H%06X M%02X T%02X R%02X",selected,unsigned(fbuf[21]),unsigned(fbuf[22]),unsigned(fbuf[23]));
    else std::snprintf(snes_detail,sizeof snes_detail,"SNES: invalid header");
    if(!found||!supported_snes_cartridge()){
        char error[40];std::snprintf(error,sizeof error,"Unsupported chip M%02X T%02X",unsigned(fbuf[21]),unsigned(fbuf[22]));
        f_close(&fcore);overlay_message(found?error:"Invalid SNES ROM header",1);
        return FR_INVALID_PARAMETER;
    }
#if defined(TANG_NANO20K)
    if(fbuf[22]==3||fbuf[22]==5){
        // New bitstreams advertise their optional cartridge-DSP capability.
        // A standard-cartridge test image must not silently run DSP games.
        const int caps=get_fpga_load_status();
        if(caps<0){f_close(&fcore);return FR_TIMEOUT;}
        if((caps&0xf0)==0xa0&&!(caps&4)){
            f_close(&fcore);overlay_message("Core has no cartridge DSP",1);return FR_INVALID_PARAMETER;
        }
    }
#endif
    // Seek before resetting the core; fbuf still contains the chosen header.
    result=f_lseek(&fcore,offset);
    if(result!=FR_OK){f_close(&fcore);return result;}
    core_running=false;set_loading_state(1);send_fbuf_data(64);
    unsigned total=0;uint32_t crc=0xffffffffu;
    while(total<length){
        UINT got=0;const unsigned chunk=length-total>1024?1024:length-total;
        result=f_read(&fcore,fbuf,chunk,&got);
        if(result!=FR_OK||got!=chunk){if(result==FR_OK)result=FR_DISK_ERR;break;}
        crc=nanoblast::crc32_update(crc,fbuf,got);
        send_fbuf_data(got);total+=got;
        if((total&0xffff)==0)overlay_status("Loading SNES %u/%uK",total>>10,length>>10);
    }
    const FRESULT closed=f_close(&fcore);if(result==FR_OK)result=closed;
    if(result!=FR_OK){set_loading_state(0);return result;}
#if defined(TANG_NANO20K)
    // Keep the game in reset until the FPGA's received stream and a complete
    // read-only scan of the actual SDRAM both match the SD file's CRC32.
    uint32_t value=0;
    auto failure=[&](const char *message,int error){
        std::snprintf(snes_transfer,sizeof snes_transfer,"%s",message);
        set_loading_state(0);overlay_message(message,1);return error;
    };
    if(!get_fpga_debug(0,&value)||value!=0x534e3031u)
        return failure("SNES diagnostic image required",FR_INT_ERR);
    if(!get_fpga_debug(1,&value)||value!=length)
        return failure("ROM: receive length mismatch",FR_INT_ERR);
    crc=~crc;
    if(!get_fpga_debug(2,&value)||value!=crc)
        return failure("ROM: UART CRC mismatch",FR_INT_ERR);
    if(!get_fpga_debug(0x80,&value))return failure("ROM: scan command timeout",FR_TIMEOUT);
    const uint64_t scan_start=bflb_mtimer_get_time_ms();bool verified=false;
    while(bflb_mtimer_get_time_ms()-scan_start<10000){
        if(!get_fpga_debug(4,&value))return failure("ROM: scan status timeout",FR_TIMEOUT);
        if(value&4)return failure("ROM: scan fault",FR_INT_ERR);
        if(value&2){verified=true;break;}
        delay(5);
    }
    if(!verified)return failure("ROM: SDRAM scan timeout",FR_TIMEOUT);
    if(!get_fpga_debug(3,&value)||value!=crc)
        return failure("ROM: SDRAM CRC mismatch",FR_INT_ERR);
    std::snprintf(snes_transfer,sizeof snes_transfer,"ROM: verified %08lX",static_cast<unsigned long>(crc));
#endif
    set_loading_state(0);
#if defined(TANG_NANO20K)
    const uint64_t start=bflb_mtimer_get_time_ms();bool started=false;
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
