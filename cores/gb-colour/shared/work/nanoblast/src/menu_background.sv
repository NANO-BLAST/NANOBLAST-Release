// Indexed scanout, double-buffered lines and bundled-data CDC handshakes.
module menu_background(
 input clk,fclk,hclk,resetn,hresetn,enable,overlay,oled,
 input [10:0] x,input [9:0] y,
 input palette_we,input [31:0] palette_data,
 output reg bg_req,output reg [19:0] bg_addr,
 input bg_ack,input [31:0] bg_data,input bg_valid,input [8:0] bg_word,
 output bg_enable,output reg [23:0] rgb,output reg valid,output reg underflow
);
 reg [31:0] lines[0:1023];
 reg [23:0] palette[0:255];
 always @(posedge clk)if(palette_we)palette[palette_data[31:24]]<=palette_data[23:0];
 reg [1:0] enable_f;
 (* syn_preserve=1 *) reg enable_meta,enable_pixel,overlay_meta,overlay_pixel,oled_meta,oled_pixel;
 always @(posedge fclk)if(!resetn)enable_f<=0;else enable_f<={enable_f[0],enable && overlay};
 always @(posedge hclk)if(!hresetn)begin enable_meta<=0;enable_pixel<=0;overlay_meta<=0;overlay_pixel<=0;oled_meta<=0;oled_pixel<=0;end
  else begin oled_meta<=oled;oled_pixel<=oled_meta;enable_meta<=enable;enable_pixel<=enable_meta;overlay_meta<=overlay;overlay_pixel<=overlay_meta;end
 assign bg_enable=enable_f[1];
 reg request_h,request_seen;
 reg [9:0] requested_line,writing_line;
 (* syn_preserve=1 *) reg req_meta,req_sync,ack_meta,ack_sync;
 always @(posedge fclk)begin
  if(!resetn)begin req_meta<=0;req_sync<=0;request_seen<=0;bg_req<=0;bg_addr<=0;writing_line<=0;end
  else begin
   req_meta<=request_h;req_sync<=req_meta;
   if(req_sync!=request_seen && bg_req==bg_ack)begin
    request_seen<=req_sync;writing_line<=requested_line;
    bg_addr<=({10'b0,requested_line}<<10)+({10'b0,requested_line}<<8);
    bg_req<=~bg_req;
   end
   if(bg_valid)lines[{writing_line[0],bg_word}]<=bg_data;
  end
 end
 reg [9:0] tags[0:1],previous_tags[0:1];reg [1:0] ready_lines;reg ack_seen;
 always @(posedge hclk)begin
  if(!hresetn)begin request_h<=0;requested_line<=0;ack_meta<=0;ack_sync<=0;ack_seen<=0;
   ready_lines<=0;tags[0]<=0;tags[1]<=0;previous_tags[0]<=0;previous_tags[1]<=0;underflow<=0;end
  else begin
   ack_meta<=bg_ack;ack_sync<=ack_meta;
   if(ack_sync!=ack_seen)begin ack_seen<=ack_sync;
    tags[requested_line[0]]<=requested_line;
    previous_tags[requested_line[0]]<=requested_line==0?10'd749:requested_line-10'd1;ready_lines[requested_line[0]]<=1;end
   if(!enable_pixel)ready_lines<=0;
   if(enable_pixel && overlay_pixel && x==0 && (y==720 || y<719))begin
    if(request_h==ack_sync)begin requested_line<=y==720?10'd0:y+10'd1;
     request_h<=~request_h;end
    else underflow<=1;
   end
  end
 end
 // Two-pixel lookahead accounts for registered RAM/palette reads. Read
 // next-line pixels 0/1 in the final two horizontal blanking cycles.
 wire next_line=x>=1648;
 wire [10:0] read_x=next_line?x-11'd1648:x+11'd2;
 // Compare cached tags directly against y; precompute the preceding-line
 // tag when a DMA line completes instead of adding to y on the pixel path.
 wire read_bank=y[0]^next_line;
 wire current_ok=y<720 && ready_lines[y[0]] && tags[y[0]]==y;
 wire next_ok=(y<719 || y==749) && ready_lines[~y[0]] && previous_tags[~y[0]]==y;
 wire read_ok=(x<1278 || next_line) && enable_pixel && overlay_pixel &&
  (next_line?next_ok:current_ok);
 reg [31:0] line_data;reg [1:0] byte_sel;reg read_ok_d;
 always @(posedge hclk)begin
  line_data<=lines[{read_bank,read_x[10:2]}];
  byte_sel<=read_x[1:0];read_ok_d<=read_ok;
  if(oled_pixel)rgb<=24'd0;else rgb<=palette[line_data[byte_sel*8+:8]];
  if(!hresetn)begin read_ok_d<=0;valid<=0;end else if(oled_pixel && overlay_pixel)valid<=1;else valid<=read_ok_d;
 end
endmodule
