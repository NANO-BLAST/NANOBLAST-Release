#include "switch_trace.h"
#include "core_stage.h"
#include <cstring>
#include <cstdio>
#ifndef NANOBLAST_SWITCH_TRACE_HOST_TEST
#include "bflb_flash.h"
#endif
namespace nanoblast {
namespace {
constexpr unsigned Start=TraceStart+0x100,Count=32,Size=24;
uint32_t word(const uint8_t*p){return uint32_t(p[0])|(uint32_t(p[1])<<8)|(uint32_t(p[2])<<16)|(uint32_t(p[3])<<24);}
void put(uint8_t*p,uint32_t v){for(unsigned i=0;i<4;i++)p[i]=v>>(8*i);}
bool owned(TraceIO&io){uint8_t b[8];return io.read(TraceStart,b,8)&&!std::memcmp(b,"NBTRACE1",8);}
const char *label(uint32_t v){switch(SwitchStep(v)){
case SwitchStep::Staged:return "staged";case SwitchStep::Chain:return "JTAG chain";case SwitchStep::Erase:return "FPGA erase";
case SwitchStep::Stream:return "FPGA stream";case SwitchStep::Activate:return "activation";case SwitchStep::Configured:return "configured";
case SwitchStep::CoreReply:return "core reply";case SwitchStep::SaveBoot:return "save boot";case SwitchStep::EraseBoot:return "boot access";
case SwitchStep::WriteBoot:return "boot write";case SwitchStep::ReloadBoot:return "boot reload";case SwitchStep::SaveDone:return "boot saved";
case SwitchStep::Complete:return "complete";case SwitchStep::Failed:return "failed";case SwitchStep::Recovered:return "recovered";case SwitchStep::FirmwareBoot:return "firmware boot";case SwitchStep::PrepareAssets:return "core source";case SwitchStep::Staging:return "staging";case SwitchStep::FlashIdentity:return "flash ID";case SwitchStep::FlashStatus:return "flash status";case SwitchStep::FlashWake:return "flash wake";case SwitchStep::FlashExit:return "flash mode exit";case SwitchStep::FlashReset:return "flash reset";case SwitchStep::FlashAccess:return "flash access";case SwitchStep::BootRead:return "boot read";}
return "invalid";}
}
bool switch_trace_append(TraceIO&io,SwitchStep step,unsigned core,uint32_t detail){
 if(!owned(io))return false;
 uint8_t b[Size];
 for(unsigned i=0;i<Count;i++){
  unsigned a=Start+i*Size;if(!io.read(a,b,Size))return false;
  bool blank=true;for(uint8_t v:b)blank=blank&&v==255;
  if(!blank)continue;
  std::memcpy(b,"NBST",4);put(b+4,uint32_t(step));put(b+8,core);put(b+12,detail);put(b+16,i);
  put(b+20,~(word(b)^word(b+4)^word(b+8)^word(b+12)^word(b+16)));
  return io.write(a,b,Size);
 }
 return false;
}
bool switch_trace_begin(TraceIO&io,unsigned core){
 uint8_t header[16],found[16];
 if(!io.read(TraceStart,header,sizeof header)||std::memcmp(header,"NBTRACE1",8))return false;
 // Header is in RAM: XIP-backed buffers cannot be flash-write sources.
 if(!io.erase_metadata()||!io.write(TraceStart,header,sizeof header)||
    !io.read(TraceStart,found,sizeof found)||std::memcmp(header,found,sizeof header))return false;
 return switch_trace_append(io,SwitchStep::PrepareAssets,core);
}
const char *switch_trace_read(TraceIO&io){
 static char status[48];uint8_t b[Size];uint32_t step=0,core=0,detail=0,previous=0,failure=0,failure_detail=0;
 if(!owned(io))return "Switch: no trace";
 for(unsigned i=0;i<Count;i++){
  if(!io.read(Start+i*Size,b,Size))break;
  if(std::memcmp(b,"NBST",4)||word(b+16)!=i||word(b+20)!=~(word(b)^word(b+4)^word(b+8)^word(b+12)^word(b+16)))continue;
  if(word(b+4)==uint32_t(SwitchStep::Failed)){failure=step;failure_detail=word(b+12);}
  if(word(b+4)==uint32_t(SwitchStep::Complete))failure=0;
  if(word(b+4)==uint32_t(SwitchStep::FirmwareBoot)&&step!=uint32_t(SwitchStep::FirmwareBoot))previous=step;
  step=word(b+4);core=word(b+8);detail=word(b+12);
 }
 if(!step)return "Switch: no trace";
 if(step==uint32_t(SwitchStep::FirmwareBoot)){
  if(!previous)return "Switch: no previous attempt";
  if(previous<uint32_t(SwitchStep::Complete)||previous>=uint32_t(SwitchStep::PrepareAssets)){
   std::snprintf(status,sizeof status,"Reset: %s %08lx",label(previous),static_cast<unsigned long>(detail));return status;
  }
  step=previous;
 }
 if(step==uint32_t(SwitchStep::Recovered)&&failure){
  std::snprintf(status,sizeof status,"Fail: %s %08lx",label(failure),static_cast<unsigned long>(failure_detail));return status;
 }
 std::snprintf(status,sizeof status,"Switch: %s %lu/%08lx",label(step),static_cast<unsigned long>(core),static_cast<unsigned long>(detail));
 return status;
}
}
#ifndef NANOBLAST_SWITCH_TRACE_HOST_TEST
namespace {struct BoardTrace:nanoblast::TraceIO {
 bool read(uint32_t a,uint8_t*p,unsigned n)override{return bflb_flash_read(a,p,n)==0;}
 bool write(uint32_t a,const uint8_t*p,unsigned n)override{return bflb_flash_write(a,const_cast<uint8_t*>(p),n)==0;}
 bool erase_metadata()override{return bflb_flash_erase(nanoblast::TraceStart,4096)==0;}
};}
void nanoblast_switch_trace(nanoblast::SwitchStep s,unsigned c,uint32_t d){BoardTrace io;nanoblast::switch_trace_append(io,s,c,d);}
void nanoblast_switch_trace_begin(unsigned c){BoardTrace io;nanoblast::switch_trace_begin(io,c);}
const char *nanoblast_switch_trace_status(){BoardTrace io;return nanoblast::switch_trace_read(io);}
void nanoblast_switch_trace_boot(){
 // BL616 GLB_RESET_STS0, same read-only register used by SDK GLB_Get_Reset_Reason.
 nanoblast_switch_trace(nanoblast::SwitchStep::FirmwareBoot,0,*reinterpret_cast<volatile uint32_t*>(0x20000530));
}
#endif
