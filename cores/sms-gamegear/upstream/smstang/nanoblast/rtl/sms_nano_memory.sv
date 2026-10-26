// ROM streaming, CPU cartridge/SRAM requests and BL616 artwork writes.
// All interfaces share clk. CPU WAIT stays asserted until the requested byte
// is cached; SDRAM refresh and artwork arbitration cannot return stale data.
module sms_nano_memory(
 input wire clk,resetn,
 input wire loading,load_valid,input wire[7:0]load_data,
 input wire rom_rd,input wire[21:0]rom_addr,output reg[7:0]rom_data,
 input wire save_rd,save_we,input wire[14:0]save_addr,input wire[7:0]save_din,
 output reg[7:0]save_dout,output wire cpu_wait_n,output wire running,
 output reg fault,
 input wire rv_valid,input wire[22:0]rv_addr,input wire[31:0]rv_wdata,
 input wire[3:0]rv_wstrb,output reg rv_ready,
 output reg req,output reg wr,output reg[22:0]addr,output reg[7:0]din,
 input wire ack,input wire[7:0]dout,input wire ready
);
reg[7:0]fifo[0:63];reg[5:0]head,tail;reg[6:0]count;
reg[22:0]size,written;reg[21:0]mask,rom_tag;reg[14:0]save_tag;
reg was_loading,eof,loaded,rom_cached,save_cached,save_written;
reg[2:0]job;localparam NONE=0,LOAD=1,ROM=2,SAVER=3,SAVEW=4,ART=5,CLEAR=6;
reg[14:0]clear_addr;reg save_cleared,generation,active_generation;
reg[21:0]active_rom;reg[14:0]active_save;
reg rv_seen,art_active;reg[1:0]art_byte;reg[22:0]art_addr;
reg[31:0]art_data;reg[3:0]art_strobe;
wire[21:0]masked_addr=rom_addr & mask;
wire need_rom=rom_rd&&!save_rd&&!save_we&&(!rom_cached||rom_tag!=masked_addr);
wire need_save=save_rd&&(!save_cached||save_tag!=save_addr);
wire need_write=save_we&&!save_written;
assign running=ready&&loaded&&!loading&&!fault;
assign cpu_wait_n=running&&!need_rom&&!need_save&&!need_write&&job!=SAVEW;
wire start_load=loading&&!was_loading;
wire push=loading&&load_valid&&!fault&&count<64&&size<23'h400000;
wire pop=job==LOAD&&req==ack;
always @(posedge clk)begin
 rv_ready<=0;was_loading<=loading;
 if(!save_we)save_written<=0;
 if(!rv_valid)rv_seen<=0;
 if(rv_valid&&!rv_seen&&!art_active)begin
  rv_seen<=1;art_active<=1;art_byte<=0;art_addr<=rv_addr;
  art_data<=rv_wdata;art_strobe<=rv_wstrb;
 end
 if(loading&&load_valid)begin
  if(push)begin fifo[tail]<=load_data;tail<=tail+1'b1;size<=size+1'b1;end
  else fault<=1;
 end
 case({push,pop})2'b10:count<=count+1'b1;2'b01:count<=count-1'b1;default:;endcase
 if(!loading&&was_loading)begin
  eof<=1;mask<=size[21:0]-1'b1;
  if(size<8192||(size&(size-1'b1))!=0)fault<=1;
 end
 if(eof&&!loading&&count==0&&job!=LOAD&&!fault&&save_cleared)loaded<=1;
 if(job!=NONE&&req==ack)begin
  case(job)
   LOAD:begin head<=head+1'b1;written<=written+1'b1;end
   ROM:begin rom_data<=dout;rom_tag<=active_rom;rom_cached<=!loading;end
   SAVER:begin save_dout<=dout;save_tag<=active_save;save_cached<=1;end
   SAVEW:begin save_dout<=din;save_tag<=active_save;save_cached<=1;save_written<=1;end
   CLEAR:if(active_generation==generation)begin
    if(clear_addr==32767)save_cleared<=1;else clear_addr<=clear_addr+1'b1;
   end
   ART:begin
    if(art_byte==3)begin art_active<=0;rv_ready<=1;end else art_byte<=art_byte+1'b1;
   end
  endcase
  job<=NONE;
 end
 if(job==NONE&&req==ack&&ready)begin
  if(count!=0)begin
   addr<=written;din<=fifo[head];wr<=1;req<=~req;job<=LOAD;
  end else if(!save_cleared)begin
   addr<=23'h400000+clear_addr;din<=0;wr<=1;req<=~req;job<=CLEAR;active_generation<=generation;
  end else if(art_active)begin
   if(art_addr<23'h200000||art_addr>23'h2e0ffc)begin art_active<=0;rv_ready<=1;fault<=1;end
   else if(!art_strobe[art_byte])begin
    if(art_byte==3)begin art_active<=0;rv_ready<=1;end else art_byte<=art_byte+1'b1;
   end else begin
    addr<=art_addr+23'h400000+art_byte;din<=art_data[art_byte*8+:8];wr<=1;req<=~req;job<=ART;
   end
  end else if(running)begin
   if(need_write)begin addr<=23'h400000+save_addr;din<=save_din;active_save<=save_addr;wr<=1;req<=~req;job<=SAVEW;end
   else if(need_save)begin addr<=23'h400000+save_addr;active_save<=save_addr;wr<=0;req<=~req;job<=SAVER;end
   else if(need_rom)begin addr<={1'b0,masked_addr};active_rom<=masked_addr;wr<=0;req<=~req;job<=ROM;end
  end
 end
 if(start_load)begin
  // The old CPU may have one read outstanding, but an unfinished previous
  // download must never be silently discarded or acknowledged as a new image.
  fault<=count!=0||job==LOAD;head<=0;tail<=0;count<=0;size<=0;written<=0;
  generation<=~generation;save_cleared<=0;clear_addr<=0;
  loaded<=0;eof<=0;rom_cached<=0;save_cached<=0;save_written<=0;
  if(load_valid)fault<=1; // protocol starts loading before its first data byte
 end
 if(!resetn)begin
  req<=0;wr<=0;addr<=0;din<=0;job<=NONE;head<=0;tail<=0;count<=0;
  save_cleared<=1;clear_addr<=0;generation<=0;active_generation<=0;
  size<=0;written<=0;mask<=0;was_loading<=0;eof<=0;loaded<=0;fault<=0;
  rom_cached<=0;save_cached<=0;save_written<=0;rom_tag<=0;save_tag<=0;
  rom_data<=0;save_dout<=0;active_rom<=0;active_save<=0;
  rv_seen<=0;art_active<=0;art_byte<=0;art_addr<=0;art_data<=0;art_strobe<=0;rv_ready<=0;
 end
end
endmodule
