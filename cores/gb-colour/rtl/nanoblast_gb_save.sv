// CRC-protected, bounded GB save-page bridge. GPL-3.0 NANOBLAST.
// Request payload: op, packet_sequence BE16, offset BE24, count BE16, data, CRC32 BE.
// Reply command 18h: packet_sequence BE16, status, data, CRC32 BE. CRC covers payload.
module nanoblast_gb_save #(parameter integer FREQ=27000000)(
 input clk,resetn,running,loading,paused,cart_ready,ram_written,
 input [47:0]rtc_value,input [31:0]rtc_timestamp,
 input rx_start,rx_valid,rx_last,input[7:0]rx_data,input[15:0]rx_length,
 output reg pause_request,output[31:0]generation,
 output reg mem_req,mem_we,output reg[16:0]mem_addr,output reg[31:0]mem_wdata,
 input mem_ack,input[31:0]mem_rdata,
 output reg rtc_wr,output reg[16:0]rtc_addr,output reg[15:0]rtc_data,
 output reg[7:0]tx_data,output tx_valid,tx_last,input tx_ready
);
localparam IDLE=0,RX=1,CHECK=2,PAUSE=3,MEM_START=4,MEM_WAIT=5,RTC=6,RTC_WAIT=7,CRC=8,TX=9,MEM_PREP=10;
reg[3:0]state=IDLE;
// One synchronous page RAM, rather than a large asynchronous register mux.
(* syn_ramstyle="block_ram" *) reg[31:0]page[0:63];
reg[31:0]page_out,rx_word=0,rx_rtc_low=0,rx_rtc_high=0;
reg[95:0]snapshot=0;
reg[5:0]page_index;
reg[31:0]gen=0;reg old_write=0;
assign generation=gen;
reg[7:0]op=0,status=0;reg[15:0]packet_sequence=0,count=0;reg[23:0]offset=0;
reg[8:0]rx_pos=0,packet_bytes=0,data_length=0,crc_pos=0,tx_pos=0,position=0;
reg[31:0]receive_crc=~0,wire_crc=0,response_crc=~0,final_crc=0,stamp=0;
reg[3:0]wait_count=0;reg[2:0]rtc_step=0;
reg[$clog2(FREQ+1)-1:0]watchdog=0;
always @*begin
 page_index=position[7:2];
 if(state==CRC)page_index=crc_pos>=2?(crc_pos-2)>>2:0;
 else if(state==TX)begin
  if(tx_ready&&tx_pos>=6)page_index=(tx_pos-6)>>2;
  else page_index=tx_pos>=7?(tx_pos-7)>>2:0;
 end
end
wire rx_word_valid=state==RX&&rx_valid&&rx_pos>=8&&rx_pos<packet_bytes-4;
wire rx_page_write=rx_word_valid&&rx_pos[1:0]==3;
wire mem_page_write=state==MEM_WAIT&&mem_req==mem_ack&&op==2;
wire page_write=rx_page_write||mem_page_write;
wire[5:0]page_write_index=rx_page_write?(rx_pos-9'd8)>>2:position[7:2];
wire[31:0]page_write_data=rx_page_write?{rx_data,rx_word[31:8]}:mem_rdata;
always @(posedge clk)begin
 page_out<=page[page_index];
 if(page_write)page[page_write_index]<=page_write_data;
end
always @(posedge clk)if(rx_word_valid)begin
 rx_word<={rx_data,rx_word[31:8]};
 if(rx_page_write&&rx_pos==11)rx_rtc_low<={rx_data,rx_word[31:8]};
 if(rx_page_write&&rx_pos==15)rx_rtc_high<={rx_data,rx_word[31:8]};
end
function automatic[31:0]crc_byte(input[31:0]old,input[7:0]value);
 reg[31:0]c;integer i;begin c=old^value;for(i=0;i<8;i=i+1)c=c[0]?(c>>1)^32'hedb88320:c>>1;crc_byte=c;end
endfunction
function automatic[7:0]data_byte(input[8:0]index);begin data_byte=op==1?snapshot>>(index*8):page_out>>(index[1:0]*8);end endfunction
wire[7:0]crc_input=crc_pos==0?packet_sequence[15:8]:crc_pos==1?packet_sequence[7:0]:crc_pos==2?status:data_byte(crc_pos-3);
task reply(input[7:0]code,input[8:0]bytes);begin status<=code;data_length<=bytes;crc_pos<=0;response_crc<=32'hffffffff;state<=CRC;end endtask
assign tx_valid=state==TX;
assign tx_last=tx_pos==data_length+10;
always @*begin
 tx_data=0;
 case(tx_pos)
 0:tx_data=8'haa;
 1:tx_data=(data_length+8)>>8;
 2:tx_data=data_length+8;
 3:tx_data=8'h18;
 4:tx_data=packet_sequence[15:8];
 5:tx_data=packet_sequence[7:0];
 6:tx_data=status;
 default:if(tx_pos<data_length+7)tx_data=data_byte(tx_pos-7);
 else case(tx_pos-data_length-7)
  0:tx_data=final_crc[31:24];1:tx_data=final_crc[23:16];2:tx_data=final_crc[15:8];default:tx_data=final_crc[7:0];
 endcase
 endcase
end
always @(posedge clk)begin
 rtc_wr<=0;old_write<=ram_written;
 if(loading)gen<=0;else if(running&&ram_written&&!old_write)gen<=gen+1'b1;
 if(state==PAUSE)watchdog<=watchdog+1'b1;else watchdog<=0;
 case(state)
 IDLE:;
 RX:if(rx_valid)begin
  rx_pos<=rx_pos+1'b1;
  if(rx_pos<packet_bytes-4)receive_crc<=crc_byte(receive_crc,rx_data);
  else wire_crc<={wire_crc[23:0],rx_data};
  case(rx_pos)
   0:op<=rx_data;1:packet_sequence[15:8]<=rx_data;2:packet_sequence[7:0]<=rx_data;
   3:offset[23:16]<=rx_data;4:offset[15:8]<=rx_data;5:offset[7:0]<=rx_data;
   6:count[15:8]<=rx_data;7:count[7:0]<=rx_data;
   default:;
  endcase
  if(rx_last)begin
   if(rx_pos+1!=packet_bytes||{wire_crc[23:0],rx_data}!=~receive_crc)reply(1,0);
   else state<=CHECK;
  end
 end
 CHECK:begin
  if((op==1||op==5)&&(packet_bytes!=12||count!=0||offset!=0))reply(2,0);
  else if(op==5)begin pause_request<=0;reply(0,0);end
  else if(!running||loading)reply(3,0);
  else if(op==1)begin pause_request<=1;wait_count<=0;state<=PAUSE;end
  else if(!pause_request||!paused||!cart_ready)reply(4,0);
  else if(op==2||op==3)begin
   if(!count||count>256||count[1:0]!=0||offset[1:0]!=0||offset>=24'h20000||offset+count>24'h20000||packet_bytes!=(op==3?count+12:12))reply(2,0);
   else begin position<=0;state<=MEM_PREP;end
  end else if(op==4)begin
   if(packet_bytes!=20||count!=8||offset!=0||rx_rtc_low[5:0]>=60||rx_rtc_low[11:6]>=60||rx_rtc_low[16:12]>=24||rx_rtc_low[26]||rx_rtc_low[31:29]!=0||rx_rtc_high!=0)reply(2,0);
   else begin stamp<=rtc_timestamp;rtc_step<=0;state<=RTC;end
  end else reply(2,0);
 end
 PAUSE:begin
  if(watchdog>=FREQ-1)begin pause_request<=0;reply(5,0);end
  else if(paused&&cart_ready)begin
   if(wait_count==4)begin snapshot<={16'd0,rtc_value,gen};reply(0,12);end
   else wait_count<=wait_count+1'b1;
  end else wait_count<=0;
 end
 MEM_PREP:state<=MEM_START;
 MEM_START:if(mem_req==mem_ack)begin
  mem_addr<=offset[16:0]+position;mem_we<=op==3;mem_wdata<=page_out;
  mem_req<=~mem_req;state<=MEM_WAIT;
 end
 MEM_WAIT:if(mem_req==mem_ack)begin
  if(position+4==count)reply(0,op==2?count[8:0]:9'd0);
  else begin position<=position+4;state<=MEM_PREP;end
 end
 RTC:begin
  rtc_wr<=1;rtc_addr<={14'd0,rtc_step};rtc_step<=rtc_step+1'b1;
  case(rtc_step)0:rtc_data<=stamp[15:0];1:rtc_data<=stamp[31:16];2:rtc_data<=rx_rtc_low[15:0];3:rtc_data<=rx_rtc_low[31:16];default:rtc_data<=0;endcase
  if(rtc_step==4)begin wait_count<=0;state<=RTC_WAIT;end
 end
 RTC_WAIT:if(wait_count==7)reply(0,0);else wait_count<=wait_count+1'b1;
 CRC:begin
  response_crc<=crc_byte(response_crc,crc_input);crc_pos<=crc_pos+1'b1;
  if(crc_pos==data_length+2)begin final_crc<=~crc_byte(response_crc,crc_input);tx_pos<=0;state<=TX;end
 end
 TX:if(tx_ready)begin if(tx_last)state<=IDLE;else tx_pos<=tx_pos+1'b1;end
 default:state<=IDLE;
 endcase
 if(rx_start&&(state==IDLE||state==RX)&&rx_length>=12&&rx_length<=268)begin
  state<=RX;packet_bytes<=rx_length[8:0];rx_pos<=0;receive_crc<=32'hffffffff;wire_crc<=0;packet_sequence<=0;op<=0;count<=0;offset<=0;
 end
 if(!resetn)begin state<=IDLE;pause_request<=0;mem_req<=0;mem_we<=0;mem_addr<=0;mem_wdata<=0;rtc_wr<=0;rtc_addr<=0;rtc_data<=0;gen<=0;old_write<=0;watchdog<=0;wait_count<=0;end
end
endmodule
