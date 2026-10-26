`timescale 1ns/1ps
module scaler_tb;
reg clk=0;always #5 clk=~clk;reg resetn=0;integer x,y;
nanoblast_gbc_hdmi dut(.clk(clk),.resetn(resetn),.pixel_resetn(resetn),.engine_reset(1'b0),.clk_pixel(clk),.clk_5x_pixel(clk),.is_cgb(1'b1),.frame_ready(1'b1),.audio_l(16'd0),.audio_r(16'd0),.overlay(1'b0),.overlay_color(16'd0),.background_rgb(24'd0),.background_valid(1'b0),.lb_data(32'd0),.line_done(1'b0),.line_done_no(8'd0));
initial begin
 repeat(5)@(negedge clk);resetn=1;
 for(y=0;y<750;y=y+1)for(x=0;x<1650;x=x+1)begin
  dut.hdmi_out.cx=x;dut.hdmi_out.cy=y;#1;
  if(y<720&&dut.ry!==y/5)$fatal(1,"row y=%d got=%d",y,dut.ry);
  if(y<720&&dut.y_repeat!==y%5)$fatal(1,"row phase y=%d got=%d",y,dut.y_repeat);
  if(x>=240&&x<1040&&dut.rx!==(x-240)/5)$fatal(1,"column x=%d got=%d",x,dut.rx);
  @(negedge clk);
 end
 $display("PASS 720p scaler addresses match division reference across all pixels and lines");$finish;
end
endmodule
