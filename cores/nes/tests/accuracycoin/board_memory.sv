// Real production NES and shared SDRAM controller; chip pins are driven by board_main.cpp.
module NESBoard(
	input         clk,
	input         menu_pause,
	input         reset_nes,
	input         cold_reset,
	input   [1:0] sys_type,
	output  [2:0] nes_div,
	input  [63:0] mapper_flags,
	output [15:0] sample,         // sample generated from APU
	output  [5:0] color /* verilator public */,          // pixel generated from PPU
	output  [2:0] joypad_out,     // Set to 1 to strobe joypads. Then set to zero to keep the value (bit0)
	output  [1:0] joypad_clock,   // Set to 1 for each joypad to clock it.
	input   [4:0] joypad1_data,   // Port1
	input   [4:0] joypad2_data,   // Port2
	input         fds_busy,       // FDS Disk Swap Busy
	input         fds_eject,      // FDS Disk Swap Pause
	output  [1:0] diskside_req,
	input   [1:0] diskside,
	input   [4:0] audio_channels, // Enabled audio channels

	// Access signals for the SDRAM.
	output [21:0] cpumem_addr,
	output        cpumem_read,
	output        cpumem_write,
	output  [7:0] cpumem_dout,
	input   [7:0] cpumem_din,
	output [21:0] ppumem_addr,
	output        ppumem_read,
	output        ppumem_write,
	output  [7:0] ppumem_dout,
	input   [7:0] ppumem_din,

	// Override for BRAM
	output [17:0] bram_addr,      // address to access
	input   [7:0] bram_din,       // Data from BRAM
	output  [7:0] bram_dout,
	output        bram_write,     // is a write operation
	output        bram_override,

	output  [8:0] cycle/* verilator public */,
	output  [8:0] scanline/* verilator public */,
	input         int_audio,
	input         ext_audio,
	output        apu_ce,
	input         gg,
	input [128:0] gg_code,
	output        gg_avail,
	input         gg_reset,
	output  [2:0] emphasis,
	output        save_written,
input fclk, input [31:0] ram_din,input ram_drive, output [31:0] ram_dout, output [10:0] ram_addr,output [1:0] ram_bank,output [3:0] ram_cmd,ram_mask,output ram_busy,output dbg_ppu_sample,output [7:0] dbg_ppu_din
);
wire [7:0] real_cpu_din,real_ppu_din;wire busy,clkref;tri [31:0] dq;assign dq=ram_drive?ram_din:32'bz;assign ram_dout=dq;assign ram_busy=busy;
assign dbg_ppu_sample=core.ppu_ce && core.ppu.is_rendering && core.ppu.cycle[0] && core.ppu.cycle<336;assign dbg_ppu_din=real_ppu_din;
NES core(.clk(clk),.menu_pause(menu_pause),.reset_nes(reset_nes || busy),.cold_reset(cold_reset || busy),.sys_type(sys_type),.nes_div(nes_div),.mapper_flags(mapper_flags),.sample(sample),.color(color),.joypad_out(joypad_out),.joypad_clock(joypad_clock),.joypad1_data(joypad1_data),.joypad2_data(joypad2_data),.fds_busy(fds_busy),.fds_eject(fds_eject),.diskside_req(diskside_req),.diskside(diskside),.audio_channels(audio_channels),.cpumem_addr(cpumem_addr),.cpumem_read(cpumem_read),.cpumem_write(cpumem_write),.cpumem_dout(cpumem_dout),.cpumem_din(real_cpu_din),.ppumem_addr(ppumem_addr),.ppumem_read(ppumem_read),.ppumem_write(ppumem_write),.ppumem_dout(ppumem_dout),.ppumem_din(real_ppu_din),.bram_addr(bram_addr),.bram_din(bram_din),.bram_dout(bram_dout),.bram_write(bram_write),.bram_override(bram_override),.cycle(cycle),.scanline(scanline),.int_audio(int_audio),.ext_audio(ext_audio),.apu_ce(apu_ce),.gg(gg),.gg_code(gg_code),.gg_avail(gg_avail),.gg_reset(gg_reset),.emphasis(emphasis),.save_written(save_written));
reg refclk=0;always @(posedge clk) if(reset_nes)refclk<=0;else refclk<=~refclk;assign clkref=refclk;
sdram_nes ram(.clk(fclk),.clkref(clkref),.resetn(!reset_nes),.busy(busy),.SDRAM_DQ(dq),.SDRAM_A(ram_addr),.SDRAM_BA(ram_bank),.SDRAM_DQM(ram_mask),.SDRAM_nCS(ram_cmd[3]),.SDRAM_nRAS(ram_cmd[2]),.SDRAM_nCAS(ram_cmd[1]),.SDRAM_nWE(ram_cmd[0]),.addrA(ppumem_addr),.weA(ppumem_write),.dinA(ppumem_dout),.oeA(ppumem_read),.doutA(real_ppu_din),.addrB(cpumem_addr),.weB(cpumem_write),.dinB(cpumem_dout),.oeB(cpumem_read),.doutB(real_cpu_din),.rv_addr(21'd0),.rv_din(16'd0),.rv_ds(2'd0),.rv_req(1'b0),.rv_we(1'b0),.bg_enable(1'b0),.bg_req(1'b0),.bg_addr(20'd0));
endmodule
