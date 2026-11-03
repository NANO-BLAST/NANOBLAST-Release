// SPDX-License-Identifier: GPL-3.0-or-later
// UART byte FIFO, JTFRAME download pacing and SDRAM programming arbitration.
module s16_loader #(parameter [25:0] MIN_BYTES=26'h444020,MAX_BYTES=26'h44c020)(
 input wire clk,resetn,loading,load_valid,input wire[7:0]load_data,
 input wire ready,output reg running=0,output reg fault=0,
 output reg[25:0]ioctl_addr=0,output reg[7:0]ioctl_dout=0,output reg ioctl_wr=0,ioctl_rom=0,
 input wire prog_we,input wire[21:0]prog_addr,input wire[1:0]prog_ba,input wire[15:0]prog_data,input wire[1:0]prog_mask,output reg prog_ack=0,
 input wire bank_req,bank_wr,input wire[22:0]bank_addr,input wire[31:0]bank_din,input wire[3:0]bank_wmask,
 output reg bank_ack=0,output reg[31:0]bank_dout=0,
 output reg mem_req=0,mem_wr=0,output reg[22:0]mem_addr=0,output reg[31:0]mem_din=0,output reg[3:0]mem_wmask=0,
 input wire mem_ack,input wire[31:0]mem_dout
);
(* ram_style="block" *) reg[7:0]fifo[0:63];
reg[7:0]head=0;reg[1:0]settle=0;
reg[5:0]wp=0,rp=0;reg[6:0]count=0;
always @(posedge clk)head<=fifo[rp];
reg old_loading=0,session=0,active=0,owner_prog=0,bank_target=0,prog_seen=0;
reg[5:0]pace=0;
reg[25:0]next_address=0;
wire push=load_valid&&loading;
wire fresh=loading&&!old_loading;
always @(posedge clk)if(push&&(fresh||count<64))fifo[fresh?6'd0:wp]<=load_data;
wire pop=session&&count!=0&&pace==0&&settle==0&&ready&&!prog_we&&!active&&!fault;
always @(posedge clk)begin
 if(settle!=0)settle<=settle-1'b1;
 if(push&&count==0)settle<=2;
 old_loading<=loading;ioctl_wr<=0;prog_ack<=0;
 if(pace!=0)pace<=pace-1'b1;
 if(!prog_we)prog_seen<=0;
 if(!running&&!active)bank_ack<=0;
 if(push)begin
  if(count==64)fault<=1;
  else wp<=wp+1'b1;
 end
 case({push,pop})2'b10:if(count!=64)count<=count+1'b1;2'b01:count<=count-1'b1;default:;endcase
 if(pop)begin
  settle<=2;
  ioctl_addr<=next_address;ioctl_dout<=head;ioctl_wr<=1;rp<=rp+1'b1;
  next_address<=next_address+1'b1;pace<=6'd31;
  if(next_address>=MAX_BYTES)fault<=1;
  // Fixed World set 3 profile. Reject encrypted variants with a different MCU.
  case(next_address)
   26'h10:if(head!=0)fault<=1;
   26'h11:if(head!=1)fault<=1;
   26'h12,26'h13:if(head!=0)fault<=1;
   26'h18:if(head!=8'h40)fault<=1;
   default:;
  endcase
 end
 if(active&&mem_ack==mem_req)begin
  active<=0;
  if(owner_prog)prog_ack<=1;
  else begin bank_ack<=bank_target;bank_dout<=mem_dout;end
 end
 if(!active&&mem_req==mem_ack&&ready)begin
  if(prog_we&&!prog_seen&&ioctl_rom)begin
   active<=1;owner_prog<=1;prog_seen<=1;
   mem_req<=~mem_req;mem_wr<=1;
   mem_addr<={prog_ba,prog_addr[19:1],2'b00};mem_din<={2{prog_data}};
   mem_wmask<=prog_addr[0]?{~prog_mask,2'b00}:{2'b00,~prog_mask};
   if(prog_addr[21:20]!=0)fault<=1;
  end else if(running&&bank_req!=bank_ack)begin
   active<=1;owner_prog<=0;bank_target<=bank_req;mem_req<=~mem_req;
   mem_wr<=bank_wr;mem_addr<=bank_addr;mem_din<=bank_din;mem_wmask<=bank_wmask;
  end
 end
 if(session&&!loading&&count==0&&pace==0&&!prog_we&&!active)begin
  session<=0;ioctl_rom<=0;
  if(next_address<MIN_BYTES)fault<=1;
  else if(!fault)running<=1;
 end
 if(loading&&!old_loading)begin
  running<=0;fault<=0;session<=1;ioctl_rom<=1;
  wp<=0;rp<=0;count<=0;next_address<=0;ioctl_addr<=0;pace<=0;settle<=2;
  if(push)begin wp<=1;count<=1;end
 end
 if(!resetn)begin
  running<=0;fault<=0;ioctl_addr<=0;ioctl_dout<=0;ioctl_wr<=0;ioctl_rom<=0;settle<=0;
  wp<=0;rp<=0;count<=0;old_loading<=0;session<=0;active<=0;owner_prog<=0;bank_target<=0;prog_seen<=0;pace<=0;next_address<=0;
  prog_ack<=0;bank_ack<=0;bank_dout<=0;mem_req<=0;mem_wr<=0;mem_addr<=0;mem_din<=0;mem_wmask<=0;
 end
end
endmodule
