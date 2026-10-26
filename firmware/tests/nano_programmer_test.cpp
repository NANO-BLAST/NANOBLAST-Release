#include <cassert>
#include <cstdint>
#include <vector>
#include <cstring>
#include <cstdlib>
#include <cstdio>
#include <fstream>
#include <iterator>
#include "core_stage.h"
#include "core_image.h"
#include "crc32.h"
#include "switch_trace.h"
using UINT=unsigned;constexpr int FR_OK=0,FA_READ=1,JTAG_MAX_CHAIN=8;constexpr uint32_t IDCODE_GW2A_18=0x81b;
struct FIL{unsigned pos=0;};
std::vector<uint8_t>source,flash(0x400000,255),emitted;
void nanoblast_switch_trace(nanoblast::SwitchStep,unsigned,uint32_t){}
uint32_t readStatusReg(){return 0;}
uint32_t nano_configuration_checksum=0;
uint32_t expected_configuration_checksum=0xa723;
unsigned free_bytes=128*1024,chain_len=0,idcodes[8],critical=0,erases=0,restores=0,reads_after_erase=0;
bool erased=false,read_failure=false,jtag_failure=false,flash_failure=false;
unsigned sd_reads=0,cache_writes=0;
int f_open(FIL*f,const char*,unsigned){f->pos=0;return FR_OK;}
uint32_t f_size(FIL*){return source.size();}
int f_close(FIL*){assert(!erased&&!critical);return FR_OK;}
int f_read(FIL*f,void*p,unsigned n,UINT*got){++sd_reads;assert(!erased&&!critical);if(read_failure)return 1;*got=n;assert(f->pos+n<=source.size());std::memcpy(p,source.data()+f->pos,n);f->pos+=n;return FR_OK;}
void overlay_status(const char*,...){}
void overlay_cursor(unsigned,unsigned){}
void overlay_printf(const char*,...){}
uint32_t bflb_flash_get_size(){return flash.size();}uint32_t bflb_flash_get_image_offset(){return 0x40000;}
int bflb_flash_read(unsigned a,void*p,unsigned n){if(erased){++reads_after_erase;if(flash_failure)return 1;}assert(a+n<=flash.size());std::memcpy(p,flash.data()+a,n);return 0;}
int bflb_flash_write(unsigned a,uint8_t*p,unsigned n){++cache_writes;assert(!erased&&a>=0x300000&&a+n<=0x400000);for(unsigned i=0;i<n;i++)flash[a+i]&=p[i];return 0;}
int bflb_flash_erase(unsigned a,unsigned n){++cache_writes;assert(!erased&&a>=0x300000&&a+n<=0x400000);std::memset(flash.data()+a,255,n);return 0;}
void enable_jtag_pins(){}void disable_jtag_pins(){}
unsigned detectChain(unsigned){idcodes[0]=IDCODE_GW2A_18;return 1;}
void taskENTER_CRITICAL(){++critical;}void taskEXIT_CRITICAL(){assert(critical);--critical;}
bool eraseSRAM(){assert(critical==1);erased=true;++erases;return true;}
bool writeSRAM_start(){emitted.clear();return true;}
void jtag_enter_gpio_out_mode(){}void jtag_exit_gpio_out_mode(){}
void jtag_writeTDI_msb_first_gpio_out_mode(uint8_t*p,unsigned n,bool last){assert(erased&&critical==1);emitted.insert(emitted.end(),p,p+n);if(last)assert(emitted.size()==source.size());}
bool writeSRAM_end(){assert(nano_configuration_checksum==expected_configuration_checksum);return !jtag_failure;}
void fpgaReset(){++restores;erased=false;}
// NANO_PROGRAMMER_UNDER_TEST
void reset(unsigned length){expected_configuration_checksum=0xa723;source.resize(length);for(unsigned i=0;i<length;i++)source[i]=(i*13)^(i>>8);if(length>=30){
  const uint8_t footer[]={0x0a,0,0,0,0,0,0xa7,0x23,255,255,255,255,255,255,255,255,8,0,0,0,255,255,255,255,255,255,255,255,255,255};
  memcpy(source.data()+length-30,footer,30);
 }flash.assign(0x400000,255);emitted.clear();erased=false;read_failure=jtag_failure=flash_failure=false;erases=restores=reads_after_erase=0;critical=0;free_bytes=128*1024;sd_reads=cache_writes=0;}
void asset(unsigned id){
 unsigned slot=id==1?0x100000:id==5?0x201000:0x300000;
 std::memcpy(flash.data()+slot,"NBCORE01",8);
 auto put=[&](unsigned off,uint32_t v){for(unsigned i=0;i<4;i++)flash[slot+off+i]=v>>(8*i);};
 put(8,id);put(12,source.size());put(16,nanoblast::crc32_update(~0u,source.data(),source.size())^~0u);put(20,0x4b30324e);
 std::memcpy(flash.data()+slot+4096,source.data(),source.size());
}
int main(int argc,char **argv){
 assert(argc==1||argc==2);
 for(unsigned id:{1u,5u,2u}){
  reset(907418);asset(id);auto original=flash;
  assert(fpga_activate_asset(id)&&sd_reads==0&&cache_writes==0&&emitted==source&&flash==original);
 }
 if(argc==2){
  reset(907418);std::ifstream image(argv[1],std::ios::binary);assert(image.good());
  source=std::vector<uint8_t>(std::istreambuf_iterator<char>(image),{});assert(source.size()==907418);
  expected_configuration_checksum=(uint32_t(source[source.size()-24])<<8)|source[source.size()-23];
  asset(2);auto original=flash;
  assert(fpga_activate_asset(2)&&emitted==source&&flash==original&&cache_writes==0&&sd_reads==0);
  puts("PASS actual released SNES image SRAM stream, configuration footer and immutable third slot");
 }
 reset(907418);asset(2);flash[0x301000+999]^=1;assert(!fpga_activate_asset(2)&&!erases&&sd_reads==0&&cache_writes==0);
 reset(907418);asset(2);flash[0x300008]=5;assert(!fpga_activate_asset(2)&&!erases);
 reset(907418);asset(2);flash[0x301000+source.size()-30]=0;assert(!fpga_activate_asset(2)&&!erases);
 reset(907418);asset(5);flash[0x202000+999]^=1;assert(!fpga_activate_asset(5)&&!erases&&sd_reads==0&&cache_writes==0);
 reset(907418);asset(5);flash[0x201008]=1;assert(!fpga_activate_asset(5)&&!erases);
 reset(907418);asset(5);flash[nanoblast::CacheStart]=0;assert(fpga_activate_asset(5)&&cache_writes==0);
 reset(907418);assert(!fpga_activate_asset(99)&&!erases);
 reset(907418);assert(fpga_stage_core("sd:core.bin")&&!erases&&!critical&&emitted.empty());
 assert(fpga_activate_staged()&&emitted==source&&erases==1);
 reset(907418);assert(fpga_stage_core("sd:core.bin"));flash[nanoblast::CacheData+200]^=1;assert(!fpga_activate_staged()&&!erases);
 reset(907418);assert(nano_program_from_sd("sd:core.bin")&&emitted==source&&reads_after_erase>0&&critical==0&&erases==1&&!restores);
 reset(512);free_bytes=1024*1024;assert(nano_program_from_sd("sd:small.bin")&&emitted==source&&reads_after_erase>0);
 reset(907418);free_bytes=24*1024;assert(nano_program_from_sd("sd:core.bin")&&emitted==source);
 reset(907418);free_bytes=0;assert(nano_program_from_sd("sd:core.bin")&&emitted==source);
 reset(0);assert(!nano_program_from_sd("sd:empty.bin")&&!erases);
 reset(nanoblast::CacheSize);assert(!nano_program_from_sd("sd:oversize.bin")&&!erases);
 reset(907418);flash[nanoblast::CacheData]=0;assert(!nano_program_from_sd("sd:core.bin")&&erases==0&&!restores);
 reset(907418);source[source.size()-30]=0;assert(!nano_program_from_sd("sd:bad-footer.bin")&&!erases);
 reset(907418);read_failure=true;assert(!nano_program_from_sd("sd:core.bin")&&erases==0);
 reset(907418);flash_failure=true;assert(!nano_program_from_sd("sd:core.bin")&&restores==1&&critical==0);
 reset(907418);jtag_failure=true;assert(!nano_program_from_sd("sd:core.bin")&&restores==1&&critical==0);
 return 0;
}
