`timescale 1ns/1ps
module control_tb;
reg clk=0;always #5 clk=~clk;
reg resetn=0,enable=1;wire cpu,vdp,pix,sp;
sms_nano_ce dut(.clk(clk),.resetn(resetn),.enable(enable),.ce_cpu(cpu),.ce_vdp(vdp),.ce_pix(pix),.ce_sp(sp));
reg[3:0]a=0,b=0;reg[7:0]da=0,db=0;reg wa=0,wb=0;wire[7:0]qa,qb;
dpram #(.widthad_a(4),.NO_RW_CHECK(1))ram(.clock_a(clk),.clock_b(clk),.address_a(a),.address_b(b),.data_a(da),.data_b(db),.wren_a(wa),.wren_b(wb),.q_a(qa),.q_b(qb));
integer n,cpus=0,vdps=0,pixels=0,sprites=0;
initial begin
 repeat(3)@(negedge clk);resetn=1;
 for(n=0;n<1000000;n=n+1)begin @(negedge clk);cpus=cpus+cpu;vdps=vdps+vdp;pixels=pixels+pix;sprites=sprites+sp;end
 assert(cpus>=55239&&cpus<=55241&&vdps>=165718&&vdps<=165722&&pixels>=82859&&pixels<=82861&&sprites>=414299&&sprites<=414301)
 else $fatal(1,"Fractional SMS clock rates cpu=%0d vdp=%0d pixel=%0d sprite=%0d",cpus,vdps,pixels,sprites);
 enable=0;repeat(3)@(negedge clk);repeat(100)begin @(negedge clk);assert(!cpu&&!vdp&&!pix&&!sp)else $fatal(1,"Menu pause enable");end
 // Same-address VRAM read/write is explicitly forwarded rather than exposing
 // the memory primitive's unspecified cross-port collision output.
 a=3;b=3;da=8'h5a;wa=1;@(negedge clk);assert(qb==8'h5a)else $fatal(1,"VRAM portB collision bypass");
 wa=0;@(negedge clk);assert(qa==8'h5a&&qb==8'h5a)else $fatal(1,"VRAM stored value");
 wb=1;db=8'hc3;@(negedge clk);assert(qa==8'hc3)else $fatal(1,"VRAM portA collision bypass");
 wb=0;@(negedge clk);assert(qa==8'hc3&&qb==8'hc3)else $fatal(1,"VRAM second stored value");
 $display("PASS controls: fractional SMS clocks, menu pause and deterministic dual-port VRAM collision bypass");$finish;
end
endmodule
