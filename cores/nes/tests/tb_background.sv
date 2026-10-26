`timescale 1ns/1ps
module tb_background #(parameter STOP_AFTER_FRAMES=3, TIMEOUT_NS=60000000);
 reg clk=0,fclk=0,hclk=0,resetn=0,enable=0,overlay=1;
 always #23.148148 clk=~clk;
 always #7.716049 fclk=~fclk;
 always #6.734007 hclk=~hclk;
 reg [10:0] x=0;reg [9:0] y=720;
 always @(posedge hclk)if(resetn)begin
  if(x==1649)begin x<=0;y<=y==749?0:y+1;end else x<=x+1;
 end
 reg clkref=0;integer phase=0;
 always @(posedge fclk)begin phase<=phase==5?0:phase+1;clkref<=phase>=2 && phase<5;end
 wire [31:0] dq;wire [10:0] a;wire [1:0] ba;wire [3:0] dqm;wire ncs,nras,ncas,nwe,busy;
 wire req,ack,wordvalid,bgen;wire [19:0] addr;wire [31:0] data;wire [8:0] wordno;
 wire [23:0] rgb;wire valid,underflow;
 reg palwe=0;reg [31:0] paldata;
 menu_background display(.clk(clk),.fclk(fclk),.hclk(hclk),.resetn(resetn),.hresetn(resetn),.enable(enable),.overlay(overlay),.oled(1'b0),
  .x(x),.y(y),.palette_we(palwe),.palette_data(paldata),.bg_req(req),.bg_addr(addr),
  .bg_ack(ack),.bg_data(data),.bg_valid(wordvalid),.bg_word(wordno),.bg_enable(bgen),
  .rgb(rgb),.valid(valid),.underflow(underflow));
 reg rv_req=0,rv_write=0;wire rv_ack;wire [15:0] rv_data;
 reg nes_oe=0,nes_we=0,write_turn=0;wire [7:0] nes_data;
 integer traffic_tick=0;
 always @(negedge fclk)if(resetn && !busy)begin
  traffic_tick=traffic_tick+1;
  if(traffic_tick%20==0 && rv_req==rv_ack)begin rv_req=~rv_req;rv_write=!rv_write;end
  if(!enable && ram.bg_idle && ram.cycle[5])begin nes_oe=!write_turn;nes_we=write_turn;write_turn=!write_turn;end
  if(enable)begin nes_oe=0;nes_we=0;end
  if(ram.cycle[1])begin nes_oe=0;nes_we=0;end
 end
 sdram_nes #(.BACKGROUND(1)) ram(.clk(fclk),.resetn(resetn),.clkref(clkref),.busy(busy),
  .SDRAM_DQ(dq),.SDRAM_A(a),.SDRAM_BA(ba),.SDRAM_DQM(dqm),.SDRAM_nCS(ncs),
  .SDRAM_nRAS(nras),.SDRAM_nCAS(ncas),.SDRAM_nWE(nwe),.SDRAM_CKE(),
  .addrA(22'd0),.weA(1'b0),.dinA(8'd0),.oeA(1'b0),.doutA(),
  .addrB(22'd0),.weB(nes_we),.dinB(8'h5a),.oeB(nes_oe),.doutB(nes_data),
  .rv_addr(21'd0),.rv_din(16'h9bdf),.rv_ds(2'b11),.rv_dout(rv_data),
  .rv_req(rv_req),.rv_req_ack(rv_ack),.rv_we(rv_write),
  .bg_enable(bgen),.bg_req(req),.bg_addr(addr),.bg_ack(ack),.bg_data(data),.bg_valid(wordvalid),.bg_word(wordno));
 // Command-level SDRAM fixture with CL2 and independently generated pixels.
 // A physical SDRAM timing/electrical model is still required on hardware.
 reg [10:0] rows[0:3];reg [3:0] opened=0;integer ticks=0,last_pre[0:3],last_act[0:3];
 reg [2:0] rdpipe=0;reg [31:0] dp[0:2];integer last_read=-100;
 assign dq=rdpipe[2]?dp[2]:32'bz;
 function [7:0] pixel(input integer byte_addr);begin pixel=(byte_addr/1280+byte_addr%1280)&255;end endfunction
 integer base;
 always @(negedge fclk)begin
  ticks=ticks+1;rdpipe={rdpipe[1:0],1'b0};dp[2]=dp[1];dp[1]=dp[0];
  if(resetn)case({ncs,nras,ncas,nwe})
   4'b0011:begin
    if(ba==3 && (opened[3] || ticks-last_pre[3]<2))$fatal(1,"Bank3 activate/precharge violation");
    rows[ba]=a;opened[ba]=1;last_act[ba]=ticks;
   end
   4'b0010:begin if(a[10])opened=0;else opened[ba]=0;last_pre[ba]=ticks;end
   4'b0101:begin
    last_read=ticks;
    if(!opened[ba])$fatal(1,"Read from closed bank %0d",ba);
    if(ba==3 && ticks-last_act[3]<2)$fatal(1,"Bank3 tRCD violation");
    base=(rows[ba]*256+a[7:0])*4;
    dp[0]=ba==3?{pixel(base+3),pixel(base+2),pixel(base+1),pixel(base)}:32'h13579bdf;
    rdpipe[0]=1;if(a[10])opened[ba]=0;
   end
   4'b0100:begin
    if(!opened[ba])$fatal(1,"Write to closed bank");
    if(ticks-last_read<3)$fatal(1,"Read/write turnaround violation");
    #1;
    if(ba==0 && dq[7:0]!==8'h5a)$fatal(1,"NES write data contention %h",dq);
    if(ba==2 && dq[15:0]!==16'h9bdf)$fatal(1,"RV write data contention %h",dq);
    if(a[10])opened[ba]=0;
   end
   4'b0001:if(opened!=0)$fatal(1,"Refresh with bank open");
  endcase
 end
 integer i,checked=0,frames=-1;reg [23:0] sample_rgb;reg sample_valid;
 always @(posedge hclk)if(resetn)begin
  // RGB consumed by the compositor at this edge must match current x/y.
  if(y<720 && x<1280 && frames>0)begin
   if(!valid)$fatal(1,"Missing pixel %0d,%0d",x,y);
   if(rgb!=={pixel(y*1280+x),pixel(y*1280+x),pixel(y*1280+x)})
    $fatal(1,"Pixel mismatch %0d,%0d rgb=%h",x,y,rgb);
   checked=checked+1;
  end
  if(y==720 && x==0)begin frames=frames+1;
   if(frames==STOP_AFTER_FRAMES)begin if(underflow)$fatal(1,"Line request underflow");
    $display("PASS two complete 720p frames, exact indexed pixels, CDC line handover, SDRAM row transitions and refresh (%0d pixels)",checked);$finish;end
  end
 end
 initial begin
  for(i=0;i<4;i=i+1)begin last_pre[i]=-100;last_act[i]=-100;end
  repeat(10)@(negedge clk);resetn=1;wait(!busy);
  for(i=0;i<256;i=i+1)begin @(negedge clk);palwe=1;paldata={i[7:0],i[7:0],i[7:0],i[7:0]};end
  @(negedge clk);palwe=0;enable=1;
 end
 initial begin #TIMEOUT_NS;$fatal(1,"Timeout");end
endmodule
