`timescale 1ns/1ps
module gamegear_mode_tb;
reg clk=0;always #10 clk=~clk;reg resetn=0;wire pal,gear,loading;
reg[7:0]data=0;reg valid=0;
nanoblast_iosys #(.CORE_ID(5),.FREQ(64800000),.ENABLE_DIAGNOSTICS(1)) dut(.clk(clk),.hclk(clk),.resetn(resetn),.core_status(8'd0),.core_debug_value(32'h53474731),
 .uart_rx(1'b1),.joy1(12'd0),.joy2(12'd0),.overlay_x(11'd0),.overlay_y(10'd0),.nes_pal(pal),.game_gear(gear),.rom_loading(loading),
 .sd_miso(1'b1),.flash_miso(1'b1),.rv_ready(1'b0));
task byte_in(input[7:0]v);begin @(negedge clk);data=v;valid=1;@(negedge clk);valid=0;end endtask
task config_in(input[7:0]v);begin byte_in(8'haa);byte_in(0);byte_in(5);byte_in(3);byte_in(0);byte_in(0);byte_in(0);byte_in(v);repeat(3)@(negedge clk);end endtask
task load_in(input[7:0]v);begin byte_in(8'haa);byte_in(0);byte_in(2);byte_in(6);byte_in(v);repeat(3)@(negedge clk);end endtask
initial begin
 force dut.received=data;force dut.received_valid=valid;
 repeat(5)@(negedge clk);resetn=1;repeat(3)@(negedge clk);
 config_in(12);if(gear||pal)$fatal(1,"Config changed mode before ROM load");
 load_in(1);if(!gear||!pal||!loading)$fatal(1,"GG/PAL config not latched at load start");
 config_in(4);if(!gear)$fatal(1,"Active load mode changed in flight");
 load_in(0);load_in(1);if(gear||!pal)$fatal(1,"SMS mode did not clear GG flag and preserve PAL");
 load_in(0);config_in(8);load_in(1);if(!gear||pal)$fatal(1,"GG NTSC config failed");
 $display("PASS real transport: mode latched only at ROM-load start, GG-to-SMS reset, PAL flag preservation");$finish;
end
initial begin #500000;$fatal(1,"Mode timeout");end
endmodule
module textdisp(input clk,hclk,resetn,input[10:0]overlay_x,input[9:0]overlay_y,output[15:0]overlay_color,input[3:0]reg_char_we,input[31:0]reg_char_di);assign overlay_color=0;endmodule
