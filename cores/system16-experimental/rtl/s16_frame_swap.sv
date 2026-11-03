// SPDX-License-Identifier: GPL-3.0-or-later
// Ownership handshake for two external framebuffers in unrelated clock domains.
// src_complete means the entire frame has reached SDRAM, including DMA drain.
// A source frame may only write when capture is high. Frames arriving while
// ownership is pending are dropped whole; the game itself is never stalled.
// Both domains must reset together, with reset release synchronized locally.
module s16_frame_swap(
    input wire src_clk,src_resetn,src_start,src_complete,
    output wire src_ready,
    output reg capture=0,
    output reg write_buffer=1,
    input wire dst_clk,dst_resetn,dst_vblank,
    output reg read_buffer=0,
    output reg display_valid=0
);
reg published=0,pending=0,acknowledged=0;
assign src_ready=!pending;
(* async_reg="true" *) reg ack_meta=0,ack_sync=0;
(* async_reg="true" *) reg request_meta=0,request_sync=0;
always @(posedge src_clk) begin
    ack_meta<=acknowledged;
    ack_sync<=ack_meta;
    if(pending && ack_sync==published) begin
        pending<=0;
        write_buffer<=~write_buffer;
    end
    if(src_start) capture<=!pending;
    if(src_complete && capture) begin
        published<=~published;
        pending<=1;
        capture<=0;
    end
    if(!src_resetn) begin
        ack_meta<=0;ack_sync<=0;published<=0;pending<=0;
        capture<=0;write_buffer<=1;
    end
end
always @(posedge dst_clk) begin
    request_meta<=published;
    request_sync<=request_meta;
    if(dst_vblank && request_sync!=acknowledged) begin
        read_buffer<=~read_buffer;
        display_valid<=1;
        acknowledged<=request_sync;
    end
    if(!dst_resetn) begin
        request_meta<=0;request_sync<=0;acknowledged<=0;
        read_buffer<=0;display_valid<=0;
    end
end
endmodule
