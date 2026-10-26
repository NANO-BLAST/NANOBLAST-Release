`timescale 1ns/1ps
module artwork_burst_tb;
reg clk=0;always #5 clk=~clk;reg resetn=0,rx_valid=0;reg[7:0]rx_data=0;
wire[22:0]address;wire[31:0]data;wire valid,tx_valid;wire[7:0]tx_data;
integer words=0,replies=0;reg[7:0]reply[0:31];reg[22:0]base=23'h200000;
nanoblast_menu_link #(.FREQ(64800000),.JOY_PERIOD_CYCLES(1000000)) dut(
 .clk(clk),.resetn(resetn),.core_status(8'd0),.rx_data(rx_data),.rx_valid(rx_valid),.tx_data(tx_data),.tx_valid(tx_valid),.tx_ready(1'b1),
 .joy1(12'd0),.joy2(12'd0),.sd_miso(1'b1),.flash_miso(1'b1),.rv_ready(1'b1),.rv_valid(valid),.rv_addr(address),.rv_wdata(data));
always @(posedge clk)begin
 if(valid)begin
  if(address!=base+words*4)$fatal(1,"address %x word %d",address,words);
  if(data!={8'((words*4+3)%256),8'((words*4+2)%256),8'((words*4+1)%256),8'((words*4)%256)})$fatal(1,"pixel data %x",data);
  words=words+1;
 end
 if(tx_valid)begin reply[replies]=tx_data;replies=replies+1;end
end
task send(input[7:0]b);begin @(negedge clk);rx_data=b;rx_valid=1;@(negedge clk);rx_valid=0;repeat(4)@(negedge clk);end endtask
integer i;
initial begin
 repeat(4)@(negedge clk);resetn=1;repeat(4)@(negedge clk);
 send(8'haa);send(4);send(5);send(19);send(0);send(8'h20);send(0);send(0);
 for(i=0;i<1024;i=i+1)send(i%256);
 repeat(100)@(negedge clk);
 if(words!=256||replies!=5||reply[3]!=19||reply[4]!=0)$fatal(1,"words %d replies %d status %x",words,replies,reply[4]);
 $display("PASS existing FPGA bridge: full 1024-byte artwork packet, 256 exact SDRAM words, address order and successful acknowledgement");$finish;
end
initial begin #500000;$fatal(1,"timeout");end
endmodule
