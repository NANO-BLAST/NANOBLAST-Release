#include <cstdio>
// GW2A direct JTAG-SPI, based on the existing openFPGALoader Gowin protocol.
// No boot flash work occurs until a core has been explicitly selected and its
// SRAM configuration has answered with the requested core ID.
static uint8_t reverse_byte(uint8_t v){v=(v>>4)|(v<<4);v=((v&0xcc)>>2)|((v&0x33)<<2);return ((v&0xaa)>>1)|((v&0x55)<<1);}
static uint32_t nano_word(const uint8_t*p){return uint32_t(p[0])|(uint32_t(p[1])<<8)|(uint32_t(p[2])<<16)|(uint32_t(p[3])<<24);}
static uint32_t nano_crc(uint32_t c,const uint8_t*p,unsigned n){while(n--){c^=*p++;for(unsigned b=0;b<8;b++)c=(c>>1)^((c&1)?0xedb88320u:0);}return c;}
// GW2A TDO returns the SPI stream one JTAG bit late. Capture one extra byte;
// decode only the requested length, with no reads outside the receive buffer.
static bool nano_spi(const uint8_t *tx,uint8_t *rx,unsigned n){
 if(!n||n>260)return false;
 uint8_t data[261],received[261];unsigned count=n+(rx?1:0);
 for(unsigned i=0;i<count;i++)data[i]=i<n?reverse_byte(tx[i]):0;
 send_command(0x16);set_state(EXIT2_DR);shiftDR(data,rx?received:nullptr,count*8);
 if(rx)for(unsigned i=0;i<n;i++)rx[i]=reverse_byte(received[i]>>1)|(received[i+1]&1);
 return true;
}
struct NanoBootIO : nanoblast::BootFlashIO {
 uint32_t source_base;
 explicit NanoBootIO(uint32_t base):source_base(base){}
 bool source(uint32_t off,uint8_t*p,unsigned n)override{return bflb_flash_read(source_base+off,p,n)==0;}
 bool status(uint8_t &value){uint8_t tx[2]={5,0},rx[2];if(!nano_spi(tx,rx,2))return false;value=rx[1];return true;}
 bool ready(){uint64_t start=bflb_mtimer_get_time_ms();uint8_t s;
  do{if(!status(s))return false;if(!(s&1))return true;}while(bflb_mtimer_get_time_ms()-start<5000);
  return false;
 }
 bool writable(){uint8_t command=6,s;return ready()&&nano_spi(&command,nullptr,1)&&status(s)&&(s&2);}
 bool read(uint32_t off,uint8_t*p,unsigned n)override{
  if(n>256||off+n>0x100000)return false;
  uint8_t tx[260]={3,uint8_t(off>>16),uint8_t(off>>8),uint8_t(off)},rx[260];
  if(!nano_spi(tx,rx,n+4))return false;memcpy(p,rx+4,n);return true;
 }
 bool erase64k(uint32_t off)override{
  if(off%65536||off>=0x100000||!writable())return false;
  uint8_t tx[4]={0xd8,uint8_t(off>>16),uint8_t(off>>8),uint8_t(off)};
  return nano_spi(tx,nullptr,4)&&ready();
 }
 bool page(uint32_t off,const uint8_t*p,unsigned n)override{
  if(!n||n>256||(off&255)+n>256||off+n>0x100000||!writable())return false;
  uint8_t tx[260]={2,uint8_t(off>>16),uint8_t(off>>8),uint8_t(off)};memcpy(tx+4,p,n);
  return nano_spi(tx,nullptr,n+4)&&ready();
 }
};
// Check real SPI reads before any erase: the header and two distant data
// blocks must match the same installed core candidate, never a mixture.
static bool nano_boot_readable(NanoBootIO &io){
 uint8_t actual[256],expected[256],header[24];
 bool matches[2]={true,false};
 if(!bflb_flash_read(0x201000,header,sizeof header))
  matches[1]=!memcmp(header,"NBCORE01",8)&&nano_word(header+8)==5&&nano_word(header+12)==907418&&nano_word(header+20)==0x4b30324e;
 const uint32_t bases[2]={0x101000,0x202000};
 const uint32_t offsets[3]={0,0x10000,0x80000};
 for(uint32_t off:offsets){
  if(!io.read(off,actual,sizeof actual))return false;
  for(unsigned i=0;i<2;i++)if(matches[i])
   matches[i]=!bflb_flash_read(bases[i]+off,expected,sizeof expected)&&!memcmp(actual,expected,sizeof actual);
 }
 return matches[0]||matches[1];
}
static bool nano_recovery_valid(){
 uint8_t buffer[256],header[24];
 if(bflb_flash_read(0x100000,header,24)||memcmp(header,"NBCORE01",8)||nano_word(header+8)!=1||nano_word(header+12)!=907418||nano_word(header+20)!=0x4b30324e)return false;
 uint32_t c=0xffffffffu;
 for(uint32_t off=0;off<907418;){unsigned n=907418-off>sizeof buffer?sizeof buffer:907418-off;
  if(bflb_flash_read(0x101000+off,buffer,n))return false;c=nano_crc(c,buffer,n);off+=n;
 }
 // Pin the exact board-verified NES recovery image, not arbitrary owned data.
 return (c^0xffffffffu)==0x107db0af && nano_word(header+16)==0x107db0af;
}
static char nano_flash_detail[48];
static const char *nano_persist_error="Core flash failed";
bool fpga_persist_core(){
 uint8_t header[16];
 nano_persist_error="Core cache invalid";
 if(bflb_flash_read(nanoblast::CacheStart,header,16)||memcmp(header,"NBCACHE1",8)||nano_word(header+8)!=907418||!nano_recovery_valid())return false;
 enable_jtag_pins();chain_len=detectChain(JTAG_MAX_CHAIN);
 if(chain_len!=1||idcodes[0]!=IDCODE_GW2A_18){disable_jtag_pins();nano_persist_error="Core JTAG not detected";return false;}
 taskENTER_CRITICAL();
 nano_persist_error="FPGA config access failed";
 nanoblast_switch_trace(nanoblast::SwitchStep::EraseBoot);
 bool ok=eraseSRAM();bool touched=false;uint32_t failure_detail=0;
 if(ok)nanoblast_switch_trace(nanoblast::SwitchStep::FlashAccess,0,readStatusReg());
 NanoBootIO io(nanoblast::CacheData);
 if(ok){
  uint8_t tx[4]={0x9f,0,0,0},rx[4]={0},s=0xff;
  ok=nano_spi(tx,rx,4);
  uint32_t identity=(uint32_t(rx[1])<<16)|(uint32_t(rx[2])<<8)|rx[3];
  nanoblast_switch_trace(nanoblast::SwitchStep::FlashIdentity,0,identity);
  auto pause=[](){flushTMS(false);uint64_t start=bflb_mtimer_get_time_ms();while(bflb_mtimer_get_time_ms()-start<2){}};
  auto probe=[&](){ok=ok&&nano_spi(tx,rx,4);identity=(uint32_t(rx[1])<<16)|(uint32_t(rx[2])<<8)|rx[3];nanoblast_switch_trace(nanoblast::SwitchStep::FlashIdentity,0,identity);};
  auto wake=[&](){uint8_t command=0xab;ok=ok&&nano_spi(&command,nullptr,1);pause();};
  if(ok&&identity==0xffffff){
   // AB releases power-down. Complete CS deassertion before tRES1.
   nanoblast_switch_trace(nanoblast::SwitchStep::FlashWake);
   wake();probe();
  }
  if(ok&&identity==0xffffff){
   // Match openFPGALoader SPIFlash::reset's all-ones mode escape before
   // attempting a reset. This changes interface mode, not status registers.
   nanoblast_switch_trace(nanoblast::SwitchStep::FlashExit);
   uint8_t escape[9];memset(escape,0xff,sizeof escape);
   ok=nano_spi(escape,nullptr,sizeof escape);pause();wake();probe();
  }
  if(ok&&identity==0xffffff){
   // Standard flash reset used by the working Mac programmer. It restores
   // volatile defaults; ID/protection and boot reads are checked afterwards.
   nanoblast_switch_trace(nanoblast::SwitchStep::FlashReset);
   uint8_t enable=0x66,reset=0x99;
   ok=nano_spi(&enable,nullptr,1)&&nano_spi(&reset,nullptr,1);
   pause();wake();probe();
  }
  bool responded=ok&&io.status(s);
  bool ready=responded&&io.ready();
  if(ready)responded=io.status(s);
  // Preserve the actual response even for an unknown/busy/protected device.
  // Preserve read-only status after interface escape/reset as well as wake.
  nanoblast_switch_trace(nanoblast::SwitchStep::FlashStatus,0,s);
  // Retain the conservative guard until the on-board response identifies why
  // access failed. Never change block protection, status, security or fuses.
  bool known=(rx[1]==0xef||rx[1]==0xc8||rx[1]==0x0b)&&rx[3]==0x17;
  ok=ok&&responded&&ready&&known&&!(s&0x7c);
  failure_detail=(identity<<8)|s;
  std::snprintf(nano_flash_detail,sizeof nano_flash_detail,"%s %06lX SR %02X",
    !known?"Flash ID":!ready?"Flash busy":"Flash protected",
    static_cast<unsigned long>(identity),unsigned(s));
  nano_persist_error=nano_flash_detail;
  if(ok){
   nanoblast_switch_trace(nanoblast::SwitchStep::BootRead);
   ok=nano_boot_readable(io);
   if(!ok)nano_persist_error="FPGA flash readback mismatch";
  }
  if(ok){
   touched=true;nano_persist_error="FPGA flash verify failed";
   nanoblast_switch_trace(nanoblast::SwitchStep::WriteBoot);
   ok=nanoblast::persist_core(io,907418,nano_word(header+12));
  }
 }
 if(!ok&&touched){
  NanoBootIO recovery(0x101000);
  if(nanoblast::persist_core(recovery,907418,0x107db0af))nano_persist_error="Flash failed; NES restored";
  else nano_persist_error="FPGA flash recovery needed";
 }
 // Record failure before the recovery reset so the trace retains its cause.
 if(!ok)nanoblast_switch_trace(nanoblast::SwitchStep::Failed,0,touched?0:failure_detail);
 nanoblast_switch_trace(nanoblast::SwitchStep::ReloadBoot,0,ok?1:0);
 fpgaReset();
 if(ok)nanoblast_switch_trace(nanoblast::SwitchStep::SaveDone);
 taskEXIT_CRITICAL();disable_jtag_pins();return ok;
}
const char *fpga_persist_diagnostic(){return nano_persist_error;}
