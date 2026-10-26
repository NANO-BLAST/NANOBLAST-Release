`timescale 1ns/1ps
// Sprite-only rendering, marker-filled OAM, and a full rendered frame.
// No intermediate OAM inspection/address writes; sequential read/writeback
// exercises the same public bus pattern as the historical ROM's evaluator.
module tb_oam_corruption_frame;
reg clk=0;always #5 clk=~clk;
reg ce=0,reset=1,write=0,read=0;
reg [1:0] sys_type=0;
reg [2:0] address=0;
reg [7:0] value=0;
wire [7:0] data;
wire [8:0] scanline,cycle;
PPU dut(.clk(clk),.ce(ce),.reset(reset),.sys_type(sys_type),
 .read(read),.write(write),.ain(address),.din(value),.dout(data),
 .vram_din(8'ha5),.scanline(scanline),.cycle(cycle));
task tick;begin @(posedge clk);#1;@(negedge clk);end endtask
task dot;begin ce=0;repeat(3) tick();ce=1;tick();ce=0;end endtask
task store(input [2:0] a,input [7:0] d);
 begin address=a;value=d;write=1;dot();write=0;end
endtask
task wait_dot(input [8:0] sl,input [8:0] d);
 integer limit;
 begin limit=0;while(scanline!=sl || cycle!=d) begin
  dot();limit=limit+1;if(limit>200000) $fatal(1,"PPU wait timeout");
 end end
endtask
function [7:0] original(input integer a);
 reg [7:0] v;
 begin v=(a==0) ? 8'h00 : 8'hff;original=(a%4==2) ? v&8'he3 : v;end
endfunction
task check_memory(input integer copied_row,input integer source_row);
 integer a,expected_address;
 begin
  for(a=0;a<256;a=a+1) begin
   address=4;read=1;dot();read=0;
   expected_address=(a/8==copied_row) ? source_row*8+a%8 : a;
   if(data!==original(expected_address))
    $fatal(1,"OAM corruption data mismatch at %0d: %h expected %h (row %0d)",a,data,original(expected_address),copied_row);
   store(4,data);
  end
  store(3,0);
 end
endtask
integer mode,a,stop_dot,target_row,source_row;
initial begin
 for(mode=0;mode<1;mode=mode+1) begin
  sys_type=(mode==2) ? 1 : 0;reset=1;dot();dot();reset=0;
  stop_dot=(mode==1) ? 19 : 7;
  target_row=(mode==1) ? 11 : 5;
  source_row=(mode==1) ? 12 : 0;
  store(3,0);for(a=0;a<256;a=a+1) store(4,(a==0) ? 8'h00 : 8'hff);
  store(1,8'h10);wait_dot(511,324);wait_dot(0,stop_dot);store(1,0);repeat(3) dot();
  wait_dot(241,20);store(1,8'h10);repeat(3) dot();
  wait_dot(511,7);wait_dot(241,20);store(1,0);repeat(3) dot();
  // Disable at dot 7 seeds row 5 in this fixed register-port alignment.
  // Row 5 must still contain the marker after the entire rendered frame.
  check_memory(mode==2 ? -1 : target_row,source_row);
 end
 $display("PASS full-frame OAM copy: sprite-only rendering, retained marker and sequential read/writeback");
 $finish;
end
endmodule



