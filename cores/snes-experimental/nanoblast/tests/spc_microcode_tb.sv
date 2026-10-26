`timescale 1ns/1ps
import spc700::*;
module spc_microcode_tb;
reg clk=0;always #5 clk=~clk;
reg resetn=0,en=0;reg[7:0]ir=0;reg[3:0]state=0;
SpcMCode_r actual,expected;
SPC700_MCode dut(.CLK(clk),.RST_N(resetn),.EN(en),.IR(ir),.STATE(state),.M(actual));
SPC700_MCode_reference refcore(.CLK(clk),.RST_N(resetn),.EN(en),.IR(ir),.STATE(state),.M(expected));
integer op,st,hold_cycle;
initial begin
 repeat(2)@(negedge clk);
 for(op=0;op<256;op=op+1)for(st=0;st<16;st=st+1)begin
  @(negedge clk);ir=8'(op);state=4'(st);en=1;resetn=1;
  @(posedge clk);#1;assert(actual===expected)else $fatal(1,"SPC microcode mismatch opcode=%h state=%h",ir,state);
  @(negedge clk);en=0;ir=~ir;state=~state;
  @(posedge clk);#1;assert(actual===expected)else $fatal(1,"SPC disabled microcode changed");
  @(negedge clk);resetn=0;
  @(posedge clk);#1;assert(actual===expected)else $fatal(1,"SPC reset mismatch");
 end
 $display("PASS SPC700 microcode equivalence: 256 opcodes x 16 states, enable holds and resets");$finish;
end
endmodule
