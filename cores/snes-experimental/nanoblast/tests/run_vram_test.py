"""Exercise both production VRAM byte lanes against an independent SDRAM model."""
from pathlib import Path
import subprocess

root = Path(__file__).resolve().parents[2]
base = root.parent.parent
out = base / 'outputs/snes-vram-transfer-test'
out.mkdir(exist_ok=True)
tb = (root / 'nanoblast/tests/sdram_tb.sv').read_text()
tb = tb.replace('module sdram_tb;', 'module vram_tb;')
tb = tb.replace('reg menu_mode=1', '''reg [1:0] reference_phase=0;
reg reference_pulse=0,use_clockref=0,pause_clockref=0;
initial begin use_clockref=$test$plusargs("clockref");pause_clockref=$test$plusargs("pauseclockref");end
// CPU DOT_CLK_CE is one master-clock pulse every four master clocks.
always @(posedge mclk)if(!pause_clockref||(!menu_mode&&!busy))begin
 reference_phase<=reference_phase+1'b1;reference_pulse<=reference_phase==2;
end
reg menu_mode=1''')
tb = tb.replace(".clkref(1'b0)", ".clkref(use_clockref?reference_pulse:1'b0)")
tb = tb.replace('available_cycle[ba]=cycle+5;', 'available_cycle[ba]=cycle+4;')
tb = tb.replace('$fatal(1,"Refresh before auto-precharge complete")', '$fatal(1,"Refresh before auto-precharge complete bank=%0d cycle=%0d available=%0d vram_write=%b",i,cycle,available_cycle[i],dut.we_latch[2])')
tb = tb.replace('reg menu_mode=1', '''reg [14:0] va1=0,va2=0;
reg [7:0] vd1=0,vd2=0;
reg vr1=0,vr2=0,vw1=0,vw2=0;
wire vk1,vk2;wire [7:0] vq1,vq2;
reg menu_mode=1''')
for index in (1, 2):
    for field, old, new in [('addr', "15'd0", f'va{index}'),
                            ('din', "8'd0", f'vd{index}'),
                            ('dout', '', f'vq{index}'),
                            ('req', "1'b0", f'vr{index}'),
                            ('ack', '', f'vk{index}'),
                            ('we', "1'b0", f'vw{index}')]:
        tb = tb.replace(f'.vram{index}_{field}({old})', f'.vram{index}_{field}({new})')
task = '''
task video_access(input bit writing,input [14:0] a1,a2,input [7:0] d1,d2,
                  input [7:0] expected1,expected2);
 integer waited;
 begin
  @(negedge mclk);#1;
  va1=a1;va2=a2;vd1=d1;vd2=d2;vw1=writing;vw2=writing;
  vr1=~vr1;vr2=~vr2;waited=0;
  while(vk1!=vr1||vk2!=vr2)begin
   @(posedge clk);#1;waited++;
   if(waited>100)$fatal(1,"VRAM ack timeout");
  end
  // The controller acknowledges at CAS; returned pixels arrive three clocks later.
  repeat(8)@(posedge clk);#1;
  if(!writing)assert(vq1===expected1&&vq2===expected2)
   else $fatal(1,"VRAM mismatch addresses %h/%h expected %h/%h got %h/%h",a1,a2,expected1,expected2,vq1,vq2);
 end
endtask
'''
tb = tb.replace('integer elapsed,n,line;', task + '\ninteger elapsed,n,line;')
# Each word has distinguishable bitplanes. Cover combined 16-bit accesses,
# independent lane writes, SDRAM halfword/row boundaries and the full VRAM range.
stimulus = '''
 menu_mode=0;
 for(n=0;n<256;n++)begin
  video_access(1,15'(n*127),15'(n*127),8'(n^8'h35),8'(n^8'hca),0,0);
 end
 for(n=0;n<256;n++)begin
  video_access(0,15'(n*127),15'(n*127),0,0,8'(n^8'h35),8'(n^8'hca));
 end
 for(n=0;n<256;n++)begin
  video_access(1,15'(n*127),15'((255-n)*127),8'(n^8'h96),8'(n^8'h69),0,0);
 end
 for(n=0;n<256;n++)begin
  video_access(0,15'(n*127),15'(n*127),0,0,8'(n^8'h96),8'((255-n)^8'h69));
 end
 menu_mode=1;
'''
tb = tb.replace('// Check artwork upload', stimulus + '\n // Check artwork upload')
tb = tb.replace('#1000000;', '#5000000;')
tb = tb.replace('PASS SNES SDRAM:', 'PASS both VRAM lanes: combined/split accesses, 256 addresses, bitplanes, row boundaries, plus')
(out / 'vram_tb.sv').write_text(tb)
cmd = [str(base / 'work/oss-cad-suite/bin/verilator'), '--binary', '--timing', '--assert',
       '-Wno-fatal', '--top-module', 'vram_tb', '-j', '4', '--Mdir', str(out / 'obj'),
       str(root / 'src/sdram_nano.v'), str(out / 'vram_tb.sv')]
with (out / 'build.log').open('w') as log:
    subprocess.run(cmd, cwd=base, stdout=log, stderr=subprocess.STDOUT, check=True)
with (out / 'run.log').open('w') as log:
    subprocess.run([str(out / 'obj/Vvram_tb')], cwd=base, stdout=log, stderr=subprocess.STDOUT, check=True)
with (out / 'run-clockref.log').open('w') as log:
    subprocess.run([str(out / 'obj/Vvram_tb'), '+clockref'], cwd=base, stdout=log, stderr=subprocess.STDOUT, check=True)
with (out / 'run-paused-clockref.log').open('w') as log:
    subprocess.run([str(out / 'obj/Vvram_tb'), '+clockref', '+pauseclockref'], cwd=base, stdout=log, stderr=subprocess.STDOUT, check=True)
print((out / 'run.log').read_text())
print((out / 'run-clockref.log').read_text())
print((out / 'run-paused-clockref.log').read_text())
