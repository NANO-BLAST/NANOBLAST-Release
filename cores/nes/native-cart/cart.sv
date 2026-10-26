// Mapper top level selection

// Notes by Kitrinx:
// This module uses bidirectional ports to handle the data out of each mapper.
// Although FPGA's do not use bidirectional wiring internally, the alternative is
// creating a tenticle-monster of wires for each mapper, and muxing them all together.
// As it stands, the compiler will efficiently do it for us with much more readable and
// manageable code if we do it this way, and since not more than one mapper can be active
// at a time, there will be no conflicts.

// SDRAM Locations for various RAM types:
// PRG       = 0....
// CHR       = 10...
// CHR-VRAM  = 1100
// CPU-RAM   = 1110
// CARTRAM   = 1111

module cart_top (
	input             clk,
	input             ce,
	input             ppu_ce,
	input             reset,
	input      [19:0] ppuflags,       // Misc flags from PPU for MMC5 cheating
	input      [63:0] flags,          // Misc flags from ines header {prg_size(3), chr_size(3), mapper(8)}
	input      [15:0] prg_ain,        // Better known as "CPU Address in"
	output reg [21:0] prg_aout,       // PRG Input / Output Address Lines
	input             prg_read,       // PRG Read / write signals
	input             prg_write,
	input       [7:0] prg_din,        // CPU Data In
	output reg  [7:0] prg_dout,       // CPU Data Out
	input       [7:0] prg_from_ram,   // PRG Data from RAM
	output reg        prg_allow,      // PRG Allow write access
	output reg        prg_bus_write,  // PRG Data Driven
	output reg        prg_conflict,   // PRG Data is ROM & prg_din
	input             chr_read,       // Read from CHR
	input             chr_write,      // Write to CHR
	input       [7:0] chr_din,        // PPU Data In
	input      [13:0] chr_ain,        // Better known as "PPU Address in"
	output reg [21:0] chr_aout,       // CHR Input / Output Address Lines
	output reg  [7:0] chr_dout,       // Value to override CHR data with
	output reg        has_chr_dout,   // True if CHR data should be overridden
	output reg        chr_allow,      // CHR Allow write
	output reg        vram_a10,       // CHR Value for A10 address line
	output reg        vram_ce,        // CHR True if the address should be routed to the internal 2kB VRAM.
	output reg [17:0] mapper_addr,
	input       [7:0] mapper_data_in,
	output reg  [7:0] mapper_data_out,
	output reg        mapper_prg_write,
	output reg        mapper_ovr,
	output reg        irq,
	input      [15:0] audio_in,
	output reg [15:0] audio,          // External Audio
	output reg  [1:0] diskside_auto,
	input       [1:0] diskside,
	input             fds_busy,       // FDS Disk Swap Busy
	input             fds_eject       // FDS Disk Swap Pause
);
// Explicit reductions preserve pull defaults under one-active-mapper selection.
wire [21:0] nb_mmc0_prg_addr_b;
wire [7:0] nb_mmc0_prg_dout_b;
wire nb_mmc0_prg_allow_b;
wire [21:0] nb_mmc0_chr_addr_b;
wire nb_mmc0_chr_allow_b;
wire nb_mmc0_vram_a10_b;
wire nb_mmc0_vram_ce_b;
wire nb_mmc0_irq_b;
wire [15:0] nb_mmc0_audio_out_b;
wire [21:0] nb_mmc1_prg_addr_b;
wire [7:0] nb_mmc1_prg_dout_b;
wire nb_mmc1_prg_allow_b;
wire [21:0] nb_mmc1_chr_addr_b;
wire nb_mmc1_chr_allow_b;
wire nb_mmc1_vram_a10_b;
wire nb_mmc1_vram_ce_b;
wire nb_mmc1_irq_b;
wire [15:0] nb_mmc1_flags_out_b;
wire [15:0] nb_mmc1_audio_out_b;
wire [21:0] nb_map28_prg_addr_b;
wire [7:0] nb_map28_prg_dout_b;
wire nb_map28_prg_allow_b;
wire [21:0] nb_map28_chr_addr_b;
wire [7:0] nb_map28_chr_dout_b;
wire nb_map28_chr_allow_b;
wire nb_map28_vram_a10_b;
wire nb_map28_vram_ce_b;
wire nb_map28_irq_b;
wire [15:0] nb_map28_flags_out_b;
wire [15:0] nb_map28_audio_out_b;
wire [21:0] nb_map30_prg_addr_b;
wire [7:0] nb_map30_prg_dout_b;
wire nb_map30_prg_allow_b;
wire [21:0] nb_map30_chr_addr_b;
wire nb_map30_chr_allow_b;
wire nb_map30_vram_a10_b;
wire nb_map30_vram_ce_b;
wire nb_map30_irq_b;
wire [15:0] nb_map30_flags_out_b;
wire [15:0] nb_map30_audio_out_b;
wire [21:0] nb_map32_prg_addr_b;
wire [7:0] nb_map32_prg_dout_b;
wire nb_map32_prg_allow_b;
wire [21:0] nb_map32_chr_addr_b;
wire nb_map32_chr_allow_b;
wire nb_map32_vram_a10_b;
wire nb_map32_vram_ce_b;
wire nb_map32_irq_b;
wire [15:0] nb_map32_flags_out_b;
wire [15:0] nb_map32_audio_out_b;
wire [21:0] nb_mmc2_prg_addr_b;
wire [7:0] nb_mmc2_prg_dout_b;
wire nb_mmc2_prg_allow_b;
wire [21:0] nb_mmc2_chr_addr_b;
wire nb_mmc2_chr_allow_b;
wire nb_mmc2_vram_a10_b;
wire nb_mmc2_vram_ce_b;
wire nb_mmc2_irq_b;
wire [15:0] nb_mmc2_flags_out_b;
wire [15:0] nb_mmc2_audio_out_b;
wire [21:0] nb_mmc3_prg_addr_b;
wire [7:0] nb_mmc3_prg_dout_b;
wire nb_mmc3_prg_allow_b;
wire [21:0] nb_mmc3_chr_addr_b;
wire nb_mmc3_chr_allow_b;
wire nb_mmc3_vram_a10_b;
wire nb_mmc3_vram_ce_b;
wire nb_mmc3_irq_b;
wire [15:0] nb_mmc3_flags_out_b;
wire [15:0] nb_mmc3_audio_out_b;
wire [21:0] nb_mmc4_prg_addr_b;
wire [7:0] nb_mmc4_prg_dout_b;
wire nb_mmc4_prg_allow_b;
wire [21:0] nb_mmc4_chr_addr_b;
wire nb_mmc4_chr_allow_b;
wire nb_mmc4_vram_a10_b;
wire nb_mmc4_vram_ce_b;
wire nb_mmc4_irq_b;
wire [15:0] nb_mmc4_flags_out_b;
wire [15:0] nb_mmc4_audio_out_b;
wire [21:0] nb_mmc5_prg_addr_b;
wire [7:0] nb_mmc5_prg_dout_b;
wire nb_mmc5_prg_allow_b;
wire [21:0] nb_mmc5_chr_addr_b;
wire nb_mmc5_chr_allow_b;
wire nb_mmc5_vram_a10_b;
wire nb_mmc5_vram_ce_b;
wire nb_mmc5_irq_b;
wire [15:0] nb_mmc5_flags_out_b;
wire [15:0] nb_mmc5_audio_out_b;
wire [7:0] nb_mmc5_chr_dout_b;
wire [21:0] nb_map13_prg_addr_b;
wire [7:0] nb_map13_prg_dout_b;
wire nb_map13_prg_allow_b;
wire [21:0] nb_map13_chr_addr_b;
wire nb_map13_chr_allow_b;
wire nb_map13_vram_a10_b;
wire nb_map13_vram_ce_b;
wire nb_map13_irq_b;
wire [15:0] nb_map13_flags_out_b;
wire [15:0] nb_map13_audio_out_b;
wire [21:0] nb_map15_prg_addr_b;
wire [7:0] nb_map15_prg_dout_b;
wire nb_map15_prg_allow_b;
wire [21:0] nb_map15_chr_addr_b;
wire nb_map15_chr_allow_b;
wire nb_map15_vram_a10_b;
wire nb_map15_vram_ce_b;
wire nb_map15_irq_b;
wire [15:0] nb_map15_flags_out_b;
wire [15:0] nb_map15_audio_out_b;
wire [21:0] nb_map16_prg_addr_b;
wire [7:0] nb_map16_prg_dout_b;
wire nb_map16_prg_allow_b;
wire [21:0] nb_map16_chr_addr_b;
wire nb_map16_chr_allow_b;
wire nb_map16_vram_a10_b;
wire nb_map16_vram_ce_b;
wire nb_map16_irq_b;
wire [15:0] nb_map16_flags_out_b;
wire [15:0] nb_map16_audio_out_b;
wire [21:0] nb_map18_prg_addr_b;
wire [7:0] nb_map18_prg_dout_b;
wire nb_map18_prg_allow_b;
wire [21:0] nb_map18_chr_addr_b;
wire nb_map18_chr_allow_b;
wire nb_map18_vram_a10_b;
wire nb_map18_vram_ce_b;
wire nb_map18_irq_b;
wire [15:0] nb_map18_flags_out_b;
wire [15:0] nb_map18_audio_out_b;
wire [21:0] nb_map34_prg_addr_b;
wire [7:0] nb_map34_prg_dout_b;
wire nb_map34_prg_allow_b;
wire [21:0] nb_map34_chr_addr_b;
wire nb_map34_chr_allow_b;
wire nb_map34_vram_a10_b;
wire nb_map34_vram_ce_b;
wire nb_map34_irq_b;
wire [15:0] nb_map34_flags_out_b;
wire [15:0] nb_map34_audio_out_b;
wire [21:0] nb_map41_prg_addr_b;
wire [7:0] nb_map41_prg_dout_b;
wire nb_map41_prg_allow_b;
wire [21:0] nb_map41_chr_addr_b;
wire nb_map41_chr_allow_b;
wire nb_map41_vram_a10_b;
wire nb_map41_vram_ce_b;
wire nb_map41_irq_b;
wire [15:0] nb_map41_flags_out_b;
wire [15:0] nb_map41_audio_out_b;
wire [21:0] nb_map42_prg_addr_b;
wire [7:0] nb_map42_prg_dout_b;
wire nb_map42_prg_allow_b;
wire [21:0] nb_map42_chr_addr_b;
wire nb_map42_chr_allow_b;
wire nb_map42_vram_a10_b;
wire nb_map42_vram_ce_b;
wire nb_map42_irq_b;
wire [15:0] nb_map42_flags_out_b;
wire [15:0] nb_map42_audio_out_b;
wire [21:0] nb_map65_prg_addr_b;
wire [7:0] nb_map65_prg_dout_b;
wire nb_map65_prg_allow_b;
wire [21:0] nb_map65_chr_addr_b;
wire nb_map65_chr_allow_b;
wire nb_map65_vram_a10_b;
wire nb_map65_vram_ce_b;
wire nb_map65_irq_b;
wire [15:0] nb_map65_flags_out_b;
wire [15:0] nb_map65_audio_out_b;
wire [21:0] nb_map66_prg_addr_b;
wire [7:0] nb_map66_prg_dout_b;
wire nb_map66_prg_allow_b;
wire [21:0] nb_map66_chr_addr_b;
wire nb_map66_chr_allow_b;
wire nb_map66_vram_a10_b;
wire nb_map66_vram_ce_b;
wire nb_map66_irq_b;
wire [15:0] nb_map66_flags_out_b;
wire [15:0] nb_map66_audio_out_b;
wire [21:0] nb_map67_prg_addr_b;
wire [7:0] nb_map67_prg_dout_b;
wire nb_map67_prg_allow_b;
wire [21:0] nb_map67_chr_addr_b;
wire nb_map67_chr_allow_b;
wire nb_map67_vram_a10_b;
wire nb_map67_vram_ce_b;
wire nb_map67_irq_b;
wire [15:0] nb_map67_flags_out_b;
wire [15:0] nb_map67_audio_out_b;
wire [21:0] nb_map68_prg_addr_b;
wire [7:0] nb_map68_prg_dout_b;
wire nb_map68_prg_allow_b;
wire [21:0] nb_map68_chr_addr_b;
wire nb_map68_chr_allow_b;
wire nb_map68_vram_a10_b;
wire nb_map68_vram_ce_b;
wire nb_map68_irq_b;
wire [15:0] nb_map68_flags_out_b;
wire [15:0] nb_map68_audio_out_b;
wire [21:0] nb_map69_prg_addr_b;
wire [7:0] nb_map69_prg_dout_b;
wire nb_map69_prg_allow_b;
wire [21:0] nb_map69_chr_addr_b;
wire nb_map69_chr_allow_b;
wire nb_map69_vram_a10_b;
wire nb_map69_vram_ce_b;
wire nb_map69_irq_b;
wire [15:0] nb_map69_flags_out_b;
wire [15:0] nb_map69_audio_out_b;
wire [21:0] nb_map71_prg_addr_b;
wire [7:0] nb_map71_prg_dout_b;
wire nb_map71_prg_allow_b;
wire [21:0] nb_map71_chr_addr_b;
wire nb_map71_chr_allow_b;
wire nb_map71_vram_a10_b;
wire nb_map71_vram_ce_b;
wire nb_map71_irq_b;
wire [15:0] nb_map71_flags_out_b;
wire [15:0] nb_map71_audio_out_b;
wire [21:0] nb_map72_prg_addr_b;
wire [7:0] nb_map72_prg_dout_b;
wire nb_map72_prg_allow_b;
wire [21:0] nb_map72_chr_addr_b;
wire nb_map72_chr_allow_b;
wire nb_map72_vram_a10_b;
wire nb_map72_vram_ce_b;
wire nb_map72_irq_b;
wire [15:0] nb_map72_flags_out_b;
wire [15:0] nb_map72_audio_out_b;
wire [21:0] nb_map77_prg_addr_b;
wire [7:0] nb_map77_prg_dout_b;
wire nb_map77_prg_allow_b;
wire [21:0] nb_map77_chr_addr_b;
wire nb_map77_chr_allow_b;
wire nb_map77_vram_a10_b;
wire nb_map77_vram_ce_b;
wire nb_map77_irq_b;
wire [15:0] nb_map77_flags_out_b;
wire [15:0] nb_map77_audio_out_b;
wire [21:0] nb_map78_prg_addr_b;
wire [7:0] nb_map78_prg_dout_b;
wire nb_map78_prg_allow_b;
wire [21:0] nb_map78_chr_addr_b;
wire nb_map78_chr_allow_b;
wire nb_map78_vram_a10_b;
wire nb_map78_vram_ce_b;
wire nb_map78_irq_b;
wire [15:0] nb_map78_flags_out_b;
wire [15:0] nb_map78_audio_out_b;
wire [21:0] nb_map79_prg_addr_b;
wire [7:0] nb_map79_prg_dout_b;
wire nb_map79_prg_allow_b;
wire [21:0] nb_map79_chr_addr_b;
wire nb_map79_chr_allow_b;
wire nb_map79_vram_a10_b;
wire nb_map79_vram_ce_b;
wire nb_map79_irq_b;
wire [15:0] nb_map79_flags_out_b;
wire [15:0] nb_map79_audio_out_b;
wire [21:0] nb_map83_prg_addr_b;
wire [7:0] nb_map83_prg_dout_b;
wire nb_map83_prg_allow_b;
wire [21:0] nb_map83_chr_addr_b;
wire nb_map83_chr_allow_b;
wire nb_map83_vram_a10_b;
wire nb_map83_vram_ce_b;
wire nb_map83_irq_b;
wire [15:0] nb_map83_flags_out_b;
wire [15:0] nb_map83_audio_out_b;
wire [21:0] nb_map89_prg_addr_b;
wire [7:0] nb_map89_prg_dout_b;
wire nb_map89_prg_allow_b;
wire [21:0] nb_map89_chr_addr_b;
wire nb_map89_chr_allow_b;
wire nb_map89_vram_a10_b;
wire nb_map89_vram_ce_b;
wire nb_map89_irq_b;
wire [15:0] nb_map89_flags_out_b;
wire [15:0] nb_map89_audio_out_b;
wire [21:0] nb_map107_prg_addr_b;
wire [7:0] nb_map107_prg_dout_b;
wire nb_map107_prg_allow_b;
wire [21:0] nb_map107_chr_addr_b;
wire nb_map107_chr_allow_b;
wire nb_map107_vram_a10_b;
wire nb_map107_vram_ce_b;
wire nb_map107_irq_b;
wire [15:0] nb_map107_flags_out_b;
wire [15:0] nb_map107_audio_out_b;
wire [21:0] nb_map111_prg_addr_b;
wire [7:0] nb_map111_prg_dout_b;
wire nb_map111_prg_allow_b;
wire [21:0] nb_map111_chr_addr_b;
wire nb_map111_chr_allow_b;
wire nb_map111_vram_a10_b;
wire nb_map111_vram_ce_b;
wire nb_map111_irq_b;
wire [15:0] nb_map111_flags_out_b;
wire [15:0] nb_map111_audio_out_b;
wire [21:0] nb_map165_prg_addr_b;
wire [7:0] nb_map165_prg_dout_b;
wire nb_map165_prg_allow_b;
wire [21:0] nb_map165_chr_addr_b;
wire nb_map165_chr_allow_b;
wire nb_map165_vram_a10_b;
wire nb_map165_vram_ce_b;
wire nb_map165_irq_b;
wire [15:0] nb_map165_flags_out_b;
wire [15:0] nb_map165_audio_out_b;
wire [21:0] nb_map218_prg_addr_b;
wire [7:0] nb_map218_prg_dout_b;
wire nb_map218_prg_allow_b;
wire [21:0] nb_map218_chr_addr_b;
wire nb_map218_chr_allow_b;
wire nb_map218_vram_a10_b;
wire nb_map218_vram_ce_b;
wire nb_map218_irq_b;
wire [15:0] nb_map218_flags_out_b;
wire [15:0] nb_map218_audio_out_b;
wire [21:0] nb_map228_prg_addr_b;
wire [7:0] nb_map228_prg_dout_b;
wire nb_map228_prg_allow_b;
wire [21:0] nb_map228_chr_addr_b;
wire nb_map228_chr_allow_b;
wire nb_map228_vram_a10_b;
wire nb_map228_vram_ce_b;
wire nb_map228_irq_b;
wire [15:0] nb_map228_flags_out_b;
wire [15:0] nb_map228_audio_out_b;
wire [21:0] nb_map234_prg_addr_b;
wire [7:0] nb_map234_prg_dout_b;
wire nb_map234_prg_allow_b;
wire [21:0] nb_map234_chr_addr_b;
wire nb_map234_chr_allow_b;
wire nb_map234_vram_a10_b;
wire nb_map234_vram_ce_b;
wire nb_map234_irq_b;
wire [15:0] nb_map234_flags_out_b;
wire [15:0] nb_map234_audio_out_b;
wire [21:0] nb_rambo1_prg_addr_b;
wire [7:0] nb_rambo1_prg_dout_b;
wire nb_rambo1_prg_allow_b;
wire [21:0] nb_rambo1_chr_addr_b;
wire nb_rambo1_chr_allow_b;
wire nb_rambo1_vram_a10_b;
wire nb_rambo1_vram_ce_b;
wire nb_rambo1_irq_b;
wire [15:0] nb_rambo1_flags_out_b;
wire [15:0] nb_rambo1_audio_out_b;
wire [21:0] nb_nesev_prg_addr_b;
wire [7:0] nb_nesev_prg_dout_b;
wire nb_nesev_prg_allow_b;
wire [21:0] nb_nesev_chr_addr_b;
wire nb_nesev_chr_allow_b;
wire nb_nesev_vram_a10_b;
wire nb_nesev_vram_ce_b;
wire nb_nesev_irq_b;
wire [15:0] nb_nesev_flags_out_b;
wire [15:0] nb_nesev_audio_out_b;
wire [21:0] nb_n163_prg_addr_b;
wire [7:0] nb_n163_prg_dout_b;
wire nb_n163_prg_allow_b;
wire [21:0] nb_n163_chr_addr_b;
wire nb_n163_chr_allow_b;
wire nb_n163_vram_a10_b;
wire nb_n163_vram_ce_b;
wire nb_n163_irq_b;
wire [15:0] nb_n163_flags_out_b;
wire [15:0] nb_n163_audio_out_b;
wire [21:0] nb_map162_prg_addr_b;
wire [7:0] nb_map162_prg_dout_b;
wire nb_map162_prg_allow_b;
wire [21:0] nb_map162_chr_addr_b;
wire nb_map162_chr_allow_b;
wire nb_map162_vram_a10_b;
wire nb_map162_vram_ce_b;
wire nb_map162_irq_b;
wire [15:0] nb_map162_flags_out_b;
wire [15:0] nb_map162_audio_out_b;
wire [21:0] nb_map163_prg_addr_b;
wire [7:0] nb_map163_prg_dout_b;
wire nb_map163_prg_allow_b;
wire [21:0] nb_map163_chr_addr_b;
wire nb_map163_chr_allow_b;
wire nb_map163_vram_a10_b;
wire nb_map163_vram_ce_b;
wire nb_map163_irq_b;
wire [15:0] nb_map163_flags_out_b;
wire [15:0] nb_map163_audio_out_b;
wire [21:0] nb_map164_prg_addr_b;
wire [7:0] nb_map164_prg_dout_b;
wire nb_map164_prg_allow_b;
wire [21:0] nb_map164_chr_addr_b;
wire nb_map164_chr_allow_b;
wire nb_map164_vram_a10_b;
wire nb_map164_vram_ce_b;
wire nb_map164_irq_b;
wire [15:0] nb_map164_flags_out_b;
wire [15:0] nb_map164_audio_out_b;
wire [21:0] nb_sachen_prg_addr_b;
wire [7:0] nb_sachen_prg_dout_b;
wire nb_sachen_prg_allow_b;
wire [21:0] nb_sachen_chr_addr_b;
wire nb_sachen_chr_allow_b;
wire nb_sachen_vram_a10_b;
wire nb_sachen_vram_ce_b;
wire nb_sachen_irq_b;
wire [15:0] nb_sachen_flags_out_b;
wire [15:0] nb_sachen_audio_out_b;
wire [21:0] nb_sachenj_prg_addr_b;
wire [7:0] nb_sachenj_prg_dout_b;
wire nb_sachenj_prg_allow_b;
wire [21:0] nb_sachenj_chr_addr_b;
wire nb_sachenj_chr_allow_b;
wire nb_sachenj_vram_a10_b;
wire nb_sachenj_vram_ce_b;
wire nb_sachenj_irq_b;
wire [15:0] nb_sachenj_flags_out_b;
wire [15:0] nb_sachenj_audio_out_b;
wire [21:0] nb_sachenn_prg_addr_b;
wire [7:0] nb_sachenn_prg_dout_b;
wire nb_sachenn_prg_allow_b;
wire [21:0] nb_sachenn_chr_addr_b;
wire nb_sachenn_chr_allow_b;
wire nb_sachenn_vram_a10_b;
wire nb_sachenn_vram_ce_b;
wire nb_sachenn_irq_b;
wire [15:0] nb_sachenn_flags_out_b;
wire [15:0] nb_sachenn_audio_out_b;
wire [21:0] nb_jycompany_prg_addr_b;
wire [7:0] nb_jycompany_prg_dout_b;
wire nb_jycompany_prg_allow_b;
wire [21:0] nb_jycompany_chr_addr_b;
wire nb_jycompany_chr_allow_b;
wire nb_jycompany_vram_a10_b;
wire nb_jycompany_vram_ce_b;
wire nb_jycompany_irq_b;
wire [15:0] nb_jycompany_flags_out_b;
wire [15:0] nb_jycompany_audio_out_b;
wire [21:0] nb_map91_prg_addr_b;
wire [7:0] nb_map91_prg_dout_b;
wire nb_map91_prg_allow_b;
wire [21:0] nb_map91_chr_addr_b;
wire nb_map91_chr_allow_b;
wire nb_map91_vram_a10_b;
wire nb_map91_vram_ce_b;
wire nb_map91_irq_b;
wire [15:0] nb_map91_flags_out_b;
wire [15:0] nb_map91_audio_out_b;
wire [21:0] nb_map225_prg_addr_b;
wire [7:0] nb_map225_prg_dout_b;
wire nb_map225_prg_allow_b;
wire [21:0] nb_map225_chr_addr_b;
wire nb_map225_chr_allow_b;
wire nb_map225_vram_a10_b;
wire nb_map225_vram_ce_b;
wire nb_map225_irq_b;
wire [15:0] nb_map225_flags_out_b;
wire [15:0] nb_map225_audio_out_b;
wire [21:0] nb_nsfplayer_prg_addr_b;
wire [7:0] nb_nsfplayer_prg_dout_b;
wire nb_nsfplayer_prg_allow_b;
wire [21:0] nb_nsfplayer_chr_addr_b;
wire nb_nsfplayer_chr_allow_b;
wire nb_nsfplayer_vram_a10_b;
wire nb_nsfplayer_vram_ce_b;
wire nb_nsfplayer_irq_b;
wire [15:0] nb_nsfplayer_flags_out_b;
wire [15:0] nb_nsfplayer_audio_out_b;
assign prg_allow_b = (1'b0 ? nb_mmc0_prg_allow_b : '0) | (me[171] | me[155] | me[1] ? nb_mmc1_prg_allow_b : '0) | (mapper28_en & ~reset ? nb_map28_prg_allow_b : '0) | (me[30] ? nb_map30_prg_allow_b : '0) | (me[32] ? nb_map32_prg_allow_b : '0) | (me[9] ? nb_mmc2_prg_allow_b : '0) | (mmc3_en ? nb_mmc3_prg_allow_b : '0) | (me[10] ? nb_mmc4_prg_allow_b : '0) | (me[5] ? nb_mmc5_prg_allow_b : '0) | (me[13] ? nb_map13_prg_allow_b : '0) | (me[15] ? nb_map15_prg_allow_b : '0) | (me[159] | me[153] | me[16] ? nb_map16_prg_allow_b : '0) | (me[18] ? nb_map18_prg_allow_b : '0) | (me[34] ? nb_map34_prg_allow_b : '0) | (me[41] ? nb_map41_prg_allow_b : '0) | (me[42] ? nb_map42_prg_allow_b : '0) | (me[65] ? nb_map65_prg_allow_b : '0) | (mapper66_en ? nb_map66_prg_allow_b : '0) | (me[67] | me[190] ? nb_map67_prg_allow_b : '0) | (me[68] ? nb_map68_prg_allow_b : '0) | (me[69] ? nb_map69_prg_allow_b : '0) | (me[71] | me[232] ? nb_map71_prg_allow_b : '0) | (me[92] | me[72] ? nb_map72_prg_allow_b : '0) | (me[77] ? nb_map77_prg_allow_b : '0) | (me[152] | me[70] | me[78] ? nb_map78_prg_allow_b : '0) | (me[79] | me[113] | me[133] | me[146] | me[148] ? nb_map79_prg_allow_b : '0) | (me[83] ? nb_map83_prg_allow_b : '0) | (me[89] | me[93] | me[184] ? nb_map89_prg_allow_b : '0) | (me[107] ? nb_map107_prg_allow_b : '0) | (me[111] ? nb_map111_prg_allow_b : '0) | (me[165] ? nb_map165_prg_allow_b : '0) | (me[218] ? nb_map218_prg_allow_b : '0) | (me[228] ? nb_map228_prg_allow_b : '0) | (me[234] ? nb_map234_prg_allow_b : '0) | (me[64] | me[158] ? nb_rambo1_prg_allow_b : '0) | (me[105] ? nb_nesev_prg_allow_b : '0) | (me[210] | me[19] ? nb_n163_prg_allow_b : '0) | (me[162] ? nb_map162_prg_allow_b : '0) | (me[163] ? nb_map163_prg_allow_b : '0) | (me[164] ? nb_map164_prg_allow_b : '0) | (me[137] | me[138] | me[139] | me[141] | me[150] | me[243] ? nb_sachen_prg_allow_b : '0) | (me[136] | me[147] | me[132] | me[173] | me[172] | me[36] ? nb_sachenj_prg_allow_b : '0) | (me[143] ? nb_sachenn_prg_allow_b : '0) | (me[90] | me[209] | me[211] | me[35] ? nb_jycompany_prg_allow_b : '0) | (me[91] ? nb_map91_prg_allow_b : '0) | (me[225] | me[255] ? nb_map225_prg_allow_b : '0) | (me[31] ? nb_nsfplayer_prg_allow_b : '0);
assign vram_a10_b = (1'b0 ? nb_mmc0_vram_a10_b : '0) | (me[171] | me[155] | me[1] ? nb_mmc1_vram_a10_b : '0) | (mapper28_en & ~reset ? nb_map28_vram_a10_b : '0) | (me[30] ? nb_map30_vram_a10_b : '0) | (me[32] ? nb_map32_vram_a10_b : '0) | (me[9] ? nb_mmc2_vram_a10_b : '0) | (mmc3_en ? nb_mmc3_vram_a10_b : '0) | (me[10] ? nb_mmc4_vram_a10_b : '0) | (me[5] ? nb_mmc5_vram_a10_b : '0) | (me[13] ? nb_map13_vram_a10_b : '0) | (me[15] ? nb_map15_vram_a10_b : '0) | (me[159] | me[153] | me[16] ? nb_map16_vram_a10_b : '0) | (me[18] ? nb_map18_vram_a10_b : '0) | (me[34] ? nb_map34_vram_a10_b : '0) | (me[41] ? nb_map41_vram_a10_b : '0) | (me[42] ? nb_map42_vram_a10_b : '0) | (me[65] ? nb_map65_vram_a10_b : '0) | (mapper66_en ? nb_map66_vram_a10_b : '0) | (me[67] | me[190] ? nb_map67_vram_a10_b : '0) | (me[68] ? nb_map68_vram_a10_b : '0) | (me[69] ? nb_map69_vram_a10_b : '0) | (me[71] | me[232] ? nb_map71_vram_a10_b : '0) | (me[92] | me[72] ? nb_map72_vram_a10_b : '0) | (me[77] ? nb_map77_vram_a10_b : '0) | (me[152] | me[70] | me[78] ? nb_map78_vram_a10_b : '0) | (me[79] | me[113] | me[133] | me[146] | me[148] ? nb_map79_vram_a10_b : '0) | (me[83] ? nb_map83_vram_a10_b : '0) | (me[89] | me[93] | me[184] ? nb_map89_vram_a10_b : '0) | (me[107] ? nb_map107_vram_a10_b : '0) | (me[111] ? nb_map111_vram_a10_b : '0) | (me[165] ? nb_map165_vram_a10_b : '0) | (me[218] ? nb_map218_vram_a10_b : '0) | (me[228] ? nb_map228_vram_a10_b : '0) | (me[234] ? nb_map234_vram_a10_b : '0) | (me[64] | me[158] ? nb_rambo1_vram_a10_b : '0) | (me[105] ? nb_nesev_vram_a10_b : '0) | (me[210] | me[19] ? nb_n163_vram_a10_b : '0) | (me[162] ? nb_map162_vram_a10_b : '0) | (me[163] ? nb_map163_vram_a10_b : '0) | (me[164] ? nb_map164_vram_a10_b : '0) | (me[137] | me[138] | me[139] | me[141] | me[150] | me[243] ? nb_sachen_vram_a10_b : '0) | (me[136] | me[147] | me[132] | me[173] | me[172] | me[36] ? nb_sachenj_vram_a10_b : '0) | (me[143] ? nb_sachenn_vram_a10_b : '0) | (me[90] | me[209] | me[211] | me[35] ? nb_jycompany_vram_a10_b : '0) | (me[91] ? nb_map91_vram_a10_b : '0) | (me[225] | me[255] ? nb_map225_vram_a10_b : '0) | (me[31] ? nb_nsfplayer_vram_a10_b : '0);
assign vram_ce_b = (1'b0 ? nb_mmc0_vram_ce_b : '0) | (me[171] | me[155] | me[1] ? nb_mmc1_vram_ce_b : '0) | (mapper28_en & ~reset ? nb_map28_vram_ce_b : '0) | (me[30] ? nb_map30_vram_ce_b : '0) | (me[32] ? nb_map32_vram_ce_b : '0) | (me[9] ? nb_mmc2_vram_ce_b : '0) | (mmc3_en ? nb_mmc3_vram_ce_b : '0) | (me[10] ? nb_mmc4_vram_ce_b : '0) | (me[5] ? nb_mmc5_vram_ce_b : '0) | (me[13] ? nb_map13_vram_ce_b : '0) | (me[15] ? nb_map15_vram_ce_b : '0) | (me[159] | me[153] | me[16] ? nb_map16_vram_ce_b : '0) | (me[18] ? nb_map18_vram_ce_b : '0) | (me[34] ? nb_map34_vram_ce_b : '0) | (me[41] ? nb_map41_vram_ce_b : '0) | (me[42] ? nb_map42_vram_ce_b : '0) | (me[65] ? nb_map65_vram_ce_b : '0) | (mapper66_en ? nb_map66_vram_ce_b : '0) | (me[67] | me[190] ? nb_map67_vram_ce_b : '0) | (me[68] ? nb_map68_vram_ce_b : '0) | (me[69] ? nb_map69_vram_ce_b : '0) | (me[71] | me[232] ? nb_map71_vram_ce_b : '0) | (me[92] | me[72] ? nb_map72_vram_ce_b : '0) | (me[77] ? nb_map77_vram_ce_b : '0) | (me[152] | me[70] | me[78] ? nb_map78_vram_ce_b : '0) | (me[79] | me[113] | me[133] | me[146] | me[148] ? nb_map79_vram_ce_b : '0) | (me[83] ? nb_map83_vram_ce_b : '0) | (me[89] | me[93] | me[184] ? nb_map89_vram_ce_b : '0) | (me[107] ? nb_map107_vram_ce_b : '0) | (me[111] ? nb_map111_vram_ce_b : '0) | (me[165] ? nb_map165_vram_ce_b : '0) | (me[218] ? nb_map218_vram_ce_b : '0) | (me[228] ? nb_map228_vram_ce_b : '0) | (me[234] ? nb_map234_vram_ce_b : '0) | (me[64] | me[158] ? nb_rambo1_vram_ce_b : '0) | (me[105] ? nb_nesev_vram_ce_b : '0) | (me[210] | me[19] ? nb_n163_vram_ce_b : '0) | (me[162] ? nb_map162_vram_ce_b : '0) | (me[163] ? nb_map163_vram_ce_b : '0) | (me[164] ? nb_map164_vram_ce_b : '0) | (me[137] | me[138] | me[139] | me[141] | me[150] | me[243] ? nb_sachen_vram_ce_b : '0) | (me[136] | me[147] | me[132] | me[173] | me[172] | me[36] ? nb_sachenj_vram_ce_b : '0) | (me[143] ? nb_sachenn_vram_ce_b : '0) | (me[90] | me[209] | me[211] | me[35] ? nb_jycompany_vram_ce_b : '0) | (me[91] ? nb_map91_vram_ce_b : '0) | (me[225] | me[255] ? nb_map225_vram_ce_b : '0) | (me[31] ? nb_nsfplayer_vram_ce_b : '0);
assign chr_allow_b = (1'b0 ? nb_mmc0_chr_allow_b : '0) | (me[171] | me[155] | me[1] ? nb_mmc1_chr_allow_b : '0) | (mapper28_en & ~reset ? nb_map28_chr_allow_b : '0) | (me[30] ? nb_map30_chr_allow_b : '0) | (me[32] ? nb_map32_chr_allow_b : '0) | (me[9] ? nb_mmc2_chr_allow_b : '0) | (mmc3_en ? nb_mmc3_chr_allow_b : '0) | (me[10] ? nb_mmc4_chr_allow_b : '0) | (me[5] ? nb_mmc5_chr_allow_b : '0) | (me[13] ? nb_map13_chr_allow_b : '0) | (me[15] ? nb_map15_chr_allow_b : '0) | (me[159] | me[153] | me[16] ? nb_map16_chr_allow_b : '0) | (me[18] ? nb_map18_chr_allow_b : '0) | (me[34] ? nb_map34_chr_allow_b : '0) | (me[41] ? nb_map41_chr_allow_b : '0) | (me[42] ? nb_map42_chr_allow_b : '0) | (me[65] ? nb_map65_chr_allow_b : '0) | (mapper66_en ? nb_map66_chr_allow_b : '0) | (me[67] | me[190] ? nb_map67_chr_allow_b : '0) | (me[68] ? nb_map68_chr_allow_b : '0) | (me[69] ? nb_map69_chr_allow_b : '0) | (me[71] | me[232] ? nb_map71_chr_allow_b : '0) | (me[92] | me[72] ? nb_map72_chr_allow_b : '0) | (me[77] ? nb_map77_chr_allow_b : '0) | (me[152] | me[70] | me[78] ? nb_map78_chr_allow_b : '0) | (me[79] | me[113] | me[133] | me[146] | me[148] ? nb_map79_chr_allow_b : '0) | (me[83] ? nb_map83_chr_allow_b : '0) | (me[89] | me[93] | me[184] ? nb_map89_chr_allow_b : '0) | (me[107] ? nb_map107_chr_allow_b : '0) | (me[111] ? nb_map111_chr_allow_b : '0) | (me[165] ? nb_map165_chr_allow_b : '0) | (me[218] ? nb_map218_chr_allow_b : '0) | (me[228] ? nb_map228_chr_allow_b : '0) | (me[234] ? nb_map234_chr_allow_b : '0) | (me[64] | me[158] ? nb_rambo1_chr_allow_b : '0) | (me[105] ? nb_nesev_chr_allow_b : '0) | (me[210] | me[19] ? nb_n163_chr_allow_b : '0) | (me[162] ? nb_map162_chr_allow_b : '0) | (me[163] ? nb_map163_chr_allow_b : '0) | (me[164] ? nb_map164_chr_allow_b : '0) | (me[137] | me[138] | me[139] | me[141] | me[150] | me[243] ? nb_sachen_chr_allow_b : '0) | (me[136] | me[147] | me[132] | me[173] | me[172] | me[36] ? nb_sachenj_chr_allow_b : '0) | (me[143] ? nb_sachenn_chr_allow_b : '0) | (me[90] | me[209] | me[211] | me[35] ? nb_jycompany_chr_allow_b : '0) | (me[91] ? nb_map91_chr_allow_b : '0) | (me[225] | me[255] ? nb_map225_chr_allow_b : '0) | (me[31] ? nb_nsfplayer_chr_allow_b : '0);
assign irq_b = (1'b0 ? nb_mmc0_irq_b : '0) | (me[171] | me[155] | me[1] ? nb_mmc1_irq_b : '0) | (mapper28_en & ~reset ? nb_map28_irq_b : '0) | (me[30] ? nb_map30_irq_b : '0) | (me[32] ? nb_map32_irq_b : '0) | (me[9] ? nb_mmc2_irq_b : '0) | (mmc3_en ? nb_mmc3_irq_b : '0) | (me[10] ? nb_mmc4_irq_b : '0) | (me[5] ? nb_mmc5_irq_b : '0) | (me[13] ? nb_map13_irq_b : '0) | (me[15] ? nb_map15_irq_b : '0) | (me[159] | me[153] | me[16] ? nb_map16_irq_b : '0) | (me[18] ? nb_map18_irq_b : '0) | (me[34] ? nb_map34_irq_b : '0) | (me[41] ? nb_map41_irq_b : '0) | (me[42] ? nb_map42_irq_b : '0) | (me[65] ? nb_map65_irq_b : '0) | (mapper66_en ? nb_map66_irq_b : '0) | (me[67] | me[190] ? nb_map67_irq_b : '0) | (me[68] ? nb_map68_irq_b : '0) | (me[69] ? nb_map69_irq_b : '0) | (me[71] | me[232] ? nb_map71_irq_b : '0) | (me[92] | me[72] ? nb_map72_irq_b : '0) | (me[77] ? nb_map77_irq_b : '0) | (me[152] | me[70] | me[78] ? nb_map78_irq_b : '0) | (me[79] | me[113] | me[133] | me[146] | me[148] ? nb_map79_irq_b : '0) | (me[83] ? nb_map83_irq_b : '0) | (me[89] | me[93] | me[184] ? nb_map89_irq_b : '0) | (me[107] ? nb_map107_irq_b : '0) | (me[111] ? nb_map111_irq_b : '0) | (me[165] ? nb_map165_irq_b : '0) | (me[218] ? nb_map218_irq_b : '0) | (me[228] ? nb_map228_irq_b : '0) | (me[234] ? nb_map234_irq_b : '0) | (me[64] | me[158] ? nb_rambo1_irq_b : '0) | (me[105] ? nb_nesev_irq_b : '0) | (me[210] | me[19] ? nb_n163_irq_b : '0) | (me[162] ? nb_map162_irq_b : '0) | (me[163] ? nb_map163_irq_b : '0) | (me[164] ? nb_map164_irq_b : '0) | (me[137] | me[138] | me[139] | me[141] | me[150] | me[243] ? nb_sachen_irq_b : '0) | (me[136] | me[147] | me[132] | me[173] | me[172] | me[36] ? nb_sachenj_irq_b : '0) | (me[143] ? nb_sachenn_irq_b : '0) | (me[90] | me[209] | me[211] | me[35] ? nb_jycompany_irq_b : '0) | (me[91] ? nb_map91_irq_b : '0) | (me[225] | me[255] ? nb_map225_irq_b : '0) | (me[31] ? nb_nsfplayer_irq_b : '0);
assign prg_addr_b = (1'b0 ? nb_mmc0_prg_addr_b : '0) | (me[171] | me[155] | me[1] ? nb_mmc1_prg_addr_b : '0) | (mapper28_en & ~reset ? nb_map28_prg_addr_b : '0) | (me[30] ? nb_map30_prg_addr_b : '0) | (me[32] ? nb_map32_prg_addr_b : '0) | (me[9] ? nb_mmc2_prg_addr_b : '0) | (mmc3_en ? nb_mmc3_prg_addr_b : '0) | (me[10] ? nb_mmc4_prg_addr_b : '0) | (me[5] ? nb_mmc5_prg_addr_b : '0) | (me[13] ? nb_map13_prg_addr_b : '0) | (me[15] ? nb_map15_prg_addr_b : '0) | (me[159] | me[153] | me[16] ? nb_map16_prg_addr_b : '0) | (me[18] ? nb_map18_prg_addr_b : '0) | (me[34] ? nb_map34_prg_addr_b : '0) | (me[41] ? nb_map41_prg_addr_b : '0) | (me[42] ? nb_map42_prg_addr_b : '0) | (me[65] ? nb_map65_prg_addr_b : '0) | (mapper66_en ? nb_map66_prg_addr_b : '0) | (me[67] | me[190] ? nb_map67_prg_addr_b : '0) | (me[68] ? nb_map68_prg_addr_b : '0) | (me[69] ? nb_map69_prg_addr_b : '0) | (me[71] | me[232] ? nb_map71_prg_addr_b : '0) | (me[92] | me[72] ? nb_map72_prg_addr_b : '0) | (me[77] ? nb_map77_prg_addr_b : '0) | (me[152] | me[70] | me[78] ? nb_map78_prg_addr_b : '0) | (me[79] | me[113] | me[133] | me[146] | me[148] ? nb_map79_prg_addr_b : '0) | (me[83] ? nb_map83_prg_addr_b : '0) | (me[89] | me[93] | me[184] ? nb_map89_prg_addr_b : '0) | (me[107] ? nb_map107_prg_addr_b : '0) | (me[111] ? nb_map111_prg_addr_b : '0) | (me[165] ? nb_map165_prg_addr_b : '0) | (me[218] ? nb_map218_prg_addr_b : '0) | (me[228] ? nb_map228_prg_addr_b : '0) | (me[234] ? nb_map234_prg_addr_b : '0) | (me[64] | me[158] ? nb_rambo1_prg_addr_b : '0) | (me[105] ? nb_nesev_prg_addr_b : '0) | (me[210] | me[19] ? nb_n163_prg_addr_b : '0) | (me[162] ? nb_map162_prg_addr_b : '0) | (me[163] ? nb_map163_prg_addr_b : '0) | (me[164] ? nb_map164_prg_addr_b : '0) | (me[137] | me[138] | me[139] | me[141] | me[150] | me[243] ? nb_sachen_prg_addr_b : '0) | (me[136] | me[147] | me[132] | me[173] | me[172] | me[36] ? nb_sachenj_prg_addr_b : '0) | (me[143] ? nb_sachenn_prg_addr_b : '0) | (me[90] | me[209] | me[211] | me[35] ? nb_jycompany_prg_addr_b : '0) | (me[91] ? nb_map91_prg_addr_b : '0) | (me[225] | me[255] ? nb_map225_prg_addr_b : '0) | (me[31] ? nb_nsfplayer_prg_addr_b : '0);
assign chr_addr_b = (1'b0 ? nb_mmc0_chr_addr_b : '0) | (me[171] | me[155] | me[1] ? nb_mmc1_chr_addr_b : '0) | (mapper28_en & ~reset ? nb_map28_chr_addr_b : '0) | (me[30] ? nb_map30_chr_addr_b : '0) | (me[32] ? nb_map32_chr_addr_b : '0) | (me[9] ? nb_mmc2_chr_addr_b : '0) | (mmc3_en ? nb_mmc3_chr_addr_b : '0) | (me[10] ? nb_mmc4_chr_addr_b : '0) | (me[5] ? nb_mmc5_chr_addr_b : '0) | (me[13] ? nb_map13_chr_addr_b : '0) | (me[15] ? nb_map15_chr_addr_b : '0) | (me[159] | me[153] | me[16] ? nb_map16_chr_addr_b : '0) | (me[18] ? nb_map18_chr_addr_b : '0) | (me[34] ? nb_map34_chr_addr_b : '0) | (me[41] ? nb_map41_chr_addr_b : '0) | (me[42] ? nb_map42_chr_addr_b : '0) | (me[65] ? nb_map65_chr_addr_b : '0) | (mapper66_en ? nb_map66_chr_addr_b : '0) | (me[67] | me[190] ? nb_map67_chr_addr_b : '0) | (me[68] ? nb_map68_chr_addr_b : '0) | (me[69] ? nb_map69_chr_addr_b : '0) | (me[71] | me[232] ? nb_map71_chr_addr_b : '0) | (me[92] | me[72] ? nb_map72_chr_addr_b : '0) | (me[77] ? nb_map77_chr_addr_b : '0) | (me[152] | me[70] | me[78] ? nb_map78_chr_addr_b : '0) | (me[79] | me[113] | me[133] | me[146] | me[148] ? nb_map79_chr_addr_b : '0) | (me[83] ? nb_map83_chr_addr_b : '0) | (me[89] | me[93] | me[184] ? nb_map89_chr_addr_b : '0) | (me[107] ? nb_map107_chr_addr_b : '0) | (me[111] ? nb_map111_chr_addr_b : '0) | (me[165] ? nb_map165_chr_addr_b : '0) | (me[218] ? nb_map218_chr_addr_b : '0) | (me[228] ? nb_map228_chr_addr_b : '0) | (me[234] ? nb_map234_chr_addr_b : '0) | (me[64] | me[158] ? nb_rambo1_chr_addr_b : '0) | (me[105] ? nb_nesev_chr_addr_b : '0) | (me[210] | me[19] ? nb_n163_chr_addr_b : '0) | (me[162] ? nb_map162_chr_addr_b : '0) | (me[163] ? nb_map163_chr_addr_b : '0) | (me[164] ? nb_map164_chr_addr_b : '0) | (me[137] | me[138] | me[139] | me[141] | me[150] | me[243] ? nb_sachen_chr_addr_b : '0) | (me[136] | me[147] | me[132] | me[173] | me[172] | me[36] ? nb_sachenj_chr_addr_b : '0) | (me[143] ? nb_sachenn_chr_addr_b : '0) | (me[90] | me[209] | me[211] | me[35] ? nb_jycompany_chr_addr_b : '0) | (me[91] ? nb_map91_chr_addr_b : '0) | (me[225] | me[255] ? nb_map225_chr_addr_b : '0) | (me[31] ? nb_nsfplayer_chr_addr_b : '0);
assign flags_out_b = (me[171] | me[155] | me[1] ? nb_mmc1_flags_out_b : '0) | (mapper28_en & ~reset ? nb_map28_flags_out_b : '0) | (me[30] ? nb_map30_flags_out_b : '0) | (me[32] ? nb_map32_flags_out_b : '0) | (me[9] ? nb_mmc2_flags_out_b : '0) | (mmc3_en ? nb_mmc3_flags_out_b : '0) | (me[10] ? nb_mmc4_flags_out_b : '0) | (me[5] ? nb_mmc5_flags_out_b : '0) | (me[13] ? nb_map13_flags_out_b : '0) | (me[15] ? nb_map15_flags_out_b : '0) | (me[159] | me[153] | me[16] ? nb_map16_flags_out_b : '0) | (me[18] ? nb_map18_flags_out_b : '0) | (me[34] ? nb_map34_flags_out_b : '0) | (me[41] ? nb_map41_flags_out_b : '0) | (me[42] ? nb_map42_flags_out_b : '0) | (me[65] ? nb_map65_flags_out_b : '0) | (mapper66_en ? nb_map66_flags_out_b : '0) | (me[67] | me[190] ? nb_map67_flags_out_b : '0) | (me[68] ? nb_map68_flags_out_b : '0) | (me[69] ? nb_map69_flags_out_b : '0) | (me[71] | me[232] ? nb_map71_flags_out_b : '0) | (me[92] | me[72] ? nb_map72_flags_out_b : '0) | (me[77] ? nb_map77_flags_out_b : '0) | (me[152] | me[70] | me[78] ? nb_map78_flags_out_b : '0) | (me[79] | me[113] | me[133] | me[146] | me[148] ? nb_map79_flags_out_b : '0) | (me[83] ? nb_map83_flags_out_b : '0) | (me[89] | me[93] | me[184] ? nb_map89_flags_out_b : '0) | (me[107] ? nb_map107_flags_out_b : '0) | (me[111] ? nb_map111_flags_out_b : '0) | (me[165] ? nb_map165_flags_out_b : '0) | (me[218] ? nb_map218_flags_out_b : '0) | (me[228] ? nb_map228_flags_out_b : '0) | (me[234] ? nb_map234_flags_out_b : '0) | (me[64] | me[158] ? nb_rambo1_flags_out_b : '0) | (me[105] ? nb_nesev_flags_out_b : '0) | (me[210] | me[19] ? nb_n163_flags_out_b : '0) | (me[162] ? nb_map162_flags_out_b : '0) | (me[163] ? nb_map163_flags_out_b : '0) | (me[164] ? nb_map164_flags_out_b : '0) | (me[137] | me[138] | me[139] | me[141] | me[150] | me[243] ? nb_sachen_flags_out_b : '0) | (me[136] | me[147] | me[132] | me[173] | me[172] | me[36] ? nb_sachenj_flags_out_b : '0) | (me[143] ? nb_sachenn_flags_out_b : '0) | (me[90] | me[209] | me[211] | me[35] ? nb_jycompany_flags_out_b : '0) | (me[91] ? nb_map91_flags_out_b : '0) | (me[225] | me[255] ? nb_map225_flags_out_b : '0) | (me[31] ? nb_nsfplayer_flags_out_b : '0);
assign audio_out_b = (1'b0 ? nb_mmc0_audio_out_b : '0) | (me[171] | me[155] | me[1] ? nb_mmc1_audio_out_b : '0) | (mapper28_en & ~reset ? nb_map28_audio_out_b : '0) | (me[30] ? nb_map30_audio_out_b : '0) | (me[32] ? nb_map32_audio_out_b : '0) | (me[9] ? nb_mmc2_audio_out_b : '0) | (mmc3_en ? nb_mmc3_audio_out_b : '0) | (me[10] ? nb_mmc4_audio_out_b : '0) | (me[5] ? nb_mmc5_audio_out_b : '0) | (me[13] ? nb_map13_audio_out_b : '0) | (me[15] ? nb_map15_audio_out_b : '0) | (me[159] | me[153] | me[16] ? nb_map16_audio_out_b : '0) | (me[18] ? nb_map18_audio_out_b : '0) | (me[34] ? nb_map34_audio_out_b : '0) | (me[41] ? nb_map41_audio_out_b : '0) | (me[42] ? nb_map42_audio_out_b : '0) | (me[65] ? nb_map65_audio_out_b : '0) | (mapper66_en ? nb_map66_audio_out_b : '0) | (me[67] | me[190] ? nb_map67_audio_out_b : '0) | (me[68] ? nb_map68_audio_out_b : '0) | (me[69] ? nb_map69_audio_out_b : '0) | (me[71] | me[232] ? nb_map71_audio_out_b : '0) | (me[92] | me[72] ? nb_map72_audio_out_b : '0) | (me[77] ? nb_map77_audio_out_b : '0) | (me[152] | me[70] | me[78] ? nb_map78_audio_out_b : '0) | (me[79] | me[113] | me[133] | me[146] | me[148] ? nb_map79_audio_out_b : '0) | (me[83] ? nb_map83_audio_out_b : '0) | (me[89] | me[93] | me[184] ? nb_map89_audio_out_b : '0) | (me[107] ? nb_map107_audio_out_b : '0) | (me[111] ? nb_map111_audio_out_b : '0) | (me[165] ? nb_map165_audio_out_b : '0) | (me[218] ? nb_map218_audio_out_b : '0) | (me[228] ? nb_map228_audio_out_b : '0) | (me[234] ? nb_map234_audio_out_b : '0) | (me[64] | me[158] ? nb_rambo1_audio_out_b : '0) | (me[105] ? nb_nesev_audio_out_b : '0) | (me[210] | me[19] ? nb_n163_audio_out_b : '0) | (me[162] ? nb_map162_audio_out_b : '0) | (me[163] ? nb_map163_audio_out_b : '0) | (me[164] ? nb_map164_audio_out_b : '0) | (me[137] | me[138] | me[139] | me[141] | me[150] | me[243] ? nb_sachen_audio_out_b : '0) | (me[136] | me[147] | me[132] | me[173] | me[172] | me[36] ? nb_sachenj_audio_out_b : '0) | (me[143] ? nb_sachenn_audio_out_b : '0) | (me[90] | me[209] | me[211] | me[35] ? nb_jycompany_audio_out_b : '0) | (me[91] ? nb_map91_audio_out_b : '0) | (me[225] | me[255] ? nb_map225_audio_out_b : '0) | (me[31] ? nb_nsfplayer_audio_out_b : '0);
assign prg_dout_b = (1'b0 ? nb_mmc0_prg_dout_b : '1) & (me[171] | me[155] | me[1] ? nb_mmc1_prg_dout_b : '1) & (mapper28_en & ~reset ? nb_map28_prg_dout_b : '1) & (me[30] ? nb_map30_prg_dout_b : '1) & (me[32] ? nb_map32_prg_dout_b : '1) & (me[9] ? nb_mmc2_prg_dout_b : '1) & (mmc3_en ? nb_mmc3_prg_dout_b : '1) & (me[10] ? nb_mmc4_prg_dout_b : '1) & (me[5] ? nb_mmc5_prg_dout_b : '1) & (me[13] ? nb_map13_prg_dout_b : '1) & (me[15] ? nb_map15_prg_dout_b : '1) & (me[159] | me[153] | me[16] ? nb_map16_prg_dout_b : '1) & (me[18] ? nb_map18_prg_dout_b : '1) & (me[34] ? nb_map34_prg_dout_b : '1) & (me[41] ? nb_map41_prg_dout_b : '1) & (me[42] ? nb_map42_prg_dout_b : '1) & (me[65] ? nb_map65_prg_dout_b : '1) & (mapper66_en ? nb_map66_prg_dout_b : '1) & (me[67] | me[190] ? nb_map67_prg_dout_b : '1) & (me[68] ? nb_map68_prg_dout_b : '1) & (me[69] ? nb_map69_prg_dout_b : '1) & (me[71] | me[232] ? nb_map71_prg_dout_b : '1) & (me[92] | me[72] ? nb_map72_prg_dout_b : '1) & (me[77] ? nb_map77_prg_dout_b : '1) & (me[152] | me[70] | me[78] ? nb_map78_prg_dout_b : '1) & (me[79] | me[113] | me[133] | me[146] | me[148] ? nb_map79_prg_dout_b : '1) & (me[83] ? nb_map83_prg_dout_b : '1) & (me[89] | me[93] | me[184] ? nb_map89_prg_dout_b : '1) & (me[107] ? nb_map107_prg_dout_b : '1) & (me[111] ? nb_map111_prg_dout_b : '1) & (me[165] ? nb_map165_prg_dout_b : '1) & (me[218] ? nb_map218_prg_dout_b : '1) & (me[228] ? nb_map228_prg_dout_b : '1) & (me[234] ? nb_map234_prg_dout_b : '1) & (me[64] | me[158] ? nb_rambo1_prg_dout_b : '1) & (me[105] ? nb_nesev_prg_dout_b : '1) & (me[210] | me[19] ? nb_n163_prg_dout_b : '1) & (me[162] ? nb_map162_prg_dout_b : '1) & (me[163] ? nb_map163_prg_dout_b : '1) & (me[164] ? nb_map164_prg_dout_b : '1) & (me[137] | me[138] | me[139] | me[141] | me[150] | me[243] ? nb_sachen_prg_dout_b : '1) & (me[136] | me[147] | me[132] | me[173] | me[172] | me[36] ? nb_sachenj_prg_dout_b : '1) & (me[143] ? nb_sachenn_prg_dout_b : '1) & (me[90] | me[209] | me[211] | me[35] ? nb_jycompany_prg_dout_b : '1) & (me[91] ? nb_map91_prg_dout_b : '1) & (me[225] | me[255] ? nb_map225_prg_dout_b : '1) & (me[31] ? nb_nsfplayer_prg_dout_b : '1);
assign chr_dout_b = (mapper28_en & ~reset ? nb_map28_chr_dout_b : '1) & (me[5] ? nb_mmc5_chr_dout_b : '1);
assign fds_diskside_auto = '0;


wire prg_allow_b, vram_a10_b, vram_ce_b, chr_allow_b, irq_b;
wire [21:0] prg_addr_b, chr_addr_b;
wire [15:0] flags_out_b, audio_out_b;
wire [7:0] prg_dout_b, chr_dout_b;

// This mapper used to be default if no other mapper was found
// It seems MMC0 is handled by map28. Does it have any purpose?
// flags_out_b will be high if no other mappers are selected, so we use that.
wire [15:0] mmc0_flags;
MMC0 mmc0(
	.clk        (clk),
	.ce         (ce),
	.enable     (1'b0),
	.flags      (flags),
	.prg_ain    (prg_ain),
	.prg_aout_b (nb_mmc0_prg_addr_b),
	.prg_read   (prg_read),
	.prg_write  (prg_write),
	.prg_din    (prg_din),
	.prg_dout_b (nb_mmc0_prg_dout_b),
	.prg_allow_b(nb_mmc0_prg_allow_b),
	.chr_ain    (chr_ain),
	.chr_aout_b (nb_mmc0_chr_addr_b),
	.chr_read   (chr_read),
	.chr_allow_b(nb_mmc0_chr_allow_b),
	.vram_a10_b (nb_mmc0_vram_a10_b),
	.vram_ce_b  (nb_mmc0_vram_ce_b),
	.irq_b      (nb_mmc0_irq_b),
	.flags_out_b(mmc0_flags),
	.audio_in   (audio_in),
	.audio_b    (nb_mmc0_audio_out_b)
);

//*****************************************************************************//
// Name   : MMC1                                                               //
// Mappers: 1, 155, 171 (hard wired vertical mirroring)                        //
// Status : Working                                                            //
// Notes  :                                                                    //
// Games  : Simon's Quest                                                      //
//*****************************************************************************//
MMC1 mmc1(
	.clk        (clk),
	.ce         (ce),
	.enable     (me[171] | me[155] | me[1]),
	.flags      (flags),
	.prg_ain    (prg_ain),
	.prg_aout_b (nb_mmc1_prg_addr_b),
	.prg_read   (prg_read),
	.prg_write  (prg_write),
	.prg_din    (prg_din),
	.prg_dout_b (nb_mmc1_prg_dout_b),
	.prg_allow_b(nb_mmc1_prg_allow_b),
	.chr_ain    (chr_ain),
	.chr_aout_b (nb_mmc1_chr_addr_b),
	.chr_read   (chr_read),
	.chr_allow_b(nb_mmc1_chr_allow_b),
	.vram_a10_b (nb_mmc1_vram_a10_b),
	.vram_ce_b  (nb_mmc1_vram_ce_b),
	.irq_b      (nb_mmc1_irq_b),
	.flags_out_b(nb_mmc1_flags_out_b),
	.audio_in   (audio_in),
	.audio_b    (nb_mmc1_audio_out_b)
);

//*****************************************************************************//
// Name   : Tepples                                                            //
// Mappers: 0, 2, 3, 7, 28, 94, 97, 180, 185                                   //
// Status : Working                                                            //
// Notes  : This mapper relies on open bus and bus conflict behavior.          //
// Games  : Donkey Kong                                                        //
//*****************************************************************************//
wire mapper28_en = me[0] | me[2] | me[3] | me[7] | me[94] | me[97] | me[180] | me[185] | me[28];
Mapper28 map28(
	.clk        (clk),
	.ce         (ce),
	.enable     (mapper28_en & ~reset),
	.flags      (flags),
	.prg_ain    (prg_ain),
	.prg_aout_b (nb_map28_prg_addr_b),
	.prg_read   (prg_read),
	.prg_write  (prg_write),
	.prg_din    (prg_din),
	.prg_dout_b (nb_map28_prg_dout_b),
	.prg_allow_b(nb_map28_prg_allow_b),
	.chr_ain    (chr_ain),
	.chr_aout_b (nb_map28_chr_addr_b),
	.chr_read   (chr_read),
	.chr_dout_b (nb_map28_chr_dout_b), // Special port
	.chr_allow_b(nb_map28_chr_allow_b),
	.vram_a10_b (nb_map28_vram_a10_b),
	.vram_ce_b  (nb_map28_vram_ce_b),
	.irq_b      (nb_map28_irq_b),
	.flags_out_b(nb_map28_flags_out_b),
	.audio_in   (audio_in),
	.audio_b    (nb_map28_audio_out_b)
);

//*****************************************************************************//
// Name   : UNROM 512                                                          //
// Mappers: 30                                                                 //
// Status : No Self Flashing/Needs testing                                     //
// Notes  : Homebrew mapper                                                    //
// Games  : ?                                                                  //
//*****************************************************************************//
Mapper30 map30(
	.clk        (clk),
	.ce         (ce),
	.enable     (me[30]),
	.flags      (flags),
	.prg_ain    (prg_ain),
	.prg_aout_b (nb_map30_prg_addr_b),
	.prg_read   (prg_read),
	.prg_write  (prg_write),
	.prg_din    (prg_din),
	.prg_dout_b (nb_map30_prg_dout_b),
	.prg_allow_b(nb_map30_prg_allow_b),
	.chr_ain    (chr_ain),
	.chr_aout_b (nb_map30_chr_addr_b),
	.chr_read   (chr_read),
	.chr_allow_b(nb_map30_chr_allow_b),
	.vram_a10_b (nb_map30_vram_a10_b),
	.vram_ce_b  (nb_map30_vram_ce_b),
	.irq_b      (nb_map30_irq_b),
	.flags_out_b(nb_map30_flags_out_b),
	.audio_in   (audio_in),
	.audio_b    (nb_map30_audio_out_b)
);

//*****************************************************************************//
// Name   : Mapper 32                                                          //
// Mappers: 32                                                                 //
// Status : Needs evaluation                                                   //
// Notes  :                                                                    //
// Games  : Image Fight                                                        //
//*****************************************************************************//
Mapper32 map32(
	.clk        (clk),
	.ce         (ce),
	.enable     (me[32]),
	.flags      (flags),
	.prg_ain    (prg_ain),
	.prg_aout_b (nb_map32_prg_addr_b),
	.prg_read   (prg_read),
	.prg_write  (prg_write),
	.prg_din    (prg_din),
	.prg_dout_b (nb_map32_prg_dout_b),
	.prg_allow_b(nb_map32_prg_allow_b),
	.chr_ain    (chr_ain),
	.chr_aout_b (nb_map32_chr_addr_b),
	.chr_read   (chr_read),
	.chr_allow_b(nb_map32_chr_allow_b),
	.vram_a10_b (nb_map32_vram_a10_b),
	.vram_ce_b  (nb_map32_vram_ce_b),
	.irq_b      (nb_map32_irq_b),
	.flags_out_b(nb_map32_flags_out_b),
	.audio_in   (audio_in),
	.audio_b    (nb_map32_audio_out_b)
);

//*****************************************************************************//
// Name   : MMC2                                                               //
// Mappers: 9                                                                  //
// Status :                                                                    //
// Notes  : Working                                                            //
// Games  : Mike Tyson's Punch-Out                                             //
//*****************************************************************************//
MMC2 mmc2(
	.clk        (clk),
	.ce         (ppu_ce), // PPU_CE
	.enable     (me[9]),
	.flags      (flags),
	.prg_ain    (prg_ain),
	.prg_aout_b (nb_mmc2_prg_addr_b),
	.prg_read   (prg_read),
	.prg_write  (prg_write),
	.prg_din    (prg_din),
	.prg_dout_b (nb_mmc2_prg_dout_b),
	.prg_allow_b(nb_mmc2_prg_allow_b),
	.chr_ain    (chr_ain),
	.chr_aout_b (nb_mmc2_chr_addr_b),
	.chr_read   (chr_read),
	.chr_allow_b(nb_mmc2_chr_allow_b),
	.vram_a10_b (nb_mmc2_vram_a10_b),
	.vram_ce_b  (nb_mmc2_vram_ce_b),
	.irq_b      (nb_mmc2_irq_b),
	.flags_out_b(nb_mmc2_flags_out_b),
	.audio_in   (audio_in),
	.audio_b    (nb_mmc2_audio_out_b)
);

//*****************************************************************************//
// Name   : MMC3                                                               //
// Mappers: 4, 33, 37, 47, 48, 74, 76, 80, 82, 88, 95, 112, 118, 119, 154, 191,//
//          192, 194, 195, 206, 207                                            //
// Status : Working -- Blaarg IRQ timing test fails, but may be submapper      //
// Notes  : While currently working well, this mapper could use a full review. //
// Games  : Crystalis, Battletoads                                             //
//*****************************************************************************//
wire mmc3_en = me[118] | me[119] | me[47] | me[206] | me[112] | me[88] | me[154] | me[95]
	| me[76] | me[80] | me[82] | me[207] | me[48] | me[33] | me[37] | me[74] | me[191]
	| me[192] | me[194] | me[195] | me[4];

MMC3 mmc3 (
	.clk        (clk),
	.ce         (ppu_ce), // PPU CE
	.enable     (mmc3_en),
	.flags      (flags),
	.prg_ain    (prg_ain),
	.prg_aout_b (nb_mmc3_prg_addr_b),
	.prg_read   (prg_read),
	.prg_write  (prg_write),
	.prg_din    (prg_din),
	.prg_dout_b (nb_mmc3_prg_dout_b),
	.prg_allow_b(nb_mmc3_prg_allow_b),
	.chr_ain    (chr_ain),
	.chr_aout_b (nb_mmc3_chr_addr_b),
	.chr_read   (chr_read),
	.chr_allow_b(nb_mmc3_chr_allow_b),
	.vram_a10_b (nb_mmc3_vram_a10_b),
	.vram_ce_b  (nb_mmc3_vram_ce_b),
	.irq_b      (nb_mmc3_irq_b),
	.flags_out_b(nb_mmc3_flags_out_b),
	.audio_in   (audio_in),
	.audio_b    (nb_mmc3_audio_out_b)
);

//*****************************************************************************//
// Name   : MMC4                                                               //
// Mappers: 10                                                                 //
// Status : Working                                                            //
// Notes  :                                                                    //
// Games  : Fire Emblem                                                        //
//*****************************************************************************//
MMC4 mmc4(
	.clk        (clk),
	.ce         (ppu_ce), // PPU_CE
	.enable     (me[10]),
	.flags      (flags),
	.prg_ain    (prg_ain),
	.prg_aout_b (nb_mmc4_prg_addr_b),
	.prg_read   (prg_read),
	.prg_write  (prg_write),
	.prg_din    (prg_din),
	.prg_dout_b (nb_mmc4_prg_dout_b),
	.prg_allow_b(nb_mmc4_prg_allow_b),
	.chr_ain    (chr_ain),
	.chr_aout_b (nb_mmc4_chr_addr_b),
	.chr_read   (chr_read),
	.chr_allow_b(nb_mmc4_chr_allow_b),
	.vram_a10_b (nb_mmc4_vram_a10_b),
	.vram_ce_b  (nb_mmc4_vram_ce_b),
	.irq_b      (nb_mmc4_irq_b),
	.flags_out_b(nb_mmc4_flags_out_b),
	.audio_in   (audio_in),
	.audio_b    (nb_mmc4_audio_out_b)
);

//*****************************************************************************//
// Name   : MMC5                                                               //
// Mappers: 5                                                                  //
// Status : Fairly complete, but has some bugs. Check Rockman Minus Infinity.  //
// Notes  : Uses expansion audio and PPU hacks. Could use a thorough review.   //
// Games  : Castlevania III, Just Breed                                        //
//*****************************************************************************//
MMC5 mmc5(
	.clk        (clk),
	.ce         (ce),
	.enable     (me[5]),
	.flags      (flags),
	.prg_ain    (prg_ain),
	.prg_aout_b (nb_mmc5_prg_addr_b),
	.prg_read   (prg_read),
	.prg_write  (prg_write),
	.prg_din    (prg_din),
	.prg_dout_b (nb_mmc5_prg_dout_b),
	.prg_allow_b(nb_mmc5_prg_allow_b),
	.chr_ain    (chr_ain),
	.chr_aout_b (nb_mmc5_chr_addr_b),
	.chr_read   (chr_read),
	.chr_allow_b(nb_mmc5_chr_allow_b),
	.vram_a10_b (nb_mmc5_vram_a10_b),
	.vram_ce_b  (nb_mmc5_vram_ce_b),
	.irq_b      (nb_mmc5_irq_b),
	.flags_out_b(nb_mmc5_flags_out_b),
	.audio_in   (mmc5_audio),
	.audio_b    (nb_mmc5_audio_out_b),
	// Special ports
	.audio_dout	(mmc5_data),
	.chr_din    (chr_din),
	.chr_write  (chr_write),
	.chr_dout_b (nb_mmc5_chr_dout_b),
	.ppu_ce     (ppu_ce),
	.ppuflags   (ppuflags)
);

//*****************************************************************************//
// Name   : CPROM                                                              //
// Mappers: 13                                                                 //
// Status : Working                                                            //
// Notes  :                                                                    //
// Games  : Videomation                                                        //
//*****************************************************************************//
Mapper13 map13(
	.clk        (clk),
	.ce         (ce),
	.enable     (me[13]),
	.flags      (flags),
	.prg_ain    (prg_ain),
	.prg_aout_b (nb_map13_prg_addr_b),
	.prg_read   (prg_read),
	.prg_write  (prg_write),
	.prg_din    (prg_din),
	.prg_dout_b (nb_map13_prg_dout_b),
	.prg_allow_b(nb_map13_prg_allow_b),
	.chr_ain    (chr_ain),
	.chr_aout_b (nb_map13_chr_addr_b),
	.chr_read   (chr_read),
	.chr_allow_b(nb_map13_chr_allow_b),
	.vram_a10_b (nb_map13_vram_a10_b),
	.vram_ce_b  (nb_map13_vram_ce_b),
	.irq_b      (nb_map13_irq_b),
	.flags_out_b(nb_map13_flags_out_b),
	.audio_in   (audio_in),
	.audio_b    (nb_map13_audio_out_b)
);

//*****************************************************************************//
// Name   : Mapper 15                                                          //
// Mappers: 15                                                                 //
// Status : Working                                                            //
// Notes  :                                                                    //
// Games  : Bao Xiao San Guo                                                   //
//*****************************************************************************//
Mapper15 map15(
	.clk        (clk),
	.ce         (ce),
	.enable     (me[15]),
	.flags      (flags),
	.prg_ain    (prg_ain),
	.prg_aout_b (nb_map15_prg_addr_b),
	.prg_read   (prg_read),
	.prg_write  (prg_write),
	.prg_din    (prg_din),
	.prg_dout_b (nb_map15_prg_dout_b),
	.prg_allow_b(nb_map15_prg_allow_b),
	.chr_ain    (chr_ain),
	.chr_aout_b (nb_map15_chr_addr_b),
	.chr_read   (chr_read),
	.chr_allow_b(nb_map15_chr_allow_b),
	.vram_a10_b (nb_map15_vram_a10_b),
	.vram_ce_b  (nb_map15_vram_ce_b),
	.irq_b      (nb_map15_irq_b),
	.flags_out_b(nb_map15_flags_out_b),
	.audio_in   (audio_in),
	.audio_b    (nb_map15_audio_out_b)
);

//*****************************************************************************//
// Name   : Bandai 16                                                          //
// Mappers: 159, 153, 16                                                       //
// Status : Working/EEPROM needs testing                                       //
// Notes  :                                                                    //
// Games  : SD Gundam Gaiden, Dragon Ball 3, Famicom Jump II                   //
//*****************************************************************************//
wire map16_prg_write, map16_ovr;
wire [7:0] map16_data_out;
wire [17:0] map16_mapper_addr;
Mapper16 map16(
	.clk        (clk),
	.ce         (ce),
	.enable     (me[159] | me[153] | me[16]),
	.flags      (flags),
	.prg_ain    (prg_ain),
	.prg_aout_b (nb_map16_prg_addr_b),
	.prg_read   (prg_read),
	.prg_write  (prg_write),
	.prg_din    (prg_din),
	.prg_dout_b (nb_map16_prg_dout_b),
	.prg_allow_b(nb_map16_prg_allow_b),
	.chr_ain    (chr_ain),
	.chr_aout_b (nb_map16_chr_addr_b),
	.chr_read   (chr_read),
	.chr_allow_b(nb_map16_chr_allow_b),
	.vram_a10_b (nb_map16_vram_a10_b),
	.vram_ce_b  (nb_map16_vram_ce_b),
	.irq_b      (nb_map16_irq_b),
	.flags_out_b(nb_map16_flags_out_b),
	.audio_in   (audio_in),
	.audio_b    (nb_map16_audio_out_b),
	// Special Ports
	.mapper_addr(map16_mapper_addr),
	.mapper_data_in(mapper_data_in),
	.mapper_data_out(map16_data_out),
	.mapper_prg_write(map16_prg_write),
	.mapper_ovr(map16_ovr)
);

//*****************************************************************************//
// Name   : Jaleco 18                                                          //
// Mappers: 18                                                                 //
// Status : Needs Evaluation                                                   //
// Notes  :                                                                    //
// Games  : Pizza Pop!, Plasma Ball, USA Ice Hockey in FC                      //
//*****************************************************************************//
Mapper18 map18(
	.clk        (clk),
	.ce         (ce),
	.enable     (me[18]),
	.flags      (flags),
	.prg_ain    (prg_ain),
	.prg_aout_b (nb_map18_prg_addr_b),
	.prg_read   (prg_read),
	.prg_write  (prg_write),
	.prg_din    (prg_din),
	.prg_dout_b (nb_map18_prg_dout_b),
	.prg_allow_b(nb_map18_prg_allow_b),
	.chr_ain    (chr_ain),
	.chr_aout_b (nb_map18_chr_addr_b),
	.chr_read   (chr_read),
	.chr_allow_b(nb_map18_chr_allow_b),
	.vram_a10_b (nb_map18_vram_a10_b),
	.vram_ce_b  (nb_map18_vram_ce_b),
	.irq_b      (nb_map18_irq_b),
	.flags_out_b(nb_map18_flags_out_b),
	.audio_in   (audio_in),
	.audio_b    (nb_map18_audio_out_b)
);

//*****************************************************************************//
// Name   : BNROM                                                              //
// Mappers: 34                                                                 //
// Status : Working                                                            //
// Notes  :                                                                    //
// Games  : Mashou, Deadly Towers                                              //
//*****************************************************************************//
Mapper34 map34(
	.clk        (clk),
	.ce         (ce),
	.enable     (me[34]),
	.flags      (flags),
	.prg_ain    (prg_ain),
	.prg_aout_b (nb_map34_prg_addr_b),
	.prg_read   (prg_read),
	.prg_write  (prg_write),
	.prg_din    (prg_din),
	.prg_dout_b (nb_map34_prg_dout_b),
	.prg_allow_b(nb_map34_prg_allow_b),
	.chr_ain    (chr_ain),
	.chr_aout_b (nb_map34_chr_addr_b),
	.chr_read   (chr_read),
	.chr_allow_b(nb_map34_chr_allow_b),
	.vram_a10_b (nb_map34_vram_a10_b),
	.vram_ce_b  (nb_map34_vram_ce_b),
	.irq_b      (nb_map34_irq_b),
	.flags_out_b(nb_map34_flags_out_b),
	.audio_in   (audio_in),
	.audio_b    (nb_map34_audio_out_b)
);

//*****************************************************************************//
// Name   : Mapper 41                                                          //
// Mappers: 41                                                                 //
// Status : Working                                                            //
// Notes  :                                                                    //
// Games  : Caltron 6-in-1                                                     //
//*****************************************************************************//
Mapper41 map41(
	.clk        (clk),
	.ce         (ce),
	.enable     (me[41]),
	.flags      (flags),
	.prg_ain    (prg_ain),
	.prg_aout_b (nb_map41_prg_addr_b),
	.prg_read   (prg_read),
	.prg_write  (prg_write),
	.prg_din    (prg_din),
	.prg_dout_b (nb_map41_prg_dout_b),
	.prg_allow_b(nb_map41_prg_allow_b),
	.chr_ain    (chr_ain),
	.chr_aout_b (nb_map41_chr_addr_b),
	.chr_read   (chr_read),
	.chr_allow_b(nb_map41_chr_allow_b),
	.vram_a10_b (nb_map41_vram_a10_b),
	.vram_ce_b  (nb_map41_vram_ce_b),
	.irq_b      (nb_map41_irq_b),
	.flags_out_b(nb_map41_flags_out_b),
	.audio_in   (audio_in),
	.audio_b    (nb_map41_audio_out_b)
);

//*****************************************************************************//
// Name   : Mapper 42                                                          //
// Mappers: 42                                                                 //
// Status : Not working                                                        //
// Notes  : Used for converted FDS carts.                                      //
// Games  : Love Warrior Nicol, Green Beret (unl)                              //
//*****************************************************************************//
Mapper42 map42(
	.clk        (clk),
	.ce         (ce),
	.enable     (me[42]),
	.flags      (flags),
	.prg_ain    (prg_ain),
	.prg_aout_b (nb_map42_prg_addr_b),
	.prg_read   (prg_read),
	.prg_write  (prg_write),
	.prg_din    (prg_din),
	.prg_dout_b (nb_map42_prg_dout_b),
	.prg_allow_b(nb_map42_prg_allow_b),
	.chr_ain    (chr_ain),
	.chr_aout_b (nb_map42_chr_addr_b),
	.chr_read   (chr_read),
	.chr_allow_b(nb_map42_chr_allow_b),
	.vram_a10_b (nb_map42_vram_a10_b),
	.vram_ce_b  (nb_map42_vram_ce_b),
	.irq_b      (nb_map42_irq_b),
	.flags_out_b(nb_map42_flags_out_b),
	.audio_in   (audio_in),
	.audio_b    (nb_map42_audio_out_b)
);

//*****************************************************************************//
// Name   : Irem H3001                                                         //
// Mappers: 65                                                                 //
// Status : Needs evaluation                                                   //
// Notes  :                                                                    //
// Games  : Spartan X 2, Daiku no Gen-san 2                                    //
//*****************************************************************************//
Mapper65 map65(
	.clk        (clk),
	.ce         (ce),
	.enable     (me[65]),
	.flags      (flags),
	.prg_ain    (prg_ain),
	.prg_aout_b (nb_map65_prg_addr_b),
	.prg_read   (prg_read),
	.prg_write  (prg_write),
	.prg_din    (prg_din),
	.prg_dout_b (nb_map65_prg_dout_b),
	.prg_allow_b(nb_map65_prg_allow_b),
	.chr_ain    (chr_ain),
	.chr_aout_b (nb_map65_chr_addr_b),
	.chr_read   (chr_read),
	.chr_allow_b(nb_map65_chr_allow_b),
	.vram_a10_b (nb_map65_vram_a10_b),
	.vram_ce_b  (nb_map65_vram_ce_b),
	.irq_b      (nb_map65_irq_b),
	.flags_out_b(nb_map65_flags_out_b),
	.audio_in   (audio_in),
	.audio_b    (nb_map65_audio_out_b)
);

//*****************************************************************************//
// Name   : GxROM                                                              //
// Mappers: 11, 38, 46, 66, 86, 87, 101, 140                                       //
// Status : 38/66 - Working, 38/87/101/140 - Needs eval, 86 - No Audio Samples //
// Notes  :                                                                    //
// Games  : Doraemon, Dragon Power, Sidewinder (145), Taiwan Mahjong 16 (149)  //
//*****************************************************************************//
wire mapper66_en = me[11] | me[38] | me[46] | me[86] | me[87] | me[101] | me[140] | me[66] | me[145] | me[149];
Mapper66 map66(
	.clk        (clk),
	.ce         (ce),
	.enable     (mapper66_en),
	.flags      (flags),
	.prg_ain    (prg_ain),
	.prg_aout_b (nb_map66_prg_addr_b),
	.prg_read   (prg_read),
	.prg_write  (prg_write),
	.prg_din    (prg_din),
	.prg_dout_b (nb_map66_prg_dout_b),
	.prg_allow_b(nb_map66_prg_allow_b),
	.chr_ain    (chr_ain),
	.chr_aout_b (nb_map66_chr_addr_b),
	.chr_read   (chr_read),
	.chr_allow_b(nb_map66_chr_allow_b),
	.vram_a10_b (nb_map66_vram_a10_b),
	.vram_ce_b  (nb_map66_vram_ce_b),
	.irq_b      (nb_map66_irq_b),
	.flags_out_b(nb_map66_flags_out_b),
	.audio_in   (audio_in),
	.audio_b    (nb_map66_audio_out_b)
);

//*****************************************************************************//
// Name   : Sunsoft-3                                                          //
// Mappers: 67, 190                                                            //
// Status : Needs Evaluation                                                   //
// Notes  :                                                                    //
// Games  : Fantasy Zone II, Mito Koumon                                       //
//*****************************************************************************//
Mapper67 map67(
	.clk        (clk),
	.ce         (ce),
	.enable     (me[67] | me[190]),
	.flags      (flags),
	.prg_ain    (prg_ain),
	.prg_aout_b (nb_map67_prg_addr_b),
	.prg_read   (prg_read),
	.prg_write  (prg_write),
	.prg_din    (prg_din),
	.prg_dout_b (nb_map67_prg_dout_b),
	.prg_allow_b(nb_map67_prg_allow_b),
	.chr_ain    (chr_ain),
	.chr_aout_b (nb_map67_chr_addr_b),
	.chr_read   (chr_read),
	.chr_allow_b(nb_map67_chr_allow_b),
	.vram_a10_b (nb_map67_vram_a10_b),
	.vram_ce_b  (nb_map67_vram_ce_b),
	.irq_b      (nb_map67_irq_b),
	.flags_out_b(nb_map67_flags_out_b),
	.audio_in   (audio_in),
	.audio_b    (nb_map67_audio_out_b)
);

//*****************************************************************************//
// Name   : Sunsoft-4                                                          //
// Mappers: 68                                                                 //
// Status : Working                                                            //
// Notes  :                                                                    //
// Games  : After Burner (J), Majaraja                                         //
//*****************************************************************************//
Mapper68 map68(
	.clk        (clk),
	.ce         (ce),
	.enable     (me[68]),
	.flags      (flags),
	.prg_ain    (prg_ain),
	.prg_aout_b (nb_map68_prg_addr_b),
	.prg_read   (prg_read),
	.prg_write  (prg_write),
	.prg_din    (prg_din),
	.prg_dout_b (nb_map68_prg_dout_b),
	.prg_allow_b(nb_map68_prg_allow_b),
	.chr_ain    (chr_ain),
	.chr_aout_b (nb_map68_chr_addr_b),
	.chr_read   (chr_read),
	.chr_allow_b(nb_map68_chr_allow_b),
	.vram_a10_b (nb_map68_vram_a10_b),
	.vram_ce_b  (nb_map68_vram_ce_b),
	.irq_b      (nb_map68_irq_b),
	.flags_out_b(nb_map68_flags_out_b),
	.audio_in   (audio_in),
	.audio_b    (nb_map68_audio_out_b)
);

//*****************************************************************************//
// Name   : Sunsoft FME-7                                                      //
// Mappers: 69                                                                 //
// Status : Working*                                                           //
// Notes  : Audio needs better mixing/processing                               //
// Games  : Gimmick!, Barcode World, Hebereke                                  //
//*****************************************************************************//
Mapper69 map69(
	.clk        (clk),
	.ce         (ce),
	.enable     (me[69]),
	.flags      (flags),
	.prg_ain    (prg_ain),
	.prg_aout_b (nb_map69_prg_addr_b),
	.prg_read   (prg_read),
	.prg_write  (prg_write),
	.prg_din    (prg_din),
	.prg_dout_b (nb_map69_prg_dout_b),
	.prg_allow_b(nb_map69_prg_allow_b),
	.chr_ain    (chr_ain),
	.chr_aout_b (nb_map69_chr_addr_b),
	.chr_read   (chr_read),
	.chr_allow_b(nb_map69_chr_allow_b),
	.vram_a10_b (nb_map69_vram_a10_b),
	.vram_ce_b  (nb_map69_vram_ce_b),
	.irq_b      (nb_map69_irq_b),
	.flags_out_b(nb_map69_flags_out_b),
	.audio_in   (ss5b_audio),
	.audio_b    (nb_map69_audio_out_b)
);

//*****************************************************************************//
// Name   : Codemasters/Camerica                                               //
// Mappers: 71, 232                                                            //
// Status : Working                                                            //
// Notes  :                                                                    //
// Games  : Micro Machines, Big Nose the Caveman                               //
//*****************************************************************************//
Mapper71 map71(
	.clk        (clk),
	.ce         (ce),
	.enable     (me[71] | me[232]),
	.flags      (flags),
	.prg_ain    (prg_ain),
	.prg_aout_b (nb_map71_prg_addr_b),
	.prg_read   (prg_read),
	.prg_write  (prg_write),
	.prg_din    (prg_din),
	.prg_dout_b (nb_map71_prg_dout_b),
	.prg_allow_b(nb_map71_prg_allow_b),
	.chr_ain    (chr_ain),
	.chr_aout_b (nb_map71_chr_addr_b),
	.chr_read   (chr_read),
	.chr_allow_b(nb_map71_chr_allow_b),
	.vram_a10_b (nb_map71_vram_a10_b),
	.vram_ce_b  (nb_map71_vram_ce_b),
	.irq_b      (nb_map71_irq_b),
	.flags_out_b(nb_map71_flags_out_b),
	.audio_in   (audio_in),
	.audio_b    (nb_map71_audio_out_b)
);

//*****************************************************************************//
// Name   : Jaleco JF-17                                                       //
// Mappers: 72, 92                                                             //
// Status : 72/92 - Needs evaluation/No audio samples.                         //
// Notes  :                                                                    //
// Games  : Pro Tennis (J), Pinball Quest (J), Pro Soccer (J)                  //
//*****************************************************************************//
Mapper72 map72(
	.clk        (clk),
	.ce         (ce),
	.enable     (me[92] | me[72]),
	.flags      (flags),
	.prg_ain    (prg_ain),
	.prg_aout_b (nb_map72_prg_addr_b),
	.prg_read   (prg_read),
	.prg_write  (prg_write),
	.prg_din    (prg_din),
	.prg_dout_b (nb_map72_prg_dout_b),
	.prg_allow_b(nb_map72_prg_allow_b),
	.chr_ain    (chr_ain),
	.chr_aout_b (nb_map72_chr_addr_b),
	.chr_read   (chr_read),
	.chr_allow_b(nb_map72_chr_allow_b),
	.vram_a10_b (nb_map72_vram_a10_b),
	.vram_ce_b  (nb_map72_vram_ce_b),
	.irq_b      (nb_map72_irq_b),
	.flags_out_b(nb_map72_flags_out_b),
	.audio_in   (audio_in),
	.audio_b    (nb_map72_audio_out_b)
);

//*****************************************************************************//
// Name   : Mapper 77                                                          //
// Mappers: 77                                                                 //
// Status : Needs Evaluation                                                   //
// Notes  :                                                                    //
// Games  : Napoleon Senki                                                     //
//*****************************************************************************//
Mapper77 map77(
	.clk        (clk),
	.ce         (ce),
	.enable     (me[77]),
	.flags      (flags),
	.prg_ain    (prg_ain),
	.prg_aout_b (nb_map77_prg_addr_b),
	.prg_read   (prg_read),
	.prg_write  (prg_write),
	.prg_din    (prg_din),
	.prg_dout_b (nb_map77_prg_dout_b),
	.prg_allow_b(nb_map77_prg_allow_b),
	.chr_ain    (chr_ain),
	.chr_aout_b (nb_map77_chr_addr_b),
	.chr_read   (chr_read),
	.chr_allow_b(nb_map77_chr_allow_b),
	.vram_a10_b (nb_map77_vram_a10_b),
	.vram_ce_b  (nb_map77_vram_ce_b),
	.irq_b      (nb_map77_irq_b),
	.flags_out_b(nb_map77_flags_out_b),
	.audio_in   (audio_in),
	.audio_b    (nb_map77_audio_out_b)
);

//*****************************************************************************//
// Name   : Holy Diver                                                         //
// Mappers: 78, 70, 152                                                        //
// Status : Needs testing overall                                             //
// Notes  : Submapper 1 Requires NES 2.0                                       //
// Games  : Holy Diver, Uchuusent                                              //
//*****************************************************************************//
Mapper78 map78(
	.clk        (clk),
	.ce         (ce),
	.enable     (me[152] | me[70] | me[78]),
	.flags      (flags),
	.prg_ain    (prg_ain),
	.prg_aout_b (nb_map78_prg_addr_b),
	.prg_read   (prg_read),
	.prg_write  (prg_write),
	.prg_din    (prg_din),
	.prg_dout_b (nb_map78_prg_dout_b),
	.prg_allow_b(nb_map78_prg_allow_b),
	.chr_ain    (chr_ain),
	.chr_aout_b (nb_map78_chr_addr_b),
	.chr_read   (chr_read),
	.chr_allow_b(nb_map78_chr_allow_b),
	.vram_a10_b (nb_map78_vram_a10_b),
	.vram_ce_b  (nb_map78_vram_ce_b),
	.irq_b      (nb_map78_irq_b),
	.flags_out_b(nb_map78_flags_out_b),
	.audio_in   (audio_in),
	.audio_b    (nb_map78_audio_out_b)
);

//*****************************************************************************//
// Name   : NINA                                                               //
// Mappers: 79, 113, 133, 146, 148                                             //
// Status : Working                                                            //
// Notes  : 133 uses simplified (72 pin) version, 146 Duplicate of 79?         //
// Games  : Tiles of Fate, Dudes with Attitude, Krazy Kreatures,               //
//          Twin Eagle (146), Mahjong World (148), Jovial Race (133)           //
//*****************************************************************************//
Mapper79 map79(
	.clk        (clk),
	.ce         (ce),
	.enable     (me[79] | me[113] | me[133] | me[146] | me[148]),
	.flags      (flags),
	.prg_ain    (prg_ain),
	.prg_aout_b (nb_map79_prg_addr_b),
	.prg_read   (prg_read),
	.prg_write  (prg_write),
	.prg_din    (prg_din),
	.prg_dout_b (nb_map79_prg_dout_b),
	.prg_allow_b(nb_map79_prg_allow_b),
	.chr_ain    (chr_ain),
	.chr_aout_b (nb_map79_chr_addr_b),
	.chr_read   (chr_read),
	.chr_allow_b(nb_map79_chr_allow_b),
	.vram_a10_b (nb_map79_vram_a10_b),
	.vram_ce_b  (nb_map79_vram_ce_b),
	.irq_b      (nb_map79_irq_b),
	.flags_out_b(nb_map79_flags_out_b),
	.audio_in   (audio_in),
	.audio_b    (nb_map79_audio_out_b)
);

//*****************************************************************************//
// Name   : Cony/Yoko (unlicensed)                                             //
// Mappers: 83                                                                 //
// Status : Supports all submappers, could use further evaluation              //
// Notes  : No user ability to control dipswitch setting                       //
// Games  : Fatal Fury 2, World Heroes 2, Dragon Ball Party                    //
//*****************************************************************************//
Mapper83 map83(
	.clk        (clk),
	.ce         (ce),
	.enable     (me[83]),
	.flags      (flags),
	.prg_ain    (prg_ain),
	.prg_aout_b (nb_map83_prg_addr_b),
	.prg_read   (prg_read),
	.prg_write  (prg_write),
	.prg_din    (prg_din),
	.prg_dout_b (nb_map83_prg_dout_b),
	.prg_allow_b(nb_map83_prg_allow_b),
	.chr_ain    (chr_ain),
	.chr_aout_b (nb_map83_chr_addr_b),
	.chr_read   (chr_read),
	.chr_allow_b(nb_map83_chr_allow_b),
	.vram_a10_b (nb_map83_vram_a10_b),
	.vram_ce_b  (nb_map83_vram_ce_b),
	.irq_b      (nb_map83_irq_b),
	.flags_out_b(nb_map83_flags_out_b),
	.audio_in   (audio_in),
	.audio_b    (nb_map83_audio_out_b)
);

//*****************************************************************************//
// Name   : Sunsoft                                                            //
// Mappers: 89, 93, 184                                                        //
// Status : Needs Evaluation                                                   //
// Notes  :                                                                    //
// Games  : Tenka no Goikenban                                                 //
//*****************************************************************************//
Mapper89 map89(
	.clk        (clk),
	.ce         (ce),
	.enable     (me[89] | me[93] | me[184]),
	.flags      (flags),
	.prg_ain    (prg_ain),
	.prg_aout_b (nb_map89_prg_addr_b),
	.prg_read   (prg_read),
	.prg_write  (prg_write),
	.prg_din    (prg_din),
	.prg_dout_b (nb_map89_prg_dout_b),
	.prg_allow_b(nb_map89_prg_allow_b),
	.chr_ain    (chr_ain),
	.chr_aout_b (nb_map89_chr_addr_b),
	.chr_read   (chr_read),
	.chr_allow_b(nb_map89_chr_allow_b),
	.vram_a10_b (nb_map89_vram_a10_b),
	.vram_ce_b  (nb_map89_vram_ce_b),
	.irq_b      (nb_map89_irq_b),
	.flags_out_b(nb_map89_flags_out_b),
	.audio_in   (audio_in),
	.audio_b    (nb_map89_audio_out_b)
);

//*****************************************************************************//
// Name   : Magic Dragon                                                       //
// Mappers: 107                                                                //
// Status : Needs Evaluation                                                   //
// Notes  :                                                                    //
// Games  : Magic Dragon                                                       //
//*****************************************************************************//
Mapper107 map107(
	.clk        (clk),
	.ce         (ce),
	.enable     (me[107]),
	.flags      (flags),
	.prg_ain    (prg_ain),
	.prg_aout_b (nb_map107_prg_addr_b),
	.prg_read   (prg_read),
	.prg_write  (prg_write),
	.prg_din    (prg_din),
	.prg_dout_b (nb_map107_prg_dout_b),
	.prg_allow_b(nb_map107_prg_allow_b),
	.chr_ain    (chr_ain),
	.chr_aout_b (nb_map107_chr_addr_b),
	.chr_read   (chr_read),
	.chr_allow_b(nb_map107_chr_allow_b),
	.vram_a10_b (nb_map107_vram_a10_b),
	.vram_ce_b  (nb_map107_vram_ce_b),
	.irq_b      (nb_map107_irq_b),
	.flags_out_b(nb_map107_flags_out_b),
	.audio_in   (audio_in),
	.audio_b    (nb_map107_audio_out_b)
);

//*****************************************************************************//
// Name   : GTROM                                                              //
// Mappers: 111                                                                //
// Status : Passes all tests except reflash test                               //
// Notes  : No LED or self-reflash support                                     //
// Games  : Super Homebrew War, Candelabra: Estoscerro, more homebrew          //
//*****************************************************************************//
Mapper111 map111(
	.clk        (clk),
	.ce         (ce),
	.enable     (me[111]),
	.flags      (flags),
	.prg_ain    (prg_ain),
	.prg_aout_b (nb_map111_prg_addr_b),
	.prg_read   (prg_read),
	.prg_write  (prg_write),
	.prg_din    (prg_din),
	.prg_dout_b (nb_map111_prg_dout_b),
	.prg_allow_b(nb_map111_prg_allow_b),
	.chr_ain    (chr_ain),
	.chr_aout_b (nb_map111_chr_addr_b),
	.chr_read   (chr_read),
	.chr_allow_b(nb_map111_chr_allow_b),
	.vram_a10_b (nb_map111_vram_a10_b),
	.vram_ce_b  (nb_map111_vram_ce_b),
	.irq_b      (nb_map111_irq_b),
	.flags_out_b(nb_map111_flags_out_b),
	.audio_in   (audio_in),
	.audio_b    (nb_map111_audio_out_b)
);

//*****************************************************************************//
// Name   : Mapper 165                                                         //
// Mappers: 165                                                                //
// Status : Working                                                            //
// Notes  : Possibly merge-able with MMC3, only used for one bootleg game      //
// Games  : Fire Emblem (unl)                                                  //
//*****************************************************************************//
Mapper165 map165(
	.clk        (clk),
	.ce         (ppu_ce), // PPU_CE
	.enable     (me[165]),
	.flags      (flags),
	.prg_ain    (prg_ain),
	.prg_aout_b (nb_map165_prg_addr_b),
	.prg_read   (prg_read),
	.prg_write  (prg_write),
	.prg_din    (prg_din),
	.prg_dout_b (nb_map165_prg_dout_b),
	.prg_allow_b(nb_map165_prg_allow_b),
	.chr_ain    (chr_ain),
	.chr_aout_b (nb_map165_chr_addr_b),
	.chr_read   (chr_read),
	.chr_allow_b(nb_map165_chr_allow_b),
	.vram_a10_b (nb_map165_vram_a10_b),
	.vram_ce_b  (nb_map165_vram_ce_b),
	.irq_b      (nb_map165_irq_b),
	.flags_out_b(nb_map165_flags_out_b),
	.audio_in   (audio_in),
	.audio_b    (nb_map165_audio_out_b)
);

//*****************************************************************************//
// Name   : Magic Floor                                                        //
// Mappers: 218                                                                //
// Status : Working                                                            //
// Notes  : Appears unused in modern packs?                                    //
// Games  : Magic Floor                                                        //
//*****************************************************************************//
Mapper218 map218(
	.clk        (clk),
	.ce         (ce),
	.enable     (me[218]),
	.flags      (flags),
	.prg_ain    (prg_ain),
	.prg_aout_b (nb_map218_prg_addr_b),
	.prg_read   (prg_read),
	.prg_write  (prg_write),
	.prg_din    (prg_din),
	.prg_dout_b (nb_map218_prg_dout_b),
	.prg_allow_b(nb_map218_prg_allow_b),
	.chr_ain    (chr_ain),
	.chr_aout_b (nb_map218_chr_addr_b),
	.chr_read   (chr_read),
	.chr_allow_b(nb_map218_chr_allow_b),
	.vram_a10_b (nb_map218_vram_a10_b),
	.vram_ce_b  (nb_map218_vram_ce_b),
	.irq_b      (nb_map218_irq_b),
	.flags_out_b(nb_map218_flags_out_b),
	.audio_in   (audio_in),
	.audio_b    (nb_map218_audio_out_b)
);

//*****************************************************************************//
// Name   : Active Enterprises                                                 //
// Mappers: 228                                                                //
// Status : Working                                                            //
// Notes  :                                                                    //
// Games  : Cheetamen                                                          //
//*****************************************************************************//
Mapper228 map228(
	.clk        (clk),
	.ce         (ce),
	.enable     (me[228]),
	.flags      (flags),
	.prg_ain    (prg_ain),
	.prg_aout_b (nb_map228_prg_addr_b),
	.prg_read   (prg_read),
	.prg_write  (prg_write),
	.prg_din    (prg_din),
	.prg_dout_b (nb_map228_prg_dout_b),
	.prg_allow_b(nb_map228_prg_allow_b),
	.chr_ain    (chr_ain),
	.chr_aout_b (nb_map228_chr_addr_b),
	.chr_read   (chr_read),
	.chr_allow_b(nb_map228_chr_allow_b),
	.vram_a10_b (nb_map228_vram_a10_b),
	.vram_ce_b  (nb_map228_vram_ce_b),
	.irq_b      (nb_map228_irq_b),
	.flags_out_b(nb_map228_flags_out_b),
	.audio_in   (audio_in),
	.audio_b    (nb_map228_audio_out_b)
);

//*****************************************************************************//
// Name   : Maxi 15                                                            //
// Mappers: 234                                                                //
// Status : Needs Evaluation                                                   //
// Notes  : The fact that this mapper needs a different cpu data in concerns me//
//          either this indicates the mapper is not correctly written or that  //
//          the system itself is not behaving correctly.                       //
// Games  : Maxi-15 Pack (unl)                                                 //
//*****************************************************************************//
Mapper234 map234(
	.clk        (clk),
	.ce         (ce),
	.enable     (me[234]),
	.flags      (flags),
	.prg_ain    (prg_ain),
	.prg_aout_b (nb_map234_prg_addr_b),
	.prg_read   (prg_read),
	.prg_write  (prg_write),
	.prg_din    (prg_from_ram),
	.prg_dout_b (nb_map234_prg_dout_b),
	.prg_allow_b(nb_map234_prg_allow_b),
	.chr_ain    (chr_ain),
	.chr_aout_b (nb_map234_chr_addr_b),
	.chr_read   (chr_read),
	.chr_allow_b(nb_map234_chr_allow_b),
	.vram_a10_b (nb_map234_vram_a10_b),
	.vram_ce_b  (nb_map234_vram_ce_b),
	.irq_b      (nb_map234_irq_b),
	.flags_out_b(nb_map234_flags_out_b),
	.audio_in   (audio_in),
	.audio_b    (nb_map234_audio_out_b)
);

//*****************************************************************************//
// Name   : RAMBO1 (Tengen MMC3)                                               //
// Mappers: 64, 158                                                            //
// Status : Needs testing.  Irq might be slightly off.                         //
// Notes  : Consider merging with MMC3                                         //
// Games  : Rolling Thunder, Klax, Skull and Crossbones, Alien Syndrome (158)  //
//*****************************************************************************//
Rambo1 rambo1(
	.clk        (clk),
	.ce         (ce),
	.enable     (me[64] | me[158]),
	.flags      (flags),
	.prg_ain    (prg_ain),
	.prg_aout_b (nb_rambo1_prg_addr_b),
	.prg_read   (prg_read),
	.prg_write  (prg_write),
	.prg_din    (prg_din),
	.prg_dout_b (nb_rambo1_prg_dout_b),
	.prg_allow_b(nb_rambo1_prg_allow_b),
	.chr_ain    (chr_ain),
	.chr_aout_b (nb_rambo1_chr_addr_b),
	.chr_read   (chr_read),
	.chr_allow_b(nb_rambo1_chr_allow_b),
	.vram_a10_b (nb_rambo1_vram_a10_b),
	.vram_ce_b  (nb_rambo1_vram_ce_b),
	.irq_b      (nb_rambo1_irq_b),
	.flags_out_b(nb_rambo1_flags_out_b),
	.audio_in   (audio_in),
	.audio_b    (nb_rambo1_audio_out_b)
);

//*****************************************************************************//
// Name   : NesEvent                                                           //
// Mappers: 105                                                                //
// Status : Working                                                            //
// Notes  : This wraps the MMC1 mapper, consider merging more elegantly        //
// Games  : Nintendo World Championships 1990 (start hack)                     //
//*****************************************************************************//
NesEvent nesev(
	.clk        (clk),
	.ce         (ce),
	.enable     (me[105]),
	.flags      (flags),
	.prg_ain    (prg_ain),
	.prg_aout_b (nb_nesev_prg_addr_b),
	.prg_read   (prg_read),
	.prg_write  (prg_write),
	.prg_din    (prg_din),
	.prg_dout_b (nb_nesev_prg_dout_b),
	.prg_allow_b(nb_nesev_prg_allow_b),
	.chr_ain    (chr_ain),
	.chr_aout_b (nb_nesev_chr_addr_b),
	.chr_read   (chr_read),
	.chr_allow_b(nb_nesev_chr_allow_b),
	.vram_a10_b (nb_nesev_vram_a10_b),
	.vram_ce_b  (nb_nesev_vram_ce_b),
	.irq_b      (nb_nesev_irq_b),
	.flags_out_b(nb_nesev_flags_out_b),
	.audio_in   (audio_in),
	.audio_b    (nb_nesev_audio_out_b)
);


//*****************************************************************************//
// Name   : Konami VRC-1                                                       //
// Mappers: 75                                                                 //
// Status : Needs Evaluation                                                   //
// Notes  :                                                                    //
// Games  : King Kong 2, Exciting Boxing, Tetsuwan Atom                        //
//*****************************************************************************//
// VRC1 vrc1(
// 	.clk        (clk),
// 	.ce         (ce),
// 	.enable     (me[75]),
// 	.flags      (flags),
// 	.prg_ain    (prg_ain),
// 	.prg_aout_b (prg_addr_b),
// 	.prg_read   (prg_read),
// 	.prg_write  (prg_write),
// 	.prg_din    (prg_din),
// 	.prg_dout_b (prg_dout_b),
// 	.prg_allow_b(prg_allow_b),
// 	.chr_ain    (chr_ain),
// 	.chr_aout_b (chr_addr_b),
// 	.chr_read   (chr_read),
// 	.chr_allow_b(chr_allow_b),
// 	.vram_a10_b (vram_a10_b),
// 	.vram_ce_b  (vram_ce_b),
// 	.irq_b      (irq_b),
// 	.flags_out_b(flags_out_b),
// 	.audio_in   (audio_in),
// 	.audio_b    (audio_out_b)
// );

//*****************************************************************************//
// Name   : Konami VRC-3                                                       //
// Mappers: 73                                                                 //
// Status : Needs Evaluation                                                   //
// Notes  :                                                                    //
// Games  : Salamander (j)                                                     //
//*****************************************************************************//
// VRC3 vrc3(
// 	.clk        (clk),
// 	.ce         (ce),
// 	.enable     (me[73]),
// 	.flags      (flags),
// 	.prg_ain    (prg_ain),
// 	.prg_aout_b (prg_addr_b),
// 	.prg_read   (prg_read),
// 	.prg_write  (prg_write),
// 	.prg_din    (prg_din),
// 	.prg_dout_b (prg_dout_b),
// 	.prg_allow_b(prg_allow_b),
// 	.chr_ain    (chr_ain),
// 	.chr_aout_b (chr_addr_b),
// 	.chr_read   (chr_read),
// 	.chr_allow_b(chr_allow_b),
// 	.vram_a10_b (vram_a10_b),
// 	.vram_ce_b  (vram_ce_b),
// 	.irq_b      (irq_b),
// 	.flags_out_b(flags_out_b),
// 	.audio_in   (audio_in),
// 	.audio_b    (audio_out_b)
// );

//*****************************************************************************//
// Name   : Konami VRC2/4                                                      //
// Mappers: 21, 22, 23, 25, 27 (pirate of 23)                                  //
// Status : Needs Evaluation                                                   //
// Notes  :                                                                    //
// Games  : Wai Wai World 2, Twinbee 3, Contra (j), Gradius II (j)             //
//*****************************************************************************//
// VRC24 vrc24(
// 	.clk        (clk),
// 	.ce         (ce),
// 	.enable     (me[21] | me[22] | me[23] | me[25] | me[27]),
// 	.flags      (flags),
// 	.prg_ain    (prg_ain),
// 	.prg_aout_b (prg_addr_b),
// 	.prg_read   (prg_read),
// 	.prg_write  (prg_write),
// 	.prg_din    (prg_din),
// 	.prg_dout_b (prg_dout_b),
// 	.prg_allow_b(prg_allow_b),
// 	.chr_ain    (chr_ain),
// 	.chr_aout_b (chr_addr_b),
// 	.chr_read   (chr_read),
// 	.chr_allow_b(chr_allow_b),
// 	.vram_a10_b (vram_a10_b),
// 	.vram_ce_b  (vram_ce_b),
// 	.irq_b      (irq_b),
// 	.flags_out_b(flags_out_b),
// 	.audio_in   (audio_in),
// 	.audio_b    (audio_out_b)
// );

//*****************************************************************************//
// Name   : Konami VRC-6                                                       //
// Mappers: 24, 26                                                             //
// Status : Working. Audio needs evaluation. Startup instability.              //
// Notes  : External audio needs to be mixed correctly.                        //
// Games  : Akamajou Densetsu, Esper Dream 2, Mouryou Senki Madara             //
//*****************************************************************************//
// VRC6 vrc6(
// 	.clk        (clk),
// 	.ce         (ce),
// 	.enable     (me[24] | me[26]),
// 	.flags      (flags),
// 	.prg_ain    (prg_ain),
// 	.prg_aout_b (prg_addr_b),
// 	.prg_read   (prg_read),
// 	.prg_write  (prg_write),
// 	.prg_din    (prg_din),
// 	.prg_dout_b (prg_dout_b),
// 	.prg_allow_b(prg_allow_b),
// 	.chr_ain    (chr_ain),
// 	.chr_aout_b (chr_addr_b),
// 	.chr_read   (chr_read),
// 	.chr_allow_b(chr_allow_b),
// 	.vram_a10_b (vram_a10_b),
// 	.vram_ce_b  (vram_ce_b),
// 	.irq_b      (irq_b),
// 	.flags_out_b(flags_out_b),
// 	.audio_in   (vrc6_audio),
// 	.audio_b    (audio_out_b)
// );

//*****************************************************************************//
// Name   : Konami VRC-7                                                       //
// Mappers: 85                                                                 //
// Status : Working.                                                           //
// Notes  : Audio mixing needs evaluation                                      //
// Games  : Lagrange Point, Tiny Toon Aventures 2 (j)                          //
//*****************************************************************************//
// VRC7 vrc7(
// 	.clk        (clk),
// 	.ce         (ce),
// 	.enable     (me[85]),
// 	.flags      (flags),
// 	.prg_ain    (prg_ain),
// 	.prg_aout_b (prg_addr_b),
// 	.prg_read   (prg_read),
// 	.prg_write  (prg_write),
// 	.prg_din    (prg_din),
// 	.prg_dout_b (prg_dout_b),
// 	.prg_allow_b(prg_allow_b),
// 	.chr_ain    (chr_ain),
// 	.chr_aout_b (chr_addr_b),
// 	.chr_read   (chr_read),
// 	.chr_allow_b(chr_allow_b),
// 	.vram_a10_b (vram_a10_b),
// 	.vram_ce_b  (vram_ce_b),
// 	.irq_b      (irq_b),
// 	.flags_out_b(flags_out_b),
// 	.audio_in   (vrc7_audio),
// 	.audio_b    (audio_out_b)
// );

//*****************************************************************************//
// Name   : Namco 163                                                          //
// Mappers: 19, 210                                                            //
// Status : Needs Evaluation                                                   //
// Notes  : This mapper requires submappers for correct operation              //
// Games  : Digital Devil Story, Battle Fleet, Famista                         //
//*****************************************************************************//
N163 n163(
	.clk        (clk),
	.ce         (ce),
	.enable     (me[210] | me[19]),
	.flags      (flags),
	.prg_ain    (prg_ain),
	.prg_aout_b (nb_n163_prg_addr_b),
	.prg_read   (prg_read),
	.prg_write  (prg_write),
	.prg_din    (prg_din),
	.prg_dout_b (nb_n163_prg_dout_b),
	.prg_allow_b(nb_n163_prg_allow_b),
	.chr_ain    (chr_ain),
	.chr_aout_b (nb_n163_chr_addr_b),
	.chr_read   (chr_read),
	.chr_allow_b(nb_n163_chr_allow_b),
	.vram_a10_b (nb_n163_vram_a10_b),
	.vram_ce_b  (nb_n163_vram_ce_b),
	.irq_b      (nb_n163_irq_b),
	.flags_out_b(nb_n163_flags_out_b),
	.audio_in   (n163_audio),
	.audio_b    (nb_n163_audio_out_b),
	// Special ports
	.audio_dout	(n163_data)
);

//*****************************************************************************//
// Name   : Waixing 162                                                        //
// Mappers: 162                                                                //
// Status : Working                                                            //
// Notes  :                                                                    //
// Games  : Zelda - San Shen Zhi Li                                            //
//*****************************************************************************//
Mapper162 map162(
	.clk        (clk),
	.ce         (ce),
	.enable     (me[162]),
	.flags      (flags),
	.prg_ain    (prg_ain),
	.prg_aout_b (nb_map162_prg_addr_b),
	.prg_read   (prg_read),
	.prg_write  (prg_write),
	.prg_din    (prg_din),
	.prg_dout_b (nb_map162_prg_dout_b),
	.prg_allow_b(nb_map162_prg_allow_b),
	.chr_ain    (chr_ain),
	.chr_aout_b (nb_map162_chr_addr_b),
	.chr_read   (chr_read),
	.chr_allow_b(nb_map162_chr_allow_b),
	.vram_a10_b (nb_map162_vram_a10_b),
	.vram_ce_b  (nb_map162_vram_ce_b),
	.irq_b      (nb_map162_irq_b),
	.flags_out_b(nb_map162_flags_out_b),
	.audio_in   (audio_in),
	.audio_b    (nb_map162_audio_out_b)
);

//*****************************************************************************//
// Name   : Nanjing 163                                                        //
// Mappers: 163                                                                //
// Status : Working                                                            //
// Notes  :                                                                    //
// Games  : Final Fantasy VII (163), Pokemon Yellow (163)                      //
//*****************************************************************************//
Nanjing map163(
	.clk        (clk),
	.ce         (ce),
	.enable     (me[163]),
	.flags      (flags),
	.prg_ain    (prg_ain),
	.prg_aout_b (nb_map163_prg_addr_b),
	.prg_read   (prg_read),
	.prg_write  (prg_write),
	.prg_din    (prg_din),
	.prg_dout_b (nb_map163_prg_dout_b),
	.prg_allow_b(nb_map163_prg_allow_b),
	.chr_ain    (chr_ain),
	.chr_aout_b (nb_map163_chr_addr_b),
	.chr_read   (chr_read),
	.chr_allow_b(nb_map163_chr_allow_b),
	.vram_a10_b (nb_map163_vram_a10_b),
	.vram_ce_b  (nb_map163_vram_ce_b),
	.irq_b      (nb_map163_irq_b),
	.flags_out_b(nb_map163_flags_out_b),
	.audio_in   (audio_in),
	.audio_b    (nb_map163_audio_out_b),
	// Special Ports
	.ppu_ce     (ppu_ce),
	.ppuflags   (ppuflags)
);


//*****************************************************************************//
// Name   : Waixing 164                                                        //
// Mappers: 164                                                                //
// Status : Working                                                            //
// Notes  :                                                                    //
// Games  : Final Fantasy V                                                    //
//*****************************************************************************//
Mapper164 map164(
	.clk        (clk),
	.ce         (ce),
	.enable     (me[164]),
	.flags      (flags),
	.prg_ain    (prg_ain),
	.prg_aout_b (nb_map164_prg_addr_b),
	.prg_read   (prg_read),
	.prg_write  (prg_write),
	.prg_din    (prg_din),
	.prg_dout_b (nb_map164_prg_dout_b),
	.prg_allow_b(nb_map164_prg_allow_b),
	.chr_ain    (chr_ain),
	.chr_aout_b (nb_map164_chr_addr_b),
	.chr_read   (chr_read),
	.chr_allow_b(nb_map164_chr_allow_b),
	.vram_a10_b (nb_map164_vram_a10_b),
	.vram_ce_b  (nb_map164_vram_ce_b),
	.irq_b      (nb_map164_irq_b),
	.flags_out_b(nb_map164_flags_out_b),
	.audio_in   (audio_in),
	.audio_b    (nb_map164_audio_out_b)
);

//*****************************************************************************//
// Name   : Sachen 8259                                                        //
// Mappers: 137, 138, 139, 141, 150, 243                                       //
// Status : Working                                                            //
// Notes  :                                                                    //
// Games  : The Great Wall (137), Silver Eagle (138), Hell Fighter (139),      //
//          Super Cart 6 - 6 in 1(141), Strategist (150), Poker III (243)      //
//*****************************************************************************//
Sachen8259 sachen(
	.clk        (clk),
	.ce         (ce),
	.enable     (me[137] | me[138] | me[139] | me[141] | me[150] | me[243]),
	.flags      (flags),
	.prg_ain    (prg_ain),
	.prg_aout_b (nb_sachen_prg_addr_b),
	.prg_read   (prg_read),
	.prg_write  (prg_write),
	.prg_din    (prg_din),
	.prg_dout_b (nb_sachen_prg_dout_b),
	.prg_allow_b(nb_sachen_prg_allow_b),
	.chr_ain    (chr_ain),
	.chr_aout_b (nb_sachen_chr_addr_b),
	.chr_read   (chr_read),
	.chr_allow_b(nb_sachen_chr_allow_b),
	.vram_a10_b (nb_sachen_vram_a10_b),
	.vram_ce_b  (nb_sachen_vram_ce_b),
	.irq_b      (nb_sachen_irq_b),
	.flags_out_b(nb_sachen_flags_out_b),
	.audio_in   (audio_in),
	.audio_b    (nb_sachen_audio_out_b)
);

//*****************************************************************************//
// Name   : Sachen JV001                                                       //
// Mappers: 136, 147, 132, 173, 172, 36                                        //
// Status : Working                                                            //
// Notes  : 147 only tested with 60 pin version                                //
// Games  : Wei Lai Xiao Zi (136), Chinese Kungfu (147), Creatom (132),        //
//          F-15 City War (173), Mahjong Block (172), Strike Wolf (36)         //
//*****************************************************************************//
SachenJV001 sachenj(
	.clk        (clk),
	.ce         (ce),
	.enable     (me[136] | me[147] | me[132] | me[173] | me[172] | me[36]),
	.flags      (flags),
	.prg_ain    (prg_ain),
	.prg_aout_b (nb_sachenj_prg_addr_b),
	.prg_read   (prg_read),
	.prg_write  (prg_write),
	.prg_din    (prg_din),
	.prg_dout_b (nb_sachenj_prg_dout_b),
	.prg_allow_b(nb_sachenj_prg_allow_b),
	.chr_ain    (chr_ain),
	.chr_aout_b (nb_sachenj_chr_addr_b),
	.chr_read   (chr_read),
	.chr_allow_b(nb_sachenj_chr_allow_b),
	.vram_a10_b (nb_sachenj_vram_a10_b),
	.vram_ce_b  (nb_sachenj_vram_ce_b),
	.irq_b      (nb_sachenj_irq_b),
	.flags_out_b(nb_sachenj_flags_out_b),
	.audio_in   (audio_in),
	.audio_b    (nb_sachenj_audio_out_b)
);

//*****************************************************************************//
// Name   : Sachen NROM                                                        //
// Mappers: 143                                                                //
// Status : Working                                                            //
// Notes  :                                                                    //
// Games  : Dancing Blocks, Magical Mathematics                                //
//*****************************************************************************//
SachenNROM sachenn(
	.clk        (clk),
	.ce         (ce),
	.enable     (me[143]),
	.flags      (flags),
	.prg_ain    (prg_ain),
	.prg_aout_b (nb_sachenn_prg_addr_b),
	.prg_read   (prg_read),
	.prg_write  (prg_write),
	.prg_din    (prg_din),
	.prg_dout_b (nb_sachenn_prg_dout_b),
	.prg_allow_b(nb_sachenn_prg_allow_b),
	.chr_ain    (chr_ain),
	.chr_aout_b (nb_sachenn_chr_addr_b),
	.chr_read   (chr_read),
	.chr_allow_b(nb_sachenn_chr_allow_b),
	.vram_a10_b (nb_sachenn_vram_a10_b),
	.vram_ce_b  (nb_sachenn_vram_ce_b),
	.irq_b      (nb_sachenn_irq_b),
	.flags_out_b(nb_sachenn_flags_out_b),
	.audio_in   (audio_in),
	.audio_b    (nb_sachenn_audio_out_b)
);

//*****************************************************************************//
// Name   : JY Company                                                         //
// Mappers: 90, 209, 211, 35                                                   //
// Status : Working (needs testing)                                            //
// Notes  : 211 and 35 can be considered duplicates.                           //
// Games  : Aladdin (90), Power Rangers 3 (209), Warioland II (35),            //
//          Tiny Toon Adventures 6 (211)                                       //
//*****************************************************************************//
JYCompany jycompany(
	.clk        (clk),
	.ce         (ce),
	.enable     (me[90] | me[209] | me[211] | me[35]),
	.flags      (flags),
	.prg_ain    (prg_ain),
	.prg_aout_b (nb_jycompany_prg_addr_b),
	.prg_read   (prg_read),
	.prg_write  (prg_write),
	.prg_din    (prg_din),
	.prg_dout_b (nb_jycompany_prg_dout_b),
	.prg_allow_b(nb_jycompany_prg_allow_b),
	.chr_ain    (chr_ain),
	.chr_aout_b (nb_jycompany_chr_addr_b),
	.chr_read   (chr_read),
	.chr_allow_b(nb_jycompany_chr_allow_b),
	.vram_a10_b (nb_jycompany_vram_a10_b),
	.vram_ce_b  (nb_jycompany_vram_ce_b),
	.irq_b      (nb_jycompany_irq_b),
	.flags_out_b(nb_jycompany_flags_out_b),
	.audio_in   (audio_in),
	.audio_b    (nb_jycompany_audio_out_b),
	// Special ports
	.ppu_ce     (ppu_ce)
);

//*****************************************************************************//
// Name   : Mapper 91                                                          //
// Mappers: 91                                                                 //
// Status : Working (Needs testing)                                            //
// Notes  :                                                                    //
// Games  : Street Fighter 3, Mortal Kombat II, Dragon Ball Z 2,               //
//          Mario & Sonic 2,  Mario Rider,                                     //
//          1995 Super HIK 4-in-1 (JY-016), 1995 Super HiK 4-in-1 (JY-017)     //
//*****************************************************************************//
Mapper91 map91(
	.clk        (clk),
	.ce         (ce),
	.enable     (me[91]),
	.flags      (flags),
	.prg_ain    (prg_ain),
	.prg_aout_b (nb_map91_prg_addr_b),
	.prg_read   (prg_read),
	.prg_write  (prg_write),
	.prg_din    (prg_din),
	.prg_dout_b (nb_map91_prg_dout_b),
	.prg_allow_b(nb_map91_prg_allow_b),
	.chr_ain    (chr_ain),
	.chr_aout_b (nb_map91_chr_addr_b),
	.chr_read   (chr_read),
	.chr_allow_b(nb_map91_chr_allow_b),
	.vram_a10_b (nb_map91_vram_a10_b),
	.vram_ce_b  (nb_map91_vram_ce_b),
	.irq_b      (nb_map91_irq_b),
	.flags_out_b(nb_map91_flags_out_b),
	.audio_in   (audio_in),
	.audio_b    (nb_map91_audio_out_b),
	.chr_ain_o  (chr_ain)
);

//*****************************************************************************//
// Name   : Mapper 225                                                         //
// Mappers: 225, 255                                                           //
// Status : Working                                                            //
// Notes  : Defining 225 as with 74'670 (4-nybble RAM) and 255 as without      //
// Games  : 64-in-1 (225), 110-in-1 (255 - with glitched menu selection)       //
//*****************************************************************************//
Mapper225 map225(
	.clk        (clk),
	.ce         (ce),
	.enable     (me[225] | me[255]),
	.flags      (flags),
	.prg_ain    (prg_ain),
	.prg_aout_b (nb_map225_prg_addr_b),
	.prg_read   (prg_read),
	.prg_write  (prg_write),
	.prg_din    (prg_din),
	.prg_dout_b (nb_map225_prg_dout_b),
	.prg_allow_b(nb_map225_prg_allow_b),
	.chr_ain    (chr_ain),
	.chr_aout_b (nb_map225_chr_addr_b),
	.chr_read   (chr_read),
	.chr_allow_b(nb_map225_chr_allow_b),
	.vram_a10_b (nb_map225_vram_a10_b),
	.vram_ce_b  (nb_map225_vram_ce_b),
	.irq_b      (nb_map225_irq_b),
	.flags_out_b(nb_map225_flags_out_b),
	.audio_in   (audio_in),
	.audio_b    (nb_map225_audio_out_b)
);

//*****************************************************************************//
// Name   : FDS                                                                //
// Mappers: 20                                                                 //
// Status : Audio good. Drive mechanics okay, but dated. Needs rewrite.        //
// Notes  : Uses a special wire to signal disk changes. Req. modified BIOS.    //
// Games  : Bio Miracle for audio, Various unlicensed games for compatibility. //
//*****************************************************************************//
wire [1:0] fds_diskside_auto;
// MapperFDS mapfds(
// 	.clk        (clk),
// 	.ce         (ce),
// 	.enable     (me[20]),
// 	.flags      (flags),
// 	.prg_ain    (prg_ain),
// 	.prg_aout_b (prg_addr_b),
// 	.prg_read   (prg_read),
// 	.prg_write  (prg_write),
// 	.prg_din    (prg_din),
// 	.prg_dout_b (prg_dout_b),
// 	.prg_allow_b(prg_allow_b),
// 	.chr_ain    (chr_ain),
// 	.chr_aout_b (chr_addr_b),
// 	.chr_read   (chr_read),
// 	.chr_allow_b(chr_allow_b),
// 	.vram_a10_b (vram_a10_b),
// 	.vram_ce_b  (vram_ce_b),
// 	.irq_b      (irq_b),
// 	.flags_out_b(flags_out_b),
// 	.audio_in   (fds_audio),
// 	.audio_b    (audio_out_b),
// 	// Special ports
// 	.audio_dout	(fds_data),
// 	.diskside_auto_b (fds_diskside_auto),
// 	.diskside   (diskside),
// 	.fds_busy   (fds_busy),
// 	.fds_eject  (fds_eject)
// );

//*****************************************************************************//
// Name   : Mapper 31                                                          //
// Mappers: 31 and NSF Player                                                  //
// Status : Testing                                                            //
// Notes  : Uses Mapper 31.15 (submapper) for NSF Player; NSF 1.0 only         //
// Games  : Famicompo Pico 2014, NSF 1.0                                       //
//*****************************************************************************//
wire [5:0] exp_audioe;
NSF nsfplayer(
	.clk        (clk),
	.ce         (ce),
	.enable     (me[31]),
	.flags      (flags),
	.prg_ain    (prg_ain),
	.prg_aout_b (nb_nsfplayer_prg_addr_b),
	.prg_read   (prg_read),
	.prg_write  (prg_write),
	.prg_din    (prg_din),
	.prg_dout_b (nb_nsfplayer_prg_dout_b),
	.prg_allow_b(nb_nsfplayer_prg_allow_b),
	.chr_ain    (chr_ain),
	.chr_aout_b (nb_nsfplayer_chr_addr_b),
	.chr_read   (chr_read),
	.chr_allow_b(nb_nsfplayer_chr_allow_b),
	.vram_a10_b (nb_nsfplayer_vram_a10_b),
	.vram_ce_b  (nb_nsfplayer_vram_ce_b),
	.irq_b      (nb_nsfplayer_irq_b),
	.flags_out_b(nb_nsfplayer_flags_out_b),
	.audio_in   (exp_audioe[5] ? ss5b_audio :
	             exp_audioe[4] ? n163_audio :
	             exp_audioe[3] ? mmc5_audio :
	             exp_audioe[2] ? fds_audio  :
	             exp_audioe[1] ? vrc7_audio :
	             exp_audioe[0] ? vrc6_audio :
					 audio_in),
	.exp_audioe (exp_audioe),  // Expansion Enabled (0x0=None, 0x1=VRC6, 0x2=VRC7, 0x4=FDS, 0x8=MMC5, 0x10=N163, 0x20=SS5B
	.audio_b    (nb_nsfplayer_audio_out_b),
	.fds_din    (fds_data)
);

wire [15:0] ss5b_audio;
SS5b_mixed snd_5bm (
	.clk(clk),
	.ce(ce),
	.enable(me[69] | (me[31] && exp_audioe[5])),
	.wren(prg_write),
	.addr_in(prg_ain),
	.data_in(prg_din),
	.audio_in(audio_in),
	.audio_out(ss5b_audio)
);

wire [15:0] n163_audio;
wire [7:0] n163_data;
namco163_mixed snd_n163 (
	.clk(clk),
	.ce(ce),
	.submapper(flags[24:21]),
	.enable(me[19] | (me[31] && exp_audioe[4])),
	.wren(prg_write),
	.addr_in(prg_ain),
	.data_in(prg_din),
	.data_out(n163_data),
	.audio_in(audio_in),
	.audio_out(n163_audio)
);

wire [15:0] mmc5_audio;
wire [7:0] mmc5_data;
mmc5_mixed snd_mmc5 (
	.clk(clk),
	.ce(ce),
	.enable(me[5] | (me[31] && exp_audioe[3])),
	.wren(prg_write),
	.rden(prg_read),
	.addr_in(prg_ain),
	.data_in(prg_din),
	.data_out(mmc5_data),
	.audio_in(audio_in),
	.audio_out(mmc5_audio)
);

wire [15:0] fds_audio;
wire [7:0] fds_data;
// fds_mixed snd_fds (
// 	.clk(clk),
// 	.ce(ce),
// 	.enable(me[20] | (me[31] && exp_audioe[2])),
// 	.wren(prg_write),
// 	.addr_in(prg_ain),
// 	.data_in(prg_din),
// 	.data_out(fds_data),
// 	.audio_in(audio_in),
// 	.audio_out(fds_audio)
// );

wire [15:0] vrc7_audio;
// vrc7_mixed snd_vrc7 (
// 	.clk(clk),
// 	.ce(ce),
// 	.enable(me[85] | (me[31] && exp_audioe[1])),
// 	.wren(prg_write),
// 	.addr_in(prg_ain),
// 	.data_in(prg_din),
// 	.audio_in(audio_in),
// 	.audio_out(vrc7_audio)
// );

wire [15:0] vrc6_audio;
// vrc6_mixed snd_vrc6 (
// 	.clk(clk),
// 	.ce(ce),
// 	.enable(me[24] | me[26] | (me[31] && exp_audioe[0])),
// 	.wren(prg_write),
// 	.addr_invert(me[26]),
// 	.addr_in(prg_ain),
// 	.data_in(prg_din),
// 	.audio_in(audio_in),
// 	.audio_out(vrc6_audio)
// );


reg [6:0] prg_mask;
reg [6:0] chr_mask;
reg [1023:0] me;

always @* begin
	me = 1023'd0;
	me[{flags[18:17],flags[7:0]}] = 1'b1;

	case(flags[10:8])
		0: prg_mask = 7'b0000000;
		1: prg_mask = 7'b0000001;
		2: prg_mask = 7'b0000011;
		3: prg_mask = 7'b0000111;
		4: prg_mask = 7'b0001111;
		5: prg_mask = 7'b0011111;
		6: prg_mask = 7'b0111111;
		7: prg_mask = 7'b1111111;
	endcase

	case(flags[13:11])
		0: chr_mask = 7'b0000000;
		1: chr_mask = 7'b0000001;
		2: chr_mask = 7'b0000011;
		3: chr_mask = 7'b0000111;
		4: chr_mask = 7'b0001111;
		5: chr_mask = 7'b0011111;
		6: chr_mask = 7'b0111111;
		7: chr_mask = 7'b1111111;
	endcase

	// Mapper output to cart pins
	{prg_aout,   prg_allow,   chr_aout,   vram_a10,   vram_ce,   chr_allow,   prg_dout,   chr_dout,   irq,   audio} =
	{prg_addr_b, prg_allow_b, chr_addr_b, vram_a10_b, vram_ce_b, chr_allow_b, prg_dout_b, chr_dout_b, irq_b, audio_out_b};

	// Currently only used for Mapper 16 EEPROM. Expand if needed.
	{mapper_addr, mapper_data_out, mapper_prg_write, mapper_ovr} = (me[159] | me[16]) ?
		{map16_mapper_addr, map16_data_out, map16_prg_write, map16_ovr} : 28'd0;

	{diskside_auto} = {fds_diskside_auto};

	// Behavior helper flags
	{prg_conflict, prg_bus_write, has_chr_dout} = {flags_out_b[2], flags_out_b[1], flags_out_b[0]};

	// Address translation for SDRAM
	if (prg_aout[21] == 1'b0)
		prg_aout[20:0] = {prg_aout[20:14] & prg_mask, prg_aout[13:0]};

	if (chr_aout[21:20] == 2'b10)
		chr_aout[19:0] = {chr_aout[19:13] & chr_mask, chr_aout[12:0]};

	// Remap the CHR address into VRAM, if needed.
	chr_aout = vram_ce ? {11'b11_0000_0000_0, vram_a10, chr_ain[9:0]} : chr_aout;
	prg_aout = (prg_ain < 'h2000) ? {11'b11_1000_0000_0, prg_ain[10:0]} : prg_aout;
	prg_allow = prg_allow || (prg_ain < 'h2000);
end

endmodule
