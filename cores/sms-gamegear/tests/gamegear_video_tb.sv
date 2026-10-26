`timescale 1ns/1ps
module gamegear_video_tb;
reg clk=0,pclk=0;always #10 clk=~clk;always #7 pclk=~pclk;
reg resetn=0,ce=0,gear=1;reg[7:0]top=24;reg[8:0]x=0,y=0;
reg[11:0]color=0;wire[10:0]ox;wire[9:0]oy;
sms_nano_hdmi dut(.clk(clk),.resetn(resetn),.pixel_resetn(resetn),.clk_pixel(pclk),.clk_5x_pixel(pclk),
 .game_gear(gear),.gamegear_top(top),.ce_pix(ce),.x(x),.y(y),.color(color),.height(9'd144),.audio_l(16'd0),.audio_r(16'd0),
 .overlay(1'b0),.overlay_x(ox),.overlay_y(oy),.overlay_color(16'd0),.background_rgb(24'd0),.background_valid(1'b0),
 .tmds_clk_n(),.tmds_clk_p(),.tmds_d_n(),.tmds_d_p());
function automatic[11:0]pattern(input integer px,py);pattern=(py*160+px)&4095;endfunction
function automatic[23:0]expand(input[11:0]c);expand={{2{c[3:0]}},{2{c[7:4]}},{2{c[11:8]}}};endfunction
integer px,py,i,expected_x,expected_y,checked=0;
initial begin
 repeat(8)@(negedge clk);resetn=1;wait(dut.initialized);
 for(py=0;py<144;py++)for(px=0;px<160;px++)begin
  @(negedge clk);ce=1;x=49+px;y=24+py;color=pattern(px,py);
 end
 @(negedge clk);ce=0;@(negedge clk);
 for(i=0;i<23040;i++)if(dut.frame[i][11:0]!=(i&4095))$fatal(1,"RGB444/crop lost at %d",i);
 // Writes outside the handheld viewport must not alias its image.
 ce=1;x=48;y=24;color=12'hfff;@(negedge clk);x=209;@(negedge clk);x=49;y=23;@(negedge clk);y=168;@(negedge clk);ce=0;
 if(dut.frame[0]!=0)$fatal(1,"Crop alias");
 wait(oy==749&&ox==1648);@(negedge pclk);wait(oy==0&&ox==2);
 for(i=0;i<1650*720-2;i++)begin
  @(negedge pclk);
  if(oy<720&&ox>=239&&ox<1039)begin
   expected_x=(ox-239)/5;expected_y=oy/5;
   if(dut.source_x!=expected_x||dut.source_y!=expected_y)$fatal(1,"GG 5x coordinate %d/%d got %d/%d",ox,oy,dut.source_x,dut.source_y);
  end
  if(oy<720&&ox>=244&&ox<1038)begin
   expected_x=(ox-241)/5;expected_y=oy/5;
   if(dut.rgb!==expand(pattern(expected_x,expected_y)))$fatal(1,"GG RGB444 output %d/%d got %h expected %h",ox,oy,dut.rgb,expand(pattern(expected_x,expected_y)));
   checked++;
  end
  if(oy<720&&(ox<238||ox>1042)&&dut.rgb!==0)$fatal(1,"GG side border not black");
 end
 // The 224-line Game Gear mode centres its 144-line window at source row40.
 top=40;@(negedge clk);ce=1;x=49;y=40;color=12'h159;@(negedge clk);ce=0;@(negedge clk);
 if(dut.frame[0]!=14'h159)$fatal(1,"GG 224-line crop origin");
 $display("PASS GG video: all4096 colours, native160x144 crop, 5x scaling, %d RGB pixels and 224-line origin",checked);$finish;
end
initial begin #80000000;$fatal(1,"GG video timeout");end
endmodule
