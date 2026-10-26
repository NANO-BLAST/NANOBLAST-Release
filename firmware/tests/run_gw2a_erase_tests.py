"""Check production GW2A recovery protocol and keep GW5A workaround separate."""
from pathlib import Path
import subprocess,tempfile
root=Path(__file__).resolve().parents[1];s=(root/'fpga/programmer.cpp').read_text()
constants=s[s.index('#define NOOP'):s.index('typedef enum prog_mode')]
function=s[s.index('bool eraseSRAM()'):s.index('// Returns true if successful\nbool writeSRAM_start')]
code='''#define TANG_NANO20K
#include <cstdint>
#include <vector>
#include <cassert>
#include <algorithm>
'''+constants+'''
constexpr unsigned IDCODE_GW2A_18=0x81b;
uint32_t idcodes[1]={IDCODE_GW2A_18},model_id=IDCODE_GW2A_18,model_status=0;
bool enable_ok=true,poll_ok=true;std::vector<unsigned>commands;
uint32_t idCode(){return model_id;}uint32_t readStatusReg(){return model_status;}
void overlay_cursor(int,int){}void overlay_printf(const char*,...){}void overlay_status(const char*,...){}
void send_command(unsigned c){commands.push_back(c);}void jtag_toggleClk(unsigned){}void sendClkUs(unsigned){}
bool enableCfg(){return enable_ok;}bool disableCfg(){return true;}
bool pollFlag(uint32_t mask,uint32_t v){assert(mask==STATUS_MEMORY_ERASE&&v==mask);return poll_ok;}
'''+function+'''
int main(){
 model_status=STATUS_CRC_ERROR;assert(eraseSRAM());
 std::vector<unsigned>prefix={CONFIG_DISABLE,0,CONFIG_DISABLE,0,CONFIG_ENABLE,RELOAD,NOOP,CONFIG_DISABLE,NOOP,NOOP};
 assert(commands.size()>=prefix.size()&&std::equal(prefix.begin(),prefix.end(),commands.begin()));
 assert(std::find(commands.begin(),commands.end(),0x3f)==commands.end());
 commands.clear();model_status=STATUS_TIMEOUT;assert(eraseSRAM());
 assert(commands[0]==ERASE_SRAM&&std::find(commands.begin(),commands.end(),0x3f)==commands.end());
 commands.clear();model_status=0;enable_ok=false;assert(!eraseSRAM()&&commands.empty());
 enable_ok=true;poll_ok=false;assert(!eraseSRAM());
}
'''
with tempfile.TemporaryDirectory(prefix='gw2a-erase-') as tmp:
 p=Path(tmp);(p/'test.cpp').write_text(code)
 subprocess.run(['clang++','-std=c++17','-Wall','-Wextra','-Werror','-fsanitize=address,undefined',str(p/'test.cpp'),'-o',str(p/'test')],check=True)
 subprocess.run([str(p/'test')],check=True)
 print('PASS production GW2A erase: reference CRC recovery sequence, GW5A-only workaround excluded, configuration/erase failure paths')
