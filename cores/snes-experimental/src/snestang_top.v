/* 
 * Top level for snestang
 * nand2mario, 2023.6
 */

//`define STEP_TRACE

`ifndef CONFIG_V
`error "config.v must be read before snestang_top.v"
`endif

import configPackage::*;

module snestang_top (
    input sys_clk,
    input s0,

    // UART
    input UART_RXD,
    output UART_TXD,

    // HDMI TX
    output       tmds_clk_p,
    output       tmds_clk_n,
    output [2:0] tmds_d_p,
    output [2:0] tmds_d_n,

    // LED
    output [7:0] led,

    // NANOBLAST storage links; shared BL616 menu owns both buses.
    output sd_clk,inout sd_cmd,input sd_dat0,output sd_dat1,sd_dat2,sd_dat3,
    output flash_spi_cs_n,input flash_spi_miso,output flash_spi_mosi,flash_spi_clk,
    output flash_spi_wp_n,flash_spi_hold_n,

    // MicroSD
    // output sd_clk,
    // inout  sd_cmd,      // MOSI
    // input  sd_dat0,     // MISO
    // output sd_dat1,
    // output sd_dat2,
    // output sd_dat3,

    // SPI flash
    // output flash_spi_cs_n,          // chip select
    // input flash_spi_miso,           // master in slave out
    // output flash_spi_mosi,          // mster out slave in
    // output flash_spi_clk,           // spi clock
    // output flash_spi_wp_n,          // write protect
    // output flash_spi_hold_n,        // hold operations

`ifdef CONTROLLER_SNES
    // snes controllers
    output joy1_strb,
    output joy1_clk,
    input joy1_data,
    output joy2_strb,
    output joy2_clk,
    input joy2_data,
`endif

`ifdef CONTROLLER_DS2
    // dualshock controllers
    output ds_clk,
    input ds_miso,
    output ds_mosi,
    output ds_cs,
    output ds_clk2,
    input ds_miso2,
    output ds_mosi2,
    output ds_cs2,
`endif

    // USB1 and USB2
`ifdef USB1
    inout usb1_dp,
    inout usb1_dn,
`endif
`ifdef USB2
    inout usb2_dp,
    inout usb2_dn,
`endif
    // SDRAM
    output O_sdram_clk,
    output O_sdram_cke,
    output O_sdram_cs_n,            // chip select
    output O_sdram_cas_n,           // columns address select
    output O_sdram_ras_n,           // row address select
    output O_sdram_wen_n,           // write enable
    inout [SDRAM_DATA_WIDTH-1:0] IO_sdram_dq,       // 31 bit bidirectional data bus
    output [SDRAM_ROW_WIDTH-1:0] O_sdram_addr,     // 11 bit multiplexed address bus
    output [SDRAM_DATA_WIDTH/8-1:0] O_sdram_dqm,       // 
    output [1:0] O_sdram_ba         // 4 banks
);

// Clock signals
wire mclk;                      // SNES master clock at 21.5054Mhz (~21.477)
wire fclk;                      // Fast clock for sdram for SDRAM
wire fclk_p;                    // 180-degree shifted fclk
wire clk27;                     // 27Mhz for hdmi clock generation
wire hclk5, hclk;               // 720p pixel clock at 74.25Mhz, and 5x high-speed

wire resetn,pixel_resetn,serializer_resetn,fast_resetn;
wire core_pll_lock,hdmi_pll_lock;
reg [15:0] resetcnt=16'hffff;
always @(posedge mclk)if(resetcnt!=0)resetcnt<=resetcnt-1'b1;
wire reset_ready=core_pll_lock && hdmi_pll_lock && resetcnt==0;
reset_release reset_main(.clk(mclk),.async_resetn(reset_ready),.resetn(resetn));
reset_release reset_fast(.clk(fclk),.async_resetn(reset_ready),.resetn(fast_resetn));
reset_release reset_pixel(.clk(hclk),.async_resetn(reset_ready),.resetn(pixel_resetn));
reset_release reset_serializer(.clk(hclk5),.async_resetn(reset_ready),.resetn(serializer_resetn));
wire pause;

// rPLL for Tang Nano 20K
`ifdef PLL_R

// Clocks for Nano 20K
assign clk27 = sys_clk;
gowin_pll_hdmi pll_hdmi (
    .clkin(sys_clk),            // 27 Mhz input
    .clkout(hclk5),.lock(hdmi_pll_lock) // 371.25Mhz
);

CLKDIV #(.DIV_MODE(5)) div5 (
    .CLKOUT(hclk),              // 74.25Mhz
    .HCLKIN(hclk5),
    .RESETN(resetn),
    .CALIB(1'b0)
);

gowin_pll_snes pll_snes (
    .clkin(sys_clk),
    .clkout(fclk),              // 86.4
    .clkoutp(fclk_p),           // 225-degrees shifted
    .clkoutd(mclk),.lock(core_pll_lock) // 21.6
);

`elsif VERILATOR
assign core_pll_lock=1'b1;assign hdmi_pll_lock=1'b1;
// Simulated clocks for verilator
reg [2:0] clk_cnt = 3'b0;       // 0 1 2 3 4 5
reg mclk_buf;                   // 0 0 0 1 1 1
assign fclk = clk_cnt[0];       // 0 1 0 1 0 1
assign mclk = mclk_buf;
always @(posedge sys_clk) begin
    clk_cnt <= clk_cnt + 3'b1; 
    if (clk_cnt == 3'd5) begin
        clk_cnt <= 0;
        mclk_buf <= 0;
    end
    if (clk_cnt == 3'd2)
        mclk_buf <= 1;
end

`else
// Mega 138K: mclk=21.5054, fclk=64.5161
// Primer 25K: mclk=21.4844, fclk=85.9375
gowin_pll_snes pll_snes (
    .clkout0(mclk),             // 21.4844
    .clkout1(fclk),
    .clkout2(fclk_p),
    .clkin(sys_clk)             // 50 Mhz input
);

// HDMI clocks
gowin_pll_27 pll_27 (
    .clkin(sys_clk),
    .clkout0(clk27)
);
gowin_pll_hdmi pll_hdmi (
    .clkin(clk27),              // 27 Mhz input
    .clkout0(hclk5), .clkout1(hclk)
);

`endif

wire [23:0] ROM_ADDR;
wire ROM_CE_N, ROM_OE_N, ROM_WE_N, ROM_WORD;
wire [15:0] ROM_D;
wire [15:0] ROM_Q;
assign      ROM_Q = (ROM_WORD || ~ROM_ADDR[0]) ? cpu_port0 : { cpu_port0[7:0], cpu_port0[15:8] };

wire [16:0] WRAM_ADDR;
wire        WRAM_CE_N;
wire        WRAM_OE_N;
wire        WRAM_RD_N;
wire        WRAM_WE_N;
wire  [7:0] WRAM_SD_Q = WRAM_ADDR[0] ? cpu_port1[15:8] : cpu_port1[7:0];
wire  [7:0] WRAM_Q;
wire  [7:0] WRAM_D;
wire        wram_rd = ~WRAM_CE_N & ~WRAM_RD_N;
wire        wram_wr = ~WRAM_CE_N & ~WRAM_WE_N;

wire [19:0] BSRAM_ADDR;
wire        BSRAM_CE_N;
wire        BSRAM_OE_N;
wire        BSRAM_WE_N;
wire        BSRAM_RD_N;
wire  [7:0] BSRAM_Q = bsram_dout;
wire  [7:0] BSRAM_D;

wire [15:0] VRAM1_ADDR;
wire        VRAM1_WE_N;
wire  [7:0] VRAM1_D, VRAM1_Q;
wire [15:0] VRAM2_ADDR;
wire        VRAM2_WE_N;
wire  [7:0] VRAM2_D, VRAM2_Q;
wire        VRAM_OE_N;

wire [15:0] ARAM_ADDR;
wire        ARAM_CE_N;
wire        ARAM_OE_N;
wire        ARAM_WE_N;
wire [15:0] aram_dout;
wire  [7:0] ARAM_Q = ARAM_ADDR[0] ? aram_dout[15:8] : aram_dout[7:0];
wire  [7:0] ARAM_D;
wire        aram_16 = 0;

wire BLEND = 1'b0;
wire PAL;
wire       dotclk  /*verilator public*/;
wire [14:0] rgb_out  /*verilator public*/;
wire [8:0] x_out /*verilator public*/, y_out /*verilator public*/;
wire       hblankn,vblankn;

wire [15:0] audio_l /*verilator public*/, audio_r /*verilator public*/;
wire audio_ready /*verilator public*/;
wire audio_en /*XXX synthesis syn_keep=1 */;

wire snes_joy_strb;
wire snes_joy1_clk, snes_joy2_clk;
wire [1:0] snes_joy1_di, snes_joy2_di;

// OR together when both SNES and DS2 controllers are connected (right now only nano20k supports both simultaneously)
wire [11:0] joy1_btns_ds2, joy2_btns_ds2;
wire [11:0] joy1_btns_snes, joy2_btns_snes;
wire [11:0] joy1_usb, joy2_usb;
wire [11:0] hid1, hid2;

wire [5:0] ph;
reg snes_start = 1'b0;
wire pause_snes_for_frame_sync;

wire [7:0] loader_do;
wire loader_do_valid, loading, header_finished;

reg [22:0] loader_addr = 0;

wire [7:0] dbg_reg, dbg_sel;
wire [7:0] core_debug_index;
wire core_debug_strobe;
reg [31:0] core_debug_value;
assign dbg_reg={3'd0,core_debug_index[4:0]};
assign dbg_sel=core_debug_index[7:5]==1?8'h01:core_debug_index[7:5]==2?8'h08:
               core_debug_index[7:5]==3?8'h10:8'h00;
wire [7:0] dbg_dat_out, dbg_dat_in;
assign dbg_dat_in=0;
reg dbg_reg_wr = 0;
reg dbg_break = 0;

wire [7:0] rom_type;
wire [3:0] rom_size, ram_size;
wire [23:0] rom_mask, ram_mask;

wire sdram_busy;
wire refresh;
reg enable; // && ~dbg_break && ~pause;
reg loaded;
reg load_fault=0;
reg [2:0] load_drain=0;
wire cpu_req_ack;

always @(posedge mclk) begin        // wait until memory initialize to start SNES
    if (~sdram_busy && ~pause_snes_for_frame_sync && loaded && !overlay && !rom_diag_busy && !rom_diag_fault)
        enable <= 1;
    else 
        enable <= 0;
end

wire sysclkf_ce, sysclkr_ce;
wire overlay;

`ifdef CHIP_DSPn
parameter USE_DSPn=1;
`else
parameter USE_DSPn=0;
`endif
`ifdef CHIP_GSU
parameter USE_GSU=1;
`else
parameter USE_GSU=0;
`endif

// `ifdef VERILATOR
// parameter USE_DSPn=1;
// parameter USE_GSU=1;
// `endif

`ifndef DISABLE_SNES
main #(.USE_DSPn(USE_DSPn), .USE_GSU(USE_GSU)) main (
    .MCLK(mclk), .RESET_N(resetn & ~loading), .ENABLE(enable), 
    .SYSCLKF_CE(sysclkf_ce), .SYSCLKR_CE(sysclkr_ce), .REFRESH(refresh),

    .ROM_TYPE(rom_type), .ROM_MASK(rom_mask), .RAM_MASK(ram_mask),

    .ROM_ADDR(ROM_ADDR), .ROM_D(ROM_D), .ROM_Q(ROM_Q),
    .ROM_CE_N(ROM_CE_N), .ROM_OE_N(ROM_OE_N), .ROM_WE_N(ROM_WE_N),
    .ROM_WORD(ROM_WORD),

    .BSRAM_ADDR(BSRAM_ADDR), .BSRAM_D(BSRAM_D),	.BSRAM_Q(BSRAM_Q),
    .BSRAM_CE_N(BSRAM_CE_N), .BSRAM_OE_N(BSRAM_OE_N), .BSRAM_WE_N(BSRAM_WE_N),
    .BSRAM_RD_N(BSRAM_RD_N),

    .WRAM_ADDR(WRAM_ADDR), .WRAM_D(WRAM_D),	.WRAM_Q(WRAM_SD_Q),
    .WRAM_CE_N(WRAM_CE_N), .WRAM_OE_N(WRAM_OE_N), .WRAM_WE_N(WRAM_WE_N),
    .WRAM_RD_N(WRAM_RD_N),

    .VRAM1_ADDR(VRAM1_ADDR), .VRAM1_DI(VRAM1_Q), .VRAM1_DO(VRAM1_D),
    .VRAM1_WE_N(VRAM1_WE_N), .VRAM2_ADDR(VRAM2_ADDR), .VRAM2_DI(VRAM2_Q),
    .VRAM2_DO(VRAM2_D), .VRAM2_WE_N(VRAM2_WE_N), .VRAM_OE_N(VRAM_OE_N),

    .ARAM_ADDR(ARAM_ADDR), .ARAM_Q(ARAM_Q), .ARAM_D(ARAM_D), 
    .ARAM_CE_N(ARAM_CE_N), .ARAM_OE_N(ARAM_OE_N), .ARAM_WE_N(ARAM_WE_N),

    .BLEND(BLEND), .PAL(PAL), .HIGH_RES(), .FIELD(), .INTERLACE(), .DIS_SHORTLINE(),
    .DOTCLK(dotclk), .RGB_OUT(rgb_out), .HBLANKn(hblankn),
    .VBLANKn(vblankn), .X_OUT(x_out), .Y_OUT(y_out),

    .JOY1_DI(overlay?2'b11:snes_joy1_di), .JOY2_DI(overlay?2'b11:snes_joy2_di), .JOY_STRB(snes_joy_strb), 
    .JOY1_CLK(snes_joy1_clk), .JOY2_CLK(snes_joy2_clk), 

    .AUDIO_L(audio_l), .AUDIO_R(audio_r), .AUDIO_READY(audio_ready), .AUDIO_EN(audio_en),

    .JOY1_P6(), .JOY2_P6(), .JOY2_P6_in(), .DOT_CLK_CE(DOT_CLK_CE), .EXT_RTC(),
    .SPC_MODE(), .IO_ADDR(), .IO_DAT(), .IO_WR(), 

    .DBG_SEL(dbg_sel), .DBG_REG(dbg_reg), .DBG_REG_WR(dbg_reg_wr), .DBG_DAT_IN(dbg_dat_in), 
    .DBG_DAT_OUT(dbg_dat_out), .DBG_BREAK(dbg_break)
);
`endif

// SDRAM for SNES ROM, WRAM and ARAM
wire [15:0] cpu_port0;
wire [15:0] cpu_port1;
reg         cpu_port;

reg         cpu_req;
reg  [1:0]  cpu_ds;
// Keep upload words and work-RAM bytes in separate registers. A shared
// 16-bit feedback mux unnecessarily puts the write-enable decoder on every
// data bit's half-cycle path.
reg [15:0] cpu_rom_din;
reg [7:0] cpu_wram_din;
wire [15:0] cpu_din=cpu_port?{cpu_wram_din,cpu_wram_din}:cpu_rom_din;
reg [22:0]  cpu_addr; 
reg         cpu_we;
wire rom_diag_active,rom_diag_req,rom_diag_busy,rom_diag_done,rom_diag_fault;
wire[22:0]rom_diag_addr;
wire[31:0]rom_received_crc,rom_memory_crc;
snes_rom_diagnostics rom_diagnostics(
 .clk(mclk),.resetn(resetn),.loading(loading),.load_start(loading&&!loading_r),
 .rx_valid(loader_do_valid&&header_finished),.rx_byte(loader_do),
 .start(core_debug_strobe&&core_debug_index==8'h80),.length(loader_addr),
 .normal_req(cpu_req),.bus_ack(cpu_req_ack),.bus_data(cpu_port0),
 .active(rom_diag_active),.bus_req(rom_diag_req),.bus_addr(rom_diag_addr),
 .busy(rom_diag_busy),.done(rom_diag_done),.fault(rom_diag_fault),
 .received_crc(rom_received_crc),.memory_crc(rom_memory_crc));
always @*begin
 case(core_debug_index)
  0:core_debug_value=32'h534e3031; // SN01 diagnostic protocol
  1:core_debug_value={9'd0,loader_addr};
  2:core_debug_value=rom_received_crc;
  3:core_debug_value=rom_memory_crc;
  4,8'h80:core_debug_value={29'd0,rom_diag_fault,rom_diag_done,rom_diag_busy};
  5:core_debug_value={ROM_ADDR,overlay,enable,loaded,pause_snes_for_frame_sync,sdram_busy,rom_diag_fault,load_fault,resetn};
  6:core_debug_value={rom_type,rom_size,ram_size,16'd0};
  default:core_debug_value={24'd0,dbg_dat_out};
 endcase
end

wire [22:0] rom_addr = loading ? loader_addr : ROM_ADDR[22:0];
reg [22:0]  rom_addr_sd;

reg [16:0]  wram_addr_sd;
reg         wram_wr_r, wram_rd_r;

reg         bsram_req, bsram_we;
reg [19:0]  bsram_addr;
reg [7:0]   bsram_din;
wire [7:0]  bsram_dout;
wire        bsram_rd = ~BSRAM_CE_N & (~BSRAM_RD_N || rom_type[7:4] == 4'hC);
wire        bsram_wr = ~BSRAM_CE_N & ~BSRAM_WE_N;
reg         bsram_rd_r, bsram_wr_r;

wire        aram_rd = ~ARAM_CE_N & ~ARAM_OE_N;
wire        aram_wr = ~ARAM_CE_N & ~ARAM_WE_N;
reg [15:0]  aram_addr_sd;
reg         aram_rd_r, aram_wr_r;
reg         aram_req;

wire        DOT_CLK_CE;
assign      O_sdram_clk = fclk_p;

// Capture memory requests half a master clock after the engine changes its
// outputs. Waiting for the next rising edge misses the FastROM branch-target
// read deadline, including the engine's registered cartridge-data path.
// UART byte-valid is also produced on the rising edge; its counter and saved
// preceding byte update on the next rising edge, so its pair remains intact.
// Generate SDRAM signals
always @(negedge mclk) begin
    if (~resetn) begin
        cpu_req<=0;cpu_we<=0;cpu_port<=0;cpu_addr<=0;cpu_rom_din<=0;cpu_wram_din<=0;cpu_ds<=0;
        rom_addr_sd<=23'h7fffff;wram_addr_sd<=0;wram_wr_r<=0;wram_rd_r<=0;
        bsram_req<=0;bsram_addr<=0;bsram_din<=0;bsram_rd_r<=0;bsram_wr_r<=0;
        aram_req<=0;aram_addr_sd<=0;aram_rd_r<=0;aram_wr_r<=0;
    end else begin
        // ROM read and load
        if (loading && loader_do_valid && header_finished && loader_addr[0] && loader_addr<23'h3c0000 
            || ~loading && ~ROM_CE_N && rom_addr_sd != rom_addr) begin
            rom_addr_sd <= rom_addr;
            cpu_addr <= rom_addr;
            cpu_req <= ~cpu_req;
            cpu_we <= loading;
            if(loading)cpu_rom_din <= {loader_do, loader_do_r};    // write 16 bits on odd addresses
            cpu_ds <= 2'b11;
            cpu_port <= 0;
        end
        
        // WRAM read/write
        wram_rd_r <= wram_rd; wram_wr_r <= wram_wr;
        if(wram_wr && !wram_wr_r)cpu_wram_din <= WRAM_D;
        if ((wram_rd && WRAM_ADDR[16:1] != wram_addr_sd[16:1]) || (wram_rd & ~wram_rd_r) || (wram_wr & ~wram_wr_r)) begin
            wram_addr_sd <= WRAM_ADDR;
            cpu_req <= ~cpu_req;
            cpu_addr <= {6'b111_111, WRAM_ADDR[16:0]};  // 7E,7F:0000-FFFF, total 128KB
            cpu_we <= wram_wr;
            cpu_ds <= {WRAM_ADDR[0], ~WRAM_ADDR[0]};
            cpu_port <= 1;
        end 

        // BSRAM read/write
        bsram_rd_r <= bsram_rd; bsram_wr_r <= bsram_wr;
        if (bsram_rd && BSRAM_ADDR != bsram_addr || (bsram_wr & ~bsram_wr_r) || (bsram_rd & ~bsram_rd_r)) begin
            bsram_addr <= BSRAM_ADDR;
            bsram_req <= ~bsram_req;
            bsram_din <= BSRAM_D;
        end

        // ARAM read/write
        aram_rd_r <= aram_rd; aram_wr_r <= aram_wr;
        if (aram_rd && aram_addr_sd != ARAM_ADDR || (aram_wr && aram_addr_sd != ARAM_ADDR) || (aram_rd & ~aram_rd_r) || (aram_wr & ~aram_wr_r)) begin
            aram_req <= ~aram_req;
            aram_addr_sd <= ARAM_ADDR;
        end
    end
end

localparam RV_IDLE_REQ0 = 3'd0;
localparam RV_WAIT0_REQ1 = 3'd1;
localparam RV_DATA0 = 3'd2;
localparam RV_WAIT1 = 3'd3;
localparam RV_DATA1 = 3'd4;
reg [2:0]   rvst;

wire        rv_valid;
reg         rv_ready;
wire [22:0] rv_addr;
wire [31:0] rv_wdata;
wire [3:0]  rv_wstrb;
reg  [15:0] rv_dout0;
wire [31:0] rv_rdata = {rv_dout, rv_dout0};
reg         rv_valid_r;
reg         rv_word;           // which word
reg         rv_req;
wire        rv_req_ack;
wire [15:0] rv_dout;
reg [1:0]   rv_ds;
reg         rv_new_req;

wire rv_write = rv_wstrb != 0;
wire rv_new_req_t = rv_valid & ~rv_valid_r;

always @(posedge mclk) begin            // RV
    if (~resetn) begin
        rvst <= RV_IDLE_REQ0;
        rv_ready <= 0;
        rv_valid_r <= 0;
        rv_new_req <= 0;
        rv_req <= 0;
        rv_word <= 0;
        rv_ds <= 0;
    end else begin
        if (rv_new_req_t) rv_new_req <= 1;

        rv_ready <= 0;
        rv_valid_r <= rv_valid;

        case (rvst)
        RV_IDLE_REQ0: if (rv_new_req || rv_new_req_t) begin
            rv_new_req <= 0;
            rv_req <= ~rv_req;
            if (rv_write && rv_wstrb[1:0] == 2'b0) begin
                // shortcut for only writing the upper word
                rv_word <= 1;
                rv_ds <= rv_wstrb[3:2];
                rvst <= RV_WAIT1;
            end else begin
                rv_word <= 0;
                if (rv_write)
                    rv_ds <= rv_wstrb[1:0];
                else
                    rv_ds <= 2'b11;
                rvst <= RV_WAIT0_REQ1;
            end
        end

        RV_WAIT0_REQ1: begin
            if (rv_req == rv_req_ack) begin
                rv_req <= ~rv_req;      // request 1
                rv_word <= 1;
                if (rv_write) begin
                    rvst <= RV_WAIT1;
                    if (rv_wstrb[3:2] == 2'b0) begin
                        // shortcut for only writing the lower word
                        rv_req <= rv_req;
                        rv_ready <= 1;
                        rvst <= RV_IDLE_REQ0;
                    end
                    rv_ds <= rv_wstrb[3:2];
                end else begin
                    rv_ds <= 2'b11;
                    rvst <= RV_DATA0;
                end
            end
        end

        RV_DATA0: begin
            rv_dout0 <= rv_dout;
            rvst <= RV_WAIT1;
        end
            
        RV_WAIT1: 
            if (rv_req == rv_req_ack) begin
                if (rv_write)  begin
                    rv_ready <= 1;
                    rvst <= RV_IDLE_REQ0;
                end else
                    rvst <= RV_DATA1;
            end

        RV_DATA1: begin
            rv_ready <= 1;
            rvst <= RV_IDLE_REQ0;
        end

        default:;
        endcase
    end
end

reg [14:0] vram1_addr_sd, vram2_addr_sd;
reg vram1_we_n_old, vram2_we_n_old;
reg vram1_req /* synthesis syn_keep=1 */; 
reg vram2_req /* synthesis syn_keep=1 */;
reg [7:0] vram1_din, vram2_din;

always @(negedge mclk) begin
    if(!resetn)begin
        vram1_we_n_old<=1;vram2_we_n_old<=1;vram1_req<=0;vram2_req<=0;
        vram1_addr_sd<=0;vram2_addr_sd<=0;vram1_din<=0;vram2_din<=0;
    end else begin
    vram1_we_n_old <= VRAM1_WE_N;
    if ((~VRAM1_WE_N & vram1_we_n_old) || (VRAM1_ADDR[14:0] != vram1_addr_sd && ~VRAM_OE_N)) begin
        vram1_addr_sd <= VRAM1_ADDR[14:0];
        if(!VRAM1_WE_N)vram1_din <= VRAM1_D;
        vram1_req <= ~vram1_req;
    end

    vram2_we_n_old <= VRAM2_WE_N;
    if ((~VRAM2_WE_N & vram2_we_n_old) || (VRAM2_ADDR[14:0] != vram2_addr_sd && ~VRAM_OE_N)) begin
        vram2_addr_sd <= VRAM2_ADDR[14:0];
        if(!VRAM2_WE_N)vram2_din <= VRAM2_D;
        vram2_req <= ~vram2_req;
    end
    end
end

sdram_snes sdram(
    .clk(fclk), .mclk(mclk), .clkref(DOT_CLK_CE), .resetn(fast_resetn), .busy(sdram_busy),

    // SDRAM pins
    .SDRAM_DQ(IO_sdram_dq), .SDRAM_A(O_sdram_addr), .SDRAM_BA(O_sdram_ba), 
    .SDRAM_nCS(O_sdram_cs_n), .SDRAM_nWE(O_sdram_wen_n), .SDRAM_nRAS(O_sdram_ras_n), 
    .SDRAM_nCAS(O_sdram_cas_n), .SDRAM_CKE(O_sdram_cke), .SDRAM_DQM(O_sdram_dqm), 

    // CPU accesses
    .cpu_addr(rom_diag_active?rom_diag_addr[22:1]:cpu_addr[22:1]), .cpu_din(cpu_din), .cpu_port(rom_diag_active?1'b0:cpu_port),
    .cpu_port0(cpu_port0), .cpu_port1(cpu_port1), .cpu_req(rom_diag_active?rom_diag_req:cpu_req), .cpu_req_ack(cpu_req_ack),
    .cpu_we(rom_diag_active?1'b0:cpu_we), .cpu_ds(rom_diag_active?2'b11:cpu_ds),

    // BSRAM accesses
    .bsram_addr(bsram_addr), .bsram_dout(bsram_dout), .bsram_din(bsram_din),
    .bsram_req(bsram_req), .bsram_req_ack(), .bsram_we(bsram_wr),

    // ARAM accesses
    .aram_16(aram_16), .aram_addr(ARAM_ADDR), .aram_din({ARAM_D, ARAM_D}), 
    .aram_dout(aram_dout), .aram_req(aram_req), .aram_req_ack(), .aram_we(aram_wr),

`ifdef SDRAM_3CH
    // VRAM accesses
    .vram1_addr(vram1_addr_sd), .vram1_req(vram1_req), .vram1_ack(), 
    .vram1_we(~vram1_we_n_old), .vram1_din(vram1_din), .vram1_dout(VRAM1_Q), 
    .vram2_addr(vram2_addr_sd), .vram2_req(vram2_req), .vram2_ack(),
    .vram2_we(~vram2_we_n_old),  .vram2_din(vram2_din), .vram2_dout(VRAM2_Q),
`endif

    .rv_addr({rv_addr[22:2], rv_word}), .rv_din(rv_word ? rv_wdata[31:16] : rv_wdata[15:0]),
    .rv_ds(rv_ds), .rv_dout(rv_dout), .rv_req(rv_req), .rv_req_ack(rv_req_ack), .rv_we(rv_wstrb != 0),
    .menu_mode(overlay || loading || !loaded),.bg_enable(bg_enable),.bg_req(bg_req),.bg_addr(bg_addr),.bg_ack(bg_ack),
    .bg_data(bg_data),.bg_valid(bg_valid),.bg_word(bg_word)

);

`ifndef SDRAM_3CH
// FPGA block RAM for SNES VRAM 
vram vram(
    .clk(mclk), 
    .vram1_addr(vram1_addr_sd), .vram1_req(vram1_req), .vram1_ack(), 
    .vram1_we(~vram1_we_n_old), .vram1_din(vram1_din), .vram1_dout(VRAM1_Q), 
    .vram2_addr(vram2_addr_sd), .vram2_req(vram2_req), .vram2_ack(),
    .vram2_we(~vram2_we_n_old),  .vram2_din(vram2_din), .vram2_dout(VRAM2_Q)
);
`endif

// Parse 64-byte rom header into rom_type and etc
smc_parser smc (
    .clk(mclk), .resetn(resetn & ~(loading & ~loading_r)),
    .rom_d(loader_do), .rom_strb(loader_do_valid), 
    .rom_type(rom_type), .rom_mask(rom_mask), .ram_mask(ram_mask),
    .rom_size(rom_size), .ram_size(ram_size),
    .header_finished(header_finished)
);

reg [7:0] loader_do_r;
reg loading_r;
always @(posedge mclk) begin
    if (~resetn) begin
        loading_r <= 0;
        loaded <= 0;load_fault<=0;load_drain<=0;loader_addr<=0;
    end else begin
        loading_r <= loading;
        if (loader_do_valid && header_finished) begin
            if(loader_addr<23'h3c0000)loader_addr<=loader_addr+23'd1;
            else load_fault<=1; 
            loader_do_r <= loader_do;
        end
        if (loading & ~loading_r) begin
            loader_addr <= 0;
            loaded <= 0;load_fault<=0;load_drain<=0;
        end
        if (~loading & loading_r)begin
            if(!header_finished || loader_addr<32768 || loader_addr[0])load_fault<=1;
            else load_drain<=4;
        end
        if(load_drain!=0 && cpu_req==cpu_req_ack)begin
            load_drain<=load_drain-1'b1;
            if(load_drain==1&&!load_fault)loaded<=1;
        end
    end
end

`ifndef VERILATOR

// Controller input
`ifdef CONTROLLER_SNES
controller_snes joy1_snes (
    .clk(mclk), .resetn(resetn), .buttons(joy1_btns_snes),
    .joy_strb(joy1_strb), .joy_clk(joy1_clk), .joy_data(joy1_data)
);
controller_snes joy2_snes (
    .clk(mclk), .resetn(resetn), .buttons(joy2_btns_snes),
    .joy_strb(joy2_strb), .joy_clk(joy2_clk), .joy_data(joy2_data)
);
`else
assign joy1_btns_snes = 12'h0;
assign joy2_btns_snes = 12'h0;
`endif

`ifdef CONTROLLER_DS2
controller_ds2 joy1_ds2 (
    .clk(mclk), .snes_buttons(joy1_btns_ds2),
    .ds_clk(ds_clk), .ds_miso(ds_miso), .ds_mosi(ds_mosi), .ds_cs(ds_cs) 
);
controller_ds2 joy2_ds2 (
   .clk(mclk), .snes_buttons(joy2_btns_ds2),
   .ds_clk(ds_clk2), .ds_miso(ds_miso2), .ds_mosi(ds_mosi2), .ds_cs(ds_cs2) 
);
`else
assign joy1_btns_ds2 = 12'h0;
assign joy2_btns_ds2 = 12'h0;
`endif

`ifdef USB1
wire clk12;
wire pll_lock_12;
wire usb_conerr;
wire [1:0] usb_type;
pll_12 pll12(.clkin(sys_clk), .clkout0(clk12), .lock(pll_lock_12));
usb_hid_host usb_hid_host (
    .usbclk(clk12), .usbrst_n(pll_lock_12),
    .usb_dm(usb1_dn), .usb_dp(usb1_dp),
    .typ(usb_type), .conerr(usb_conerr),
    .game_snes(joy1_usb)
);
`else
assign joy1_usb = 12'h0;
`endif

`ifdef USB2
wire usb_conerr2;
wire [1:0] usb_type2;   
usb_hid_host usb_hid_host2 (
    .usbclk(clk12), .usbrst_n(pll_lock_12),
    .usb_dm(usb2_dn), .usb_dp(usb2_dp),
    .game_snes(joy2_usb), .typ(usb_type2), .conerr(usb_conerr2)
);
assign led = ~{joy2_usb[1:0], usb_type2, usb_conerr2, usb_type, usb_conerr};
`else
assign joy2_usb = 12'h0;
`endif

// output button presses to SNES
controller_adapter joy1_adapter (
    .clk(mclk), .snes_joy_strb(snes_joy_strb), 
    .snes_buttons(joy1_btns_ds2 | joy1_btns_snes | hid1 | joy1_usb), .snes_joy_clk(snes_joy1_clk), .snes_joy_di(snes_joy1_di[0])
);
controller_adapter joy2_adapter (
    .clk(mclk), .snes_joy_strb(snes_joy_strb), 
    .snes_buttons(joy2_btns_ds2 | joy2_btns_snes | hid2 | joy2_usb), .snes_joy_clk(snes_joy2_clk), .snes_joy_di(snes_joy2_di[0])
);
assign snes_joy1_di[1] = 0;  // P3
assign snes_joy2_di[1] = 0;  // P4

wire [15:0] overlay_color;
wire [10:0] overlay_x;
wire [9:0] overlay_y;

wire [7:0] dbg_dat_out_loader;

wire background_enable,palette_we,bg_req,bg_ack,bg_valid,bg_enable;
wire [31:0] palette_data,bg_data;
wire [19:0] bg_addr;
wire [8:0] bg_word;
wire [23:0] background_rgb;
wire background_valid,background_underflow;
menu_background background (
 .clk(mclk),.fclk(fclk),.hclk(hclk),.resetn(fast_resetn),.hresetn(pixel_resetn),
 .enable(background_enable),.oled(1'b0),.overlay(overlay),.x(overlay_x),.y(overlay_y),
 .palette_we(palette_we),.palette_data(palette_data),
 .bg_req(bg_req),.bg_addr(bg_addr),.bg_ack(bg_ack),.bg_data(bg_data),
 .bg_valid(bg_valid),.bg_word(bg_word),.bg_enable(bg_enable),
 .rgb(background_rgb),.valid(background_valid),.underflow(background_underflow)
);

snes2hdmi s2h(
    .clk(mclk), .resetn(resetn),.pixel_resetn(pixel_resetn),.serializer_resetn(serializer_resetn), .snes_refresh(refresh),
    .pause_snes_for_frame_sync(pause_snes_for_frame_sync),
    .dotclk(dotclk), .hblank(~hblankn),.vblank(~vblankn),.rgb5(rgb_out),
    .xs(x_out), .ys(y_out), 
    .overlay(overlay), .overlay_x(overlay_x), .overlay_y(overlay_y),
    .overlay_color(overlay_color),.background_rgb(background_rgb),.background_valid(background_valid),
    .audio_l(overlay?16'd0:audio_l), .audio_r(overlay?16'd0:audio_r), .audio_ready(audio_ready), .audio_en(audio_en),
    .clk_pixel(hclk),.clk_5x_pixel(hclk5),.locked(1'b1),
    .tmds_clk_n(tmds_clk_n), .tmds_clk_p(tmds_clk_p),
    .tmds_d_n(tmds_d_n), .tmds_d_p(tmds_d_p)
);

assign flash_spi_wp_n=1;assign flash_spi_hold_n=1;assign sd_dat1=1;assign sd_dat2=1;
// NANOBLAST command protocol, text renderer and persistent flash bridge.
nanoblast_iosys #(.CORE_ID(2),.FREQ(21_600_000),.ENABLE_DIAGNOSTICS(1)) iosys (
 .clk(mclk),.hclk(hclk),.resetn(resetn),.core_status({4'ha,1'b0,(USE_DSPn!=0),(load_fault|rom_diag_fault),loaded}),
 .core_debug_value(core_debug_value),.core_debug_index(core_debug_index),.core_debug_strobe(core_debug_strobe),
 .overlay(overlay),.overlay_x(overlay_x),.overlay_y(overlay_y),.overlay_color(overlay_color),
 .joy1(joy1_btns_ds2|joy1_btns_snes),.joy2(joy2_btns_ds2|joy2_btns_snes),
 .usb_joy1(hid1),.usb_joy2(hid2),.uart_tx(UART_TXD),.uart_rx(UART_RXD),
 .rom_loading(loading),.rom_do(loader_do),.rom_do_valid(loader_do_valid),.nes_pal(PAL),
 .sd_clk(sd_clk),.sd_mosi(sd_cmd),.sd_cs_n(sd_dat3),.sd_miso(sd_dat0),
 .flash_clk(flash_spi_clk),.flash_mosi(flash_spi_mosi),.flash_cs_n(flash_spi_cs_n),.flash_miso(flash_spi_miso),
 .background_enable(background_enable),.background_palette_we(palette_we),.background_palette_data(palette_data),
 .rv_valid(rv_valid),.rv_addr(rv_addr),.rv_wdata(rv_wdata),.rv_wstrb(rv_wstrb),.rv_ready(rv_ready));

`else       // VERILATOR

// test loader with embedded rom
test_loader test_loader (
    .clk(mclk), .resetn(resetn),
    .dout(loader_do), .dout_valid(loader_do_valid),
    .loading(loading), .fail()
);

// test audio sink: FIFO-like rate limiting to sound sample generation
reg [3:0] sample_counter = 0;
always @(posedge mclk) begin
    if (audio_ready)
        sample_counter <= 0;
    else
        sample_counter <= sample_counter == 15 ? 15 : sample_counter + 1;
end
assign audio_en = sample_counter == 15;


// test video sync by turning on pause_snes_for_frame_sync periodically
reg test_halt_snes, test_sync_done;
reg [3:0] test_halt_cnt = 0;
assign pause_snes_for_frame_sync = test_halt_snes;

always @(posedge mclk) begin    // halt SNES during snes dram refresh on line 2
    if (~resetn) begin
        test_halt_cnt <= 0;
        test_halt_snes <= 0;
        test_sync_done <= 0;
    end else begin
        if (~test_sync_done) begin
            if (~test_halt_snes) begin
                if (y_out[7:0] == 2 && refresh) begin
                    test_halt_snes <= 1;
                    test_halt_cnt <= 4'd12;        // halt snes for 13 cycles
                end
            end else begin
                if (test_halt_cnt != 0) begin
                    test_halt_cnt <= test_halt_cnt - 4'd1;
                end else begin
                    test_halt_snes <= 0;
                    test_sync_done <= 1;
                end                            
            end
        end else if (y_out[7:0] == 8'd200)
            test_sync_done <= 0;
    end
end

`endif

`ifndef VERILATOR

reg [19:0] timer;           // 21 times per second

// status display on LED

reg [9:0] status;
//assign led = s0 == 1'b0 ? ~status[9:5] : ~status[4:0];        // s0==0 when pressed, for mega138k
// assign led = UART_TXD;
//assign led = joy1_btns[1:0];        // Y and B

always @(posedge mclk) begin
    if (loading && ~loading_r)
        status <= 0;
    if (loaded) begin
        case (rom_addr)
        23'h00_000A: status[1] <= 1;
        23'h00_00A1: status[2] <= 1;        // Clear_WRAM
        23'h00_0645: status[3] <= 1;        // Main
        23'h00_0111: status[4] <= 1;        // DMA_Palette
        
        23'h00_06AB: status[5] <= 1;        // Draw_Map
        23'h00_072A: status[6] <= 1;        // Init_Music
        23'h00_075F: status[7] <= 1;        // Infinite_loop
        23'h00_0787: status[8] <= 1;        // left button
        default: ;
        endcase
    end
end

`endif

endmodule
