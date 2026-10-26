"""Exercise production fast GPIO and TAP state transitions against an independent TAP."""
from pathlib import Path
import subprocess,tempfile
root=Path(__file__).resolve().parents[1];s=(root/'fpga/programmer.cpp').read_text()
enum=s[s.index('typedef enum tapState_t'):s.index('static int _num_tms')]
writer=s[s.index('void jtag_writeTDI_msb_first_gpio_out_mode'):s.index('\n/*\nstatic int jtag_writeTDI_slow')]
tap=s[s.index('static unsigned _dr_bits_before'):s.index('static uint32_t readReg32')]
reset=s[s.index('void fpgaReset()'):s.index('void enable_jtag_pins')]
end=s[s.index('bool writeSRAM_end()'):s.index('void fpgaStatus()')]
harness=r'''
#define TANG_NANO20K
#include <cstdint>
#include <cassert>
#include <cstring>
#include <cstdio>
#include <vector>
// ENUM
static unsigned half_periods=0;
static void jtag_nano_half_period(){++half_periods;}
static tapState_t _state=SHIFT_DR;
static int _num_tms=0,_curr_tms=0,_curr_tdi=0;
#define JTAG_TMS_BUFFER_SIZE 128
static unsigned char _tms_buffer[128];
static int physical=SHIFT_DR;static bool clock_high=false;
static std::vector<unsigned> data_bits,ir_bits,instructions;
static const int next_state[16][2]={{1,0},{1,2},{3,9},{4,5},{4,5},{6,8},{6,7},{4,8},{1,2},{10,0},{11,12},{11,12},{13,15},{13,14},{11,15},{1,2}};
void edge(unsigned tms,unsigned tdi){
 if(physical==SHIFT_DR)data_bits.push_back(tdi);
 if(physical==CAPTURE_IR)ir_bits.clear();
 if(physical==SHIFT_IR)ir_bits.push_back(tdi);
 if(physical==UPDATE_IR){unsigned v=0;assert(ir_bits.size()==8);for(unsigned i=0;i<8;i++)v|=ir_bits[i]<<i;instructions.push_back(v);}
 physical=next_state[physical][tms];
}
constexpr uint32_t unrelated=0xa5a5a5a5u&~((1u<<16)|(1u<<12)|(1u<<10));
struct Register {uint32_t stored=unrelated;operator uint32_t()const{return stored;}void operator=(uint32_t value){assert((value&~((1u<<16)|(1u<<12)|(1u<<10)))==unrelated);stored=value;bool high=value&(1<<10);if(high&&!clock_high)edge(bool(value&(1<<16)),bool(value&(1<<12)));clock_high=high;}} reg;
static Register *reg_gpio0_31=&reg;
static int flushTMS(bool){for(int i=0;i<_num_tms;i++)edge((_tms_buffer[i/8]>>(i&7))&1,_curr_tdi);memset(_tms_buffer,0,sizeof _tms_buffer);_num_tms=0;return 0;}
static int jtag_writeTDI(const uint8_t *tx,uint8_t *rx,int len,bool last){if(rx)memset(rx,0,(len+7)/8);for(int i=0;i<len;i++)edge(last&&i==len-1,tx?(tx[i/8]>>(i&7))&1:0);return len;}
static void jtag_toggleClk(int n){for(int i=0;i<n;i++)edge(0,0);}
// WRITER
// TAP
// RESET
uint32_t nano_configuration_checksum=0xa723,model_status=STATUS_DONE_FINAL;
void overlay_status(const char*,...){}
uint32_t readUserCode(){return 0;}
uint32_t readStatusReg(){return model_status;}
// END
int main(){
 uint8_t a[]={0xa5,0x18},b[]={0x81,0x3c};
 jtag_writeTDI_msb_first_gpio_out_mode(a,2,false);assert(physical==SHIFT_DR&&_state==SHIFT_DR);
 jtag_writeTDI_msb_first_gpio_out_mode(b,2,true);assert(physical==EXIT1_DR&&_state==EXIT1_DR);
 assert(data_bits.size()==32&&half_periods==64);
 for(unsigned i=0;i<32;i++)assert(data_bits[i]==(((i<16?a[i/8]:b[i/8-2])>>(7-(i&7)))&1));
 assert(writeSRAM_end());assert(physical==RUN_TEST_IDLE&&_state==RUN_TEST_IDLE);
 assert(instructions==std::vector<unsigned>({0x0a,0x08,CONFIG_DISABLE,NOOP}));
 assert(data_bits.size()==64);
 for(unsigned i=0;i<32;i++)assert(data_bits[32+i]==((nano_configuration_checksum>>i)&1));
 model_status=STATUS_DONE_FINAL|STATUS_CRC_ERROR;
 assert(!writeSRAM_end());model_status=STATUS_DONE_FINAL;
 nano_configuration_checksum=0x8a84;unsigned offset=data_bits.size();
 assert(writeSRAM_end());
 for(unsigned i=0;i<32;i++)assert(data_bits[offset+i]==((nano_configuration_checksum>>i)&1));
 // A failed transfer may leave physical and software TAP states different.
 // The production boot reload must re-synchronize before issuing RELOAD.
 physical=PAUSE_DR;_state=RUN_TEST_IDLE;
 fpgaReset();assert(physical==RUN_TEST_IDLE&&_state==RUN_TEST_IDLE);
 assert(instructions[instructions.size()-2]==RELOAD&&instructions.back()==NOOP);
}
'''.replace('// ENUM',enum).replace('// WRITER',writer).replace('// TAP',tap).replace('// RESET',reset).replace('// END',end)
with tempfile.TemporaryDirectory(prefix='nano-tap-') as tmp:
 p=Path(tmp);(p/'test.cpp').write_text(harness)
 subprocess.run(['clang++','-std=c++17','-Wall','-Wextra','-Wno-unused-function','-Wno-unused-variable','-fsanitize=address,undefined',str(p/'test.cpp'),'-o',str(p/'test')],check=True)
 subprocess.run([str(p/'test')],check=True)
 print('PASS independent JTAG TAP: exact MSB-first chunked payload, final physical/software EXIT1_DR, actual GW2A checksum0A/activation08/CONFIG_DISABLE, both NES/SMS checksums, CRC-failure rejection, and boot recovery from an unsynchronized TAP')
