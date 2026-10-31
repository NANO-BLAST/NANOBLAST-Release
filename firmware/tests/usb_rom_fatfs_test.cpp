#include "../storage/usb_rom_fatfs.h"
#include "../storage/crc32.h"
extern "C" {
#include "diskio.h"
}
#include <cassert>
#include <cstring>
#include <vector>
using namespace nanoblast::usbrom;
static std::vector<BYTE> disk(64*1024*1024);
extern "C" DSTATUS disk_initialize(BYTE){return 0;}
extern "C" DSTATUS disk_status(BYTE){return 0;}
extern "C" DRESULT disk_read(BYTE,BYTE*b,LBA_t s,UINT n){if((s+n)*512>disk.size())return RES_ERROR;std::memcpy(b,disk.data()+s*512,n*512);return RES_OK;}
extern "C" DRESULT disk_write(BYTE,const BYTE*b,LBA_t s,UINT n){if((s+n)*512>disk.size())return RES_ERROR;std::memcpy(disk.data()+s*512,b,n*512);return RES_OK;}
extern "C" DRESULT disk_ioctl(BYTE,BYTE cmd,void*b){if(cmd==CTRL_SYNC)return RES_OK;if(cmd==GET_SECTOR_COUNT){*static_cast<LBA_t*>(b)=disk.size()/512;return RES_OK;}if(cmd==GET_SECTOR_SIZE){*static_cast<WORD*>(b)=512;return RES_OK;}if(cmd==GET_BLOCK_SIZE){*static_cast<DWORD*>(b)=1;return RES_OK;}return RES_PARERR;}
int main(){
 BYTE work[4096];MKFS_PARM opt={FM_FAT32|FM_SFD,1,0,0,0};assert(f_mkfs("sd:",&opt,work,sizeof work)==FR_OK);FATFS fs;assert(f_mount(&fs,"sd:",1)==FR_OK);
 FatFiles files;const uint8_t data[]={1,2,3,4};auto crc=nanoblast::crc32_update(0xffffffff,data,4)^0xffffffff;
 assert(files.begin("nes/game.nes",4));assert(files.append(data,4));assert(files.commit(4,crc));files.abort();
 FILINFO info;assert(f_stat("sd:nes/game.nes",&info)==FR_OK&&info.fsize==4);assert(f_stat("sd:nes/game.nes.nbpart",&info)==FR_NO_FILE);
 assert(!files.begin("nes/game.nes",4));assert(f_stat("sd:nes/game.nes",&info)==FR_OK);
 assert(files.begin("nes/failed.nes",4));assert(files.append(data,4));assert(!files.commit(4,crc^1));files.abort();assert(f_stat("sd:nes/failed.nes",&info)==FR_NO_FILE);assert(f_stat("sd:nes/failed.nes.nbpart",&info)==FR_NO_FILE);
 assert(files.begin("gb/disconnected.gb",4));assert(files.append(data,4));files.abort();assert(f_stat("sd:gb/disconnected.gb",&info)==FR_NO_FILE);
 Entry e;bool end;assert(files.list("nes",0,e,end)&&!end&&!e.directory&&e.size==4&&!std::strcmp(e.name,"game.nes"));
 assert(files.list("nes",1,e,end)&&end);
 assert(f_mkdir("sd:gb/saves")==FR_OK);assert(files.list("gb",0,e,end)&&end);
 const char* exact="sms/X-Men - Mojo World (Brazil).sms";
 assert(valid_path(exact,true));assert(files.begin(exact,4));assert(files.append(data,4));assert(files.commit(4,crc));files.abort();
 assert(f_stat("sd:sms/X-Men - Mojo World (Brazil).sms",&info)==FR_OK&&info.fsize==4);
 assert(files.list("sms",0,e,end)&&!end&&!std::strcmp(e.name,"X-Men - Mojo World (Brazil).sms"));
 puts("PASS actual FatFs: new ROM, readback, rename, existing-file preservation, failed checksum, disconnect cleanup, directory listing, saves hidden");
}
