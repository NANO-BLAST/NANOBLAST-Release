`timescale 1ns/1ps
module hdmi #(parameter VIDEO_ID_CODE=4,DVI_OUTPUT=0,VIDEO_REFRESH_RATE=60.0,IT_CONTENT=1,AUDIO_RATE=32000,AUDIO_BIT_WIDTH=16,START_X=0,START_Y=0)(
 input clk_pixel_x5,clk_pixel,clk_audio,reset,reset_serializer,input[23:0]rgb,
 input[15:0]audio_sample_word[1:0],output[2:0]tmds,output tmds_clock,
 output reg[10:0]cx=0,output reg[9:0]cy=0,output[10:0]frame_width,output[9:0]frame_height);
 assign tmds=0;assign tmds_clock=0;assign frame_width=1280;assign frame_height=720;
endmodule
module ELVDS_OBUF(input I,output O,OB);assign O=I;assign OB=~I;endmodule
