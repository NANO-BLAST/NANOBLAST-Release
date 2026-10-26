`timescale 1ns/1ps
module xor_ram_tb;
    reg clk=0;always #5 clk=~clk;
    reg [1:0] we=0;reg [5:0] wa=0,ra=0;reg [31:0] data=0;
    wire [31:0] q;reg [15:0] model[0:7];
    integer n,j,collisions=0,both=0;
    reg [31:0] rng=32'h3921abcd;
    snes_xor_ram dut(clk,we,wa,data,ra,q);
    always @(posedge clk) begin
        if(we[0])model[wa[2:0]]=data[15:0];
        if(we[1])model[wa[5:3]]=data[31:16];
    end
    task check;
        assert(q==={model[ra[5:3]],model[ra[2:0]]})else $fatal(1,"XOR RAM read/collision mismatch at %0d",n);
    endtask
    initial begin
        for(j=0;j<8;j=j+1)model[j]=0;
        #1;check();
        for(n=0;n<100000;n=n+1)begin
            @(negedge clk);
            rng=rng^(rng<<13);rng=rng^(rng>>17);rng=rng^(rng<<5);
            we=rng[1:0];wa=rng[7:2];ra=rng[13:8];data=rng^{rng[15:0],rng[31:16]};
            if(rng[16])wa[5:3]=wa[2:0];
            if(we==3)begin both=both+1;if(wa[5:3]==wa[2:0])collisions=collisions+1;end
            #1;check();@(posedge clk);#1;check();
        end
        assert(collisions>1000&&both>10000)else $fatal(1,"Insufficient dual-write coverage");
        $display("PASS XOR RAM: 100000 cycles, %0d simultaneous writes, %0d priority collisions, asynchronous reads and hold",both,collisions);
        $finish;
    end
endmodule
