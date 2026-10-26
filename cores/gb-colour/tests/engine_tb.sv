`timescale 1ns/1ps
module engine_tb;
reg clk=0;
always #5 clk=~clk;
reg reset=1,loading=0;
wire ce,ce_n,ce_2x;
nanoblast_gbc_ce phases(.clk(clk),.resetn(!reset),.enable(1'b1),.memory_ready(1'b1),.ce(ce),.ce_n(ce_n),.ce_2x(ce_2x),.paused());
reg ioctl_wr=0;
reg [24:0] ioctl_addr=0;
reg [15:0] ioctl_dout=0;
wire [22:0] addr;
wire [7:0] wdata;
wire rd_phase,cram_read,cram_write,cgb,speed,px,on,vs;
wire [14:0] color;
wire [1:0] shade,mode;
wire [15:0] al,ar;
reg [7:0] rom[0:4194303];
reg [7:0] ram[0:131071];
wire [7:0] rdata=addr>=23'h400000 ? ram[addr[16:0]] : rom[addr[21:0]];
always @(posedge clk) if(cram_write) ram[addr[16:0]]<=wdata;
nanoblast_gbc_engine dut(.save_rtc_wr(1'b0),.save_rtc_addr(17'd0),.save_rtc_data(16'd0),.clk_sys(clk),.reset(reset),.loading(loading),
 .ce(ce),.ce_n(ce_n),.ce_2x(ce_2x),.ce_32k(1'b0),.buttons(8'd0),
 .ioctl_wr(ioctl_wr),.ioctl_addr(ioctl_addr),.ioctl_dout(ioctl_dout),.mem_rdata(rdata),
 .mem_addr(addr),.mem_wdata(wdata),.mem_read_phase(rd_phase),.mem_cram_read(cram_read),.mem_cram_write(cram_write),
 .isGBC(cgb),.speed(speed),.lcd_clkena(px),.lcd_data(color),.lcd_data_gb(shade),.lcd_mode(mode),.lcd_on(on),.lcd_vsync(vs),.audio_l(al),.audio_r(ar));
integer file,bytes,i,batch,frames=0,pixels=0;
reg oldvs=0;
reg [32767:0] colors=0;
integer unique_colors=0;
string path;
always @(posedge clk) if(!reset&&!loading&&ce) begin
 oldvs<=vs;
 if(vs&&!oldvs)frames<=frames+1;
 if(px&&on&&!dut.u_gb.boot_rom_enabled)begin pixels<=pixels+1;colors[color]<=1'b1;end
end
initial begin
 if(!$value$plusargs("ROM=%s",path))$fatal(1,"ROM required");
 file=$fopen(path,"rb");if(!file)$fatal(1,"ROM open failed");
 bytes=$fread(rom,file);$fclose(file);
 for(i=0;i<131072;i=i+1)ram[i]=0;
 repeat(100)@(negedge clk);
 loading=1;reset=0;
 // Same paired little-endian header words as MiSTer; include every bank in ROM mask.
 for(i=0;i<bytes;i=i+16384)begin
  ioctl_addr=i;ioctl_dout={rom[i+1],rom[i]};ioctl_wr=1;@(negedge clk);ioctl_wr=0;@(negedge clk);
 end
 for(i=0;i<336;i=i+2)begin
  ioctl_addr=i;ioctl_dout={rom[i+1],rom[i]};ioctl_wr=1;@(negedge clk);ioctl_wr=0;@(negedge clk);
 end
 repeat(32)@(negedge clk);
 if(cgb!==rom[16'h143][7])$fatal(1,"Header mode mismatch");
 loading=0;
 // Allow the replacement boot ROM to finish before counting game output.
 begin : run_game
  for(batch=0;batch<150;batch=batch+1)begin
   repeat(2000000)@(negedge clk);
   if(!dut.u_gb.boot_rom_enabled&&pixels>=46080&&$countones(colors)>(cgb?4:3))disable run_game;
  end
 end
 for(i=0;i<32768;i=i+1)if(colors[i])unique_colors=unique_colors+1;
 $display("RESULT cgb=%0d speed=%0d frames=%0d pixels=%0d colors=%0d PC=%04x",cgb,speed,frames,pixels,unique_colors,dut.u_gb.cpu_addr);
 if(dut.u_gb.boot_rom_enabled||frames<10||pixels<23040||unique_colors<(cgb?5:4))$fatal(1,"No game output");
 $display("PASS cartridge mode, CPU boot and LCD colours at port clock-enable ratio (ideal cartridge memory)");
 $finish;
end
endmodule
