// Exact average 32768 Hz from 27 MHz, independent of CPU pauses/stalls.
module nanoblast_gbc_rtc_tick #(parameter integer FREQ=27000000)(
 input clk, resetn, output reg ce_32k=0);
reg [24:0] fraction=0;
wire [25:0] next_fraction={1'b0,fraction}+26'd32768;
always @(posedge clk) begin
 ce_32k<=0;
 if(!resetn) fraction<=0;
 else if(next_fraction>=FREQ) begin fraction<=next_fraction-FREQ;ce_32k<=1;end
 else fraction<=next_fraction;
end
endmodule
