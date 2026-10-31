// Bundled-data mailbox: the source holds a complete word until the
// destination captures it and its acknowledgment crosses back. Updates
// while busy coalesce; this is appropriate for the current audio level,
// not for a lossless event queue.
module cdc_mailbox #(parameter WIDTH=16)(
 input src_clk,src_resetn,input [WIDTH-1:0] src_data,
 input dst_clk,dst_resetn,output reg [WIDTH-1:0] dst_data
);
 reg [WIDTH-1:0] held_data;
 reg request,acknowledge;
 (* syn_preserve=1 *) reg ack_meta,ack_sync,req_meta,req_sync;
 always @(posedge src_clk or negedge src_resetn)begin
  if(!src_resetn)begin held_data<=0;request<=0;ack_meta<=0;ack_sync<=0;end
  else begin
   ack_meta<=acknowledge;ack_sync<=ack_meta;
   if(ack_sync==request)begin
    held_data<=src_data;request<=~request;
   end
  end
 end
 always @(posedge dst_clk or negedge dst_resetn)begin
  if(!dst_resetn)begin req_meta<=0;req_sync<=0;acknowledge<=0;dst_data<=0;end
  else begin
   req_meta<=request;req_sync<=req_meta;
   if(req_sync!=acknowledge)begin
    dst_data<=held_data;acknowledge<=req_sync;
   end
  end
 end
endmodule
