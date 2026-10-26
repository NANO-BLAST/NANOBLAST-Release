`timescale 1ns/1ps
module gowin_dpb_menu(input clka,reseta,ocea,cea,input[10:0]ada,input wrea,input[7:0]dina,output[7:0]douta,
 input clkb,resetb,oceb,ceb,input[10:0]adb,input wreb,input[7:0]dinb,output reg[7:0]doutb);
reg[7:0]mem[0:2047];integer i;
initial begin
 for(i=0;i<2048;i++)mem[i]=0;
 for(i=0;i<896;i++)mem[i]=8'h20;
 for(i=15;i<=18;i++)mem[i*32+5]=8'h41;
 for(i=2;i<30;i++)mem[26*32+i]=8'h41;
 mem[1024+65*8+0]=8'h81;mem[1024+65*8+1]=8'h42;
 mem[1024+65*8+2]=8'h24;mem[1024+65*8+3]=8'h18;
 mem[1024+65*8+4]=8'h18;mem[1024+65*8+5]=8'h24;
 mem[1024+65*8+6]=8'h42;mem[1024+65*8+7]=8'h81;
end
assign douta=0;
always @(posedge clka)if(cea&&wrea)mem[ada]<=dina;
always @(posedge clkb)if(ceb)doutb<=mem[adb];
endmodule
module menu_large_tb;
reg clk=0,pclk=0,resetn=0;
always #8 clk=~clk;always #5 pclk=~pclk;
wire[10:0]ox;wire[9:0]oy;wire[15:0]osd;
reg[3:0]we=0;reg[31:0]command=0;
textdisp text(.clk(clk),.hclk(pclk),.resetn(resetn),.overlay_x(ox),.overlay_y(oy),.overlay_color(osd),.reg_char_we(we),.reg_char_di(command));
sms_nano_hdmi dut(.clk(clk),.resetn(resetn),.pixel_resetn(resetn),.clk_pixel(pclk),.clk_5x_pixel(pclk),
 .ce_pix(1'b0),.x(9'd0),.y(9'd0),.color(12'd0),.height(9'd192),.audio_l(16'd0),.audio_r(16'd0),
 .overlay(1'b1),.overlay_x(ox),.overlay_y(oy),.overlay_color(osd),.background_rgb(24'h123456),.background_valid(1'b1));

reg[10:0]last_x;reg[9:0]last_y;
integer checked=0,helper=0,px,py,tx,ty;reg[7:0]pattern;reg lit;
always @(posedge pclk)begin last_x<=ox;last_y<=oy;end
always @(negedge pclk)if(resetn&&last_x>=257&&last_x<1024&&
 ((last_y>=384&&last_y<576)||(last_y>=648&&last_y<672)))begin
 px=(last_x-257)/3;py=(last_y-24)/3;tx=px;ty=py;
 if(py>=120&&py<184)begin tx=px/2;ty=120+(py-120)/2;end
 case(ty%8)
 0,7:pattern=8'h81;1,6:pattern=8'h42;2,5:pattern=8'h24;default:pattern=8'h18;
 endcase
 lit=(((ty/8>=15&&ty/8<=18)&&tx/8==5)||(ty/8==26&&tx/8>=2&&tx/8<30))&&pattern[tx%8];
 assert(dut.rgb===(lit?24'hf8f8f8:24'h123456))
  else $fatal(1,"Scaled/menu helper pixel x=%0d y=%0d expected=%0d got=%h source=%0d/%0d",last_x,last_y,lit,dut.rgb,tx,ty);
 if(last_y<576)checked++;else helper++;
end
initial begin
 repeat(10)@(negedge clk);resetn=1;
 @(negedge clk);command=32'h04300000|(22<<15)|(15<<10);we=1;
 @(negedge clk);we=0;
 wait(oy==673);
 assert(checked==192*767&&helper==24*767);
 $display("PASS %0d double-size menu pixels and %0d row26 helper pixels, legacy logo disabled",checked,helper);$finish;
end
initial begin #12000000;$fatal(1,"Timeout");end
endmodule
