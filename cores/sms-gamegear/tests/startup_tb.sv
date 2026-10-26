`timescale 1ns/1ps
// Real startup+UART+menu transport, with a behavioral replacement only for the
// Gowin text BRAM. ROM/SDRAM initialization is deliberately absent: core ID
// must be available before a game or artwork can be loaded.
module startup_tb;
reg clk=0,hclk=0;always #7.7160493827 clk=~clk;always #6.734006734 hclk=~hclk;
reg rx=1;wire tx,old_tx,ready,resetn;reg s1=0,reset2=1,main_lock=0,hdmi_lock=0;
sms_nano_startup startup(.clk(clk),.ready(ready));
reset_release release_reset(.clk(clk),.async_resetn(ready),.resetn(resetn));
wire old_reset=ready&&main_lock&&hdmi_lock&&!reset2&&s1;
nanoblast_iosys #(.CORE_ID(5),.FREQ(64_800_000)) actual(
 .clk(clk),.hclk(hclk),.resetn(resetn),.core_status(8'd0),.uart_rx(rx),.uart_tx(tx),
 .joy1(12'd0),.joy2(12'd0),.overlay_x(11'd0),.overlay_y(10'd0),.sd_miso(1'b1),.rv_ready(1'b1));
nanoblast_iosys #(.CORE_ID(5),.FREQ(64_800_000)) previous(
 .clk(clk),.hclk(hclk),.resetn(old_reset),.core_status(8'd0),.uart_rx(rx),.uart_tx(old_tx),
 .joy1(12'd0),.joy2(12'd0),.overlay_x(11'd0),.overlay_y(10'd0),.sd_miso(1'b1),.rv_ready(1'b1));
wire[7:0]byte_rx;wire byte_valid;
async_receiver #(.ClkFrequency(64_800_000),.Baud(2_000_000)) monitor(.clk(clk),.RxD(tx),.RxD_data(byte_rx),.RxD_data_ready(byte_valid));
reg[7:0]reply[0:127];integer received=0;
always @(posedge clk)if(byte_valid)begin reply[received]=byte_rx;received=received+1;end
task send_byte(input[7:0]value);integer i;begin
 rx=0;#500;for(i=0;i<8;i=i+1)begin rx=value[i];#500;end rx=1;#750;
end endtask
integer n,start,timeout;
initial begin
 #1;if(resetn!==0)$fatal(1,"Startup did not begin in reset");
 repeat(65530)@(posedge clk);#1;if(resetn!==0)$fatal(1,"Startup released before hold interval");
 wait(resetn);#1000;
 // Eight unfavorable/favorable pin and lock combinations. The previous top
 // suppresses replies on its unfavorable combinations; new startup must not.
 for(n=0;n<8;n=n+1)begin
  s1=n[0];reset2=n[1];main_lock=n[2];hdmi_lock=n[0];start=received;
  send_byte(8'haa);send_byte(0);send_byte(1);send_byte(1);
  timeout=0;while(received<start+5&&timeout<3000)begin @(posedge clk);timeout=timeout+1;end
  if(received!=start+5)$fatal(1,"No core ID for pin/lock state %d",n);
  if({reply[start],reply[start+1],reply[start+2],reply[start+3],reply[start+4]}!==40'haa00020105)$fatal(1,"Wrong actual UART ID reply");
  if(!old_reset&&old_tx!==1'b1)$fatal(1,"Old held-reset transport unexpectedly active");
 end
 start=received;send_byte(8'haa);send_byte(0);send_byte(1);send_byte(22);
 timeout=0;while(received<start+8&&timeout<5000)begin @(posedge clk);timeout=timeout+1;end
 if(received!=start+8||{reply[start],reply[start+1],reply[start+2],reply[start+3],reply[start+4],reply[start+5],reply[start+6],reply[start+7]}!==64'haa0005164e424631)$fatal(1,"UART flash capability");
 start=received;send_byte(8'haa);send_byte(0);send_byte(3);send_byte(21);send_byte(3);send_byte(8'h5a);
 timeout=0;while(received<start+5&&timeout<3000)begin @(posedge clk);timeout=timeout+1;end
 if(received!=start+5||{reply[start],reply[start+1],reply[start+2],reply[start+3],reply[start+4]}!==40'haa0002155a)$fatal(1,"UART flash sequence acknowledgement");
 $display("PASS startup + real UART flash capability/sequence:  >=1ms hold, real 2Mbaud UART replies CORE5 before ROM, eight pin/LOCK combinations; old reset predicate suppresses transport");$finish;
end
initial begin #3000000;$fatal(1,"Startup test timeout");end
endmodule
module gowin_dpb_menu(output reg[7:0]douta,doutb,input clka,ocea,cea,reseta,wrea,clkb,oceb,ceb,resetb,wreb,input[10:0]ada,adb,input[7:0]dina,dinb);
reg[7:0]mem[0:2047];integer i;initial for(i=0;i<2048;i=i+1)mem[i]=0;
always @(posedge clka)if(cea)begin if(wrea)mem[ada]<=dina;douta<=mem[ada];end
always @(posedge clkb)if(ceb)begin if(wreb)mem[adb]<=dinb;doutb<=mem[adb];end
endmodule
