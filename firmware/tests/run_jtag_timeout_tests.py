"""Check real JTAG polling terminates when configuration status never arrives."""
from pathlib import Path
import subprocess,tempfile
root=Path(__file__).resolve().parents[1];s=(root/'fpga/programmer.cpp').read_text()
function=s[s.index('bool pollFlag('):s.index('\nbool enableCfg()')]
code='''#include <cstdint>
#include <cassert>
uint64_t ticks=0;unsigned reads=0;uint32_t status=0;
uint64_t bflb_mtimer_get_time_ms(){return ticks++;}
uint32_t readStatusReg(){++reads;return status;}
'''+function+'''
int main(){
 assert(!pollFlag(0x80,0x80)&&ticks<=502&&reads<=501);
 ticks=0;reads=0;status=0x80;assert(pollFlag(0x80,0x80)&&reads==1);
 ticks=0;reads=0;assert(!pollFlag(0x80,0)&&ticks<=502&&reads<=501);
 ticks=0;reads=0;status=0;assert(pollFlag(0x80,0)&&reads==1);
}
'''
with tempfile.TemporaryDirectory(prefix='nano-timeout-') as tmp:
 p=Path(tmp);(p/'test.cpp').write_text(code)
 subprocess.run(['clang++','-std=c++17','-Wall','-Wextra','-Werror','-fsanitize=address,undefined',str(p/'test.cpp'),'-o',str(p/'test')],check=True)
 subprocess.run([str(p/'test')],check=True)
 print('PASS real JTAG poll: missing enable/disable status terminates within 500ms; matching status returns immediately')
