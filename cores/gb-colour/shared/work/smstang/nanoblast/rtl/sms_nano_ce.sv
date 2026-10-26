// Keep both physical PLLs available for SDRAM and HDMI. A fractional enable
// produces the original 53.693175MHz SMS master timing inside the 64.8MHz domain.
module sms_nano_ce(input clk,resetn,enable,output reg ce_cpu,ce_vdp,ce_pix,ce_sp);
localparam [32:0] STEP=33'd3558802942; // round(53.693175/64.8 * 2^32)
reg[31:0]fraction;reg[4:0]phase;
wire[32:0]next_fraction={1'b0,fraction}+STEP;
always @(posedge clk)begin
 ce_cpu<=0;ce_vdp<=0;ce_pix<=0;ce_sp<=0;
 if(enable)begin
  fraction<=next_fraction[31:0];
  if(next_fraction[32])begin
   phase<=phase==29?0:phase+1'b1;
   ce_sp<=phase[0];
   ce_vdp<=phase==4||phase==9||phase==14||phase==19||phase==24||phase==29;
   ce_pix<=phase==9||phase==19||phase==29;
   ce_cpu<=phase==9||phase==24;
  end
 end
 if(!resetn)begin fraction<=0;phase<=0;ce_cpu<=0;ce_vdp<=0;ce_pix<=0;ce_sp<=0;end
end
endmodule
