`timescale 1ns/1ps
module dsp_voice_ram_tb;
    reg clk=0;always #5 clk=~clk;
    reg resetn=0,enable=1,pal=0,write_n=1;
    reg [15:0] smp_addr=0;
    reg [7:0] smp_data=0,ram_data=0;
    wire smp_en[2],smp_ce[2],ram_we[2],ram_oe[2],ram_ce[2],ready[2];
    wire [7:0] smp_read[2],ram_write[2];
    wire [15:0] ram_addr[2],audio_l[2],audio_r[2];
    DSP dut(.CLK(clk),.RST_N(resetn),.ENABLE(enable),.PAL(pal),
        .SMP_EN(smp_en[0]),.SMP_A(smp_addr),.SMP_DO(smp_data),.SMP_DI(smp_read[0]),.SMP_WE_N(write_n),.SMP_CE(smp_ce[0]),
        .RAM_A(ram_addr[0]),.RAM_Q(ram_data),.RAM_D(ram_write[0]),.RAM_WE_N(ram_we[0]),.RAM_OE_N(ram_oe[0]),.RAM_CE_N(ram_ce[0]),
        .AUDIO_L(audio_l[0]),.AUDIO_R(audio_r[0]),.SND_RDY(ready[0]),
        .DBG_REG(8'd0),.DBG_DAT_IN(8'd0),.DBG_DAT_WR(1'b0),.DBG_DAT_OUT());
    DSP_reference ref_dsp(.CLK(clk),.RST_N(resetn),.ENABLE(enable),.PAL(pal),
        .SMP_EN(smp_en[1]),.SMP_A(smp_addr),.SMP_DO(smp_data),.SMP_DI(smp_read[1]),.SMP_WE_N(write_n),.SMP_CE(smp_ce[1]),
        .RAM_A(ram_addr[1]),.RAM_Q(ram_data),.RAM_D(ram_write[1]),.RAM_WE_N(ram_we[1]),.RAM_OE_N(ram_oe[1]),.RAM_CE_N(ram_ce[1]),
        .AUDIO_L(audio_l[1]),.AUDIO_R(audio_r[1]),.SND_RDY(ready[1]),
        .DBG_REG(8'd0),.DBG_DAT_IN(8'd0),.DBG_DAT_WR(1'b0),.DBG_DAT_OUT());
    reg [31:0] rng=32'h3921abcd;
    reg phase=0;reg [6:0] reg_index=0;
    integer n,samples=0,writes=0;
    initial begin
        for(n=0;n<1000000;n=n+1) begin
            @(negedge clk);
            rng=rng^(rng<<13);rng=rng^(rng>>17);rng=rng^(rng<<5);
            resetn=n>3 && n%100003!=0;
            enable=rng[9:0]!=0;pal=n[18];ram_data=rng[7:0];
            write_n=1;
            if(smp_en[0] && smp_ce[0] && resetn) begin
                write_n=0;smp_addr=phase?16'h00f3:16'h00f2;
                // Exercise the real register interface, voices, envelope modes,
                // BRR blocks, echo coefficients, key-on and key-off.
                smp_data=phase?rng[15:8]:{1'b0,reg_index};
                if(phase)begin reg_index=reg_index+1;writes=writes+1;end
                phase=~phase;
            end
            @(posedge clk);#1;
            assert({smp_en[0],smp_ce[0],smp_read[0],ram_addr[0],ram_write[0],ram_we[0],ram_oe[0],ram_ce[0],audio_l[0],audio_r[0],ready[0]}===
                   {smp_en[1],smp_ce[1],smp_read[1],ram_addr[1],ram_write[1],ram_we[1],ram_oe[1],ram_ce[1],audio_l[1],audio_r[1],ready[1]})
                else $fatal(1,"Real DSP output mismatch at cycle %0d",n);
            for(integer v=0;v<8;v=v+1) begin
                assert(dut.read_brr_addr(3'(v))===ref_dsp.BRR_ADDR[v])else $fatal(1,"BRR address reset/read mismatch");
                assert(dut.read_interp_pos(3'(v))===ref_dsp.INTERP_POS[v])else $fatal(1,"Interpolation reset/read mismatch");
                assert(dut.read_env(3'(v))===ref_dsp.ENV[v])else $fatal(1,"Envelope reset/read mismatch");
                assert(dut.read_tenvx(3'(v))===ref_dsp.TENVX[v])else $fatal(1,"ENVX reset/read mismatch");
            end
            if(ready[0])samples=samples+1;
        end
        assert(samples>100 && writes>1000)else $fatal(1,"Insufficient DSP exercise");
        $display("PASS real DSP voice RAM: 1000000 cycles, %0d audio samples, %0d SMP register writes, pauses, resets and both region inputs",samples,writes);
        $finish;
    end
endmodule
