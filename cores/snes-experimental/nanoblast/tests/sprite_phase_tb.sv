`timescale 1ns/1ps
// Exercise the real PPU's phase sequencer. A mixed-port RAM collision may
// destroy an unobserved read during sprite construction, but must never reach
// SPR_PIX_DATA_BUF when visible scanout consumes it.
module sprite_phase_tb;
reg clk=0;always #5 clk=~clk;
reg resetn=0,enable=1,pal=0,wr_n=1;
reg[7:0]pa=0,di=0;
SPPU dut(.CLK(clk),.RST_N(resetn),.ENABLE(enable),.DIS_SHORTLINE(1'b0),
 .PA(pa),.PARD_N(1'b1),.PAWR_N(wr_n),.DI(di),.SYSCLK_CE(1'b1),
 .VRAM_DAI(8'hff),.VRAM_DBI(8'hff),.EXTLATCH(1'b1),.PAL(pal),.BLEND(1'b0),.BG_EN(5'b11111));
SPPU_reference refcore(.CLK(clk),.RST_N(resetn),.ENABLE(enable),.DIS_SHORTLINE(1'b0),
 .PA(pa),.PARD_N(1'b1),.PAWR_N(wr_n),.DI(di),.SYSCLK_CE(1'b1),
 .VRAM_DAI(8'hff),.VRAM_DBI(8'hff),.EXTLATCH(1'b1),.PAL(pal),.BLEND(1'b0),.BG_EN(5'b11111));
integer writes=0,consumed=0,collisions=0,colored=0;
always @(negedge clk)if(resetn)begin
 assert({dut.COLOR_OUT,dut.X_OUT,dut.Y_OUT,dut.VRAM_ADDRA,dut.VRAM_ADDRB,dut.VRAM_DAO,dut.VRAM_DBO,dut.VRAM_WRA_N,dut.VRAM_WRB_N,dut.VRAM_RD_N,dut.HBLANK,dut.VBLANK,dut.HDE,dut.VDE,dut.DO}===
        {refcore.COLOR_OUT,refcore.X_OUT,refcore.Y_OUT,refcore.VRAM_ADDRA,refcore.VRAM_ADDRB,refcore.VRAM_DAO,refcore.VRAM_DBO,refcore.VRAM_WRA_N,refcore.VRAM_WRB_N,refcore.VRAM_RD_N,refcore.HBLANK,refcore.VBLANK,refcore.HDE,refcore.VDE,refcore.DO})
 else $fatal(1,"PPU differs from upstream after RAM mapping H=%0d V=%0d",dut.H_CNT,dut.V_CNT);
 if(dut.HDE&&dut.VDE&&dut.COLOR_OUT!=0)colored<=colored+1;
end
reg invalid=0;
always @(posedge clk)begin
 if(!resetn)invalid<=0;
 else begin
  if(dut.SPR_PIX_WE_A)writes<=writes+1;
  if(!dut.SPR_PIX_WE_B)begin
   invalid<=dut.SPR_PIX_WE_A && dut.SPR_PIX_ADDR_A==dut.SPR_PIXEL_X;
   if(dut.SPR_PIX_WE_A && dut.SPR_PIX_ADDR_A==dut.SPR_PIXEL_X)collisions<=collisions+1;
  end
  if(enable && dut.DOT_CLKR_CE && dut.SPR_GET_PIXEL)begin
   assert(!invalid)else $fatal(1,"Sprite RAM collision reaches visible scanout H=%0d V=%0d",dut.H_CNT,dut.V_CNT);
   consumed<=consumed+1;
  end
  assert(!(dut.SPR_PIX_WE_A&&dut.SPR_PIX_WE_B))else $fatal(1,"Simultaneous sprite construction and clear");
 end
end
// Normal bus transactions, including all eight OBJ size settings and NTSC/
// PAL, overscan/interlace. Menu-style pauses stop ENABLE at arbitrary phases.
task write_reg(input[7:0]a,input[7:0]d);
 begin @(negedge clk);pa=a;di=d;wr_n=0;@(negedge clk);wr_n=1;end
endtask
integer mode,n,j;reg[31:0]rng=32'h4a3921ab;
initial begin
 for(j=0;j<256;j=j+1)begin
  dut.OAM.mem[j]=(j%2==0)?{8'(j),8'(j/2)}:16'd0;refcore.OAM.mem[j]=dut.OAM.mem[j];
  dut.cgram.mem[j]=15'(j*131);refcore.cgram.mem[j]=dut.cgram.mem[j];
 end
 for(j=0;j<128;j=j+1)begin dut.HOAM[j]=0;refcore.HOAM[j]=0;end
 for(mode=0;mode<8;mode=mode+1)begin
  @(negedge clk);resetn=0;enable=1;pal=mode[0];repeat(4)@(posedge clk);
  @(negedge clk);resetn=1;
  // Deliberately leave different contents after reset; only the counter's
  // initialized prefix is allowed to influence an observable output.
  for(j=0;j<32;j=j+1)dut.OAM_RANGE[j]=7'(j^7'h6d);
  write_reg(8'h00,8'h0f);write_reg(8'h2c,8'h1f);write_reg(8'h2d,8'h1f);write_reg(8'h05,8'(mode));write_reg(8'h01,{3'(mode),5'd0});
  write_reg(8'h33,{5'd0,mode[2],mode[1],mode[1]});
  for(n=0;n<435000;n=n+1)begin
   @(negedge clk);
   rng=(rng<<1)^(rng[31]?32'h04c11db7:0);
   enable=rng[7:0]!=8'h23;
  end
 end
 assert(writes>1000&&consumed>100000&&collisions>0&&colored>100)else $fatal(1,"Sprite coverage insufficient writes=%0d pixels=%0d collisions=%0d",writes,consumed,collisions);
 $display("PASS real SNES PPU: eight sprite-size modes, PAL/NTSC, interlace/overscan and pauses; %0d writes, %0d visible pixels, %0d harmless collisions",writes,consumed,collisions);$finish;
end
endmodule
