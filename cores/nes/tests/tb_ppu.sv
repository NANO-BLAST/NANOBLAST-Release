`timescale 1ns/1ps
module tb_ppu;
reg clk=0;always #5 clk=~clk;
reg ce=1,render=0,read=0,write=0;
reg [2:0] ain=0;reg [7:0] din=0;
wire [14:0] v;
LoopyGen dut(.clk(clk),.ce(ce),.is_rendering(render),.ain(ain),.din(din),
 .read(read),.write(write),.is_pre_render(1'b0),.cycle(9'd100),.loopy(v));
PPU ppu(.clk(clk),.ce(ce),.reset(1'b0),.sys_type(2'd0),.din(din),.ain(ain),
 .read(read),.write(write),.vram_din(8'd0));
task tick;begin @(posedge clk);#1;@(negedge clk);end endtask
task store(input [2:0] a,input [7:0] d);
 begin ain=a;din=d;write=1;tick();write=0;end endtask
task set_v(input [14:0] address);
 begin render=0;read=1;ain=2;tick();read=0;
 store(6,{2'b0,address[13:8]});store(6,address[7:0]);
 // Fine Y bit 14 cannot be set by PPUADDR. PPU scroll then pre-render
 // reload would normally set it. Seed only initial state for exhaustive rules.
 dut.loopy_v=address;
 end endtask
function automatic [14:0] expected(input [14:0] old);
 integer x,y,fy,ntx,nty;
 begin
 x=old[4:0];y=old[9:5];fy=old[14:12];ntx=old[10];nty=old[11];
 x=x+1;if(x==32)begin x=0;ntx=1-ntx;end
 fy=fy+1;if(fy==8)begin fy=0;
   if(y==29)begin y=0;nty=1-nty;end
   else if(y==31)y=0;else y=y+1;
 end
 expected=(fy<<12)|(nty<<11)|(ntx<<10)|(y<<5)|x;
 end endfunction
integer x,y,fy,inc,access;reg [14:0] old;
initial begin
`ifndef PALETTE_ONLY
 for(inc=0;inc<2;inc=inc+1)begin
  store(0,inc ? 8'h04:0);
  for(access=0;access<2;access=access+1)
  for(x=0;x<32;x=x+1)for(y=0;y<32;y=y+1)for(fy=0;fy<8;fy=fy+1)begin
   old=(fy<<12)|(3<<10)|(y<<5)|x;set_v(old);render=1;ain=7;
   read=!access;write=access;tick();read=0;write=0;
   if(v!==expected(old))$fatal(1,"render increment %h got %h expected %h",old,v,expected(old));
  end
  set_v(15'h3fff);ain=7;read=1;tick();read=0;
  if(v!==((15'h3fff+(inc?32:1))&15'h7fff))$fatal(1,"linear increment broken");
 end
`endif
 // Check the real top-level palette gate in both rendering states.
 force ppu.is_rendering=0;force ppu.is_pal_address=1;force ppu.pram_addr=5'd1;
 store(7,8'h25);
 if(ppu.palette_ram.palette[1]!==6'h25)$fatal(1,"blank palette write blocked");
 force ppu.is_rendering=1;store(7,8'h12);
 if(ppu.palette_ram.palette[1]!==6'h25)$fatal(1,"render palette write allowed");
 release ppu.is_rendering;release ppu.is_pal_address;release ppu.pram_addr;
`ifdef PALETTE_ONLY
 $display("PASS palette write gate");
`else
 $display("PASS 32768 rendering scroll cases, linear increment and palette gate");
`endif
 $finish;
end
endmodule
