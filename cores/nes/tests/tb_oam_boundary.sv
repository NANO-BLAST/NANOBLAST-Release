`timescale 1ns/1ps
// Independent phase contract: primary OAMADDR is cleared during sprite
// fetches, then survives refresh and secondary-OAM clearing. All stimulus
// uses ports; the evaluator and memories are never seeded hierarchically.
module tb_oam_boundary;
reg clk=0;always #5 clk=~clk;
reg ce=0,reset_line=1,render=0,ptr_load=0,write=0;
reg [7:0] value=0;
reg [8:0] cycle=340,scanline=511;
wire [7:0] data;
SpriteRAM dut(.clk(clk),.ce(ce),.reset_line(reset_line),.sprites_enabled(render),
`ifdef SPRITERAM_CORRUPTION_PORTS
 .reset(1'b0),.is_pal(1'b1),
`endif
 .exiting_vblank(1'b0),.obj_size(1'b0),.scanline(scanline),.cycle(cycle),
 .oam_bus(data),.oam_ptr_load(ptr_load),.oam_load(write),.data_in(value),.is_vbe(1'b0));
task tick;begin @(posedge clk);#1;@(negedge clk);end endtask
task dot;begin ce=0;tick();tick();ce=1;tick();ce=0;end endtask
task address(input [7:0] a);
 begin value=a;ptr_load=1;dot();ptr_load=0;end
endtask
integer i;
initial begin
 dot();reset_line=0;
 for(i=0;i<256;i=i+1) begin
  address(i[7:0]);value=(i==4) ? 8'h8c : 8'hff;write=1;dot();write=0;
 end
 address(0);render=1;
 for(i=0;i<321;i=i+1) begin cycle=i;dot();end
 cycle=321;address(1);
 for(i=322;i<339;i=i+1) begin cycle=i;dot();end
 // A late OAMDATA write must leave the pointer at 4 across the boundary.
 cycle=339;value=0;write=1;dot();write=0;
 if(dut.oam_ptr!==8'd4) $fatal(1,"late rendering write did not select row 1");
 cycle=340;reset_line=1;dot();reset_line=0;
 if(dut.oam_ptr!==8'd4) $fatal(1,"primary OAMADDR erased by evaluator line reset");
 scanline=0;
 for(i=0;i<8;i=i+1) begin cycle=i;dot();end
 render=0;dot();
 if(dut.oam_ptr!==8'd4 || data!==8'h8c)
  $fatal(1,"secondary clear changed primary address/data: %h/%h",dut.oam_ptr,data);
 // Complete a line with every sprite outside the scanline. Unused tile,
 // attribute and X bytes must clear despite nonzero primary OAMADDR.
 // The legacy evaluator writes rejected Y values; that is separate work.
 render=1;
 for(i=9;i<320;i=i+1) begin
  cycle=i;dot();
  if(i>=256 && ((i%8!=0 && data!==8'hff) || dut.oam_ptr!==0))
   $fatal(1,"secondary clear/fetch reset incorrect at dot %0d: bus %h ptr %h",i,data,dut.oam_ptr);
 end
 // CPU address writes override fetch reset for their CE, then the next
 // fetch dot reasserts zero. Refresh itself must leave that address alone.
 cycle=310;address(8'h25);
 if(dut.oam_ptr!==8'h25) $fatal(1,"fetch reset overrode CPU address write");
 cycle=311;dot();
 if(dut.oam_ptr!==0) $fatal(1,"fetch did not reset primary address");
 cycle=320;address(8'h25);
 cycle=321;dot();
 if(dut.oam_ptr!==8'h25) $fatal(1,"refresh changed primary address");
 // A normal visible-line evaluation must still copy an in-range sprite.
 render=0;cycle=340;
 address(0);value=0;write=1;dot();value=8'h13;dot();value=1;dot();value=8'h22;dot();write=0;
 address(0);reset_line=1;dot();reset_line=0;render=1;
 for(i=0;i<260;i=i+1) begin
  cycle=i;dot();
  if(i==256 && data!==0) $fatal(1,"copied sprite Y incorrect");
  if(i==257 && data!==8'h13) $fatal(1,"copied sprite tile incorrect");
  if(i==258 && data!==1) $fatal(1,"copied sprite attributes incorrect");
  if(i==259 && data!==8'h22) $fatal(1,"copied sprite X incorrect");
 end
 render=0;cycle=340;reset_line=1;dot();reset_line=0;
 for(i=0;i<64;i=i+1) begin cycle=i;dot();end
 render=1;
 for(i=64;i<258;i=i+1) begin cycle=i;dot();end
 if(data!==8'h13) $fatal(1,"enabling after secondary-clear boundary failed to evaluate");
 $display("PASS OAM phase boundary: refresh write, line transition, secondary clear, blanking read");
 $finish;
end
endmodule
