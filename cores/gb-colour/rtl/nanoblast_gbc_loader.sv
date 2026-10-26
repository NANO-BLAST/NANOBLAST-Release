// NANOBLAST NBGB byte stream -> 32-bit SDRAM writes + MiSTer ioctl pairs.
// ROM 000000..3fffff, volatile cartridge RAM 400000..41ffff.
module nanoblast_gbc_loader(
 input clk,resetn,loading,load_valid,input [7:0]load_data,
 output reg ioctl_wr,output reg [24:0]ioctl_addr,output reg [15:0]ioctl_dout,
 output running,output reg fault,
 output reg [22:0]size,output reg [31:0]received_crc,read_crc,
 output reg host_req,host_we,output reg [22:0]host_addr,
 output reg [31:0]host_wdata,output [3:0]host_be,
 input host_ack,input [31:0]host_rdata,input memory_ready
);
reg was_loading,eof,loaded;reg [3:0]header_count;
reg [31:0]pack;reg [7:0]pair_lo;
reg [31:0]fifo[0:63];reg [5:0]head,tail;reg [6:0]count;
reg [22:0]written,verify_addr;reg [16:0]clear_addr;
reg cleared,verified;reg [2:0]job;localparam IDLE=0,WRITE=1,CLEAR=2,READ=3,CRC=4;
reg [31:0]verify_word;reg [1:0]verify_byte;
function automatic [31:0]crc_byte(input [31:0]state,input [7:0]data);
 reg[31:0]c;integer i;begin c=state^data;for(i=0;i<8;i=i+1)c=c[0]?(c>>1)^32'hedb88320:c>>1;crc_byte=c;end
endfunction
wire rom_byte=loading&&load_valid&&header_count==8&&!fault;
wire push=rom_byte&&size[1:0]==3&&count<64;
wire pop=job==WRITE&&host_req==host_ack;
assign running=memory_ready&&loaded&&!loading&&!fault;
assign host_be=4'hf;
always @(posedge clk)begin
 was_loading<=loading;ioctl_wr<=0;
 case({push,pop})2'b10:count<=count+1'b1;2'b01:count<=count-1'b1;default:;endcase
 if(loading&&load_valid&&header_count<8)begin
  case(header_count)
   0:if(load_data!="N")fault<=1;
   1:if(load_data!="B")fault<=1;
   2:if(load_data!="G")fault<=1;
   3:if(load_data!="B")fault<=1;
   default:;
  endcase
  header_count<=header_count+1'b1;
 end
 if(rom_byte)begin
  if(size==23'h400000||count==64)fault<=1;
  else begin
   size<=size+1'b1;received_crc<=crc_byte(received_crc,load_data);
   pack[size[1:0]*8+:8]<=load_data;
   if(!size[0])pair_lo<=load_data;
   else begin ioctl_wr<=1;ioctl_addr<={2'b0,size}-1'b1;ioctl_dout<={load_data,pair_lo};end
   if(push)begin fifo[tail]<={load_data,pack[23:0]};tail<=tail+1'b1;end
  end
 end
 if(!loading&&was_loading)begin
  eof<=1;
  if(header_count!=8||size<32768||(size&(size-1'b1))!=0)fault<=1;
 end
 if(eof&&count==0&&cleared&&verified&&!fault)loaded<=1;
 if(job!=IDLE&&job!=CRC&&host_req==host_ack)begin
  case(job)
   WRITE:begin head<=head+1'b1;written<=written+4;end
   CLEAR:if(clear_addr==17'h1fffc)cleared<=1;else clear_addr<=clear_addr+4;
   READ:begin verify_word<=host_rdata;verify_byte<=0;end
   default:;
  endcase
  job<=job==READ?CRC:IDLE;
 end
 if(job==CRC)begin
  read_crc<=crc_byte(read_crc,verify_word[verify_byte*8+:8]);
  if(verify_byte==3)begin
   verify_addr<=verify_addr+4;job<=IDLE;
   if(verify_addr+4==size)begin
    verified<=1;
    if(crc_byte(read_crc,verify_word[31:24])!=received_crc)fault<=1;
   end
  end else verify_byte<=verify_byte+1'b1;
 end
 if(job==IDLE&&host_req==host_ack&&memory_ready&&!fault)begin
  if(count!=0)begin host_addr<=written;host_wdata<=fifo[head];host_we<=1;host_req<=~host_req;job<=WRITE;end
  else if(eof&&!cleared)begin host_addr<=23'h400000+clear_addr;host_wdata<=0;host_we<=1;host_req<=~host_req;job<=CLEAR;end
  else if(eof&&cleared&&!verified&&size!=0)begin host_addr<=verify_addr;host_we<=0;host_req<=~host_req;job<=READ;end
 end
 if(loading&&!was_loading)begin
  // Never abandon an in-flight transfer from an unfinished download.
  fault<=count!=0||job!=IDLE;header_count<=0;size<=0;written<=0;head<=0;tail<=0;count<=0;
  eof<=0;loaded<=0;cleared<=0;verified<=0;clear_addr<=0;verify_addr<=0;
  received_crc<=32'hffffffff;read_crc<=32'hffffffff;
  if(load_valid)fault<=1;
 end
 if(!resetn)begin
  was_loading<=0;header_count<=0;size<=0;written<=0;head<=0;tail<=0;count<=0;
  eof<=0;loaded<=0;fault<=0;cleared<=1;verified<=0;clear_addr<=0;verify_addr<=0;
  received_crc<=32'hffffffff;read_crc<=32'hffffffff;
  job<=IDLE;host_req<=0;host_we<=0;host_addr<=0;host_wdata<=0;
  pack<=0;pair_lo<=0;ioctl_wr<=0;ioctl_addr<=0;ioctl_dout<=0;verify_byte<=0;verify_word<=0;
 end
end
endmodule
