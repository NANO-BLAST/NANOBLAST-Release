#pragma once
#include <cstdint>
namespace nanoblast {
constexpr uint32_t TraceStart=0x3ff000;
enum class SwitchStep:uint32_t {Staged=1,Chain,Erase,Stream,Activate,Configured,CoreReply,SaveBoot,EraseBoot,WriteBoot,ReloadBoot,SaveDone,Complete,Failed,Recovered,FirmwareBoot,PrepareAssets,Staging,FlashIdentity,FlashStatus,FlashWake,FlashExit,FlashReset,FlashAccess,BootRead};
struct TraceIO {virtual ~TraceIO()=default;virtual bool read(uint32_t,uint8_t*,unsigned)=0;virtual bool write(uint32_t,const uint8_t*,unsigned)=0;virtual bool erase_metadata(){return false;}};
// Append-only journal in its own owned NBTRACE1 sector, outside core assets.
// No erase, allocation, filesystem or external FPGA flash operation.
bool switch_trace_append(TraceIO&,SwitchStep,unsigned core=0,uint32_t detail=0);
const char *switch_trace_read(TraceIO&);
// Renew only the owned journal sector; never erase a core image or staged payload.
bool switch_trace_begin(TraceIO&,unsigned core);
}
void nanoblast_switch_trace(nanoblast::SwitchStep,unsigned core=0,uint32_t detail=0);
const char *nanoblast_switch_trace_status();

void nanoblast_switch_trace_boot();
void nanoblast_switch_trace_begin(unsigned core);
