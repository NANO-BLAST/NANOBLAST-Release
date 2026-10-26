module sms_nano_top(
 input sys_clk,s1,reset2,UART_RXD,output UART_TXD,output[1:0]led,
 output O_sdram_clk,O_sdram_cke,O_sdram_cs_n,O_sdram_cas_n,O_sdram_ras_n,O_sdram_wen_n,
 inout[31:0]IO_sdram_dq,output[10:0]O_sdram_addr,output[1:0]O_sdram_ba,output[3:0]O_sdram_dqm,
 output sd_clk,inout sd_cmd,input sd_dat0,output sd_dat1,sd_dat2,sd_dat3,
 output flash_spi_cs_n,flash_spi_mosi,flash_spi_clk,flash_spi_wp_n,flash_spi_hold_n,input flash_spi_miso,
 output joy1_strb,joy1_clk,input joy1_data,output joy2_strb,joy2_clk,input joy2_data,
 output ds_clk,ds_mosi,ds_cs,input ds_miso,output ds_clk2,ds_mosi2,ds_cs2,input ds_miso2,
 output tmds_clk_n,tmds_clk_p,output[2:0]tmds_d_n,tmds_d_p
);
wire clk,hclk,hclk5,main_locked,hdmi_locked,resetn,pixel_resetn;
wire running,fault;
sms_nano_pll main_pll(.clkin(sys_clk),.clkout(clk),.clkoutp(O_sdram_clk),.clkoutd3(),.lock(main_locked));
gowin_pll_hdmi video_pll(.clkin(sys_clk),.clkout(hclk5),.lock(hdmi_locked));
CLKDIV #(.DIV_MODE(5),.GSREN("true"))video_div(.HCLKIN(hclk5),.CLKOUT(hclk),.RESETN(1'b1),.CALIB(1'b0));
// Match NES: allow clocked configuration startup without gating all I/O on
// unused external reset pins or a PLL LOCK indication. Hold for ~1ms first.
wire startup_ready;
sms_nano_startup startup(.clk(clk),.ready(startup_ready));
reset_release main_reset(.clk(clk),.async_resetn(startup_ready),.resetn(resetn));
reset_release pixel_reset(.clk(hclk),.async_resetn(resetn),.resetn(pixel_resetn));
// Flash SPI remains available to BL616 throughout core persistence.
assign flash_spi_wp_n=1;assign flash_spi_hold_n=1;assign sd_dat1=1;assign sd_dat2=1;
wire[11:0]pad1,pad2,ds1,ds2,hid1,hid2;
controller_snes #(.FREQ(64_800_000))snes1(.clk(clk),.resetn(resetn),.buttons(pad1),.joy_strb(joy1_strb),.joy_clk(joy1_clk),.joy_data(joy1_data));
controller_snes #(.FREQ(64_800_000))snes2(.clk(clk),.resetn(resetn),.buttons(pad2),.joy_strb(joy2_strb),.joy_clk(joy2_clk),.joy_data(joy2_data));
controller_ds2 #(.FREQ(64_800_000))dualshock1(.clk(clk),.snes_buttons(ds1),.ds_clk(ds_clk),.ds_miso(ds_miso),.ds_mosi(ds_mosi),.ds_cs(ds_cs));
controller_ds2 #(.FREQ(64_800_000))dualshock2(.clk(clk),.snes_buttons(ds2),.ds_clk(ds_clk2),.ds_miso(ds_miso2),.ds_mosi(ds_mosi2),.ds_cs(ds_cs2));
wire overlay,loading,load_valid,configured_pal,game_gear;
wire pal=configured_pal&&!game_gear;
wire[7:0]debug_index,gamegear_top;
wire[31:0]debug_value=debug_index==0?32'h53474731:debug_index==1?{31'd0,game_gear}:32'd0;
wire[7:0]load_data;wire[10:0]overlay_x;wire[9:0]overlay_y;wire[15:0]overlay_color;
wire background_enable,background_oled,palette_we;wire[31:0]palette_data;
wire rv_valid,rv_ready;wire[22:0]rv_addr;wire[31:0]rv_wdata;wire[3:0]rv_wstrb;
nanoblast_iosys #(.CORE_ID(5),.ENABLE_DIAGNOSTICS(1),.FREQ(64_800_000))transport(
 .flash_clk(flash_spi_clk),.flash_mosi(flash_spi_mosi),.flash_cs_n(flash_spi_cs_n),.flash_miso(flash_spi_miso),
 .core_status({6'd0,fault,running}),.core_debug_index(debug_index),.core_debug_value(debug_value),
 .clk(clk),.hclk(hclk),.resetn(resetn),.uart_rx(UART_RXD),.uart_tx(UART_TXD),
 .joy1(pad1|ds1),.joy2(pad2|ds2),.usb_joy1(hid1),.usb_joy2(hid2),
 .overlay_x(overlay_x),.overlay_y(overlay_y),.overlay_color(overlay_color),.overlay(overlay),
 .rom_loading(loading),.rom_do(load_data),.rom_do_valid(load_valid),.nes_pal(configured_pal),.game_gear(game_gear),
 .sd_clk(sd_clk),.sd_mosi(sd_cmd),.sd_cs_n(sd_dat3),.sd_miso(sd_dat0),
 .background_enable(background_enable),.background_oled(background_oled),.background_palette_we(palette_we),.background_palette_data(palette_data),
 .rv_valid(rv_valid),.rv_ready(rv_ready),.rv_addr(rv_addr),.rv_wdata(rv_wdata),.rv_wstrb(rv_wstrb));
wire rom_rd,save_rd,save_we,cpu_wait_n,ram_ready;
wire[21:0]rom_addr;wire[7:0]rom_data,save_din,save_dout;wire[14:0]save_addr;
wire ram_req,ram_ack,ram_wr;wire[22:0]ram_addr;wire[7:0]ram_din,ram_dout;
sms_nano_memory memory(
 .clk(clk),.resetn(resetn),.loading(loading),.load_valid(load_valid),.load_data(load_data),
 .rom_rd(rom_rd),.rom_addr(rom_addr),.rom_data(rom_data),
 .save_rd(save_rd),.save_we(save_we),.save_addr(save_addr),.save_din(save_din),.save_dout(save_dout),
 .cpu_wait_n(cpu_wait_n),.running(running),.fault(fault),
 .rv_valid(rv_valid),.rv_addr(rv_addr),.rv_wdata(rv_wdata),.rv_wstrb(rv_wstrb),.rv_ready(rv_ready),
 .req(ram_req),.wr(ram_wr),.addr(ram_addr),.din(ram_din),.ack(ram_ack),.dout(ram_dout),.ready(ram_ready));
wire ce_cpu,ce_vdp,ce_pix,ce_sp;
sms_nano_ce enables(.clk(clk),.resetn(resetn&&running),.enable(running&&!overlay),
 .ce_cpu(ce_cpu),.ce_vdp(ce_vdp),.ce_pix(ce_pix),.ce_sp(ce_sp));
wire[8:0]x,y,height;wire[11:0]color;wire[15:0]audio_l,audio_r;
sms_nano_core #(.EXTERNAL_SAVE_RAM(1))engine(
 .clk(clk),.resetn(resetn&&running),.ce_cpu(ce_cpu),.ce_vdp(ce_vdp),.ce_pix(ce_pix),.ce_sp(ce_sp),
 .pal(pal),.region(!game_gear),.game_gear(game_gear),.joy1(pad1|ds1|hid1),.joy2(pad2|ds2|hid2),
 .memory_wait_n(cpu_wait_n),.rom_rd(rom_rd),.rom_addr(rom_addr),.rom_data(rom_data),
 .save_rd(save_rd),.save_write(save_we),.save_address(save_addr),.save_wdata(save_din),.save_rdata(save_dout),
 .x(x),.y(y),.frame_height(height),.gamegear_top(gamegear_top),.color(color),.audio_l(audio_l),.audio_r(audio_r));
wire bg_req,bg_ack,bg_enable,bg_valid;wire[19:0]bg_addr;wire[31:0]bg_data;wire[8:0]bg_word;
wire[23:0]background_rgb;wire background_valid,background_underflow;
menu_background backdrop(.clk(clk),.fclk(clk),.hclk(hclk),.resetn(resetn),.hresetn(pixel_resetn),
 .enable(background_enable),.oled(background_oled),.overlay(overlay),.x(overlay_x),.y(overlay_y),
 .palette_we(palette_we),.palette_data(palette_data),.bg_req(bg_req),.bg_addr(bg_addr),
 .bg_ack(bg_ack),.bg_data(bg_data),.bg_valid(bg_valid),.bg_word(bg_word),.bg_enable(bg_enable),
 .rgb(background_rgb),.valid(background_valid),.underflow(background_underflow));
sms_nano_sdram #(.FREQ(64_800_000))ram(
 .clk(clk),.resetn(resetn),.req(ram_req),.wr(ram_wr),.addr(ram_addr),.din(ram_din),
 .ack(ram_ack),.dout(ram_dout),.ready(ram_ready),
 .bg_enable(bg_enable),.bg_req(bg_req),.bg_addr(bg_addr),.bg_ack(bg_ack),.bg_valid(bg_valid),.bg_data(bg_data),.bg_word(bg_word),
 .sdram_dq(IO_sdram_dq),.sdram_a(O_sdram_addr),.sdram_ba(O_sdram_ba),.sdram_dqm(O_sdram_dqm),
 .sdram_cs_n(O_sdram_cs_n),.sdram_ras_n(O_sdram_ras_n),.sdram_cas_n(O_sdram_cas_n),.sdram_we_n(O_sdram_wen_n),.sdram_cke(O_sdram_cke));
sms_nano_hdmi video(
 .clk(clk),.resetn(resetn),.pixel_resetn(pixel_resetn),.clk_pixel(hclk),.clk_5x_pixel(hclk5),
 .game_gear(game_gear),.gamegear_top(gamegear_top),.ce_pix(ce_pix),.x(x),.y(y),.color(color),.height(height),
 .audio_l(overlay?16'd0:audio_l),.audio_r(overlay?16'd0:audio_r),
 .overlay(overlay),.overlay_x(overlay_x),.overlay_y(overlay_y),.overlay_color(overlay_color),
 .background_rgb(background_rgb),.background_valid(background_valid),
 .tmds_clk_n(tmds_clk_n),.tmds_clk_p(tmds_clk_p),.tmds_d_n(tmds_d_n),.tmds_d_p(tmds_d_p));
assign led=~{fault,running};
endmodule
