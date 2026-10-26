module mappers(
	input         reset,

	input         clk_sys,
	input         ce_cpu,
	input         ce_cpu2x,
	input         speed,

	input         mbc1,
	input         mbc1m,
	input         mbc2,
	input         mbc3,
	input         mbc30,
	input         mbc5,
	input         mbc6,
	input         mbc7,
	input         mmm01,
	input         huc1,
	input         huc3,
	input         gb_camera,
	input         tama,
	input         rocket,
	input         sachen,
	input         wisdom_tree,
	input         mani161,

	input         megaduck,
	input         duck_md0_mode,

	input         isGBC_game,

	input  [15:0] joystick_analog_0,

	input         ce_32k,
	input  [32:0] RTC_time,
	output [31:0] RTC_timestampOut,
	output [47:0] RTC_savedtimeOut,
	output        RTC_inuse,

	input         bk_wr,
	input         bk_rtc_wr,
	input  [16:0] bk_addr,
	input  [15:0] bk_data,
	input  [63:0] img_size,

	input         savestate_load,
	input  [15:0] savestate_data,
	output [15:0] savestate_back,
	input  [63:0] savestate_data2,
	output [63:0] savestate_back2,

	input         has_ram,
	input   [3:0] ram_mask,
	input   [8:0] rom_mask,

	input  [14:0] cart_addr,
	input         cart_a15,

	input   [7:0] cart_mbc_type,

	input         cart_rd,
	input         cart_wr,
	input   [7:0] cart_di,
	output        cart_oe,

	input   [7:0] rom_di,
	output  [7:0] rom_do,

	input         nCS,

	input         cram_rd,
	input   [7:0] cram_di,    // input from Cart RAM q
	output  [7:0] cram_do,    // output to CPU
	output [16:0] cram_addr,

	output  [7:0] cram_wr_do, // For writing to Cart RAM directly without CPU (MBC7 EEPROM)
	output        cram_wr,

	output [22:0] mbc_addr,
	output        ram_enabled,
	output        has_battery,
	output        rumbling

);

// NANOBLAST: independent mapper outputs and an explicit mux. Internal
// tri-state resolution is not portable between Intel and Gowin synthesis.
wire ce = speed ? ce_cpu2x : ce_cpu;
wire no_mapper = !(mbc1|mbc2|mbc3|mbc5);
wire single_bank = no_mapper && !rom_mask[1];
wire use1 = mbc1 || (no_mapper && !single_bank);
wire [22:0] a1,a2,a3,a5;
wire [16:0] c1,c2,c3,c5;
wire [7:0] d1,d2,d3,d5;
wire r1,r2,r3,r5,b1,b2,b3,b5,oe3;
wire [15:0] s1,s2,s3,s5;
wire [31:0] rtc_stamp;
wire [47:0] rtc_saved;
wire rtc_active;
mbc1 map_mbc1 (
	.enable           ( use1 ),
	.mbc1m            ( mbc1m ),

	.clk_sys          ( clk_sys ),
	.ce_cpu           ( ce ),

	.savestate_load   ( savestate_load ),
	.savestate_data   ( savestate_data ),
	.savestate_back_b ( s1 ),

	.has_ram          ( has_ram  ),
	.ram_mask         ( ram_mask[1:0] ),
	.rom_mask         ( rom_mask[6:0] ),

	.cart_addr        ( cart_addr ),
	.cart_a15         ( cart_a15 ),

	.cart_mbc_type    ( cart_mbc_type ),

	.cart_wr          ( cart_wr ),
	.cart_di          ( cart_di ),

	.cram_di          ( cram_di ),
	.cram_do_b        ( d1 ),
	.cram_addr_b      ( c1 ),

	.mbc_addr_b       ( a1 ),
	.ram_enabled_b    ( r1 ),
	.has_battery_b    ( b1 )
);
mbc2 map_mbc2 (
	.enable           ( mbc2 ),

	.clk_sys          ( clk_sys ),
	.ce_cpu           ( ce ),

	.savestate_load   ( savestate_load ),
	.savestate_data   ( savestate_data ),
	.savestate_back_b ( s2 ),

	.ram_mask         ( ram_mask[1:0] ),
	.rom_mask         ( rom_mask[6:0] ),

	.cart_addr        ( cart_addr ),
	.cart_a15         ( cart_a15 ),

	.cart_mbc_type    ( cart_mbc_type ),

	.cart_wr          ( cart_wr ),
	.cart_di          ( cart_di ),

	.cram_di          ( cram_di ),
	.cram_do_b        ( d2 ),
	.cram_addr_b      ( c2 ),

	.mbc_addr_b       ( a2 ),
	.ram_enabled_b    ( r2 ),
	.has_battery_b    ( b2 )
);
mbc3 map_mbc3 (
	.enable            ( mbc3 ),
	.reset             ( reset ),
	.mbc30             ( mbc30 ),

	.clk_sys           ( clk_sys ),
	.ce_cpu            ( ce ),

	.savestate_load    ( savestate_load ),
	.savestate_data    ( savestate_data ),
	.savestate_back_b  ( s3 ),

	.ce_32k            ( ce_32k            ),
	.RTC_time          ( RTC_time         ),
	.RTC_timestampOut_b( rtc_stamp ),
	.RTC_savedtimeOut_b( rtc_saved ),
	.RTC_inuse_b       ( rtc_active ),

	.bk_wr             ( bk_wr     ),
	.bk_rtc_wr         ( bk_rtc_wr ),
	.bk_addr           ( bk_addr   ),
	.bk_data           ( bk_data   ),
	.img_size          ( img_size  ),

	.has_ram           ( has_ram  ),
	.ram_mask          ( ram_mask[2:0] ),
	.rom_mask          ( rom_mask[7:0] ),

	.cart_addr         ( cart_addr     ),
	.cart_a15          ( cart_a15      ),

	.cart_mbc_type     ( cart_mbc_type ),

	.cart_rd           ( cart_rd ),
	.cart_wr           ( cart_wr ),
	.cart_di           ( cart_di ),
	.cart_oe_b         ( oe3 ),

	.nCS               ( nCS      ),

	.cram_di           ( cram_di     ),
	.cram_do_b         ( d3 ),
	.cram_addr_b       ( c3 ),

	.mbc_addr_b        ( a3 ),
	.ram_enabled_b     ( r3 ),
	.has_battery_b     ( b3 )
);
mbc5 map_mbc5 (
	.enable           ( mbc5 ),

	.clk_sys          ( clk_sys ),
	.ce_cpu           ( ce ),

	.savestate_load   ( savestate_load ),
	.savestate_data   ( savestate_data ),
	.savestate_back_b ( s5 ),

	.has_ram          ( has_ram  ),
	.ram_mask         ( ram_mask ),
	.rom_mask         ( rom_mask ),

	.cart_addr        ( cart_addr ),
	.cart_a15         ( cart_a15 ),
	.cart_mbc_type    ( cart_mbc_type ),

	.cart_wr          ( cart_wr ),
	.cart_di          ( cart_di ),

	.cram_di          ( cram_di ),
	.cram_do_b        ( d5 ),
	.cram_addr_b      ( c5 ),

	.mbc_addr_b       ( a5 ),
	.ram_enabled_b    ( r5 ),
	.has_battery_b    ( b5 ),
	.rumbling         ( rumbling )
);

assign mbc_addr = single_bank ? {8'd0,cart_addr} : mbc3 ? a3 : mbc2 ? a2 : mbc5 ? a5 : a1;
assign cram_addr = single_bank ? {4'd0,cart_addr[12:0]} : mbc3 ? c3 : mbc2 ? c2 : mbc5 ? c5 : c1;
assign ram_enabled = single_bank ? has_ram : mbc3 ? r3 : mbc2 ? r2 : mbc5 ? r5 : r1;
assign has_battery = single_bank ? cart_mbc_type==8'h09 : mbc3 ? b3 : mbc2 ? b2 : mbc5 ? b5 : b1;
assign cram_do = single_bank ? (has_ram ? cram_di : 8'hff) : mbc3 ? d3 : mbc2 ? d2 : mbc5 ? d5 : d1;
assign rom_do = rom_di;
assign cart_oe = mbc3 ? oe3 : ((cart_rd && !cart_a15) || (cram_rd && ram_enabled));
assign savestate_back = mbc3 ? s3 : mbc2 ? s2 : mbc5 ? s5 : use1 ? s1 : 16'd0;
assign savestate_back2 = 0;
assign RTC_timestampOut = mbc3 ? rtc_stamp : 0;
assign RTC_savedtimeOut = mbc3 ? rtc_saved : 0;
assign RTC_inuse = mbc3 && rtc_active;
assign cram_wr_do = 0;
assign cram_wr = 0;
endmodule
