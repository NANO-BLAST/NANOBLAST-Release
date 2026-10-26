`timescale 1ns/1ps
// Real firmware loader process, stimulated through its SPI-byte/reset ports.
// Checks deterministic cold reset and reset/restart during an active transfer.
module tb_boot_reset;
reg clk=0;always #5 clk=~clk;
reg resetn=0,busy=1,byte_valid=0;
reg [7:0] byte_data=0;
wire loaded,loading,start,write;
wire [20:0] address;
wire [7:0] data;
wire [3:0] strobes;
reg rv_valid=0,rv_ack=0;
reg [3:0] rv_wstrb=0;
reg [15:0] rv_dout=0;
wire rv_req,rv_word,rv_ready;
wire [1:0] rv_ds;
wire [31:0] rv_rdata;
rv_bridge_under_test bridge(.clk(clk),.sys_resetn(resetn),.rv_valid(rv_valid),
 .rv_wstrb(rv_wstrb),.rv_req_ack(rv_ack),.rv_dout(rv_dout),
 .rv_req(rv_req),.rv_word(rv_word),.rv_ready(rv_ready),.rv_ds(rv_ds),.rv_rdata(rv_rdata));
reg spi_start=0;
wire spi_busy,spi_strobe;
wire [7:0] spi_data;
reg clkref=0;
always @(negedge clk) clkref=~clkref;
wire ram_init_busy,ram_ack;
wire [3:0] ram_cmd;
tri [31:0] ram_dq;
sdram_nes #(.FREQ(1000000)) ram(.clk(clk),.resetn(resetn),.clkref(clkref),
 .busy(ram_init_busy),.SDRAM_DQ(ram_dq),.SDRAM_nCS(ram_cmd[3]),
 .SDRAM_nRAS(ram_cmd[2]),.SDRAM_nCAS(ram_cmd[1]),.SDRAM_nWE(ram_cmd[0]),
 .addrA(22'd0),.weA(1'b0),.dinA(8'd0),.oeA(1'b0),
 .addrB(22'd0),.weB(1'b0),.dinB(8'd0),.oeB(1'b0),
 .rv_addr(20'd0),.rv_din(16'd0),.rv_ds(2'd0),.rv_req(1'b0),.rv_we(1'b0),.rv_req_ack(ram_ack));
spiflash #(.LEN(4)) spi_reader(.clk(clk),.resetn(resetn),.miso(1'b0),
 .start(spi_start),.busy(spi_busy),.dout(spi_data),.dout_strb(spi_strobe));
boot_loader_under_test dut(.clk(clk),.resetn(resetn),.ram_busy(busy),
 .flash_dout(byte_data),.flash_out_strb(byte_valid),.loaded(loaded),
 .loading(loading),.start(start),.write(write),.address(address),.data(data),.strobes(strobes));
task tick;begin @(posedge clk);#1;@(negedge clk);end endtask
task check_reset;
 begin
  resetn=0;tick();
  if(loaded!==0 || loading!==0 || start!==0 || write!==0 || strobes!==0)
   $fatal(1,"firmware reset did not clear all loader controls");
  if(rv_req!==0 || rv_ready!==0 || rv_word!==0 || rv_ds!==0)
   $fatal(1,"RISC-V memory request reset is not deterministic");
  if(spi_busy!==0 || spi_strobe!==0)
   $fatal(1,"SPI reader reset left active transfer controls");
  if(ram_init_busy!==1 || ram_ack!==0 || ram_cmd!==4'b1111)
   $fatal(1,"SDRAM reset did not establish idle command/request state");
  resetn=1;busy=1;tick();
  if(start!==0 || write!==0) $fatal(1,"loader ran before SDRAM initialized");
  busy=0;tick();
  if(start!==1 || loading!==1) $fatal(1,"firmware did not restart");
  tick();
 end
endtask
integer i;
initial begin
 check_reset();
 for(i=0;i<8;i=i+1) begin
  byte_data=i^8'ha5;byte_valid=1;tick();byte_valid=0;
  if(write!==1 || address!==i || data!==(i^8'ha5) || strobes!==(1<<(i%4)))
   $fatal(1,"firmware byte address/data/strobe incorrect at %0d",i);
  tick();
 end
 check_reset();
 byte_data=8'h3c;byte_valid=1;tick();byte_valid=0;
 if(address!==0 || data!==8'h3c || strobes!==1 || write!==1)
  $fatal(1,"interrupted transfer restart did not begin at byte zero");
 // Upper-half-only write: one request, correct byte lanes, one completion.
 rv_valid=1;rv_wstrb=4'b1100;tick();
 if(rv_req!==1 || rv_word!==1 || rv_ds!==3) $fatal(1,"upper write request incorrect");
 rv_ack=1;tick();
 if(rv_ready!==1) $fatal(1,"upper write completion missing");
 rv_valid=0;tick();
 // Full read: two halfword requests and assembled low/high data.
 rv_valid=1;rv_wstrb=0;tick();
 if(rv_req!==0 || rv_word!==0 || rv_ds!==3) $fatal(1,"read request incorrect");
 rv_ack=0;tick();rv_dout=16'h1234;tick();
 rv_ack=1;rv_dout=16'habcd;tick();tick();
 if(rv_ready!==1 || rv_rdata!==32'habcd1234) $fatal(1,"read assembly/completion incorrect");
 rv_valid=0;tick();
 // Reset cancels a pending memory request and an in-flight SPI byte.
 rv_valid=1;rv_wstrb=1;spi_start=1;tick();spi_start=0;
 repeat(20) tick();rv_valid=0;rv_ack=0;check_reset();
 // Shorten only the initialization delay parameter, retaining the actual
 // SDRAM state machine. No SDRAM data model is supplied by this reset test.
 repeat(250) tick();
 if(ram_init_busy!==0 || ram_ack!==0)
  $fatal(1,"SDRAM failed to initialize after reset");
 $display("PASS firmware loader reset, SDRAM wait, byte addresses/lanes and interrupted-load restart");
 $finish;
end
endmodule
