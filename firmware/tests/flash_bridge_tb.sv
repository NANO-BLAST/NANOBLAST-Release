`timescale 1ns/1ps
module flash_bridge_tb;
reg clk=0;always #5 clk=~clk;
reg resetn=0,rx_valid=0;reg[7:0]rx_data;wire[7:0]tx_data;wire tx_valid;
wire fsck,fmosi,fcs,sdclk,sdmosi,sdcs;wire[31:0]unused_word;wire[22:0]unused_addr;
reg[7:0]wire_bytes[0:511],reply[0:2047];integer bit_count=0,byte_count=0,reply_count=0;reg[7:0]shift=0;
reg[7:0]command=0;integer sd_edges=0;
wire fmiso=bit_count<8?1'b1:command==8'h9f ? ((24'hef4017>>(23-((bit_count-8)%24)))&1):1'b0;
nanoblast_menu_link #(.FREQ(21_600_000),.TIMEOUT_CYCLES(200),.JOY_PERIOD_CYCLES(1000000)) dut(
 .clk(clk),.resetn(resetn),.core_status(8'h01),.rx_data(rx_data),.rx_valid(rx_valid),.tx_data(tx_data),.tx_valid(tx_valid),.tx_ready(1'b1),
 .joy1(12'd0),.joy2(12'd0),.sd_clk(sdclk),.sd_mosi(sdmosi),.sd_cs_n(sdcs),.sd_miso(1'b1),
 .flash_clk(fsck),.flash_mosi(fmosi),.flash_cs_n(fcs),.flash_miso(fmiso),.rv_ready(1'b1));
defparam dut.FLASH_CS_TIMEOUT_CYCLES=500;
always @(posedge clk)if(tx_valid)begin reply[reply_count]=tx_data;reply_count=reply_count+1;end
always @(posedge sdclk)sd_edges=sd_edges+1;
always @(negedge fcs)begin bit_count=0;byte_count=0;shift=0;command=0;end
always @(posedge fsck)if(!fcs)begin
 shift={shift[6:0],fmosi};bit_count=bit_count+1;
 if(bit_count%8==0)begin wire_bytes[byte_count]=shift;byte_count=byte_count+1;if(byte_count==1)command=shift;end
end
task send(input[7:0]b);begin @(negedge clk);rx_data=b;rx_valid=1;@(negedge clk);rx_valid=0;repeat(2)@(negedge clk);end endtask
task head(input integer n,input[7:0]cmd);begin send(8'haa);send(n>>8);send(n);send(cmd);end endtask
task wait_reply(input integer n);integer i;begin
 i=0;while(reply_count<n&&i<100000)begin @(negedge clk);i=i+1;end
 if(reply_count!=n)$fatal(1,"reply length %d expected%d",reply_count,n);
end endtask
task packet(input[7:0]flags,input[7:0]seq_value,input integer n,input[7:0]first);integer i;begin
 reply_count=0;head(n+3,21);send(flags);send(seq_value);for(i=0;i<n;i=i+1)send(i==0?first:0);
 wait_reply(n+5);
 if(reply[0]!=8'haa||reply[1]!=0||reply[2]!=n+2||reply[3]!=21||reply[4]!=seq_value)$fatal(1,"flash reply framing/seq_value");
end endtask
integer i;
initial begin
 repeat(4)@(negedge clk);resetn=1;repeat(4)@(negedge clk);
 if(!fcs||fsck)$fatal(1,"unsafe reset pins");
 head(1,22);wait_reply(8);if({reply[4],reply[5],reply[6],reply[7]}!=32'h4e424631)$fatal(1,"capability");
 packet(2,8'h7d,4,8'h9f);
 if({reply[6],reply[7],reply[8]}!=24'hef4017)$fatal(1,"JEDEC bit order %x %x %x",reply[6],reply[7],reply[8]);
 if(byte_count!=4||wire_bytes[0]!=8'h9f||sd_edges!=0)$fatal(1,"SPI routing");
 packet(3,8'h7e,0,0);if(!fcs)$fatal(1,"CS not released");
 // Hold CS across packet boundaries to send one 256-byte page.
 packet(2,8'h80,4,8'h02);
 for(i=0;i<8;i=i+1)packet(2,8'h81+i,32,i);
 if(byte_count!=260||wire_bytes[0]!=2)$fatal(1,"page split failed %d",byte_count);
 for(i=0;i<8;i=i+1)if(wire_bytes[4+i*32]!=i)$fatal(1,"page chunk mismatch");
 packet(3,8'h90,0,0);if(!fcs)$fatal(1,"page CS close");
 // A malformed or incomplete frame cannot start a flash transaction.
 reply_count=0;head(2,21);send(0);repeat(300)@(negedge clk);if(!fcs||reply_count)$fatal(1,"invalid flash packet");
 reply_count=0;head(35,21);send(0);repeat(300)@(negedge clk);if(!fcs||reply_count)$fatal(1,"partial flash packet");
 // Transport failure cannot leave flash selected indefinitely.
 packet(2,8'h91,0,0);repeat(510)@(negedge clk);if(!fcs||fsck)$fatal(1,"flash CS watchdog");
 // Existing SD command framing and buffers remain usable after flash traffic.
 reply_count=0;head(3,16);send(3);send(8'ha5);wait_reply(5);
 if(reply[3]!=16||reply[4]!=255||!fcs||sd_edges!=8)$fatal(1,"SD isolation");
 $display("PASS direct flash RTL: capability, sequenced replies, real SPI ID, 260-byte split page, reset/watchdog, malformed packets and SD isolation");$finish;
end
initial begin #5000000;$fatal(1,"simulation timeout");end
endmodule
