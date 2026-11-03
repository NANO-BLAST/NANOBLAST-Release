`timescale 1ns/1ps
module fir_equivalence_tb;
reg clk=0;always #5 clk=~clk;
reg rst=1,sample=0;
reg signed[15:0]l_in=0,r_in=0;
wire signed[15:0]l_out,r_out,ref_l,ref_r;
jtframe_fir #(.COEFFS("fir_192k_4k.hex")) dut(.*);
jtframe_fir_reference #(.COEFFS("fir_192k_4k.hex")) ref_dut(
 .rst(rst),.clk(clk),.sample(sample),.l_in(l_in),.r_in(r_in),.l_out(ref_l),.r_out(ref_r));
reg[31:0]random_state=32'h712f3d8a;
integer n,j,checks=0;
always @(posedge clk)begin
 #1;assert(l_out===ref_l && r_out===ref_r)else $fatal(1,"FIR mismatch at cycle %0d: %h/%h versus %h/%h",checks,l_out,r_out,ref_l,ref_r);
 checks=checks+1;
end
initial begin
 repeat(4)@(negedge clk);rst=0;
 for(n=0;n<128;n=n+1)begin
  random_state=(random_state<<1)^((random_state[31])?32'h04c11db7:0);
  sample=1;l_in=random_state[15:0];r_in=random_state[31:16];
  @(negedge clk);sample=0;
  // Include interrupted filter calculations and normal 192-kHz spacing.
  for(j=0;j<(n%7==0?47:262);j=j+1)@(negedge clk);
  if(n==63)begin rst=1;repeat(3)@(negedge clk);rst=0;end
 end
 repeat(300)@(negedge clk);
 $display("PASS FIR equivalence: %0d cycles, 128 stereo samples, interrupted MACs and reset; exact upstream outputs",checks);
 $finish;
end
endmodule
