#include "usb_rom_fatfs.h"
#include "crc32.h"
#include <cstdio>
#include <cstring>
namespace nanoblast::usbrom {
bool FatFiles::list(const char*path,uint32_t index,Entry&e,bool&end){
 end=false;if(!*path){const char*cores[]={"nes","sms","gb","snes"};if(index>=4){end=true;return true;}std::strcpy(e.name,cores[index]);e.directory=true;return true;}
 char full[MaxPath+5];std::snprintf(full,sizeof full,"sd:%s",path);DIR dir;auto result=f_opendir(&dir,full);
 if(result==FR_NO_PATH){end=true;return true;}if(result!=FR_OK)return false;
 FILINFO info;uint32_t seen=0;bool ok=true;
 for(;;){if(f_readdir(&dir,&info)!=FR_OK){ok=false;break;}if(!info.fname[0]){end=true;break;}
  char candidate[MaxPath+1];int n=std::snprintf(candidate,sizeof candidate,"%s/%s",path,info.fname);
  if(n<0||unsigned(n)>=sizeof candidate||!valid_path(candidate,!(info.fattrib&AM_DIR)))continue;
  if(seen++!=index)continue;std::strncpy(e.name,info.fname,MaxPath);e.directory=info.fattrib&AM_DIR;e.size=info.fsize;break;
 }return f_closedir(&dir)==FR_OK&&ok;
}
bool FatFiles::begin(const char*path,uint32_t){
 abort();std::snprintf(dest_,sizeof dest_,"sd:%s",path);std::snprintf(temp_,sizeof temp_,"%s.nbpart",dest_);
 FILINFO info;auto existing=f_stat(dest_,&info);if(existing!=FR_NO_FILE&&existing!=FR_NO_PATH)return false;
 // Only core directories may be created; nested destination folders must exist.
 char core[10];const char*slash=std::strchr(path,'/');std::snprintf(core,sizeof core,"sd:%.*s",int(slash-path),path);
 auto mkdir=f_mkdir(core);if(mkdir!=FR_OK&&mkdir!=FR_EXIST)return false;
 if(f_open(&file_,temp_,FA_WRITE|FA_CREATE_NEW)!=FR_OK)return false;
 open_=owned_=true;return true;
}
bool FatFiles::append(const uint8_t*d,unsigned n){UINT written=0;return open_&&f_write(&file_,d,n,&written)==FR_OK&&written==n;}
bool FatFiles::commit(uint32_t size,uint32_t wanted){
 if(!open_||f_sync(&file_)!=FR_OK)return false;
 auto closed=f_close(&file_);open_=false;if(closed!=FR_OK)return false;
 if(f_open(&file_,temp_,FA_READ)!=FR_OK)return false;open_=true;
 uint8_t block[512];uint32_t crc=0xffffffff,total=0;UINT n;
 do{if(f_read(&file_,block,sizeof block,&n)!=FR_OK)return false;crc=crc32_update(crc,block,n);total+=n;}while(n);
 closed=f_close(&file_);open_=false;if(closed!=FR_OK||total!=size||(crc^0xffffffff)!=wanted)return false;
 FILINFO info;if(f_stat(dest_,&info)!=FR_NO_FILE||f_rename(temp_,dest_)!=FR_OK)return false;
 owned_=false;return true;
}
void FatFiles::abort(){if(open_){f_close(&file_);open_=false;}if(owned_){f_unlink(temp_);owned_=false;}}
}
