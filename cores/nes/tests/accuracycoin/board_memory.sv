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
input loader_active,input loader_write,input [21:0] loader_addr,input [7:0] loader_data,
output dbg_ppu_enabled, output dbg_ppu_ce,output [4:0] dbg_div_cpu,output [2:0] dbg_div_ppu,
input fclk, input [31:0] ram_din,input ram_drive, output [31:0] ram_dout, output [10:0] ram_addr,output [1:0] ram_bank,output [3:0] ram_cmd,ram_mask,output ram_busy,output dbg_ppu_sample,output [7:0] dbg_ppu_din
);
wire [7:0] real_cpu_din,real_ppu_din;
reg actual_paused=0,pause_ref;reg [1:0] idle_sync;wire bg_idle;
reg bg_req=0;wire bg_ack;reg [19:0] bg_addr=0;reg [11:0] bg_gap=0;
always @(posedge fclk)begin
 if(cold_reset)begin bg_req<=0;bg_addr<=0;bg_gap<=0;end
 else if(menu_pause && bg_req==bg_ack)begin
  if(bg_gap==0)begin bg_req<=~bg_req;bg_addr<=bg_addr+1280;end
  bg_gap<=bg_gap+1'b1;
 end
end
always @(posedge clk)begin
 if(cold_reset)begin actual_paused<=0;pause_ref<=0;idle_sync<=0;end
 else begin
 idle_sync<={idle_sync[0],bg_idle};
 if(menu_pause)begin if(!actual_paused)pause_ref<=clkref;actual_paused<=1;end
 else if(idle_sync[1] && clkref==pause_ref)actual_paused<=0;
 end
end
wire busy,clkref;tri [31:0] dq;assign dq=ram_drive?ram_din:32'bz;assign ram_dout=dq;assign ram_busy=busy;
assign dbg_ppu_enabled=core.ppu.enable_playfield | core.ppu.enable_objects | core.ppu.vbl_enable;
assign dbg_ppu_ce=core.ppu_ce;assign dbg_div_cpu=core.div_cpu;assign dbg_div_ppu=core.div_ppu;
assign dbg_ppu_sample=core.ppu_ce && core.ppu.is_rendering && core.ppu.cycle[0] && core.ppu.cycle<336;assign dbg_ppu_din=real_ppu_din;
NES #(.MENU_PAUSE_SUPPORT(1)) core(.clk(clk),.menu_pause(actual_paused),.reset_nes(reset_nes || busy),.cold_reset(cold_reset || busy),.sys_type(sys_type),.nes_div(nes_div),.mapper_flags(mapper_flags),.sample(sample),.color(color),.joypad_out(joypad_out),.joypad_clock(joypad_clock),.joypad1_data(joypad1_data),.joypad2_data(joypad2_data),.fds_busy(fds_busy),.fds_eject(fds_eject),.diskside_req(diskside_req),.diskside(diskside),.audio_channels(audio_channels),.cpumem_addr(cpumem_addr),.cpumem_read(cpumem_read),.cpumem_write(cpumem_write),.cpumem_dout(cpumem_dout),.cpumem_din(real_cpu_din),.ppumem_addr(ppumem_addr),.ppumem_read(ppumem_read),.ppumem_write(ppumem_write),.ppumem_dout(ppumem_dout),.ppumem_din(real_ppu_din),.bram_addr(bram_addr),.bram_din(bram_din),.bram_dout(bram_dout),.bram_write(bram_write),.bram_override(bram_override),.cycle(cycle),.scanline(scanline),.int_audio(int_audio),.ext_audio(ext_audio),.apu_ce(apu_ce),.gg(gg),.gg_code(gg_code),.gg_avail(gg_avail),.gg_reset(gg_reset),.emphasis(emphasis),.save_written(save_written));
reg refclk=0,loading_r=0;
always @(posedge clk)begin
 loading_r<=loader_active;refclk<=~refclk;
 if(!loader_active && loading_r)refclk<=1;
 if(cold_reset)refclk<=0;
end
assign clkref=refclk;
sdram_nes #(.BACKGROUND(1)) ram(.clk(fclk),.clkref(clkref),.resetn(!cold_reset),.busy(busy),.SDRAM_DQ(dq),.SDRAM_A(ram_addr),.SDRAM_BA(ram_bank),.SDRAM_DQM(ram_mask),.SDRAM_nCS(ram_cmd[3]),.SDRAM_nRAS(ram_cmd[2]),.SDRAM_nCAS(ram_cmd[1]),.SDRAM_nWE(ram_cmd[0]),.addrA(ppumem_addr),.weA(ppumem_write),.dinA(ppumem_dout),.oeA(ppumem_read),.doutA(real_ppu_din),.addrB(loader_active?loader_addr:cpumem_addr),.weB(loader_write || cpumem_write),.dinB(loader_active?loader_data:cpumem_dout),.oeB(!loader_active && cpumem_read),.doutB(real_cpu_din),.rv_addr(21'd0),.rv_din(16'd0),.rv_ds(2'd0),.rv_req(1'b0),.rv_we(1'b0),.bg_enable(menu_pause),.bg_req(bg_req),.bg_addr(bg_addr),.bg_ack(bg_ack),.bg_idle(bg_idle));
endmodule
