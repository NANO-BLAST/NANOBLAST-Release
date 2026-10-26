`timescale 1ns/1ps
// This bench checks the actual timing generator, not the electrical serializer
// or HDMI auxiliary packets. The vendor serializer is a compile-only stub.
module OSER10 #(parameter GSREN="false", LSREN="true")
             (output wire Q, input wire D0,D1,D2,D3,D4,D5,D6,D7,D8,D9,
              input wire PCLK,FCLK,RESET);
    assign Q = D0;
endmodule

module tb_hdmi_video;
    reg clk = 0;
    reg reset = 1;
    always #5 clk = ~clk;
    wire [10:0] x;
    wire [9:0] y;
    wire [2:0] serial;
    wire serial_clock;
    reg [15:0] audio [1:0];
    hdmi #(.VIDEO_ID_CODE(4), .DVI_OUTPUT(1), .VIDEO_REFRESH_RATE(60.0)) dut (
        .clk_pixel(clk), .clk_pixel_x5(clk), .clk_audio(1'b0),
        .rgb(24'h804020), .reset(reset), .reset_serializer(reset), .audio_sample_word(audio),
        .tmds(serial), .tmds_clock(serial_clock), .cx(x), .cy(y)
    );
    integer horizontal_high = 0, vertical_high = 0;
    initial begin
        repeat (4) @(negedge clk);
        reset = 0;
        // CTA VIC 4: 1650 clocks/line, 750 lines, +40-clock H sync,
        // +5-line V sync, 1280x720 active. Inspect a complete frame.
        for (integer n=0; n<1650*750; n=n+1) begin
            #0.01;
            if (x !== n%1650 || y !== n/1650) $fatal(1,"raster position %0d",n);
            if (dut.hsync !== (x>=1390 && x<1430)) $fatal(1,"H sync at %0d",n);
            horizontal_high += dut.hsync;
            vertical_high += dut.vsync;
            @(negedge clk);
        end
        if (x !== 0 || y !== 0) $fatal(1,"frame did not wrap");
        if (horizontal_high != 40*750 || vertical_high != 5*1650)
            $fatal(1,"sync pulse totals H=%0d V=%0d",horizontal_high,vertical_high);
        $display("PASS VIC4 raster: 1650x750, H=40, V=5, full-frame wrap");
        $finish;
    end
endmodule
