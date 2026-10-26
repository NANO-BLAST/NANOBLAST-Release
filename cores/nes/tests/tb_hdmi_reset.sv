`timescale 1ns/1ps
module tb_hdmi_reset;
    reg fast_clk = 0;
    reg pixel_clk = 0;
    reg locked = 0;
    wire divider_resetn, video_resetn;
    hdmi_clock_reset dut(locked, pixel_clk,
                         divider_resetn, video_resetn);
    always #1 fast_clk = ~fast_clk;
    // A stopped pixel clock must not prevent assertion of video reset.
    reg pixel_run = 0;
    always #5 if (pixel_run) pixel_clk = ~pixel_clk;

    task check_release;
        begin
            locked = 1;
            #0.01;
            if (divider_resetn !== 1) $fatal(1,"divider did not follow PLL lock");
            if (video_resetn !== 0) $fatal(1,"video released without pixel edges");
            pixel_run = 1;
            for (integer i = 0; i < 3; i = i + 1) begin
                @(posedge pixel_clk); #0.01;
                if (video_resetn !== (i == 2)) $fatal(1,"video release edge %0d",i);
            end
        end
    endtask

    initial begin
        #0.1;
        if ({divider_resetn,video_resetn} !== 2'b00) $fatal(1,"unsafe power-on state");
        check_release();
        repeat (100) @(posedge pixel_clk);
        if ({divider_resetn,video_resetn} !== 2'b11) $fatal(1,"unstable locked link");
        // Lose lock between edges, with no pixel clock available.
        pixel_run = 0;
        #0.2; locked = 0; #0.01;
        if ({divider_resetn,video_resetn} !== 2'b00) $fatal(1,"unlock did not assert asynchronously");
        @(negedge fast_clk); #0.1;
        pixel_clk = 0;
        check_release();
        $display("PASS HDMI reset: startup, synchronous release, stopped-clock unlock, relock");
        $finish;
    end
    initial begin #10000; $fatal(1,"timeout"); end
endmodule
