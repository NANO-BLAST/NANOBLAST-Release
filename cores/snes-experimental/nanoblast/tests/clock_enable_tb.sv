`timescale 1ns/1ps
module clock_enable_tb;
reg clk=0;always #5 clk=~clk;
reg resetn=0,fast=0;wire audio_ce,cart_ce;
reg[31:0]a=0,b=0;reg expected_audio=0,expected_cart=0;
CEGen #(.ACC_WIDTH(22)) audio(.CLK(clk),.RST_N(resetn),.IN_CLK(32'd2147730),.OUT_CLK(32'd411904),.CE(audio_ce));
CEGen #(.ACC_WIDTH(9)) cart(.CLK(clk),.RST_N(resetn),.IN_CLK(32'd216),.OUT_CLK(fast?32'd100:32'd76),.CE(cart_ce));
always @(posedge clk)begin
 if(!resetn)begin a=0;b=0;expected_audio=0;expected_cart=0;end
 else begin
  a=a+411904;b=b+(fast?1000000:760000);expected_audio=0;expected_cart=0;
  if(a>=2147730)begin a=a-2147730;expected_audio=1;end
  if(b>=2160000)begin b=b-2160000;expected_cart=1;end
 end
 #1;
 assert(audio_ce===expected_audio && cart_ce===expected_cart)else $fatal(1,"Clock-enable pulse changed");
end
integer n;reg[31:0]rng=32'h3921abc3;
initial begin
 for(n=0;n<2000000;n=n+1)begin
  @(negedge clk);rng=(rng<<1)^(rng[31]?32'h04c11db7:0);
  resetn=n>4&&rng[15:0]!=16'h3921;fast=rng[3];
 end
 $display("PASS SNES clock enables: two million cycles, both DSP cartridge rates, arbitrary rate changes and resets");$finish;
end
endmodule
