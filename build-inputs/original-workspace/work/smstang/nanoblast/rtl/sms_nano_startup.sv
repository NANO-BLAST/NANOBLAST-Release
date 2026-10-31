// Configuration-time startup, following the working Nano NES clock/reset model.
// The transport must answer before any ROM is loaded. External spare pins and
// PLL LOCK outputs must not hold the complete UART/menu subsystem in reset.
module sms_nano_startup #(
 parameter integer HOLD_CYCLES=65536,
 parameter integer WIDTH=$clog2(HOLD_CYCLES)
)(input wire clk,output reg ready=0);
reg[WIDTH-1:0]count=HOLD_CYCLES-1;
always @(posedge clk)begin
 if(count!=0)count<=count-1'b1;
 else ready<=1;
end
endmodule
