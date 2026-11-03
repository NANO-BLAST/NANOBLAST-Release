// SPDX-License-Identifier: GPL-3.0-or-later
// Two independent writes and asynchronous reads. Per-byte ownership preserves
// the fx68k Y-port priority for a simultaneous write to the same byte.
module s16_fx68k_rf #(parameter WIDTH=8)(
 input clk, input [4:0] x,y, input wx,wy,
 input [WIDTH-1:0] dx,dy, output [WIDTH-1:0] qx,qy
);
 (* ram_style="distributed" *) reg [WIDTH-1:0] bank_x[0:31],bank_y[0:31];
 reg [17:0] owner;
 always @(posedge clk) begin
  if(wx) bank_x[x]<=dx;
  if(wy) bank_y[y]<=dy;
 end
 for(genvar i=0;i<18;i=i+1) begin
  always @(posedge clk)
   if(wy && y==i) owner[i]<=1;
   else if(wx && x==i) owner[i]<=0;
 end
 assign qx=owner[x]?bank_y[x]:bank_x[x];
 assign qy=owner[y]?bank_y[y]:bank_x[y];
endmodule
