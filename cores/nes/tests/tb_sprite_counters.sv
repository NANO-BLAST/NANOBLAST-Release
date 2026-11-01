`timescale 1ns/1ps
// Exercise pins only: counter clocks, pixel clocks and independent fetch slots.
module tb_sprite_counters;
reg clk=0;always #5 clk=~clk;
reg ce=1, enable=0, count_enable=0, start_count=0;
reg [3:0] load=0;
reg [2:0] load_index=0;
reg [26:0] load_in=0;
wire [26:0] state;
wire [4:0] bits, set_bits;
wire is_zero;
Sprite one(.clk(clk),.ce(ce),.enable(enable),.count_enable(count_enable),
 .start_count(start_count),.load(load),.load_in(load_in),.load_out(state),.bits(bits));
SpriteSet bank(.clk(clk),.ce(ce),.enable(enable),.count_enable(count_enable),
 .start_count(start_count),.load(load),.load_index(load_index),.load_in(load_in),
 .bits(set_bits),.is_sprite0(is_zero));
task tick;begin @(posedge clk);#1;@(negedge clk);end endtask
task fetch(input [2:0] slot,input [7:0] x,input [7:0] plane);
 begin load_index=slot;load_in={plane,8'd0,x,3'd0};load=15;tick();load=0;end
endtask
integer i;
initial begin
 tick();
 for(i=0;i<8;i=i+1)fetch(i,0,0);
 fetch(0,5,8'hff);
 start_count=1;tick();start_count=0;
 count_enable=1;repeat(5)tick();count_enable=0;
 if(state[10:3]!==0 || state[26:19]!==8'hff)
  $fatal(1,"forced blank did not clock X independently of the pixel shifter");
 if(bits[1:0]!==1)$fatal(1,"counter did not enter drawing state at X=0");
 enable=1;tick();enable=0;
 if(state[26:19]!==8'h7f)$fatal(1,"enabled drawing did not shift one pixel");
 // HBlank holds the counter and pixel shifter; loading another slot must
 // not move an already fetched sprite zero to another slot.
 fetch(1,9,8'hff);
 if(!is_zero || set_bits[1:0]!==1)$fatal(1,"partial fetch displaced sprite zero");
 // A loaded X value does not start counting until the dot-339 start pulse.
 fetch(0,20,8'hff);
 if(bits[1:0]!==1)$fatal(1,"fetch incorrectly started the X counter");
 start_count=1;tick();start_count=0;
 if(bits[1:0]!==0)$fatal(1,"counter start pulse did not hide the sprite");
 repeat(8)tick();
 if(state[10:3]!==20)$fatal(1,"HBlank clocked the X counter");
 count_enable=1;repeat(20)tick();
 if(bits[1:0]!==1)$fatal(1,"counter did not resume at the fetched X position");
 $display("PASS sprite counters: forced-blank countdown, frozen pixels, HBlank and independent slots");
 $finish;
end
endmodule
