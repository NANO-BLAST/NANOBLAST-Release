// SPDX-License-Identifier: GPL-3.0-or-later
// Adapted from jtframe_pole.v by Jose Tejada. The board's fixed coefficients
// and 192 kHz sample pulse leave over 250 clocks between successive samples.
module jtframe_pole #(parameter WS=16, WA=WS/2)(
 input rst,clk,sample,
 input signed [WS-1:0] sin,
 input [WA-1:0] a,
 output signed [WS-1:0] sout
);
localparam signed [WS-1:0] ONE = 1 << WA;
wire signed [WS-1:0] feedback_gain = $signed({1'b0,a});
wire signed [WS-1:0] input_gain = ONE - feedback_gain;
reg signed [WS-1:0] previous_input, current_input;
reg signed [WS:0] input_sum, full_out;
reg signed [2*WS-1:0] feedback_product, input_product;
reg [2:0] pending;
wire signed [2*WS-1:0] sum = feedback_product + input_product;
assign sout = full_out[WS:1];
always @(posedge clk) begin
 if(rst) begin
  previous_input<=0;current_input<=0;input_sum<=0;full_out<=0;
  feedback_product<=0;input_product<=0;pending<=0;
 end else begin
  pending<={pending[1:0],sample};
  if(sample) begin
   previous_input<=current_input;
   current_input<=sin;
   if(a==0) full_out<={sin,1'b0};
  end
  if(pending[0]) begin
   input_sum<=$signed({current_input[WS-1],current_input})+
              $signed({previous_input[WS-1],previous_input});
   feedback_product<=feedback_gain * full_out;
  end
  if(pending[1]) input_product<=input_gain * input_sum;
  if(pending[2] && a!=0) full_out<=sum[WA+:WS+1];
 end
end
endmodule
