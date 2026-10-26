// NANOBLAST menu/ROM transport without an FPGA soft CPU. GPL-3.0.
// UART and text renderer remain in FPGA; file/menu logic runs on BL616.
module nanoblast_iosys #(
    parameter integer FREQ=21_600_000,
    parameter integer BAUD=2_000_000,
    parameter [7:0] CORE_ID=1,
    parameter integer ENABLE_DIAGNOSTICS=0
)(
    input wire clk,hclk,resetn,
    input wire[7:0]core_status,
    input wire[31:0]core_debug_value,
    output wire[7:0]core_debug_index,output wire core_debug_strobe,
    input wire uart_rx,
    output wire uart_tx,
    input wire [11:0] joy1,joy2,
    output wire [11:0] usb_joy1,usb_joy2,
    input wire [10:0] overlay_x,
    input wire [9:0] overlay_y,
    output wire [15:0] overlay_color,
    output wire overlay,
    output wire rom_loading,
    output wire [7:0] rom_do,
    output wire rom_do_valid,
    output reg nes_pal,
    output wire sd_clk,sd_mosi,sd_cs_n,input wire sd_miso,
    output wire flash_clk,flash_mosi,flash_cs_n,input wire flash_miso,
    output wire background_enable,background_oled,background_palette_we,output wire[31:0]background_palette_data,
    output wire rv_valid,input wire rv_ready,output wire[22:0]rv_addr,output wire[31:0]rv_wdata,output wire[3:0]rv_wstrb
);
reg uart_rx_sync1=1,uart_rx_sync2=1;
always @(posedge clk) begin uart_rx_sync1<=uart_rx;uart_rx_sync2<=uart_rx_sync1;end
wire [7:0] received,transmit;
wire received_valid,transmit_valid,transmit_busy;
wire [31:0] text_word,core_config;
wire text_we;
wire [15:0] hid1,hid2;
assign usb_joy1=hid1[11:0];assign usb_joy2=hid2[11:0];
async_receiver #(.ClkFrequency(FREQ),.Baud(BAUD)) receiver(
    .clk(clk),.RxD(uart_rx_sync2),.RxD_data(received),.RxD_data_ready(received_valid));
async_transmitter #(.ClkFrequency(FREQ),.Baud(BAUD)) transmitter(
    .clk(clk),.TxD_start(transmit_valid&&!transmit_busy),.TxD_data(transmit),.TxD(uart_tx),.TxD_busy(transmit_busy));
nanoblast_menu_link #(.CORE_ID(CORE_ID),.ENABLE_DIAGNOSTICS(ENABLE_DIAGNOSTICS),.FREQ(FREQ),.TIMEOUT_CYCLES(FREQ/10),.JOY_PERIOD_CYCLES(FREQ/50)) link(
    .clk(clk),.resetn(resetn),.core_status(core_status),.rx_data(received),.rx_valid(received_valid),
    .core_debug_value(core_debug_value),.core_debug_index(core_debug_index),.core_debug_strobe(core_debug_strobe),
    .tx_data(transmit),.tx_valid(transmit_valid),.tx_ready(!transmit_busy),
    .joy1(joy1),.joy2(joy2),.text_word(text_word),.text_we(text_we),.overlay_enable(overlay),
    .core_config(core_config),.rom_loading(rom_loading),.rom_data(rom_do),.rom_valid(rom_do_valid),.hid1(hid1),.hid2(hid2),.sd_clk(sd_clk),.sd_mosi(sd_mosi),.sd_cs_n(sd_cs_n),.sd_miso(sd_miso),
    .flash_clk(flash_clk),.flash_mosi(flash_mosi),.flash_cs_n(flash_cs_n),.flash_miso(flash_miso),
    .background_enable(background_enable),.background_oled(background_oled),.background_palette_we(background_palette_we),.background_palette_data(background_palette_data),
    .rv_valid(rv_valid),.rv_ready(rv_ready),.rv_addr(rv_addr),.rv_wdata(rv_wdata),.rv_wstrb(rv_wstrb));
textdisp disp(.clk(clk),.hclk(hclk),.resetn(resetn),.overlay_x(overlay_x),.overlay_y(overlay_y),
    .overlay_color(overlay_color),.reg_char_we({3'd0,text_we}),.reg_char_di(text_word));
reg was_loading;
always @(posedge clk or negedge resetn)
    if(!resetn) begin was_loading<=0;nes_pal<=0;end
    else begin was_loading<=rom_loading;if(rom_loading&&!was_loading)nes_pal<=core_config[2];end
endmodule
