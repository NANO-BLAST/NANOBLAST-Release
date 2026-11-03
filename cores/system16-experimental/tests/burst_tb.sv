`timescale 1ns/1ps
module burst_tb;
reg clk=0;always #10 clk=~clk;
reg resetn=0,req=0,wr=0;reg[22:0]addr=0;reg[31:0]din=0;reg[3:0]wmask=15;
wire ack,ready,fault;wire[31:0]dout;tri[31:0]dq;
wire[10:0]a;wire[1:0]ba;wire[3:0]dqm;wire cs,ras,cas,we,cke;
reg burst_req=0,burst_wr=0;reg[22:0]burst_addr=0;reg[8:0]burst_length=0;
wire burst_ack,burst_valid;wire[31:0]burst_data;wire[8:0]burst_word,burst_index;
reg[31:0]burst_din=0;reg[31:0]upload[0:511];
always @(posedge clk)burst_din<=upload[burst_word];
s16_sdram32_burst #(.INIT_CYCLES(16),.REFRESH_CYCLES(256))dut(.burst_enable(1'b1),
 .clk(clk),.resetn(resetn),.req(req),.wr(wr),.addr(addr),.din(din),.wmask(wmask),.ack(ack),.dout(dout),.ready(ready),
 .burst_req(burst_req),.burst_wr(burst_wr),.burst_addr(burst_addr),.burst_length(burst_length),.burst_din(burst_din),
 .burst_ack(burst_ack),.burst_valid(burst_valid),.burst_data(burst_data),.burst_word(burst_word),.burst_index(burst_index),.fault(fault),
 .sdram_dq(dq),.sdram_a(a),.sdram_ba(ba),.sdram_dqm(dqm),.sdram_cs_n(cs),.sdram_ras_n(ras),.sdram_cas_n(cas),.sdram_we_n(we),.sdram_cke(cke));
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


integer n,elapsed,j,received_count;
task transfer(input bit writing,input[22:0]address,input[8:0]words);
 begin
  @(negedge clk);#1;burst_wr=writing;burst_addr=address;burst_length=words;burst_req=~burst_req;
  elapsed=0;received_count=0;
  while(burst_ack!=burst_req)begin
   @(posedge clk);#1;elapsed=elapsed+1;
   if(burst_valid)begin
    assert(burst_index==received_count && burst_data==upload[received_count])else $fatal(1,"Burst word %0d got %h at %0d",received_count,burst_data,burst_index);
    received_count=received_count+1;
   end
   if(elapsed>600)$fatal(1,"Burst timeout");
  end
  if(!writing)assert(received_count==words)else $fatal(1,"Incomplete burst");
  assert(!fault)else $fatal(1,"Unexpected burst fault");
 end
endtask
initial begin
 for(n=0;n<512;n=n+1)upload[n]=32'h12340000+n*32'h10201;
 repeat(4)@(negedge clk);resetn=1;wait(ready);
 for(j=0;j<4;j=j+1)begin
  transfer(1,j*23'h200000+23'h3fc,160);
  for(n=0;n<160;n=n+1)assert(mem[(j*23'h200000+23'h3fc)/4+n]==upload[n])else $fatal(1,"Write burst data/read-ahead error at %0d",n);
  transfer(0,j*23'h200000+23'h3fc,160);
 end
 transfer(1,23'h200000,1);transfer(0,23'h200000,1);
 transfer(1,23'h400000,256);transfer(0,23'h400000,256);
 // A native request held alongside a long burst must eventually complete.
 @(negedge clk);#1;addr=23'h7ffffc;din=32'h98765432;wr=1;req=~req;
 transfer(1,23'h200000,160);wait(ack==req);
 assert(mem[23'h7ffffc/4]==32'h98765432)else $fatal(1,"Native request starved/lost");
 repeat(400)@(negedge clk);
 assert(refreshes>5)else $fatal(1,"Refresh missing");
 // Reject a transfer that would alias past the end of physical memory.
 @(negedge clk);#1;burst_addr=23'h7ffffc;burst_length=2;burst_req=~burst_req;
 repeat(8)@(negedge clk);assert(fault)else $fatal(1,"Out-of-range burst accepted");
 $display("PASS burst SDRAM: synchronous write prefetch, 1/160/256-word bursts, bank/row boundaries, refresh, native arbitration and bounds");
 $finish;
end
initial begin #2000000;$fatal(1,"Simulation timeout");end
endmodule
