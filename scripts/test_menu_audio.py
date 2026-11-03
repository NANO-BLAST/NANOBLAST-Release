"""Simulate the production NES-to-HDMI sample expression across menu/DMA states."""
from pathlib import Path
import argparse,re,subprocess,tempfile
p=argparse.ArgumentParser();p.add_argument('--iverilog',default='iverilog');p.add_argument('--vvp',default='vvp');a=p.parse_args()
r=Path(__file__).resolve().parents[1];s=(r/'cores/nes/src/nestang_top.sv').read_text();s=s[s.index('nes2hdmi u_hdmi'):];expression=re.search(r'\.sample\((.*?)\),\s*\n',s,re.S)[1]
with tempfile.TemporaryDirectory(prefix='nanoblast-audio-') as d:
 d=Path(d);bench=d/'audio.sv';exe=d/'audio.vvp'
 bench.write_text('''module tb;
reg overlay,menu_paused,reset_nes,loading;reg[15:0]sample;
wire[15:0]out='''+expression+''';
integer mode,v;
initial begin
for(mode=0;mode<16;mode=mode+1)begin
 {overlay,menu_paused,reset_nes,loading}=mode;
 for(v=0;v<65536;v=v+1)begin
  sample=v;#1;
  if(mode!=0 && out!==16'd0)$fatal(1,"Audio leaked in menu, DMA transition, reset or loading: %0d",mode);
  if(mode==0 && out!==(sample>>1))$fatal(1,"Game audio changed");
 end
end
// Before this fix, opening artwork DMA with overlay=1 and menu_paused=0
// passed sample>>1. Exercise that exact regression with a nonzero sample.
overlay=1;menu_paused=0;reset_nes=0;loading=0;sample=16'h7fff;#1;
if(out!==0)$fatal(1,"Artwork-update buzz regression");
$display("PASS production HDMI audio mux: all samples, 16 states, DMA-update mute, game passthrough");$finish;
end
endmodule
''')
 subprocess.run([a.iverilog,'-g2012','-s','tb','-o',str(exe),str(bench)],check=True)
 subprocess.run([a.vvp,str(exe)],check=True)
