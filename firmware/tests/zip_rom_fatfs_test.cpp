#include "../storage/usb_rom_fatfs.h"
#include "../storage/crc32.h"
extern "C" {
#include "diskio.h"
}
#include <cassert>
#include <cstring>
#include <vector>
#include <fstream>
#include <iterator>
#include "../storage/zip_rom_fatfs.h"
using namespace nanoblast::usbrom;
static unsigned writes=0;
static std::vector<BYTE> disk(64*1024*1024);
extern "C" DSTATUS disk_initialize(BYTE){return 0;}
extern "C" DSTATUS disk_status(BYTE){return 0;}
extern "C" DRESULT disk_read(BYTE,BYTE*b,LBA_t s,UINT n){if((s+n)*512>disk.size())return RES_ERROR;std::memcpy(b,disk.data()+s*512,n*512);return RES_OK;}
extern "C" DRESULT disk_write(BYTE,const BYTE*b,LBA_t s,UINT n){++writes;if((s+n)*512>disk.size())return RES_ERROR;std::memcpy(disk.data()+s*512,b,n*512);return RES_OK;}
extern "C" DRESULT disk_ioctl(BYTE,BYTE cmd,void*b){if(cmd==CTRL_SYNC)return RES_OK;if(cmd==GET_SECTOR_COUNT){*static_cast<LBA_t*>(b)=disk.size()/512;return RES_OK;}if(cmd==GET_SECTOR_SIZE){*static_cast<WORD*>(b)=512;return RES_OK;}if(cmd==GET_BLOCK_SIZE){*static_cast<DWORD*>(b)=1;return RES_OK;}return RES_PARERR;}
int main(int argc,char**argv){
 assert(argc==3);BYTE work[4096];MKFS_PARM opt={FM_FAT32|FM_SFD,1,0,0,0};assert(f_mkfs("sd:",&opt,work,sizeof work)==FR_OK);FATFS fs;assert(f_mount(&fs,"sd:",1)==FR_OK);assert(f_mkdir("sd:/sms")==FR_OK);
 std::ifstream input(argv[1],std::ios::binary),expected_input(argv[2],std::ios::binary);
 std::vector<uint8_t> zip((std::istreambuf_iterator<char>(input)),{}),expected((std::istreambuf_iterator<char>(expected_input)),{});
 auto put=[&](const char*path,const std::vector<uint8_t>&data){FIL f;UINT n=0;assert(f_open(&f,path,FA_WRITE|FA_CREATE_NEW)==FR_OK);assert(f_write(&f,data.data(),data.size(),&n)==FR_OK&&n==data.size());assert(f_close(&f)==FR_OK);};
 put("sd:/sms/Game.zip",zip);put("sd:/sms/raw.sms",expected);
 unsigned before=writes;RomFile file;assert(file.open("sd:/sms/Game.zip",5)==FR_OK);assert(file.size()==expected.size()&&std::string(file.name())=="X-Men - Mojo World (Brazil).sms");
 uint8_t buffer[1024];unsigned got=0;
 for(unsigned position:{0u,336u,32704u,65472u,512u,0u}){assert(file.seek(position)==FR_OK);assert(file.read(buffer,64,&got)==FR_OK&&got==64);assert(!std::memcmp(buffer,expected.data()+position,64));}
 assert(file.seek(0)==FR_OK);unsigned total=0;
 while(total<expected.size()){unsigned n=std::min<unsigned>(sizeof buffer,expected.size()-total);assert(file.read(buffer,n,&got)==FR_OK&&got==n);assert(!std::memcmp(buffer,expected.data()+total,n));total+=n;}
 assert(file.read(buffer,sizeof buffer,&got)==FR_OK&&!got);assert(file.close()==FR_OK&&writes==before);
 FILINFO info;assert(f_stat("sd:/sms/.nbzip",&info)==FR_NO_FILE);
 assert(file.open("sd:/sms/raw.sms",5)==FR_OK);assert(file.seek(128)==FR_OK);assert(file.read(buffer,64,&got)==FR_OK&&got==64&&!std::memcmp(buffer,expected.data()+128,64));assert(file.close()==FR_OK&&writes==before);
 assert(file.open("sd:/sms/Game.zip",1)!=FR_OK);file.close();assert(writes==before);
 // A stale ZIP CRC is deliberately not scanned, per the requested fast path.
 auto bad_crc=zip;auto patch=[&](std::vector<uint8_t>&bytes,unsigned pos){bytes[pos]=0x78;bytes[pos+1]=0x56;bytes[pos+2]=0x34;bytes[pos+3]=0x12;};
 patch(bad_crc,14);for(unsigned i=0;i+46<bad_crc.size();++i)if(!std::memcmp(bad_crc.data()+i,"PK\1\2",4)){patch(bad_crc,i+16);break;}
 put("sd:/sms/NoCrc.zip",bad_crc);before=writes;assert(file.open("sd:/sms/NoCrc.zip",5)==FR_OK);
 for(total=0;total<expected.size();){unsigned n=std::min<unsigned>(sizeof buffer,expected.size()-total);assert(file.read(buffer,n,&got)==FR_OK&&got==n);assert(!std::memcmp(buffer,expected.data()+total,n));total+=n;}
 assert(file.close()==FR_OK&&writes==before);
 // Deflate framing is still checked while streaming, without a CRC pass.
 auto malformed=zip;unsigned data_offset=30u+unsigned(malformed[26])+(unsigned(malformed[27])<<8)+unsigned(malformed[28])+(unsigned(malformed[29])<<8);
 malformed[data_offset]=7;put("sd:/sms/Invalid.zip",malformed);before=writes;
 assert(file.open("sd:/sms/Invalid.zip",5)==FR_OK);assert(file.read(buffer,sizeof buffer,&got)!=FR_OK);assert(file.close()!=FR_OK&&writes==before);
 puts("PASS ZIP direct reader: exact bytes, seeks, raw files, zero SD writes/cache and no ZIP checksum pass");return 0;
}
