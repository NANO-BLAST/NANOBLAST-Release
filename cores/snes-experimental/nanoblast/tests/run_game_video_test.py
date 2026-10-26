"""Exercise the production SNES HDMI compositor; only HDMI timing/serializer is a stub."""
from pathlib import Path
import subprocess
root=Path(__file__).resolve().parents[2];base=root.parent.parent
out=base/'outputs/snes-game-video-test';out.mkdir(exist_ok=True)
stub=r'''`timescale 1ns/1ps
module hdmi #(parameter VIDEO_ID_CODE=4,DVI_OUTPUT=0,VIDEO_REFRESH_RATE=60.0,IT_CONTENT=1,AUDIO_RATE=32000,AUDIO_BIT_WIDTH=16,START_X=0,START_Y=0)(
 input clk_pixel_x5,clk_pixel,clk_audio,reset,reset_serializer,input[23:0]rgb,
 input[15:0]audio_sample_word[1:0],output[2:0]tmds,output tmds_clock,
 output reg[10:0]cx=0,output reg[9:0]cy=0,output[10:0]frame_width,output[9:0]frame_height);
 assign tmds=0;assign tmds_clock=0;assign frame_width=1280;assign frame_height=720;
endmodule
module ELVDS_OBUF(input I,output O,OB);assign O=I;assign OB=~I;endmodule
module video_tb;
reg clk=0,pixel=0;always #23.148 clk=~clk;always #6.734 pixel=~pixel;
reg resetn=0,overlay=0;reg[15:0]text_color=0;reg[23:0]art=24'h406080;reg art_valid=1;
snes2hdmi dut(.clk(clk),.resetn(resetn),.pixel_resetn(resetn),.serializer_resetn(resetn),
 .dotclk(1'b0),.hblank(1'b1),.vblank(1'b1),.rgb5(15'd0),.xs(9'd0),.ys(9'd0),
 .overlay(overlay),.overlay_color(text_color),.background_rgb(art),.background_valid(art_valid),
 .audio_l(16'd0),.audio_r(16'd0),.audio_ready(1'b0),.snes_refresh(1'b0),
 .clk_pixel(pixel),.clk_5x_pixel(pixel),.locked(1'b1));
integer i;
task settle;begin repeat(3)@(negedge pixel);end endtask
initial begin
 #1;for(i=0;i<4096;i++)dut.mem[i]=15'h03e0;
 settle();resetn=1;dut.hdmi.cx=256;dut.hdmi.cy=24;settle();
 assert(dut.mem_portB_rdata==15'h03e0)else $fatal(1,"Game line RAM did not reach compositor");
 assert(dut.rgb==24'h00f800)else $fatal(1,"Visible game pixel black: active=%b delayed=%b rgb=%h",dut.active,dut.r_active,dut.rgb);
 dut.hdmi.cx=0;settle();assert(dut.rgb==0)else $fatal(1,"Game blanking");
 dut.hdmi.cx=256;overlay=1;settle();assert(dut.rgb==art)else $fatal(1,"Menu artwork");
 text_color=16'hffff;settle();assert(dut.rgb==24'hf8f8f8)else $fatal(1,"Menu glyph");
 text_color=0;overlay=0;settle();assert(dut.rgb==24'h00f800)else $fatal(1,"Return from menu to gameplay");
 $display("PASS actual SNES HDMI wrapper: visible game line RAM pixels, blanking, artwork, glyph and menu-to-game transition");$finish;
end
endmodule
'''
(out/'video_tb.sv').write_text(stub)
cmd=[str(base/'work/oss-cad-suite/bin/verilator'),'--binary','--timing','--assert','-Wno-fatal','--top-module','video_tb','--Mdir',str(out/'obj'),'-j','4',str(root/'src/snes2hdmi_nano.v'),str(root/'src/dual_clk_fifo.v'),str(out/'video_tb.sv')]
with (out/'build.log').open('w') as log:subprocess.run(cmd,stdout=log,stderr=subprocess.STDOUT,check=True)
with (out/'run.log').open('w') as log:subprocess.run([str(out/'obj/Vvideo_tb')],cwd=out,stdout=log,stderr=subprocess.STDOUT,check=True)
print((out/'run.log').read_text())
