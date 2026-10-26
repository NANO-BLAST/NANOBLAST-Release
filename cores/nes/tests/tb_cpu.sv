`timescale 1ns/1ps
module tb_cpu;
reg clk=0;always #5 clk=~clk;
reg resetn=0,irqn=1,nmin=1;
wire [23:0] addr;wire [7:0] dout;wire rnw,sync;
reg [7:0] mem[0:65535];
wire [7:0] din=rnw?mem[addr[15:0]]:dout;
T65 dut(.Mode(2'b00),.BCD_en(1'b0),.Res_n(resetn),.Enable(1'b1),.Clk(clk),
 .Rdy(1'b1),.Abort_n(1'b1),.IRQ_n(irqn),.NMI_n(nmin),.SO_n(1'b1),
 .R_W_n(rnw),.Sync(sync),.A(addr),.DI(din),.DO(dout));
always @(posedge clk)if(!rnw)mem[addr[15:0]]<=dout;
task tick;begin @(posedge clk);#1;@(negedge clk);end endtask
task reset_cpu;begin resetn=0;irqn=1;nmin=1;repeat(5)tick();resetn=1;end endtask
task await_fetch(input [15:0] target);
 integer n;begin n=0;
 while(!(sync && addr[15:0]==target) && n<80)begin tick();n=n+1;end
 if(n==80)$fatal(1,"CPU failed to fetch %h",target);
 end endtask
reg [7:0] kil[0:11];integer i,j;
initial begin
 kil[0]='h02;kil[1]='h12;kil[2]='h22;kil[3]='h32;kil[4]='h42;kil[5]='h52;
 kil[6]='h62;kil[7]='h72;kil[8]='h92;kil[9]='hb2;kil[10]='hd2;kil[11]='hf2;
 for(j=0;j<65536;j=j+1)mem[j]=8'hea;
 mem['hfffc]=0;mem['hfffd]='h80;
 mem['hfffa]=0;mem['hfffb]='h90;mem['hfffe]=0;mem['hffff]='h90;
 for(i=0;i<12;i=i+1)begin
  mem['h8000]=kil[i];reset_cpu();await_fetch('h8000);tick();
  for(j=0;j<40;j=j+1)begin
   if(j==10)begin irqn=0;nmin=0;end
   tick();if(sync || !rnw)$fatal(1,"KIL %h resumed or wrote",kil[i]);
  end
  // Only reset recovers; legal LDX and immediate NOP must still execute.
  mem['h8000]='ha2;mem['h8001]='h37;mem['h8002]='h82;mem['h8003]='hff;
  mem['h8004]='h8e;mem['h8005]=0;mem['h8006]=2;mem['h0200]=0;
  reset_cpu();await_fetch('h8007);
  if(mem['h0200]!==8'h37)$fatal(1,"KIL recovery or LDX/NOP failed");
 end
 $display("PASS all 12 KIL opcodes, interrupt immunity, reset recovery, LDX/NOP");$finish;
end
endmodule
