`timescale 1ns/1ps
module dspn_stack_tb;
    reg clk=0;always #5 clk=~clk;
    reg ce=0,resetn=0,enable=1,a0=0,cs_n=1,rd_n=1,wr_n=1,dp_sel=0,rev=0;
    reg [7:0] din=0;reg [11:0] dp_addr=0;reg [2:0] version=0;
    wire [7:0] dout[2];
    DSPn dut(clk,ce,resetn,enable,a0,din,dout[0],cs_n,rd_n,wr_n,dp_addr,dp_sel,version,rev);
    DSPn_reference reference_dsp(clk,ce,resetn,enable,a0,din,dout[1],cs_n,rd_n,wr_n,dp_addr,dp_sel,version,rev);
    integer mode,n,v,pushes=0,returns=0;
    reg [31:0] rng=32'h3921abcd;
    initial begin
        for(mode=0;mode<6;mode=mode+1)begin
            @(negedge clk);resetn=0;version=mode<2?3'd0:3'(mode-1);rev=(mode==1);
            // Include all supported DSP1/1B/2/3/4 programs and the engine's
            // existing ST010 ROM path; do not reduce the cartridge hardware.
            for(v=0;v<8;v=v+1)dut.STACK_RAM[v]=11'(v^11'h719);
            repeat(3)@(posedge clk);
            for(n=0;n<150000;n=n+1)begin
                @(negedge clk);
                rng=rng^(rng<<13);rng=rng^(rng>>17);rng=rng^(rng<<5);
                resetn=n%65537!=0;ce=rng[0];enable=rng[9:1]!=0;
                a0=rng[10];cs_n=0;rd_n=rng[11];wr_n=!rd_n;
                din=rng[23:16];dp_addr=rng[27:16];dp_sel=rng[12];
                if(resetn&&dut.EN) begin
                    if(dut.OP_INSTR==dut.INSTR_RT)returns=returns+1;
                    if(dut.OP_INSTR==dut.INSTR_JP&&dut.OP_BRCH[8:6]==3'b101&&dut.OP_BRCH[5:0]==0)pushes=pushes+1;
                end
                @(posedge clk);#1;
                assert(dout[0]===dout[1] && dut.PC===reference_dsp.PC && dut.SP===reference_dsp.SP)
                    else $fatal(1,"Cartridge DSP stack mismatch mode %0d cycle %0d",mode,n);
                for(v=0;v<8;v=v+1)
                    assert(dut.read_stack(3'(v))===reference_dsp.STACK_RAM[v])else $fatal(1,"Unwritten cartridge stack observed");
            end
        end
        assert(pushes>10 && returns>10)else $fatal(1,"Insufficient DSP stack coverage: %0d calls %0d returns",pushes,returns);
        $display("PASS cartridge DSP stack: six ROM variants, 900000 cycles, %0d calls, %0d returns, holds, wrap and reset masking",pushes,returns);
        $finish;
    end
endmodule
