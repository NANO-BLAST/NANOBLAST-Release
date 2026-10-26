// 4.194304/8.388608 MHz phase enables from the existing 27 MHz clock.
// Enables change on the falling edge, matching the MiSTer engine contract.
// Finish the second half before pausing; never shorten or repeat an enable.
module nanoblast_gbc_ce(input clk,resetn,enable,memory_ready,
 output reg ce=0,ce_n=0,ce_2x=0,paused=0);
localparam [31:0] STEP=32'd1334399889;
reg [31:0] fraction=0;reg half=0;
wire [32:0] next_fraction={1'b0,fraction}+{1'b0,STEP};
always @(negedge clk)begin
 ce<=0;ce_n<=0;ce_2x<=0;
 if(!resetn)begin fraction<=0;half<=0;paused<=0;end
 else if(!enable&&!half)paused<=1;
 else begin
  paused<=0;
  if(!next_fraction[32])fraction<=next_fraction[31:0];
  else if(memory_ready)begin
   fraction<=next_fraction[31:0];half<=~half;
   ce_2x<=1;ce<=!half;ce_n<=half;
  end
 end
end
endmodule
