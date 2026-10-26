// SD SPI transaction engine for the onboard-card MCU bridge. GPL-3.0.
module nanoblast_sd_spi #(parameter integer FREQ=21_600_000,CS_TIMEOUT_CYCLES=0)(input clk,resetn,start,input[7:0]length,flags,
 output reg[6:0]tx_index,input[7:0]tx_byte,
 output reg[6:0]rx_index,output reg[7:0]rx_byte,output reg rx_we,done,busy,
 output reg sck,mosi,cs_n,input miso);
reg[31:0]cs_idle;
reg[1:0]state;reg[15:0]divider;reg[2:0]bit_index;reg[7:0]shift;
wire[15:0]half_period=flags[1]?(FREQ/10_800_000):(FREQ/337_500);
always @(posedge clk or negedge resetn)begin
 if(!resetn)begin cs_idle<=0;state<=0;divider<=0;bit_index<=7;shift<=0;tx_index<=0;rx_index<=0;rx_byte<=0;rx_we<=0;done<=0;busy<=0;sck<=0;mosi<=1;cs_n<=1;end
 else begin
  rx_we<=0;done<=0;
  if(CS_TIMEOUT_CYCLES!=0)begin
   if(start||busy||cs_n)cs_idle<=0;
   else if(cs_idle>=CS_TIMEOUT_CYCLES-1)begin cs_n<=1;cs_idle<=0;end
   else cs_idle<=cs_idle+1;
  end
  case(state)
  0:if(start)begin cs_n<=flags[0];sck<=0;tx_index<=0;busy<=1;divider<=0;state<=3;
    if(length==0)begin done<=1;busy<=0;state<=0;end end
  3:begin mosi<=tx_byte[7];bit_index<=7;divider<=0;state<=1;end
  1:if(divider==half_period-1)begin divider<=0;sck<=1;shift<={shift[6:0],miso};state<=2;end else divider<=divider+1;
  2:if(divider==half_period-1)begin
    divider<=0;sck<=0;
    if(bit_index!=0)begin bit_index<=bit_index-1;mosi<=tx_byte[bit_index-1];state<=1;end
    else begin rx_index<=tx_index;rx_byte<=shift;rx_we<=1;
     if({1'b0,tx_index}+1==length)begin state<=0;busy<=0;done<=1;mosi<=1;end
     else begin tx_index<=tx_index+1;state<=3;end
    end
   end else divider<=divider+1;
  endcase
 end
end
endmodule
