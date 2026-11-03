`timescale 1ns/1ps
module loader_tb;
reg clk=0,resetn=0,loading=0,valid=0;reg[7:0]byte_in=0;always #10 clk=~clk;
wire running,fault,iw,rom,pwe,pack;wire[25:0]ia;wire[7:0]id;wire[21:0]pa;wire[1:0]pb,pm;wire[15:0]pd;
wire req,wr;wire[22:0]addr;wire[31:0]din;wire[3:0]mask;reg ack=0;reg[31:0]dout=0;
reg breq=0,bwr=0;wire back;wire[31:0]bdata;
s16_loader #(.MIN_BYTES(320),.MAX_BYTES(1024))dut(.clk(clk),.resetn(resetn),.loading(loading),.load_valid(valid),.load_data(byte_in),.ready(1'b1),
 .running(running),.fault(fault),.ioctl_addr(ia),.ioctl_dout(id),.ioctl_wr(iw),.ioctl_rom(rom),
 .prog_we(pwe),.prog_addr(pa),.prog_ba(pb),.prog_data(pd),.prog_mask(pm),.prog_ack(pack),
 .bank_req(breq),.bank_wr(bwr),.bank_addr(23'h600004),.bank_din(32'h12345678),.bank_wmask(4'hf),.bank_ack(back),.bank_dout(bdata),
 .mem_req(req),.mem_wr(wr),.mem_addr(addr),.mem_din(din),.mem_wmask(mask),.mem_ack(ack),.mem_dout(dout));
jtframe_dwnld #(.SDRAMW(23),.HEADER(32),.BA1_START(64),.BA2_START(128),.BA3_START(192),.PROM_START(256),.SWAB(1))download(
 .clk(clk),.ioctl_rom(rom),.ioctl_addr({1'b0,ia}),.ioctl_dout(id),.ioctl_wr(iw),.prog_addr(pa),.prog_data(pd),.prog_mask(pm),.prog_we(pwe),.prog_rd(),.prog_ba(pb),
 .gfx4_en(1'b0),.gfx8_en(1'b0),.gfx16_en(1'b0),.gfx16b_en(1'b0),.gfx16c_en(1'b0),.prom_we(),.header(),.sdram_ack(pack));
reg[7:0]mem[0:255];integer delay_count=0,writes=0;
always @(posedge clk)begin
 if(req!=ack)begin
  if(delay_count<9)delay_count<=delay_count+1;
  else begin
   delay_count<=0;ack<=req;dout<=32'hcafeabcd;
   if(wr)begin
    if(mask[0])mem[(addr[22:21]*64)+addr[5:0]]<=din[7:0];
    if(mask[1])mem[(addr[22:21]*64)+addr[5:0]+1]<=din[15:8];
    if(mask[2])mem[(addr[22:21]*64)+addr[5:0]+2]<=din[23:16];
    if(mask[3])mem[(addr[22:21]*64)+addr[5:0]+3]<=din[31:24];
    writes<=writes+1;
   end
  end
 end
 if(!resetn)begin ack<=0;delay_count<=0;end
end
function automatic[7:0]pattern(input integer a);
 if(a<32)case(a)17:pattern=1;24:pattern=8'h40;default:pattern=0;endcase
 else pattern=(a-32)^8'ha5;
endfunction
task stream(input integer size,input integer spacing,input bit corrupt);
 integer i;
 begin
  @(negedge clk);loading=1;repeat(5)@(negedge clk);
  for(i=0;i<size;i=i+1)begin
   valid=1;byte_in=corrupt&&i==17?0:pattern(i);@(negedge clk);valid=0;
   repeat(spacing-1)@(negedge clk);
  end
  loading=0;repeat(160)@(negedge clk);
 end
endtask
integer i;
initial begin
 repeat(8)@(negedge clk);resetn=1;repeat(5)@(negedge clk);
 stream(320,40,0);
 if(!running||fault||rom||writes!=256)$fatal(1,"download running=%b fault=%b writes=%d",running,fault,writes);
 for(i=0;i<256;i=i+1)if(mem[i]!==pattern(32+i))$fatal(1,"mapping/byte swap at %d got%h expected%h",i,mem[i],pattern(32+i));
 breq=1;wait(back==1);if(bdata!==32'hcafeabcd)$fatal(1,"bank read response");
 stream(320,40,0);if(!running||fault||writes!=512)$fatal(1,"reload failed");
 stream(319,40,0);if(running||!fault)$fatal(1,"truncation accepted");
 stream(320,40,1);if(running||!fault)$fatal(1,"wrong profile accepted");
 stream(320,1,0);if(running||!fault)$fatal(1,"FIFO overflow accepted");
 $display("PASS loader: upstream download mapping, all byte lanes/banks, drain, bank reads, reload, malformed/truncated ROM and FIFO overflow");$finish;
end
initial begin #3000000;$fatal(1,"timeout");end
endmodule
