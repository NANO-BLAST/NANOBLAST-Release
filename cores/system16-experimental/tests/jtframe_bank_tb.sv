`timescale 1ns/1ps
module jtframe_bank_tb;
parameter TAG_RAM=0;
reg clk=0;always #5 clk=~clk;
reg resetn=0;
reg[15:0]a16=0,a32=0,a8=0;reg cs16=0,cs32=0,cs8=0;
wire[15:0]q16;wire[31:0]q32;wire[7:0]q8;wire ok16,ok32,ok8;
wire rd0;wire[21:0]addr0;
wire[3:0]ack,dst,dok,rdy;wire[15:0]data_read;
reg[3:1]manual_rd=0,manual_wr=0;
reg[65:0]manual_addr=0;reg[47:0]manual_din=0;reg[5:0]manual_dsn=6'b111111;
wire mem_req,mem_wr;wire[22:0]mem_addr;wire[31:0]mem_din;wire[3:0]mem_wmask;
reg mem_ack=0;reg[31:0]mem_dout=0;wire fault;
s16_jtframe_bank_bridge bridge(.clk(clk),.resetn(resetn),.mem_ready(1'b1),
 .rd({manual_rd,rd0}),.wr({manual_wr,1'b0}),.bank_addr({manual_addr,addr0}),
 .bank_din({manual_din,16'd0}),.bank_dsn({manual_dsn,2'b11}),
 .ack(ack),.dst(dst),.dok(dok),.rdy(rdy),.data_read(data_read),
 .mem_req(mem_req),.mem_wr(mem_wr),.mem_addr(mem_addr),.mem_din(mem_din),.mem_wmask(mem_wmask),
 .mem_ack(mem_ack),.mem_dout(mem_dout),.fault(fault));
jtframe_rom_3slots #(.SDRAMW(22),.SLOT0_DW(16),.SLOT1_DW(32),.SLOT2_DW(8),
 .TAG_RAM(TAG_RAM),.CACHE0_SIZE(1024),.CACHE0_LARGE(1),.SLOT0_AW(16),.SLOT1_AW(16),.SLOT2_AW(16)) cache(
 .rst(!resetn),.clk(clk),.slot0_addr(a16),.slot1_addr(a32),.slot2_addr(a8),
 .slot0_dout(q16),.slot1_dout(q32),.slot2_dout(q8),.slot0_cs(cs16),.slot1_cs(cs32),.slot2_cs(cs8),
 .slot0_ok(ok16),.slot1_ok(ok32),.slot2_ok(ok8),.sdram_ack(ack[0]),.sdram_rd(rd0),
 .sdram_addr(addr0),.data_dst(dst[0]),.data_rdy(rdy[0]),.data_read(data_read));
function automatic[15:0] value(input[21:0]word_address);
 value=16'h1000+word_address*17+word_address[21:20]*16'h1101;
endfunction
reg pending=0;integer delay_count=0,reads=0,writes=0;
reg[22:0]held_addr;reg held_req,held_wr;reg[31:0]held_din;reg[3:0]held_mask;
always @(posedge clk)begin
 if(!resetn)begin pending<=0;mem_ack<=0;mem_dout<=0;end
 else if(!pending && mem_req!=mem_ack)begin
  held_addr<=mem_addr;held_req<=mem_req;held_wr<=mem_wr;held_din<=mem_din;held_mask<=mem_wmask;
  delay_count<=3;pending<=1;
 end else if(pending)begin
  assert(mem_addr==held_addr&&mem_req==held_req&&mem_wr==held_wr&&mem_din==held_din&&mem_wmask==held_mask)else $fatal(1,"Native payload changed before ack");
  if(delay_count!=0)delay_count<=delay_count-1;
  else begin
   mem_dout<={value((held_addr>>1)+1),value(held_addr>>1)};
   mem_ack<=held_req;pending<=0;
   if(held_wr)begin
    writes=writes+1;
    assert(held_addr==23'h400004&&held_mask==4'b0100&&held_din==32'habcdabcd)else $fatal(1,"Masked upper-half bank write incorrect");
   end else reads=reads+1;
  end
 end
end
integer i,elapsed;reg[15:0]v;
initial begin
 repeat(4)@(negedge clk);resetn=1;
 for(i=0;i<64;i=i+1)begin
  @(negedge clk);a16=i;cs16=1;elapsed=0;
  @(posedge clk);#1;
  while(!ok16)begin @(posedge clk);#1;if(elapsed++>50)$fatal(1,"16-bit cache timeout");end
  assert(q16==value(i))else $fatal(1,"16-bit cache byte/word order");
  @(negedge clk);cs16=0;repeat(3)@(negedge clk);
  a32=i*2;cs32=1;elapsed=0;@(posedge clk);#1;
  while(!ok32)begin @(posedge clk);#1;if(elapsed++>50)$fatal(1,"32-bit cache timeout");end
  assert(q32=={value(i*2+1),value(i*2)})else $fatal(1,"32-bit cache word order got %h",q32);
  @(negedge clk);cs32=0;repeat(3)@(negedge clk);
  a8=i;cs8=1;elapsed=0;@(posedge clk);#1;
  while(!ok8)begin @(posedge clk);#1;if(elapsed++>50)$fatal(1,"8-bit cache timeout");end
  v=value(i>>1);
  assert(q8==(i%2?v[15:8]:v[7:0]))else $fatal(1,"8-bit cache byte order");
  @(negedge clk);cs8=0;repeat(3)@(negedge clk);
 end
 // Hold all other bank requests at once and check paired data delivery.
 for(i=1;i<4;i=i+1)manual_addr[(i-1)*22+:22]=i*16;
 manual_rd=3'b111;
 for(i=1;i<4;i=i+1)begin
  wait(ack[i]);@(negedge clk);manual_rd[i]=0;
  wait(dst[i]);#1;
  assert(data_read==value((i<<20)+i*16))else $fatal(1,"Bank/low-word routing");
  @(posedge clk);#1;
  assert(rdy[i]&&dok[i]&&data_read==value((i<<20)+i*16+1))else $fatal(1,"Burst end/high-word routing");
  @(negedge clk);
 end
 repeat(3)@(negedge clk);
 manual_addr[22+:22]=22'd3;manual_din[16+:16]=16'habcd;manual_dsn[2+:2]=2'b10;
 manual_wr[2]=1;wait(ack[2]);@(negedge clk);manual_wr[2]=0;
 wait(rdy[2]);repeat(3)@(negedge clk);
 assert(writes==1&&!fault)else $fatal(1,"Write failed");
 // A logical bank address beyond 2 MiB must never alias a lower row.
 manual_addr[44+:22]=22'h100000;manual_rd[3]=1;
 repeat(5)@(negedge clk);
 assert(fault && !ack[3])else $fatal(1,"Out-of-range bank access accepted");
 $display("PASS upstream JTFRAME caches: 192 cached reads plus concurrent banks, %0d native bursts; 8/16/32-bit ordering, byte masks and address bounds",reads);
 $finish;
end
initial begin #1000000;$fatal(1,"Test timeout");end
endmodule
