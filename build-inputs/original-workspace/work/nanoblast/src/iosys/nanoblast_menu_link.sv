// NANOBLAST MCU command bridge. GPL-3.0; see COPYING.
// Byte interface to UART: AA length_hi length_lo command payload.
// Length includes command. No terminator is needed for text or ROM packets.
module nanoblast_menu_link #(
    parameter [7:0] CORE_ID=1,
    parameter integer ENABLE_DIAGNOSTICS=0,
    parameter integer FREQ=21_600_000,
    parameter integer FLASH_CS_TIMEOUT_CYCLES=FREQ/2,
    parameter integer TIMEOUT_CYCLES=2_000_000,
    parameter integer JOY_PERIOD_CYCLES=400_000
)(
    input wire clk, resetn,
    input wire[7:0]core_status,
    input wire[31:0]core_debug_value,
    output reg[7:0]core_debug_index,output reg core_debug_strobe,
    input wire [7:0] rx_data,
    input wire rx_valid,
    output wire [7:0] tx_data,
    output wire tx_valid,
    input wire tx_ready,
    input wire [11:0] joy1,joy2,
    output reg [31:0] text_word,
    output reg text_we,
    output reg overlay_enable,
    output reg [31:0] core_config,
    output reg rom_loading,
    output reg [7:0] rom_data,
    output reg rom_valid,
    output reg [15:0] hid1,hid2,
    output wire sd_clk,sd_mosi,sd_cs_n,input wire sd_miso,
    output wire flash_clk,flash_mosi,flash_cs_n,input wire flash_miso,
    output reg background_enable,background_oled,background_palette_we,output reg[31:0]background_palette_data,
    output reg rv_valid,input wire rv_ready,output reg[22:0]rv_addr,output reg[31:0]rv_wdata,
    output wire[3:0]rv_wstrb
);
localparam SYNC=0,LEN_HI=1,LEN_LO=2,COMMAND=3,PAYLOAD=4;
reg [2:0] state;
reg [15:0] length,remaining;
reg [7:0] command;
reg [31:0] word;
reg [7:0] cursor_x,cursor_y;
// These counters reset at their terminal count; unused high bits would
// otherwise become a wide feedback adder in the native synthesis flow.
reg [(TIMEOUT_CYCLES>1?$clog2(TIMEOUT_CYCLES):1)-1:0] idle_count;
reg [(JOY_PERIOD_CYCLES>1?$clog2(JOY_PERIOD_CYCLES):1)-1:0] joy_count;
reg status_pending;
reg debug_pending;
reg id_pending,joy_pending,bg_ack_pending,bg_last_wait,bg_frame_valid;
reg[22:0]bg_next_addr;reg[7:0]bg_status;
assign rv_wstrb=rv_valid?4'hf:4'h0;
reg [63:0] tx_shift;
reg [3:0] tx_left;
// Small transactions keep the menu transport within the Nano's logic budget.
reg [7:0] sd_tx_mem[0:31],sd_rx_mem[0:31];
reg [7:0] sd_length,sd_flags,sd_tx_pos,flash_sequence;
reg [15:0] payload_index;
reg sd_start,flash_start,storage_flash,flash_cap_pending,sd_pending,sd_tx_active,sd_accept;
wire sd_busy,sd_done,sd_rx_we;
wire[6:0]sd_index,sd_rx_index;wire[7:0]sd_rx_byte;
wire storage_start=sd_start||flash_start;
wire storage_sck,storage_mosi;
reg sd_select,flash_select;reg[$clog2(FLASH_CS_TIMEOUT_CYCLES+1)-1:0]flash_idle;
// SD and flash transactions are serialized by the menu task. One SPI engine
// and single-port packet buffers suffice; chip selects remain device-specific.
nanoblast_sd_spi #(.FREQ(FREQ)) storage_spi(
 .clk(clk),.resetn(resetn),.start(storage_start),.length(sd_length),.flags(sd_flags),
 .tx_index(sd_index),.tx_byte(sd_tx_mem[sd_index[4:0]]),
 .rx_index(sd_rx_index),.rx_byte(sd_rx_byte),.rx_we(sd_rx_we),
 .done(sd_done),.busy(sd_busy),.sck(storage_sck),.mosi(storage_mosi),.cs_n(),
 .miso(storage_flash?flash_miso:sd_miso));
assign sd_clk=storage_flash?1'b0:storage_sck;
assign sd_mosi=storage_flash?1'b1:storage_mosi;
assign sd_cs_n=sd_select;
assign flash_clk=storage_flash?storage_sck:1'b0;
assign flash_mosi=storage_flash?storage_mosi:1'b1;
assign flash_cs_n=flash_select;
always @(posedge clk or negedge resetn)begin
 if(!resetn)begin sd_select<=1;flash_select<=1;flash_idle<=0;end
 else begin
  if(flash_select||sd_busy||storage_start)flash_idle<=0;
  else if(flash_idle>=FLASH_CS_TIMEOUT_CYCLES-1)begin flash_select<=1;flash_idle<=0;end
  else flash_idle<=flash_idle+1;
  if(storage_start)begin
   if(storage_flash)begin flash_select<=sd_flags[0];sd_select<=1;end
   else begin sd_select<=sd_flags[0];flash_select<=1;end
  end
 end
end
assign tx_valid=sd_tx_active || tx_left!=0;
assign tx_data=!sd_tx_active ? tx_shift[63:56] : sd_tx_pos==0 ? 8'haa : sd_tx_pos==1 ? 8'd0 :
 sd_tx_pos==2 ? sd_length+(storage_flash?8'd2:8'd1) : sd_tx_pos==3 ? (storage_flash?8'h15:8'h10) : storage_flash&&sd_tx_pos==4 ? flash_sequence : sd_rx_mem[(sd_tx_pos-4-(storage_flash?1:0))&31];
wire [31:0] complete_word={word[23:0],rx_data};
always @(posedge clk or negedge resetn) begin
    if(!resetn) begin
        state<=SYNC;length<=0;remaining<=0;command<=0;word<=0;
        cursor_x<=0;cursor_y<=0;idle_count<=0;joy_count<=0;
        text_word<=0;text_we<=0;overlay_enable<=1;core_config<=0;
        rom_loading<=0;rom_data<=0;rom_valid<=0;hid1<=0;hid2<=0;
        status_pending<=0;debug_pending<=0;core_debug_index<=0;core_debug_strobe<=0;
        id_pending<=0;joy_pending<=0;tx_shift<=0;tx_left<=0;
        background_enable<=0;background_oled<=0;background_palette_we<=0;background_palette_data<=0;rv_valid<=0;rv_addr<=0;rv_wdata<=0;bg_next_addr<=0;bg_ack_pending<=0;bg_last_wait<=0;bg_frame_valid<=0;bg_status<=0;
        flash_start<=0;flash_sequence<=0;storage_flash<=0;flash_cap_pending<=0;sd_length<=0;sd_flags<=1;sd_tx_pos<=0;payload_index<=0;sd_start<=0;sd_pending<=0;sd_tx_active<=0;sd_accept<=0;
    end else begin
        text_we<=0;rom_valid<=0;sd_start<=0;flash_start<=0;background_palette_we<=0;core_debug_strobe<=0;
        if(rv_valid&&rv_ready)begin rv_valid<=0;if(bg_last_wait)begin bg_last_wait<=0;bg_ack_pending<=1;end end
        if(sd_rx_we)sd_rx_mem[sd_rx_index[4:0]]<=sd_rx_byte;
        if(sd_done)sd_pending<=1;
        // Missing bytes must not leave the decoder consuming future frames.
        if(rx_valid) idle_count<=0;
        else if(state!=SYNC) begin
            if(idle_count>=TIMEOUT_CYCLES-1) begin state<=SYNC;idle_count<=0;end
            else idle_count<=idle_count+1;
        end
        if(joy_count>=JOY_PERIOD_CYCLES-1) begin joy_count<=0;joy_pending<=1;end
        else joy_count<=joy_count+1;
        if(sd_tx_active)begin
            if(tx_ready)begin
                if(sd_tx_pos==sd_length+3+(storage_flash?1:0))sd_tx_active<=0;
                else sd_tx_pos<=sd_tx_pos+1;
            end
        end else if(tx_left!=0) begin
            if(tx_ready) begin tx_shift<={tx_shift[55:0],8'd0};tx_left<=tx_left-1;end
        end else if(sd_pending)begin sd_tx_active<=1;sd_tx_pos<=0;sd_pending<=0;
        end else if(flash_cap_pending)begin tx_shift<={8'haa,16'd5,8'h16,32'h4e424631};tx_left<=8;flash_cap_pending<=0;
        end else if(bg_ack_pending)begin tx_shift<={8'haa,16'd2,8'h13,bg_status,24'd0};tx_left<=5;bg_ack_pending<=0;
        end else if(debug_pending)begin tx_shift<={8'haa,16'd5,8'h17,core_debug_value};tx_left<=8;debug_pending<=0;
        end else if(status_pending)begin tx_shift<={8'haa,16'd2,8'h14,core_status,24'd0};tx_left<=5;status_pending<=0;
        end else if(id_pending) begin
            tx_shift<={8'haa,16'd2,8'h01,CORE_ID,24'd0};tx_left<=5;id_pending<=0;
        end else if(joy_pending) begin
            tx_shift<={8'haa,16'd5,8'h03,4'd0,joy1,4'd0,joy2};tx_left<=8;joy_pending<=0;
        end
        if(rx_valid) case(state)
            SYNC: if(rx_data==8'haa) state<=LEN_HI;
            LEN_HI: begin length[15:8]<=rx_data;state<=LEN_LO;end
            LEN_LO: begin length[7:0]<=rx_data;state<=COMMAND;end
            COMMAND: begin
                command<=rx_data;remaining<=length-1;word<=0;payload_index<=0;
                sd_accept<=!sd_busy && !sd_pending && !sd_tx_active;
                if(rx_data==19)begin bg_frame_valid<=length>=9 && (length-5)%4==0 && !rv_valid;bg_status<=0;end
                if(length==0) state<=SYNC;
                else if(length==1) begin
                    if(rx_data==1) id_pending<=1;
                    if(rx_data==20) status_pending<=1;
                    if(rx_data==22) flash_cap_pending<=1;
                    state<=SYNC;
                end else state<=PAYLOAD;
            end
            PAYLOAD: begin
                remaining<=remaining-1;word<=complete_word;payload_index<=payload_index+1;
                if(sd_accept&&((command==16&&length>=2&&length<=34)||(command==21&&length>=3&&length<=35)))begin
                    if(payload_index==0)sd_flags<=rx_data;
                    else if(command==21&&payload_index==1)flash_sequence<=rx_data;
                    else sd_tx_mem[payload_index[4:0]-(command==21?5'd2:5'd1)]<=rx_data;
                end
                if(command==19)begin
                    if(payload_index==3)begin
                        bg_next_addr<=complete_word[22:0];
                        if(complete_word<32'h00200000 || complete_word>32'h002e0ffc || complete_word+length-5>32'h002e1000 || complete_word[1:0]!=0)begin bg_frame_valid<=0;bg_status<=1;end
                    end
                    if(payload_index>=7 && payload_index[1:0]==3 && bg_frame_valid)begin
                        if(rv_valid && !rv_ready)begin bg_frame_valid<=0;bg_status<=2;end
                        else begin rv_addr<=bg_next_addr;rv_wdata<={complete_word[7:0],complete_word[15:8],complete_word[23:16],complete_word[31:24]};rv_valid<=1;bg_next_addr<=bg_next_addr+4;end
                    end
                end
                // Fixed-width commands commit only after a complete packet.
                if(remaining==1) begin
                    state<=SYNC;
                    case(command)
                        23:if(ENABLE_DIAGNOSTICS&&length==2)begin core_debug_index<=rx_data;core_debug_strobe<=1;debug_pending<=1;end
                        3: if(length==5) core_config<=complete_word;
                        4: if(length==3) begin cursor_x<=word[7:0];cursor_y<=rx_data;end
                        6: if(length==2) rom_loading<=rx_data[0];
                        8: if(length==2) overlay_enable<=rx_data[0];
                        9: if(length==5) begin hid1<=complete_word[31:16];hid2<=complete_word[15:0];end
                        17:if(length==2)begin background_enable<=rx_data[0];background_oled<=rx_data[1];end
                        18:if(length==5)begin background_palette_data<=complete_word;background_palette_we<=1;end
                        19:begin
                            if(bg_frame_valid && payload_index>=7 && !(rv_valid&&!rv_ready))bg_last_wait<=1;
                            else begin bg_ack_pending<=1;if(bg_status==0)bg_status<=1;end
                        end
                        16: if(length>=2&&length<=34&&sd_accept)begin sd_length<=length-2;storage_flash<=0;sd_start<=1;end
                        21: if(length>=3&&length<=35&&sd_accept)begin sd_length<=length-3;storage_flash<=1;flash_start<=1;end
                        14: if(length==5 && complete_word[31:24]<=4) begin text_word<=complete_word;text_we<=1;end
                        default: ;
                    endcase
                end
                if(command==5 && cursor_x<32 && cursor_y<28 && rx_data>=32) begin
                    text_word<={8'd0,cursor_x,cursor_y,rx_data};text_we<=1;cursor_x<=cursor_x+1;
                end
                if(command==7 && rom_loading) begin rom_data<=rx_data;rom_valid<=1;end
            end
            default: state<=SYNC;
        endcase
    end
end
endmodule
