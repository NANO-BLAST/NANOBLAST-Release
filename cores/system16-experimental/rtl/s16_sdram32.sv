// SPDX-License-Identifier: GPL-3.0-or-later
// Derived from NANOBLAST sms_nano_sdram: native aligned x32 access, no artwork
// burst channel. This is a standalone integration component, not a board top.
// Nano 20K 8 MiB geometry: bank[22:21], row[20:10], column[9:2].
module s16_sdram32 #(
    parameter integer FREQ=50_349_600,
    parameter integer INIT_CYCLES=(FREQ+4999)/5000,
    parameter integer REFRESH_CYCLES=FREQ/128_000
)(
    input wire clk, resetn, req, wr,
    input wire [22:0] addr,
    input wire [31:0] din,
    input wire [3:0] wmask,
    output reg ack=0,
    output reg [31:0] dout=0,
    output reg ready=0,
    inout wire [31:0] sdram_dq,
    output reg [10:0] sdram_a=0,
    output reg [1:0] sdram_ba=0,
    output reg [3:0] sdram_dqm=4'hf,
    output wire sdram_cs_n,sdram_ras_n,sdram_cas_n,sdram_we_n,sdram_cke
);
localparam [3:0] NOP=4'b0111, PRE=4'b0010, REF=4'b0001,
                 MODE=4'b0000, ACT=4'b0011, READ=4'b0101, WRITE=4'b0100;
localparam [3:0] POWERUP=0, INIT_PRE=1, INIT_REF1=2, INIT_REF2=3,
                 INIT_MODE=4, IDLE=5, ACT_WAIT=6, READ_WAIT=7,
                 WRITE_HOLD=8, WRITE_WAIT=9, REF_WAIT=10;
localparam integer T_RCD=2,T_RP=2,T_RFC=5,T_WR=2;
reg [3:0] command=NOP,state=POWERUP,wait_count=0;
reg [$clog2(INIT_CYCLES+1)-1:0] init_count=0;
reg [$clog2(REFRESH_CYCLES+1)-1:0] refresh_count=0;
reg [22:0] address=0;
reg [31:0] data=0,dq_out=0;
reg [3:0] mask=0;
reg writing=0,request=0,drive=0;
assign {sdram_cs_n,sdram_ras_n,sdram_cas_n,sdram_we_n}=command;
assign sdram_cke=1'b1;
assign sdram_dq=drive?dq_out:32'bz;
initial begin
    if(FREQ<27_000_000||FREQ>66_700_000) $fatal(1,"Unsupported SDRAM clock");
    if(INIT_CYCLES<2||REFRESH_CYCLES<16) $fatal(1,"Invalid timing parameters");
end
always @(posedge clk) begin
    command<=NOP;
    if(ready && refresh_count<REFRESH_CYCLES) refresh_count<=refresh_count+1'b1;
    if(wait_count!=0) wait_count<=wait_count-1'b1;
    case(state)
    POWERUP: if(init_count==INIT_CYCLES-1) begin
        command<=PRE;sdram_a<=11'b10000000000;wait_count<=T_RP-1;state<=INIT_PRE;
    end else init_count<=init_count+1'b1;
    INIT_PRE: if(wait_count==0) begin command<=REF;wait_count<=T_RFC-1;state<=INIT_REF1;end
    INIT_REF1: if(wait_count==0) begin command<=REF;wait_count<=T_RFC-1;state<=INIT_REF2;end
    INIT_REF2: if(wait_count==0) begin
        command<=MODE;sdram_ba<=0;sdram_a<=11'h020;
        wait_count<=1;state<=INIT_MODE;
    end
    INIT_MODE: if(wait_count==0) begin ready<=1;refresh_count<=0;state<=IDLE;end
    IDLE: if(refresh_count==REFRESH_CYCLES) begin
        command<=REF;refresh_count<=0;wait_count<=T_RFC-1;state<=REF_WAIT;
    end else if(req!=ack) begin
        address<=addr;data<=din;mask<=wmask;writing<=wr;request<=req;
        sdram_ba<=addr[22:21];sdram_a<=addr[20:10];
        command<=ACT;wait_count<=T_RCD-1;state<=ACT_WAIT;
    end
    ACT_WAIT: if(wait_count==0) begin
        sdram_a<={1'b1,2'b00,address[9:2]};
        if(writing) begin
            command<=WRITE;sdram_dqm<=~mask;
            dq_out<=data;drive<=1;state<=WRITE_HOLD;
        end else begin
            command<=READ;sdram_dqm<=0;wait_count<=2;state<=READ_WAIT;
        end
    end
    READ_WAIT: if(wait_count==0) begin
        dout<=sdram_dq;ack<=request;sdram_dqm<=4'hf;state<=IDLE;
    end
    WRITE_HOLD: begin
        drive<=0;sdram_dqm<=4'hf;
        wait_count<=T_WR+T_RP-2;state<=WRITE_WAIT;
    end
    WRITE_WAIT: if(wait_count==0) begin ack<=request;state<=IDLE;end
    REF_WAIT: if(wait_count==0) state<=IDLE;
    default: state<=POWERUP;
    endcase
    if(!resetn) begin
        state<=POWERUP;init_count<=0;refresh_count<=0;wait_count<=0;
        ack<=0;dout<=0;ready<=0;drive<=0;command<=NOP;
        sdram_a<=0;sdram_ba<=0;sdram_dqm<=4'hf;
        address<=0;data<=0;mask<=0;writing<=0;request<=0;dq_out<=0;
    end
end
endmodule
