`timescale 1ns/1ps
module pipeline_tb;
reg clk=0,hclk=0;always #18.518519 clk=~clk;always #6.734007 hclk=~hclk;
wire hclk5=hclk;reg resetn=0;wire pixel_resetn=resetn;
reg overlay=1,loading=0,load_valid=0;reg[7:0]load_data=0;
wire[11:0]pad1=0,pad2=0,ds1=0,ds2=0,hid1=0,hid2=0;
wire[11:0]joy1_buttons=pad1,joy2_buttons=pad2;
wire ds1_valid=0,ds2_valid=0;
reg background_enable=0,background_oled=0,palette_we=0;reg[31:0]palette_data=0;
reg rv_valid=0;reg[22:0]rv_addr=0;reg[31:0]rv_wdata=0;reg[3:0]rv_wstrb=0;wire rv_ready;
wire[10:0]overlay_x;wire[9:0]overlay_y;wire[15:0]overlay_color=0;
reg[7:0]debug_index=0;reg[31:0]debug_value;wire[1:0]led;
wire O_sdram_clk=~clk;wire O_sdram_cke,O_sdram_cs_n,O_sdram_cas_n,O_sdram_ras_n,O_sdram_wen_n;
wire[10:0]O_sdram_addr;wire[1:0]O_sdram_ba;wire[3:0]O_sdram_dqm;wire[31:0]IO_sdram_dq;
wire tmds_clk_n,tmds_clk_p;wire[2:0]tmds_d_n,tmds_d_p;
wire running,load_fault,host_fault,fault;
reg save_rx_start=0,save_rx_valid=0,save_rx_last=0;reg[7:0]save_rx_data=0;reg[15:0]save_rx_length=0;
wire save_tx_valid,save_tx_last;wire save_tx_ready=1;wire[7:0]save_tx_data;
wire save_pause,save_mem_req,save_mem_we,save_mem_ack,save_rtc_wr,rtc_written;
wire[16:0]save_mem_addr,save_rtc_addr;wire[15:0]save_rtc_data;
wire[31:0]save_generation,save_mem_wdata,save_mem_rdata,rtc_timestamp;wire[47:0]rtc_value;
sdram_model model(.clk(O_sdram_clk),.cke(O_sdram_cke),.cs_n(O_sdram_cs_n),.ras_n(O_sdram_ras_n),.cas_n(O_sdram_cas_n),.we_n(O_sdram_wen_n),.dqm(O_sdram_dqm),.addr(O_sdram_addr),.ba(O_sdram_ba),.dq(IO_sdram_dq));

// @BOARD_BODY@

reg[7:0]save_packet[0:279],save_response[0:279];integer save_len=0,save_replies=0;
always @(posedge clk)if(save_tx_valid)begin save_response[save_len]<=save_tx_data;save_len<=save_len+1;if(save_tx_last)save_replies<=save_replies+1;end
function automatic[31:0]save_crc(input[31:0]old,input[7:0]v);reg[31:0]c;integer n;begin c=old^v;for(n=0;n<8;n++)c=c[0]?(c>>1)^32'hedb88320:c>>1;save_crc=c;end endfunction
task save_command(input integer op,count,databytes);integer n,target;reg[31:0]c;begin
 save_len=0;target=save_replies+1;save_packet[0]=op;save_packet[1]=0;save_packet[2]=op;save_packet[3]=0;save_packet[4]=0;save_packet[5]=0;save_packet[6]=count>>8;save_packet[7]=count;
 c=~0;for(n=0;n<8+databytes;n++)c=save_crc(c,save_packet[n]);c=~c;for(n=0;n<4;n++)save_packet[8+databytes+n]=c>>(24-n*8);
 @(negedge clk);save_rx_start=1;save_rx_length=12+databytes;@(negedge clk);save_rx_start=0;
 for(n=0;n<12+databytes;n++)begin save_rx_valid=1;save_rx_last=n==11+databytes;save_rx_data=save_packet[n];@(negedge clk);end
 save_rx_valid=0;save_rx_last=0;wait(save_replies==target);@(negedge clk);if(save_response[6]!=0)$fatal(1,"Physical save command %d failed %d",op,save_response[6]);
end endtask
integer frames=0,pixels=0,rgb_count=0,k,batch,boot_end=0;
reg old_vs=0;reg[32767:0]colors=0;
reg[23:0]seen_rgb[0:31];reg found;
always @(posedge clk)begin
 if(resetn&&fault)$fatal(1,"Pipeline fault: load%0d host%0d frame%0d line%0d crc%h/%h",load_fault,host_fault,frame_overflow,line_overrun,received_crc,read_crc);
 if(ce&&running)begin
  old_vs<=lcd_vs;if(lcd_vs&&!old_vs)frames<=frames+1;
  if(!debug_boot&&lcd_ce&&lcd_on)begin colors[lcd_pixel]<=1;pixels<=pixels+1;end
 end
end
always @(posedge hclk)if(!overlay&&!debug_boot&&video.active_d&&video.ready_d)begin
 found=0;for(k=0;k<rgb_count;k=k+1)if(seen_rgb[k]==video.rgb)found=1;
 if(!found&&rgb_count<32)begin seen_rgb[rgb_count]=video.rgb;rgb_count=rgb_count+1;end
end
reg[7:0]rom[0:4194303];integer f,bytes,i;string path;reg expected_cgb;integer required_colors;
task byte_in(input[7:0]v);begin repeat(20)@(negedge clk);load_data=v;load_valid=1;@(negedge clk);load_valid=0;end endtask
initial begin
 if(!$value$plusargs("ROM=%s",path))$fatal(1,"ROM required");
 f=$fopen(path,"rb");if(!f)$fatal(1,"ROM open");bytes=$fread(rom,f);$fclose(f);expected_cgb=rom[16'h143][7];required_colors=expected_cgb?5:4;
 repeat(50)@(negedge clk);resetn=1;wait(ram_ready);repeat(50)@(negedge clk);
 loading=1;repeat(5)@(negedge clk);
 byte_in("N");byte_in("B");byte_in("G");byte_in("B");byte_in(rom['h147]);byte_in(rom['h148]);byte_in(rom['h149]);byte_in(0);
 for(i=0;i<bytes;i=i+1)byte_in(rom[i]);
 repeat(30)@(negedge clk);loading=0;wait(running||fault);
 if(!running||received_crc!=read_crc||rom_size!=bytes)$fatal(1,"ROM load/verify failed");
 repeat(200)@(negedge clk);
 if(!paused||gb_cycles!=0)$fatal(1,"Menu failed to keep game paused");
 $display("ROM/SDRAM verified, header cgb=%0d size=%0d",cgb,rom_size);$fflush();overlay=0;
 begin:game_run
  for(batch=0;batch<180;batch=batch+1)begin
   repeat(2000000)@(negedge clk);
   if(!debug_boot&&pixels>46080&&$countones(colors)>=required_colors&&rgb_count>=required_colors)disable game_run;
   if(batch%20==19)begin $display("progress cycles%0d CPU%h boot%0d frames%0d pixels%0d RGB%0d",gb_cycles,debug_pc,debug_boot,frames,pixels,rgb_count);$fflush();end
  end
 end
 $display("RESULT pipeline cgb=%0d speed=%0d boot=%0d frames=%0d pixels=%0d colours=%0d HDMI_RGB=%0d underflow=%0d",cgb,speed,debug_boot,frames,pixels,$countones(colors),rgb_count,video_underflow);
 if(video_underflow||debug_boot||cgb!=expected_cgb||(!expected_cgb&&speed)||pixels<46080||$countones(colors)<required_colors||rgb_count<required_colors)$fatal(1,"Colour pipeline failed");
 // Opening the menu pauses execution while line scanout/refresh continue.
 overlay=1;wait(paused);repeat(500)@(negedge clk);boot_end=gb_cycles;
 repeat(1000)@(negedge clk);if(gb_cycles!=boot_end)$fatal(1,"Menu pause leaked cycles");
 save_command(1,0,0);
 for(i=0;i<256;i++)save_packet[8+i]=i^8'h5a;
 save_command(3,256,256);save_command(2,256,0);
 for(i=0;i<256;i++)if(save_response[7+i]!=(i^8'h5a))$fatal(1,"Physical SDRAM save mismatch %d",i);
 save_command(5,0,0);
 $display("PASS physical SDRAM battery page write/read and pause/release");
 $display("PASS NBGB load, physical SDRAM readback, CGB CPU/PPU double speed, colour frame writes/HDMI scanout and menu pause");$finish;
end
initial begin #5000000000;$fatal(1,"pipeline timeout");end
endmodule
