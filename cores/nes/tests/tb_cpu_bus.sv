`timescale 1ns/1ps
// Independent bus rules: writes drive the bus; $4015 is internal and must
// not replace external open bus; its undriven D5 retains the bus value.
module tb_cpu_bus;
reg clk=0; always #5 clk=~clk;
reg reset=1, cpu_ce=0, mw=0, apu_cs=0, prg_allow=0;
reg [7:0] dbus=0, mem=0, status=0;
reg [15:0] addr=16'h5000;
wire [7:0] data;
nes_bus_under_test dut(.clk(clk), .reset(reset), .cpu_ce(cpu_ce),
 .mw_int(mw), .mr_int(!mw), .dbus(dbus), .genie_data(8'b0),
 .apu_dout(status), .ppu_dout(8'b0), .cpumem_din(mem), .prg_dout_mapper(8'b0),
 .genie_ovr(1'b0), .apu_cs(apu_cs), .joypad1_cs(1'b0), .joypad2_cs(1'b0),
 .ppu_cs(1'b0), .prg_allow(prg_allow), .prg_bus_write(1'b0),
 .joypad1_data(5'b0), .joypad2_data(5'b0), .addr(addr), .cpu_data(data));
task tick; begin @(posedge clk); #1; @(negedge clk); end endtask
integer value;
initial begin
 tick(); reset=0;
 prg_allow=1; mem=8'ha9; tick(); prg_allow=0;
 // Every written byte must be visible on a subsequent floating-bus read.
 for(value=0;value<256;value=value+1) begin
  mw=1; dbus=value; tick(); mw=0; #1;
  if(data!==value[7:0]) $fatal(1,"write did not update open bus: wrote %h read %h",value[7:0],data);
 end
 // Read $4015 repeatedly. It exposes APU status, except undriven D5,
 // and does not overwrite the external latch even when status changes.
 for(value=0;value<256;value=value+1) begin
  mw=1; dbus=value; tick(); mw=0;
  apu_cs=1; addr=16'h4015; status=8'hc5; #1;
  if(data!=={2'b11,value[5],5'b00101}) $fatal(1,"4015 undriven bit 5 lost");
  tick(); tick();
  apu_cs=0; addr=16'h5000; #1;
  if(data!==value[7:0]) $fatal(1,"4015 overwrote external open bus");
 end
 // CPU-step edge is not a bus sampling slot (upstream CE contract).
 prg_allow=1; mem=8'h7d; tick();
 cpu_ce=1; mem=8'h12; tick(); prg_allow=0; cpu_ce=0; #1;
 if(data!==8'h7d) $fatal(1,"bus sampled on CPU-step edge");
 $display("PASS CPU bus: all write values, internal status isolation, undriven D5, CE sampling");
 $finish;
end
endmodule
