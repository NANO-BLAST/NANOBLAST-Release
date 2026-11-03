module s16_nano_top(
 input sys_clk,s1,reset2,UART_RXD,output UART_TXD,output[1:0]led,
 output O_sdram_clk,O_sdram_cke,O_sdram_cs_n,O_sdram_cas_n,O_sdram_ras_n,O_sdram_wen_n,
 inout[31:0]IO_sdram_dq,output[10:0]O_sdram_addr,output[1:0]O_sdram_ba,output[3:0]O_sdram_dqm,
 output sd_clk,inout sd_cmd,input sd_dat0,output sd_dat1,sd_dat2,sd_dat3,
 output flash_spi_cs_n,flash_spi_mosi,flash_spi_clk,flash_spi_wp_n,flash_spi_hold_n,input flash_spi_miso,
 output joy1_strb,joy1_clk,input joy1_data,output joy2_strb,joy2_clk,input joy2_data,
 output ds_clk,ds_mosi,ds_cs,input ds_miso,output ds_clk2,ds_mosi2,ds_cs2,input ds_miso2,
 output tmds_clk_n,tmds_clk_p,output[2:0]tmds_d_n,tmds_d_p
);
wire clk,hclk,hclk5,main_locked,hdmi_locked,resetn,pixel_resetn,pixel_game_resetn;
wire running,fault,underflow,overflow,bridge_fault,mem_fault,loader_fault;
wire[25:0]ioctl_addr;
s16_nano_pll main_pll(.clkin(sys_clk),.clkout(clk),.clkoutp(O_sdram_clk),.clkoutd3(),.lock(main_locked));
gowin_pll_hdmi video_pll(.clkin(sys_clk),.clkout(hclk5),.lock(hdmi_locked));
CLKDIV #(.DIV_MODE(5),.GSREN("true"))video_div(.HCLKIN(hclk5),.CLKOUT(hclk),.RESETN(1'b1),.CALIB(1'b0));
// Match NES: allow clocked configuration startup without gating all I/O on
// unused external reset pins or a PLL LOCK indication. Hold for ~1ms first.
wire startup_ready;
sms_nano_startup startup(.clk(clk),.ready(startup_ready));
reset_release main_reset(.clk(clk),.async_resetn(startup_ready),.resetn(resetn));
reset_release pixel_reset(.clk(hclk),.async_resetn(resetn),.resetn(pixel_resetn));
reset_release game_pixel_reset(.clk(hclk),.async_resetn(resetn&&running),.resetn(pixel_game_resetn));
// Flash SPI remains available to BL616 throughout core persistence.
assign flash_spi_wp_n=1;assign flash_spi_hold_n=1;assign sd_dat1=1;assign sd_dat2=1;
wire[11:0]pad1,pad2,ds1,ds2,hid1,hid2;
controller_snes #(.FREQ(50_625_000))snes1(.clk(clk),.resetn(resetn),.buttons(pad1),.joy_strb(joy1_strb),.joy_clk(joy1_clk),.joy_data(joy1_data));
controller_snes #(.FREQ(50_625_000))snes2(.clk(clk),.resetn(resetn),.buttons(pad2),.joy_strb(joy2_strb),.joy_clk(joy2_clk),.joy_data(joy2_data));
// First board candidate supports native SNES/NES and USB HID controllers.
assign ds1=0;assign ds2=0;
assign ds_clk=0;assign ds_mosi=1;assign ds_cs=1;
assign ds_clk2=0;assign ds_mosi2=1;assign ds_cs2=1;
wire overlay,loading,load_valid,configured_pal,game_gear;
wire pal=configured_pal&&!game_gear;
wire [1:0] crt_mode;
wire[7:0]debug_index,gamegear_top;
wire[31:0]debug_value=debug_index==0?32'h53313631:debug_index==1?{6'd0,ioctl_addr}:debug_index==2?{27'd0,underflow,overflow,bridge_fault,mem_fault,loader_fault}:32'd0;
wire[7:0]load_data;wire[10:0]overlay_x;wire[9:0]overlay_y;wire[15:0]overlay_color;
wire background_enable,background_oled,palette_we;wire[31:0]palette_data;
wire rv_valid,rv_ready;wire[22:0]rv_addr;wire[31:0]rv_wdata;wire[3:0]rv_wstrb;
nanoblast_iosys #(.CORE_ID(16),.ENABLE_DIAGNOSTICS(1),.FREQ(50_625_000))transport(
 .flash_clk(flash_spi_clk),.flash_mosi(flash_spi_mosi),.flash_cs_n(flash_spi_cs_n),.flash_miso(flash_spi_miso),
 .core_status({6'd0,fault,running}),.core_debug_index(debug_index),.core_debug_value(debug_value),
 .clk(clk),.hclk(hclk),.resetn(resetn),.uart_rx(UART_RXD),.uart_tx(UART_TXD),
 .joy1(pad1|ds1),.joy2(pad2|ds2),.usb_joy1(hid1),.usb_joy2(hid2),
 .overlay_x(overlay_x),.overlay_y(overlay_y),.overlay_color(overlay_color),.overlay(overlay),
 .rom_loading(loading),.rom_do(load_data),.rom_do_valid(load_valid),.nes_pal(configured_pal),.crt_mode(crt_mode),.game_gear(game_gear),
 .sd_clk(sd_clk),.sd_mosi(sd_cmd),.sd_cs_n(sd_dat3),.sd_miso(sd_dat0),
 .background_enable(background_enable),.background_oled(background_oled),.background_palette_we(palette_we),.background_palette_data(palette_data),
 .rv_valid(rv_valid),.rv_ready(rv_ready),.rv_addr(rv_addr),.rv_wdata(rv_wdata),.rv_wstrb(rv_wstrb));

assign rv_ready=rv_valid; // System 16 uses these SDRAM addresses for game memory.
wire[11:0]joy1=pad1|ds1|hid1,joy2=pad2|ds2|hid2;
function automatic[8:0]arcade_joy(input[11:0]p);
 arcade_joy=~{2'b00,p[1],p[0],p[8],p[4],p[5],p[6],p[7]};
endfunction
reg clk24=0;
always @(posedge clk)clk24<=~clk24;
wire pxl_ce,pxl2_ce;
// Preserve the original pixel rate (50.3181818 MHz / 8) on the 50.625 MHz board PLL.
jtframe_frac_cen #(.W(2),.WC(8)) pxlen(.clk(clk),.n(8'd41),.m(8'd165),
 .cen({pxl_ce,pxl2_ce}),.cenb());
wire[4:0]red,green,blue;wire lhbl,lvbl;
wire[15:0]snd;
wire[3:0]ba_rd,ba_wr,ba_ack,ba_dst,ba_dok,ba_rdy;
wire[21:0]ba0_addr,ba1_addr,ba2_addr,ba3_addr,prog_addr;
wire[15:0]ba0_din,ba1_din,ba2_din,ba3_din,data_read,prog_data;
wire[1:0]ba0_dsn,ba1_dsn,ba2_dsn,ba3_dsn,prog_ba,prog_mask;
wire prog_we,prog_ack,ioctl_wr,ioctl_rom,ram_ready;
wire[7:0]ioctl_dout;
wire game_reset=!resetn||!running;
jts16b_game_sdram engine(
 .clk(clk),.rst(game_reset),.clk24(clk24),.rst24(game_reset),.clk96(clk),.rst96(game_reset),
 .pxl_cen(pxl_ce),.pxl2_cen(pxl2_ce),.red(red),.green(green),.blue(blue),.LHBL(lhbl),.LVBL(lvbl),.HS(),.VS(),
 .cab_1p(~{2'b00,joy2[3],joy1[3]}),.coin(~{2'b00,joy2[2],joy1[2]}),
 .joystick1(arcade_joy(joy1)),.joystick2(arcade_joy(joy2)),.joystick3(9'h1ff),.joystick4(9'h1ff),
 .dial_x(2'd0),.dial_y(2'd0),.joyana_l1(16'd0),.joyana_l2(16'd0),.joyana_l3(16'd0),.joyana_l4(16'd0),
 .joyana_r1(16'd0),.joyana_r2(16'd0),.joyana_r3(16'd0),.joyana_r4(16'd0),
 .snd_en(6'h3f),.snd_vol(8'h80),.status(32'd0),.dipsw(32'hffffffff),
 .dip_pause(!overlay),.dip_test(1'b1),.service(1'b1),.tilt(1'b1),.dip_flip(),.dip_fxlevel(2'd0),
 .st_addr(8'd0),.st_dout(),.gfx_en(4'hf),.debug_bus(8'd0),.debug_view(),
 .ioctl_addr(ioctl_addr),.ioctl_dout(ioctl_dout),.ioctl_wr(ioctl_wr),.ioctl_rom(ioctl_rom),.ioctl_ram(1'b0),.ioctl_cart(1'b0),.ioctl_din(),.dwnld_busy(),
 .ba0_addr(ba0_addr),.ba1_addr(ba1_addr),.ba2_addr(ba2_addr),.ba3_addr(ba3_addr),
 .ba_rd(ba_rd),.ba_wr(ba_wr),.ba0_din(ba0_din),.ba1_din(ba1_din),.ba2_din(ba2_din),.ba3_din(ba3_din),
 .ba0_dsn(ba0_dsn),.ba1_dsn(ba1_dsn),.ba2_dsn(ba2_dsn),.ba3_dsn(ba3_dsn),
 .ba_ack(ba_ack),.ba_dst(ba_dst),.ba_dok(ba_dok),.ba_rdy(ba_rdy),.data_read(data_read),
 .prog_addr(prog_addr),.prog_ba(prog_ba),.prog_we(prog_we),.prog_rd(),.prog_data(prog_data),.prog_mask(prog_mask),
 .prog_ack(prog_ack),.prog_rdy(prog_ack),.prog_dst(1'b0),.prog_dok(1'b0),.snd(snd),.snd_vu(),.snd_peak(),.sample());
wire bank_req,bank_wr,bank_ack;wire[22:0]bank_addr;wire[31:0]bank_din,bank_dout;wire[3:0]bank_wmask;
s16_jtframe_bank_bridge banks(.clk(clk),.resetn(resetn&&running),.mem_ready(ram_ready&&running),
 .rd(ba_rd),.wr(ba_wr),.bank_addr({ba3_addr,ba2_addr,ba1_addr,ba0_addr}),
 .bank_din({ba3_din,ba2_din,ba1_din,ba0_din}),.bank_dsn({ba3_dsn,ba2_dsn,ba1_dsn,ba0_dsn}),
 .ack(ba_ack),.dst(ba_dst),.dok(ba_dok),.rdy(ba_rdy),.data_read(data_read),
 .mem_req(bank_req),.mem_wr(bank_wr),.mem_addr(bank_addr),.mem_din(bank_din),.mem_wmask(bank_wmask),
 .mem_ack(bank_ack),.mem_dout(bank_dout),.fault(bridge_fault));
wire mem_req,mem_wr,mem_ack;wire[22:0]mem_addr;wire[31:0]mem_din,mem_dout;wire[3:0]mem_wmask;
s16_loader loader(.clk(clk),.resetn(resetn),.loading(loading),.load_valid(load_valid),.load_data(load_data),
 .ready(ram_ready),.running(running),.fault(loader_fault),.ioctl_addr(ioctl_addr),.ioctl_dout(ioctl_dout),.ioctl_wr(ioctl_wr),.ioctl_rom(ioctl_rom),
 .prog_we(prog_we),.prog_addr(prog_addr),.prog_ba(prog_ba),.prog_data(prog_data),.prog_mask(prog_mask),.prog_ack(prog_ack),
 .bank_req(bank_req),.bank_wr(bank_wr),.bank_addr(bank_addr),.bank_din(bank_din),.bank_wmask(bank_wmask),.bank_ack(bank_ack),.bank_dout(bank_dout),
 .mem_req(mem_req),.mem_wr(mem_wr),.mem_addr(mem_addr),.mem_din(mem_din),.mem_wmask(mem_wmask),.mem_ack(mem_ack),.mem_dout(mem_dout));
wire burst_req,burst_wr,burst_ack,burst_valid;wire[22:0]burst_addr;wire[8:0]burst_length,burst_word,burst_index;
wire[31:0]burst_din,burst_data;wire[23:0]game_rgb;wire display_valid;
s16_video_dma framebuffer(.clk(clk),.resetn(resetn&&running),.pix_ce(pxl_ce),.lhbl(lhbl),.lvbl(lvbl),.color({red,green,blue}),
 .pclk(hclk),.presetn(pixel_game_resetn),.cx(overlay_x),.cy(overlay_y),.rgb(game_rgb),
 .burst_req(burst_req),.burst_wr(burst_wr),.burst_addr(burst_addr),.burst_length(burst_length),.burst_din(burst_din),
 .burst_ack(burst_ack),.burst_valid(burst_valid),.burst_data(burst_data),.burst_word(burst_word),.burst_index(burst_index),
 .overflow(overflow),.underflow(underflow),.display_valid(display_valid));
s16_sdram32_burst #(.FREQ(50_625_000))ram(.burst_enable(running),.clk(clk),.resetn(resetn),.req(mem_req),.wr(mem_wr),.addr(mem_addr),.din(mem_din),.wmask(mem_wmask),
 .ack(mem_ack),.dout(mem_dout),.ready(ram_ready),
 .burst_req(burst_req),.burst_wr(burst_wr),.burst_addr(burst_addr),.burst_length(burst_length),.burst_din(burst_din),
 .burst_ack(burst_ack),.burst_valid(burst_valid),.burst_data(burst_data),.burst_word(burst_word),.burst_index(burst_index),.fault(mem_fault),
 .sdram_dq(IO_sdram_dq),.sdram_a(O_sdram_addr),.sdram_ba(O_sdram_ba),.sdram_dqm(O_sdram_dqm),
 .sdram_cs_n(O_sdram_cs_n),.sdram_ras_n(O_sdram_ras_n),.sdram_cas_n(O_sdram_cas_n),.sdram_we_n(O_sdram_wen_n),.sdram_cke(O_sdram_cke));
s16_hdmi video(.clk(clk),.resetn(resetn),.pixel_resetn(pixel_resetn),.clk_pixel(hclk),.clk_5x_pixel(hclk5),
 .game_rgb(game_rgb),.audio_l(overlay||!running?16'd0:snd),.audio_r(overlay||!running?16'd0:snd),
 .overlay(overlay),.overlay_x(overlay_x),.overlay_y(overlay_y),.overlay_color(overlay_color),.crt_mode(crt_mode),
 .tmds_clk_n(tmds_clk_n),.tmds_clk_p(tmds_clk_p),.tmds_d_n(tmds_d_n),.tmds_d_p(tmds_d_p));
assign fault=loader_fault|mem_fault|bridge_fault;
assign led=~{fault,running};
endmodule
