"""Independent asset-loader and full-frame background regressions."""
import argparse,json,subprocess
from pathlib import Path
p=argparse.ArgumentParser()
p.add_argument('--out',type=Path,required=True)
p.add_argument('--host-cc',required=True)
p.add_argument('--iverilog',required=True)
p.add_argument('--vvp',required=True)
a=p.parse_args();repo=Path(__file__).resolve().parents[1]
a.out=a.out.resolve();a.out.mkdir(parents=True,exist_ok=False)
def run(command,name):
 r=subprocess.run(list(map(str,command)),stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True)
 (a.out/(name+'.log')).write_text(r.stdout);print(r.stdout,flush=True)
 if r.returncode:raise SystemExit(r.returncode)
run([a.host_cc,'-std=c11','-O1','-fno-builtin','-DBACKGROUND_HOST_TEST','-I'+str(repo/'firmware'),
 repo/'firmware/background.c',repo/'firmware/tests/background_test.c','-o',a.out/'loader.exe'],'loader_compile')
run([a.out/'loader.exe',repo/'firmware/background/compiled/background.nbbg'],'loader')
run([a.iverilog,'-g2012','-s','tb_background','-o',a.out/'scanout.vvp',repo/'src/nano20k/config.v',
 repo/'src/sdram_nes.v',repo/'src/menu_background.sv',repo/'tests/tb_background.sv'],'scanout_compile')
run([a.vvp,'-i',a.out/'scanout.vvp'],'scanout')
top=(repo/'src/nestang_top.sv').read_text()
start=top.index('localparam RV_IDLE_REQ0')
block=top[start:top.index('iosys #(',start)]
(a.out/'rv_bridge.v').write_text('''module rv_bridge_under_test(
input clk,sys_resetn,rv_valid,input [3:0] rv_wstrb,input rv_req_ack,input [15:0] rv_dout,
output reg rv_req,rv_word,rv_ready,output reg [1:0] rv_ds,output [31:0] rv_rdata);
reg rv_valid_r,rv_new_req;reg [15:0] rv_dout0;
assign rv_rdata={rv_dout,rv_dout0};
'''+block+'\nendmodule\n')
run([a.iverilog,'-g2012','-s','tb_background_mapping','-o',a.out/'mapping.vvp',
 repo/'src/nano20k/config.v',repo/'src/sdram_nes.v',a.out/'rv_bridge.v',
 repo/'tests/tb_background_mapping.sv'],'mapping_compile')
run([a.vvp,'-i',a.out/'mapping.vvp'],'mapping')
(a.out/'results.json').write_text(json.dumps({'asset_loader_host':'PASS',
 'two_complete_720p_frames':'PASS','concurrent_RV_reads_writes':'PASS',
 'SDRAM_command_timing_and_refresh':'PASS','900_row_RV_bank_mapping':'PASS',
 'physical_SDRAM_model':'not included',
 'hardware_validation':'pending'},indent=2)+'\n')
