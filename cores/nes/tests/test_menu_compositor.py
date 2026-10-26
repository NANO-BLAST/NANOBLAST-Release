"""Exercise the actual RGB compositor block against independent pixel values."""
import argparse, subprocess
from pathlib import Path
p=argparse.ArgumentParser()
p.add_argument('--out',type=Path,required=True)
p.add_argument('--iverilog',required=True)
p.add_argument('--vvp',required=True)
a=p.parse_args();a.out.mkdir(parents=True,exist_ok=False)
source=(Path(__file__).resolve().parents[1]/'src/nes2hdmi.sv').read_text()
start=source.index('    if (overlay_pixel) begin')
end=source.index('    if (cx == 0)',start)
block=source[start:end]
bench='''`timescale 1ns/1ps
module tb;
reg clk=0;always #5 clk=~clk;
reg overlay_pixel,overlay_active,background_valid;
reg [15:0] overlay_color;
reg [23:0] rgb_nes,background_rgb;
reg [23:0] rgb;
always @(posedge clk) begin
'''+block+'''end
task check(input [23:0] expected);
begin @(posedge clk);#1;if(rgb!==expected)$fatal(1,"RGB got %h expected %h",rgb,expected);
@(negedge clk);end endtask
initial begin
 overlay_pixel=1;overlay_active=1;background_valid=1;
 overlay_color=0;rgb_nes=24'hb07030;
 // Artwork must be unchanged in the middle of the text area and outside it.
 background_rgb=24'hfc8040;check(24'hfc8040);
 background_rgb=24'h010203;check(24'h010203);
 overlay_active=0;check(24'h010203);
 // Only transparent pixels marked as panel are darkened, at half brightness.
 overlay_active=1;overlay_color=16'h0001;check(24'h000101);
 overlay_active=0;check(24'h010203);
 // An opaque BGR5 text glyph still wins, and never leaks outside the area.
 overlay_active=1;overlay_color=16'h83ff;check(24'hf8f800);
 overlay_active=0;check(24'h010203);
 // Preserve the established NES fallback and game output.
 background_valid=0;overlay_color=0;check(24'h2c1c0c);
 overlay_pixel=0;background_valid=1;check(24'hb07030);
 $display("PASS undimmed artwork, opaque glyph priority, text bounds, fallback and game RGB");$finish;
end
endmodule
'''
(a.out/'compositor.sv').write_text(bench)
for command,name in [([a.iverilog,'-g2012','-s','tb','-o',str(a.out/'compositor.vvp'),str(a.out/'compositor.sv')],'compile'),
                     ([a.vvp,str(a.out/'compositor.vvp')],'simulation')]:
    r=subprocess.run(command,capture_output=True,text=True)
    (a.out/(name+'.log')).write_text(r.stdout+r.stderr)
    print(r.stdout+r.stderr,end='')
    if r.returncode:raise SystemExit(r.returncode)
