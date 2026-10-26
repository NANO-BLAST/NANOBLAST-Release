`timescale 1ns/1ps
module gowin_dpb_menu(input clka,reseta,ocea,cea,input[10:0]ada,input wrea,input[7:0]dina,output[7:0]douta,
 input clkb,resetb,oceb,ceb,input[10:0]adb,input wreb,input[7:0]dinb,output reg[7:0]doutb);
reg[7:0]mem[0:2047];integer i;
initial begin
 for(i=0;i<2048;i++)mem[i]=0;
 for(i=0;i<896;i++)mem[i]=8'h20;
 for(i=15;i<=18;i++)mem[i*32+5]=8'h41;
 for(i=2;i<30;i++)mem[26*32+i]=8'h41;
 mem[1024+65*8+0]=8'h81;mem[1024+65*8+1]=8'h42;
 mem[1024+65*8+2]=8'h24;mem[1024+65*8+3]=8'h18;
 mem[1024+65*8+4]=8'h18;mem[1024+65*8+5]=8'h24;
 mem[1024+65*8+6]=8'h42;mem[1024+65*8+7]=8'h81;
end
assign douta=0;
always @(posedge clka)if(cea&&wrea)mem[ada]<=dina;
always @(posedge clkb)if(ceb)doutb<=mem[adb];
endmodule
module games_black_panel_tb;
reg clk=0,pclk=0,resetn=0;
always #8 clk=~clk;always #5 pclk=~pclk;
wire[10:0]ox;wire[9:0]oy;wire[15:0]osd;
reg[3:0]we=0;reg[31:0]command=0;
textdisp text(.clk(clk),.hclk(pclk),.resetn(resetn),.overlay_x(ox),.overlay_y(oy),.overlay_color(osd),.reg_char_we(we),.reg_char_di(command));
sms_nano_hdmi dut(.clk(clk),.resetn(resetn),.pixel_resetn(resetn),.clk_pixel(pclk),.clk_5x_pixel(pclk),
 .ce_pix(1'b0),.x(9'd0),.y(9'd0),.color(12'd0),.height(9'd192),.audio_l(16'd0),.audio_r(16'd0),
 .overlay(1'b1),.overlay_x(ox),.overlay_y(oy),.overlay_color(osd),.background_rgb(24'h123456),.background_valid(1'b1));

reg[10:0]last_x;reg[9:0]last_y;
integer checked=0,black_pixels=0,selected_pixels=0,glyph_pixels=0,art_pixels=0;
integer px,py;reg[7:0]pattern;reg lit,in_panel;reg[23:0]expected;
always @(posedge pclk)begin last_x<=ox;last_y<=oy;end
always @(negedge pclk)if(resetn&&last_x>=257&&last_x<1024&&last_y>=336&&last_y<576)begin
 px=(last_x-257)/3;py=(last_y-24)/3;
 case(py%8)
 0,7:pattern=8'h81;1,6:pattern=8'h42;2,5:pattern=8'h24;default:pattern=8'h18;
 endcase
 lit=(py/8>=15&&py/8<=18&&px/8==5)&&pattern[px%8];
 in_panel=px/8>=1&&px/8<=31&&py/8>=14&&py/8<=20;
 expected=24'h123456;
 if(in_panel)begin
  expected=(py/8==16)?24'h303030:24'h000000;
  if(py/8==16)selected_pixels++;else black_pixels++;
 end else art_pixels++;
 if(lit)begin expected=(py/8==16)?24'h0080f8:24'hf8f8f8;glyph_pixels++;end
 assert(dut.rgb===expected)else $fatal(1,"Panel pixel %0d/%0d got %h expected %h",last_x,last_y,dut.rgb,expected);
 checked++;
end
task write_word(input[31:0]word);
 begin @(negedge clk);command=word;we=1;@(negedge clk);we=0;repeat(20)@(negedge clk);end
endtask
initial begin
 repeat(10)@(negedge clk);resetn=1;
 write_word(32'h04200000|(22<<15)|(15<<10));
 write_word(32'h03300000|(20<<15)|(14<<10)|(31<<5)|1);
 write_word(32'h02100000|(16<<15)|(16<<10)|(31<<5)|1);
 wait(oy==577);
 assert(checked==240*767&&black_pixels>0&&selected_pixels>0&&glyph_pixels>0&&art_pixels>0);
 $display("PASS %0d actual shared-renderer/SMS pixels: solid black panel, grey selection, blue selected and white unselected glyphs, artwork outside",checked);$finish;
end
initial begin #12000000;$fatal(1,"Timeout");end
endmodule
