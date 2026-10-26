// 32x28 text display in 8x8 font, with a picorv32 register I/O interface
// to print characters to the display.

module textdisp(
	input clk,          // main logic clock
    input hclk,         // hdmi clock
	input resetn,

    input [10:0] overlay_x,
    input [9:0] overlay_y,
    output reg [15:0] overlay_color, // BGR5, [15] is opacity

    // PicoRV32 I/O interface. Every write updates one character
    // [23:16]: x, [15:8]: y, [7-0]: character to print
	input   [3:0] reg_char_we,
	input  [31:0] reg_char_di
);

// BGR
localparam [14:0] COLOR_BACK    = 15'b00000_00000_00000;
localparam [14:0] COLOR_TEXT    = 15'b11111_11111_11111;    // white
localparam [14:0] COLOR_SELECTED = 15'b11111_10000_00000; // bright blue
localparam [14:0] COLOR_CURSOR  = 15'b11111_11111_11111;    // white
parameter [14:0] COLOR_LOGO    = 15'b11111_11111_11111;    // white

//
// Pixel output logic for characters and logo:
// 1. To improve timing, output logic is broken into 3 cycles.
// 2. Char buffer, font rom, logo rom are all stored in the same bram 
//    block to save LUTs.
//
reg [10:0] mem_addr_b;
reg [7:0] mem_do_b;
reg [1:0] mem_cnt;
reg is_cursor;
reg [2:0] xoff, yoff;
reg [15:0] overlay_color_buf;

wire [7:0] cmd = reg_char_di[31:24];
wire [4:0] text_x = reg_char_di[20:16];
wire [4:0] text_y = reg_char_di[12:8];
wire [6:0] text_char = reg_char_di[6:0];

// Command 3 configures one rectangle; solid black[21], in inclusive text-cell
// coordinates: enable[20], bottom[19:15], top[14:10], right[9:5], left[4:0].
// Transfer the complete box coherently; individual coordinates must not tear.
reg [21:0] panel_box;
wire [21:0] panel_pixel;
wire panel_resetn;
reset_release panel_release(.clk(hclk),.async_resetn(resetn),.resetn(panel_resetn));
always @(posedge clk or negedge resetn)
    if(!resetn)panel_box<=0;
    else if(reg_char_we[0] && cmd==2'd3)panel_box<=reg_char_di[21:0];
cdc_mailbox #(.WIDTH(22)) panel_bridge(
    .src_clk(clk),.src_resetn(resetn),.src_data(panel_box),
    .dst_clk(hclk),.dst_resetn(panel_resetn),.dst_data(panel_pixel));
reg panel_hit;
reg debug_hit;
localparam [14:0] THEME_LIGHT=15'b11011_11010_11110;
localparam [14:0] THEME_TEXT=15'b11011_11011_11111;
// Command 2 controls an independent selection highlight with the same bounds.
reg [20:0] selection_box;
wire [20:0] selection_pixel;
always @(posedge clk or negedge resetn)
    if(!resetn)selection_box<=0;
    else if(reg_char_we[0] && cmd==2'd2)selection_box<=reg_char_di[20:0];
cdc_mailbox #(.WIDTH(21)) selection_bridge(
    .src_clk(clk),.src_resetn(resetn),.src_data(selection_box),
    .dst_clk(hclk),.dst_resetn(panel_resetn),.dst_data(selection_pixel));
reg selection_hit;

// Command4: disable legacy logo[21], double-size text[20], physical
// bottom row[19:15] and top row[14:10]. Selection/panel bounds stay physical.
reg [23:0] layout_box;
wire [23:0] layout_pixel;
always @(posedge clk or negedge resetn)
    if(!resetn)layout_box<=0;
    else if(reg_char_we[0] && cmd==8'd4)layout_box<=reg_char_di[23:0];
cdc_mailbox #(.WIDTH(24)) layout_bridge(
    .src_clk(clk),.src_resetn(resetn),.src_data(layout_box),
    .dst_clk(hclk),.dst_resetn(panel_resetn),.dst_data(layout_pixel));

// Char buffer, font and logo rom backed by Dual-port BRAM (total 2KB)
// this is initialized with font.mi (font.vh + logo.vh)
// $000-$37F: Character buffer RAM (32*28)
// $380-$3FF: Logo ROM (14*9 bytes)
// $400-$800: Font ROM
gowin_dpb_menu menu_mem (
    .clka(clk), .reseta(1'b0), .ocea(), .cea(1'b1), 
    .ada({1'b0, text_y, text_x}), .wrea(reg_char_we[0] && cmd == 2'd0),
    .dina({1'b0, text_char}), .douta(), 

    .clkb(hclk), .resetb(1'b0), .oceb(), .ceb(1'b1), 
    .adb(mem_addr_b), .wreb(1'b0), 
    .dinb(), .doutb(mem_do_b)
);

localparam overlay_x_start = 256 - 3;
reg [7:0] px;   // = (overlay_x - overlay_x_start) / 3;
reg [7:0] py;   // = (overlay_y - 24) / 3;
reg [9:0] overlay_y_r;
reg [1:0] y_cnt;

wire double_text=layout_pixel[20] && py[7:3]>=layout_pixel[14:10] && py[7:3]<=layout_pixel[19:15];
// Bit22 shifts glyphs on row[14:10] by half a cell; physical panels stay fixed.
wire half_cell=layout_pixel[22] && py[7:3]==layout_pixel[14:10];
wire [7:0] text_px=double_text?{1'b0,px[7:1]}:half_cell?px-8'd4:px;
wire [7:0] text_top={layout_pixel[14:10],3'b000};
wire [7:0] text_py=double_text?text_top+((py-text_top)>>1):py;

// 72x14 pixels 1bpp logo
localparam LOGO_X = 128-36;
localparam LOGO_Y = 201;

reg [6:0] logo_addr;
reg [2:0] logo_xoff;
reg logo_active;

always @* begin
    case (mem_cnt)
    2'd0: mem_addr_b <= {1'b0, text_py[7:3], text_px[7:3]};       // fetch next character
    2'd1: mem_addr_b <= logo_active ? 
                        {4'b0111, logo_addr} :          // fetch logo byte
                        {1'b1, mem_do_b[7] ? 7'h3F : mem_do_b[6:0], yoff};    
                                                        // fetch font byte (? for non-ASCII chars)
    default: mem_addr_b <= 0;
    endcase
end

reg py_logo_active;

always @(posedge hclk) begin
    if (py == LOGO_Y)
        py_logo_active <= 1;
    if (py == LOGO_Y + 14)
        py_logo_active <= 0;

    if (!layout_pixel[21] && px >= LOGO_X && px < LOGO_X+71 && py_logo_active)
        logo_active <= 1;
    else
        logo_active <= 0;
end

always @(posedge hclk) begin

    // mem_cnt: cycle counter (0,1,2)
    mem_cnt <= mem_cnt + 2'd1;
    if (mem_cnt == 2'd2) begin
        mem_cnt <= 0;
        px <= px + 8'd1;
    end
    if (overlay_x == overlay_x_start-1) begin
        mem_cnt <= 0;
        px <= 0;
    end
    overlay_y_r <= overlay_y;
    if (overlay_y != overlay_y_r) begin
        if (overlay_y == 10'd24) begin
            py <= 0;
            y_cnt <= 0;
        end else begin
            y_cnt <= y_cnt + 2'd1;
            if (y_cnt == 2'd2) begin
                py <= py + 10'd1;
                y_cnt <= 0;
            end
        end
    end

    // address generation
    case (mem_cnt)
    2'd0: begin
        reg [6:0] logo_x;
        reg [3:0] logo_y;

        // output color from last cycle
        overlay_color <= overlay_color_buf;

        // for next character
        is_cursor <= text_px[7:3] == 0;
        xoff <= text_px[2:0];
        yoff <= text_py[2:0];
        panel_hit <= panel_pixel[20] &&
            px[7:3]>=panel_pixel[4:0] && px[7:3]<=panel_pixel[9:5] &&
            py[7:3]>=panel_pixel[14:10] && py[7:3]<=panel_pixel[19:15];
        debug_hit <= layout_pixel[23] && py[7:3]>=1 && py[7:3]<=13;
        selection_hit <= selection_pixel[20] &&
            px[7:3]>=selection_pixel[4:0] && px[7:3]<=selection_pixel[9:5] &&
            py[7:3]>=selection_pixel[14:10] && py[7:3]<=selection_pixel[19:15];

        logo_x = px - LOGO_X;
        logo_y = py - LOGO_Y;
        // logo_addr <= logo_y * 9 + logo_x[6:3];
        logo_addr <= {logo_y, 3'b0} + logo_y + logo_x[6:3];
        logo_xoff <= logo_x[2:0];

        // mem_do_b is character after cycle 0
    end
    2'd1: begin
        // bram fetches font or logo byte to mem_do_b 
    end  
    2'd2: begin
        // compute output color
        // On transparent pixels bits 0/1 carry panel/selection masks. Opaque glyphs
        // retain the existing BGR5 color contract and always take priority.
        overlay_color_buf <= debug_hit ? {1'b1,15'd0} : panel_hit && selection_hit ? {1'b1,layout_pixel[22] ? THEME_LIGHT : 15'h7fff}
            : {1'b0,13'd0,selection_hit,panel_hit};
        if (logo_active) begin
            if (mem_do_b[logo_xoff])
                overlay_color_buf <= {1'b1, COLOR_LOGO};
            else
                overlay_color_buf <= {1'b0, COLOR_BACK};
        end else if (mem_do_b[xoff]) begin
            overlay_color_buf <= {1'b1,panel_hit && selection_hit
                ? 15'd0 : panel_hit ? THEME_TEXT : COLOR_TEXT};
        end
    end
    endcase
end

endmodule
