// NANOBLAST Tang Nano 20K integration of the upstream SMSTang SMS system.
// This is the console engine, not a board top level. Clock enables, cartridge
// reads, video scanout, BL616 transport and SDRAM arbitration are external.
module sms_nano_core #(parameter EXTERNAL_SAVE_RAM=0) (
    input wire clk, resetn,
    input wire ce_cpu, ce_vdp, ce_pix, ce_sp,
    input wire pal, region,
    input wire memory_wait_n,
    output wire save_rd,save_write,
    output wire [14:0] save_address,
    output wire [7:0] save_wdata,
    input wire [7:0] save_rdata,
    input wire [11:0] joy1, joy2,
    output wire rom_rd,
    output wire [21:0] rom_addr,
    input wire [7:0] rom_data,
    output wire [8:0] x, y,
    output wire [8:0] frame_height,
    output wire [11:0] color,
    output wire [15:0] audio_l, audio_r
);
wire [13:0] ram_addr;
wire [7:0] ram_data, ram_q;
wire ram_we;
wire [14:0] save_addr;
wire [7:0] save_data, save_q;
wire save_we;
wire th1, th2, mask_column, smode_m1, smode_m3;
assign frame_height=smode_m1?9'd224:smode_m3?9'd240:9'd192;
sms_nano_raster raster (
    .clk(clk), .resetn(resetn), .ce_pix(ce_pix), .pal(pal),
    .border(1'b0), .ggres(1'b0), .mask_column(mask_column), .cut_mask(1'b0),
    .smode_M1(smode_m1), .smode_M3(smode_m3), .x(x), .y(y),
    .hsync(), .vsync(), .hblank(), .vblank()
);
// Real SMS has 8KiB work RAM; system.v already mirrors it in the CPU map.
spram #(.widthad_a(13)) work_ram (
    .clock(clk), .address(ram_addr[12:0]), .wren(ram_we),
    .data(ram_data), .q(ram_q)
);
// Keep mapper cartridge RAM for now. This is volatile until save-file support
// is connected. Moving it to SDRAM is an option if scanout exceeds BSRAM budget.
assign save_address=save_addr;assign save_wdata=save_data;assign save_write=save_we;
generate if(EXTERNAL_SAVE_RAM)begin
    assign save_q=save_rdata;
end else begin
spram #(.widthad_a(15)) cartridge_ram (
    .clock(clk), .address(save_addr), .wren(save_we),
    .data(save_data), .q(save_q)
);
end endgenerate
system #(.MAX_SPPL(7), .SMS_ONLY(1)) sms (
    .cart_wait_n(memory_wait_n), .nvram_rd(save_rd),
    .clk_sys(clk), .ce_cpu(ce_cpu), .ce_vdp(ce_vdp),
    .ce_pix(ce_pix), .ce_sp(ce_sp), .turbo(1'b0),
    .gg(1'b0), .ggres(1'b0), .systeme(1'b0), .bios_en(1'b0),
    .GG_EN(1'b0), .GG_CODE(129'b0), .GG_RESET(!resetn), .GG_AVAIL(),
    .RESET_n(resetn), .rom_rd(rom_rd), .rom_a(rom_addr), .rom_do(rom_data),
    .j1_up(!joy1[4]), .j1_down(!joy1[5]),
    .j1_left(!joy1[6]), .j1_right(!joy1[7]),
    .j1_tl(!joy1[0]), .j1_tr(!joy1[8]), .j1_th(th1),
    .j1_start(1'b1), .j1_coin(1'b1), .j1_a3(1'b1),
    .j2_up(!joy2[4]), .j2_down(!joy2[5]),
    .j2_left(!joy2[6]), .j2_right(!joy2[7]),
    .j2_tl(!joy2[0]), .j2_tr(!joy2[8]), .j2_th(th2),
    .j2_start(1'b1), .j2_coin(1'b1), .j2_a3(1'b1),
    // Pause is active low at the Z80 NMI input. START is distinct from button 1.
    .pause(!joy1[3]), .j1_tr_out(), .j1_th_out(th1),
    .j2_tr_out(), .j2_th_out(th2),
    .E0Type(2'b0), .E1Use(1'b0), .E2Use(1'b0),
    .E0(8'hff), .F2(8'hff), .F3(8'hff),
    .has_paddle(1'b0), .has_pedal(1'b0),
    .paddle(8'b0), .paddle2(8'b0), .pedal(8'b0),
    .x(x), .y(y), .color(color), .palettemode(1'b0),
    .mask_column(mask_column), .black_column(1'b0),
    .smode_M1(smode_m1), .smode_M2(), .smode_M3(smode_m3), .ysj_quirk(1'b0),
    .pal(pal), .region(region), .mapper_lock(1'b0),
    .vdp_enables(2'b0), .psg_enables(2'b0),
    .audioL(audio_l), .audioR(audio_r), .fm_ena(1'b1),
    .dbr(1'b0), .sp64(1'b0),
    .ram_a(ram_addr), .ram_d(ram_data), .ram_we(ram_we), .ram_q(ram_q),
    .nvram_a(save_addr), .nvram_d(save_data), .nvram_we(save_we), .nvram_q(save_q),
    .encrypt(2'b0), .key_a(), .key_d(8'b0),
    .ROMCL(clk), .ROMAD(25'b0), .ROMDT(8'b0), .ROMEN(1'b0)
);
endmodule
