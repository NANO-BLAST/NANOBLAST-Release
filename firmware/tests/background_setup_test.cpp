// Exercise the real installer and SDK FatFs on a host-only RAM disk.
#include "background_setup.h"
#include "background_runtime.h"
#include "background_asset.h"
#include "background_runtime_platform.h"
extern "C" {
#include "ff.h"
#include "diskio.h"
}
#include <vector>
#include <fstream>
#include <cassert>
#include <cstring>
#include <string>
#include <cstdarg>
#include <cstdio>
const char *drv="sd:";
FATFS fs;int nanoblast_sd_mount_result=0;
const char *fpga_sd_diagnostic(){return "SD test";}
bool semaphore=false,background_enabled=false;
unsigned flash_fault=0,disk_reads=0,disk_writes=0;
bool disk_fault=false,upload_fault_once=false;
const uint8_t *nanoblast_real_builtin_background(unsigned&);
const uint8_t *nanoblast_builtin_background(unsigned &length){
 const auto*original=nanoblast_real_builtin_background(length);
 if(flash_fault==3){length=0;return nullptr;}
 if(!flash_fault)return original;
 static std::vector<uint8_t> damaged;damaged.assign(original,original+length);
 damaged[flash_fault==1?0:length/2]^=0x40;return damaged.data();
}
unsigned background_control=0,pixel_packets=0;
unsigned command_type=0,tx_left=0,tx_index=0;uint32_t address=0,mask_word=0;
bool selection_enabled=true,panel_enabled=true;
std::vector<uint8_t> screen;
SemaphoreHandle_t xSemaphoreCreateBinary(){return &semaphore;}
int xSemaphoreTake(SemaphoreHandle_t s,unsigned){bool v=*s;*s=false;return v;}
void xSemaphoreGive(SemaphoreHandle_t s){*s=true;}
uint64_t bflb_mtimer_get_time_ms(){static uint64_t ticks=0;return ticks++;}
void dprint(const char*,...){}
void fpga_tx_header(int cmd,int len){if(cmd==19)++pixel_packets;command_type=cmd;tx_left=len-1;tx_index=0;address=0;mask_word=0;}
void fpga_tx_byte(uint8_t v){
 if(command_type==14){
  mask_word=(mask_word<<8)|v;
  if(tx_index==3){
   assert(mask_word==0x02000000||mask_word==0x03000000);
   if(mask_word==0x02000000)selection_enabled=false;else panel_enabled=false;
  }
 }
 if(command_type==17){background_control=v;background_enabled=v&1;if(!v)screen.clear();}
 if(command_type==19){
  if(tx_index<4)address=(address<<8)|v;
  else {assert(address+tx_index-4==0x200000+screen.size());screen.push_back(v);}
 }
 ++tx_index;
 if(!--tx_left&&command_type==19){nanoblast_background_reply(upload_fault_once?1:0);upload_fault_once=false;}
}
std::vector<BYTE> ramdisk(64*1024*1024);
extern "C" DSTATUS disk_initialize(BYTE){return 0;}
extern "C" DSTATUS disk_status(BYTE){return 0;}
extern "C" DRESULT disk_read(BYTE,BYTE*out,LBA_t sector,UINT count){disk_reads+=count;if(disk_fault)return RES_ERROR;if((uint64_t(sector)+count)*512>ramdisk.size())return RES_PARERR;std::memcpy(out,ramdisk.data()+uint64_t(sector)*512,count*512);return RES_OK;}
extern "C" DRESULT disk_write(BYTE,const BYTE*in,LBA_t sector,UINT count){disk_writes+=count;if(disk_fault)return RES_ERROR;if((uint64_t(sector)+count)*512>ramdisk.size())return RES_PARERR;std::memcpy(ramdisk.data()+uint64_t(sector)*512,in,count*512);return RES_OK;}
extern "C" DRESULT disk_ioctl(BYTE,BYTE cmd,void*out){switch(cmd){case CTRL_SYNC:return RES_OK;case GET_SECTOR_COUNT:*static_cast<LBA_t*>(out)=ramdisk.size()/512;return RES_OK;case GET_SECTOR_SIZE:*static_cast<WORD*>(out)=512;return RES_OK;case GET_BLOCK_SIZE:*static_cast<DWORD*>(out)=1;return RES_OK;default:return RES_PARERR;}}
bool loading_label=false;int cursor_col=0,cursor_row=0;
char text_screen[28][32];
void overlay_clear(){std::memset(text_screen,' ',sizeof text_screen);}void overlay_status(const char*,...){}
void overlay_cursor(int x,int y){cursor_col=x;cursor_row=y;}
void overlay_printf(const char *fmt,...){
 char text[128];va_list args;va_start(args,fmt);std::vsnprintf(text,sizeof text,fmt,args);va_end(args);
 if(cursor_col>=0&&cursor_col<32&&cursor_row>=0&&cursor_row<28)
  std::memcpy(text_screen[cursor_row]+cursor_col,text,std::min<std::size_t>(32-cursor_col,std::strlen(text)));
 if(std::strcmp(fmt,"LOADING...")==0){assert(cursor_col==11&&cursor_row==27);loading_label=true;}
}

std::vector<BYTE> load(const char*path){std::ifstream in(path,std::ios::binary);assert(in);return {std::istreambuf_iterator<char>(in),{}};}
void save(const char*path,const std::vector<BYTE>&data){FIL f;UINT n;assert(f_open(&f,path,FA_WRITE|FA_CREATE_NEW)==FR_OK);assert(f_write(&f,data.data(),data.size(),&n)==FR_OK&&n==data.size());assert(f_close(&f)==FR_OK);}
std::vector<BYTE> read(const char*path){FIL f;assert(f_open(&f,path,FA_READ)==FR_OK);std::vector<BYTE> result(f_size(&f));UINT n;assert(f_read(&f,result.data(),result.size(),&n)==FR_OK&&n==result.size());assert(f_close(&f)==FR_OK);return result;}
int main(int argc,char**argv){
 assert(argc==3);auto original=load(argv[1]),compressed=load(argv[2]);
 unsigned embedded_length=0;auto *embedded=nanoblast_real_builtin_background(embedded_length);
 assert(std::vector<BYTE>(embedded,embedded+embedded_length)==compressed);
 // No mounted filesystem and no working media are needed.
 disk_fault=true;nanoblast_load_background();
 assert(!disk_reads&&!disk_writes&&background_enabled);
 assert(std::string(nanoblast_background_status()).find("loaded flash")!=std::string::npos);
 assert(screen==std::vector<BYTE>(original.begin()+800,original.end()));
 disk_fault=false;
 for(unsigned format:{FM_FAT32,FM_EXFAT}){
  std::fill(ramdisk.begin(),ramdisk.end(),0);
  BYTE work[4096];MKFS_PARM options={};options.fmt=format|FM_SFD;options.au_size=512;
  assert(f_mkfs("sd:",&options,work,sizeof work)==FR_OK);
  assert(f_mount(&fs,"sd:",1)==FR_OK);
  // SD artwork is deliberately wrong. Neither it nor unrelated files may
  // be opened, replaced or consulted on success OR failure.
  const std::vector<BYTE> wrong={1,2,3};
  save("sd:background.nbbg",wrong);save("sd:background.nbcz",wrong);
  assert(f_mkdir("sd:My Games")==FR_OK);
  std::vector<BYTE> game(4097,0x6e);save("sd:My Games/keep.nes",game);
  const auto unchanged_disk=ramdisk;
  auto check_no_sd=[&](unsigned fault,bool transport_error){
   flash_fault=fault;upload_fault_once=transport_error;
   std::memset(text_screen,'X',sizeof text_screen);selection_enabled=panel_enabled=true;
   unsigned reads_before=disk_reads,writes_before=disk_writes;
   nanoblast_load_background();
   assert(disk_reads==reads_before&&disk_writes==writes_before&&ramdisk==unchanged_disk);
   assert(!selection_enabled&&!panel_enabled&&loading_label);
   assert(std::string(text_screen[15],32)==std::string(32,' '));
   assert(!*nanoblast_background_fallback_status()&&!*nanoblast_background_fallback_sd());
   if(!fault&&!transport_error){
    assert(background_enabled&&std::string(nanoblast_background_status()).find("loaded flash")!=std::string::npos);
    assert(screen==std::vector<BYTE>(original.begin()+800,original.end()));
    assert(std::string(text_screen[14],32)=="  [==========================]  ");
   }else{
    assert(!background_enabled);
    assert(std::string(nanoblast_background_status()).find("loaded")==std::string::npos);
   }
  };
  check_no_sd(0,false);
  for(unsigned fault:{1u,2u,3u})check_no_sd(fault,false);
  check_no_sd(0,true); // A rejected upload must not trigger another source.
  assert(std::string(nanoblast_background_status())=="artwork upload failed");
  check_no_sd(0,false); // The next normal request can recover from flash.
  unsigned oled_packets=pixel_packets;
  nanoblast_background_oled(true);assert(background_control==2&&!background_enabled);
  assert(std::string(nanoblast_background_status())=="off (OLED Mode)");
  flash_fault=3;nanoblast_load_background();
  assert(background_control==2&&pixel_packets==oled_packets); // A new core needs no artwork upload.
  flash_fault=0;nanoblast_background_oled(false);
  assert(background_control==1&&background_enabled&&pixel_packets>oled_packets);
  assert(screen==std::vector<BYTE>(original.begin()+800,original.end()));
  assert(read("sd:My Games/keep.nes")==game);
  assert(read("sd:background.nbbg")==wrong&&read("sd:background.nbcz")==wrong);
  assert(f_mount(nullptr,"sd:",0)==FR_OK);
 }
 return 0;
}
