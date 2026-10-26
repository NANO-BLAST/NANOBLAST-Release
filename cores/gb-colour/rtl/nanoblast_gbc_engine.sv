// Experimental MiSTer-derived GB/CGB engine adapter for NANOBLAST.
// GPL-3.0-or-later; adapted from open-pocket-gbc (see ../README.md).
// External interfaces deliberately exclude the reference menu CPU, SD and HDMI.
// Clock enables and the memory/video bridges belong to the board integration.
module nanoblast_gbc_engine #(parameter [22:0] CRAM_BASE=23'h400000) (
 input clk_sys, input reset, input loading,
 input ce, input ce_n, input ce_2x, input ce_32k,
 input [7:0] buttons, // {Start, Select, B, A, Down, Up, Left, Right}, active high
 input ioctl_wr, input [24:0] ioctl_addr, input [15:0] ioctl_dout,
 input [7:0] mem_rdata,
 input save_rtc_wr,input[16:0]save_rtc_addr,input[15:0]save_rtc_data,
 output[47:0]rtc_value,output[31:0]rtc_timestamp,output rtc_written,
 output [22:0] mem_addr, output [7:0] mem_wdata,
 output mem_read_phase, output mem_cram_read, output mem_cram_write,
 output isGBC, output speed,
 output [15:0] debug_pc, output debug_boot, output [7:0] debug_lcdc,
 output lcd_clkena, output [14:0] lcd_data, output [1:0] lcd_data_gb,
 output [1:0] lcd_mode, output lcd_on, output lcd_vsync,
 output [15:0] audio_l, output [15:0] audio_r
);
wire gb_reset = reset | loading;
wire isGBC_game;
reg cgb_mode = 0;
always @(posedge clk_sys) if (gb_reset) cgb_mode <= isGBC_game;
assign isGBC = cgb_mode;
wire [14:0] ext_bus_addr;
wire ext_bus_a15, cart_rd, cart_wr, cart_oe, nCS, sdram_rd;
wire [7:0] cart_do, cart_di, cart_ram_size;
wire [1:0] joy_p54;
wire [3:0] joy_din = (~buttons[3:0] | {4{joy_p54[0]}}) &
                       (~buttons[7:4] | {4{joy_p54[1]}});
wire DMA_on;
wire [63:0] ss_ext_din, ss_ext_dout;
wire [9:0] ss_ext_adr;
wire ss_ext_wren, ss_ext_rst;
gb u_gb (
    .reset(gb_reset),
    .clk_sys(clk_sys), .ce(ce), .ce_n(ce_n), .ce_2x(ce_2x),
    .joystick(8'd0), .isGBC(isGBC), .real_cgb_boot(1'b0), .isSGB(1'b0), .extra_spr_en(1'b0),
    .ext_bus_addr(ext_bus_addr), .ext_bus_a15(ext_bus_a15),
    .cart_rd(cart_rd), .cart_wr(cart_wr), .cart_do(cart_do), .cart_di(cart_di), .cart_oe(cart_oe),
    .nCS(nCS), .PHI(), .sdram_rd(sdram_rd),
    .cgb_boot_download(1'b0), .dmg_boot_download(1'b0), .sgb_boot_download(1'b0),
    .ioctl_wr(1'b0), .ioctl_addr(25'd0), .ioctl_dout(16'd0),
    .boot_gba_en(1'b0), .fast_boot_en(1'b1),
    .audio_l(audio_l), .audio_r(audio_r), .audio_no_pops(1'b0),
    .megaduck(1'b0),
    .lcd_clkena(lcd_clkena), .lcd_data(lcd_data), .lcd_data_gb(lcd_data_gb),
    .lcd_mode(lcd_mode), .lcd_on(lcd_on), .lcd_vsync(lcd_vsync),
    .joy_p54(joy_p54), .joy_din(joy_din),
    .speed(speed), .DMA_on(DMA_on),
    .gg_reset(1'b0), .gg_en(1'b0), .gg_code(129'd0), .gg_available(),
    .sc_int_clock2(), .serial_clk_in(1'b1), .serial_clk_out(), .serial_data_in(1'b1), .serial_data_out(),
    .increaseSSHeaderCount(1'b0), .cart_ram_size(cart_ram_size),
    .save_state(1'b0), .load_state(1'b0), .savestate_number(2'd0),
    .sleep_savestate(), .savestate_ovr(),
    .SaveStateExt_Din(ss_ext_din), .SaveStateExt_Adr(ss_ext_adr), .SaveStateExt_wren(ss_ext_wren),
    .SaveStateExt_rst(ss_ext_rst), .SaveStateExt_Dout(ss_ext_dout), .SaveStateExt_load(),
    .Savestate_CRAMAddr(), .Savestate_CRAMRdEn(), .Savestate_CRAMRWrEn(), .Savestate_CRAMWriteData(),
    .Savestate_CRAMReadData(16'd0),
    .SAVE_out_Din(), .SAVE_out_Dout(64'd0), .SAVE_out_Adr(), .SAVE_out_rnw(), .SAVE_out_ena(),
    .SAVE_out_be(), .SAVE_out_done(1'b0),
    .savestate_sdram_busy(1'b0), .rewind_on(1'b0), .rewind_active(1'b0)
);

wire [22:0] mbc_addr;
wire        is_cram_addr, cram_rd, cram_wr;
wire [16:0] cram_addr;
wire [7:0] sdram_cart_dout = mem_rdata;



cart_top u_cart (
    .reset(gb_reset),
    .clk_sys(clk_sys), .ce_cpu(ce), .ce_cpu2x(ce_2x), .speed(speed),
    .megaduck(1'b0), .duck_md0_mode(1'b0), .mapper_sel(3'd0),
    .cart_addr(ext_bus_addr), .cart_a15(ext_bus_a15), .cart_rd(cart_rd), .cart_wr(cart_wr),
    .cart_do(cart_do), .cart_di(cart_di), .cart_oe(cart_oe),
    .nCS(nCS),
    .mbc_addr(mbc_addr),
    .dn_write(), .cart_ready(),
    .is_cram_addr(is_cram_addr), .cram_rd(cram_rd), .cram_wr(cram_wr), .cram_bram_wr(), .cram_addr(cram_addr),
    .cart_download(loading),
    .ram_mask_file(), .ram_size(cart_ram_size), .has_save(), .bram_save(),
    .isGBC_game(isGBC_game), .isSGB_game(),
    .ioctl_download(loading), .ioctl_wr(ioctl_wr), .ioctl_addr(ioctl_addr), .ioctl_dout(ioctl_dout), .ioctl_wait(),
    .bk_wr(1'b0), .bk_rtc_wr(save_rtc_wr), .bk_addr(save_rtc_addr), .bk_data(save_rtc_data), .bk_q(), .img_size(64'd0),
    .rom_di(sdram_cart_dout),
    .joystick_analog_0(16'd0),
    .ce_32k(ce_32k), .RTC_time(33'd0), .RTC_timestampOut(rtc_timestamp), .RTC_savedtimeOut(rtc_value), .RTC_inuse(),
    .SaveStateExt_Din(ss_ext_din), .SaveStateExt_Adr(ss_ext_adr), .SaveStateExt_wren(ss_ext_wren),
    .SaveStateExt_rst(ss_ext_rst), .SaveStateExt_Dout(ss_ext_dout),
    .savestate_load(1'b0), .savestate_ovr(1'b0),
    .Savestate_CRAMAddr(20'd0), .Savestate_CRAMRWrEn(1'b0), .Savestate_CRAMWriteData(16'd0), .Savestate_CRAM_Q(),
    .rumbling()
);

// SDRAM byte map: ROM 0..0x3fffff, cartridge RAM 0x400000..0x41ffff.
// Never expose a CPU cartridge write as a ROM write.
assign rtc_written=u_cart.mbc3 && u_cart.mappers.map_mbc3.mbc3_mode && cart_wr && !nCS && !ext_bus_addr[14];
assign mem_addr = is_cram_addr ? (CRAM_BASE | {6'd0, cram_addr}) : mbc_addr;
assign mem_wdata = cart_di;
assign mem_read_phase = sdram_rd & ~gb_reset;
assign mem_cram_read = cram_rd & ~gb_reset;
assign mem_cram_write = cram_wr & ~gb_reset;
assign debug_pc=u_gb.cpu_addr;
assign debug_boot=u_gb.boot_rom_enabled;
assign debug_lcdc=u_gb.video.lcdc;
endmodule
