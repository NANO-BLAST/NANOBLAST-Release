`timescale 1ns/1ps
module rtc_tb;
reg clk=0;always #5 clk=~clk;
reg reset=0,resetn=0,ce_cpu=0,ce32=0,wr=0,a15=0,ncs=1;
reg[14:0]addr=0;reg[7:0]data=0;wire[7:0]out;
mbc3 dut(.enable(1'b1),.reset(reset),.mbc30(1'b0),.clk_sys(clk),.ce_cpu(ce_cpu),.savestate_load(1'b0),.savestate_data(16'd0),
 .ce_32k(ce32),.RTC_time(33'd0),.bk_wr(1'b0),.bk_rtc_wr(1'b0),.bk_addr(17'd0),.bk_data(16'd0),.img_size(64'd0),
 .has_ram(1'b1),.ram_mask(3'd3),.rom_mask(8'h7f),.cart_addr(addr),.cart_a15(a15),.cart_mbc_type(8'h10),
 .cart_rd(1'b1),.cart_wr(wr),.cart_di(data),.nCS(ncs),.cram_di(8'hff),.cram_do_b(out));
wire tick;nanoblast_gbc_rtc_tick ticks(clk,resetn,tick);
integer count=0,i,cycles=0,last_tick=0;
reg divider_checked=0;
always @(posedge clk)if(resetn)begin
 cycles=cycles+1;
 if(tick)begin
  count=count+1;
  if(last_tick && (cycles-last_tick<823||cycles-last_tick>824))$fatal(1,"RTC tick spacing");
  last_tick=cycles;
 end
 if(cycles==270000)begin
  if(count!=327)$fatal(1,"RTC rate: %0d",count);
  divider_checked=1;
 end
end
task write_reg(input[15:0]a,input[7:0]v);begin
 @(negedge clk);addr=a[14:0];a15=a[15];ncs=~a[15];data=v;wr=1;ce_cpu=1;
 @(negedge clk);wr=0;ce_cpu=0;
end endtask
task latch;begin write_reg(16'h6000,0);write_reg(16'h6000,1);end endtask
task check(input[7:0]index,input[7:0]value);begin
 write_reg(16'h4000,index);@(negedge clk);addr=15'h2000;a15=1;ncs=0;#1;
 if(out!==value)$fatal(1,"RTC register %h got %h expected %h",index,out,value);
end endtask
initial begin
 repeat(3)@(negedge clk);reset=1;repeat(3)@(negedge clk);reset=0;resetn=1;
 write_reg(0,8'h0a);write_reg(16'h4000,8'h08);write_reg(16'ha000,58);
 write_reg(16'h4000,8'h09);write_reg(16'ha000,59);
 write_reg(16'h4000,8'h0a);write_reg(16'ha000,23);
 write_reg(16'h4000,8'h0b);write_reg(16'ha000,1);
 latch;check(8,58);
 // Free-running RTC must advance even with CPU enables held off (menu pause).
 @(negedge clk);ce32=1;repeat(32768)@(negedge clk);ce32=0;latch;check(8,59);
 // Reads remain latched until the next 0->1 latch write.
 @(negedge clk);ce32=1;repeat(32768)@(negedge clk);ce32=0;check(8,59);
 latch;check(8,0);check(9,0);check(10,0);check(11,2);
 write_reg(16'h4000,12);write_reg(16'ha000,8'h40);
 @(negedge clk);ce32=1;repeat(65536)@(negedge clk);ce32=0;latch;check(8,0);
 // Reset defines the initial clock without a save-file service.
 @(negedge clk);reset=1;repeat(3)@(negedge clk);reset=0;latch;check(8,0);check(12,0);
 while(!divider_checked)@(negedge clk);
 if(ticks.fraction>=27000000)$fatal(1,"RTC divider overflow");
 $display("PASS MBC3 RTC write/latch/tick/day rollover/halt/reset; CPU paused; 27 MHz tick divider");$finish;
end
initial begin #5000000;$fatal(1,"timeout");end
endmodule
