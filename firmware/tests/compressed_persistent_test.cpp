#include <cstdint>
#include <cstring>
#include <cassert>
#include <vector>
#include <fstream>
#include <iterator>
#include "core_stage.h"
#include "persistent_core.h"
#include "compressed_core_slots.h"
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

std::string packed_root,raw_root;
const char *names[]={"nes","sms-gamegear","gb-colour","snes-experimental"};
std::vector<uint8_t> raw[4];
void seed(){
 bl.assign(0x400000,255);flash.assign(0x800000,0xa5);memcpy(flash.data(),raw[0].data(),raw[0].size());
 selected=wel=protected_flash=complement=unknown=corrupt_read=ignore_page=link_failure=recovery_failure=no_wel=false;busy=busy_cycles=0;bridge=true;erases=pages=reloads=progress_calls=read_bytes=0;
 for(unsigned i=0;i<4;i++){auto image=load((packed_root+"/"+names[i]+".core").c_str());std::copy(image.begin(),image.end(),bl.begin()+nanoblast::CoreSlots[i].base);}
 nanoblast::compressed_core_reset();nano_boot_diag_valid=false;
}
int main(int argc,char**argv){assert(argc==3);packed_root=argv[1];raw_root=argv[2];
 for(unsigned i=0;i<4;i++)raw[i]=load((raw_root+"/"+names[i]+"-nano20k.bin").c_str());
 for(unsigned i=0;i<4;i++)for(bool verify:{true,false}){
  seed();auto before=bl;assert(fpga_persist_asset(nanoblast::CoreSlots[i].id,verify)&&reloads==1&&bl==before&&!memcmp(flash.data(),raw[i].data(),raw[i].size()));
  for(unsigned j=14*65536;j<flash.size();j++)assert(flash[j]==0xa5);
 }
 seed();protected_flash=true;assert(!fpga_persist_asset(7,true)&&!erases&&!reloads);
 seed();complement=true;assert(!fpga_persist_asset(5,true)&&!erases&&!reloads);
 seed();unknown=true;assert(!fpga_persist_asset(1,true)&&!erases&&!reloads);
 seed();bl[nanoblast::CoreSlots[2].base+4100]^=1;assert(!fpga_persist_asset(7,true)&&!erases&&!reloads);
 seed();corrupt_read=true;assert(!fpga_persist_asset(5,true)&&!erases&&!reloads);
 seed();ignore_page=true;assert(!fpga_persist_asset(7,true)&&!reloads&&erases==14);
 puts("PASS actual boot-flash persistence for all four compressed sources, verification on/off, immutable BL flash, protection/ID guards and failed-save handling");
}
