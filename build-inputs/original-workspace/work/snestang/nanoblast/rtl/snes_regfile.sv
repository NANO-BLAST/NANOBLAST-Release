// Synchronous read-before-write register file in Gowin block RAM.
// Delay physical writes one edge and forward that pending value to reads.
// Every physical mixed-port collision is thus bypassed, while the externally
// visible port retains exactly the original one-edge read-before-write timing.
module snes_regfile(
 input clk,we,input[6:0]wr_addr,rd_addr,input[7:0]data,
 output[7:0]q
);
 (* ram_style="block",no_rw_check *) reg[7:0]mem[0:127];
 reg pending=0;reg[6:0]address;reg[7:0]value;
 reg bypass;reg[7:0]forwarded,ram_q;
 always @(posedge clk)begin
  if(pending)mem[address]<=value;
  ram_q<=mem[rd_addr];
  bypass<=pending&&address==rd_addr;forwarded<=value;
  pending<=we;address<=wr_addr;value<=data;
 end
 assign q=bypass?forwarded:ram_q;
endmodule
