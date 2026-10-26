`timescale 1ns/1ps
module srtc_tb;
reg clk=0;always #5 clk=~clk;
reg a0=0,cs=0,rd_n=1,wr_n=1;reg[7:0]di=0;wire[7:0]dout;
reg[64:0]ext=0;
SRTC dut(.CLK(clk),.A0(a0),.DI(di),.DO(dout),.CS(cs),.CPURD_N(rd_n),.CPUWR_N(wr_n),.SYSCLKF_CE(1'b1),.EXT_RTC(ext));
task write_nibble(input[3:0]value);
 begin @(negedge clk);cs=1;a0=1;di={4'd0,value};wr_n=0;@(negedge clk);cs=0;wr_n=1;end
endtask
task read_nibble(input[3:0]expected);
 begin @(negedge clk);cs=1;a0=0;rd_n=0;#1;
  assert(dout=={4'd0,expected})else $fatal(1,"RTC serial mismatch index=%0d got=%h expected=%h",dut.INDEX,dout,expected);
  @(negedge clk);cs=0;rd_n=1;
 end
endtask
integer n;
initial begin
 repeat(3)@(negedge clk);ext={1'b1,64'd0};repeat(3)@(negedge clk);
 write_nibble(4'he);write_nibble(0);
 for(n=0;n<12;n=n+1)write_nibble(4'(n%10));
 write_nibble(4'hd);read_nibble(4'hf);
 for(n=0;n<12;n=n+1)read_nibble(4'(n%10));
 read_nibble(0);read_nibble(4'hf);read_nibble(4'hf);read_nibble(0);
 // Exact terminal count is unchanged by bounding the second divider.
 @(negedge clk);dut.SEC_DIV=21477268;
 @(posedge clk);#1;assert(!dut.SEC_TICK)else $fatal(1,"RTC early tick");
 @(posedge clk);#1;assert(dut.SEC_TICK&&dut.SEC_DIV==0)else $fatal(1,"RTC second boundary");
 @(posedge clk);#1;assert(!dut.SEC_TICK)else $fatal(1,"RTC tick repeated");
 $display("PASS S-RTC serial write/read, start/end markers, index wrap and second-divider boundary");$finish;
end
endmodule
