module nanoblast_gb_mister_top(
 input sys_clk,s1,reset2,UART_RXD,output UART_TXD,output[1:0]led,
 output O_sdram_clk,O_sdram_cke,O_sdram_cs_n,O_sdram_cas_n,O_sdram_ras_n,O_sdram_wen_n,
 inout[31:0]IO_sdram_dq,output[10:0]O_sdram_addr,output[1:0]O_sdram_ba,output[3:0]O_sdram_dqm,
 output sd_clk,inout sd_cmd,input sd_dat0,output sd_dat1,sd_dat2,sd_dat3,
 output flash_spi_cs_n,flash_spi_mosi,flash_spi_clk,flash_spi_wp_n,flash_spi_hold_n,input flash_spi_miso,
 output joy1_strb,joy1_clk,input joy1_data,output joy2_strb,joy2_clk,input joy2_data,
 output ds_clk,ds_mosi,ds_cs,input ds_miso,output ds_clk2,ds_mosi2,ds_cs2,input ds_miso2,
 output tmds_clk_n,tmds_clk_p,output[2:0]tmds_d_n,tmds_d_p
);
wire save_rx_start,save_rx_valid,save_rx_last,save_tx_valid,save_tx_last,save_tx_ready;
wire[7:0]save_rx_data,save_tx_data;wire[15:0]save_rx_length;
wire save_pause,save_mem_req,save_mem_we,save_mem_ack,save_rtc_wr,rtc_written;
wire[16:0]save_mem_addr,save_rtc_addr;wire[15:0]save_rtc_data;
wire[31:0]save_generation,save_mem_wdata,save_mem_rdata,rtc_timestamp;wire[47:0]rtc_value;
wire clk,hclk,hclk5,main_locked,hdmi_locked,resetn,pixel_resetn;
nanoblast_mister_pll main_pll(.clkin(sys_clk),.clkout(clk),.clkoutp(O_sdram_clk),.clkoutd3(),.lock(main_locked));
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
controller_snes #(.FREQ(27_000_000))snes1(.clk(clk),.resetn(resetn),.buttons(pad1),.joy_strb(joy1_strb),.joy_clk(joy1_clk),.joy_data(joy1_data));
controller_snes #(.FREQ(27_000_000))snes2(.clk(clk),.resetn(resetn),.buttons(pad2),.joy_strb(joy2_strb),.joy_clk(joy2_clk),.joy_data(joy2_data));
controller_ds2 #(.FREQ(27_000_000))dualshock1(.clk(clk),.snes_buttons(ds1),.ds_clk(ds_clk),.ds_miso(ds_miso),.ds_mosi(ds_mosi),.ds_cs(ds_cs));
controller_ds2 #(.FREQ(27_000_000))dualshock2(.clk(clk),.snes_buttons(ds2),.ds_clk(ds_clk2),.ds_miso(ds_miso2),.ds_mosi(ds_mosi2),.ds_cs(ds_cs2));
wire overlay,loading,load_valid,pal;
wire[7:0]load_data;wire[10:0]overlay_x;wire[9:0]overlay_y;wire[15:0]overlay_color;
wire background_enable,background_oled,palette_we;wire[31:0]palette_data;
wire rv_valid,rv_ready;wire[22:0]rv_addr;wire[31:0]rv_wdata;wire[3:0]rv_wstrb;
wire[7:0]debug_index;wire debug_strobe;reg[31:0]debug_value;
nanoblast_iosys #(.CORE_ID(7),.ENABLE_DIAGNOSTICS(1),.ENABLE_SAVE(1),.FREQ(27_000_000))transport(
 .core_debug_value(debug_value),.core_debug_index(debug_index),.core_debug_strobe(debug_strobe),
 .flash_clk(flash_spi_clk),.flash_mosi(flash_spi_mosi),.flash_cs_n(flash_spi_cs_n),.flash_miso(flash_spi_miso),
 .core_status({6'd0,fault,running}),
 .clk(clk),.hclk(hclk),.resetn(resetn),.uart_rx(UART_RXD),.uart_tx(UART_TXD),
 .joy1(pad1|ds1),.joy2(pad2|ds2),.usb_joy1(hid1),.usb_joy2(hid2),
 .overlay_x(overlay_x),.overlay_y(overlay_y),.overlay_color(overlay_color),.overlay(overlay),
 .rom_loading(loading),.rom_do(load_data),.rom_do_valid(load_valid),.nes_pal(pal),
 .sd_clk(sd_clk),.sd_mosi(sd_cmd),.sd_cs_n(sd_dat3),.sd_miso(sd_dat0),
 .background_enable(background_enable),.background_oled(background_oled),.background_palette_we(palette_we),.background_palette_data(palette_data),
 .rv_valid(rv_valid),.rv_ready(rv_ready),.rv_addr(rv_addr),.rv_wdata(rv_wdata),.rv_wstrb(rv_wstrb),
 .save_rx_start(save_rx_start),.save_rx_valid(save_rx_valid),.save_rx_last(save_rx_last),.save_rx_data(save_rx_data),.save_rx_length(save_rx_length),
 .save_tx_data(save_tx_data),.save_tx_valid(save_tx_valid),.save_tx_last(save_tx_last),.save_tx_ready(save_tx_ready));

wire running,load_fault,host_fault,fault;
wire load_req,load_we,load_ack;wire[22:0]load_addr,rom_size;wire[31:0]load_wdata,load_rdata,received_crc,read_crc;wire[3:0]load_be;
wire ioctl_wr;wire[24:0]ioctl_addr;wire[15:0]ioctl_dout;
nanoblast_gbc_loader loader(.clk(clk),.resetn(resetn),.loading(loading),.load_valid(load_valid),.load_data(load_data),
 .ioctl_wr(ioctl_wr),.ioctl_addr(ioctl_addr),.ioctl_dout(ioctl_dout),.running(running),.fault(load_fault),
 .size(rom_size),.received_crc(received_crc),.read_crc(read_crc),.host_req(load_req),.host_we(load_we),.host_addr(load_addr),
 .host_wdata(load_wdata),.host_be(load_be),.host_ack(load_ack),.host_rdata(load_rdata),.memory_ready(ram_ready));
wire host_req,host_we,host_ack,host_rvalid;wire[20:0]host_addr;wire[31:0]host_wdata,lp_rdata;wire[3:0]host_be;
nanoblast_gbc_host host(.clk(clk),.resetn(resetn),.load_req(load_req),.load_we(load_we),.load_addr(load_addr),.load_wdata(load_wdata),.load_be(load_be),
 .load_ack(load_ack),.load_rdata(load_rdata),
 .save_req(save_mem_req),.save_we(save_mem_we),.save_addr(save_mem_addr),.save_wdata(save_mem_wdata),.save_ack(save_mem_ack),.save_rdata(save_mem_rdata),.rv_valid(rv_valid),.rv_addr(rv_addr),.rv_wdata(rv_wdata),.rv_wstrb(rv_wstrb),.rv_ready(rv_ready),
 .req(host_req),.we(host_we),.addr(host_addr),.wdata(host_wdata),.be(host_be),.ack(host_ack),.rvalid(host_rvalid),.rdata(lp_rdata),.fault(host_fault));
wire ram_ready,cart_ready,ce,ce_n,ce_2x,paused,cgb,speed;
wire gb_reset=!resetn||!running||fault;
wire bg_req,bg_ack,bg_enable,bg_valid;wire[19:0]bg_addr;wire[31:0]bg_data;wire[8:0]bg_word;
wire[23:0]background_rgb;wire background_valid,background_underflow;
// Break the cartridge address/decode path before the falling-edge phase generator.
// A bus request changes only on an engine enable; at least three main clocks
// separate enables, so the single-cycle ready withdrawal reaches it in time.
reg cart_ready_latched=0;
always @(posedge clk) if(!resetn||!running) cart_ready_latched<=0;
else cart_ready_latched<=cart_ready;
nanoblast_gbc_ce clocks(.clk(clk),.resetn(resetn),.enable(!running||(!overlay&&!save_pause&&!bg_enable&&bg_req==bg_ack)),
 .memory_ready(!running||cart_ready_latched),.ce(ce),.ce_n(ce_n),.ce_2x(ce_2x),.paused(paused));
wire rtc_ce;
nanoblast_gbc_rtc_tick rtc_clock(.clk(clk),.resetn(resetn),.ce_32k(rtc_ce));
wire[11:0]joy=pad1|ds1|pad2|ds2|hid1|hid2;
wire[7:0]buttons={joy[3],joy[2],joy[0]|joy[9],joy[8],joy[5],joy[4],joy[6],joy[7]};
wire[22:0]cart_addr;wire[7:0]cart_din,cart_dout;wire cart_phase,cram_rd,cram_wr;
wire[15:0]audio_l,audio_r,debug_pc;wire debug_boot;wire[7:0]debug_lcdc;
wire lcd_ce,lcd_on,lcd_vs;wire[14:0]lcd_pixel;wire[1:0]lcd_shade,lcd_mode;
nanoblast_gbc_engine engine(.clk_sys(clk),.reset(gb_reset),.loading(loading),.ce(ce),.ce_n(ce_n),.ce_2x(ce_2x),.ce_32k(rtc_ce),.buttons(buttons),
 .ioctl_wr(ioctl_wr),.ioctl_addr(ioctl_addr),.ioctl_dout(ioctl_dout),.mem_rdata(cart_dout),.mem_addr(cart_addr),.mem_wdata(cart_din),
 .save_rtc_wr(save_rtc_wr),.save_rtc_addr(save_rtc_addr),.save_rtc_data(save_rtc_data),.rtc_value(rtc_value),.rtc_timestamp(rtc_timestamp),.rtc_written(rtc_written),
 .mem_read_phase(cart_phase),.mem_cram_read(cram_rd),.mem_cram_write(cram_wr),.isGBC(cgb),.speed(speed),
 .debug_pc(debug_pc),.debug_boot(debug_boot),.debug_lcdc(debug_lcdc),.lcd_clkena(lcd_ce),.lcd_data(lcd_pixel),.lcd_data_gb(lcd_shade),
 .lcd_mode(lcd_mode),.lcd_on(lcd_on),.lcd_vsync(lcd_vs),.audio_l(audio_l),.audio_r(audio_r));
nanoblast_gb_save #(.FREQ(27000000)) saves(.clk(clk),.resetn(resetn),.running(running),.loading(loading),.paused(paused),.cart_ready(cart_ready),.ram_written(cram_wr|rtc_written),
 .rtc_value(rtc_value),.rtc_timestamp(rtc_timestamp),.rx_start(save_rx_start),.rx_valid(save_rx_valid),.rx_last(save_rx_last),.rx_data(save_rx_data),.rx_length(save_rx_length),
 .pause_request(save_pause),.generation(save_generation),.mem_req(save_mem_req),.mem_we(save_mem_we),.mem_addr(save_mem_addr),.mem_wdata(save_mem_wdata),.mem_ack(save_mem_ack),.mem_rdata(save_mem_rdata),
 .rtc_wr(save_rtc_wr),.rtc_addr(save_rtc_addr),.rtc_data(save_rtc_data),.tx_data(save_tx_data),.tx_valid(save_tx_valid),.tx_last(save_tx_last),.tx_ready(save_tx_ready));
wire lp_req,lp_ack,lp_we,lp_rvalid;wire[20:0]lp_addr;wire[31:0]lp_wdata;wire[3:0]lp_be;
nanoblast_gbc_sdram #(.REFRESH_INTERVAL(206)) ram(.clk(clk),.resetn(resetn),.ready(ram_ready),.cart_ready(cart_ready),
 .cart_rd_strobe(cart_phase),.cart_wr_strobe(cram_wr),.cart_addr(cart_addr),.cart_din(cart_din),.cart_dout(cart_dout),
 .lp_block(running&&!paused&&!cart_phase),.pd_en(1'b0),.sr_req(1'b0),
 .lp_req(lp_req),.lp_ack(lp_ack),.lp_we(lp_we),.lp_addr(lp_addr),.lp_wdata(lp_wdata),.lp_be(lp_be),.lp_rdata(lp_rdata),.lp_rvalid(lp_rvalid),
 // Before the first ROM the engine is held in reset, so no cartridge access
 // can conflict with artwork. Its phase generator need not report paused.
 .bg_enable(bg_enable&&(!running||paused)),.bg_req(bg_req),.bg_addr(bg_addr),.bg_ack(bg_ack),.bg_data(bg_data),.bg_valid(bg_valid),.bg_word(bg_word),
 .clk_sdram_p(O_sdram_clk),.O_sdram_clk(),.O_sdram_cke(O_sdram_cke),.O_sdram_cs_n(O_sdram_cs_n),.O_sdram_cas_n(O_sdram_cas_n),
 .O_sdram_ras_n(O_sdram_ras_n),.O_sdram_wen_n(O_sdram_wen_n),.O_sdram_addr(O_sdram_addr),.O_sdram_ba(O_sdram_ba),.O_sdram_dqm(O_sdram_dqm),.IO_sdram_dq(IO_sdram_dq));
menu_background backdrop(.clk(clk),.fclk(clk),.hclk(hclk),.resetn(resetn),.hresetn(pixel_resetn),.enable(background_enable),.oled(background_oled),.overlay(overlay),
 .x(overlay_x),.y(overlay_y),.palette_we(palette_we),.palette_data(palette_data),.bg_req(bg_req),.bg_addr(bg_addr),.bg_ack(bg_ack),
 .bg_data(bg_data),.bg_valid(bg_valid),.bg_word(bg_word),.bg_enable(bg_enable),.rgb(background_rgb),.valid(background_valid),.underflow(background_underflow));
wire vs_toggle,line_req,line_done,line_overrun,frame_ready,frame_overflow,video_underflow;
wire[7:0]line_no,line_done_no,lb_addr;wire[31:0]lb_data;
reg[2:0]vs_sync=0;always @(posedge clk)if(!resetn)vs_sync<=0;else vs_sync<={vs_sync[1:0],vs_toggle};
wire[1:0]rd_buf;wire wq_empty,wq_pop;wire[20:0]wq_addr;wire[31:0]wq_data;wire[5:0]wq_level;
nanoblast_gbc_frame capture(.clk(clk),.reset(gb_reset),.ce(ce),.isGBC(cgb),.lcd_clkena(lcd_ce),.lcd_data(lcd_pixel),.lcd_mode(lcd_mode),.lcd_on(lcd_on),.lcd_vsync(lcd_vs),
 .vs_event(vs_sync[2]^vs_sync[1]),.rd_buf(rd_buf),.newest(),.wq_empty(wq_empty),.wq_addr(wq_addr),.wq_data(wq_data),.wq_level(wq_level),.wq_pop(wq_pop),
 .fb_en(1'b1),.px_we(),.px_first(),.px_data(),.frame_ready(frame_ready),.overflow(frame_overflow));
nanoblast_gbc_memsys memsys(.clk(clk),.reset(!resetn),.lp_req(lp_req),.lp_ack(lp_ack),.lp_we(lp_we),.lp_addr(lp_addr),.lp_wdata(lp_wdata),.lp_be(lp_be),.lp_rdata(lp_rdata),.lp_rvalid(lp_rvalid),
 .wq_empty(wq_empty),.wq_addr(wq_addr),.wq_data(wq_data),.wq_level(wq_level),.wq_pop(wq_pop),
 .rv_req(host_req),.rv_we(host_we),.rv_addr(host_addr),.rv_wdata(host_wdata),.rv_be(host_be),.rv_ack(host_ack),.rv_rvalid(host_rvalid),
 .line_req_tgl(line_req),.line_req_no(line_no),.rd_buf(rd_buf),.vclk(hclk),.lb_raddr(lb_addr),.lb_q(lb_data),.line_done(line_done),.line_done_no(line_done_no),.line_overrun(line_overrun));
nanoblast_gbc_hdmi video(.clk(clk),.resetn(resetn),.pixel_resetn(pixel_resetn),.engine_reset(gb_reset),.clk_pixel(hclk),.clk_5x_pixel(hclk5),.is_cgb(cgb),.frame_ready(frame_ready),
 .audio_l(overlay?16'd0:audio_l),.audio_r(overlay?16'd0:audio_r),.overlay(overlay),.overlay_x(overlay_x),.overlay_y(overlay_y),.overlay_color(overlay_color),
 .background_rgb(background_rgb),.background_valid(background_valid),.vs_toggle(vs_toggle),.line_req(line_req),.line_no(line_no),.lb_addr(lb_addr),.lb_data(lb_data),
 .line_done(line_done),.line_done_no(line_done_no),.underflow(video_underflow),.tmds_clk_n(tmds_clk_n),.tmds_clk_p(tmds_clk_p),.tmds_d_n(tmds_d_n),.tmds_d_p(tmds_d_p));
assign fault=load_fault|host_fault|frame_overflow|line_overrun;
reg[31:0]gb_cycles=0,gb_pixels=0;
always @(posedge clk)if(gb_reset)begin gb_cycles<=0;gb_pixels<=0;end else if(ce)begin gb_cycles<=gb_cycles+1'b1;if(lcd_ce)gb_pixels<=gb_pixels+1'b1;end
always @*case(debug_index)
 0:debug_value=32'h47423031;
 1:debug_value={9'd0,rom_size};
 2:debug_value=received_crc^32'hffffffff;
 3:debug_value=read_crc^32'hffffffff;
 4:debug_value={18'd0,video_underflow,background_underflow,line_overrun,frame_overflow,cgb,speed,paused,cart_ready,frame_ready,debug_boot,load_fault,host_fault,running,gb_reset};
 5:debug_value={debug_pc,16'd0};
 6:debug_value={debug_lcdc,20'd0,lcd_on,lcd_ce,lcd_mode};
 7:debug_value=gb_cycles;
 8:debug_value=gb_pixels;
 9:debug_value=32'h43474231; // CGB1: negotiate before accepting .gbc/CGB-only ROMs.
 10:debug_value={8'd0,ds1,pad1};
 11:debug_value=0;
 12:debug_value=32'h534d5331; // SMS1: shared NES/SMS controller baseline.
 13:debug_value=32'h52544331; // RTC1: running MBC3 clock; no battery persistence.
 20:debug_value=32'h53415631; // SAV1: checked save-page transport.
 21:debug_value=save_generation;
 default:debug_value=0;
endcase
assign led=~{fault,running};
endmodule
