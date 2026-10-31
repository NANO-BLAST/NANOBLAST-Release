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
static unsigned writes=0,reads=0;
static std::vector<BYTE> disk(64*1024*1024);
extern "C" DSTATUS disk_initialize(BYTE){return 0;}
extern "C" DSTATUS disk_status(BYTE){return 0;}
extern "C" DRESULT disk_read(BYTE,BYTE*b,LBA_t s,UINT n){reads+=n;if((s+n)*512>disk.size())return RES_ERROR;std::memcpy(b,disk.data()+s*512,n*512);return RES_OK;}
extern "C" DRESULT disk_write(BYTE,const BYTE*b,LBA_t s,UINT n){++writes;if((s+n)*512>disk.size())return RES_ERROR;std::memcpy(disk.data()+s*512,b,n*512);return RES_OK;}
extern "C" DRESULT disk_ioctl(BYTE,BYTE cmd,void*b){if(cmd==CTRL_SYNC)return RES_OK;if(cmd==GET_SECTOR_COUNT){*static_cast<LBA_t*>(b)=disk.size()/512;return RES_OK;}if(cmd==GET_SECTOR_SIZE){*static_cast<WORD*>(b)=512;return RES_OK;}if(cmd==GET_BLOCK_SIZE){*static_cast<DWORD*>(b)=1;return RES_OK;}return RES_PARERR;}

int loadnes(const char*);int loadsms(const char*);int loadgb(const char*);int loadsnes(const char*);
uint8_t fbuf[1024];bool core_running=false;
std::vector<uint8_t> sent;unsigned core=0,first_read_count=0,start_reads=0;std::vector<int> states;uint64_t ticks=0;uint32_t configuration=4;std::string saved_name;
void overlay_message(const char*message,int){std::fprintf(stderr,"overlay: %s\n",message);}void overlay_status(const char*,...){}void overlay(int){}
void set_loading_state(int value){states.push_back(value);}
void send_fbuf_data(unsigned n){if(sent.empty())first_read_count=reads-start_reads;sent.insert(sent.end(),fbuf,fbuf+n);}
int get_fpga_load_status(){return 1;}
uint64_t bflb_mtimer_get_time_ms(){return ticks++;}void delay(unsigned n){ticks+=n;}
uint32_t get_core_config(){return configuration;}void set_core_config(uint32_t n){configuration=n;}
bool gb_save_flush(){return true;}void gb_save_forget(){}const char*gb_save_status(){return "save test";}
bool gb_save_restore(const char*name,uint32_t,unsigned,unsigned,unsigned){saved_name=name;return true;}
bool get_fpga_debug(uint8_t index,uint32_t*out){
 unsigned header=core==7?8:core==2?64:0;
 uint32_t crc=sent.size()>=header?(nanoblast::crc32_update(~0u,sent.data()+header,sent.size()-header)^~0u):0;
 if(core==5){*out=0x53474731;return true;}
 if(core==7){*out=index==0?0x47423031:index==9?0x43474231:index==13?0x52544331:crc;return true;}
 if(core==2){*out=index==0?0x534e3031:index==1?sent.size()-64:index==2||index==3?crc:2;return true;}
 return false;
}
int main(int argc,char**argv){
 assert(argc==5||argc==6);core=std::stoul(argv[3]);std::string basename=argv[4];
 BYTE work[4096];MKFS_PARM opt={FM_FAT32|FM_SFD,1,0,0,0};assert(f_mkfs("sd:",&opt,work,sizeof work)==FR_OK);FATFS fs;assert(f_mount(&fs,"sd:",1)==FR_OK);
 std::ifstream input(argv[1],std::ios::binary),raw_input(argv[2],std::ios::binary);
 std::vector<uint8_t> zip((std::istreambuf_iterator<char>(input)),{}),raw((std::istreambuf_iterator<char>(raw_input)),{});
 auto put=[&](const std::string&path,const std::vector<uint8_t>&data){FIL f;UINT n=0;assert(f_open(&f,path.c_str(),FA_WRITE|FA_CREATE_NEW)==FR_OK);assert(f_write(&f,data.data(),data.size(),&n)==FR_OK&&n==data.size());assert(f_close(&f)==FR_OK);};
 const std::string raw_path="sd:/"+basename;put(raw_path,raw);put("sd:/Archive.zip",zip);const unsigned before=writes;
 auto loader=core==1?loadnes:core==5?loadsms:core==7?loadgb:loadsnes;
 assert(loader(raw_path.c_str())==FR_OK&&core_running);auto reference=sent;auto reference_states=states;auto reference_config=configuration;
 sent.clear();states.clear();core_running=false;configuration=4;saved_name.clear();start_reads=reads;
 int result=loader("sd:/Archive.zip");
 if(argc==6){assert(result!=FR_OK&&!core_running&&sent.empty()&&writes==before);std::printf("PASS malformed ZIP rejected by core %u before ROM output\n",core);return 0;}
 if(result!=FR_OK||!core_running||sent!=reference||states!=reference_states||configuration!=reference_config){std::fprintf(stderr,"core=%u result=%d running=%d sent=%zu expected=%zu config=%u expected_config=%u states=%zu expected_states=%zu\n",core,result,core_running,sent.size(),reference.size(),configuration,reference_config,states.size(),reference_states.size());for(unsigned i=0;i<sent.size()&&i<reference.size();++i)if(sent[i]!=reference[i]){std::fprintf(stderr,"first difference %u: zip=%02x raw=%02x\n",i,sent[i],reference[i]);break;}std::abort();}
 if(core==7)assert(saved_name==basename);
 if(core!=2)assert(first_read_count<32); // No whole-ROM checksum pre-scan before the first core bytes.
 assert(writes==before);FILINFO info;assert(f_stat("sd:/.nbzip",&info)==FR_NO_FILE);
 std::printf("PASS direct core %u: %s, exact raw/ZIP output, no SD writes\n",core,basename.c_str());return 0;
}
