`timescale 1ns/1ps
module echo_history_tb;
    reg clk=0;always #5 clk=~clk;
    reg resetn=0,we=0,channel=0;
    reg [14:0] din=0;
    reg [2:0] index=0;
    wire signed [14:0] left_sample,right_sample;
    reg [14:0] reference[0:1][0:7];
    integer i,j,n;
    reg [31:0] random_state=32'h187f34ab;
    snes_echo_history dut(clk,resetn,we,channel,din,index,left_sample,right_sample);
    always @(posedge clk) begin
        if (!resetn) begin
            for(integer a=0;a<2;a=a+1)
                for(integer b=0;b<8;b=b+1) reference[a][b]<=0;
        end else if(we) begin
            for(integer b=0;b<7;b=b+1) reference[channel][b]<=reference[channel][b+1];
            reference[channel][7]<=din;
        end
    end
    task check_all;
        for(integer k=0;k<8;k=k+1) begin
            index=k;#0.05;
            assert(left_sample===reference[0][k] && right_sample===reference[1][k])
                else $fatal(1,"Echo mismatch cycle %0d index %0d",n,k);
        end
    endtask
    initial begin
        // Poison RAM so reset masking is verified independently of power-up data.
        for(i=0;i<8;i=i+1) begin dut.left_mem[i]=15'h5555;dut.right_mem[i]=15'h1234;end
        @(posedge clk);#1;check_all();
        for(n=0;n<100000;n=n+1) begin
            @(negedge clk);
            random_state=random_state^(random_state<<13);
            random_state=random_state^(random_state>>17);
            random_state=random_state^(random_state<<5);
            resetn=(n%997!=0);we=random_state[0];channel=random_state[1];din=random_state[30:16];
            #1;check_all();
            @(posedge clk);#1;check_all();
        end
        $display("PASS DSP echo history: exact shift-buffer equivalence, both channels/all taps, reset masking, holds and wrap (100000 cycles)");
        $finish;
    end
endmodule
