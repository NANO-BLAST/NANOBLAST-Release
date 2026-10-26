`timescale 1ns/1ps
// Exercise primary addresses separately from secondary byte positions.
// All memory/evaluator setup uses register ports and ordinary PPU dots.
module tb_oam_eval;
reg clk=0;always #5 clk=~clk;
reg ce=0,reset_line=1,render=0,ptr_load=0,write=0;
reg [7:0] value=0;
reg [8:0] cycle=340;
wire [7:0] data;
wire sprite0;
reg ppu_reset=1,ppu_write=0,ppu_read=0,ppu_ce=1;
reg [2:0] ppu_address=0;
reg [7:0] ppu_value=0;
wire [8:0] ppu_scanline,ppu_cycle;
wire [7:0] ppu_data;
PPU ppu(.clk(clk),.ce(ppu_ce),.reset(ppu_reset),.sys_type(2'd0),
 .read(ppu_read),.write(ppu_write),.ain(ppu_address),.din(ppu_value),.dout(ppu_data),
 .vram_din(8'ha5),.scanline(ppu_scanline),.cycle(ppu_cycle));
SpriteRAM dut(.clk(clk),.ce(ce),.reset_line(reset_line),.sprites_enabled(render),
`ifdef SPRITERAM_CORRUPTION_PORTS
 .reset(1'b0),.is_pal(1'b1), // Full PPU instance below separately exercises NTSC.
`endif
 .exiting_vblank(1'b0),.obj_size(1'b0),.scanline(9'd0),.cycle(cycle),
 .oam_bus(data),.oam_ptr_load(ptr_load),.oam_load(write),.data_in(value),
 .sprite0(sprite0),.is_vbe(1'b0));
task tick;begin @(posedge clk);#1;@(negedge clk);end endtask
task dot;begin ce=0;repeat(3) tick();ce=1;tick();ce=0;end endtask
task address(input [7:0] a);
 begin value=a;ptr_load=1;dot();ptr_load=0;end
endtask
task store(input [7:0] a,input [7:0] d);
 begin address(a);value=d;write=1;dot();write=0;end
endtask
task clear;
 integer j;
 begin
  render=0;cycle=340;reset_line=1;dot();reset_line=0;
  for(j=0;j<256;j=j+1) store(j[7:0],8'hff);
 end
endtask
task begin_eval(input [7:0] first);
 integer j;
 begin
  reset_line=1;dot();reset_line=0;
  address(first);render=1;
  for(j=0;j<64;j=j+1) begin cycle=j;dot();end
 end
endtask
task ppu_store(input [2:0] a,input [7:0] d);
 begin ppu_address=a;ppu_value=d;ppu_write=1;ppu_dot();ppu_write=0;end
endtask
task ppu_dot;begin ppu_ce=0;repeat(3) tick();ppu_ce=1;tick();ppu_ce=0;end endtask
task ppu_wait(input [8:0] sl,input [8:0] dot);
 integer limit;
 begin limit=0;while(ppu_scanline!=sl || ppu_cycle!=dot) begin
  ppu_dot();limit=limit+1;if(limit>100000) $fatal(1,"PPU wait timeout");
 end end
endtask
integer offset,j;
initial begin
 for(offset=0;offset<4;offset=offset+1) begin
  clear();
  store(32+offset,0);store(33+offset,8'he3);store(34+offset,0);store(35+offset,0);
  begin_eval(32+offset);
  for(j=64;j<260;j=j+1) begin
   cycle=j;dot();
   if(j==71 && dut.oam_ptr!==(36+offset))
    $fatal(1,"in-range X did not preserve misalignment at offset %0d",offset);
   if(j==73 && dut.oam_ptr!==8'd40)
    $fatal(1,"out-of-range Y did not increment/align at offset %0d",offset);
`ifdef OAM_COLUMNS_ONLY
   if(j==256 && data!==0)
`else
   if(j==256 && (sprite0!==1 || data!==0))
`endif
    $fatal(1,"first evaluated sprite flag/Y incorrect at offset %0d",offset);
   if(j==257 && data!==8'he3) $fatal(1,"secondary tile column follows primary alignment");
   if(j==258 && data!==0) $fatal(1,"secondary attribute column incorrect");
   if(j==259 && data!==0) $fatal(1,"secondary X column incorrect");
  end
 end
 // An out-of-range first candidate must not promote a later in-range one.
 clear();store(32,8'h80);store(36,0);store(37,8'he3);store(38,0);store(39,0);
 begin_eval(32);
 for(j=64;j<257;j=j+1) begin cycle=j;dot();end
 if(sprite0!==0) $fatal(1,"later in-range sprite became sprite zero");
 // X is evaluated too: out-of-range X aligns (+1)&FC before next Y.
 clear();store(33,0);store(34,8'he3);store(35,0);store(36,8'h80);
 begin_eval(33);
 for(j=64;j<72;j=j+1) begin cycle=j;dot();end
 if(dut.oam_ptr!==8'd36) $fatal(1,"out-of-range X did not align primary address");
 // Complete PPU: a misaligned first candidate must draw and hit the BG.
 // Bit 4 in the attribute comes from primary X, and must not mark it invalid.
 ppu_reset=0;ppu_store(3,0);
 for(j=0;j<256;j=j+1) ppu_store(4,8'hff);
 ppu_store(3,33);ppu_store(4,4);ppu_store(4,8'he3);ppu_store(4,8'h10);ppu_store(4,0);
 ppu_store(1,8'h1e);ppu_wait(4,60);ppu_store(3,33);
 ppu_wait(5,70);ppu_address=2;ppu_read=1;ppu_dot();
 if(ppu_data[6]!==1) $fatal(1,"misaligned sprite failed full PPU sprite-zero hit: data %h flag %b selected %b bg %h obj %h",ppu_data,ppu.obj0_on_line,ppu.is_obj0_pixel,ppu.bg_pixel,ppu.obj_pixel);
 ppu_read=0;
 $display("PASS OAM evaluation: four alignments, independent secondary columns, first-candidate flag and Y/X address rules");
 $finish;
end
endmodule
