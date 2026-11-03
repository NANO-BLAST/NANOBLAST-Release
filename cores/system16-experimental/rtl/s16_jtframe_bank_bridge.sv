// SPDX-License-Identifier: GPL-3.0-or-later
// JTFRAME 32-bit read bursts / 16-bit masked writes -> native x32 toggle bus.
// Four logical banks of 2 MiB, each addressed in 16-bit words. The generated
// wrapper must relocate XRAM's VRAM_OFFSET to fit this physical geometry.
// This adapter deliberately faults on out-of-range/unaligned burst requests.
// It has no programming port, framebuffer arbitration or clock crossing yet.
module s16_jtframe_bank_bridge(
    input wire clk,resetn,mem_ready,
    input wire [3:0] rd,wr,
    input wire [87:0] bank_addr,
    input wire [63:0] bank_din,
    input wire [7:0] bank_dsn,
    output reg [3:0] ack=0,dst=0,dok=0,rdy=0,
    output reg [15:0] data_read=0,
    output reg mem_req=0,mem_wr=0,
    output reg [22:0] mem_addr=0,
    output reg [31:0] mem_din=0,
    output reg [3:0] mem_wmask=0,
    input wire mem_ack,
    input wire [31:0] mem_dout,
    output reg fault=0
);
localparam IDLE=0,WAIT_DATA=1,LAST_WORD=2;
reg [1:0] state=IDLE,owner=0,next_owner=0;
reg reading=0;
reg [15:0] high_word=0;
reg found;
reg [1:0] selected,candidate;
integer i;
always @* begin
    selected=next_owner;candidate=0;found=0;
    for(i=0;i<4;i=i+1)begin
        candidate=next_owner+i;
        if(!found && (rd[candidate] || wr[candidate]))begin
            found=1;selected=candidate;
        end
    end
end
wire [21:0] address=bank_addr[selected*22+:22];
wire [1:0] enables=~bank_dsn[selected*2+:2];
always @(posedge clk)begin
    ack<=0;dst<=0;dok<=0;rdy<=0;
    case(state)
    IDLE:if(mem_ready && found && !fault)begin
        if(address[21:20]!=0 || (rd[selected] && address[0]) || (rd[selected] && wr[selected]))begin
            fault<=1;
        end else begin
            owner<=selected;reading<=rd[selected];
            mem_addr<={selected,address[19:1],2'b00};
            mem_din<={2{bank_din[selected*16+:16]}};
            mem_wmask<=address[0]?{enables,2'b00}:{2'b00,enables};
            mem_wr<=wr[selected];mem_req<=~mem_req;
            ack[selected]<=1;
            state<=WAIT_DATA;
        end
    end
    WAIT_DATA:if(mem_ack==mem_req)begin
        if(reading)begin
            data_read<=mem_dout[15:0];high_word<=mem_dout[31:16];
            dst[owner]<=1;dok[owner]<=1;state<=LAST_WORD;
        end else begin
            rdy[owner]<=1;next_owner<=owner+2'd1;state<=IDLE;
        end
    end
    LAST_WORD:begin
        data_read<=high_word;dok[owner]<=1;rdy[owner]<=1;
        next_owner<=owner+2'd1;state<=IDLE;
    end
    default:state<=IDLE;
    endcase
    if(!resetn)begin
        state<=IDLE;owner<=0;next_owner<=0;reading<=0;high_word<=0;
        ack<=0;dst<=0;dok<=0;rdy<=0;data_read<=0;
        mem_req<=0;mem_wr<=0;mem_addr<=0;mem_din<=0;mem_wmask<=0;fault<=0;
    end
end
endmodule
