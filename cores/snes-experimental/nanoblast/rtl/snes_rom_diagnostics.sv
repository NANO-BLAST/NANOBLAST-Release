// Read-only ROM transport/SDRAM verification before releasing the SNES reset.
module snes_rom_diagnostics(
 input clk,resetn,loading,load_start,rx_valid,input[7:0]rx_byte,
 input start,input[22:0]length,
 input normal_req,bus_ack,input[15:0]bus_data,
 output reg active=0,bus_req=0,output reg[22:0]bus_addr=0,
 output reg busy=0,done=0,fault=0,
 output wire[31:0]received_crc,output reg[31:0]memory_crc=0
);
 function automatic[31:0]byte_crc(input[31:0]state,input[7:0]data);
  reg[31:0]v;integer i;
  begin v=state^{24'd0,data};for(i=0;i<8;i=i+1)v=v[0]?(v>>1)^32'hedb88320:v>>1;byte_crc=v;end
 endfunction
 reg[31:0]rx_crc=32'hffffffff,scan_crc=32'hffffffff;
 assign received_crc=~rx_crc;
 localparam IDLE=0,WAIT_IDLE=1,DRAIN=2,WAIT_READ=3,SAMPLE=4,RESTORE=5,RESTORE_DRAIN=6;
 reg[2:0]state=IDLE;
 reg[2:0]settle=0;
 reg[22:0]scan_length=0;
 wire[31:0]next_crc=byte_crc(byte_crc(scan_crc,bus_data[7:0]),bus_data[15:8]);
 always @(posedge clk)begin
  if(!resetn||load_start)begin
   active<=0;bus_req<=normal_req;bus_addr<=0;busy<=0;done<=0;fault<=0;
   rx_crc<=32'hffffffff;scan_crc<=32'hffffffff;memory_crc<=0;state<=IDLE;settle<=0;
  end else begin
   if(loading&&rx_valid)rx_crc<=byte_crc(rx_crc,rx_byte);
   if(busy&&!loading)fault<=1;
   case(state)
    IDLE:if(start)begin
     if(!loading||length<32768||length[0])fault<=1;
     else begin busy<=1;done<=0;memory_crc<=0;scan_length<=length;state<=WAIT_IDLE;end
    end
    WAIT_IDLE:if(normal_req==bus_ack&&!rx_valid)begin
     active<=1;bus_req<=normal_req;bus_addr<=0;settle<=4;state<=DRAIN;
    end
    DRAIN:if(settle!=0)settle<=settle-1'b1;
          else begin scan_crc<=32'hffffffff;bus_req<=~bus_req;state<=WAIT_READ;end
    WAIT_READ:if(bus_ack==bus_req)state<=SAMPLE;
    SAMPLE:begin
     scan_crc<=next_crc;
     if(bus_addr+23'd2>=scan_length)begin
      memory_crc<=~next_crc;
      // Return the shared toggle to the loader's original state before
      // releasing ownership; an odd number of words must not cause a write.
      if(bus_req!=normal_req)begin bus_addr<=0;bus_req<=normal_req;state<=RESTORE;end
      else begin settle<=2;state<=RESTORE_DRAIN;end
     end else begin bus_addr<=bus_addr+23'd2;bus_req<=~bus_req;state<=WAIT_READ;end
    end
    RESTORE:if(bus_ack==bus_req)begin settle<=2;state<=RESTORE_DRAIN;end
    RESTORE_DRAIN:if(settle!=0)settle<=settle-1'b1;
                  else begin active<=0;busy<=0;done<=!fault;state<=IDLE;end
    default:begin fault<=1;active<=0;busy<=0;state<=IDLE;end
   endcase
  end
 end
endmodule
