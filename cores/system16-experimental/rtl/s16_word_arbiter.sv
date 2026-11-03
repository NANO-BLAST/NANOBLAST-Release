// SPDX-License-Identifier: GPL-3.0-or-later
// Four synchronous 16-bit toggle-request clients share an aligned x32 channel.
// Addresses are physical SDRAM byte addresses divided by two. Clients must
// hold their payload until their acknowledgement matches the request toggle.
// wmask is active high: bit 0 enables the low byte, bit 1 the high byte.
// All clients and the downstream memory channel must share clk/resetn.
module s16_word_arbiter (
    input wire clk, resetn,
    input wire [3:0] req, wr,
    input wire [87:0] addr,
    input wire [63:0] din,
    input wire [7:0] wmask,
    output reg [3:0] ack=0,
    output reg [63:0] dout=0,
    output reg mem_req=0, mem_wr=0,
    output reg [22:0] mem_addr=0,
    output reg [31:0] mem_din=0,
    output reg [3:0] mem_wmask=0,
    input wire mem_ack,
    input wire [31:0] mem_dout
);
reg busy=0, upper=0;
reg [1:0] owner=0, next_owner=0;
reg owner_request=0;
reg found;
reg [1:0] selected, candidate;
integer i;
always @* begin
    found=0;
    selected=next_owner;
    candidate=0;
    for(i=0;i<4;i=i+1) begin
        candidate=next_owner+i;
        if(!found && req[candidate]!=ack[candidate]) begin
            found=1;
            selected=candidate;
        end
    end
end
wire [21:0] selected_address=addr[selected*22+:22];
always @(posedge clk) begin
    if(!resetn) begin
        ack<=0; dout<=0; mem_req<=0; mem_wr<=0; mem_addr<=0;
        mem_din<=0; mem_wmask<=0; busy<=0; upper<=0;
        owner<=0; next_owner<=0; owner_request<=0;
    end else if(busy) begin
        if(mem_ack==mem_req) begin
            dout[owner*16+:16]<=upper?mem_dout[31:16]:mem_dout[15:0];
            ack[owner]<=owner_request;
            next_owner<=owner+2'd1;
            busy<=0;
        end
    end else if(found) begin
        owner<=selected;
        owner_request<=req[selected];
        upper<=selected_address[0];
        mem_addr<={selected_address[21:1],2'b00};
        mem_din<={2{din[selected*16+:16]}};
        mem_wmask<=selected_address[0]?{wmask[selected*2+:2],2'b00}:
                                              {2'b00,wmask[selected*2+:2]};
        mem_wr<=wr[selected];
        mem_req<=~mem_req;
        busy<=1;
    end
end
endmodule
