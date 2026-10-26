// SMS resolved-color indexed scanout, full 240 lines, and shared NANOBLAST artwork/OSD.
// SMS CRAM supplies two bits per channel; storing the resolved color at each
// pixel preserves raster palette changes without a large RGB444 framebuffer.
module sms_nano_hdmi(
 input wire clk,resetn,pixel_resetn,clk_pixel,clk_5x_pixel,
 input wire ce_pix,game_gear,input wire[7:0]gamegear_top,input wire[8:0]x,y,input wire[11:0]color,
 input wire[8:0]height,input wire[15:0]audio_l,audio_r,
 input wire overlay,output wire[10:0]overlay_x,output wire[9:0]overlay_y,
 input wire[15:0]overlay_color,input wire[23:0]background_rgb,input wire background_valid,
 output wire tmds_clk_n,tmds_clk_p,output wire[2:0]tmds_d_n,tmds_d_p
);
// 64 native SMS colors plus the fixed legacy TMS palette used by SMS titles
// in legacy display modes. Seven bits retain both without RGB quantization.
function automatic[6:0]encode_color(input[11:0]c);
 begin
 encode_color={1'b0,c[11:10],c[7:6],c[3:2]};
 case(c)
  12'h4A2:encode_color=7'd64;
  12'h7E6:encode_color=7'd65;
  12'hF55:encode_color=7'd66;
  12'hF88:encode_color=7'd67;
  12'h55D:encode_color=7'd68;
  12'hFF4:encode_color=7'd69;
  12'h55F:encode_color=7'd70;
  12'h88F:encode_color=7'd71;
  12'h5DD:encode_color=7'd72;
  12'h8DE:encode_color=7'd73;
  12'h4B2:encode_color=7'd74;
  12'hA6B:encode_color=7'd75;
  12'hBBB:encode_color=7'd76;
  default:;
 endcase
 end
endfunction
function automatic[23:0]decode_color(input[6:0]c);
 reg[11:0]legacy;
 begin
 legacy=0;
 case(c)
  7'd64:legacy=12'h4A2;
  7'd65:legacy=12'h7E6;
  7'd66:legacy=12'hF55;
  7'd67:legacy=12'hF88;
  7'd68:legacy=12'h55D;
  7'd69:legacy=12'hFF4;
  7'd70:legacy=12'h55F;
  7'd71:legacy=12'h88F;
  7'd72:legacy=12'h5DD;
  7'd73:legacy=12'h8DE;
  7'd74:legacy=12'h4B2;
  7'd75:legacy=12'hA6B;
  7'd76:legacy=12'hBBB;
  default:;
 endcase
 decode_color=c[6]?{{2{legacy[3:0]}},{2{legacy[7:4]}},{2{legacy[11:8]}}}:{{4{c[1:0]}},{4{c[3:2]}},{4{c[5:4]}}};
 end
endfunction
// A common 14-bit RAM holds two lossless SMS pixels or one RGB444 GG pixel.
// Packing SMS pairs preserves its full 256x240 image and all legacy colours,
// while GG uses 160x144 RGB444 cells within exactly the same storage budget.
(* syn_ramstyle="block_ram" *) reg[13:0]frame[0:30719];
reg[14:0]init_address=0;reg initialized=0;reg[6:0]first_pixel=0;
wire sms_write=ce_pix&&!game_gear&&x>=1&&x<=256&&y<240&&!x[0];
wire gg_write=ce_pix&&game_gear&&x>48&&x<=208&&y>=gamegear_top&&y<({1'b0,gamegear_top}+9'd144);
wire[7:0]gg_row=y-gamegear_top;
wire[14:0]gg_write_address=({7'd0,gg_row}<<7)+({7'd0,gg_row}<<5)+(x-9'd49);
wire[14:0]frame_write_address=!initialized?init_address:game_gear?gg_write_address:{y[7:0],x[7:1]-7'd1};
wire[13:0]frame_write_data=!initialized?14'd0:game_gear?{2'b0,color}:{encode_color(color),first_pixel};
wire frame_write=!initialized||sms_write||gg_write;
always @(posedge clk)if(frame_write)frame[frame_write_address]<=frame_write_data;
always @(posedge clk)begin
 if(!initialized)begin
  if(init_address==30719)initialized<=1;else init_address<=init_address+1'b1;
 end
 if(ce_pix&&x>=1&&x<=256&&y<240&&x[0])first_pixel<=encode_color(color);
 if(!resetn)begin init_address<=0;initialized<=0;first_pixel<=0;end
end
wire[10:0]cx;wire[9:0]cy;
assign overlay_x=cx;assign overlay_y=cy;
wire[8:0]pixel_height;
cdc_mailbox #(.WIDTH(9))height_cdc(.src_clk(clk),.src_resetn(resetn),.src_data(height),
 .dst_clk(clk_pixel),.dst_resetn(pixel_resetn),.dst_data(pixel_height));
reg init_meta=0,init_pixel=0,overlay_meta=0,overlay_pixel=0;
always @(posedge clk_pixel)begin
 init_meta<=initialized;init_pixel<=init_meta;overlay_meta<=overlay;overlay_pixel<=overlay_meta;
 if(!pixel_resetn)begin init_meta<=0;init_pixel<=0;overlay_meta<=0;overlay_pixel<=0;end
end
// Fractional scaling uses bounded add/subtract counters, not wide dividers.
// Prefetch the next HDMI pixel to compensate for synchronous framebuffer RAM.
wire gear_pixel=pixel_height==9'd144;
wire[10:0]window_left=gear_pixel?11'd240:11'd160,window_right=gear_pixel?11'd1040:11'd1120;
wire[10:0]window_width=gear_pixel?11'd800:11'd960;
reg[7:0]sx=0,sy=0;reg[9:0]xphase=0,yphase=0;
wire[10:0]xsum={1'b0,xphase}+(gear_pixel?11'd160:11'd256);
wire[10:0]ysum={1'b0,yphase}+{2'b0,(gear_pixel?9'd144:pixel_height==224?9'd224:pixel_height==240?9'd240:9'd192)};
wire[7:0]source_x=cx==window_left-1?8'd0:xsum>=window_width?sx+1'b1:sx;
wire[7:0]source_y=sy;
always @(posedge clk_pixel)begin
 if(cx==window_left-1)begin sx<=0;xphase<=0;end
 else if(cx>=window_left&&cx<window_right-1)begin
  xphase<=xsum>=window_width?xsum-window_width:xsum;
  sx<=source_x;
 end
 if(cx==1649&&cy<719)begin
  yphase<=ysum>=720?ysum-11'd720:ysum;
  if(ysum>=720)sy<=sy+1'b1;
 end
 if((cx==0&&cy==0)||!pixel_resetn)begin sy<=0;yphase<=0;end
 if(!pixel_resetn)begin sx<=0;xphase<=0;end
end
reg[13:0]pixel_pair;reg pixel_half=0;
wire[6:0]pixel=pixel_half?pixel_pair[13:7]:pixel_pair[6:0];
wire game_window=cx>=window_left&&cx<window_right&&cy<720;
wire[14:0]gg_read_address=({7'd0,source_y}<<7)+({7'd0,source_y}<<5)+source_x;
wire[14:0]frame_read_address=gear_pixel?gg_read_address:{source_y,source_x[7:1]};
always @(posedge clk_pixel)begin
 if(cx>=window_left-1&&cx<window_right-1&&cy<720&&source_y<(gear_pixel?144:240))begin
  pixel_pair<=frame[frame_read_address];pixel_half<=source_x[0];
 end else begin pixel_pair<=0;pixel_half<=0;end
end
wire[23:0]gg_rgb={{2{pixel_pair[3:0]}},{2{pixel_pair[7:4]}},{2{pixel_pair[11:8]}}};
wire[23:0]game_rgb=game_window&&init_pixel?(gear_pixel?gg_rgb:decode_color(pixel)):24'd0;
reg[23:0]rgb;
// textdisp updates its first valid pixel at cx256 on this same edge.
// The compositor sees the preceding registered color, as in the NES scanout.
wire text_window=cx>=257&&cx<1024&&cy>=24&&cy<696;
always @(posedge clk_pixel)begin
 rgb<=game_rgb;
 if(overlay_pixel)begin
  rgb<={2'b0,game_rgb[23:18],2'b0,game_rgb[15:10],2'b0,game_rgb[7:2]};
  if(background_valid)begin
   rgb<=background_rgb;
   if(text_window&&!overlay_color[15]&&overlay_color[0])
    rgb<={1'b0,background_rgb[23:17],1'b0,background_rgb[15:9],1'b0,background_rgb[7:1]};
  end
  if(text_window&&!overlay_color[15]&&overlay_color[1])begin
   if(background_valid)begin
    if(overlay_color[0])rgb<={2'b0,background_rgb[23:18],2'b0,background_rgb[15:10],2'b0,background_rgb[7:2]};
    else rgb<={1'b0,background_rgb[23:17],1'b0,background_rgb[15:9],1'b0,background_rgb[7:1]};
   end else rgb<={2'b01,game_rgb[23:18],2'b01,game_rgb[15:10],2'b01,game_rgb[7:2]};
  end
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
