`timescale 1ns/1ps
module tb_cdc_mailbox;
reg src_clk=0,dst_clk=0,resetn=0,run_dst=1;
always #17 src_clk=~src_clk;
always #7 if(run_dst)dst_clk=~dst_clk;
wire dst_resetn;
reset_release reset_sync(dst_clk,resetn,dst_resetn);
reg [7:0] sequence_id=0;wire [15:0] source={sequence_id,~sequence_id};
wire [15:0] received;
cdc_mailbox mailbox(src_clk,resetn,source,dst_clk,dst_resetn,received);
always @(negedge src_clk)if(resetn)sequence_id<=sequence_id+1;
integer deliveries=0;
always @(negedge dst_clk)if(dst_resetn && received!=0)begin
 if(received[7:0]!==~received[15:8])$fatal(1,"torn word %h",received);
 deliveries=deliveries+1;
end
initial begin
 #23;resetn=1;
 @(posedge dst_clk);#1;if(dst_resetn)$fatal(1,"reset released before two edges");
 @(posedge dst_clk);#1;if(!dst_resetn)$fatal(1,"reset did not release");
 repeat(300)@(negedge src_clk);
 if(deliveries<100)$fatal(1,"no deliveries");
 @(negedge dst_clk);run_dst=0;
 repeat(10)@(negedge src_clk);
 begin reg [15:0] held;held=mailbox.held_data;
  repeat(100)begin @(negedge src_clk);if(mailbox.held_data!==held)$fatal(1,"pending data not held");end
 end
 run_dst=1;repeat(100)@(negedge src_clk);
 #3;resetn=0;#1;if(dst_resetn || received!==0)$fatal(1,"asynchronous reset failed");
 #19;resetn=1;repeat(100)@(negedge src_clk);
 $display("PASS complete audio words with unrelated clocks, destination stall, asynchronous reset and synchronized release");
 $finish;
end
initial begin #100000;$fatal(1,"timeout");end
endmodule
