`timescale 1ns/1ps
module sdram_tb;
reg clk=0;always #10 clk=~clk;
reg resetn=0,req=0,wr=0;
reg [22:0] addr=0;reg [7:0] din=0;
reg bg_enable=0,bg_req=0;reg[19:0]bg_addr=0;wire bg_ack,bg_valid;wire[31:0]bg_data;wire[8:0]bg_word;
wire ack,ready;wire[7:0] dout;
tri [31:0] dq;
wire[10:0] a;wire[1:0] ba;wire[3:0] dqm;
wire cs,ras,cas,we,cke;
sms_nano_sdram #(.INIT_CYCLES(16),.REFRESH_CYCLES(512)) dut(
 .bg_enable(bg_enable),.bg_req(bg_req),.bg_addr(bg_addr),.bg_ack(bg_ack),.bg_valid(bg_valid),.bg_data(bg_data),.bg_word(bg_word),
 .clk(clk),.resetn(resetn),.req(req),.wr(wr),.addr(addr),.din(din),
 .ack(ack),.dout(dout),.ready(ready),.sdram_dq(dq),.sdram_a(a),
 .sdram_ba(ba),.sdram_dqm(dqm),.sdram_cs_n(cs),.sdram_ras_n(ras),
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
     assert(dq!==32'bz&&dqm!=4'hf)else $fatal(1,"Missing write drive");
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
integer elapsed,max_latency=0;
task access(input bit writing,input[22:0]address,input[7:0]data,input[7:0]expected);
 begin
  @(negedge clk);#1;wr=writing;addr=address;din=data;req=~req;elapsed=0;
  while(ack!=req)begin @(posedge clk);#1;elapsed=elapsed+1;if(elapsed>50)$fatal(1,"No acknowledgement");end
  if(elapsed>max_latency)max_latency=elapsed;
  if(!writing)assert(dout===expected)else $fatal(1,"Read mismatch addr=%h expected=%h got=%h",address,expected,dout);
 end
endtask
integer bank,n;reg[22:0]base;reg[31:0]random_state=32'h172f091b;
initial begin
 repeat(3)@(posedge clk);@(negedge clk);#1;resetn=1;
 wait(ready);#1;assert(precharges==1&&refreshes==2&&modes==1)else $fatal(1,"Bad init sequence");
 // Lane independence plus column/row/bank boundaries and the last word.
 for(bank=0;bank<4;bank=bank+1)begin
  for(n=0;n<4;n=n+1)begin
   case(n)0:base=bank*23'h200000;1:base=bank*23'h200000+23'h3fc;
    2:base=bank*23'h200000+23'h400;3:base=bank*23'h200000+23'h1ffffc;endcase
   for(integer j=0;j<4;j=j+1)access(1,base+j,8'h31+bank*9+n*4+j,0);
   for(integer j=0;j<4;j=j+1)access(0,base+j,0,8'h31+bank*9+n*4+j);
  end
 end
 // Deterministic randomized masked writes and reads under repeated refresh.
 for(n=0;n<256;n=n+1)begin
  random_state=(random_state<<1)^((random_state[31])?32'h04c11db7:0);
  base={random_state[22:2],2'b0};
  for(integer j=0;j<4;j=j+1)access(1,base+j,random_state[j*8+:8],0);
  for(integer j=0;j<4;j=j+1)access(0,base+j,0,random_state[j*8+:8]);
 end
 // Artwork line burst spans a row boundary, with one byte request held
 // pending throughout; every delivered word must retain order and address.
 for(n=0;n<320;n=n+1)mem[(23'h6003fc>>2)+n]=32'h12340000+n;
 @(negedge clk);#1;bg_addr=20'h003fc;bg_enable=1;bg_req=~bg_req;
 n=0;elapsed=0;
 while(bg_ack!=bg_req)begin
  @(posedge clk);#1;elapsed=elapsed+1;
  if(bg_valid)begin
   assert(bg_word==n&&bg_data==32'h12340000+n)else $fatal(1,"Artwork word %0d got %h at %0d",n,bg_data,bg_word);
   n=n+1;
  end
  if(elapsed>400)$fatal(1,"Artwork burst deadline");
 end
 assert(n==320)else $fatal(1,"Artwork burst incomplete");
 bg_enable=0;access(1,23'h400123,8'h69,0);access(0,23'h400123,0,8'h69);
 repeat(200)@(posedge clk);
 assert(refreshes>10)else $fatal(1,"Missing periodic refresh");
 // Reset invalidates old acknowledgement and reinitializes SDRAM safely.
 @(negedge clk);#1;resetn=0;req=0;repeat(3)@(posedge clk);
 @(negedge clk);#1;resetn=1;wait(ready);#1;
 access(1,23'h7fffff,8'h5a,0);access(0,23'h7fffff,0,8'h5a);
 $display("PASS SDRAM: %0d writes, %0d reads, %0d refreshes; max request latency %0d cycles",writes,reads,refreshes,max_latency);
 $finish;
end
initial begin #2000000;$fatal(1,"Simulation timeout");end
endmodule
