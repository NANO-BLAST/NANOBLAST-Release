`timescale 1ns/1ps
// Drive the complete PPU through register ports and its normal dot counter.
// Internal state is observed to check retention, but never seeded or forced.
module tb_shifter_hold;
reg clk=0;always #5 clk=~clk;
reg ce=1,reset=1,read=0,write=0;
reg [2:0] address=0;
reg [7:0] value=0;
wire [8:0] scanline,cycle;
PPU dut(.clk(clk),.ce(ce),.reset(reset),.sys_type(2'd0),
 .read(read),.write(write),.ain(address),.din(value),.vram_din(8'ha5),
 .scanline(scanline),.cycle(cycle));
task tick;begin @(posedge clk);#1;@(negedge clk);end endtask
task store(input [2:0] a,input [7:0] d);
 begin address=a;value=d;write=1;tick();write=0;end
endtask
task wait_dot(input [8:0] sl,input [8:0] dot);
 integer limit;
 begin limit=0;while(scanline!=sl || cycle!=dot) begin
  tick();limit=limit+1;if(limit>100000) $fatal(1,"PPU dot wait timed out");
 end end
endtask
function [49:0] bg_state;
 begin bg_state={dut.bg_painter.playfield_pipe_1,dut.bg_painter.playfield_pipe_2,
                 dut.bg_painter.playfield_pipe_3,dut.bg_painter.playfield_pipe_4};end
endfunction
reg [49:0] bg_saved;
reg [26:0] sprite_saved;
integer i;
initial begin
 tick();reset=0;
 store(3,0);
 for(i=0;i<256;i=i+1) store(4,8'hff);
 store(3,0);store(4,4);store(4,0);store(4,0);store(4,0);
 store(1,8'h1e);
 wait_dot(4,260);bg_saved=bg_state();
 repeat(25) tick();
 if(bg_state()!==bg_saved) $fatal(1,"background shifters clocked during sprite fetch/HBlank");
 if(dut.obj0_on_line!==1) $fatal(1,"sprite-zero flag not transferred during sprite fetch");
 store(1,0);repeat(2) tick();bg_saved=bg_state();
 wait_dot(5,16);
 if(bg_state()!==bg_saved) $fatal(1,"background state lost while rendering disabled");
 sprite_saved=dut.sprite_gen.sprite0.load_out;
 repeat(32) tick();
 if(dut.sprite_gen.sprite0.load_out!==sprite_saved)
  $fatal(1,"sprite countdown/pixels clocked while rendering disabled");
 if(dut.obj0_on_line!==1) $fatal(1,"sprite-zero transfer lost on disabled line boundary");
 store(1,8'h1e);repeat(5) tick();
 if(bg_state()===bg_saved) $fatal(1,"background shifters did not resume after rendering enable");
 if(dut.sprite_gen.sprite0.load_out===sprite_saved)
  $fatal(1,"sprite pipeline did not resume after rendering enable");
 $display("PASS full PPU shifter hold: HBlank, disabled rendering, fetch sprite-zero flag, resumed clocks");
 $finish;
end
endmodule
