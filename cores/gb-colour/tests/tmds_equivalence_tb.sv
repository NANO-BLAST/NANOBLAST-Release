`timescale 1ns/1ps
module tmds_equivalence_tb;
reg clk_pixel=0;always #5 clk_pixel=~clk_pixel;
reg[7:0]video_data=0;reg[3:0]data_island_data=0;reg[1:0]control_data=0;reg[2:0]mode=0;
wire[9:0]old_value[0:2],new_value[0:2];
for(genvar c=0;c<3;c++)begin
 tmds_reference #(.CN(c)) original(.clk_pixel(clk_pixel),.video_data(video_data),.data_island_data(data_island_data),.control_data(control_data),.mode(mode),.tmds(old_value[c]));
 tmds_channel #(.CN(c)) changed(.clk_pixel(clk_pixel),.video_data(video_data),.data_island_data(data_island_data),.control_data(control_data),.mode(mode),.tmds(new_value[c]));
end
integer i,c;
initial begin
 repeat(4)@(negedge clk_pixel);
 for(i=0;i<100000;i++)begin
  for(c=0;c<3;c++)if(old_value[c]!==new_value[c])$fatal(1,"TMDS changed at %d channel %d",i,c);
  video_data=i;control_data=(i>>8);data_island_data=(i>>3);mode=(i/513)%5;
  @(negedge clk_pixel);
 end
 $display("PASS 300000 HDMI symbols match baseline across all channels/modes with unchanged latency");$finish;
end
endmodule
