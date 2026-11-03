`timescale 1ns/1ps
module video_dma_tb;
parameter S=3;
reg clk=0,pclk=0,resetn=0;always #10 clk=~clk;always #7 pclk=~pclk;
localparam W=8,H=4,HT=40,VT=20,VA=14,L=4,T=2;
reg[10:0]cx=0;reg[9:0]cy=0;
always @(posedge pclk)if(!resetn)begin cx<=0;cy<=0;end else if(cx==HT-1)begin cx<=0;cy<=cy==VT-1?0:cy+1'b1;end else cx<=cx+1'b1;
reg[5:0]gx=0,gy=0;reg[2:0]div=0;reg[4:0]frame=0;reg pause_game=0;
wire ce=div==0;wire lhbl=gx<W,lvbl=gy<H;
always @(posedge clk)if(!resetn)begin gx<=0;gy<=0;div<=0;frame<=1;end else begin
 div<=div+1'b1;
 if(ce&&!pause_game)if(gx==11)begin gx<=0;if(gy==5)begin gy<=0;frame<=frame==31?1:frame+1'b1;end else gy<=gy+1'b1;end else gx<=gx+1'b1;
end
wire[14:0]color={frame,gy[4:0],gx[4:0]};wire[23:0]rgb;wire req,wr;wire[22:0]addr;wire[8:0]len,word,index;wire[31:0]din,data;wire ack,valid,ov,uf,dv;
s16_video_dma #(.WIDTH(W),.HEIGHT(H),.SCALE(S),.LEFT(L),.TOP(T),.H_TOTAL(HT),.V_TOTAL(VT),.V_ACTIVE(VA),.FB_STRIDE(23'h1000))dut(
 .clk(clk),.resetn(resetn),.pix_ce(ce&&!pause_game),.lhbl(lhbl),.lvbl(lvbl),.color(color),.pclk(pclk),.presetn(resetn),.cx(cx),.cy(cy),.rgb(rgb),
 .burst_req(req),.burst_wr(wr),.burst_addr(addr),.burst_length(len),.burst_din(din),.burst_ack(ack),.burst_valid(valid),.burst_data(data),.burst_word(word),.burst_index(index),.overflow(ov),.underflow(uf),.display_valid(dv));
// Independent transaction model: synchronous source RAM data is prefetched one
// edge before consumption, as on the physical SDRAM controller.
reg[31:0]mem[0:2047];reg busy=0,ackr=0,vr=0;reg[31:0]dr=0;reg[8:0]wi=0,ix=0,n=0;integer stage=0;reg[10:0]base;reg writing;
assign ack=ackr;assign valid=vr;assign data=dr;assign word=wi;assign index=ix;
always @(posedge clk)begin
 vr<=0;
 if(!busy&&req!=ackr)begin busy<=1;base<=((addr-23'h100000)>>2);writing<=wr;n<=0;wi<=0;stage<=0;end
 if(busy)begin
  stage<=stage+1;
  if(stage==1)wi<=1;
  if(stage>=2&&n<len)begin
   if(writing)mem[base+n]<=din;else begin dr<=mem[base+n];ix<=n;vr<=1;end
   n<=n+1'b1;wi<=n+2;
  end
  if(n==len)begin busy<=0;ackr<=req;end
 end
 if(!resetn)begin busy<=0;ackr<=0;vr<=0;wi<=0;ix<=0;n<=0;stage<=0;end
end
integer checked=0,frames=0;reg[7:0]stamp=0;integer expected_x,expected_y;
always @(negedge pclk)if(resetn&&dv&&cx>=L&&cx<L+W*S&&cy>=T&&cy<T+H*S)begin
 expected_x=(cx-L)/S;expected_y=(cy-T)/S;
 if(cx==L&&cy==T)begin stamp=rgb[23:16];frames=frames+1;end
 if(rgb[23:16]!==stamp||rgb[15:8]!==((expected_y<<3)|(expected_y>>2))||rgb[7:0]!==((expected_x<<3)|(expected_x>>2)))
  $fatal(1,"torn/prefetch error at %d,%d rgb=%h stamp=%h",cx,cy,rgb,stamp);
 checked=checked+1;
end
initial begin
 #200;resetn=1;
 #200000;pause_game=1;
 #50000;
 if(checked<1000||frames<10||ov||uf)$fatal(1,"video checks=%d frames=%d overflow=%b underflow=%b",checked,frames,ov,uf);
 $display("PASS video DMA: %0d pixels, %0d complete frames, repeat without new game frame, asynchronous clocks",checked,frames);$finish;
end
initial begin #300000;$fatal(1,"timeout");end
endmodule
