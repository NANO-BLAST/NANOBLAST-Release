`timescale 1ns/1ps
module loader_tb;
reg clk=0;always #5 clk=~clk;
reg resetn=0,loading=0,valid=0,ready=0,rv_valid=0;reg[7:0]data=0;reg[22:0]rv_addr=0;
wire req,wr,waitn,running,fault,rv_ready;wire[22:0]addr;wire[7:0]din,rom_data,save_data;
reg ack=0;reg[7:0]dout=0;reg[7:0]ram[0:8388607];integer pending=0;
reg req_copy,write_copy;reg[22:0]addr_copy;reg[7:0]data_copy;
sms_nano_memory dut(.clk(clk),.resetn(resetn),.loading(loading),.load_valid(valid),.load_data(data),
 .rom_rd(1'b0),.rom_addr(22'd0),.rom_data(rom_data),.save_rd(1'b0),.save_we(1'b0),.save_addr(15'd0),.save_din(8'd0),.save_dout(save_data),
 .cpu_wait_n(waitn),.running(running),.fault(fault),.rv_valid(rv_valid),.rv_addr(rv_addr),.rv_wdata(32'h12345678),.rv_wstrb(4'hf),.rv_ready(rv_ready),
 .req(req),.wr(wr),.addr(addr),.din(din),.ack(ack),.dout(dout),.ready(ready));
always @(posedge clk)begin
 if(pending!=0)begin pending<=pending-1;if(pending==1)begin if(write_copy)ram[addr_copy]<=data_copy;else dout<=ram[addr_copy];ack<=req_copy;end end
 else if(req!=ack&&ready)begin pending<=4;req_copy<=req;write_copy<=wr;addr_copy<=addr;data_copy<=din;end
 if(!resetn)begin ack<=0;pending<=0;end
end
task reset;begin resetn=0;loading=0;valid=0;rv_valid=0;repeat(3)@(negedge clk);resetn=1;@(negedge clk);end endtask
task stream(input integer length,input integer gap);integer i;begin
 loading=1;@(negedge clk);
 for(i=0;i<length;i=i+1)begin valid=1;data=i;@(negedge clk);valid=0;repeat(gap)@(negedge clk);end
 loading=0;@(negedge clk);
end endtask
integer i;
initial begin
 reset();ready=0;stream(80,1);assert(fault&&!running)else $fatal(1,"FIFO overflow did not fail closed");
 reset();ready=1;stream(8191,12);repeat(3)@(negedge clk);assert(fault&&!running)else $fatal(1,"Invalid-size image started");
 reset();stream(0,1);assert(fault&&!running)else $fatal(1,"Empty image started");
 reset();stream(8192,12);wait(running);assert(!fault)else $fatal(1,"Valid image rejected");
 for(i=0;i<32768;i=i+1)assert(ram[23'h400000+i]===8'd0)else $fatal(1,"Cartridge RAM was not cleared before CPU release");
 // Artwork is placed in bank3, away from ROM and cartridge RAM.
 rv_addr=23'h200000;rv_valid=1;wait(rv_ready);@(negedge clk);rv_valid=0;repeat(3)@(negedge clk);
 assert(ram[23'h600000]==8'h78&&ram[23'h600001]==8'h56&&ram[23'h600002]==8'h34&&ram[23'h600003]==8'h12)else $fatal(1,"Artwork write address/order");
 assert(ram[0]==0&&ram[1]==1&&ram[23'h400000]==0)else $fatal(1,"Artwork crossed protected regions");
 rv_addr=23'h1fffff;rv_valid=1;wait(rv_ready);@(negedge clk);assert(fault&&!running)else $fatal(1,"Invalid artwork address accepted");
 $display("PASS loader: FIFO overflow, empty/invalid ROM sizes, final drain, cleared cartridge RAM, artwork endian/memory separation and bounds");$finish;
end
initial begin #10000000;$fatal(1,"Loader test timeout");end
endmodule
