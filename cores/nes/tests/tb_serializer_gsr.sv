`timescale 1ns/1ps
// Run with the installed GW2A prim_sim.v. Check the actual divider and
// serializer models; do not substitute a behavioral serializer stub.
module tb_serializer_gsr;
    reg fast = 0, gsri = 1, runtime_reset = 0;
    always #5 fast = ~fast;
    GSR GSR(.GSRI(gsri));
    wire pixel;
    CLKDIV #(.DIV_MODE("5"), .GSREN("true")) divider(
        .CLKOUT(pixel), .HCLKIN(fast), .RESETN(1'b1), .CALIB(1'b0));
    reg [9:0] word [2:0];
    reg [31:0] random_state = 32'h12345678;
    wire [2:0] serial;
    wire serial_clock;
    serializer #(.NUM_CHANNELS(3), .VIDEO_RATE(60.0)) dut(
        .clk_pixel(pixel), .clk_pixel_x5(fast), .reset(runtime_reset),
        .tmds_internal(word), .tmds(serial), .tmds_clock(serial_clock));
    reg [2:0] expected [0:9999], observed [0:9999];
    integer n_expected=0, n_observed=0, matched, mismatch;
    always @(negedge pixel) begin
        random_state = {random_state[30:0],
            random_state[31]^random_state[21]^random_state[1]^random_state[0]};
        word[0] = runtime_reset ? 10'b1101010100 : random_state[9:0];
        word[1] = runtime_reset ? 10'b1101010100 : random_state[19:10];
        word[2] = runtime_reset ? 10'b1101010100 : random_state[29:20];
    end
    always @(posedge pixel) if(gsri) begin
        for(integer bit_index=0;bit_index<10;bit_index=bit_index+1) begin
            expected[n_expected] = {word[2][bit_index],word[1][bit_index],word[0][bit_index]};
            n_expected=n_expected+1;
        end
    end
    always @(fast) if(gsri) begin
        #0.02;
        observed[n_observed]=serial;
        n_observed=n_observed+1;
    end
    initial begin
        word[0]=0;word[1]=0;word[2]=0;
        #1; gsri=0; #34; gsri=1;
        #14000;runtime_reset=1;
        #200;runtime_reset=0;
        #16000;
        matched=-1;
        // Allow only ONE fixed startup latency for the complete stream.
        // Compare across the runtime reset as well as before/after it.
        for(integer offset=0;offset<100;offset=offset+1) begin
            mismatch=0;
            for(integer bit_index=100;bit_index<5500;bit_index=bit_index+1)
                if(observed[bit_index+offset] !== expected[bit_index]) mismatch=mismatch+1;
            if(mismatch==0) matched=offset;
        end
        if(n_expected<5600 || n_observed<5600 || matched<0)
            $fatal(1,"Serializer stream mismatch: expected=%0d observed=%0d offset=%0d",n_expected,n_observed,matched);
        $display("PASS Gowin GSR serializer/divider: 5400 serial bits per lane, fixed latency %0d, runtime reset preserves phase",matched);
        $finish;
    end
endmodule
