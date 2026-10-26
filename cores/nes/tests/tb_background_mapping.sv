`timescale 1ns/1ps
// Actual RV bridge/controller with a writable, command-level 8 MiB fixture.
// Check independent physical bank/row/column addresses, not an RV RAM shortcut.
module tb_background_mapping;
 reg clk=0,fclk=0,resetn=0;always #23.148148 clk=~clk;always #7.716049 fclk=~fclk;
 reg clkref=0;always @(posedge clk)clkref<=~clkref;
 reg valid=0;reg [31:0] address=0,wdata=0;reg [3:0] strobes=0;
 wire ready,req,ack,wordsel;wire [1:0] ds;wire [31:0] rdata;wire [15:0] dout;
 rv_bridge_under_test bridge(.clk(clk),.sys_resetn(resetn),.rv_valid(valid),.rv_wstrb(strobes),
  .rv_req_ack(ack),.rv_dout(dout),.rv_req(req),.rv_word(wordsel),.rv_ready(ready),.rv_ds(ds),.rv_rdata(rdata));
 wire [31:0] dq;wire [10:0] a;wire [1:0] ba;wire [3:0] dqm;wire ncs,nras,ncas,nwe,busy;
 sdram_nes #(.BACKGROUND(1)) controller(.clk(fclk),.resetn(resetn),.clkref(clkref),.busy(busy),
  .SDRAM_DQ(dq),.SDRAM_A(a),.SDRAM_BA(ba),.SDRAM_DQM(dqm),.SDRAM_nCS(ncs),
  .SDRAM_nRAS(nras),.SDRAM_nCAS(ncas),.SDRAM_nWE(nwe),.SDRAM_CKE(),
  .addrA(22'd0),.weA(1'b0),.dinA(8'd0),.oeA(1'b0),.doutA(),
  .addrB(22'd0),.weB(1'b0),.dinB(8'd0),.oeB(1'b0),.doutB(),
  .rv_addr({address[21:2],wordsel}),.rv_din(wordsel?wdata[31:16]:wdata[15:0]),
  .rv_ds(ds),.rv_dout(dout),.rv_req(req),.rv_req_ack(ack),.rv_we(|strobes),
  .bg_enable(1'b0),.bg_req(1'b0),.bg_addr(20'd0),.bg_ack(),.bg_data(),.bg_valid(),.bg_word(),.bg_idle());
 reg [31:0] memory[0:2097151];reg [10:0] rows[0:3];reg [3:0] opened=0;
 reg [2:0] pipe=0;reg [31:0] dp[0:2];integer location,byte_no;
 assign dq=pipe[2]?dp[2]:32'bz;
 always @(negedge fclk)begin
  pipe={pipe[1:0],1'b0};dp[2]=dp[1];dp[1]=dp[0];
  if(resetn)case({ncs,nras,ncas,nwe})
   4'b0011:begin rows[ba]=a;opened[ba]=1;end
   4'b0010:if(a[10])opened=0;else opened[ba]=0;
   4'b0100:begin
    if(!opened[ba])$fatal(1,"Write to closed bank");
    location=ba*524288+rows[ba]*256+a[7:0];#1;
    for(byte_no=0;byte_no<4;byte_no=byte_no+1)
     if(!dqm[byte_no])memory[location][byte_no*8+:8]=dq[byte_no*8+:8];
    if(a[10])opened[ba]=0;
   end
   4'b0101:begin
    if(!opened[ba])$fatal(1,"Read from closed bank");
    location=ba*524288+rows[ba]*256+a[7:0];dp[0]=memory[location];pipe[0]=1;
    if(a[10])opened[ba]=0;
   end
   4'b0001:if(opened!=0)$fatal(1,"Refresh with open bank");
  endcase
 end
 task store(input [31:0] addr,value);begin
  @(negedge clk);address=addr;wdata=value;strobes=15;valid=1;
  do @(negedge clk);while(!ready);
  valid=0;strobes=0;repeat(2)@(negedge clk);
 end endtask
 task check(input [31:0] addr,value);begin
  @(negedge clk);address=addr;strobes=0;valid=1;
  do @(negedge clk);while(!ready);
  if(rdata!==value)$fatal(1,"Readback %h got %h expected %h",addr,rdata,value);
  valid=0;repeat(2)@(negedge clk);
 end endtask
 integer i;reg [31:0] value;
 initial begin
  repeat(10)@(negedge clk);resetn=1;wait(!busy);
  store(0,32'h12345678);store(32'h00100000,32'h87654321);
  for(i=0;i<900;i=i+1)begin
   value=32'hd3a556ff^i;
   store(32'h00200000+i*1024,value);
   store(32'h002003fc+i*1024,~value);
  end
  for(i=0;i<900;i=i+1)begin
   value=32'hd3a556ff^i;
   if(memory[1572864+i*256]!==value || memory[1573119+i*256]!==~value)
    $fatal(1,"Physical bank-3 row mapping mismatch %0d",i);
   check(32'h00200000+i*1024,value);check(32'h002003fc+i*1024,~value);
  end
  check(0,32'h12345678);check(32'h00100000,32'h87654321);
  $display("PASS actual RV bridge/controller: all 900 framebuffer rows, both halfwords, physical bank-3 mapping and bank-2 sentinels");$finish;
 end
 initial begin #100000000;$fatal(1,"Mapping timeout");end
endmodule
