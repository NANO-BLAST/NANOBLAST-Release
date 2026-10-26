`timescale 1ns/1ps
module tb_dma_cancel;
reg clk=0;always #5 clk=~clk;
reg reset=1,ce=0,odd=0,request=0,cpu_read=1,sprite=0;
wire [15:0] bus_addr;
wire [7:0] write_data;
wire bus_read;
wire ack,pause_cpu,owns_bus;
DmaController dma(.clk(clk),.ce(ce),.reset(reset),.odd_cycle(odd),
 .sprite_trigger(sprite),.dmc_trigger(request),.cpu_read(cpu_read),
 .data_from_cpu(8'h02),.data_from_ram(bus_addr[7:0] ^ 8'ha5),.dmc_dma_addr(16'hc000),
 .aout(bus_addr),.read(bus_read),.data_to_ram(write_data),
 .aout_enable(owns_bus),.dmc_ack(ack),.pause_cpu(pause_cpu));
reg get=0,put=0,write=0;
reg [2:0] regaddr=0;
reg [7:0] value=0;
wire dmc_request,dmc_enabled;
DmcChan dmc(.MMC5(1'b0),.clk(clk),.aclk1(get),.aclk1_d(put),
 .reset(reset),.cold_reset(reset),.ain(regaddr),.DIN(value),.write(write),
 .dma_ack(1'b0),.dma_data(8'b0),.PAL(1'b0),
 .dma_req(dmc_request),.enable(dmc_enabled));
task tick;begin @(posedge clk);#1;@(negedge clk);end endtask
task store(input [2:0] addr,input [7:0] data);
 begin regaddr=addr;value=data;write=1;tick();write=0;end
endtask
task put_tick;begin put=1;tick();put=0;end endtask
task get_tick;begin get=1;tick();get=0;end endtask
integer i;
initial begin
 tick();reset=0;
`ifndef DMA_PIPELINE_ONLY
 // A CPU write must finish before a DMC halt can be accepted.
 request=1;cpu_read=0;ce=1;tick();ce=0;
 if(ack!==0 || owns_bus!==0) $fatal(1,"DMC stole a CPU write cycle");
 cpu_read=1;ce=1;tick();ce=0;
 odd=1;request=0;#1;
 // An accepted transfer has already halted the CPU. Cancelling its fetch
 // must not release RDY early, or acknowledge a nonexistent sample byte.
 for(i=0;i<12;i=i+1) begin
  tick();
  if(pause_cpu!==1 || ack!==0 || owns_bus!==0)
   $fatal(1,"cancelled DMC lost halt or acknowledged nonexistent byte");
 end
 odd=0;#1;
 if(pause_cpu!==1 || ack!==0 || owns_bus!==0)
  $fatal(1,"cancelled DMC performed a get");
 ce=1;tick();ce=0;
 if(pause_cpu!==0 || ack!==0) $fatal(1,"cancelled DMC did not release at completion");
 // A non-cancelled request still gets exactly the intended DMC byte.
 request=1;ce=1;tick();ce=0;odd=1;#1;
 if(ack!==0 || pause_cpu!==1) $fatal(1,"normal DMC halt broken");
 odd=0;#1;
 if(ack!==1 || owns_bus!==1 || bus_addr!==16'hc000 || bus_read!==1)
  $fatal(1,"normal DMC fetch broken");
 ce=1;tick();ce=0;request=0;#1;
 if(ack!==0 || pause_cpu!==0) $fatal(1,"normal DMC completion broken");
 // OAM, with no DMC request: 256 ordered source bytes reach $2004.
 cpu_read=0;sprite=1;ce=1;tick();sprite=0;ce=0;
 cpu_read=1;odd=1;ce=1;tick();ce=0;
 for(i=0;i<256;i=i+1) begin
  odd=0;#1;
  if(owns_bus!==1'b1 || bus_read!==1'b1 || bus_addr!==(16'h0200+i))
   $fatal(1,"OAM source sequence broken at %0d",i);
  ce=1;tick();ce=0;odd=1;#1;
  if(owns_bus!==1'b1 || bus_read!==1'b0 || bus_addr!==16'h2004 || write_data!==(i[7:0]^8'ha5))
   $fatal(1,"OAM destination/data broken at %0d",i);
  ce=1;tick();ce=0;
 end
 if(owns_bus!==1'b0 || pause_cpu!==1'b0) $fatal(1,"OAM failed to release after byte 256");
`endif
 // The DMC's delayed enable pipeline, rather than the live $4015 enable,
 // controls request deassertion. There is no sample buffer/ack in this case.
 store(0,0);store(2,0);store(3,1);store(5,8'h10);
 for(i=0;i<4;i=i+1) begin put_tick();get_tick();end
 if(dmc_request!==1) $fatal(1,"DMC never requested sample");
 store(5,0);
 if(dmc_enabled!==0 || dmc_request!==1)
  $fatal(1,"live enable bypassed delayed DMA request cancellation");
 put_tick();get_tick();put_tick();
 if(dmc_request!==1) $fatal(1,"delayed DMA request cleared early");
 get_tick();
 if(dmc_request!==0) $fatal(1,"delayed DMA request never cleared");
`ifdef DMA_PIPELINE_ONLY
 $display("PASS DMC delayed-enable request cancellation (channel only)");
`else
 $display("PASS DMA: cancellation, write priority, delayed enable, normal DMC and 256 OAM bytes");
`endif
 $finish;
end
endmodule
