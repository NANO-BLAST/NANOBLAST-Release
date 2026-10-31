#include <cstring>
#include <algorithm>
#include <strings.h>
#include <cstdio>
#include "../storage/crc32.h"
#if !defined(NANOBLAST_GB_LOADER_HOST_TEST) || defined(NANOBLAST_ROM_READER_INTEGRATION)
#include "../storage/gb_save.h"
#else
static const char *gb_save_status(){return "GB save test";}
static void gb_save_forget(){}
static bool gb_save_flush(){return true;}
static bool gb_save_restore(const char*,uint32_t,unsigned,unsigned,unsigned){return true;}
#endif
#ifdef NANOBLAST_GB_LOADER_HOST_TEST
#include "../tests/sms_loader_platform.h"
#else
#include "utils.h"
#include "cores.h"
#include "overlay.h"
#endif
#include "../storage/rom_file.h"

namespace {char gb_rom_line[48]="GB ROM: not loaded";uint32_t gb_source_crc=0;}
const char *gb_diagnostic(unsigned line){
 static char lines[3][48];uint32_t a=0,b=0,c=0;
 if(line==0)return gb_rom_line;
 char *out=lines[(line-1)%3];
 if(line==1){
  if(get_fpga_debug(5,&a)&&get_fpga_debug(7,&b))std::snprintf(out,48,"GB PC%04X A%04X C%08lX",unsigned(a>>16),unsigned(a&65535),static_cast<unsigned long>(b));
  else std::snprintf(out,48,"GB CPU: diagnostic timeout");
 }else if(line==2){
  if(get_fpga_debug(6,&a)&&get_fpga_debug(8,&b))std::snprintf(out,48,"GB LCD%02X X%u Y%u P%lu",unsigned(a>>24),unsigned((a>>8)&255),unsigned((a>>16)&255),static_cast<unsigned long>(b));
  else std::snprintf(out,48,"GB video: diagnostic timeout");
 }else{
  if(get_fpga_debug(4,&a)&&get_fpga_debug(2,&b)&&get_fpga_debug(3,&c))std::snprintf(out,48,"GB S%03lX R%08lX M%08lX",static_cast<unsigned long>(a),static_cast<unsigned long>(b),static_cast<unsigned long>(c));
  else std::snprintf(out,48,"GB state: diagnostic timeout");
 }
 return out;
}
// CGB-only cartridges require an explicitly advertised Colour FPGA engine.
// Timer cartridges additionally require the RTC1 clock capability.
int loadgb(const char *fname){
    RomFile file;int opened=file.open(fname,7);
    if(opened!=FR_OK){if(file.is_zip())overlay_message(file.error(),1);return opened;}

 const char *ext=std::strrchr(file.name(),'.');
 if(!ext||(strcasecmp(ext,".gb")&&strcasecmp(ext,".gbc"))){overlay_message("Choose a Game Boy .gb/.gbc file",1);return FR_INVALID_NAME;}
 if(!gb_save_flush()){overlay_message("Previous save failed; retry",1);return FR_DISK_ERR;}
 int result=FR_OK;
 const unsigned length=file.size();UINT got=0;
 if(length<32768||length>4*1024*1024||(length&(length-1))){file.close();return FR_INVALID_PARAMETER;}
 result=file.read(fbuf,0x150,&got);
 if(result!=FR_OK||got!=0x150){file.close();return result==FR_OK?FR_DISK_ERR:result;}
 const unsigned type=fbuf[0x147],rom=fbuf[0x148],ram=fbuf[0x149];
 if(!strcasecmp(ext,".gbc")||fbuf[0x143]==0xc0){
  uint32_t capability=0;
  if(!get_fpga_debug(9,&capability)||capability!=0x43474231){
   file.close();overlay_message("Game Boy Colour core required",1);return FR_INVALID_PARAMETER;
  }
 }
 if(type==0x0f||type==0x10){
  uint32_t capability=0;
  if(!get_fpga_debug(13,&capability)||capability!=0x52544331){
   file.close();overlay_message("MBC3 clock core required",1);return FR_INVALID_PARAMETER;
  }
 }
 const bool supported=type==0||type==8||type==9||(type>=1&&type<=3)||type==5||type==6||
 (type>=0x0f&&type<=0x13)||(type>=0x19&&type<=0x1e);
 const bool mapper_size_ok=(type==0||type==8||type==9)?rom==0:
  (type==5||type==6)?rom<=3:(type>=0x19&&type<=0x1e)?rom<=7:rom<=6;
 uint8_t check=0;for(unsigned i=0x134;i<=0x14c;i++)check=check-fbuf[i]-1;
 if(!supported||!mapper_size_ok||rom>7||length!=(32768u<<rom)||ram>5||check!=fbuf[0x14d]){
  file.close();overlay_message("Unsupported/invalid GB cartridge",1);return FR_INVALID_PARAMETER;
 }
 gb_save_forget();
 core_running=false;result=file.seek(0);if(result!=FR_OK){file.close();return result;}
 set_loading_state(1);
 const uint8_t header[8]={'N','B','G','B',uint8_t(type),uint8_t(rom),uint8_t(ram),0};
 std::memcpy(fbuf,header,8);send_fbuf_data(8);
 unsigned total=0;uint32_t crc=~0u;std::snprintf(gb_rom_line,sizeof gb_rom_line,"GB ROM: receiving");
 while(total<length){
  const unsigned n=std::min(1024u,length-total);got=0;result=file.read(fbuf,n,&got);
  if(result!=FR_OK||got!=n){if(result==FR_OK)result=FR_DISK_ERR;break;}
  crc=nanoblast::crc32_update(crc,fbuf,got);send_fbuf_data(got);total+=got;
  if(!(total&0x7fff))overlay_status("Loading GB %u/%uK",total>>10,length>>10);
 }
 const int closed=file.close();if(result==FR_OK)result=closed;
 set_loading_state(0);if(result!=FR_OK)return result;
 gb_source_crc=crc^~0u;
 const uint64_t start=bflb_mtimer_get_time_ms();bool started=false;
 while(bflb_mtimer_get_time_ms()-start<3000){
  const int state=get_fpga_load_status();if(state>=0&&(state&2)){std::snprintf(gb_rom_line,sizeof gb_rom_line,"GB ROM: FPGA readback failed");return FR_INT_ERR;}
  if(state>=0&&(state&1)){started=true;break;}delay(10);
 }
 if(!started){std::snprintf(gb_rom_line,sizeof gb_rom_line,"GB ROM: startup timeout");return FR_TIMEOUT;}
 uint32_t signature=0,received=0,memory=0;
 if(!get_fpga_debug(0,&signature)||signature!=0x47423031||!get_fpga_debug(2,&received)||!get_fpga_debug(3,&memory)){
  std::snprintf(gb_rom_line,sizeof gb_rom_line,"GB ROM: no readback reply");return FR_INT_ERR;
 }
 if(received!=gb_source_crc||memory!=gb_source_crc){std::snprintf(gb_rom_line,sizeof gb_rom_line,"GB ROM: CRC mismatch");return FR_INT_ERR;}
 std::snprintf(gb_rom_line,sizeof gb_rom_line,"GB ROM: verified %08lX",static_cast<unsigned long>(gb_source_crc));
 if(!gb_save_restore(file.name(),gb_source_crc,length,type,ram)){overlay_message(gb_save_status(),1);return FR_DISK_ERR;}
 core_running=true;overlay(0);return FR_OK;
}
