#include "../storage/crc32.h"
#include "core_assets.h"
#include "../storage/core_image.h"
#ifdef NANOBLAST_CORE_ASSETS_HOST_TEST
#include "../tests/core_assets_platform.h"
#else
#include "utils.h"
#include "overlay.h"
extern "C" {
#include "bflb_flash.h"
}
#endif
#include <cstring>
#include <cstdio>
#include <string>
#include <algorithm>
extern const char *drv;
namespace {
#include "gb_test_rom.inc"
uint32_t word(const uint8_t*p){return uint32_t(p[0])|uint32_t(p[1])<<8|uint32_t(p[2])<<16|uint32_t(p[3])<<24;}
uint32_t crc(uint32_t c,const uint8_t*p,unsigned n){return nanoblast::crc32_update(c,p,n);}
bool file_matches(const char*name,uint32_t length,uint32_t checksum){
 FIL file;if(f_open(&file,name,FA_READ)!=FR_OK)return false;
 bool ok=f_size(&file)==length;uint8_t buffer[1024];uint32_t check=0xffffffffu;
 for(uint32_t off=0;ok&&off<length;){UINT got=0;unsigned n=length-off>sizeof buffer?sizeof buffer:length-off;
  ok=f_read(&file,buffer,n,&got)==FR_OK&&got==n;if(ok)check=crc(check,buffer,n);off+=n;
 }
 ok=f_close(&file)==FR_OK&&ok;return ok&&(check^0xffffffffu)==checksum;
}
}
void nanoblast_prepare_cores(){}
const char *nanoblast_core_path(unsigned){return nullptr;}
const char *nanoblast_core_setup_status(){return "Compressed core assets";}
bool nanoblast_core_asset_available(unsigned id){
 nanoblast::CoreImageSource source;
 auto read=[](uint32_t a,uint8_t*p,unsigned n){return bflb_flash_read(a,p,n)==0;};
 return nanoblast::builtin_core_source(read,id,source);
}
bool nanoblast_prepare_core(unsigned id){return nanoblast_core_asset_available(id);}

bool nanoblast_import_game(){
 // This sector and its 128KiB payload fit wholly after the NES core asset.
 // They never overlap the reserved 0x200000 sector or the staging cache.
 constexpr uint32_t slot=0x1df000,data=slot+4096,capacity=0x20000;
 uint8_t header[112],buffer[1024];
 if(bflb_flash_get_size()<0x400000||bflb_flash_read(slot,header,sizeof header)!=0)return false;
 bool blank=true;for(uint8_t b:header)blank=blank&&b==255;
 if(blank)return true;
 if(std::memcmp(header,"NBFILE01",8))return false;
 const uint32_t length=word(header+8),checksum=word(header+12);
 if(!length||length>capacity)return false;
 const char*path=reinterpret_cast<const char*>(header+16);
 if(!std::memchr(path,0,96)||std::strncmp(path,"sms/",4))return false;
 const std::string relative(path);
 if(relative.size()<=8||relative.substr(relative.size()-4)!=".sms")return false;
 for(unsigned i=4;i<relative.size();i++)
  if(static_cast<unsigned char>(relative[i])<32||relative[i]>126||relative[i]=='/'||relative[i]=='\\'||relative[i]==':')return false;
 uint32_t check=0xffffffffu;
 for(uint32_t off=0;off<length;){unsigned n=std::min<unsigned>(sizeof buffer,length-off);
  if(bflb_flash_read(data+off,buffer,n)!=0)return false;
  check=crc(check,buffer,n);off+=n;
 }
 if((check^0xffffffffu)!=checksum)return false;
 const std::string name=std::string(drv)+relative;
 const std::string directory=std::string(drv)+"sms";
 auto result=f_mkdir(directory.c_str());if(result!=FR_OK&&result!=FR_EXIST)return false;
 FILINFO info;result=f_stat(name.c_str(),&info);
 if(result==FR_OK)return file_matches(name.c_str(),length,checksum);
 if(result!=FR_NO_FILE)return false;
 FIL file;std::string temp;bool opened=false;
 for(unsigned suffix=0;suffix<10;suffix++){
  temp=name+"."+std::to_string(suffix)+".tmp";
  result=f_open(&file,temp.c_str(),FA_CREATE_NEW|FA_WRITE);
  if(result==FR_OK){opened=true;break;}if(result!=FR_EXIST)return false;
 }
 if(!opened)return false;
 overlay_clear();overlay_status("Copying game to sms...");
 bool ok=true;
 for(uint32_t off=0;ok&&off<length;){unsigned n=std::min<unsigned>(sizeof buffer,length-off);UINT got=0;
  ok=bflb_flash_read(data+off,buffer,n)==0&&f_write(&file,buffer,n,&got)==FR_OK&&got==n;
  off+=n;
 }
 ok=f_sync(&file)==FR_OK&&ok;ok=f_close(&file)==FR_OK&&ok;
 if(ok)ok=file_matches(temp.c_str(),length,checksum);
 if(ok)ok=f_rename(temp.c_str(),name.c_str())==FR_OK;
 if(!ok)f_unlink(temp.c_str());
 return ok;
}

bool nanoblast_prepare_gb_game(){
 const std::string directory=std::string(drv)+"gb",path=directory+"/NANOBLAST DMG Test.gb";
 FILINFO info;FRESULT result=f_stat(path.c_str(),&info);
 if(result==FR_OK)return true; // Never replace an existing file or directory.
 if(result!=FR_NO_FILE&&result!=FR_NO_PATH)return false;
 result=f_mkdir(directory.c_str());if(result!=FR_OK&&result!=FR_EXIST)return false;
 FIL file;if(f_open(&file,path.c_str(),FA_CREATE_NEW|FA_WRITE)!=FR_OK)return false;
 uint8_t buffer[512];bool ok=true;
 for(unsigned off=0;ok&&off<32768;off+=sizeof buffer){
  std::memset(buffer,0,sizeof buffer);
  if(off<sizeof gb_test_prefix)std::memcpy(buffer,gb_test_prefix+off,std::min(unsigned(sizeof buffer),unsigned(sizeof gb_test_prefix)-off));
  UINT got=0;ok=f_write(&file,buffer,sizeof buffer,&got)==FR_OK&&got==sizeof buffer;
 }
 ok=f_sync(&file)==FR_OK&&ok;ok=f_close(&file)==FR_OK&&ok;
 if(!ok)f_unlink(path.c_str());return ok;
}
