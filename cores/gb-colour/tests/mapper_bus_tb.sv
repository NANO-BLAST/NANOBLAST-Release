`timescale 1ns/1ps
module mapper_bus_tb;
reg clk=0;always #5 clk=~clk;
reg reset=1,loading=0,io_wr=0,wr=0,rd=0,a15=0,ncs=1;reg[24:0]io_addr=0;reg[15:0]io_data=0;reg[14:0]addr=0;reg[7:0]din=0;
wire[22:0]rom_addr;wire[16:0]ram_addr;wire[7:0]dout;wire oe,cram_wr;wire[7:0]ram_size;
cart_top dut(.reset(reset),.clk_sys(clk),.ce_cpu(1'b1),.ce_cpu2x(1'b1),.speed(1'b0),.megaduck(1'b0),.duck_md0_mode(1'b0),.mapper_sel(3'd0),
 .cart_addr(addr),.cart_a15(a15),.cart_rd(rd),.cart_wr(wr),.cart_do(dout),.cart_di(din),.cart_oe(oe),.nCS(ncs),.mbc_addr(rom_addr),
 .cram_addr(ram_addr),.cram_wr(cram_wr),.ram_size(ram_size),.cart_download(loading),.ioctl_download(loading),.ioctl_wr(io_wr),.ioctl_addr(io_addr),.ioctl_dout(io_data),
 .bk_wr(1'b0),.bk_rtc_wr(1'b0),.bk_addr(17'd0),.bk_data(16'd0),.img_size(64'd0),.rom_di(8'hb6),.joystick_analog_0(16'd0),.ce_32k(1'b0),.RTC_time(33'd0),
 .SaveStateExt_Din(64'd0),.SaveStateExt_Adr(10'd0),.SaveStateExt_wren(1'b0),.SaveStateExt_rst(1'b0),.savestate_load(1'b0),.savestate_ovr(1'b0),
 .Savestate_CRAMAddr(20'd0),.Savestate_CRAMRWrEn(1'b0),.Savestate_CRAMWriteData(16'd0));
task pair(input[24:0]a,input[15:0]v);begin @(negedge clk);io_addr=a;io_data=v;io_wr=1;@(negedge clk);io_wr=0;end endtask
task header(input[7:0]kind,input[7:0]size,input[7:0]ram,input[24:0]last);begin
 @(negedge clk);loading=1;wr=0;rd=0;repeat(4)@(negedge clk);
 pair('h142,16'hc000);pair('h146,{kind,8'd0});pair('h148,{ram,size});pair(last,0);
 repeat(8)@(negedge clk);loading=0;repeat(8)@(negedge clk);
end endtask
task write_bus(input[15:0]a,input[7:0]v);begin @(negedge clk);addr=a[14:0];a15=a[15];ncs=!a[15];din=v;wr=1;rd=0;@(negedge clk);wr=0;end endtask
task bank(input[15:0]a,input[22:0]expected);begin @(negedge clk);addr=a[14:0];a15=a[15];ncs=!a[15];rd=1;#1;
 if(rom_addr!==expected||!oe||dout!==8'hb6)$fatal(1,"Bank addr %h got %h data %h oe%b expected %h",a,rom_addr,dout,oe,expected);
end endtask
task cram(input[16:0]expected);begin @(negedge clk);addr='h2123;a15=1;ncs=0;din=8'h5a;wr=1;#1;
 if(!cram_wr||ram_addr!==expected)$fatal(1,"RAM got %h wr%b expected %h",ram_addr,cram_wr,expected);
 @(negedge clk);wr=0;end endtask
initial begin
 repeat(6)@(negedge clk);reset=0;
 header(0,0,0,'h7ffe);bank('h0123,'h0123);bank('h4123,'h4123);
 header(1,6,3,'h1ffffe);bank('h4123,'h4123);write_bus('h2000,2);bank('h4123,'h8123);
 write_bus('h2000,0);bank('h4123,'h4123);write_bus('h4000,2);bank('h4123,'h104123);
 write_bus('h6000,1);bank('h0123,'h100123);write_bus(0,10);cram('h4123);
 header(6,3,0,'h3fffe);write_bus('h2100,7);bank('h4123,'h1c123);write_bus(0,10);cram('h123);
 header('h10,6,3,'h1ffffe);bank('h4123,'h4123);write_bus('h2000,127);bank('h4123,'h1fc123);write_bus('h2000,0);bank('h4123,'h4123);write_bus(0,10);write_bus('h4000,3);cram('h6123);
 header('h1b,7,4,'h3ffffe);write_bus('h2000,255);bank('h4123,'h3fc123);write_bus('h2000,0);bank('h4123,'h123);write_bus(0,10);write_bus('h4000,15);cram('h1e123);
 // Fresh load must clear old bank state across mapper families.
 header(1,1,0,'hfffe);bank('h4123,'h4123);
 $display("PASS cartridge header decode, ROM/MBC1/MBC2/MBC3/MBC5 bank addresses, zero-bank rules, RAM banks and reload");$finish;
end
endmodule
