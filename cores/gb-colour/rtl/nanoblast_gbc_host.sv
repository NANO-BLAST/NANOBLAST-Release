// Multiplex loader and existing BL616 artwork writes onto a word request channel.
// Toggle completion for reads is returned only after the read data is valid.
module nanoblast_gbc_host(
 input clk,resetn,
 input load_req,load_we,input [22:0]load_addr,input [31:0]load_wdata,input [3:0]load_be,
 output reg load_ack,output reg [31:0]load_rdata,
 input save_req,save_we,input[16:0]save_addr,input[31:0]save_wdata,
 output reg save_ack,output reg[31:0]save_rdata,
 input rv_valid,input [22:0]rv_addr,input [31:0]rv_wdata,input [3:0]rv_wstrb,output reg rv_ready,
 output reg req,we,output reg [20:0]addr,output reg [31:0]wdata,output reg [3:0]be,
 input ack,rvalid,input [31:0]rdata,output reg fault
);
reg busy,write_q,target,rv_seen;reg[1:0]owner;
always @(posedge clk)begin
 rv_ready<=0;
 if(!rv_valid)rv_seen<=0;
 if(!busy)begin
  if(load_req!=load_ack)begin
   req<=1;we<=load_we;addr<=load_addr[22:2];wdata<=load_wdata;be<=load_be;
   busy<=1;owner<=0;write_q<=load_we;target<=load_req;
  end else if(save_req!=save_ack)begin
   req<=1;we<=save_we;addr<=(23'h400000+save_addr)>>2;wdata<=save_wdata;be<=4'hf;
   busy<=1;owner<=2;write_q<=save_we;target<=save_req;
  end else if(rv_valid&&!rv_seen)begin
   rv_seen<=1;
   if(rv_addr<23'h200000||rv_addr>23'h2e0ffc||rv_addr[1:0]!=0)begin fault<=1;rv_ready<=1;end
   else begin
    req<=1;we<=1;addr<=(rv_addr+23'h400000)>>2;wdata<=rv_wdata;be<=rv_wstrb;
    busy<=1;owner<=1;write_q<=1;
   end
  end
 end else begin
  if(ack)req<=0;
  if((write_q&&ack)||(!write_q&&rvalid))begin
   busy<=0;req<=0;
   if(owner==2)begin save_ack<=target;save_rdata<=rdata;end
   else if(owner==1)rv_ready<=1;
   else begin load_ack<=target;load_rdata<=rdata;end
  end
 end
 if(!resetn)begin busy<=0;owner<=0;write_q<=0;target<=0;rv_seen<=0;
  req<=0;we<=0;addr<=0;wdata<=0;be<=0;load_ack<=0;load_rdata<=0;save_ack<=0;save_rdata<=0;rv_ready<=0;fault<=0;end
end
endmodule
