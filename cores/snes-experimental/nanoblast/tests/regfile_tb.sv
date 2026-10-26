`timescale 1ns/1ps
module regfile_tb;
reg clk=0;always #5 clk=~clk;
reg we=0;reg[6:0]wa=0,ra=0;reg[7:0]d=0;wire[7:0]q;
snes_regfile dut(.clk(clk),.we(we),.wr_addr(wa),.rd_addr(ra),.data(d),.q(q));
reg[7:0]model[0:127];reg[127:0]valid=0;reg[7:0]expected;reg check=0;
always @(posedge clk)begin
 expected=model[ra];check=valid[ra];
 if(we)begin model[wa]=d;valid[wa]=1;end
 #1;if(check)assert(q===expected)else $fatal(1,"Register-file read-before-write mismatch");
end
integer n;reg[31:0]rng=32'h392116ab;
initial begin
 for(n=0;n<128;n=n+1)begin @(negedge clk);we=1;wa=7'(n);d=8'(n*7);end
 for(n=0;n<100000;n=n+1)begin
  @(negedge clk);rng=(rng<<1)^(rng[31]?32'h04c11db7:0);
  we=rng[0];wa=rng[7:1];ra=rng[8]?wa:rng[15:9];d=rng[23:16];
 end
 @(negedge clk);we=0;repeat(4)@(negedge clk);
 $display("PASS SNES DSP register file: 100000 random reads/writes, same-address collisions and back-to-back forwarding");$finish;
end
endmodule
