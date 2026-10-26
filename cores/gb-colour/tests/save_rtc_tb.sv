`timescale 1ns/1ps
module save_rtc_tb;
reg clk=0;always #5 clk=~clk;
reg resetn=0,running=1,loading=0,ram_written=0,cart_ready=1;
wire pause_request;wire paused=pause_request;
reg rx_start=0,rx_valid=0,rx_last=0;reg[7:0]rx_data=0;reg[15:0]rx_length;
wire[31:0]generation;wire mem_req,mem_we;wire[16:0]mem_addr;wire[31:0]mem_wdata;
reg mem_ack=0;reg[31:0]mem_rdata=0;
wire rtc_wr;wire[16:0]rtc_addr;wire[15:0]rtc_data;
wire[7:0]tx_data;wire tx_valid,tx_last;reg tx_ready=1;
wire[47:0]rtc_value;wire[31:0]rtc_timestamp;
mbc3 cartridge(.enable(1'b1),.reset(!resetn),.mbc30(1'b0),.clk_sys(clk),.ce_cpu(1'b0),.savestate_load(1'b0),.savestate_data(16'd0),
 .ce_32k(1'b0),.RTC_time(33'd0),.bk_wr(1'b0),.bk_rtc_wr(rtc_wr),.bk_addr(rtc_addr),.bk_data(rtc_data),.img_size(64'd0),
 .has_ram(1'b1),.ram_mask(3'd3),.rom_mask(8'h7f),.cart_addr(15'd0),.cart_a15(1'b0),.cart_mbc_type(8'h10),
 .cart_rd(1'b0),.cart_wr(1'b0),.cart_di(8'd0),.nCS(1'b1),.cram_di(8'hff),.RTC_savedtimeOut_b(rtc_value),.RTC_timestampOut_b(rtc_timestamp));
nanoblast_gb_save #(.FREQ(100)) dut(.*);
reg[31:0]memory[0:32767];reg[15:0]rtc_words[0:4];
integer delay_cycles=0,requests=0,replies=0,len=0;reg[7:0]response[0:299],packet[0:299];
always @(posedge clk)begin
 if(mem_ack!=mem_req)begin
  if(delay_cycles==3)begin
   if(mem_we)memory[mem_addr>>2]<=mem_wdata;else mem_rdata<=memory[mem_addr>>2];
   mem_ack<=mem_req;delay_cycles<=0;requests<=requests+1;
  end else delay_cycles<=delay_cycles+1;
 end
 if(rtc_wr)rtc_words[rtc_addr]<=rtc_data;
 if(tx_valid&&tx_ready)begin response[len]<=tx_data;len<=len+1;if(tx_last)replies<=replies+1;end
end
function automatic[31:0]crc_byte(input[31:0]old,input[7:0]v);
 reg[31:0]c;integer i;begin c=old^v;for(i=0;i<8;i++)c=c[0]?(c>>1)^32'hedb88320:c>>1;crc_byte=c;end
endfunction
task request(input integer op,seq,offset,count,databytes,corrupt);
 integer i,target;reg[31:0]c;begin
 len=0;target=replies+1;packet[0]=op;packet[1]=seq>>8;packet[2]=seq;packet[3]=offset>>16;packet[4]=offset>>8;packet[5]=offset;packet[6]=count>>8;packet[7]=count;
 c=~0;for(i=0;i<8+databytes;i++)c=crc_byte(c,packet[i]);c=~c^corrupt;
 for(i=0;i<4;i++)packet[8+databytes+i]=c>>(24-i*8);
 @(negedge clk);rx_start=1;rx_length=12+databytes;@(negedge clk);rx_start=0;
 for(i=0;i<12+databytes;i++)begin rx_valid=1;rx_data=packet[i];rx_last=i==11+databytes;@(negedge clk);end
 rx_valid=0;rx_last=0;
 wait(replies==target);@(negedge clk);
 if(response[0]!=8'haa||response[3]!=8'h18||response[4]!=(seq>>8)||response[5]!=(seq&255))$fatal(1,"Bad reply framing/sequence");
 c=~0;for(i=4;i<len-4;i++)c=crc_byte(c,response[i]);c=~c;
 if(c!={response[len-4],response[len-3],response[len-2],response[len-1]})$fatal(1,"Reply CRC");
 if({response[1],response[2]}!=len-3)$fatal(1,"Reply length");
end endtask
integer tx_cycles=0;always @(negedge clk)begin tx_cycles=tx_cycles+1;tx_ready=tx_cycles%3!=0;end
integer i,old_requests;
initial begin
 #100;resetn=1;
 request(2,1,0,256,0,0);if(response[6]!=4)$fatal(1,"Read without pause accepted");
 request(1,2,0,0,0,0);if(response[6]!=0||len!=23||!pause_request)$fatal(1,"Acquire failed");
 if({response[14],response[13],response[12],response[11]}!=rtc_value[31:0])$fatal(1,"RTC snapshot");
 for(i=0;i<256;i++)packet[8+i]=i;
 request(3,3,0,256,256,0);if(response[6]!=0||requests!=64)$fatal(1,"Page write failed");
 request(2,4,0,256,0,0);if(response[6]!=0||len!=267)$fatal(1,"256 byte read failed");
 for(i=0;i<256;i++)if(response[7+i]!=i)$fatal(1,"Read mismatch at %d",i);
 old_requests=requests;request(3,5,0,256,256,1);if(response[6]!=1||requests!=old_requests)$fatal(1,"Bad CRC mutated memory");
 request(2,6,131068,8,0,0);if(response[6]!=2)$fatal(1,"Overflow accepted");
 request(2,7,1,4,0,0);if(response[6]!=2)$fatal(1,"Unaligned accepted");
 for(i=0;i<8;i++)packet[8+i]=0;packet[8]=10;
 request(4,8,0,8,8,0);if(response[6]!=0||rtc_words[0]!=0||rtc_words[1]!=0||rtc_words[2]!=10||rtc_words[3]!=0)$fatal(1,"RTC load failed");
 if(cartridge.rtc_seconds!=10||cartridge.rtc_minutes!=0||rtc_value!=10)$fatal(1,"Actual MBC3 restore failed %h",rtc_value);
 request(5,9,0,0,0,0);if(response[6]!=0||pause_request)$fatal(1,"Release failed");
 @(negedge clk);ram_written=1;repeat(4)@(negedge clk);ram_written=0;repeat(2)@(negedge clk);if(generation!=1)$fatal(1,"Dirty edge count");
 cart_ready=0;request(1,10,0,0,0,0);if(response[6]!=5||pause_request)$fatal(1,"Pause watchdog failed");
 $display("PASS actual MBC3 save bridge: framing, CRC, 256 byte pages, bounds, RTC, release, dirty counter and watchdog");$finish;
end
initial begin #1000000;$fatal(1,"Test timeout");end
endmodule
