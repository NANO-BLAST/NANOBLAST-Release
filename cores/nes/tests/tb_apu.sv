`timescale 1ns/1ps
module tb_apu;
reg clk=0;always #5 clk=~clk;
reg reset=1,cs=0,rw=1;
reg [4:0] addr=0; reg [7:0] data=0;
APU dut(.MMC5(1'b0),.clk(clk),.PHI2(1'b0),.ce(1'b0),.reset(reset),
 .cold_reset(reset),.allow_us(1'b0),.PAL(1'b0),.ADDR(addr),.DIN(data),.RW(rw),.CS(cs),
 .audio_channels(5'b11111),.DmaData(8'd0),.odd_or_even(1'b0),.DmaAck(1'b0));
task tick;begin @(posedge clk);#1;@(negedge clk);end endtask
task store(input [4:0] a,input [7:0] d);
 begin addr=a;data=d;cs=1;rw=0;tick();cs=0;rw=1;end endtask
integer a;
initial begin
 tick();reset=0;
 store(5'h10,8'h8a);store(5'h11,8'h35);store(5'h12,8'h57);store(5'h13,8'h69);
 if(dut.Dmc.frequency!==4'ha || dut.Dmc.dmc_volume!==8'h35 ||
    dut.Dmc.sample_address!==8'h57 || dut.Dmc.sample_length!==8'h69)
    $fatal(1,"DMC legal register writes broken");
 // $4014 is OAM DMA, $4016 controller strobe, $4017 frame sequencer.
 for(a=20;a<32;a=a+1) if(a!=21) begin
   store(a[4:0],8'hff);
   if(dut.Dmc.frequency!==4'ha || dut.Dmc.dmc_volume!==8'h35 ||
      dut.Dmc.sample_address!==8'h57 || dut.Dmc.sample_length!==8'h69)
      $fatal(1,"non-DMC write aliased at %h",a+16'h4000);
 end
 store(5'h15,8'h10);
 if(dut.Dmc.enable!==1) $fatal(1,"4015 enable lost");
 store(5'h15,0);if(dut.Dmc.enable!==0) $fatal(1,"4015 disable lost");
 $display("PASS APU DMC write isolation and legal register writes");$finish;
end
endmodule
