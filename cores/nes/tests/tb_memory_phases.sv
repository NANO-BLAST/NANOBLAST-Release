`timescale 1ns/1ps
// Exercise the real controller with slow-clock payloads changing EVERY edge,
// faster than CPU/PPU normally change them. This establishes capture-edge
// spacing, not analog delay or SDRAM electrical timing.
module tb_memory_phases #(parameter BACKGROUND=0);
reg fast=0,slow=0;
always #5 fast=~fast;
always #15 slow=~slow;
reg resetn=0,loading=0;wire clkref;
reference_clock ref_clock(.clk(slow),.sys_resetn(resetn),.loading(loading),.clkref(clkref));
reg [21:0] addressA=0,addressB=0;
reg [7:0] dataA=0,dataB=0;
reg readA=0,readB=0,writeA=0,writeB=0;
reg [15:0] sequence_id=0;
time last_slow_launch=0,last_read_return=0;
integer captures=0,returns=0,bg_words=0;time min_out=1000000,min_in=1000000;
wire busy;wire [7:0] outA,outB;tri [31:0] dq;
reg bg_request=0;reg [19:0] bg_address=0;wire bg_ack;
sdram_nes #(.FREQ(6_000_000),.BACKGROUND(BACKGROUND)) ram(
 .clk(fast),.clkref(clkref),.resetn(resetn),.busy(busy),.SDRAM_DQ(dq),
 .addrA(addressA),.weA(writeA),.dinA(dataA),.oeA(readA),.doutA(outA),
 .addrB(addressB),.weB(writeB),.dinB(dataB),.oeB(readB),.doutB(outB),
 .rv_addr(21'd0),.rv_din(16'd0),.rv_ds(2'd0),.rv_req(1'b0),.rv_we(1'b0),
 .bg_enable(BACKGROUND!=0),.bg_req(bg_request),.bg_addr(bg_address),.bg_ack(bg_ack));
always @(posedge slow)begin
 last_slow_launch<=$time;
 if(!resetn || busy)begin readA<=0;readB<=0;writeA<=0;writeB<=0;end
 else begin
  sequence_id<=sequence_id+1;
  addressA<=addressA+4;addressB<=addressB+4;
  dataA<=dataA+1;dataB<=dataB+3;
  if(bg_request==bg_ack && sequence_id[5:0]==0)begin
   bg_request<=~bg_request;bg_address<=bg_address+1280;
  end
  readA<=sequence_id[1:0]==0;writeA<=sequence_id[1:0]==2;
  readB<=sequence_id[1:0]==1;writeB<=sequence_id[1:0]==3;
  if(last_read_return!=0 && $time!=last_read_return)begin
   if($time-last_read_return<min_in)min_in=$time-last_read_return;
   if($time-last_read_return<20)$fatal(1,"return has less than two fast clocks before slow capture");
  end
 end
end
always @(posedge fast)if(resetn && !busy && ram.normal)begin
 if(ram.bg_valid)bg_words=bg_words+1;
 if(ram.cycle[0] && ram.next_port[0]!=0)begin
  captures=captures+1;
  if($time-last_slow_launch<min_out)min_out=$time-last_slow_launch;
  if($time-last_slow_launch<30)$fatal(1,"request capture too early: %0t since slow launch",$time-last_slow_launch);
 end
 if(ram.cycle[4] && ram.oe_latch[0])begin last_read_return<=$time;returns=returns+1;end
end
initial begin
 repeat(8)@(negedge slow);resetn=1;
 wait(!busy);repeat(64)@(negedge slow);
 // Exercise both odd/even-duration reloads, which explicitly force clkref.
 for(integer i=0;i<16;i=i+1)begin
  loading=1;repeat(11+i)@(negedge slow);loading=0;
  repeat(128)@(negedge slow);
 end
 repeat(2048)@(negedge slow);
 if(captures<100 || returns<100)$fatal(1,"insufficient transactions");
 if(BACKGROUND && bg_words<100)$fatal(1,"background traffic was not exercised");
 $display("PASS phase schedule: %0d requests, %0d returns; minimum request %0t, return %0t (fast period 10ns)",captures,returns,min_out,min_in);
 $display("Background words exercised: %0d",bg_words);
 $finish;
end
initial begin #1000000;$fatal(1,"timeout");end
endmodule
