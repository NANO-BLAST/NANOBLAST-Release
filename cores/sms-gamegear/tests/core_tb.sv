`timescale 1ns/1ps
module core_tb;
reg clk=0;always #10 clk=~clk;
reg resetn=0;reg[11:0]joy1=12'h011,joy2=0;
reg[4:0] phase=0;
wire ce_cpu=(phase==9||phase==24);
wire ce_vdp=(phase==4||phase==9||phase==14||phase==19||phase==24||phase==29);
wire ce_pix=(phase==9||phase==19||phase==29);
wire ce_sp=phase[0];
always @(negedge clk)if(!resetn)phase<=0;else phase<=phase==29?0:phase+1'b1;
wire rom_rd;wire[21:0]rom_addr;wire[7:0]rom_data;
wire[8:0]x,y;wire[11:0]color;wire[15:0]audio_l,audio_r;
reg[7:0]rom[0:65535];
assign rom_data=rom[rom_addr[15:0]];
sms_nano_core dut(.game_gear(1'b0),.clk(clk),.resetn(resetn),.ce_cpu(ce_cpu),.ce_vdp(ce_vdp),
 .ce_pix(ce_pix),.ce_sp(ce_sp),.memory_wait_n(1'b1),.save_rd(),.save_write(),.save_address(),.save_wdata(),.save_rdata(8'd0),.pal(1'b0),.region(1'b1),
 .joy1(joy1),.joy2(joy2),.rom_rd(rom_rd),.rom_addr(rom_addr),.rom_data(rom_data),
 .x(x),.y(y),.color(color),.audio_l(audio_l),.audio_r(audio_r));
integer i;reg[3:0]passed=0;
always @(posedge clk)if(resetn&&dut.ram_we)begin
 case(dut.ram_addr[12:0])
  0:begin assert(dut.ram_data==8'h42)else $fatal(1,"WRAM write");passed[0]=1;end
  1:begin assert(dut.ram_data==8'h43)else $fatal(1,"WRAM mirror/read");passed[1]=1;end
  2:begin assert(dut.ram_data==8'hee)else $fatal(1,"Controller input expected EE, got %h",dut.ram_data);passed[2]=1;end
  3:begin assert(dut.ram_data==8'ha7)else $fatal(1,"Mapper bank read expected A7, got %h",dut.ram_data);passed[3]=1;end
 endcase
end
initial begin
 for(i=0;i<65536;i=i+1)rom[i]=0;
 // Handwritten test program, no commercial ROM. DI; LD SP,D000; LD A,42;
 // write C000, read its E000 mirror and compare; signal 43 at C001;
 // read controller DC -> C002; select bank 3 at FFFF; read 8000 -> C003.
 rom[0]=8'hf3;rom[1]=8'h31;rom[2]=0;rom[3]=8'hd0;
 rom[4]=8'h3e;rom[5]=8'h42;rom[6]=8'h32;rom[7]=0;rom[8]=8'hc0;
 rom[9]=8'h3a;rom[10]=0;rom[11]=8'he0;rom[12]=8'hfe;rom[13]=8'h42;
 rom[14]=8'h20;rom[15]=8'hfe;
 rom[16]=8'h3e;rom[17]=8'h43;rom[18]=8'h32;rom[19]=1;rom[20]=8'hc0;
 rom[21]=8'hdb;rom[22]=8'hdc;rom[23]=8'h32;rom[24]=2;rom[25]=8'hc0;
 rom[26]=8'h3e;rom[27]=3;rom[28]=8'h32;rom[29]=8'hff;rom[30]=8'hff;
 rom[31]=8'h3a;rom[32]=0;rom[33]=8'h80;rom[34]=8'h32;rom[35]=3;rom[36]=8'hc0;
 // Write VDP RAM[0]=5A through its actual BF/BE CPU I/O ports.
 rom[37]=8'h3e;rom[38]=0;rom[39]=8'hd3;rom[40]=8'hbf;
 rom[41]=8'h3e;rom[42]=8'h40;rom[43]=8'hd3;rom[44]=8'hbf;
 rom[45]=8'h3e;rom[46]=8'h5a;rom[47]=8'hd3;rom[48]=8'hbe;
 rom[49]=8'h76;rom[16'hc000]=8'ha7;
 repeat(10)@(negedge clk);resetn=1;
 wait(passed==15);wait(dut.sms.vdp_inst.vdp_vram_inst.mem[0]==8'h5a);wait(y>=2);@(negedge clk);
 assert(x<=511&&y>=2)else $fatal(1,"Raster did not advance");
 // START routes to active-low NMI, never to SMS button 1.
 joy1=12'h008;#1;
 assert(dut.sms.pause==0&&dut.sms.j1_tl==1)else $fatal(1,"Pause/button mapping");
 joy1=0;joy2=12'h100;#1;
 assert(dut.sms.pause==1&&dut.sms.j2_tr==0&&dut.sms.j1_tr==1)else $fatal(1,"Second controller mapping");
 $display("PASS SMS engine: executes test ROM, WRAM write/read/mirroring, controller I/O, mapper banking, VDP RAM write, raster advance and Pause mapping");$finish;
end
initial begin #3000000;$fatal(1,"CPU program timeout: passed=%b PC=%h",passed,dut.sms.z80_inst.A);end
endmodule
