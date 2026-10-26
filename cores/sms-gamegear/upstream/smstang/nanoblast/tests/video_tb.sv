`timescale 1ns/1ps
module video_tb;
reg clk=0,pclk=0;always #10 clk=~clk;always #7 pclk=~pclk;
reg resetn=0,ce=0,overlay=0,bg_valid=0;reg[8:0]x=0,y=0,height=192;
reg[11:0]color=0;reg[15:0]osd=0;reg[23:0]bg=24'h804020;
wire[10:0]ox;wire[9:0]oy;
sms_nano_hdmi dut(.clk(clk),.resetn(resetn),.pixel_resetn(resetn),.clk_pixel(pclk),.clk_5x_pixel(pclk),
 .ce_pix(ce),.x(x),.y(y),.color(color),.height(height),.audio_l(16'd0),.audio_r(16'd0),
 .overlay(overlay),.overlay_x(ox),.overlay_y(oy),.overlay_color(osd),.background_rgb(bg),.background_valid(bg_valid),
 .tmds_clk_n(),.tmds_clk_p(),.tmds_d_n(),.tmds_d_p());
function automatic[23:0]rgb222(input[5:0]v);rgb222={{4{v[1:0]}},{4{v[3:2]}},{4{v[5:4]}}};endfunction
reg[11:0]legacy[0:12];
integer i,mode,expected_x,expected_y,checked=0;
initial begin
 legacy[0]=12'h4A2;
 legacy[1]=12'h7E6;
 legacy[2]=12'hF55;
 legacy[3]=12'hF88;
 legacy[4]=12'h55D;
 legacy[5]=12'hFF4;
 legacy[6]=12'h55F;
 legacy[7]=12'h88F;
 legacy[8]=12'h5DD;
 legacy[9]=12'h8DE;
 legacy[10]=12'h4B2;
 legacy[11]=12'hA6B;
 legacy[12]=12'hBBB;
 repeat(8)@(negedge clk);resetn=1;wait(dut.initialized);
 for(i=0;i<64;i=i+1)begin
  @(negedge clk);ce=1;x=i+1;y=0;color={{2{i[5:4]}},{2{i[3:2]}},{2{i[1:0]}}};
 end
 for(i=0;i<13;i=i+1)begin @(negedge clk);ce=1;x=65+i;y=0;color=legacy[i];end
 @(negedge clk);ce=0;
 for(mode=0;mode<3;mode=mode+1)begin
  height=mode==0?192:mode==1?224:240;
  wait(oy==749&&ox==1648);@(negedge pclk);
  wait(oy==0&&ox==2);
  for(i=0;i<1650*720-2;i=i+1)begin
   @(negedge pclk);
   if(oy<720&&ox>=159&&ox<1119)begin
    expected_x=(ox-159)*256/960;expected_y=oy*height/720;
    assert(dut.source_x==expected_x&&dut.source_y==expected_y)
      else $fatal(1,"Scaler mode %0d cx=%0d cy=%0d got %0d/%0d expected %0d/%0d",height,ox,oy,dut.source_x,dut.source_y,expected_x,expected_y);
    checked=checked+1;
   end
   if(mode==0&&oy==0&&ox>=164&&ox<398)
    assert(dut.rgb===rgb222((ox-161)*256/960))else $fatal(1,"RGB222 palette/scanout at x=%0d: %h",ox,dut.rgb);
  end
 end
 for(i=0;i<13;i=i+1)assert(dut.decode_color(dut.encode_color(legacy[i]))=={{2{legacy[i][3:0]}},{2{legacy[i][7:4]}},{2{legacy[i][11:8]}}})else $fatal(1,"Legacy TMS palette loss");
 // Whole-frame artwork and selection/diagnostics/glyph layering.
 force dut.cx=500;force dut.cy=100;overlay=1;bg_valid=1;osd=16'h8000|16'h7fff;
 repeat(30)@(negedge pclk);assert(dut.rgb==24'hf8f8f8)else $fatal(1,"White glyph priority");
 osd=2;repeat(3)@(negedge pclk);assert(dut.rgb==24'h402010)else $fatal(1,"Selection darkening");
 osd=3;repeat(3)@(negedge pclk);assert(dut.rgb==24'h201008)else $fatal(1,"Nested highlight");
 osd=0;repeat(3)@(negedge pclk);assert(dut.rgb==bg)else $fatal(1,"Artwork outside menu panel");
 force dut.cx=100;osd=2;repeat(3)@(negedge pclk);assert(dut.rgb==bg)else $fatal(1,"Highlight leaked outside text window");
 $display("PASS video: %0d scaler coordinates over 192/224/240-line frames, 64 SMS colors, full artwork, white glyph and translucent selection",checked);$finish;
end
initial begin #100000000;$fatal(1,"Video timeout");end
endmodule
module hdmi #(parameter VIDEO_ID_CODE=4,DVI_OUTPUT=0,VIDEO_REFRESH_RATE=60.0,IT_CONTENT=1,AUDIO_RATE=48000,AUDIO_BIT_WIDTH=16,START_X=0,START_Y=0)
(input clk_pixel_x5,clk_pixel,clk_audio,input[23:0]rgb,input reset,reset_serializer,input[15:0]audio_sample_word[1:0],
output[2:0]tmds,output tmds_clock,output reg[10:0]cx=0,output reg[9:0]cy=0,output[10:0]frame_width,output[9:0]frame_height);
assign tmds=0;assign tmds_clock=clk_pixel;assign frame_width=1650;assign frame_height=750;
always @(posedge clk_pixel)if(reset)begin cx<=0;cy<=0;end else if(cx==1649)begin cx<=0;cy<=cy==749?0:cy+1'b1;end else cx<=cx+1'b1;
endmodule
module ELVDS_OBUF(input I,output O,OB);assign O=I;assign OB=!I;endmodule
