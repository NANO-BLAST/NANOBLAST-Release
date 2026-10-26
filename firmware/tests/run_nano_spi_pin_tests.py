"""Exercise the actual GPIO writer, TAP state machine and GW2A SPI codec together."""
from pathlib import Path
import subprocess,tempfile
root=Path(__file__).resolve().parents[1]
s=(root/'fpga/programmer.cpp').read_text()
enum=s[s.index('typedef enum tapState_t'):s.index('static int _num_tms')]
tms=s[s.index('static int jtag_writeTMS('):s.index('uint64_t jtag_writetdi_time')]
writer=s[s.index('static int jtag_writeTDI('):s.index('#define GPIO_INT_MASK')]
tap=s[s.index('static int flushTMS('):s.index('// ------------------------------------------------------------\n// Gowin specific:')]
spi=(root/'fpga/nano_persistent.inc').read_text().split('struct NanoBootIO')[0]
harness=r'''
#include <cstdint>
#include <cstring>
#include <cassert>
#include <cstdio>
#include <vector>
// ENUM
static tapState_t _state=RUN_TEST_IDLE;
static int _num_tms=0,_curr_tms=0,_curr_tdi=0;
#define JTAG_TMS_BUFFER_SIZE 128
static unsigned char _tms_buffer[128];
static int physical=RUN_TEST_IDLE;static unsigned instruction=0,ir=0,ir_bits=0;
static bool clock_high=false,tms_pin=false,tdi_pin=false,tdo_pin=true,lag=true;
static std::vector<unsigned> bits;
static std::vector<std::vector<uint8_t>> frames;
static const int next_state[16][2]={{1,0},{1,2},{3,9},{4,5},{4,5},{6,8},{6,7},{4,8},{1,2},{10,0},{11,12},{11,12},{13,15},{13,14},{11,15},{1,2}};
void edge(){
 if(physical==CAPTURE_IR){ir=ir_bits=0;}
 if(physical==SHIFT_IR){ir|=unsigned(tdi_pin)<<ir_bits++;}
 if(physical==UPDATE_IR){if(ir_bits!=8)std::fprintf(stderr,"IR bits=%u ir=%x software=%d frames=%zu\n",ir_bits,ir,int(_state),frames.size());assert(ir_bits==8);instruction=ir;}
 if(physical==SHIFT_DR&&instruction==0x16){
  unsigned pos=bits.size();bits.push_back(tdi_pin);
  uint8_t command=0;for(unsigned i=0;i<8&&i<bits.size();i++)command|=bits[i]<<(7-i);
  bool miso=true;
  if(pos>=8){
   const uint8_t id[]={0xef,0x40,0x17};
   uint8_t data=command==0x9f?id[((pos-8)/8)%3]:0;
   miso=(data>>(7-(pos&7)))&1;
  }
  // Gowin exposes a one-bit read pipeline to the JTAG TDO pin.
  tdo_pin=lag;lag=miso;
 }
 int next=next_state[physical][tms_pin];
 if(next==SHIFT_DR&&physical!=SHIFT_DR){bits.clear();lag=true;}
 if(physical==SHIFT_DR&&next!=SHIFT_DR&&instruction==0x16){
  assert(bits.size()%8==0);std::vector<uint8_t> bytes(bits.size()/8);
  for(unsigned i=0;i<bits.size();i++)bytes[i/8]|=bits[i]<<(7-(i&7));frames.push_back(bytes);
 }
 physical=next;
}
void pin(unsigned p,bool high){if(p==16)tms_pin=high;else if(p==12)tdi_pin=high;else {assert(p==10);if(high&&!clock_high)edge();clock_high=high;}}
#define GPIO_PIN_JTAG_TMS_H() pin(16,true)
#define GPIO_PIN_JTAG_TMS_L() pin(16,false)
#define GPIO_PIN_JTAG_TDI_H() pin(12,true)
#define GPIO_PIN_JTAG_TDI_L() pin(12,false)
#define GPIO_PIN_JTAG_TCK_H() pin(10,true)
#define GPIO_PIN_JTAG_TCK_L() pin(10,false)
struct Register {unsigned p;void operator|=(uint32_t v){assert(v==1u<<25||v==1u<<26);pin(p,v==1u<<25);}};
Register tms{16},tdi{12},tck{10};
Register *reg_gpio_tms=&tms,*reg_gpio_tdi=&tdi,*reg_gpio_tck=&tck;
static void jtag_nano_half_period(){}
static int jtag_read_tdo(){return tdo_pin;}
uint64_t bflb_mtimer_get_time_us(){return 0;}
uint64_t jtag_writetdi_time=0;
// TMS
// WRITER
// TAP
bool send_command(uint8_t command){shiftIR(&command,nullptr,8);jtag_toggleClk(6);return true;}
// SPI
int main(){
 uint8_t id[4]={0x9f,0,0,0},rx[4]={0};
 assert(nano_spi(id,rx,4));assert(rx[1]==0xef&&rx[2]==0x40&&rx[3]==0x17);
 assert(physical==RUN_TEST_IDLE&&_state==RUN_TEST_IDLE);
 assert(frames.back()==std::vector<uint8_t>({0x9f,0,0,0,0}));
 uint8_t status[2]={5,0};assert(nano_spi(status,rx,2)&&rx[1]==0);
 assert(frames.back()==std::vector<uint8_t>({5,0,0}));
 uint8_t wake=0xab;assert(nano_spi(&wake,nullptr,1));
 assert(frames.back()==std::vector<uint8_t>({0xab}));
 uint8_t escape[9];memset(escape,255,sizeof escape);assert(nano_spi(escape,nullptr,9));
 assert(frames.back()==std::vector<uint8_t>(9,255));
 uint8_t en=0x66,reset=0x99;assert(nano_spi(&en,nullptr,1)&&nano_spi(&reset,nullptr,1));
 assert(frames[frames.size()-2]==std::vector<uint8_t>({0x66}));assert(frames.back()==std::vector<uint8_t>({0x99}));
 // Repeat transactions after interface commands without losing TAP alignment.
 assert(nano_spi(id,rx,4)&&rx[1]==0xef&&rx[2]==0x40&&rx[3]==0x17);
 assert(physical==RUN_TEST_IDLE&&_state==RUN_TEST_IDLE);
}
'''.replace('// ENUM',enum).replace('// TMS',tms).replace('// WRITER',writer).replace('// TAP',tap).replace('// SPI',spi)
with tempfile.TemporaryDirectory(prefix='nano-spi-pins-') as tmp:
 p=Path(tmp);(p/'test.cpp').write_text(harness)
 subprocess.run(['clang++','-std=c++17','-Wall','-Wextra','-Wno-unused-function','-Wno-unused-variable','-Wno-sign-compare','-Wno-unused-parameter','-fsanitize=address,undefined',str(p/'test.cpp'),'-o',str(p/'test')],check=True)
 subprocess.run([str(p/'test')],check=True)
 print('PASS actual GPIO + TAP + SPI: byte-exact ID/status/wake/escape/reset commands, one-bit TDO decode, physical/software state agreement across repeated transactions')
