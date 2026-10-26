`timescale 1ns/1ps
// Set up and read memory through the actual OAMDATA/OAMADDR interfaces.
// No memory or evaluator state is forced. Independent address arithmetic
// checks every starting pointer, including wraparound and attribute masking.
module tb_oam_write;
reg clk=0;always #5 clk=~clk;
reg ce=0,reset_line=1,render=0,ptr_load=0,write=0,vbe=1;
reg [7:0] value=0;
reg [8:0] cycle=340;
wire [7:0] data;
SpriteRAM dut(.clk(clk),.ce(ce),.reset_line(reset_line),.sprites_enabled(render),
`ifdef SPRITERAM_CORRUPTION_PORTS
 .reset(1'b0),.is_pal(1'b1), // Isolate write rules from NTSC rendering-transition corruption.
`endif
 .exiting_vblank(1'b0),.obj_size(1'b0),.scanline(9'd10),.cycle(cycle),
 .oam_bus(data),.oam_ptr_load(ptr_load),.oam_load(write),.data_in(value),.is_vbe(vbe));
task tick;begin @(posedge clk);#1;@(negedge clk);end endtask
task pulse;
 begin ce=0;tick();ce=1;tick();ce=0;end
endtask
task address(input [7:0] a);
 begin value=a;ptr_load=1;pulse();ptr_load=0;end
endtask
task store(input [7:0] d);
 begin value=d;write=1;pulse();write=0;end
endtask
function [7:0] expected(input integer a);
 reg [7:0] raw;
 begin raw=a[7:0]^8'ha5;expected=(a%4==2) ? raw&8'he3 : raw;end
endfunction
integer i,j;
reg [7:0] next_pointer;
initial begin
 pulse();pulse();reset_line=0;vbe=0;cycle=100;
 for(i=0;i<256;i=i+1) begin
  address(i[7:0]);store(i[7:0]^8'ha5);
  if(dut.oam_ptr!==((i+1)&255)) $fatal(1,"non-rendering write counter incorrect at %0d",i);
 end
 for(i=0;i<256;i=i+1) begin
  address(i[7:0]);#1;
  if(data!==expected(i)) $fatal(1,"OAM write/read or attribute masking incorrect at %0d",i);
 end
 for(i=0;i<256;i=i+1) begin
  address(i[7:0]);render=1;
  value=8'hff;write=1;ce=0;tick();
  if(dut.oam_ptr!==i[7:0]) $fatal(1,"write advanced pointer without CE");
  ce=1;tick();ce=0;write=0;
  next_pointer=((i/4+1)%64)*4;
  if(dut.oam_ptr!==next_pointer)
   $fatal(1,"rendering write counter incorrect at %0d: got %h expected %h",i,dut.oam_ptr,next_pointer);
  render=0;
  // Read the written row and the following row, covering bytes the write
  // might erroneously target during the look-ahead RAM read.
  for(j=0;j<8;j=j+1) begin
   address((i+j)&255);#1;
   if(data!==expected((i+j)&255)) $fatal(1,"rendering write modified OAM near %0d",i);
  end
 end
 $display("PASS OAMDATA: all 256 pointers, CE gating, rendering suppression/alignment, normal writes/attributes");
 $finish;
end
endmodule
