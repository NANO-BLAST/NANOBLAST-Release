"""Check actual load-control, NES dividers and PPU frame counters."""
import argparse,re,subprocess
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True)
p.add_argument('--iverilog',required=True);p.add_argument('--vvp',required=True)
p.add_argument('--memory-phases',action='store_true')
p.add_argument('--background',action='store_true')
a=p.parse_args();repo=Path(__file__).resolve().parents[1]
a.out.mkdir(parents=True,exist_ok=False)
io=(repo/'src/iosys/iosys.v').read_text()
block=re.search(r'always @\(posedge clk\) begin\s+if \(!resetn\) nes_pal.*?\nend',io,re.S)[0]
(a.out/'region_control.sv').write_text('''module region_control(input clk,resetn,romload_reg_ctrl_sel,
input [3:0] mem_wstrb,input [31:0] mem_wdata,output reg nes_pal);
'''+block+'\nendmodule\n')
nes=(repo/'src/nes.v').read_text();start=nes.index('wire [4:0] div_cpu_n')
stop=nes.index('/**********************************************************/',start)
block=nes[start:stop]
# Move declarations only to accommodate Icarus's forward-declaration rules.
decls=['reg [1:0] ppu_tick = 0;','reg [2:0] cpu_tick_count;']
for d in decls:block=block.replace(d,'')
block=block.replace('wire cart_pre  =','assign cart_pre =')
(a.out/'nes_dividers.sv').write_text('''module nes_dividers(input clk,reset,menu_pause,
input [1:0] sys_type,input skip_pixel_input,output cpu_tick_out,ppu_tick_out);
localparam MENU_PAUSE_SUPPORT=1;
reg odd_or_even=1;wire cart_pre;
'''+ '\n'.join(decls)+'\n'+block+'''
assign skip_pixel=skip_pixel_input;
assign cpu_tick_out=cpu_ce;assign ppu_tick_out=ppu_ce;
endmodule
''')
ppu=(repo/'src/ppu.v').read_text();start=ppu.index('module ClockGen')
block=ppu[start:ppu.index('endmodule',start)+len('endmodule')]
block=block.replace('wire skip_pixel =','assign skip_pixel =')
block=block.replace('assign short_frame =','wire skip_pixel;\nassign short_frame =')
(a.out/'ppu_clock.sv').write_text(block)
bench='tb_memory_phases' if a.memory_phases else 'tb_region'
extra=[str(repo/'src/nano20k/config.v'),str(repo/'src/sdram_nes.v')] if a.memory_phases else []
if a.memory_phases:
 top=(repo/'src/nestang_top.sv').read_text()
 start=top.index('always @(posedge clk) begin\n    clkref <= ~clkref;')
 block=top[start:top.index('///////////////////////////',start)]
 (a.out/'reference_clock.sv').write_text('''module reference_clock(input clk,sys_resetn,loading,
 output reg clkref,output reg reset_nes=1);
 reg loading_r;always @(posedge clk)loading_r<=loading;
 '''+block+'\nendmodule\n')
 extra.append(str(a.out/'reference_clock.sv'))
params=['-Ptb_memory_phases.BACKGROUND=1'] if a.background else []
cmd=[a.iverilog,'-g2012','-s',bench,*params,'-o',str(a.out/'test.vvp'),
str(a.out/'region_control.sv'),str(a.out/'nes_dividers.sv'),
str(a.out/'ppu_clock.sv'),*extra,str(repo/'tests'/f'{bench}.sv')]
for name,command in [('compile',cmd),('region',[a.vvp,'-i',str(a.out/'test.vvp')])]:
 r=subprocess.run(command,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True)
 (a.out/(name+'.log')).write_text(r.stdout);print(r.stdout,flush=True)
 if r.returncode:raise SystemExit(r.returncode)
