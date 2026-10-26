`timescale 1ns/1ps
module gamegear_core_tb;
reg clk=0;always #10 clk=~clk;
reg resetn=0;reg[11:0]joy1=0;reg[4:0]phase=0;
always @(negedge clk)if(!resetn)phase<=0;else phase<=phase==29?0:phase+1'b1;
wire ce_cpu=phase==9||phase==24,ce_vdp=phase==4||phase==9||phase==14||phase==19||phase==24||phase==29,ce_pix=phase==9||phase==19||phase==29,ce_sp=phase[0];
reg[7:0]rom[0:32767];wire rom_rd;wire[21:0]rom_addr;wire[7:0]rom_data=rom[rom_addr[14:0]];
wire[8:0]x,y,height;wire[7:0]top;wire[11:0]color;wire[15:0]left,right;
sms_nano_core dut(.game_gear(1'b1),.clk(clk),.resetn(resetn),.ce_cpu(ce_cpu),.ce_vdp(ce_vdp),.ce_pix(ce_pix),.ce_sp(ce_sp),
 .pal(1'b0),.region(1'b0),.memory_wait_n(1'b1),.save_rdata(8'd0),.joy1(joy1),.joy2(12'd0),
 .rom_rd(rom_rd),.rom_addr(rom_addr),.rom_data(rom_data),.x(x),.y(y),.frame_height(height),.gamegear_top(top),.color(color),.audio_l(left),.audio_r(right));
reg[7:0]start_value=0,pad_value=0;reg[4095:0]colours=0;integer pixels=0,lines=0;
always @(posedge clk)begin
 if(resetn&&dut.ram_we)begin
  if(dut.ram_addr[12:0]==0)start_value<=dut.ram_data;
  if(dut.ram_addr[12:0]==1)pad_value<=dut.ram_data;
 end
 if(resetn&&ce_pix&&x>48&&x<=208&&y>=24&&y<168&&dut.sms.vdp_inst.display_on)begin colours[color]<=1;pixels<=pixels+1;end
end
integer f,n,i;string path;
initial begin
 if(!$value$plusargs("ROM=%s",path))$fatal(1,"ROM required");f=$fopen(path,"rb");n=$fread(rom,f);$fclose(f);if(n!=32768)$fatal(1,"ROM size");
 repeat(10)@(negedge clk);resetn=1;
 wait(start_value==8'hff);if(height!=144||top!=24||dut.sms.PSG_mux!=8'h10)$fatal(1,"GG mode/stereo configuration");
 joy1=8;wait(start_value==8'h7f);if(dut.sms.z80_inst.NMI_n!=1)$fatal(1,"GG Start caused SMS NMI");
 joy1=12'h080;wait(pad_value==8'hf7);joy1=12'h100;wait(pad_value==8'hdf);joy1=1;wait(pad_value==8'hef);joy1=0;wait(start_value==8'hff&&pad_value==8'hff);
 wait(colours[12'h159]&&colours[12'h357]&&colours[12'h753]&&pixels>46080);
 if(dut.sms.vdp_inst.vdp_cram_inst.ram[6]!=12'h159)$fatal(1,"GG 12-bit CRAM not retained");
 $display("PASS actual GG CPU/VDP: ROM boots, Start/directions/A/B, stereo port, RGB444 palette, pixels=%d colours=%d",pixels,$countones(colours));$finish;
end
initial begin #180000000;$fatal(1,"GG CPU/video timeout start=%h pad=%h PC=%h colors=%d",start_value,pad_value,dut.sms.z80_inst.A,$countones(colours));end
endmodule
