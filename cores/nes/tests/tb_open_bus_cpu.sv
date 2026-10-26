`timescale 1ns/1ps
// Execute real T65 instructions through the extracted NES bus RTL.
// JMP $4800 leaves $48 (PHA) on open bus. PHA pushes A=$EA; the next
// floating opcode must consequently be $EA (NOP), rather than another PHA.
module tb_open_bus_cpu;
reg clk=0; always #5 clk=~clk;
reg resetn=0;
reg [3:0] divider=0;
wire ce=divider==11;
always @(posedge clk) divider<=ce ? 0 : divider+1'b1;
wire [23:0] address;
wire [7:0] dout, bus_data;
wire rnw, sync;
reg [7:0] mem[0:65535];
wire driven=address[15:13]!=3'b010;
T65 cpu(.Mode(2'b00),.BCD_en(1'b0),.Res_n(resetn),.Enable(ce),.Clk(clk),
 .Rdy(1'b1),.Abort_n(1'b1),.IRQ_n(1'b1),.NMI_n(1'b1),.SO_n(1'b1),
 .R_W_n(rnw),.Sync(sync),.A(address),.DI(rnw ? bus_data : dout),.DO(dout));
nes_bus_under_test bus(.clk(clk),.reset(!resetn),.cpu_ce(ce),
 .mw_int(!rnw),.mr_int(rnw),.dbus(dout),.genie_data(8'b0),
 .apu_dout(8'b0),.ppu_dout(8'b0),.cpumem_din(mem[address[15:0]]),.prg_dout_mapper(8'b0),
 .genie_ovr(1'b0),.apu_cs(1'b0),.joypad1_cs(1'b0),.joypad2_cs(1'b0),
 .ppu_cs(1'b0),.prg_allow(driven),.prg_bus_write(1'b0),
 .joypad1_data(5'b0),.joypad2_data(5'b0),.addr(address[15:0]),.cpu_data(bus_data));
reg saw_pha=0, saw_push=0, saw_nop=0;
always @(posedge clk) if(resetn && ce) begin
 if(!rnw && driven) begin
  mem[address[15:0]]<=dout;
  if(address[15:8]==8'h01 && dout==8'hea) saw_push<=1;
 end
 if(sync && address[15:0]==16'h4800) begin
  if(bus_data!==8'h48) $fatal(1,"floating JMP target did not fetch PHA");
  saw_pha<=1;
 end
 if(sync && address[15:0]==16'h4801) begin
  if(bus_data!==8'hea || !saw_push || !saw_pha)
   $fatal(1,"PHA stack write did not supply next floating opcode: %h",bus_data);
  saw_nop<=1;
 end
end
integer i;
initial begin
 for(i=0;i<65536;i=i+1) mem[i]=0;
 mem['hfffc]=0;mem['hfffd]='h80;
 mem['h8000]='ha9;mem['h8001]='hea; // LDA #$EA
 mem['h8002]='h4c;mem['h8003]=0;mem['h8004]='h48; // JMP $4800
 repeat(120) @(negedge clk);resetn=1;
 for(i=0;i<2000 && !saw_nop;i=i+1) @(negedge clk);
 if(!saw_nop) $fatal(1,"floating execution never completed PHA/NOP sequence");
 $display("PASS real T65 floating-bus execution: JMP, PHA write, subsequent NOP opcode");
 $finish;
end
endmodule
