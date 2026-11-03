`timescale 1ns/1ps
module frame_swap_tb;
reg src_clk=0,dst_clk=0;always #5 src_clk=~src_clk;always #7 dst_clk=~dst_clk;
reg src_resetn=0,dst_resetn=0,src_start=0,src_complete=0,dst_vblank=0;
wire src_ready,capture,write_buffer,read_buffer,display_valid;
s16_frame_swap dut(.*);
integer stamp[0:1];integer starts=0,captures=0,swaps=0,dropped=0,last_display=0;
integer n,frame_number,delay_count;
reg prev_buffer=0,prev_valid=0;
always @(posedge src_clk)begin
 #1;
 if(src_resetn && capture && display_valid)
  assert(write_buffer!=read_buffer)else $fatal(1,"Writer owns displayed buffer");
end
integer dst_cycle=0;
always @(negedge dst_clk)begin
 dst_cycle=dst_cycle+1;
 dst_vblank=(dst_cycle%79==0);
end
always @(posedge dst_clk)begin
 #1;
 if(!dst_resetn)begin prev_buffer=0;prev_valid=0;last_display=0;end
 else if(display_valid && (!prev_valid || read_buffer!=prev_buffer))begin
  assert(dst_vblank)else $fatal(1,"Buffer changed outside vblank");
  assert(!capture)else $fatal(1,"Swap overlapped frame capture");
  assert(stamp[read_buffer]>last_display)else $fatal(1,"Stale or incomplete frame displayed");
  last_display=stamp[read_buffer];swaps=swaps+1;
 end
 prev_buffer=read_buffer;prev_valid=display_valid;
end
initial begin
 stamp[0]=0;stamp[1]=0;
 repeat(4)@(negedge src_clk);src_resetn=1;dst_resetn=1;
 for(frame_number=1;frame_number<=240;frame_number=frame_number+1)begin
  @(negedge src_clk);src_start=1;starts=starts+1;
  @(negedge src_clk);src_start=0;
  if(capture)begin
   captures=captures+1;
   // Stamp remains invalid while SDRAM writes would still be in flight.
   stamp[write_buffer]=-frame_number;
   delay_count=35+(frame_number%17);
   repeat(delay_count)@(negedge src_clk);
   stamp[write_buffer]=frame_number;src_complete=1;
   @(negedge src_clk);src_complete=0;
   repeat(80-delay_count)@(negedge src_clk);
  end else begin
   dropped=dropped+1;repeat(81)@(negedge src_clk);
  end
 end
 repeat(200)@(negedge dst_clk);
 assert(swaps==captures&&swaps>60&&dropped>0)else $fatal(1,"Handshake missing a frame or no contention exercised");
 // Reset a published frame before the next display vblank.
 @(negedge src_clk);src_start=1;
 @(negedge src_clk);src_start=0;
 repeat(4)@(negedge src_clk);src_complete=1;
 @(negedge src_clk);src_complete=0;src_resetn=0;dst_resetn=0;
 repeat(5)@(negedge src_clk);
 assert(!capture&&!display_valid&&write_buffer==1&&read_buffer==0)else $fatal(1,"Stale ownership after reset");
 $display("PASS frame ownership CDC: %0d starts, %0d complete frames displayed, %0d whole frames dropped; vblank swaps, DMA-drain gating and reset",starts,swaps,dropped);
 $finish;
end
initial begin #500000;$fatal(1,"Frame test timeout");end
endmodule
