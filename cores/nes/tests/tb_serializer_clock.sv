`timescale 1ns/1ps
// Run with the installed Gowin GW2A prim_sim.v, not an invented OSER10 model.
module tb_serializer_clock;
    reg pixel_clk=0, fast_clk=0, reset=0;
    always #5 pixel_clk=!pixel_clk;
    always #1 fast_clk=!fast_clk;
    reg [9:0] words [2:0];
    wire [2:0] data_out;
    wire clock_out;
    serializer #(.VIDEO_RATE(74.25e6)) dut(pixel_clk,fast_clk,reset,words,data_out,clock_out);
    reg checking=0;
    realtime last_rise=0, last_fall=0;
    integer periods=0;
    always @(posedge clock_out) if(checking) begin
        if(last_rise!=0 && $realtime-last_rise!=10) $fatal(1,"clock period");
        if(last_fall!=0 && $realtime-last_fall!=5) $fatal(1,"clock low width");
        last_rise=$realtime; periods++;
    end
    always @(negedge clock_out) if(checking) begin
        if(last_rise!=0 && $realtime-last_rise!=5) $fatal(1,"clock high width");
        last_fall=$realtime;
    end
    always @(fast_clk) begin
        #0.01;
        if(checking && (clock_out !== data_out[0] || $isunknown(clock_out)))
            $fatal(1,"clock and identical data lane differ");
    end
    initial begin
        words[0]=10'b1111100000;
        words[1]=10'b0101010101;
        words[2]=10'b0011110000;
        #0.2; reset=1;
        #30; reset=0;
        #100; checking=1;
        #1000;
        if(periods<99) $fatal(1,"missing clock periods");
        $display("PASS vendor OSER10 model: matched clock/data path, 5/5 duty, pixel-rate period");
        $finish;
    end
endmodule
