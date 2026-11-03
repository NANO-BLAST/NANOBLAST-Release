`timescale 1ns/1ps
module tb_crt_presets;
reg clk=0,pclk=0,resetn=0;always #11 clk=~clk;always #7 pclk=~pclk;
reg[1:0]mode=0;reg overlay=0;
nes2hdmi nes(.crt_mode(mode),.clk(clk),.resetn(resetn),.pixel_resetn(resetn),.serializer_resetn(resetn),
 .color(6'd0),.cycle(9'd0),.scanline(9'd0),.sample(16'd0),.aspect_8x7(1'b0),
 .overlay(overlay),.overlay_color(16'd0),.background_rgb(24'h804020),.background_valid(1'b1),
 .clk_pixel(pclk),.clk_5x_pixel(pclk));
sms_nano_hdmi sms(.crt_mode(mode),.clk(clk),.resetn(resetn),.pixel_resetn(resetn),.clk_pixel(pclk),.clk_5x_pixel(pclk),
 .ce_pix(1'b0),.game_gear(1'b0),.gamegear_top(8'd24),.x(9'd0),.y(9'd0),.color(12'd0),.height(9'd192),
 .audio_l(16'd0),.audio_r(16'd0),.overlay(overlay),.overlay_color(16'd0),.background_rgb(24'h804020),.background_valid(1'b1));
integer m,v,d,s;reg[23:0]c,expected;integer rr,gg,bb;
initial begin
 repeat(8)@(negedge pclk);resetn=1;
 // All channel levels, strengths, scanline phases and mask phases; distinct RGB channels.
 for(m=0;m<4;m=m+1)for(v=0;v<256;v=v+1)for(d=0;d<2;d=d+1)for(s=0;s<3;s=s+1)begin
  rr=v;gg=255-v;bb=v^85;c={8'(rr),8'(gg),8'(bb)};
  if(m!=0&&d!=0)begin rr=rr*(m==2?2:3)/4;gg=gg*(m==2?2:3)/4;bb=bb*(m==2?2:3)/4;
   // Light preset rounds upward, matching a subtractive 25% attenuation.
   if(m!=2)begin rr=(3*v+3)/4;gg=(3*(255-v)+3)/4;bb=(3*(v^85)+3)/4;end
  end
  if(m==3)begin if(s!=0)rr=(7*rr+7)/8;if(s!=1)gg=(7*gg+7)/8;if(s!=2)bb=(7*bb+7)/8;end
  expected={8'(rr),8'(gg),8'(bb)};
  if(nes.crt_filter(c,2'(m),1'(d),2'(s))!==expected)$fatal(1,"NES filter mismatch");
  if(sms.crt_filter(c,2'(m),1'(d),2'(s))!==expected)$fatal(1,"SMS filter mismatch");
 end
 // Midframe settings must cross atomically but wait for the next frame.
 force nes.cx=100;force nes.cy=100;force sms.cx=100;force sms.cy=100;
 mode=3;repeat(80)@(negedge pclk);
 if(nes.crt_pending!==3||sms.crt_pending!==3)$fatal(1,"CDC delivery");
 if(nes.crt_active!==0||sms.crt_active!==0)$fatal(1,"midframe change");
 force nes.cx=0;force nes.cy=0;force sms.cx=0;force sms.cy=0;
 repeat(2)@(negedge pclk);
 if(nes.crt_active!==3||sms.crt_active!==3)$fatal(1,"frame apply");
 overlay=1;force nes.cx=100;force nes.cy=100;force sms.cx=100;force sms.cy=100;
 repeat(10)@(negedge pclk);
 if(nes.rgb!==24'h804020||sms.rgb!==24'h804020)$fatal(1,"menu bypass");
 // Verify the effects actually reach the RGB output in both production paths.
 overlay=0;force nes.cy=101;force nes.rgbv=24'hc08040;
 force nes.r2_active=1;force nes.mix=0;
 force sms.game_rgb=24'hc08040;force sms.yphase=500;
 repeat(10)@(negedge pclk);
 expected=nes.crt_filter(24'hc08040,3,1,nes.crt_stripe);
 @(posedge pclk);#1;if(nes.rgb!==expected)$fatal(1,"NES RGB effect insertion");
 @(negedge pclk);expected=sms.crt_filter(24'hc08040,3,1,sms.crt_stripe);
 @(posedge pclk);#1;if(sms.rgb!==expected)$fatal(1,"SMS RGB effect insertion");
 resetn=0;repeat(3)@(negedge pclk);
 if(nes.crt_active!==0||sms.crt_active!==0)$fatal(1,"reset bypass");
 $display("PASS CRT: exhaustive RGB arithmetic, atomic CDC, frame latch, menu bypass and reset");$finish;
end
endmodule
