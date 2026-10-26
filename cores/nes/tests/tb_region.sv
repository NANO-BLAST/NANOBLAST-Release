`timescale 1ns/1ps
module tb_region;
reg clk=0;always #5 clk=~clk;
reg resetn=0,select_ctrl=0;reg [3:0] strobes=0;reg [31:0] data=0;
wire pal;
region_control control(clk,resetn,select_ctrl,strobes,data,pal);
reg reset=1,pause_menu=0;reg [1:0] mode=1;
wire cpu_tick,ppu_tick;
nes_dividers dividers(clk,reset,pause_menu,mode,1'b0,cpu_tick,ppu_tick);
wire [8:0] line,dot;wire entering;
ClockGen counter(.clk(clk),.ce(1'b1),.reset(reset),.sys_type(mode),
 .is_rendering(1'b0),.scanline(line),.cycle(dot),.entering_vblank(entering));
task write_ctrl(input [31:0] value,input [3:0] mask);
begin @(negedge clk);select_ctrl=1;data=value;strobes=mask;
 @(negedge clk);select_ctrl=0;strobes=0;end endtask
task check_ratio(input [1:0] region,input integer masters,input integer expected_cpu,input integer expected_ppu);
integer cpus,ppus,i;
begin
 @(negedge clk);mode=region;
 repeat(128)@(negedge clk);
 cpus=0;ppus=0;
 for(i=0;i<masters;i=i+1)begin
  @(posedge clk);if(cpu_tick)cpus=cpus+1;if(ppu_tick)ppus=ppus+1;
  @(negedge clk);
 end
 if(cpus!=expected_cpu || ppus!=expected_ppu)$fatal(1,"region %d clocks CPU %d PPU %d",region,cpus,ppus);
end endtask
task check_frame(input [1:0] region,input integer expected);
integer dots;
begin
 @(negedge clk);mode=region;reset=1;
 repeat(4)@(negedge clk);reset=0;
 while(!entering)@(negedge clk);
 @(negedge clk);dots=1;
 while(!entering)begin @(negedge clk);dots=dots+1;end
 if(dots!=expected)$fatal(1,"region %d frame dots %d expected %d",region,dots,expected);
end endtask
initial begin
 repeat(4)@(negedge clk);if(pal!==0)$fatal(1,"reset default");resetn=1;
 write_ctrl(32'h101,4'hf);if(pal!==1)$fatal(1,"PAL load");
 write_ctrl(0,4'hf);if(pal!==1)$fatal(1,"load end changed region");
 write_ctrl(2,4'hf);if(pal!==1)$fatal(1,"invalid control changed region");
 write_ctrl(1,4'h2);if(pal!==1)$fatal(1,"no low-byte strobe");
 write_ctrl(1,4'hf);if(pal!==0)$fatal(1,"legacy NTSC load");
 write_ctrl(32'h101,4'h1);if(pal!==0)$fatal(1,"unwritten high byte selected PAL");
 @(negedge clk);reset=0;
 check_ratio(0,12000,1000,3000);
 check_ratio(1,12800,1000,3200);
 @(negedge clk);pause_menu=1;
 repeat(64)begin @(posedge clk);if(cpu_tick || ppu_tick)$fatal(1,"menu did not freeze clocks");end
 @(negedge clk);pause_menu=0;
 check_frame(0,341*262);
 check_frame(1,341*312);
 $display("PASS load-only PAL/NTSC selection, byte strobes, 3:1 NTSC and 16:5 PAL PPU/CPU ratios, menu freeze, 262/312-line frames");
 $finish;
end
initial begin #10000000;$fatal(1,"timeout");end
endmodule
