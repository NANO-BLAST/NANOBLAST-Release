`timescale 1ns/1ps
module sdram_tb;
reg clk=0;always #5 clk=~clk;
reg mclk=0;always #20 mclk=~mclk;
reg resetn=0,cpu_req=0,cpu_we=0,rv_req=0,rv_we=0;
reg [21:0] cpu_addr=0,rv_addr=0;reg [15:0] cpu_din=0,rv_din=0;
wire cpu_ack,rv_ack,busy;wire [15:0] cpu_data,rv_data;
reg menu_mode=1,bg_enable=0,bg_req=0;reg [19:0]bg_addr=0;
wire bg_ack,bg_valid;wire [31:0]bg_data;wire [8:0]bg_word;
tri [31:0]dq;wire[10:0]a;wire[1:0]ba;wire[3:0]dqm;wire cs,ras,cas,we,cke;
sdram_snes #(.FREQ(1000000))dut(
 .clk(clk),.mclk(mclk),.clkref(1'b0),.resetn(resetn),.busy(busy),
 .SDRAM_DQ(dq),.SDRAM_A(a),.SDRAM_BA(ba),.SDRAM_DQM(dqm),
 .SDRAM_nCS(cs),.SDRAM_nRAS(ras),.SDRAM_nCAS(cas),.SDRAM_nWE(we),.SDRAM_CKE(cke),
 .cpu_din(cpu_din),.cpu_port(1'b0),.cpu_port0(cpu_data),.cpu_port1(),
 .cpu_addr(cpu_addr),.cpu_req(cpu_req),.cpu_req_ack(cpu_ack),.cpu_we(cpu_we),.cpu_ds(2'b11),
 .bsram_addr(20'd0),.bsram_din(8'd0),.bsram_dout(),.bsram_req(1'b0),.bsram_req_ack(),.bsram_we(1'b0),
 .aram_16(1'b0),.aram_addr(16'd0),.aram_din(16'd0),.aram_dout(),.aram_req(1'b0),.aram_req_ack(),.aram_we(1'b0),
 .vram1_addr(15'd0),.vram1_din(8'd0),.vram1_dout(),.vram1_req(1'b0),.vram1_ack(),.vram1_we(1'b0),
 .vram2_addr(15'd0),.vram2_din(8'd0),.vram2_dout(),.vram2_req(1'b0),.vram2_ack(),.vram2_we(1'b0),
 .rv_addr(rv_addr),.rv_din(rv_din),.rv_ds(2'b11),.rv_dout(rv_data),.rv_req(rv_req),.rv_req_ack(rv_ack),.rv_we(rv_we),
 .menu_mode(menu_mode),.bg_enable(bg_enable),.bg_req(bg_req),.bg_addr(bg_addr),.bg_ack(bg_ack),.bg_valid(bg_valid),.bg_data(bg_data),.bg_word(bg_word),
 .refreshing(),.total_refresh());
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
    refreshes=refreshes+1;last_refresh=cycle;global_available=cycle+6;
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
     assert(dqm==0&&dut.dq_oen)else $fatal(1,"Read masks or bus contention");
     read_q0=word_index;read_valid[0]=1;reads=reads+1;available_cycle[ba]=cycle+3;
    end
   end
  endcase
  if(!busy)assert(cycle-last_refresh<600)else $fatal(1,"Refresh starved by request stream");
 end
end
integer elapsed,n,line;
task access(input bit writing,input[22:0]address,input[15:0]data,input[15:0]expected);
 integer cpu_elapsed;
 begin
  @(negedge clk);#1;cpu_we=writing;cpu_addr=address[22:1];cpu_din=data;cpu_req=~cpu_req;cpu_elapsed=0;
  while(cpu_ack!=cpu_req)begin @(posedge clk);#1;cpu_elapsed=cpu_elapsed+1;if(cpu_elapsed>450)$fatal(1,"CPU ack timeout");end
  repeat(4)@(posedge clk);#1;
  if(!writing)assert(cpu_data===expected)else $fatal(1,"CPU read mismatch addr=%h expected=%h got=%h",address,expected,cpu_data);
 end
endtask
initial begin
 repeat(3)@(posedge clk);@(negedge clk);#1;resetn=1;
 wait(!busy);#1;
 assert(precharges==1&&refreshes==2&&modes==1)else $fatal(1,"Init sequence");
 for(n=0;n<64;n=n+1)begin
  access(1,n*1022,16'hba00+n,0);access(0,n*1022,0,16'hba00+n);
 end
 // Check artwork upload through the same RV channel as the MCU's 32-bit bridge.
 @(negedge clk);#1;rv_we=1;rv_addr=23'h2003fc>>1;rv_din=16'h5678;rv_req=~rv_req;
 wait(rv_req==rv_ack);repeat(6)@(posedge clk);#1;
 assert(mem[23'h5003fc>>2][15:0]===16'h5678)else $fatal(1,"Artwork RV address translation");
 for(line=0;line<4;line=line+1)begin
  for(n=0;n<320;n=n+1)mem[(23'h5003fc>>2)+line*320+n]=32'h12340000+n+line*320;
  @(negedge clk);#1;bg_addr=20'h003fc+line*1280;bg_enable=1;bg_req=~bg_req;
  fork
   begin wait(dut.bg_state==dut.BG_READ);access(0,1022,0,16'hba01);end
   begin
  n=0;elapsed=0;
  while(bg_ack!=bg_req)begin
   @(posedge clk);#1;elapsed=elapsed+1;
   if(bg_valid)begin
    assert(bg_word==n&&bg_data==32'h12340000+n+line*320)else $fatal(1,"Artwork word %0d got %h at %0d",n,bg_data,bg_word);
    n=n+1;
   end
   if(elapsed>420)$fatal(1,"Artwork line deadline");
  end
  assert(n==320)else $fatal(1,"Incomplete artwork line");
   end
  join
  access(0,1022,0,16'hba01);
 end
 bg_enable=0;menu_mode=0;access(1,23'h3ffffe,16'h4567,0);access(0,23'h3ffffe,0,16'h4567);
 repeat(1200)@(posedge clk);
 assert(refreshes>8)else $fatal(1,"Missing refreshes");
 $display("PASS SNES SDRAM: cartridge/RV writes, four crossing-row artwork lines, cartridge resume and refresh");$finish;
end
initial begin #1000000;$fatal(1,"Simulation timeout");end
endmodule
