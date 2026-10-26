`timescale 1ns/1ps
// Check the externally visible $4015 status latch, not the LFSR encoding.
// A status read acknowledges IRQ immediately, but status remains latched
// until the next get enable. Extra master clocks must not clear it early.
module tb_frame_irq;
reg clk=0; always #5 clk=~clk;
reg reset=1, get_ce=0, put_phi2=0, rd=0, write_ce=0;
reg [1:0] addr=1;
reg [7:0] din=0;
wire irq, status;
FrameCtr dut(.clk(clk), .aclk1(get_ce), .aclk2(put_phi2),
 .reset(reset), .cold_reset(reset), .write(1'b0), .read(rd),
 .write_ce(write_ce), .din(din), .addr(addr), .PAL(1'b0),
 .MMC5(1'b0), .irq(irq), .irq_flag(status));
task tick; begin @(posedge clk); #1; @(negedge clk); end endtask
task cpu_cycle(input bit is_get);
 integer phase;
 begin
  for(phase=0;phase<12;phase=phase+1) begin
   get_ce=is_get && phase==11;
   put_phi2=!is_get && phase==5;
   tick();
  end
  get_ce=0; put_phi2=0;
 end
endtask
integer cycle, idle;
initial begin
 get_ce=1; tick(); get_ce=0; reset=0;
 // Let the real sequencer reach its first interrupt, then move past the
 // multi-cycle setting window before acknowledging it.
 for(cycle=0;cycle<31000 && irq!==1'b1;cycle=cycle+1)
  cpu_cycle(cycle[0]==0);
 if(irq!==1'b1 || status!==1'b1) $fatal(1,"frame IRQ never asserted");
 rd=1; tick(); rd=0;
 if(irq!==1'b1 || status!==1'b1)
  $fatal(1,"coincident frame event did not win over read acknowledgment");
 for(idle=0;idle<12;idle=idle+1) cpu_cycle(idle[0]==0);
 rd=1; tick(); rd=0;
 if(irq!==1'b0) $fatal(1,"status read did not acknowledge IRQ");
 for(idle=0;idle<24;idle=idle+1) begin
  tick();
  if(status!==1'b1) $fatal(1,"status cleared on master clock before get transition");
 end
 get_ce=1; tick(); get_ce=0;
 if(status!==1'b0) $fatal(1,"status did not clear at get transition");
 reset=1; tick();
 if(irq!==1'b0 || status!==1'b0) $fatal(1,"reset left IRQ/status asserted");
 get_ce=1; tick(); get_ce=0; reset=0;
 addr=3; din=8'h40; write_ce=1; tick(); write_ce=0; addr=1;
 for(cycle=0;cycle<31000 && status!==1'b1;cycle=cycle+1)
  cpu_cycle(cycle[0]==0);
 if(status!==1'b1 || irq!==1'b0)
  $fatal(1,"inhibited IRQ must still expose frame event status");
 $display("PASS frame IRQ acknowledgment, get-phase status latch, event priority, inhibit and reset");
 $finish;
end
endmodule
