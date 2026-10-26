#include "../storage/crc32.h"
#include "../storage/core_image.h"
// Direct SPI via the running FPGA; no SRAM erase or JTAG-to-SPI commands.
#include <cstdio>
#include "nano_core_images.h"
static uint32_t nano_word(const uint8_t*p){return uint32_t(p[0])|(uint32_t(p[1])<<8)|(uint32_t(p[2])<<16)|(uint32_t(p[3])<<24);}
static uint32_t nano_crc(uint32_t c,const uint8_t*p,unsigned n){return nanoblast::crc32_update(c,p,n);}
struct NanoDirectIO : nanoblast::BootFlashIO {
 char failure_detail[48]="Core flash failed";
 void failure(nanoblast::BootFlashFailure why,uint32_t value)override{
  const char*labels[]={"Image length","Source read","Source CRC","Erase at","Program at","Verify read","Verify CRC"};
  std::snprintf(failure_detail,sizeof failure_detail,"%s %08lX",labels[unsigned(why)],static_cast<unsigned long>(value));
 }
 uint32_t base;bool mutated=false,closed=false,known_ready=false;
 explicit NanoDirectIO(uint32_t b):base(b){}
 bool source(uint32_t off,uint8_t*p,unsigned n)override{auto read=[](uint32_t a,uint8_t*p,unsigned n){return bflb_flash_read(a,p,n)==0;};return nanoblast::core_image_read(read,base,off,p,n);}
 bool begin(){
  // Every completed operation already acknowledged CS high. Only force it
  // again at first use or after a failed close, rather than before every cmd.
  bool ok=closed||fpga_flash_transfer(true,nullptr,nullptr,0);closed=false;return ok;
 }
 bool finish(){closed=fpga_flash_transfer(true,nullptr,nullptr,0);if(!closed)known_ready=false;return closed;}
 bool transaction(const uint8_t*tx,uint8_t*rx,unsigned n){
  bool ok=begin()&&fpga_flash_transfer(false,tx,rx,n);
  bool ended=finish();if(!ok)known_ready=false;return ok&&ended;
 }
 bool status(uint8_t &s,unsigned command=5){uint8_t tx[2]={uint8_t(command),0xff},rx[2];if(!transaction(tx,rx,2))return false;s=rx[1];return true;}
 bool ready(){uint64_t start=bflb_mtimer_get_time_ms();uint8_t s;known_ready=false;
  do{if(!status(s))return false;if(!(s&1)){known_ready=true;return true;}delay(1);}while(bflb_mtimer_get_time_ms()-start<5000);
  return false;
 }
 bool writable(){uint8_t command=6,s;return (known_ready||ready())&&transaction(&command,nullptr,1)&&status(s)&&!(s&1)&&(s&2);}
 bool read(uint32_t off,uint8_t*p,unsigned n)override{
  if(n>1024||off>0x100000||n>0x100000-off)return false;
  uint8_t cmd[4]={3,uint8_t(off>>16),uint8_t(off>>8),uint8_t(off)};
  bool ok=begin()&&fpga_flash_transfer(false,cmd,nullptr,4)&&fpga_flash_transfer(false,nullptr,p,n);
  bool ended=finish();return ok&&ended;
 }
 bool erase64k(uint32_t off)override{
  if(off%65536||off>=0x100000||!writable())return false;
  uint8_t tx[4]={0xd8,uint8_t(off>>16),uint8_t(off>>8),uint8_t(off)};mutated=true;known_ready=false;return transaction(tx,nullptr,4)&&ready();
 }
 bool page(uint32_t off,const uint8_t*p,unsigned n)override{
  if(!n||n>256||(off&255)+n>256||off>0x100000||n>0x100000-off||!writable())return false;
  uint8_t cmd[4]={2,uint8_t(off>>16),uint8_t(off>>8),uint8_t(off)};
  known_ready=false;
  bool ok=begin()&&fpga_flash_transfer(false,cmd,nullptr,4)&&fpga_flash_transfer(false,p,nullptr,n);
  bool ended=finish();return ok&&ended&&ready();
 }
 void progress(unsigned offset,unsigned length,bool verifying)override{
  char line[30];std::snprintf(line,sizeof line,"%s core: %3u%%",verifying?"Verifying":"Saving",offset*100/length);overlay_cursor(2,22);overlay_printf("%-28s",line);
 }
};
// Read-only, cached full-image fingerprint. Never issues WREN, erase or program.
static bool nano_boot_diag_valid=false;
static char nano_boot_diag[48]="Boot flash: not checked";
const char *fpga_boot_flash_diagnostic(){
 if(nano_boot_diag_valid)return nano_boot_diag;
 nano_boot_diag_valid=true;
 std::snprintf(nano_boot_diag,sizeof nano_boot_diag,"Boot flash: read failed");
 if(!fpga_flash_available())return nano_boot_diag;
 NanoDirectIO io(0);uint8_t tx[4]={0x9f,0xff,0xff,0xff},rx[4];
 if(!io.transaction(tx,rx,4)||rx[1]!=0xef||rx[2]!=0x40||rx[3]!=0x17)return nano_boot_diag;
 uint8_t b[1024];uint32_t crc=~0u;
 for(uint32_t off=0;off<907418;){
  unsigned n=907418-off>sizeof b?sizeof b:907418-off;
  if(!io.read(off,b,n))return nano_boot_diag;
  crc=nano_crc(crc,b,n);off+=n;
 }
 crc^=~0u;
 const unsigned ids[4]={1,5,7,2};const char *names[4]={"NES","SMS/GG","GB/GBC","SNES"};
 for(unsigned i=0;i<4;i++){
  nanoblast::CoreImageSource source;
  auto read=[](uint32_t a,uint8_t*p,unsigned n){return bflb_flash_read(a,p,n)==0;};
  if(nanoblast::builtin_core_source(read,ids[i],source)&&source.checksum==crc){
   std::snprintf(nano_boot_diag,sizeof nano_boot_diag,"Boot flash: %s %08lX",names[i],static_cast<unsigned long>(crc));return nano_boot_diag;
  }
 }
 for(const auto &old:NanoPriorBootImages)if(crc==old.crc){
  std::snprintf(nano_boot_diag,sizeof nano_boot_diag,"Boot flash: %s %08lX",old.core==1?"NES":old.core==5?"SMS":old.core==7?"GB":"SNES",static_cast<unsigned long>(crc));return nano_boot_diag;
 }
 std::snprintf(nano_boot_diag,sizeof nano_boot_diag,"Boot flash: unknown %08lX",static_cast<unsigned long>(crc));return nano_boot_diag;
}
static bool nano_boot_readable(NanoDirectIO&io){
 uint8_t expected[256];bool matches[4]={};
 nanoblast::CoreImageSource sources[4];const unsigned ids[4]={1,5,7,2};
 auto read=[](uint32_t a,uint8_t*p,unsigned n){return bflb_flash_read(a,p,n)==0;};
 for(unsigned i=0;i<4;i++)matches[i]=nanoblast::builtin_core_source(read,ids[i],sources[i]);
 bool legacy=true;bool prior[sizeof NanoPriorBootImages/sizeof NanoPriorBootImages[0]];
 for(bool &match:prior)match=true;
 const uint32_t offsets[3]={0,0x10000,0x80000};
 // Read all samples per core together to reuse each decoded 64-KiB block.
 uint8_t samples[3][256];
 for(unsigned block=0;block<3;block++){
  if(!io.read(offsets[block],samples[block],sizeof expected))return false;
  const uint32_t sample=nano_crc(~0u,samples[block],sizeof expected)^~0u;
  legacy=legacy&&(sample==NanoLegacySampleCRC[block]);
  for(unsigned i=0;i<sizeof prior/sizeof prior[0];i++)prior[i]=prior[i]&&(sample==NanoPriorBootImages[i].sample[block]);
 }
 for(unsigned i=0;i<4;i++)for(unsigned block=0;block<3&&matches[i];block++)
  matches[i]=nanoblast::core_image_read(read,sources[i].base,offsets[block],expected,sizeof expected)&&!memcmp(samples[block],expected,sizeof expected);
 for(bool match:prior)if(match)return true;
 return matches[0]||matches[1]||matches[2]||matches[3]||legacy;
}
static char nano_flash_detail[48];
static const char *nano_persist_error="Core flash failed";
static bool nano_persist_source(uint32_t base,uint32_t checksum,bool verify){
 nano_boot_diag_valid=false;
 nano_persist_error="FPGA flash bridge unavailable";
 if(!fpga_flash_available())return false;
 NanoDirectIO io(base);
 uint8_t tx[4]={0x9f,0xff,0xff,0xff},rx[4]={0},s=0xff,s2=0xff;
 bool ok=io.transaction(tx,rx,4);uint32_t identity=(uint32_t(rx[1])<<16)|(uint32_t(rx[2])<<8)|rx[3];
 nanoblast_switch_trace(nanoblast::SwitchStep::FlashIdentity,0,identity);
 ok=ok&&io.ready()&&io.status(s)&&io.status(s2,0x35);
 nanoblast_switch_trace(nanoblast::SwitchStep::FlashStatus,0,(unsigned(s2)<<8)|s);
 // The physical Nano was previously identified as Winbond W25Q64 EF4017.
 // Refuse all-FF responses, BP/TB/SEC protection and complement protection.
 ok=ok&&identity==0xef4017&&!(s&0x7c)&&!(s2&0x40);
 std::snprintf(nano_flash_detail,sizeof nano_flash_detail,"Flash %06lX SR %02X/%02X",static_cast<unsigned long>(identity),unsigned(s),unsigned(s2));nano_persist_error=nano_flash_detail;
 if(ok){nanoblast_switch_trace(nanoblast::SwitchStep::BootRead);ok=nano_boot_readable(io);if(!ok)nano_persist_error="FPGA flash readback mismatch";}
 if(ok){
  nano_persist_error="FPGA flash verify failed";
  nanoblast_switch_trace(nanoblast::SwitchStep::WriteBoot);
  ok=nanoblast::persist_core(io,907418,checksum,verify);
  if(!ok){std::snprintf(nano_flash_detail,sizeof nano_flash_detail,"%s",io.failure_detail);nano_persist_error=nano_flash_detail;}
 }
 if(!ok)nanoblast_switch_trace(nanoblast::SwitchStep::Failed,0,(identity<<8)|s);
 // No automatic replacement image is written on failure. Keep the live FPGA
 // configured; reload only after the requested image has been saved successfully.
 if(ok){nanoblast_switch_trace(nanoblast::SwitchStep::ReloadBoot,0,1);fpga_reload_boot_core();}
 if(ok)nanoblast_switch_trace(nanoblast::SwitchStep::SaveDone);
 return ok;
}
bool fpga_persist_core(bool verify){
 uint8_t header[16];nano_persist_error="Core cache invalid";
 if(bflb_flash_read(nanoblast::CacheStart,header,16)||memcmp(header,"NBCACHE1",8)||nano_word(header+8)!=907418)return false;
 return nano_persist_source(nanoblast::CacheData,nano_word(header+12),verify);
}
bool fpga_persist_asset(unsigned id,bool verify){
 nanoblast::CoreImageSource source;nano_persist_error="Invalid built-in core asset";
 auto read=[](uint32_t a,uint8_t*p,unsigned n){return bflb_flash_read(a,p,n)==0;};
 if(!nanoblast::builtin_core_source(read,id,source))return false;
 return nano_persist_source(source.base,source.checksum,verify);
}
const char *fpga_persist_diagnostic(){return nano_persist_error;}
