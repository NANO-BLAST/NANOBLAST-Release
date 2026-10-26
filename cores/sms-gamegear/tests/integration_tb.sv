`timescale 1ns/1ps
module integration_tb;
reg clk=0;always #10 clk=~clk;
reg resetn=0,loading=0,load_valid=0;reg[7:0]load_data=0;
wire rom_rd,save_rd,save_we,waitn,running,fault;
wire[21:0]rom_addr;wire[14:0]save_addr;wire[7:0]rom_data,save_din,save_dout;
wire req,wr;wire[22:0]addr;wire[7:0]din;reg ack=0;reg[7:0]dout=0;reg ready=0;
reg[7:0]ram[0:8388607];integer countdown=0,transfers=0,cycles=0;
reg request=0;reg[22:0]address;reg writing;reg[7:0]data;
always @(posedge clk)begin
 cycles<=cycles+1;
 if(cycles==1700)ready<=1;
 if(countdown!=0)begin
  countdown<=countdown-1;
  if(countdown==1)begin
   if(writing)ram[address]<=data;else dout<=ram[address];
   ack<=request;transfers<=transfers+1;
  end
 end else if(req!=ack&&ready)begin
  request<=req;address<=addr;writing<=wr;data<=din;
  // Model regular traffic, occasional long refresh/artwork interference and
  // an extended last-write delay. CPU must wait, never sample an old byte.
  countdown<=loading?8:(transfers%7==0?80:12);
 end
 if(!resetn)begin ack<=0;countdown<=0;ready<=0;cycles<=0;transfers<=0;end
end
sms_nano_memory memory(.clk(clk),.resetn(resetn),.loading(loading),.load_valid(load_valid),.load_data(load_data),
 .rom_rd(rom_rd),.rom_addr(rom_addr),.rom_data(rom_data),.save_rd(save_rd),.save_we(save_we),
 .save_addr(save_addr),.save_din(save_din),.save_dout(save_dout),.cpu_wait_n(waitn),.running(running),.fault(fault),
 .rv_valid(1'b0),.rv_addr(23'd0),.rv_wdata(32'd0),.rv_wstrb(4'd0),.rv_ready(),
 .req(req),.wr(wr),.addr(addr),.din(din),.ack(ack),.dout(dout),.ready(ready));
wire ce_cpu,ce_vdp,ce_pix,ce_sp;
sms_nano_ce enables(.clk(clk),.resetn(resetn&&running),.enable(running),.ce_cpu(ce_cpu),.ce_vdp(ce_vdp),.ce_pix(ce_pix),.ce_sp(ce_sp));
wire[8:0]x,y;wire[11:0]color;wire[15:0]al,ar;
sms_nano_core #(.EXTERNAL_SAVE_RAM(1))dut(.clk(clk),.resetn(resetn&&running),.memory_wait_n(waitn),
 .ce_cpu(ce_cpu),.ce_vdp(ce_vdp),.ce_pix(ce_pix),.ce_sp(ce_sp),.pal(1'b0),.region(1'b1),
 .joy1(12'h011),.joy2(12'd0),.rom_rd(rom_rd),.rom_addr(rom_addr),.rom_data(rom_data),
 .save_rd(save_rd),.save_write(save_we),.save_address(save_addr),.save_wdata(save_din),.save_rdata(save_dout),
 .x(x),.y(y),.frame_height(),.color(color),.audio_l(al),.audio_r(ar));
reg[7:0]program_rom[0:65535];integer i;reg[3:0]passed=0;
always @(posedge clk)if(running&&dut.ram_we)case(dut.ram_addr[12:0])
 0:begin assert(dut.ram_data==8'h42)else $fatal(1,"Streamed ROM WRAM");passed[0]=1;end
 1:begin assert(dut.ram_data==8'h43)else $fatal(1,"Streamed ROM mirror");passed[1]=1;end
 2:begin assert(dut.ram_data==8'hee)else $fatal(1,"Streamed ROM controller");passed[2]=1;end
 3:begin assert(dut.ram_data==8'ha7)else $fatal(1,"Streamed ROM mapper bank");passed[3]=1;end
 4:assert(dut.ram_data==8'h5c)else $fatal(1,"External save SRAM read returned stale byte");
endcase
initial begin
 for(i=0;i<65536;i=i+1)program_rom[i]=0;
 program_rom[0]=8'hf3;program_rom[1]=8'h31;program_rom[2]=0;program_rom[3]=8'hd0;
 program_rom[4]=8'h3e;program_rom[5]=8'h42;program_rom[6]=8'h32;program_rom[7]=0;program_rom[8]=8'hc0;
 program_rom[9]=8'h3a;program_rom[10]=0;program_rom[11]=8'he0;program_rom[12]=8'hfe;program_rom[13]=8'h42;
 program_rom[14]=8'h20;program_rom[15]=8'hfe;
 program_rom[16]=8'h3e;program_rom[17]=8'h43;program_rom[18]=8'h32;program_rom[19]=1;program_rom[20]=8'hc0;
 program_rom[21]=8'hdb;program_rom[22]=8'hdc;program_rom[23]=8'h32;program_rom[24]=2;program_rom[25]=8'hc0;
 program_rom[26]=8'h3e;program_rom[27]=3;program_rom[28]=8'h32;program_rom[29]=8'hff;program_rom[30]=8'hff;
 program_rom[31]=8'h3a;program_rom[32]=0;program_rom[33]=8'h80;program_rom[34]=8'h32;program_rom[35]=3;program_rom[36]=8'hc0;
 // Enable the Sega mapper's cartridge RAM, write/read SRAM[0], and publish it.
 program_rom[37]=8'h3e;program_rom[38]=8'h08;program_rom[39]=8'h32;program_rom[40]=8'hfc;program_rom[41]=8'hff;
 program_rom[42]=8'h3e;program_rom[43]=8'h5c;program_rom[44]=8'h32;program_rom[45]=0;program_rom[46]=8'h80;
 program_rom[47]=8'h3a;program_rom[48]=0;program_rom[49]=8'h80;program_rom[50]=8'h32;program_rom[51]=4;program_rom[52]=8'hc0;
 program_rom[53]=8'h76;program_rom[16'hc000]=8'ha7;
 repeat(10)@(negedge clk);resetn=1;@(negedge clk);loading=1;
 // Start before SDRAM is ready. The FIFO must retain the initial ROM bytes.
 for(i=0;i<65536;i=i+1)begin
  @(negedge clk);load_data=program_rom[i];load_valid=1;
  @(negedge clk);load_valid=0;repeat(30)@(negedge clk);
  assert(!fault&&!running)else $fatal(1,"Loader FIFO/early CPU release at %0d",i);
 end
 @(negedge clk);loading=0;
 wait(running);assert(memory.count==0&&memory.job!=1)else $fatal(1,"CPU started before write drain");
 for(i=0;i<65536;i=i+1)assert(ram[i]==program_rom[i])else $fatal(1,"ROM stream mismatch at %0d",i);
 wait(passed==15&&dut.work_ram.mem[4]==8'h5c);
 assert(ram[23'h400000]==8'h5c)else $fatal(1,"Save write missing");
 $display("PASS integration: queued ROM stream before SDRAM ready, drained final write, real CPU under 12/80-cycle WAIT, banked ROM and external cartridge SRAM");$finish;
end
initial begin #100000000;$fatal(1,"Integration timeout: flags=%b PC=%h fault=%b",passed,dut.sms.z80_inst.A,fault);end
endmodule
