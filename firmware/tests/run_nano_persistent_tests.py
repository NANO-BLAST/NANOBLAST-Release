"""Run actual GW2A persistence adapter against a JTAG-SPI flash model."""
from pathlib import Path
import subprocess,tempfile
root=Path(__file__).resolve().parents[1];work=root.parent;out=work.parent/'outputs/sms-integration-fixes'
harness=r'''
#include <cstdint>
#include <cstring>
#include <cassert>
#include <vector>
#include <fstream>
#include <iterator>
#include "core_stage.h"
#include "persistent_core.h"
#include "switch_trace.h"
struct Event {nanoblast::SwitchStep step;uint32_t detail;};
std::vector<Event> events;
void nanoblast_switch_trace(nanoblast::SwitchStep s,unsigned,uint32_t d){events.push_back({s,d});}
constexpr unsigned JTAG_MAX_CHAIN=8,IDCODE_GW2A_18=0x81b,EXIT2_DR=7;
unsigned chain_len=0,idcodes[8],critical=0,sram_erases=0,flash_erases=0,reloads=0,pages=0;
uint64_t ticks=0;uint64_t bflb_mtimer_get_time_ms(){return ++ticks;}
std::vector<uint8_t> bl(0x400000,255),fpga(0x800000,0xa5),nes,sms;
bool wel=false,page_failure=false,unknown=false,protected_flash=false,busy=false,asleep=false,disconnected=false,wake_pending=false,continuous=false,needs_reset=false,reset_enabled=false,read_corrupt=false;
unsigned escapes=0,resets=0;
unsigned wakes=0;uint64_t wake_ready=0;
int bflb_flash_read(unsigned a,void*p,unsigned n){assert(a+n<=bl.size());memcpy(p,bl.data()+a,n);return 0;}
void enable_jtag_pins(){}void disable_jtag_pins(){}
unsigned detectChain(unsigned){idcodes[0]=IDCODE_GW2A_18;return 1;}
void taskENTER_CRITICAL(){assert(!critical);++critical;}void taskEXIT_CRITICAL(){assert(critical);--critical;}
uint32_t readStatusReg(){return 0x20;}
bool eraseSRAM(){++sram_erases;return true;}void fpgaReset(){++reloads;}
void flushTMS(bool){if(wake_pending){wake_pending=false;wake_ready=ticks+2;}}
void send_command(unsigned v){assert(v==0x16);}void set_state(unsigned v){assert(v==EXIT2_DR);}
uint8_t reverse(uint8_t v){uint8_t r=0;for(unsigned i=0;i<8;i++)r|=((v>>i)&1)<<(7-i);return r;}
void shiftDR(const uint8_t*data,uint8_t*rx,unsigned bits){
 assert(critical==1&&bits%8==0);unsigned count=bits/8,n=count-(rx?1:0);
 std::vector<uint8_t>tx(count),reply(count,0);for(unsigned i=0;i<count;i++)tx[i]=reverse(data[i]);
 unsigned addr=n>=4?(unsigned(tx[1])<<16)|(unsigned(tx[2])<<8)|tx[3]:0;
 if(asleep&&wake_ready&&ticks>=wake_ready)asleep=false;
 if(disconnected||(asleep&&tx[0]!=0xab)||(continuous&&tx[0]!=0xff)||(needs_reset&&tx[0]!=0x66&&tx[0]!=0x99)){
  // Undriven MISO reads high for every bit while asleep or disconnected.
  for(auto &v:reply)v=0xff;
 }else {switch(tx[0]){
 case 0xff:assert(!rx&&n==9);for(unsigned i=0;i<n;i++)assert(tx[i]==255);++escapes;continuous=false;break;
 case 0x66:assert(!rx&&n==1);reset_enabled=true;break;
 case 0x99:assert(!rx&&n==1&&reset_enabled);reset_enabled=false;needs_reset=false;++resets;wake_ready=ticks+2;asleep=true;break;
 case 0xab:assert(!rx&&n==1);++wakes;if(asleep)wake_pending=true;break;
 case 0x9f:assert(rx&&n==4);reply[1]=unknown?0xff:0xef;reply[2]=0x40;reply[3]=0x17;break;
 case 5:assert(rx&&n==2);reply[1]=(wel?2:0)|(protected_flash?4:0)|(busy?1:0);break;
 case 6:assert(!rx&&n==1&&!asleep&&!disconnected&&!protected_flash&&!unknown&&!busy);wel=true;break;
 case 0xd8:assert(!rx&&n==4&&wel&&addr%65536==0&&addr<0x100000);wel=false;++flash_erases;memset(fpga.data()+addr,255,65536);break;
 case 2:assert(!rx&&wel&&n>4&&n<=260&&(addr&255)+n-4<=256);wel=false;++pages;
  if(page_failure){page_failure=false;break;}
  for(unsigned i=4;i<n;i++)fpga[addr+i-4]&=tx[i];break;
 case 3:assert(rx&&n>4&&addr+n-4<=0x100000);memcpy(reply.data()+4,fpga.data()+addr,n-4);if(read_corrupt)reply[4]^=1;break;
 default:assert(false);
 }}
 if(rx){memset(rx,0,count);for(unsigned i=0;i<n;i++){rx[i]|=uint8_t((reverse(reply[i])&0x7f)<<1);rx[i+1]|=reply[i]&1;}}
}
// ADAPTER
std::vector<uint8_t>load(const char*p){std::ifstream f(p,std::ios::binary);assert(f.good());return std::vector<uint8_t>(std::istreambuf_iterator<char>(f),{});}
void put(unsigned a,uint32_t v){for(unsigned i=0;i<4;i++)bl[a+i]=v>>(8*i);}
void seed(){
 bl.assign(0x400000,255);fpga.assign(0x800000,0xa5);wel=false;pages=flash_erases=sram_erases=reloads=0;unknown=protected_flash=page_failure=busy=false;events.clear();asleep=disconnected=wake_pending=false;wakes=0;wake_ready=0;continuous=needs_reset=reset_enabled=read_corrupt=false;escapes=resets=0;
 memcpy(fpga.data(),nes.data(),nes.size());
 memcpy(bl.data()+0x201000,"NBCORE01",8);put(0x201008,5);put(0x20100c,sms.size());put(0x201014,0x4b30324e);memcpy(bl.data()+0x202000,sms.data(),sms.size());
 memcpy(bl.data()+0x100000,"NBCORE01",8);put(0x100008,1);put(0x10000c,nes.size());put(0x100010,0x107db0af);put(0x100014,0x4b30324e);memcpy(bl.data()+0x101000,nes.data(),nes.size());
 memcpy(bl.data()+nanoblast::CacheStart,"NBCACHE1",8);put(nanoblast::CacheStart+8,sms.size());put(nanoblast::CacheStart+12,nano_crc(~0u,sms.data(),sms.size())^~0u);memcpy(bl.data()+nanoblast::CacheData,sms.data(),sms.size());
}
int main(int argc,char**argv){assert(argc==3);nes=load(argv[1]);sms=load(argv[2]);assert(nes.size()==907418&&sms.size()==907418);
 seed();assert(fpga_persist_core()&&!critical&&reloads==1&&flash_erases==14&&!memcmp(fpga.data(),sms.data(),sms.size()));
 for(unsigned i=14*65536;i<fpga.size();i++)assert(fpga[i]==0xa5);
 // The observed all-FF condition is reproduced until AB, CS deassertion,
 // and a full 2ms quiet interval have completed. No protection command exists.
 seed();asleep=true;assert(fpga_persist_core()&&!critical&&wakes==1&&!asleep&&flash_erases==14);
 assert(!memcmp(fpga.data(),sms.data(),sms.size()));
 assert(events[2].step==nanoblast::SwitchStep::FlashIdentity&&events[2].detail==0xffffff);
 assert(events[3].step==nanoblast::SwitchStep::FlashWake);
 assert(events[4].step==nanoblast::SwitchStep::FlashIdentity&&events[4].detail==0xef4017);
 seed();disconnected=true;assert(!fpga_persist_core()&&!flash_erases&&!pages&&!wel&&!critical&&wakes==0);
 assert(!strcmp(fpga_persist_diagnostic(),"Flash ID FFFFFF SR FF"));
 seed();asleep=protected_flash=true;assert(!fpga_persist_core()&&!flash_erases&&!pages&&!wel&&!critical&&wakes==1);
 assert(!strcmp(fpga_persist_diagnostic(),"Flash protected EF4017 SR 04"));
 seed();continuous=true;assert(fpga_persist_core()&&!critical&&escapes==1&&!resets&&flash_erases==14);
 seed();needs_reset=true;assert(fpga_persist_core()&&!critical&&escapes==0&&resets==1&&flash_erases==14);
 seed();needs_reset=protected_flash=true;assert(!fpga_persist_core()&&!flash_erases&&!pages&&!wel&&!critical&&resets==1);
 assert(!strcmp(fpga_persist_diagnostic(),"Flash protected EF4017 SR 04"));
 seed();memcpy(fpga.data(),sms.data(),sms.size());assert(fpga_persist_core()&&flash_erases==14);
 seed();read_corrupt=true;assert(!fpga_persist_core()&&!flash_erases&&!pages&&!wel&&!critical);
 assert(!strcmp(fpga_persist_diagnostic(),"FPGA flash readback mismatch"));
 seed();fpga[0x80000]^=1;assert(!fpga_persist_core()&&!flash_erases&&!pages&&!wel&&!critical);
 // Header and distant data must match the same installed core.
 seed();memcpy(fpga.data()+0x80000,sms.data()+0x80000,256);assert(!fpga_persist_core()&&!flash_erases);
 seed();unknown=true;assert(!fpga_persist_core()&&!flash_erases&&!critical);
 assert(!strcmp(fpga_persist_diagnostic(),"Flash ID FF4017 SR 00"));
 assert(events[2].step==nanoblast::SwitchStep::FlashIdentity&&events[2].detail==0xff4017);
 assert(events[3].step==nanoblast::SwitchStep::FlashStatus&&events[3].detail==0);
 assert(events[4].step==nanoblast::SwitchStep::Failed&&events[4].detail==0xff401700);
 assert(events[5].step==nanoblast::SwitchStep::ReloadBoot);
 seed();protected_flash=true;assert(!fpga_persist_core()&&!flash_erases&&!critical);
 assert(!strcmp(fpga_persist_diagnostic(),"Flash protected EF4017 SR 04"));
 assert(events[4].detail==0xef401704);
 seed();busy=true;assert(!fpga_persist_core()&&!flash_erases&&!critical);
 assert(!strcmp(fpga_persist_diagnostic(),"Flash busy EF4017 SR 01"));
 assert(events[4].detail==0xef401701);
 seed();bl[0x101000]^=1;assert(!fpga_persist_core()&&!sram_erases&&!flash_erases);
 seed();page_failure=true;assert(!fpga_persist_core()&&!critical&&reloads==1&&flash_erases==28&&!memcmp(fpga.data(),nes.data(),nes.size()));
 assert(!strcmp(fpga_persist_diagnostic(),"Flash failed; NES restored"));
}
'''.replace('// ADAPTER',(root/'fpga/nano_persistent.inc').read_text())
with tempfile.TemporaryDirectory(prefix='nano-persist-') as tmp:
 p=Path(tmp);(p/'test.cpp').write_text(harness)
 subprocess.run(['clang++','-std=c++17','-Wall','-Wextra','-Werror','-fsanitize=address,undefined','-I',str(root/'storage'),str(p/'test.cpp'),str(root/'storage/persistent_core.cpp'),'-o',str(p/'test')],check=True)
 subprocess.run([str(p/'test'),str(work.parent/'outputs/menu-unified/nanoblast-menu-unified.bin'),str(work.parent/'outputs/sms-nano-integration/smstang-nano20k.bin')],check=True)
 print('PASS mode escape/reset retry and read-before-erase: corrupt/mixed boot samples rejected, reset preserves protection guard; wake retry: asleep flash needs AB + CS release + delay, disconnected/protected remain unwritten; actual persistent adapter: GW2A one-bit RX delay, Winbond ID/protection guards, exact boot image/page readback, unchanged upper flash, preflight recovery CRC, simulated write failure restores exact NES recovery')
