`timescale 1ns/1ps
// Exercise physical chip-select and independent bus drivers, not ROM results.
module tb_io_bus;
reg clk=0;always #5 clk=~clk;
reg reset=1,ce=0,odd=1,rnw=1,mw=0,dma=0,ppu=0,prg=0;
reg [15:0] cpu_addr=16'h8000,addr=16'h8000;
reg [7:0] cpu_dout=0,dbus=0,mem=0;
wire apu_cs;wire [1:0] joyclk;wire [2:0] joyout;
wire [7:0] ext_data,cpu_data,dma_data,apu_data;
wire apu_irq;
NesCpuBus bus(.clk(clk),.reset(reset),.cpu_ce(ce),.odd_or_even(odd),
 .cpu_rnw(rnw),.mw_int(mw),.dma_aout_enable(dma),
 .cpu_addr(cpu_addr),.addr(addr),.cpu_dout(cpu_dout),.dbus(dbus),
 .genie_data(8'b0),.apu_dout(apu_data),.ppu_dout(8'b0),.cpumem_din(mem),
 .prg_dout_mapper(8'b0),.genie_ovr(1'b0),.ppu_cs(ppu),.prg_allow(prg),
 .prg_bus_write(1'b0),.joypad1_data(5'h15),.joypad2_data(5'h0a),
 .apu_cs(apu_cs),.joypad_clock(joyclk),.joypad_out(joyout),
 .from_data_bus(ext_data),.internal_data_bus(cpu_data),.dma_data_bus(dma_data));
APU apu(.MMC5(1'b0),.clk(clk),.PHI2(1'b0),.ce(ce),.reset(reset),
 .cold_reset(reset),.allow_us(1'b0),.PAL(1'b0),.ADDR(addr[4:0]),
 .DIN(dbus),.RW(rnw),.CS(apu_cs),.audio_channels(5'b11111),
 .DmaData(dma_data),.odd_or_even(odd),.DmaAck(1'b0),.DOUT(apu_data),.IRQ(apu_irq));
task tick;begin @(posedge clk);#1;@(negedge clk);end endtask
integer cycle,phase,clock_count=0;
always @(posedge joyclk[0]) if(!reset) clock_count=clock_count+1;
initial begin
 ce=1;tick();ce=0;reset=0;
 // A DMA source in the I/O range must not select the CPU's internal APU
 // while the halted CPU is addressing cartridge ROM.
 addr=16'h4015;dma=1;#1;
 if(apu_cs!==0) $fatal(1,"external DMA address activated internal APU");
 // CPU high address selects APU while DMA supplies the low address bits.
 cpu_addr=16'h4016;addr=16'hc016;prg=1;mem=8'ha8;#1;
 if(apu_cs!==1 || dma_data!==8'hb5 || ext_data!==8'ha8)
  $fatal(1,"DMC/controller driver conflict or external bus isolation incorrect");
 // Direct controller reads retain undriven upper bits of the external bus.
 tick();dma=0;prg=0;addr=16'h4016;#1;
 if(cpu_data!==8'hb5) $fatal(1,"controller upper bits do not follow current bus driver");
 // A DMC get whose low bits match $4016 must not produce a new controller
 // edge when the original CPU read is held continuously.
 clock_count=0;addr=16'h4014;#1;addr=16'h4016;#1;
 dma=1;addr=16'hc016;#1;dma=0;addr=16'h4016;#1;
 if(clock_count!=1) $fatal(1,"DMC matching low address re-clocked controller: %0d",clock_count);
 // Strobe changes are latched on put enable, not arbitrary master clocks
 // or the other CPU phase. Same-edge writes take priority over old latch.
 rnw=0;mw=1;cpu_dout=1;dbus=1;odd=1;tick();
 if(joyout[0]!==0) $fatal(1,"controller strobe changed before put enable");
 ce=1;tick();ce=0;
 if(joyout[0]!==0) $fatal(1,"controller strobe changed on get enable");
 odd=0;ce=1;tick();ce=0;
 if(joyout[0]!==1) $fatal(1,"controller strobe missed put enable");
 cpu_dout=0;dbus=0;ce=1;tick();ce=0;
 if(joyout[0]!==0) $fatal(1,"same-edge controller write used stale latch");
 // D5 of $4015 belongs to the internal latch. An external DMA driver
 // changing D5 must not replace the undriven internal bit.
 ce=0;dma=0;cpu_addr=16'h5000;addr=16'h5000;cpu_dout=8'h20;dbus=8'h20;tick();
 rnw=1;mw=0;cpu_addr=16'h4015;addr=16'hc015;dma=1;prg=1;mem=0;tick();
 dma=0;prg=0;addr=16'h4015;#1;
 if(cpu_data[5]!==1'b1 || ext_data[5]!==1'b0)
  $fatal(1,"internal status D5 followed external DMA bus latch");
 // Run the real frame sequencer, then verify DMA cannot clear IRQ unless
 // the halted CPU's internal I/O decoder permits that read.
 rnw=1;mw=0;dma=0;prg=0;cpu_addr=16'h8000;addr=16'h8000;
 for(cycle=0;cycle<31000 && apu_irq!==1;cycle=cycle+1) begin
  odd=cycle[0]==0;
  for(phase=0;phase<12;phase=phase+1) begin ce=phase==11;tick();end
 end
 ce=0;
 if(apu_irq!==1) $fatal(1,"frame IRQ setup failed");
 // Move past the sequencer's multi-cycle setting window.
 for(cycle=0;cycle<12;cycle=cycle+1) begin
  odd=cycle[0]==0;ce=1;tick();ce=0;
 end
 dma=1;addr=16'h4015;tick();tick();
 if(apu_irq!==1) $fatal(1,"external DMA cleared internal frame IRQ");
 cpu_addr=16'h4016;addr=16'hc015;tick();
 if(apu_irq!==0) $fatal(1,"enabled internal DMA alias failed to acknowledge IRQ");
 $display("PASS CPU I/O: APU decode, controller DMA conflict/edges, put strobe, real frame IRQ isolation");
 $finish;
end
endmodule
