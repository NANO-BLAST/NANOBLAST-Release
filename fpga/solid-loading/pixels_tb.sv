`timescale 1ns/1ps
// Actual renderer, deterministic BRAM/font model. Never connects to hardware.
module gowin_dpb_menu(input clka,reseta,ocea,cea,input[10:0]ada,input wrea,input[7:0]dina,output[7:0]douta,
 input clkb,resetb,oceb,ceb,input[10:0]adb,input wreb,input[7:0]dinb,output reg[7:0]doutb);
 reg[7:0]mem[0:2047];integer i;
 initial begin
  for(i=0;i<2048;i=i+1)mem[i]=0;
  for(i=0;i<896;i=i+1)mem[i]=8'h20;
  mem[13*32+8]=65;
  for(i=0;i<8;i=i+1)mem[1024+65*8+i]=8'h81;
 end
 assign douta=0;
 always @(posedge clka)if(cea&&wrea)mem[ada]<=dina;
 always @(posedge clkb)if(ceb)doutb<=mem[adb];
endmodule
module solid_loading_tb;
 reg clk=0,hclk=0,resetn=0;always #8 clk=~clk;always #5 hclk=~hclk;
 reg[3:0]we=0;reg[31:0]command=0;wire[15:0]color;
 textdisp dut(.clk(clk),.hclk(hclk),.resetn(resetn),.overlay_x(11'd0),.overlay_y(10'd0),.overlay_color(color),.reg_char_we(we),.reg_char_di(command));
 integer x,y,mode,checked=0;reg[7:0]sx,sy;reg in_box,lit;reg[15:0]expected;
 task write_word(input[31:0]word);
  begin @(negedge clk);command=word;we=1;@(negedge clk);we=0;repeat(30)@(negedge clk);end
 endtask
 initial begin
  force dut.px=sx;force dut.py=sy;
  force dut.mem_cnt=0;@(negedge hclk);release dut.mem_cnt;
  sx=0;sy=0;repeat(10)@(negedge clk);resetn=1;
  write_word(32'h04200000); // Disable legacy logo, keep normal size.
  for(mode=0;mode<4;mode=mode+1)begin
   write_word((mode==0?32'h03100000:mode==3?32'h03000000:32'h03300000)|(15<<15)|(12<<10)|(29<<5)|2);
   write_word(mode==2?32'h02100000|(15<<15)|(12<<10)|(29<<5)|2:32'h02000000);
   for(y=0;y<224;y=y+1)for(x=0;x<256;x=x+1)begin
    sx=x;sy=y;repeat(12)@(negedge hclk);
    in_box=x>=16&&x<240&&y>=96&&y<128;
    lit=y>=104&&y<112&&x>=64&&x<72&&(x%8==0||x%8==7);
    expected=mode==3?16'd0:in_box?(mode==0?16'd1:16'h8000):16'd0;
    if(lit)expected=in_box&&mode!=3?{1'b1,15'b11011_11011_11111}:16'hffff;
    if(color!==expected)$fatal(1,"mode=%0d pixel=%0d,%0d got=%h expected=%h",mode,x,y,color,expected);
    checked=checked+1;
   end
  end
  $display("PASS %0d renderer pixels: solid black, artwork outside, readable glyphs, translucent menus preserved and panel cleanup",checked);$finish;
 end
 initial begin #100000000;$fatal(1,"Timeout");end
endmodule
