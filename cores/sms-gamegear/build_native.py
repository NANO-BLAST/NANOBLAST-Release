"""Native macOS Gowin build of the SMS/Game Gear port. No hardware access."""
from pathlib import Path
import os,subprocess,sys,json,hashlib,re,html
P=Path(__file__).resolve().parent;O=P/'build';O.mkdir(exist_ok=True)
sources=[P/'opll.v',*sorted((P/'engine').rglob('*.v')),*sorted((P/'engine').rglob('*.sv')),*sorted((P/'rtl').glob('*.v')),*sorted((P/'rtl').glob('*.sv')),*sorted((P/'shared').rglob('*.v')),*sorted((P/'shared').rglob('*.sv'))]
sdc=O/'gamegear.sdc';sdc.write_text('''create_clock -name sys_clk -period 37.037037 [get_ports {sys_clk}]
create_clock -name main -period 15.432099 [get_nets {clk}]
create_clock -name hclk5 -period 2.693603 [get_nets {hclk5}]
create_generated_clock -name hclk -source [get_nets {hclk5}] -master_clock hclk5 -divide_by 5 [get_nets {hclk}]
set_clock_groups -asynchronous -group [get_clocks {main}] -group [get_clocks {hclk hclk5}]
''')
lines=[f'create_project -force -name sms_gamegear -dir {{{O}/project}} -pn GW2AR-LV18QN88C8/I7 -device_version C',f'cd {{{O}}}','set_device GW2AR-LV18QN88C8/I7 -device_version C']
lines += [f'add_file -type verilog {{{p}}}' for p in sources]
lines += [f'add_file -type cst {{{P}/constraints/board.cst}}',f'add_file -type sdc {{{sdc}}}','set_option -synthesis_tool gowinsynthesis','set_option -top_module sms_nano_top','set_option -verilog_std sysv2017','set_option -output_base_name nanoblast_sms_gg','set_option -rw_check_on_ram 1','set_option -place_option 2','set_option -route_option 1']
lines += [f'set_option -use_{x}_as_gpio 1' for x in ['mspi','sspi','ready','done','i2c','cpu']]
lines += ['set_option -multi_boot 1','set_option -bit_compress 1','run '+('all' if '--all' in sys.argv else 'syn')]
(O/'build-input-sha256.json').write_text(json.dumps({str(p.relative_to(P)):hashlib.sha256(p.read_bytes()).hexdigest() for p in sources+[P/'constraints/board.cst',sdc]},indent=2)+'\n');tcl=O/'build.tcl';tcl.write_text('\n'.join(lines)+'\n')
env={**os.environ,'DYLD_LIBRARY_PATH':'/Applications/GowinIDE.app/Contents/Resources/Gowin_EDA/IDE/lib','DYLD_FRAMEWORK_PATH':'/Applications/GowinIDE.app/Contents/Resources/Gowin_EDA/IDE/lib'}
with (O/'gowin-build.log').open('w') as log:r=subprocess.run(['/Applications/GowinIDE.app/Contents/Resources/Gowin_EDA/IDE/bin/gw_sh',str(tcl)],cwd=O,env=env,stdout=log,stderr=subprocess.STDOUT)
log=(O/'gowin-build.log').read_text();assert r.returncode==0 and 'ERROR ' not in log and 'Cannot open file' not in log, 'Inspect native build log'
print('Native Gowin build complete:',O/'gowin-build.log')
