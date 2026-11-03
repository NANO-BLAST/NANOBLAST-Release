`timescale 1ns/1ps
module memory_tb;
reg clk=0;always #10 clk=~clk;
reg resetn=0;
reg[3:0] req=0,wr=0;
reg[87:0]addr=0;reg[63:0]din=0;reg[7:0]wmask=0;
wire[3:0]ack;wire[63:0]dout;
wire mem_req,mem_wr,mem_ack,ready;
wire[22:0]mem_addr;wire[31:0]mem_din,mem_dout;wire[3:0]mem_wmask;
tri[31:0]dq;wire[10:0]a;wire[1:0]ba;wire[3:0]dqm;
wire cs,ras,cas,we,cke;
s16_word_arbiter bridge(.clk(clk),.resetn(resetn),.req(req),.wr(wr),.addr(addr),
 .din(din),.wmask(wmask),.ack(ack),.dout(dout),.mem_req(mem_req),.mem_wr(mem_wr),
 .mem_addr(mem_addr),.mem_din(mem_din),.mem_wmask(mem_wmask),.mem_ack(mem_ack),.mem_dout(mem_dout));
s16_sdram32 #(.INIT_CYCLES(16),.REFRESH_CYCLES(128)) dut(
 .clk(clk),.resetn(resetn),.req(mem_req),.wr(mem_wr),.addr(mem_addr),.din(mem_din),
 .wmask(mem_wmask),.ack(mem_ack),.dout(mem_dout),.ready(ready),.sdram_dq(dq),
 .sdram_a(a),.sdram_ba(ba),.sdram_dqm(dqm),.sdram_cs_n(cs),.sdram_ras_n(ras),
 .sdram_cas_n(cas),.sdram_we_n(we),.sdram_cke(cke));
// Independent x32 SDR SDRAM model: sample commands on the opposite clock edge.
// It decodes ACT row/bank and CAS column, performs masked word writes, and
// schedules CL2 read data. Storage spans all four banks (8MiB).
reg [31:0] mem[0:2097151];
reg [10:0] row[0:3];reg [3:0] opened=0;
integer active_cycle[0:3],available_cycle[0:3];
integer cycle=0,refreshes=0,last_refresh=0,global_available=0;
integer precharges=0,modes=0,pending=0,read_index=0,writes=0,reads=0;
reg[1:0]read_valid=0;integer read_q0=0,read_q1=0;
integer i,lane,word_index;reg drive=0;reg[31:0] model_data;
assign dq=drive?model_data:32'bz;
always @(negedge clk) begin
 cycle=cycle+1;
 if(!resetn)begin
  opened=0;pending=0;read_valid=0;drive=0;global_available=0;last_refresh=cycle;
  for(i=0;i<4;i=i+1)available_cycle[i]=0;
 end else begin
  drive=read_valid[1];
  if(read_valid[1])model_data=mem[read_q1];
  read_valid={read_valid[0],1'b0};read_q1=read_q0;
  case({cs,ras,cas,we})
   4'b0010:begin assert(a[10])else $fatal(1,"Expected precharge-all");precharges=precharges+1;opened=0;global_available=cycle+2;end
   4'b0001:begin
    assert(cycle>=global_available&&opened==0)else $fatal(1,"Refresh timing/open row");
    for(i=0;i<4;i=i+1)assert(cycle>=available_cycle[i])else $fatal(1,"Refresh before auto-precharge complete");
    refreshes=refreshes+1;last_refresh=cycle;global_available=cycle+5;
   end
   4'b0000:begin
    assert(cycle>=global_available&&a==11'h020&&ba==0)else $fatal(1,"Wrong mode/tMRD");
    modes=modes+1;global_available=cycle+2;
   end
   4'b0011:begin
    assert(cycle>=global_available&&cycle>=available_cycle[ba]&&!opened[ba])else $fatal(1,"ACT timing");
    row[ba]=a;opened[ba]=1;active_cycle[ba]=cycle;
   end
   4'b0100,4'b0101:begin
    assert(opened[ba]&&a[9:8]==0&&cycle-active_cycle[ba]>=2)else $fatal(1,"CAS geometry or tRCD");
    word_index={ba,row[ba],a[7:0]};if(a[10])opened[ba]=0;
    if(!we)begin
     assert(dq!==32'bz)else $fatal(1,"Missing write drive");
     for(lane=0;lane<4;lane=lane+1)if(!dqm[lane])mem[word_index][lane*8+:8]=dq[lane*8+:8];
     writes=writes+1;available_cycle[ba]=cycle+5;
    end else begin
     assert(dqm==0&&!dut.drive)else $fatal(1,"Read masks or bus contention");
     read_q0=word_index;read_valid[0]=1;reads=reads+1;available_cycle[ba]=cycle+3;
    end
   end
  endcase
  if(ready)assert(cycle-last_refresh<900)else $fatal(1,"Refresh starved by request stream");
 end
end

integer elapsed,bank,n,j,client,transactions=0;reg[22:0]base;
reg[31:0]random_state=32'h172f091b,expected_word;
task access(input integer port,input bit writing,input[22:0]byte_address,input[15:0]data,input[1:0]mask,input[15:0]expected);
 begin
  if(byte_address[0])$fatal(1,"Test supplied unaligned 16-bit request");
  @(negedge clk);#1;wr[port]=writing;addr[port*22+:22]=byte_address[22:1];
  din[port*16+:16]=data;wmask[port*2+:2]=mask;req[port]=~req[port];elapsed=0;
  while(ack[port]!=req[port])begin
   @(posedge clk);#1;elapsed=elapsed+1;if(elapsed>50)$fatal(1,"No acknowledgement for port %0d",port);
  end
  if(!writing && dout[port*16+:16]!==expected)$fatal(1,"Read mismatch %h expected %h got %h",byte_address,expected,dout[port*16+:16]);
  transactions=transactions+1;
 end
endtask
initial begin
 repeat(3)@(posedge clk);@(negedge clk);#1;resetn=1;wait(ready);#1;
 assert(precharges==1&&refreshes==2&&modes==1)else $fatal(1,"Bad initialization");
 for(bank=0;bank<4;bank=bank+1)begin
  for(n=0;n<4;n=n+1)begin
   case(n)
    0:base=bank*23'h200000;
    1:base=bank*23'h200000+23'h3fc;
    2:base=bank*23'h200000+23'h400;
    3:base=bank*23'h200000+23'h1ffffc;
   endcase
   mem[base>>2]=32'h12345678;
   access(bank,0,base,0,0,16'h5678);access(bank,0,base+2,0,0,16'h1234);
   access(bank,1,base,16'habcd,2'b11,0);access(bank,1,base+2,16'hfe90,2'b11,0);
   access(bank,1,base,16'h0077,2'b01,0);access(bank,1,base+2,16'h6600,2'b10,0);
   access(bank,0,base,0,0,16'hab77);access(bank,0,base+2,0,0,16'h6690);
   access(bank,1,base,16'hffff,2'b00,0);access(bank,0,base,0,0,16'hab77);
  end
 end
 for(n=0;n<128;n=n+1)begin
  random_state=(random_state<<1)^((random_state[31])?32'h04c11db7:0);
  base={random_state[22:2],2'b00};mem[base>>2]=~random_state;
  access(n%4,1,base,random_state[15:0],2'b11,0);
  access((n+1)%4,1,base+2,random_state[31:16],2'b11,0);
  access((n+2)%4,0,base,0,0,random_state[15:0]);
  access((n+3)%4,0,base+2,0,0,random_state[31:16]);
 end
 // Establish round-robin pointer 0, then issue four simultaneous requests.
 mem[0]=32'd0;access(3,0,0,0,0,0);
 for(n=0;n<16;n=n+1)begin
  @(negedge clk);#1;
  for(j=0;j<4;j=j+1)begin
   addr[j*22+:22]=(23'h100000+j*4)>>1;
   din[j*16+:16]=16'h5000+n*4+j;wmask[j*2+:2]=2'b11;
  end
  wr=4'hf;req=~ack;elapsed=0;client=0;
  while(ack!=req)begin
   @(posedge clk);#1;elapsed=elapsed+1;
   if(client<4 && ack[client]==req[client])client=client+1;
   for(j=client;j<4;j=j+1)assert(ack[j]!=req[j])else $fatal(1,"Round-robin order violated");
   if(elapsed>160)$fatal(1,"A client starved");
  end
  assert(client==4)else $fatal(1,"Missing acknowledgement");
  for(j=0;j<4;j=j+1)assert(mem[(23'h100000+j*4)>>2][15:0]==16'h5000+n*4+j)else $fatal(1,"Wrong client write payload");
 end
 // Reset during a pending request must not produce a stale completion.
 @(negedge clk);#1;req[0]=~req[0];wr[0]=0;
 @(posedge clk);@(negedge clk);#1;resetn=0;req=0;
 repeat(3)@(posedge clk);@(negedge clk);#1;resetn=1;wait(ready);#1;
 assert(ack==0&&mem_ack==0)else $fatal(1,"Stale acknowledgement after reset");
 access(0,0,0,0,0,0);
 assert(refreshes>20)else $fatal(1,"Missing refreshes under sustained requests");
 $display("PASS 16-bit/x32 SDRAM: %0d serial transactions, 64 concurrent requests, %0d refreshes; lanes, bank/row boundaries, zero masks, arbitration and in-flight reset",transactions,refreshes);
 $finish;
end
initial begin #2000000;$fatal(1,"Simulation timeout");end
endmodule
