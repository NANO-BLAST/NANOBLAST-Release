module hdmi #(parameter VIDEO_ID_CODE=4,DVI_OUTPUT=0,VIDEO_REFRESH_RATE=60.0,IT_CONTENT=1,AUDIO_RATE=48000,AUDIO_BIT_WIDTH=16,START_X=0,START_Y=0)
(input clk_pixel_x5,clk_pixel,clk_audio,input[23:0]rgb,input reset,reset_serializer,input[15:0]audio_sample_word[1:0],
output[2:0]tmds,output tmds_clock,output reg[10:0]cx=0,output reg[9:0]cy=0,output[10:0]frame_width,output[9:0]frame_height);
assign tmds=0;assign tmds_clock=clk_pixel;assign frame_width=1650;assign frame_height=750;
always @(posedge clk_pixel)if(reset)begin cx<=0;cy<=0;end else if(cx==1649)begin cx<=0;cy<=cy==749?0:cy+1'b1;end else cx<=cx+1'b1;
endmodule
module ELVDS_OBUF(input I,output O,OB);assign O=I;assign OB=!I;endmodule
