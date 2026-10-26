// NANOBLAST 720p 5x GB/CGB scanout, dual line buffers supplied from SDRAM.
module nanoblast_gbc_hdmi(
 input clk,resetn,pixel_resetn,engine_reset,clk_pixel,clk_5x_pixel,
 input is_cgb,frame_ready,input [15:0]audio_l,audio_r,
 input overlay,output [10:0]overlay_x,output [9:0]overlay_y,input [15:0]overlay_color,
 input [23:0]background_rgb,input background_valid,
 output reg vs_toggle=0,line_req=0,output reg [7:0]line_no=0,
 output [7:0]lb_addr,input [31:0]lb_data,input line_done,input [7:0]line_done_no,
 output reg underflow=0,
 output tmds_clk_n,tmds_clk_p,output [2:0]tmds_d_n,tmds_d_p
);
wire [10:0]cx;wire[9:0]cy;assign overlay_x=cx;assign overlay_y=cy;
(* async_reg="true" *)reg [1:0]done_sync=0,reset_sync=3,frame_sync=0;
reg display_started=0;
reg done_seen=0;reg[1:0]line_valid=0;reg[7:0]tags[0:1];
wire active=cx>=240&&cx<1040&&cy<720;
reg [7:0]rx=0,ry=0;
reg [2:0]x_repeat=0,y_repeat=0;
always @(posedge clk_pixel) begin
 if(cx<240||cx>=1040)begin rx<=0;x_repeat<=0;end
 else if(x_repeat==4)begin rx<=rx+1'b1;x_repeat<=0;end
 else x_repeat<=x_repeat+1'b1;
 if(cx==1649)begin
  if(cy==747)begin ry<=0;y_repeat<=0;end
  else if(cy<720)begin
   if(y_repeat==4)begin ry<=ry+1'b1;y_repeat<=0;end
   else y_repeat<=y_repeat+1'b1;
  end
 end
 if(!pixel_resetn)begin rx<=0;ry<=0;x_repeat<=0;y_repeat<=0;end
end
assign lb_addr={ry[0],rx[7:1]};
wire[14:0]pixel=half_d?lb_data[30:16]:lb_data[14:0];reg active_d=0,ready_d=0,half_d=0;reg [23:0]rgb;
wire text_window=cx>=257&&cx<1024&&cy>=24&&cy<696;
function automatic [23:0]pixel_rgb(input[14:0]p,input cgb);
 begin
 if(cgb)pixel_rgb={p[4:0],p[4:2],p[9:5],p[9:7],p[14:10],p[14:12]};
 else case(p[1:0])0:pixel_rgb=24'he0f8d0;1:pixel_rgb=24'h88c070;2:pixel_rgb=24'h346856;3:pixel_rgb=24'h081820;endcase
 end
endfunction
always @(posedge clk_pixel)begin
 done_sync<={done_sync[0],line_done};reset_sync<={reset_sync[0],engine_reset};frame_sync<={frame_sync[0],frame_ready};
 if(done_sync[1]!=done_seen)begin
  done_seen<=done_sync[1];line_valid[line_done_no[0]]<=1;tags[line_done_no[0]]<=line_done_no;
 end
 // Publish at start of vertical blank, fetch row zero near its end so the
 // source-domain bank selection has settled before the first line read.
 if(cx==0&&cy==720)vs_toggle<=~vs_toggle;
 if(frame_sync[1]&&!reset_sync[1]&&cx==0&&(cy==747||(cy<715&&y_repeat==2)))begin
  line_no<=cy==747?8'd0:ry+8'd1;line_req<=~line_req;
 end
 if(cx==0&&cy==0&&frame_sync[1]&&line_valid[0]&&tags[0]==0)display_started<=1;
 half_d<=rx[0];
 active_d<=active;ready_d<=line_valid[ry[0]]&&tags[ry[0]]==ry&&frame_sync[1]&&display_started&&!reset_sync[1];
 rgb<=active_d&&ready_d?pixel_rgb(pixel,is_cgb):24'd0;
 if(active&&display_started&&frame_sync[1]&&!reset_sync[1]&&!overlay&&(!line_valid[ry[0]]||tags[ry[0]]!=ry))underflow<=1;
 if(overlay)begin
  rgb<=background_valid?background_rgb:24'd0;
  if(text_window)begin
   if(!overlay_color[15]&&background_valid&&(overlay_color[1]||overlay_color[0]))begin
    if(overlay_color[1]&&overlay_color[0])rgb<={2'b0,background_rgb[23:18],2'b0,background_rgb[15:10],2'b0,background_rgb[7:2]};
    else rgb<={1'b0,background_rgb[23:17],1'b0,background_rgb[15:9],1'b0,background_rgb[7:1]};
   end
   if(overlay_color[15])rgb<={overlay_color[4:0],3'b0,overlay_color[9:5],3'b0,overlay_color[14:10],3'b0};
  end
 end
 if(reset_sync[1])begin line_valid<=0;display_started<=0;end
 if(!pixel_resetn)begin
  display_started<=0;vs_toggle<=0;line_req<=0;line_no<=0;done_sync<=0;done_seen<=0;
  reset_sync<=3;frame_sync<=0;line_valid<=0;tags[0]<=0;tags[1]<=0;
  active_d<=0;ready_d<=0;half_d<=0;rgb<=0;underflow<=0;
 end
end
wire [31:0]audio;
cdc_mailbox #(.WIDTH(32))audio_cdc(.src_clk(clk),.src_resetn(resetn),.src_data({audio_r,audio_l}),.dst_clk(clk_pixel),.dst_resetn(pixel_resetn),.dst_data(audio));
wire[15:0]samples[1:0];assign samples[0]=audio[15:0];assign samples[1]=audio[31:16];
reg[31:0]fraction=0;reg clk_audio=0;wire[32:0]next_audio={1'b0,fraction}+33'd5553089;
always @(posedge clk_pixel)begin fraction<=next_audio[31:0];if(next_audio[32])clk_audio<=~clk_audio;if(!pixel_resetn)begin fraction<=0;clk_audio<=0;end end
wire[2:0]tmds;
hdmi #(.VIDEO_ID_CODE(4),.DVI_OUTPUT(0),.VIDEO_REFRESH_RATE(60.0),.IT_CONTENT(1),.AUDIO_RATE(48000),.AUDIO_BIT_WIDTH(16),.START_X(0),.START_Y(0))hdmi_out(
 .clk_pixel_x5(clk_5x_pixel),.clk_pixel(clk_pixel),.clk_audio(clk_audio),.rgb(rgb),.reset(!pixel_resetn),.reset_serializer(!pixel_resetn),
 .audio_sample_word(samples),.tmds(tmds),.tmds_clock(),.cx(cx),.cy(cy),.frame_width(),.frame_height());
ELVDS_OBUF pads[3:0](.I({clk_pixel,tmds}),.O({tmds_clk_p,tmds_d_p}),.OB({tmds_clk_n,tmds_d_n}));
endmodule
