`timescale 1ns/1ps
// A menu/frame-sync pause must preserve a sprite awaiting visible scanout.
module sprite_pause_tb;
reg clk=0;always #5 clk=~clk;
reg resetn=0,enable=1;
SPPU dut(.CLK(clk),.RST_N(resetn),.ENABLE(enable),.DIS_SHORTLINE(1'b0),
 .PA(8'd0),.PARD_N(1'b1),.PAWR_N(1'b1),.DI(8'd0),.SYSCLK_CE(1'b1),
 .VRAM_DAI(8'hff),.VRAM_DBI(8'hff),.EXTLATCH(1'b1),.PAL(1'b0),.BLEND(1'b0),.BG_EN(5'b11111));
integer pixel,j;
initial begin
 repeat(4)@(negedge clk);resetn=1;
 wait(dut.V_CNT==2&&dut.H_CNT==64);
 @(negedge clk);enable=0;pixel=dut.SPR_PIXEL_X;
 dut.spr_buf[pixel]=9'h1af;
 repeat(32)@(negedge clk);
 assert(dut.SPR_PIXEL_X==pixel)else $fatal(1,"Pixel advanced while paused");
 assert(dut.spr_buf[pixel]==9'h1af)
 else $fatal(1,"Paused sprite erased: x=%0d got=%h",pixel,dut.spr_buf[pixel]);
 enable=1;
 while(dut.SPR_PIXEL_X==pixel)@(negedge clk);
 assert(dut.SPR_PIX_DATA_BUF==9'h1af)else $fatal(1,"Resumed scanout lost pending sprite");
 enable=0;
 // A valid in-progress tile must also remain frozen during a pause.
 // Seed the constructor state while the PPU sequencer is stopped.
 dut.OBJ_TIME_SAVE=1;dut.SPR_TILE_DATA=32'hffffffff;
 dut.SPR_TILE_X=0;dut.SPR_TILE_PAL=0;dut.SPR_TILE_PRIO=0;
 dut.SPR_PIX_CNT=3;
 for(j=0;j<256;j++)dut.spr_buf[j]=9'h1af;
 repeat(32)@(negedge clk);
 assert(dut.SPR_PIX_CNT==3)else $fatal(1,"Paused sprite constructor advanced");
 for(j=0;j<256;j++)assert(dut.spr_buf[j]==9'h1af)
 else $fatal(1,"Paused constructor modified sprite RAM at %0d",j);
 $display("PASS real PPU pause preserves pending sprite pixel and tile constructor");$finish;
end
initial begin #1000000;$fatal(1,"Sprite phase timeout");end
endmodule
