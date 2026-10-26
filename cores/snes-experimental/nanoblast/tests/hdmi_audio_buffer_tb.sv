`timescale 1ns/1ps
module hdmi_audio_buffer_tb;
    reg clk=0;always #5 clk=~clk;
    reg reset=1,push=0,used=0,busy=0;
    reg [31:0] sample_data=0;wire ready;wire [127:0] packet_data;
    reg [127:0] expected[0:8191],assembling=0,held=0;
    reg [31:0] rng=32'h3921abcd;
    integer wi=0,ri=0,part=0,n,gap=0,busy_count=0,packets=0;
    snes_hdmi_audio_buffer dut(clk,reset,push,used,busy,sample_data,ready,packet_data);
    initial begin
        for(n=0;n<500000;n=n+1)begin
            @(negedge clk);
            rng=rng^(rng<<13);rng=rng^(rng>>17);rng=rng^(rng<<5);
            reset=n<4||n%200003==0;push=0;used=0;
            if(busy_count>0)busy_count=busy_count-1;
            if(!reset)begin
                if(gap==0)begin
                    push=1;sample_data=rng;
                    gap=n<250000?2319:26+(rng%33);
                end else gap=gap-1;
                if(n%64==0&&ready&&busy_count==0)begin used=1;busy_count=32;end
            end
            busy=busy_count!=0;
            @(posedge clk);
            if(reset)begin wi=0;ri=0;part=0;assembling=0;gap=0;busy_count=0;end
            else begin
                if(used)begin
                    assert(ri<wi&&packet_data===expected[ri])else $fatal(1,"HDMI PCM order/data mismatch at cycle %0d",n);
                    held=packet_data;ri=ri+1;packets=packets+1;
                end
                if(push)begin
                    assembling[part*32+:32]=sample_data;
                    if(part==3)begin expected[wi]=assembling;wi=wi+1;part=0;end
                    else part=part+1;
                end
            end
            #1;
            if(busy_count>0)assert(packet_data===held)else $fatal(1,"PCM data changed during packet transmission");
        end
        assert(packets>1000)else $fatal(1,"Insufficient packet exercise");
        $display("PASS HDMI BRAM audio buffer: %0d exact stereo packets, 500000 cycles, nominal 32kHz and accelerated arrivals, write/read contention, resets and stable packet transmission",packets);
        $finish;
    end
endmodule
