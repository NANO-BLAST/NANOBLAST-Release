#include "switch_trace.h"
#include "core_stage.h"
#include <vector>
#include <cstring>
#include <cassert>
#include <string>
struct Flash:nanoblast::TraceIO {
 std::vector<uint8_t>b=std::vector<uint8_t>(0x400000,255);unsigned writes=0,erases=0;bool partial=false;
 bool read(uint32_t a,uint8_t*p,unsigned n)override{assert(a+n<=b.size());memcpy(p,b.data()+a,n);return true;}
 bool write(uint32_t a,const uint8_t*p,unsigned n)override{assert((a==0x3ff000&&n==16)||(a>=0x3ff100&&a+n<=0x3ff400));++writes;for(unsigned i=0;i<(partial?n/2:n);i++)b[a+i]&=p[i];return !partial;}
 bool erase_metadata()override{++erases;std::memset(b.data()+0x3ff000,255,4096);return true;}
};
int main(){
 Flash f;assert(!nanoblast::switch_trace_append(f,nanoblast::SwitchStep::Stream)&&!f.writes);
 memcpy(f.b.data()+0x3ff000,"NBTRACE1",8);auto original=f.b;
 assert(nanoblast::switch_trace_append(f,nanoblast::SwitchStep::Stream,5,0xa723));
 assert(std::string(nanoblast::switch_trace_read(f)).find("FPGA stream 5/")!=std::string::npos);
 // A new API instance after reset sees the durable phase. A torn next record
 // cannot hide the prior valid entry, and subsequent entries remain usable.
 Flash reset;reset.b=f.b;assert(std::string(nanoblast::switch_trace_read(reset)).find("FPGA stream")!=std::string::npos);
 assert(nanoblast::switch_trace_append(reset,nanoblast::SwitchStep::FirmwareBoot,0,8));
 assert(std::string(nanoblast::switch_trace_read(reset))=="Reset: FPGA stream 00000008");
 reset.partial=true;assert(!nanoblast::switch_trace_append(reset,nanoblast::SwitchStep::Activate));
 assert(std::string(nanoblast::switch_trace_read(reset)).find("FPGA stream")!=std::string::npos);
 reset.partial=false;assert(nanoblast::switch_trace_append(reset,nanoblast::SwitchStep::Configured));
 assert(std::string(nanoblast::switch_trace_read(reset)).find("configured")!=std::string::npos);
 assert(nanoblast::switch_trace_append(reset,nanoblast::SwitchStep::Activate));
 assert(nanoblast::switch_trace_append(reset,nanoblast::SwitchStep::Failed,0,0x6021));
 assert(nanoblast::switch_trace_append(reset,nanoblast::SwitchStep::Recovered,1));
 assert(std::string(nanoblast::switch_trace_read(reset))=="Fail: activation 00006021");
 assert(nanoblast::switch_trace_append(reset,nanoblast::SwitchStep::FlashIdentity,0,0xef4017));
 assert(nanoblast::switch_trace_append(reset,nanoblast::SwitchStep::FlashStatus,0,4));
 assert(nanoblast::switch_trace_append(reset,nanoblast::SwitchStep::Failed,0,0xef401704));
 assert(nanoblast::switch_trace_append(reset,nanoblast::SwitchStep::ReloadBoot));
 assert(nanoblast::switch_trace_append(reset,nanoblast::SwitchStep::Recovered,1));
 assert(std::string(nanoblast::switch_trace_read(reset))=="Fail: flash status ef401704");
 for(unsigned i=0;i<reset.b.size();i++)if(i<0x3ff100||i>=0x3ff400)assert(reset.b[i]==original[i]);
 Flash foreign;foreign.b[0x3ff000]=1;
 assert(!nanoblast::switch_trace_begin(foreign,5)&&!foreign.writes&&!foreign.erases);
 auto previous=reset.b;
 assert(nanoblast::switch_trace_begin(reset,5)&&reset.erases==1);
 assert(std::memcmp(reset.b.data()+0x3ff000,previous.data()+0x3ff000,16)==0);
 for(unsigned i=0;i<reset.b.size();i++)if(i<0x3ff000||i>=0x400000)assert(reset.b[i]==previous[i]);
 assert(std::string(nanoblast::switch_trace_read(reset)).find("5/")!=std::string::npos);
}
