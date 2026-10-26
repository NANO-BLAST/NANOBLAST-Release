`timescale 1ns/1ps
module tb_nanoblast_iosys #(parameter FREQ=20_000_000,CORE_ID=1);
reg clk=0,hclk=0;always #(500000000.0/FREQ)clk=~clk;always #7 hclk=~hclk;
reg resetn=0,uart_rx=1;wire uart_tx,overlay,loading,rom_valid,pal;
wire [7:0] rom_data;wire [11:0] usb1,usb2;wire [15:0] color;
integer count=0,writes=0;reg [31:0] last_word;
nanoblast_iosys #(.FREQ(FREQ),.CORE_ID(CORE_ID),.BAUD(2_000_000)) dut(
.clk(clk),.hclk(hclk),.resetn(resetn),.core_status(8'h01),.uart_rx(uart_rx),.uart_tx(uart_tx),
.joy1(12'd0),.joy2(12'd0),.usb_joy1(usb1),.usb_joy2(usb2),.overlay_x(11'd0),.overlay_y(10'd0),
.overlay_color(color),.overlay(overlay),.rom_loading(loading),.rom_do(rom_data),.rom_do_valid(rom_valid),.nes_pal(pal));
always @(posedge clk) begin
 if(rom_valid)begin if(rom_data!=8'ha5)$fatal(1,"serial ROM transfer");count=count+1;end
 if(dut.text_we)begin writes=writes+1;last_word=dut.text_word;end
end
task send(input[7:0] b);integer i;begin
 @(negedge clk);uart_rx=0;#500;
 for(i=0;i<8;i=i+1)begin uart_rx=b[i];#500;end
 uart_rx=1;#1000;
end endtask
task frame(input[15:0] len,input[7:0] cmd);begin send(8'haa);send(len[15:8]);send(len[7:0]);send(cmd);end endtask
reg [7:0] replies[0:4];integer n,i;
initial begin
 // Independently sample the serial TX response at each bit center.
 for(n=0;n<5;n=n+1)begin
  @(negedge uart_tx);#750;
  for(i=0;i<8;i=i+1)begin replies[n][i]=uart_tx;#500;end
  if(!uart_tx)$fatal(1,"UART stop bit");
 end
 if(replies[0]!=8'haa||replies[1]!=0||replies[2]!=2||replies[3]!=1||replies[4]!=CORE_ID)$fatal(1,"serial ID response");
end
initial begin
 repeat(5)@(negedge clk);resetn=1;
 frame(1,1);repeat(700)@(negedge clk);
 frame(5,3);send(0);send(0);send(0);send(4);
 frame(2,6);send(1);repeat(5)@(negedge clk);
 if(!pal||!loading)$fatal(1,"PAL latch on load start");
 frame(2,7);send(8'ha5);
 frame(2,6);send(0);
 frame(5,14);send(0);send(2);send(14);send("Z");repeat(10)@(negedge clk);
 if(count!=1||loading||writes!=1||last_word!=32'h00020e5a)$fatal(1,"serial text/ROM");
 frame(5,9);send(0);send(1);send(0);send(8'h80);repeat(5)@(negedge clk);
 if(usb1!=1||usb2!=128)$fatal(1,"USB controller injection");
 frame(5,14);send(2);send(8'h17);send(8'h3b);send(8'h83);repeat(20)@(negedge clk);
 if(dut.disp.selection_box!==21'h173b83||dut.disp.selection_pixel!==21'h173b83)$fatal(1,"UART selection rectangle/CDC");
 frame(5,14);send(2);send(0);send(0);send(0);repeat(20)@(negedge clk);
 if(dut.disp.selection_pixel!==0)$fatal(1,"UART selection disable");
 $display("PASS real UART: core ID, PAL latch, ROM, text, USB controllers, selection rectangle and disable");$finish;
end
initial begin #2000000;$fatal(1,"serial test timeout");end
endmodule
// Menu RAM fixture isolates the command bridge from Gowin-specific primitives.
module gowin_dpb_menu(input clka,reseta,ocea,cea,input[10:0]ada,input wrea,input[7:0]dina,output[7:0]douta,
input clkb,resetb,oceb,ceb,input[10:0]adb,input wreb,input[7:0]dinb,output[7:0]doutb);
assign douta=0;assign doutb=0;
endmodule
