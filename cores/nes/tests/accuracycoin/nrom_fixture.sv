// Simulation-only NROM-256 cartridge and address translation.
// CPU, APU, DMA, bus, PPU and dividers are the production NES RTL.
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

always @* begin
 prg_aout=prg_ain<16'h2000 ? 22'h380000|{11'd0,prg_ain[10:0]} : {7'd0,prg_ain[14:0]};
 prg_allow=prg_ain<16'h2000 || (prg_ain[15] && !prg_write);
 prg_dout=8'hff; prg_bus_write=0; prg_conflict=0;
 vram_a10=flags[14] ? chr_ain[10] : chr_ain[11]; vram_ce=chr_ain[13];
 chr_aout=vram_ce ? 22'h300000|{11'd0,vram_a10,chr_ain[9:0]} : 22'h200000|{9'd0,chr_ain[12:0]};
 chr_allow=flags[15]; chr_dout=0; has_chr_dout=0;
 mapper_addr=0; mapper_data_out=0; mapper_prg_write=0; mapper_ovr=0; irq=0;
 audio={1'b0,audio_in[15:1]}; diskside_auto=0;
end
endmodule
