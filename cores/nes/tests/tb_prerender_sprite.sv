`timescale 1ns/1ps
module tb_prerender_sprite;
reg clk=0;always #5 clk=~clk;
reg reset=1;
reg [1:0] region=0;
wire [8:0] scanline,dot;
PPU dut(.clk(clk),.ce(1'b1),.reset(reset),.sys_type(region),
 .read(1'b0),.write(1'b0),.ain(3'd0),.din(8'd0),.vram_din(8'd0),
 .scanline(scanline),.cycle(dot));
reg [2:0] phase=0;
reg [8:0] physical_line=261;
reg [7:0] temp=5;
wire [3:0] load;
wire [26:0] value;
SpriteAddressGen fetch(.clk(clk),.ce(1'b1),.enabled(1'b1),.obj_size(1'b0),
 .obj_patt(1'b0),.scanline(physical_line),.cycle(phase),.temp(temp),
 .vram_data(8'h81),.load(load),.load_in(value));
task tick;begin @(posedge clk);#1;@(negedge clk);end endtask
task check_row(input [8:0] line_number,input [7:0] y,input valid);
 begin
 physical_line=line_number;temp=y;phase=0;tick();
 phase=1;temp=0;tick();phase=2;tick();phase=5;#1;
 if(load!==8 || value[26:19] !== (valid ? 8'h81 : 8'h00))
  $fatal(1,"incorrect physical pre-render range at line %0d, Y %0d",line_number,y);
 end
endtask
integer r,limit;
initial begin
 tick();
 check_row(261,5,1);check_row(261,6,0);
 check_row(311,55,1);check_row(311,56,0);
 for(r=0;r<3;r=r+1)begin
  reset=1;region=r;tick();reset=0;limit=0;
  while(scanline!=511 || dot!=257)begin
   tick();limit=limit+1;if(limit>110000)$fatal(1,"pre-render wait timeout");
  end
  if(dut.address_gen.scanline !== (r==0 ? 9'd261 : 9'd311))
   $fatal(1,"PPU passed its encoded sentinel instead of the physical pre-render line");
 end
 $display("PASS physical pre-render sprite range: NTSC 261, PAL/Dendy 311");
 $finish;
end
endmodule
