`timescale 1ns/1ps
module controller_tb;
reg clk=0;always #5 clk=~clk;
reg resetn=0;reg[11:0]wanted=0;wire[11:0]buttons;wire strobe,sclk;
reg[15:0]serial=16'hffff;wire data=serial[0];
controller_snes #(.FREQ(27000000)) dut(.clk(clk),.resetn(resetn),.buttons(buttons),.joy_strb(strobe),.joy_clk(sclk),.joy_data(data));
always @(posedge strobe)serial<=~{4'd0,wanted};
always @(posedge sclk)if(!strobe)serial<={1'b1,serial[15:1]};
task check(input[11:0]w);begin
 @(negedge clk);wanted=w;@(posedge strobe);@(negedge strobe);wait(dut.state==3);#1;
 if(buttons!==w)$fatal(1,"pad wanted %03x got %03x",w,buttons);
end endtask
initial begin repeat(10)@(negedge clk);resetn=1;check(0);check(12'h001);check(12'h100);check(12'h080);check(12'h010);check(12'h020);check(12'h040);$display("PASS shared SNES controller rest/B/A/Right/Up/Down/Left");$finish;end
initial begin #50000000;$fatal(1,"controller timeout");end
endmodule
