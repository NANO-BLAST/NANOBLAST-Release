// SPDX-License-Identifier: GPL-3.0-or-later
// Lossless RGB555 external framebuffer, two scanline buffers in each direction.
// Game and SDRAM share clk; the HDMI line RAM is dual-clock. Frame publication
// waits for DMA completion. Reader ownership changes only with no read in flight.
module s16_video_dma #(
 parameter integer WIDTH=320,HEIGHT=224,SCALE=3,LEFT=160,TOP=24,
 parameter integer H_TOTAL=1650,V_TOTAL=750,V_ACTIVE=720,
 parameter [22:0] FB_BASE=23'h100000,FB_STRIDE=23'h030000
)(
 input wire clk,resetn,pix_ce,lhbl,lvbl,
 input wire[14:0]color,
 input wire pclk,presetn,input wire[10:0]cx,input wire[9:0]cy,
 output wire[23:0]rgb,
 output reg burst_req=0,burst_wr=0,
 output reg[22:0]burst_addr=0,output wire[8:0]burst_length,
 output reg[31:0]burst_din=0,
 input wire burst_ack,burst_valid,input wire[31:0]burst_data,
 input wire[8:0]burst_word,burst_index,
 output reg overflow=0,output reg underflow=0,
 output wire display_valid
);
localparam integer WORDS=WIDTH/2;
(* ram_style="block" *) reg[31:0]capture_ram[0:2*WORDS-1];
(* ram_style="block" *) reg[31:0]display_ram[0:2*WORDS-1];
reg[8:0]rows_written=0;
reg[1:0]pending=0;
reg[7:0]pending_y[0:1];
reg cap_bank=0,active_bank=0,active=0,active_write=0;
reg[7:0]active_y=0;
reg[8:0]x=0,y=0;
reg[14:0]first_pixel=0;
reg old_lvbl=0,frame_active=0,frame_ended=0,bad_frame=0,frame_was_active=0;
wire src_ready,capturing,write_buffer,read_buffer;
reg frame_complete=0;
wire can_start=src_ready && !frame_ended && pending==0 && !(active&&active_write);
wire start_frame=lvbl&&!old_lvbl&&can_start;
wire take_pixel=pix_ce&&lhbl&&lvbl && (frame_active||start_frame) && !bad_frame;
reg read_req=0,read_inflight=0,read_fb=0;
reg[7:0]read_y=0;
reg read_ack=0;
(* async_reg="true" *)reg read_meta=0,read_sync=0;
(* async_reg="true" *)reg ack_meta=0,ack_sync=0;
reg[1:0]line_valid=0;
reg[7:0]line_y[0:1];
reg display_seen=0,last_front=0;
wire vblank=cx==0&&cy==V_ACTIVE&&!read_inflight;
s16_frame_swap ownership(.src_clk(clk),.src_resetn(resetn),.src_start(start_frame),
 .src_complete(frame_complete),.src_ready(src_ready),.capture(capturing),.write_buffer(write_buffer),
 .dst_clk(pclk),.dst_resetn(presetn),.dst_vblank(vblank),.read_buffer(read_buffer),.display_valid(display_valid));
assign burst_length=WORDS;
wire[8:0]prefetch=burst_word<WORDS?burst_word:WORDS-1;
always @(posedge clk)burst_din<=capture_ram[active_bank*WORDS+prefetch];
wire have_read=read_sync!=read_ack;
reg prefer_read=0;
wire select_read=have_read && (pending==0 || prefer_read);
wire selected_cap=pending[0]?1'b0:1'b1;
always @(posedge clk)begin
 old_lvbl<=lvbl;frame_complete<=0;
 read_meta<=read_req;read_sync<=read_meta;
 if(!lvbl)begin x<=0;y<=0;end
 if(lvbl&&!old_lvbl)begin
  frame_active<=can_start;frame_was_active<=can_start;
  bad_frame<=0;cap_bank<=0;
 end
 if(!lvbl&&old_lvbl)begin frame_active<=0;frame_ended<=1;end
 if(take_pixel && y<HEIGHT)begin
  if(x==0 && (pending[cap_bank]||(active&&active_write&&active_bank==cap_bank)))begin
   bad_frame<=1;overflow<=1;
  end
  if(!x[0])first_pixel<=color;
  else capture_ram[cap_bank*WORDS+(x>>1)]<={1'b0,color,1'b0,first_pixel};
  if(x==WIDTH-1)begin
   x<=0;y<=y+1'b1;
   pending[cap_bank]<=1;pending_y[cap_bank]<=y;cap_bank<=~cap_bank;
  end else x<=x+1'b1;
 end
 if(frame_ended && pending==0 && !(active&&active_write))begin
  if(frame_was_active && !bad_frame && y==0)begin
   // y resets in vertical blank; all complete rows are counted separately below.
   if(rows_written==HEIGHT)frame_complete<=1;
  end
  frame_ended<=0;
 end
 if(active && burst_valid && !active_write && burst_index<WORDS)
  display_ram[active_y[0]*WORDS+burst_index]<=burst_data;
 if(active && burst_ack==burst_req)begin
  active<=0;
  if(active_write)begin pending[active_bank]<=0;rows_written<=rows_written+1'b1;end
  else read_ack<=read_sync;
 end
 if(!active && burst_req==burst_ack && (pending!=0||have_read))begin
  active<=1;active_write<=!select_read;burst_wr<=!select_read;burst_req<=~burst_req;
  prefer_read<=!select_read;
  if(select_read)begin
   active_y<=read_y;
   burst_addr<=FB_BASE+(read_fb?FB_STRIDE:0)+read_y*(WIDTH*2);
  end else begin
   active_bank<=selected_cap;active_y<=pending_y[selected_cap];
   burst_addr<=FB_BASE+(write_buffer?FB_STRIDE:0)+pending_y[selected_cap]*(WIDTH*2);
  end
 end
 if(start_frame)rows_written<=0;
 if(!resetn)begin
  pending<=0;pending_y[0]<=0;pending_y[1]<=0;
  cap_bank<=0;active_bank<=0;active<=0;active_write<=0;active_y<=0;
  x<=0;y<=0;first_pixel<=0;old_lvbl<=0;frame_active<=0;frame_ended<=0;
  bad_frame<=0;frame_was_active<=0;frame_complete<=0;rows_written<=0;
  read_meta<=0;read_sync<=0;read_ack<=0;prefer_read<=0;
  burst_req<=0;burst_wr<=0;burst_addr<=0;overflow<=0;
 end
end
// Two-stage acknowledgement gives the dual-clock RAM writes time to settle.
wire[10:0]next_cx=cx==H_TOTAL-1?11'd0:cx+1'b1;
wire[9:0]next_cy=cx==H_TOTAL-1?(cy==V_TOTAL-1?10'd0:cy+1'b1):cy;
wire next_window=next_cx>=LEFT&&next_cx<LEFT+WIDTH*SCALE&&next_cy>=TOP&&next_cy<TOP+HEIGHT*SCALE;
reg[8:0]source_x=0;
reg[7:0]source_y=0;
reg[1:0]x_repeat=0,y_repeat=0;
wire[8:0]sx=cx==LEFT-1?9'd0:x_repeat==SCALE-1?source_x+1'b1:source_x;
wire[7:0]sy=source_y;
always @(posedge pclk)begin
 if(cx==LEFT-1)begin source_x<=0;x_repeat<=0;end
 else if(cx>=LEFT&&cx<LEFT+WIDTH*SCALE-1)begin
  if(x_repeat==SCALE-1)begin x_repeat<=0;source_x<=source_x+1'b1;end
  else x_repeat<=x_repeat+1'b1;
 end
 if(cx==H_TOTAL-1&&cy>=TOP&&cy<TOP+HEIGHT*SCALE)begin
  if(y_repeat==SCALE-1)begin y_repeat<=0;source_y<=source_y+1'b1;end
  else y_repeat<=y_repeat+1'b1;
 end
 if(cy<TOP||!presetn)begin source_y<=0;y_repeat<=0;end
 if(!presetn)begin source_x<=0;x_repeat<=0;end
end
reg[31:0]pair=0;
reg half=0;
wire[15:0]pixel=half?pair[31:16]:pair[15:0];
wire window=cx>=LEFT&&cx<LEFT+WIDTH*SCALE&&cy>=TOP&&cy<TOP+HEIGHT*SCALE;
wire[7:0]current_y=source_y;
wire valid_line=line_valid[current_y[0]]&&line_y[current_y[0]]==current_y;
assign rgb=window&&display_valid&&valid_line?{pixel[14:10],pixel[14:12],pixel[9:5],pixel[9:7],pixel[4:0],pixel[4:2]}:24'd0;
always @(posedge pclk)begin
 ack_meta<=read_ack;ack_sync<=ack_meta;
 if(next_window)begin pair<=display_ram[sy[0]*WORDS+(sx>>1)];half<=sx[0];end
 if(read_inflight && ack_sync==read_req)begin
  read_inflight<=0;line_valid[read_y[0]]<=1;line_y[read_y[0]]<=read_y;
 end
 if(display_valid && cx==0 && cy==V_ACTIVE+1 && !read_inflight)begin
  display_seen<=1;last_front<=read_buffer;line_valid<=0;
  read_y<=0;read_fb<=read_buffer;read_req<=~read_req;read_inflight<=1;
 end else if(display_valid && cx==LEFT+WIDTH*SCALE && cy>=TOP && cy<TOP+(HEIGHT-1)*SCALE && y_repeat==0)begin
  if(!read_inflight)begin
   read_y<=current_y+1'b1;read_fb<=read_buffer;read_req<=~read_req;read_inflight<=1;
   line_valid[~current_y[0]]<=0;
  end else underflow<=1;
 end
 if(window&&display_valid&&!valid_line)underflow<=1;
 if(!presetn)begin
  ack_meta<=0;ack_sync<=0;read_req<=0;read_inflight<=0;read_y<=0;read_fb<=0;
  line_valid<=0;line_y[0]<=0;line_y[1]<=0;display_seen<=0;last_front<=0;
  pair<=0;half<=0;underflow<=0;
 end
end
endmodule
