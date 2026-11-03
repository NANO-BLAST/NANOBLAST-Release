// SPDX-License-Identifier: GPL-3.0-or-later
module s16_hdmi(input wire[1:0]crt_mode,input wire clk,resetn,pixel_resetn,clk_pixel,clk_5x_pixel,
 input wire[23:0]game_rgb,input wire[15:0]audio_l,audio_r,
 input wire overlay,output wire[10:0]overlay_x,output wire[9:0]overlay_y,input wire[15:0]overlay_color,
 output wire tmds_clk_n,tmds_clk_p,output wire[2:0]tmds_d_n,tmds_d_p);
wire[10:0]cx;wire[9:0]cy;assign overlay_x=cx;assign overlay_y=cy;
reg overlay_meta=0,overlay_pixel=0;
always @(posedge clk_pixel)begin overlay_meta<=overlay;overlay_pixel<=overlay_meta;if(!pixel_resetn)begin overlay_meta<=0;overlay_pixel<=0;end end
// CRT presets: 0 bypass, 1 light scanlines, 2 strong scanlines, 3 mask + light.
// Shift/subtract arithmetic: no framebuffer, DSP, or extra video pipeline stage.
function automatic [23:0] crt_filter(input [23:0] c, input [1:0] mode,
                                  input dark_line, input [1:0] stripe);
 reg [7:0] rr,gg,bb;
 begin
  rr=c[23:16];gg=c[15:8];bb=c[7:0];
  if(mode!=0 && dark_line)begin
   if(mode==2)begin rr=rr>>1;gg=gg>>1;bb=bb>>1;end
   else begin rr=rr-(rr>>2);gg=gg-(gg>>2);bb=bb-(bb>>2);end
  end
  if(mode==3)begin
   if(stripe!=0)rr=rr-(rr>>3);
   if(stripe!=1)gg=gg-(gg>>3);
   if(stripe!=2)bb=bb-(bb>>3);
  end
  crt_filter={rr,gg,bb};
 end
endfunction
wire [1:0] crt_pending;
reg [1:0] crt_active;
cdc_mailbox #(.WIDTH(2)) crt_cdc(.src_clk(clk),.src_resetn(resetn),.src_data(crt_mode),
 .dst_clk(clk_pixel),.dst_resetn(pixel_resetn),.dst_data(crt_pending));
// Apply complete settings only at a frame boundary.
always @(posedge clk_pixel)begin
 if(!pixel_resetn)crt_active<=0;
 else if(cx==0 && cy==0)crt_active<=crt_pending;
end
// Three output columns per repeating RGB mask, implemented with a tiny counter.
reg [1:0] crt_stripe;
always @(posedge clk_pixel)begin
 if(!pixel_resetn || cx==0)crt_stripe<=0;
 else crt_stripe<=crt_stripe==2?0:crt_stripe+1'b1;
end

reg[23:0]rgb;
// textdisp updates its first valid pixel at cx256 on this same edge.
// The compositor sees the preceding registered color, as in the NES scanout.
wire text_window=cx>=257&&cx<1024&&cy>=24&&cy<696;
always @(posedge clk_pixel)begin
 rgb<=crt_filter(game_rgb,crt_active,overlay_y[0],crt_stripe);
 if(overlay_pixel)begin
  rgb<={2'b0,game_rgb[23:18],2'b0,game_rgb[15:10],2'b0,game_rgb[7:2]};
  if(text_window&&!overlay_color[15]&&overlay_color[1])rgb<=24'h183048;
  if(text_window&&overlay_color[15])rgb<={overlay_color[4:0],3'b0,overlay_color[9:5],3'b0,overlay_color[14:10],3'b0};
 end
 if(!pixel_resetn)rgb<=0;
end
wire[31:0]coherent_audio;
cdc_mailbox #(.WIDTH(32))audio_cdc(.src_clk(clk),.src_resetn(resetn),.src_data({audio_r,audio_l}),
 .dst_clk(clk_pixel),.dst_resetn(pixel_resetn),.dst_data(coherent_audio));
wire[15:0]samples[1:0];assign samples[0]=coherent_audio[15:0];assign samples[1]=coherent_audio[31:16];
reg[31:0]audio_fraction=0;reg clk_audio=0;
wire[32:0]audio_next={1'b0,audio_fraction}+33'd5553089;
always @(posedge clk_pixel)begin
 audio_fraction<=audio_next[31:0];if(audio_next[32])clk_audio<=~clk_audio;
 if(!pixel_resetn)begin audio_fraction<=0;clk_audio<=0;end
end
wire[2:0]tmds;wire tmds_clock;
hdmi #(.VIDEO_ID_CODE(4),.DVI_OUTPUT(0),.VIDEO_REFRESH_RATE(60.0),
 .IT_CONTENT(1),.AUDIO_RATE(48000),.AUDIO_BIT_WIDTH(16),.START_X(0),.START_Y(0)) hdmi_out(
 .clk_pixel_x5(clk_5x_pixel),.clk_pixel(clk_pixel),.clk_audio(clk_audio),.rgb(rgb),
 .reset(!pixel_resetn),.reset_serializer(!pixel_resetn),.audio_sample_word(samples),
 .tmds(tmds),.tmds_clock(tmds_clock),.cx(cx),.cy(cy),.frame_width(),.frame_height());
ELVDS_OBUF tmds_buffers[3:0](.I({clk_pixel,tmds}),.O({tmds_clk_p,tmds_d_p}),.OB({tmds_clk_n,tmds_d_n}));
endmodule
