module tb_nanoblast_menu_link;
reg clk=0;always #5 clk=~clk;
reg resetn=0,rx_valid=0,tx_ready=1;
reg [7:0] rx_data;
wire [7:0] tx_data,rom_data;wire tx_valid,text_we,overlay_enable,rom_loading,rom_valid;
wire background_enable,background_oled;
wire [31:0] text_word,core_config;wire [15:0] hid1,hid2;
reg [7:0] received[0:255];integer tx_count=0,writes=0,rom_count=0;
reg [31:0] last_word;
nanoblast_menu_link #(.TIMEOUT_CYCLES(20),.JOY_PERIOD_CYCLES(10000)) dut(
.clk(clk),.resetn(resetn),.core_status(8'h03),.rx_data(rx_data),.rx_valid(rx_valid),.tx_data(tx_data),.tx_valid(tx_valid),.tx_ready(tx_ready),
.joy1(12'h123),.joy2(12'h456),.text_word(text_word),.text_we(text_we),.overlay_enable(overlay_enable),
.background_enable(background_enable),.background_oled(background_oled),.core_config(core_config),.rom_loading(rom_loading),.rom_data(rom_data),.rom_valid(rom_valid),.hid1(hid1),.hid2(hid2));
always @(posedge clk) begin
 if(tx_valid&&tx_ready)begin received[tx_count]=tx_data;tx_count=tx_count+1;end
 if(text_we)begin writes=writes+1;last_word=text_word;end
 if(rom_valid)begin
  if(rom_data!=(rom_count==0?8'haa:8'h00))$fatal(1,"ROM bytes changed");
  rom_count=rom_count+1;
 end
end
task byte_in(input [7:0] value);begin @(negedge clk);rx_data=value;rx_valid=1;@(negedge clk);rx_valid=0;end endtask
task header(input [15:0] len,input [7:0] cmd);begin byte_in(8'haa);byte_in(len[15:8]);byte_in(len[7:0]);byte_in(cmd);end endtask
task settle;begin repeat(3)@(negedge clk);end endtask
initial begin
 repeat(2)@(negedge clk);resetn=1;
 header(1,1);repeat(10)@(negedge clk);
 if(tx_count!=5||received[0]!=8'haa||received[1]!=0||received[2]!=2||received[3]!=1||received[4]!=1)$fatal(1,"core reply frame");
 header(3,4);byte_in(2);byte_in(14);
 header(3,5);byte_in("O");byte_in("K");settle;
 if(writes!=2||last_word!=32'h00030e4b)$fatal(1,"text cursor/stream");
 header(5,14);byte_in(3);byte_in(8'h10);byte_in(8'h84);
 if(writes!=2)$fatal(1,"partial panel write");
 byte_in(8'h21);settle;
 if(writes!=3||last_word!=32'h03108421)$fatal(1,"panel command");
 header(4,14);byte_in(3);byte_in(1);byte_in(2);settle;
 if(writes!=3)$fatal(1,"bad length accepted");
 header(2,6);byte_in(1);header(3,7);byte_in(8'haa);byte_in(0);settle;
 if(rom_count!=2)$fatal(1,"ROM frame length or AA handling");
 header(2,6);byte_in(0);header(2,7);byte_in(99);settle;
 if(rom_count!=2)$fatal(1,"ROM written outside loading");
 header(5,3);byte_in(0);byte_in(0);byte_in(0);byte_in(4);settle;
 if(core_config!=4)$fatal(1,"core config");
 header(5,9);byte_in(1);byte_in(2);byte_in(3);byte_in(4);settle;
 if(hid1!=16'h0102||hid2!=16'h0304)$fatal(1,"HID");
 header(2,8);byte_in(0);settle;if(overlay_enable)$fatal(1,"overlay disable");
 // Timeout a truncated fixed-width command; a following frame must decode.
 header(5,14);byte_in(3);repeat(25)@(negedge clk);
 header(2,8);byte_in(1);settle;
 if(!overlay_enable||writes!=3)$fatal(1,"timeout recovery");
 // Backpressure must preserve the entire ID response.
 tx_ready=0;header(1,1);repeat(5)@(negedge clk);
 if(!tx_valid||tx_data!=8'haa)$fatal(1,"response backpressure");
 tx_ready=1;repeat(10)@(negedge clk);
 if(tx_count!=10)$fatal(1,"response dropped");
 header(1,20);repeat(10)@(negedge clk);
 if(tx_count!=15||received[13]!=20||received[14]!=3)$fatal(1,"core loader status reply");
 header(5,14);byte_in(4);byte_in(8'h30);byte_in(8'h3c);byte_in(0);settle;
 if(writes!=4||last_word!=32'h04303c00)$fatal(1,"layout command not committed atomically");
 header(5,14);byte_in(5);byte_in(0);byte_in(0);byte_in(0);settle;
 if(writes!=4)$fatal(1,"unsupported layout command accepted");
 header(2,17);settle;
 if(background_enable||background_oled)$fatal(1,"partial OLED command changed backdrop");
 byte_in(2);settle;
 if(background_enable||!background_oled)$fatal(1,"OLED on must disable artwork DMA");
 header(3,17);byte_in(1);byte_in(0);settle;
 if(background_enable||!background_oled)$fatal(1,"malformed OLED command accepted");
 header(2,17);byte_in(1);settle;
 if(!background_enable||background_oled)$fatal(1,"Artwork on must disable OLED");
 resetn=0;settle;resetn=1;settle;
 if(background_enable||background_oled)$fatal(1,"OLED reset state");
 $display("PASS MCU link: framing, text, atomic panel/OLED, lengths, ROM, config, HID, timeout, TX backpressure");$finish;
end
endmodule
