`timescale 1ns/1ps
module addrgen_tb;
    reg clk=0;always #5 clk=~clk;
    reg resetn=0,en=0,pcdec=0,irq=0,emulation=0;
    reg [2:0] loadpc=0;
    reg [7:0] ctrl=0,din=0,dr=0,dbr=0;
    reg [1:0] indirect=0;
    reg [15:0] x=0,y=0,d=0,s=0,t=0;
    wire [15:0] pc[2],dx[2];wire [16:0] aa[2];wire [7:0] ab[2];
    wire carry[2],jump[2];
    AddrGen dut(clk,resetn,en,loadpc,pcdec,irq,ctrl,indirect,din,x,y,d,s,t,dr,dbr,emulation,pc[0],aa[0],ab[0],dx[0],carry[0],jump[0]);
    AddrGen_reference ref_addr(clk,resetn,en,loadpc,pcdec,irq,ctrl,indirect,din,x,y,d,s,t,dr,dbr,emulation,pc[1],aa[1],ab[1],dx[1],carry[1],jump[1]);
    reg [31:0] rng=32'h3921f00d;
    integer n;
    task check;
        assert({pc[0],aa[0],ab[0],dx[0],carry[0],jump[0]}==={pc[1],aa[1],ab[1],dx[1],carry[1],jump[1]})
            else $fatal(1,"65C816 address mismatch at cycle %0d",n);
        assert(dut.NewAAL===ref_addr.NewAAL && dut.NewAAH===ref_addr.NewAAH)
            else $fatal(1,"65C816 arithmetic mismatch at cycle %0d",n);
    endtask
    initial begin
        @(posedge clk);#1;
        for(n=0;n<200000;n=n+1)begin
            @(negedge clk);
            rng=rng^(rng<<13);rng=rng^(rng>>17);rng=rng^(rng<<5);
            resetn=n%997!=0;en=rng[0];loadpc=n[13:11];ctrl=n[7:0];indirect=n[9:8];emulation=n[10];
            pcdec=rng[1];irq=rng[2];din=rng[10:3];dr=rng[18:11];dbr=rng[26:19];
            x=rng[15:0];y=rng[31:16];d=x^y;s=~x;t=~y;
            #1;check();@(posedge clk);#1;check();
        end
        $display("PASS 65C816 address generator: 200000 cycles, all address/indirection/load controls, both CPU modes, holds, resets and carries");
        $finish;
    end
endmodule
