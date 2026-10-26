#include <cstdint>
#include <cstring>
#include <cassert>
#include <vector>
#include <fstream>
#include <iterator>
#include "core_stage.h"
#include "persistent_core.h"
#include "switch_trace.h"
std::vector<uint8_t> bl(0x400000,255),flash(0x800000,0xa5),nes,sms,legacy,wire;
unsigned wire_calls=0,wire_frames=0;
unsigned read_bytes=0;
unsigned busy_cycles=0,busy=0;
bool no_wel=false;
unsigned erases=0,pages=0,reloads=0,progress_calls=0;uint64_t ticks=0;
bool selected=false,wel=false,protected_flash=false,complement=false,unknown=false,corrupt_read=false,ignore_page=false,link_failure=false,recovery_failure=false,bridge=true;
int bflb_flash_read(unsigned a,void*p,unsigned n){assert(a+n<=bl.size());memcpy(p,bl.data()+a,n);return 0;}
uint64_t bflb_mtimer_get_time_ms(){return ++ticks;}void delay(unsigned n){ticks+=n;}
void overlay_cursor(unsigned,unsigned){}void overlay_printf(const char*,...){++progress_calls;}
void nanoblast_switch_trace(nanoblast::SwitchStep,unsigned,uint32_t){}
void fpga_reload_boot_core(){++reloads;assert(!selected);}
bool fpga_flash_available(){return bridge;}
unsigned addr(){return (unsigned(wire[1])<<16)|(unsigned(wire[2])<<8)|wire[3];}
void close(){
 if(!selected)return;
 if(wire.empty()){selected=false;return;}
 switch(wire[0]){
 case 6:assert(wire.size()==1&&!busy&&!protected_flash&&!complement&&!unknown);wel=!no_wel;break;
 case 0xd8:assert(wel&&!busy&&wire.size()==4&&addr()%65536==0&&addr()<0x100000);wel=false;busy=busy_cycles;++erases;memset(flash.data()+addr(),255,65536);break;
 case 2:if(wire.size()==4){wel=false;break;}assert(wel&&!busy&&wire.size()>4&&wire.size()<=260&&(addr()&255)+wire.size()-4<=256);wel=false;busy=busy_cycles;++pages;
  if(ignore_page){ignore_page=false;break;}
  if(recovery_failure)break;
  for(unsigned i=4;i<wire.size();i++)flash[addr()+i-4]&=wire[i];break;
 default:break;
 }
 selected=false;
}
bool fpga_flash_transfer(bool high,const uint8_t*tx,uint8_t*rx,unsigned n){
 ++wire_calls;
 wire_frames+=n?(n+31)/32:1;
 if(high){assert(n==0);close();return true;}
 if(!selected){selected=true;wire.clear();}
 if(link_failure&&wire.size()==4&&wire[0]==2){link_failure=false;return false;}
 for(unsigned i=0;i<n;i++){
  unsigned p=wire.size();uint8_t data=tx?tx[i]:255,result=255;
  wire.push_back(data);
  if(p){switch(wire[0]){
   case 0x9f:{const uint8_t id[]={0xef,0x40,0x17};result=unknown?255:id[(p-1)%3];break;}
   case 5:result=(wel?2:0)|(protected_flash?4:0)|(busy?1:0);if(busy)--busy;break;
   case 0x35:result=complement?0x40:0;break;
   case 3:if(p>=4){++read_bytes;assert(addr()+p-4<0x100000);result=flash[addr()+p-4]^(corrupt_read?1:0);}break;
  }}
  if(rx)rx[i]=result;
 }
 return true;
}
#include "../fpga/nano_direct_persistent.inc"
std::vector<uint8_t>load(const char*p){std::ifstream f(p,std::ios::binary);assert(f.good());return std::vector<uint8_t>(std::istreambuf_iterator<char>(f),{});}
void put(unsigned a,uint32_t v){for(unsigned i=0;i<4;i++)bl[a+i]=v>>(8*i);}
void seed(){
 bl.assign(0x400000,255);flash.assign(0x800000,0xa5);memcpy(flash.data(),nes.data(),nes.size());
 selected=wel=protected_flash=complement=unknown=corrupt_read=ignore_page=link_failure=recovery_failure=no_wel=false;busy=busy_cycles=0;bridge=true;erases=pages=reloads=progress_calls=read_bytes=0;
 memcpy(bl.data()+0x100000,"NBCORE01",8);put(0x100008,1);put(0x10000c,nes.size());put(0x100010,NanoRecoveryCRC);put(0x100014,0x4b30324e);memcpy(bl.data()+0x101000,nes.data(),nes.size());
 memcpy(bl.data()+0x201000,"NBCORE01",8);put(0x201008,5);put(0x20100c,sms.size());put(0x201010,nano_crc(~0u,sms.data(),sms.size())^~0u);put(0x201014,0x4b30324e);memcpy(bl.data()+0x202000,sms.data(),sms.size());
 memcpy(bl.data()+nanoblast::CacheStart,"NBCACHE1",8);put(nanoblast::CacheStart+8,sms.size());put(nanoblast::CacheStart+12,nano_crc(~0u,sms.data(),sms.size())^~0u);memcpy(bl.data()+nanoblast::CacheData,sms.data(),sms.size());
}
int main(int argc,char**argv){assert(argc==4||argc==5);nes=load(argv[1]);sms=load(argv[2]);legacy=load(argv[3]);assert(nes.size()==907418&&sms.size()==907418);
 seed();assert(fpga_persist_core(true)&&reloads==1&&erases==14&&progress_calls&&!memcmp(flash.data(),sms.data(),sms.size()));
 printf("Flash transfer calls per NES-to-SMS switch: %u\n",wire_calls);
 printf("32-byte bridge packets per NES-to-SMS switch: %u\n",wire_frames);
 assert(wire_frames<=87000);
 for(unsigned i=14*65536;i<flash.size();i++)assert(flash[i]==0xa5);
 seed();memcpy(flash.data(),legacy.data(),legacy.size());assert(fpga_persist_core(true)&&reloads==1);
 seed();memcpy(flash.data(),sms.data(),sms.size());assert(fpga_persist_core(true)&&reloads==1);
 seed();protected_flash=true;assert(!fpga_persist_core(true)&&!erases&&!reloads);
 seed();no_wel=true;assert(!fpga_persist_core(true)&&!erases&&!reloads);
 seed();busy=10000;assert(!fpga_persist_core(true)&&!erases&&!reloads);
 seed();busy_cycles=2;assert(fpga_persist_core(true)&&reloads==1&&!memcmp(flash.data(),sms.data(),sms.size()));
 seed();complement=true;assert(!fpga_persist_core(true)&&!erases&&!reloads);
 seed();unknown=true;assert(!fpga_persist_core(true)&&!erases&&!reloads);
 seed();corrupt_read=true;assert(!fpga_persist_core(true)&&!erases&&!reloads);
 seed();bridge=false;assert(!fpga_persist_core(true)&&!erases&&!reloads);
 seed();memcpy(flash.data(),sms.data(),sms.size());bl[0x101000]^=1;assert(fpga_persist_asset(5,true)&&reloads==1); // No dependency on a NES repair image.
 seed();bl[nanoblast::CacheData+500]^=1;assert(!fpga_persist_core(true)&&!erases&&!reloads);
 seed();ignore_page=true;assert(!fpga_persist_core(true)&&!reloads&&erases==14);
 assert(strstr(fpga_persist_diagnostic(),"Verify CRC"));
 seed();link_failure=true;assert(!fpga_persist_core(true)&&!reloads&&erases==1);
 seed();recovery_failure=true;assert(!fpga_persist_core(true)&&!reloads);
 assert(strstr(fpga_persist_diagnostic(),"Verify CRC")&&erases==14);
 // Validate both directions: current SMS -> saved NES.
 seed();memcpy(flash.data(),sms.data(),sms.size());memcpy(bl.data()+nanoblast::CacheData,nes.data(),nes.size());put(nanoblast::CacheStart+12,NanoRecoveryCRC);
 assert(fpga_persist_core(true)&&reloads==1&&!memcmp(flash.data(),nes.data(),nes.size()));
 // Both built-in sources work even with no staging cache. BL flash remains
 // byte-for-byte unchanged by persistence, including the old cache payload.
 for(unsigned id:{1u,5u})for(bool verify:{true,false}){
  seed();std::memset(bl.data()+nanoblast::CacheStart,0x5a,nanoblast::CacheSize);auto before=bl;
  unsigned packets_before=wire_frames;
  assert(fpga_persist_asset(id,verify)&&reloads==1&&bl==before);
  const auto&expected=id==1?nes:sms;
  assert(!memcmp(flash.data(),expected.data(),expected.size()));
  assert(read_bytes==768+(verify?907418:0));
  if(id==5)printf("Direct SMS bridge packets, verification %s: %u\n",verify?"on":"off",wire_frames-packets_before);
 }
 seed();bl[0x202000+500]^=1;assert(!fpga_persist_asset(5,false)&&!erases&&!reloads);
 seed();bl[0x201008]=1;assert(!fpga_persist_asset(5,false)&&!erases);
 seed();bl[0x202000+sms.size()-30]=0;assert(!fpga_persist_asset(5,false)&&!erases);
 seed();assert(!fpga_persist_asset(99,false)&&!erases);
 seed();protected_flash=true;assert(!fpga_persist_asset(5,false)&&!erases);
 seed();ignore_page=true;assert(fpga_persist_asset(5,false)&&read_bytes==768); // explicit readback opt-out
 seed();link_failure=true;assert(!fpga_persist_asset(5,false)&&!reloads&&erases==1); // No automatic NES writes.
 seed();link_failure=recovery_failure=true;assert(!fpga_persist_asset(5,false)&&!reloads);
 // A distinct SNES fixture exercises all three source slots and switching
 // away from an existing SNES boot image. This host fixture is never flashed.
 std::vector<uint8_t>snes=sms;
 for(unsigned off:{100u,0x10064u,0x80064u})snes[off]^=0x5a;
 if(argc==5){snes=load(argv[4]);assert(snes.size()==907418);}
 for(unsigned id:{1u,2u,5u})for(bool verify:{true,false}){
  seed();memcpy(bl.data()+0x300000,"NBCORE01",8);put(0x300008,2);put(0x30000c,snes.size());
  put(0x300010,nano_crc(~0u,snes.data(),snes.size())^~0u);put(0x300014,0x4b30324e);
  memcpy(bl.data()+0x301000,snes.data(),snes.size());
  memcpy(bl.data()+0x3ff000,"NBTRACE1",8);memcpy(flash.data(),snes.data(),snes.size());auto before=bl;
  assert(fpga_persist_asset(id,verify)&&reloads==1&&before==bl);
  const auto &expected=id==1?nes:id==2?snes:sms;
  assert(!memcmp(flash.data(),expected.data(),expected.size()));
 }

 // Inspect physical flash contents without modifying either device; cache reads.
 seed();nano_boot_diag_valid=false;auto before_diag=bl;
 assert(std::strstr(fpga_boot_flash_diagnostic(),"Boot flash: NES "));
 assert(!erases&&!pages&&!reloads&&bl==before_diag&&read_bytes==907418);
 unsigned cached_reads=read_bytes;fpga_boot_flash_diagnostic();assert(read_bytes==cached_reads);
 assert(fpga_persist_asset(5,false));
 unsigned saved_erases=erases,saved_pages=pages,saved_reloads=reloads;
 assert(std::strstr(fpga_boot_flash_diagnostic(),"Boot flash: SMS "));
 assert(erases==saved_erases&&pages==saved_pages&&reloads==saved_reloads&&bl==before_diag);
 flash[500]^=1;nano_boot_diag_valid=false;
 assert(std::strstr(fpga_boot_flash_diagnostic(),"Boot flash: unknown "));
 assert(erases==saved_erases&&pages==saved_pages&&reloads==saved_reloads);

 // Updating the auxiliary SMS image must not make the saved older SMS boot
 // image unrecognizable or block a later explicit flash-save of the new image.
 seed();memcpy(flash.data(),sms.data(),sms.size());
 for(unsigned off:{100u,0x10064u,0x80064u})bl[0x202000+off]^=0x5a;
 put(0x201010,nano_crc(~0u,bl.data()+0x202000,sms.size())^~0u);
 nano_boot_diag_valid=false;assert(strstr(fpga_boot_flash_diagnostic(),"Boot flash: SMS ")&&!erases);
 assert(fpga_persist_asset(5,true)&&reloads==1);
 assert(!memcmp(flash.data(),bl.data()+0x202000,sms.size()));

}
