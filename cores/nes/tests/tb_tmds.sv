`timescale 1ns/1ps
// Independent inverse of DVI 1.0 Figure 3-6 plus symbol-count disparity.
// The decoder does not inspect the encoder's q_m or accumulator.
module tb_tmds;
    reg clk = 0;
    always #5 clk = ~clk;
    reg [7:0] pixel = 0;
    reg [3:0] island = 0;
    reg [1:0] control = 0;
    reg [2:0] mode = 0;
    wire [9:0] symbol [0:2];
    for(genvar ch=0; ch<3; ch=ch+1) begin
        tmds_channel #(.CN(ch)) dut(clk,pixel,island,control,mode,symbol[ch]);
    end
    function [7:0] decode(input [9:0] s);
        reg [7:0] transitions;
        begin
            transitions = s[7:0] ^ {8{s[9]}};
            decode[0] = transitions[0];
            for(integer j=1;j<8;j=j+1)
                decode[j] = transitions[j] ^ transitions[j-1] ^ !s[8];
        end
    endfunction
    function integer imbalance(input [9:0] s);
        integer ones;
        begin
            ones=0;
            for(integer j=0;j<10;j=j+1) ones+=s[j];
            imbalance = 2*ones-10;
        end
    endfunction
    function [9:0] ctrl_symbol(input [1:0] c);
        case(c)
            0:ctrl_symbol=10'b1101010100;
            1:ctrl_symbol=10'b0010101011;
            2:ctrl_symbol=10'b0101010100;
            3:ctrl_symbol=10'b1010101011;
        endcase
    endfunction
    // HDMI 1.4a TERC4 alphabet, used as an inverse decoder.
    function integer decode_terc(input [9:0] s);
        case(s)
            10'b1010011100:decode_terc=0; 10'b1001100011:decode_terc=1;
            10'b1011100100:decode_terc=2; 10'b1011100010:decode_terc=3;
            10'b0101110001:decode_terc=4; 10'b0100011110:decode_terc=5;
            10'b0110001110:decode_terc=6; 10'b0100111100:decode_terc=7;
            10'b1011001100:decode_terc=8; 10'b0100111001:decode_terc=9;
            10'b0110011100:decode_terc=10; 10'b1011000110:decode_terc=11;
            10'b1010001110:decode_terc=12; 10'b1001110001:decode_terc=13;
            10'b0101100011:decode_terc=14; 10'b1011000011:decode_terc=15;
            default:decode_terc=-1;
        endcase
    endfunction
    integer disparity=0;
`ifdef TMDS_UNPIPELINED
    localparam PIPELINE = 0;
`else
    localparam PIPELINE = 1;
`endif
    reg [7:0] previous_pixel=0, expected_pixel;
    reg [2:0] previous_mode=0, expected_mode;
    reg [1:0] previous_control=0, expected_control;
    reg [3:0] previous_island=0, expected_island;
    always @(posedge clk) begin
        expected_pixel=PIPELINE ? previous_pixel : pixel;
        expected_mode=PIPELINE ? previous_mode : mode;
        expected_control=PIPELINE ? previous_control : control;
        expected_island=PIPELINE ? previous_island : island;
        previous_pixel=pixel; previous_mode=mode; previous_control=control;
        previous_island=island;
        #0.01;
        if (expected_mode==1) begin
            for(integer ch=0;ch<3;ch=ch+1)
                if(decode(symbol[ch]) !== expected_pixel) $fatal(1,"decode value %h lane %0d",expected_pixel,ch);
            disparity+=imbalance(symbol[0]);
            if(disparity < -8 || disparity > 8) $fatal(1,"unbounded disparity %0d",disparity);
        end else begin
            disparity=0;
            if (expected_mode==0)
                for(integer ch=0;ch<3;ch=ch+1)
                    if(symbol[ch] !== ctrl_symbol(expected_control)) $fatal(1,"control %0d",expected_control);
            if (expected_mode==2)
                for(integer ch=0;ch<3;ch=ch+1)
                    if(symbol[ch] !== (ch==1 ? 10'b0100110011 : 10'b1011001100)) $fatal(1,"video guard");
            if (expected_mode==3)
                for(integer ch=0;ch<3;ch=ch+1)
                    if(decode_terc(symbol[ch]) != expected_island) $fatal(1,"island nibble %0d",expected_island);
            if (expected_mode==4) begin
                if(decode_terc(symbol[0]) != 12+expected_control) $fatal(1,"data guard sync");
                if(symbol[1] !== 10'b0100110011 || symbol[2] !== 10'b0100110011) $fatal(1,"data guard lanes");
            end
        end
    end
    reg [31:0] lfsr=32'h12345678;
    task check_pixel(input [7:0] value);
        begin
            @(negedge clk); pixel=value; mode=1;
            @(posedge clk); #0.02;
        end
    endtask
    initial begin
        repeat(2) @(negedge clk);
        for(integer c=0;c<4;c=c+1) begin
            control=c; mode=0;
            @(posedge clk); #0.02;
            // Each byte after reset and in ascending/descending streams.
            for(integer value=0;value<256;value=value+1) check_pixel(value);
            for(integer value=255;value>=0;value=value-1) check_pixel(value);
            @(negedge clk);
        end
        for(integer n=0;n<65536;n=n+1) begin
            lfsr={lfsr[30:0],lfsr[31]^lfsr[21]^lfsr[1]^lfsr[0]};
            check_pixel(lfsr[7:0]);
        end
        // Exercise mode boundaries, all TERC4 nibbles and all sync states.
        for(integer m=0;m<=4;m=m+1)
            for(integer c=0;c<4;c=c+1)
                for(integer d=0;d<16;d=d+1) begin
                    @(negedge clk); mode=m; control=c; island=d; pixel=d*17;
                end
        repeat(3) @(negedge clk);
        $display("PASS TMDS: RGB inverse decode, controls/guards/TERC4, 65536 changing pixels, bounded disparity, aligned lanes");
        $finish;
    end
endmodule
