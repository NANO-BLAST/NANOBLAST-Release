`timescale 1ns/1ps
module tb_mappers;
reg clk=0; always #5 clk=~clk;
reg ce=1, en=0, wr=0;
reg [31:0] flags=0;
reg [15:0] pa=16'h6000;
reg [13:0] ca=14'h2400;
reg [7:0] data=0;
wire mirror, allow;
wire [21:0] ramaddr;
Mapper78 m70(.clk(clk),.ce(ce),.enable(en),.flags(flags),.prg_ain(pa),
 .prg_read(!wr),.prg_write(wr),.prg_din(data),.chr_ain(ca),.chr_read(1'b1),
 .vram_a10_b(mirror),.audio_in(16'd0));
MMC3 m112(.clk(clk),.ce(ce),.enable(en),.flags(flags),.prg_ain(pa),
 .prg_read(!wr),.prg_write(wr),.prg_din(data),.chr_ain(ca),.chr_read(1'b1),
 .prg_allow_b(allow),.prg_aout_b(ramaddr),.audio_in(16'd0));
task tick; begin @(posedge clk); #1; @(negedge clk); end endtask
task write_reg(input [15:0] a,input [7:0] d);
 begin pa=a;data=d;wr=1;tick();wr=0; end endtask
initial begin
 // Disabled with a DIFFERENT mapper/header, then atomically select new ROM.
`ifndef RAM_ONLY
 tick(); flags=32'h00004046; en=1; #1;
 if(mirror!==1) $fatal(1,"mapper70 vertical header lost at selection");
 flags=32'h00000046; #1;
 if(mirror!==0) $fatal(1,"mapper70 horizontal header ignored");
 flags=32'h00004046; write_reg(16'h8000,8'h80); ca=14'h2800; #1;
 if(mirror!==0) $fatal(1,"mapper70 write changed fixed mirroring");
 flags=32'd152; write_reg(16'h8000,8'h80); #1;
 if(mirror!==1) $fatal(1,"mapper152 upper one-screen changed");
 write_reg(16'h8000,0); #1;
 if(mirror!==0) $fatal(1,"mapper152 lower one-screen changed");
`endif
 en=0;flags=0;tick(); flags=112;en=1;pa=16'h6000;wr=1;#1;
 if(allow!==1 || ramaddr!==22'h3c0000) $fatal(1,"mapper112 initial RAM unavailable");
 pa=16'h7fff;#1;
 if(allow!==1 || ramaddr!==22'h3c1fff) $fatal(1,"mapper112 upper RAM unavailable");
 pa=16'h5fff;#1;if(allow!==0) $fatal(1,"mapper112 RAM below range");
 en=0;wr=0;flags=0;tick();flags=4;en=1;pa=16'h6000;wr=1;#1;
 if(allow!==0) $fatal(1,"MMC3 RAM protection bypassed");
 write_reg(16'ha001,8'h80);pa=16'h6000;wr=1;#1;
 if(allow!==1) $fatal(1,"MMC3 RAM enable broken");
 write_reg(16'ha001,8'hc0);pa=16'h6000;wr=1;#1;
 if(allow!==0) $fatal(1,"MMC3 write protect broken");
 wr=0;#1;if(allow!==1) $fatal(1,"MMC3 protected read broken");
 $display("PASS mapper header selection, RAM windows and MMC3 controls");$finish;
end
endmodule
