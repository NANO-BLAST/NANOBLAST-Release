// Assert immediately; release only after two local clock edges.
module reset_release(input clk,async_resetn,output resetn);
 (* syn_preserve=1 *) reg [1:0] pipe=0;
 always @(posedge clk or negedge async_resetn)
  if(!async_resetn)pipe<=0;else pipe<={pipe[0],1'b1};
 assign resetn=pipe[1];
endmodule
