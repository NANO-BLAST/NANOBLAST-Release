module tb_nanoblast_artwork;
reg clk=0;always #5 clk=~clk;
reg resetn=0,valid=0,ready=0;reg[7:0]data;
wire[7:0]tx;wire tv,en,pwe,rv;wire[31:0]pal,wd;wire[22:0]addr;wire[3:0]strb;
integer replies=0,writes=0;reg[7:0]response[0:255];reg[31:0]words[0:15];reg[22:0]addresses[0:15];
nanoblast_menu_link #(.JOY_PERIOD_CYCLES(100000),.TIMEOUT_CYCLES(100)) dut(
 .clk(clk),.resetn(resetn),.rx_data(data),.rx_valid(valid),.tx_data(tx),.tx_valid(tv),.tx_ready(1'b1),
 .joy1(12'd0),.joy2(12'd0),.sd_miso(1'b1),.background_enable(en),.background_palette_we(pwe),
 .background_palette_data(pal),.rv_valid(rv),.rv_ready(ready),.rv_addr(addr),.rv_wdata(wd),.rv_wstrb(strb));
always@(posedge clk)begin
 if(tv)begin response[replies]=tx;replies=replies+1;end
 if(rv&&ready)begin words[writes]=wd;addresses[writes]=addr;writes=writes+1;if(strb!=15)$fatal(1,"write strobes");end
end
task byte_in(input[7:0]v);begin @(negedge clk);data=v;valid=1;@(negedge clk);valid=0;end endtask
task header(input[15:0]len,input[7:0]cmd);begin byte_in(8'haa);byte_in(len[15:8]);byte_in(len[7:0]);byte_in(cmd);end endtask
task address(input[31:0]a);begin byte_in(a[31:24]);byte_in(a[23:16]);byte_in(a[15:8]);byte_in(a[7:0]);end endtask
task pixel;begin byte_in(8'h11);byte_in(8'h22);byte_in(8'haa);byte_in(8'h44);end endtask
task wait_reply;begin repeat(20)@(negedge clk);end endtask
initial begin
 repeat(2)@(negedge clk);resetn=1;
 if(en)$fatal(1,"background must start disabled");
 header(5,18);address(32'hfa123456);
 if(!pwe||pal!=32'hfa123456)$fatal(1,"palette atomic commit");
 header(9,19);address(32'h00200000);pixel;
 repeat(20)@(negedge clk);
 if(!rv||addr!=23'h200000||wd!=32'h44aa2211||replies)$fatal(1,"word must wait for memory acknowledgement");
 ready=1;wait_reply;
 if(writes!=1||replies!=5||response[3]!=19||response[4]!=0)$fatal(1,"pixel acknowledgement");
 header(13,19);address(32'h00200004);pixel;pixel;wait_reply;
 if(writes!=3||addresses[1]!=23'h200004||addresses[2]!=23'h200008||replies!=10||response[9]!=0)$fatal(1,"multiple words");
 header(9,19);address(32'h002e1000);pixel;wait_reply;
 if(writes!=3||response[14]!=1)$fatal(1,"upper bound");
 header(9,19);address(32'hfffffffC);pixel;wait_reply;
 if(writes!=3||response[19]!=1)$fatal(1,"overflow address");
 header(9,19);address(32'h00200001);pixel;wait_reply;
 if(writes!=3||response[24]!=1)$fatal(1,"unaligned address");
 header(2,17);byte_in(1);if(!en)$fatal(1,"artwork enable");
 header(2,17);byte_in(0);if(en)$fatal(1,"artwork disable");
 $display("PASS artwork bridge: palette, byte order, address bounds, multiple words, delayed memory ACK, enable");$finish;
end
initial begin #100000;$fatal(1,"timeout");end
endmodule
