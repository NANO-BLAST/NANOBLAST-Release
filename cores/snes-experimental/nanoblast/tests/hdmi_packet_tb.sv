`timescale 1ns/1ps
module hdmi_packet_tb;
    reg clk=0;always #5 clk=~clk;
    reg clk_audio=0,reset=1,field_end=0,packet_enable=0;
    reg [4:0] counter=0;reg [15:0] samples[1:0];
    wire [23:0] header[2];wire [55:0] subs0[3:0],subs1[3:0];
    packet_picker #(.VIDEO_ID_CODE(4),.VIDEO_RATE(74250000.0),.AUDIO_BIT_WIDTH(16),.AUDIO_RATE(32000)) dut(
        .clk_pixel(clk),.clk_audio(clk_audio),.reset(reset),.video_field_end(field_end),.packet_enable(packet_enable),
        .packet_pixel_counter(counter),.audio_sample_word(samples),.header(header[0]),.sub(subs0));
    packet_picker_reference #(.VIDEO_ID_CODE(4),.VIDEO_RATE(74250000.0),.AUDIO_BIT_WIDTH(16),.AUDIO_RATE(32000)) ref_packet(
        .clk_pixel(clk),.clk_audio(clk_audio),.reset(reset),.video_field_end(field_end),.packet_enable(packet_enable),
        .packet_pixel_counter(counter),.audio_sample_word(samples),.header(header[1]),.sub(subs1));
    reg [247:0] actual[0:1023],gold[0:1023];
    integer n,na=0,ng=0,checked=0,serial=0;
    initial begin
        samples[0]=0;samples[1]=0;
        for(n=0;n<3001000;n=n+1)begin
            @(negedge clk);reset=n<5;field_end=n%1237500==0;
            counter=5'(n%64);packet_enable=n%64==0;
            if(n>5 && n<3000000 && n%1160==0)begin
                clk_audio=~clk_audio;
                if(clk_audio)begin serial=serial+1;samples[0]=16'(serial*17);samples[1]=16'(~serial*31);end
            end
            if(n>=3000000)clk_audio=0;
            @(posedge clk);#1;
            if(packet_enable&&!reset&&!field_end)begin
                if(header[0][7:0]==2)begin actual[na]={header[0],subs0[0],subs0[1],subs0[2],subs0[3]};na=na+1;end
                if(header[1][7:0]==2)begin gold[ng]={header[1],subs1[0],subs1[1],subs1[2],subs1[3]};ng=ng+1;end
            end
            while(checked<na&&checked<ng)begin
                assert(actual[checked]===gold[checked])else $fatal(1,"HDMI audio packet differs at packet %0d",checked);
                checked=checked+1;
            end
        end
        assert(checked>300&&na==ng)else $fatal(1,"HDMI packet count mismatch %0d/%0d",na,ng);
        $display("PASS full HDMI packet picker: %0d bit-identical PCM packets including headers, channel status and parity over 3M pixel cycles",checked);
        $finish;
    end
endmodule
