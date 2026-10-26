`timescale 1ns/1ps
// Isolate panel control/mask from the unchanged font RAM. Font data is blank;
// the actual textdisp pipeline, reset release and CDC mailbox are exercised.
module gowin_dpb_menu(input clka,reseta,ocea,cea,input [10:0] ada,
 input wrea,input [7:0] dina,output [7:0] douta,
 input clkb,resetb,oceb,ceb,input [10:0] adb,input wreb,
 input [7:0] dinb,output reg [7:0] doutb);
 assign douta=0;
 always @(posedge clkb)doutb<=0;
endmodule
module tb_menu_panel;
reg clk=0,hclk=0,resetn=0;
always #8.5 clk=~clk;
always #5 hclk=~hclk;
reg [3:0] we=0;reg [31:0] command=0;
wire [15:0] color;
textdisp dut(.clk(clk),.hclk(hclk),.resetn(resetn),
 .overlay_x(11'd0),.overlay_y(10'd0),.overlay_color(color),
 .reg_char_we(we),.reg_char_di(command));
reg [7:0] point_x=0,point_y=0;
reg [1:0] phase=0;
task send(input [31:0] value);
begin
 @(negedge clk);command=value;we=1;
 @(negedge clk);we=0;
 repeat(40)@(negedge hclk);
end endtask
task mask(input integer column,row,input [1:0] hit);
begin
 point_x=column*8;point_y=row*8;
 phase=0;@(negedge hclk);
 phase=1;@(negedge hclk);
 phase=2;@(negedge hclk);
 phase=0;@(negedge hclk);
 if(color!=={14'b0,hit})$fatal(1,"Mask col %0d row %0d got %h expected %0d",column,row,color,hit);
end endtask
task point(input integer column,row,input bit hit);
begin mask(column,row,{1'b0,hit});end endtask
initial begin
 force dut.px=point_x;force dut.py=point_y;force dut.mem_cnt=phase;
 repeat(5)@(negedge clk);resetn=1;
 repeat(50)@(negedge hclk);
 point(4,14,0);
 // Settings box: columns 3..27 and rows 13..17, inclusive.
 send(32'h03100000 | (17<<15) | (13<<10) | (27<<5) | 3);
 point(3,13,1);point(27,17,1);point(4,14,1);
 point(2,14,0);point(28,14,0);point(4,12,0);point(4,18,0);
 // Shrink to a short browser: columns 0..12, rows 13..17.
 send(32'h03100000 | (17<<15) | (13<<10) | (12<<5));
 point(12,17,1);point(13,17,0);point(27,14,0);
 send(32'h03000000);point(4,14,0);
 // Reset clears an enabled panel in both domains.
 send(32'h03100000 | (17<<15) | (13<<10) | (27<<5) | 3);
 resetn=0;repeat(5)@(negedge clk);resetn=1;
 repeat(50)@(negedge hclk);point(4,14,0);
 // Selection is independent of the diagnostic/submenu panel, and has a
 // separate mask so the selected row remains visible over a dark panel.
 send(32'h02100000 | (14<<15) | (14<<10) | (28<<5) | 3);
 mask(3,14,2);mask(28,14,2);mask(2,14,0);mask(29,14,0);
 mask(4,13,0);mask(4,15,0);
 send(32'h03100000 | (17<<15) | (13<<10) | (28<<5) | 3);
 mask(4,14,3);mask(4,15,1);
 send(32'h02100000 | (16<<15) | (16<<10) | (28<<5) | 3);
 mask(4,14,1);mask(4,16,3);
 send(32'h03000000);mask(4,16,2);
 // Opaque glyphs take priority over both transparent masks.
 force dut.mem_do_b=8'hff;
 phase=0;@(negedge hclk);phase=1;@(negedge hclk);
 phase=2;@(negedge hclk);phase=0;@(negedge hclk);
 if(color!==16'hfe00)$fatal(1,"Selected text must be opaque blue");
 release dut.mem_do_b;
 send(32'h02000000);mask(4,16,0);
 send(32'h02100000 | (14<<15) | (14<<10) | (28<<5) | 3);
 resetn=0;repeat(5)@(negedge clk);resetn=1;
 repeat(50)@(negedge hclk);mask(4,14,0);
 $display("PASS panel and selection CDC, inclusive bounds, independent masks, movement, blue selected glyph priority, disable and reset");$finish;
end
initial begin #100000;$fatal(1,"Panel timeout");end
endmodule
