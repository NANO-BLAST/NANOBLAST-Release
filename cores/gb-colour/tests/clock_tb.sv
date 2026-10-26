`timescale 1ns/1ps
module clock_tb;
reg clk=0;always #5 clk=~clk;
reg resetn=0,enable=1,ready=1;wire ce,cen,ce2,paused;
nanoblast_gbc_ce dut(clk,resetn,enable,ready,ce,cen,ce2,paused);
integer a=0,b=0,c=0,i;
always @(posedge clk)if(resetn)begin if(ce)a=a+1;if(cen)b=b+1;if(ce2)c=c+1;if(ce&&cen)$fatal(1,"phases overlap");end
initial begin repeat(4)@(posedge clk);@(negedge clk);#1;resetn=1;
 repeat(270000)@(posedge clk);#1;
 if(a<41942||a>41944||b<41942||b>41944||c<83885||c>83887)$fatal(1,"bad GB rate %d/%d/%d",a,b,c);
 @(posedge clk);enable=0;repeat(20)@(posedge clk);#1;if(!paused||ce||ce2||cen)$fatal(1,"pause failed");
 $display("PASS GB/CGB enable rate and menu pause %d/%d/%d",a,b,c);$finish;end
endmodule
