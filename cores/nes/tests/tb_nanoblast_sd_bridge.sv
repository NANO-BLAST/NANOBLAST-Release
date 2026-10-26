module tb_nanoblast_sd_bridge #(parameter FREQ=21_600_000, SCALE=FREQ/21_600_000);
reg clk=0;always #5 clk=~clk;
reg resetn=0,valid=0;reg[7:0]data;wire[7:0]tx;wire tv,sck,mosi,cs;
wire[31:0]tw,cfg;wire twe,ov,loading,rv;wire[7:0]rom;wire[15:0]h1,h2;
reg miso=1;integer bitno=7,nbits=0,rxcount=0;reg[7:0]mosibyte=0,received[0:255],sent[0:255];
nanoblast_menu_link #(.FREQ(FREQ),.JOY_PERIOD_CYCLES(100000),.TIMEOUT_CYCLES(100)) dut(
.clk(clk),.resetn(resetn),.core_status(8'h01),.rx_data(data),.rx_valid(valid),.tx_data(tx),.tx_valid(tv),.tx_ready(1'b1),
.joy1(12'd0),.joy2(12'd0),.text_word(tw),.text_we(twe),.overlay_enable(ov),.core_config(cfg),.rom_loading(loading),.rom_data(rom),.rom_valid(rv),.hid1(h1),.hid2(h2),
.sd_clk(sck),.sd_mosi(mosi),.sd_cs_n(cs),.sd_miso(miso));
always@(posedge clk)if(tv)begin received[rxcount]=tx;rxcount=rxcount+1;end
always@(posedge sck)begin mosibyte={mosibyte[6:0],mosi};nbits=nbits+1;if(nbits%8==0)sent[nbits/8-1]=mosibyte;end
always@(negedge sck or posedge cs)begin if(cs)begin bitno=7;miso=1;end else begin bitno=bitno==0?7:bitno-1;miso=(8'ha5>>bitno)&1;end end
task byte_in(input[7:0]v);begin @(negedge clk);data=v;valid=1;@(negedge clk);valid=0;end endtask
task header(input[15:0]len);begin byte_in(8'haa);byte_in(len[15:8]);byte_in(len[7:0]);byte_in(16);end endtask
integer i,cycles=0,rise=0;reg slow=0;
always @(posedge clk)cycles=cycles+1;
always @(posedge sck)rise=cycles;
always @(negedge sck)if(resetn&&nbits!=0)
 if(cycles-rise!=(slow?FREQ/337500:FREQ/10800000))$fatal(1,"SD SPI high pulse frequency");
initial begin
 repeat(2)@(negedge clk);resetn=1;
 header(4);byte_in(2);byte_in(8'h12);byte_in(8'h34);
 repeat(100*SCALE)@(negedge clk);
 $display("rxcount=%d bytes=%h %h %h %h %h %h nbits=%d",rxcount,received[0],received[1],received[2],received[3],received[4],received[5],nbits);
 if(rxcount!=6||received[0]!=8'haa||received[2]!=3||received[3]!=16||received[4]!=8'ha5||received[5]!=8'ha5)$fatal(1,"SPI response framing/data");
 if(nbits!=16||sent[0]!=8'h12||sent[1]!=8'h34||cs)$fatal(1,"SPI MOSI/CS");
 header(2);byte_in(3);repeat(20*SCALE)@(negedge clk);
 if(!cs||nbits!=16||rxcount!=10||received[8]!=1||received[9]!=16)$fatal(1,"zero-length chipselect");
 header(34);byte_in(2);for(i=0;i<32;i=i+1)byte_in(i);
 repeat(1200*SCALE)@(negedge clk);
 if(rxcount!=46||received[12]!=33||received[13]!=16||nbits!=272)$fatal(1,"maximum SPI packet");
 for(i=0;i<32;i=i+1)if(received[14+i]!=8'ha5||sent[2+i]!=i)$fatal(1,"SPI byte order");
 slow=1;header(3);byte_in(0);byte_in(8'haa);repeat(1200*SCALE)@(negedge clk);
 if(nbits!=280||sent[34]!=8'haa||rxcount!=51||received[50]!=8'ha5)$fatal(1,"Slow SD SPI transaction");
 $display("PASS onboard SD bridge: MOSI, MISO, SPI mode 0, CS, length 0/2/32, framed replies");$finish;
end
endmodule
