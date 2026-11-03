// SPDX-License-Identifier: GPL-3.0-or-later
// Burst extension of NANOBLAST sms_nano_sdram: native aligned x32 access, no artwork
// burst interface supports synchronous read-ahead data, full-word writes and reads.
// Nano 20K 8 MiB geometry: bank[22:21], row[20:10], column[9:2].
module s16_sdram32_burst #(
    parameter integer FREQ=50_349_600,
    parameter integer INIT_CYCLES=(FREQ+4999)/5000,
    parameter integer REFRESH_CYCLES=FREQ/128_000
)(
    input wire burst_enable,burst_req,burst_wr,
    input wire [22:0] burst_addr,
    input wire [8:0] burst_length,
    input wire [31:0] burst_din,
    output reg burst_ack=0,burst_valid=0,
    output reg [31:0] burst_data=0,
    output reg [8:0] burst_word=0,burst_index=0,
    output reg fault=0,
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
localparam [4:0] POWERUP=0, INIT_PRE=1, INIT_REF1=2, INIT_REF2=3,
                 INIT_MODE=4, IDLE=5, ACT_WAIT=6, READ_WAIT=7,
                 WRITE_HOLD=8, WRITE_WAIT=9, REF_WAIT=10,
 BURST_ACT=11,BURST_READ=12,BURST_WRITE=13,BURST_DRAIN=14,BURST_PRE=15;
localparam integer T_RCD=2,T_RP=2,T_RFC=5,T_WR=2;
reg [3:0] command=NOP,wait_count=0;
reg [4:0] state=POWERUP;
reg [$clog2(INIT_CYCLES+1)-1:0] init_count=0;
reg [$clog2(REFRESH_CYCLES+1)-1:0] refresh_count=0;
reg [22:0] address=0;
reg [31:0] data=0,dq_out=0;
reg [3:0] mask=0;
reg writing=0,request=0,drive=0;
reg [22:0] burst_address=0;
reg [8:0] issued=0,received=0,length=0;
reg [2:0] read_pipe=0;
reg burst_target=0,burst_writing=0,last_burst=0;
wire choose_burst=burst_enable && burst_req!=burst_ack && (req==ack || !last_burst);
wire [23:0] burst_end={1'b0,burst_addr}+({15'd0,burst_length}<<2);
assign {sdram_cs_n,sdram_ras_n,sdram_cas_n,sdram_we_n}=command;
assign sdram_cke=1'b1;
assign sdram_dq=drive?dq_out:32'bz;
initial begin
    if(FREQ<27_000_000||FREQ>66_700_000) $fatal(1,"Unsupported SDRAM clock");
    if(INIT_CYCLES<2||REFRESH_CYCLES<16) $fatal(1,"Invalid timing parameters");
end
always @(posedge clk) begin
    command<=NOP;drive<=0;burst_valid<=0;
    read_pipe<={read_pipe[1:0],1'b0};
    if(read_pipe[2])begin
        burst_data<=sdram_dq;burst_index<=received;burst_valid<=1;
        received<=received+1'b1;
    end
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
    IDLE: begin
    if(!burst_enable)burst_ack<=burst_req;
    if(refresh_count==REFRESH_CYCLES) begin
        command<=REF;refresh_count<=0;wait_count<=T_RFC-1;state<=REF_WAIT;
    end else if(choose_burst && !fault) begin
        if(burst_addr[1:0]!=0 || burst_length==0 || burst_length>256 || burst_end>24'h800000)begin
            fault<=1;
        end else begin
            burst_address<=burst_addr;length<=burst_length;
            issued<=0;received<=0;burst_word<=0;
            burst_target<=burst_req;burst_writing<=burst_wr;last_burst<=1;
            sdram_ba<=burst_addr[22:21];sdram_a<=burst_addr[20:10];
            command<=ACT;wait_count<=T_RCD-1;state<=BURST_ACT;
        end
    end else if(req!=ack) begin
        last_burst<=0;
        address<=addr;data<=din;mask<=wmask;writing<=wr;request<=req;
        sdram_ba<=addr[22:21];sdram_a<=addr[20:10];
        command<=ACT;wait_count<=T_RCD-1;state<=ACT_WAIT;
    end
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
    BURST_ACT:if(wait_count==0)begin
        state<=burst_writing?BURST_WRITE:BURST_READ;
        if(burst_writing)burst_word<=issued+1'b1;
    end
    BURST_READ:begin
        command<=READ;sdram_a<={3'b000,burst_address[9:2]};sdram_dqm<=0;
        read_pipe[0]<=1;issued<=issued+1'b1;burst_address<=burst_address+4;
        if(issued==length-1'b1 || burst_address[9:2]==255)state<=BURST_DRAIN;
    end
    BURST_WRITE:begin
        command<=WRITE;sdram_a<={3'b000,burst_address[9:2]};sdram_dqm<=0;
        dq_out<=burst_din;drive<=1;issued<=issued+1'b1;burst_address<=burst_address+4;
        if(issued==length-1'b1 || burst_address[9:2]==255)begin
            wait_count<=T_WR;state<=BURST_DRAIN;burst_word<=issued+1'b1;
        end else burst_word<=issued+2'd2;
    end
    BURST_DRAIN:if((burst_writing && wait_count==0)||(!burst_writing && read_pipe==0))begin
        command<=PRE;sdram_a<=11'b10000000000;sdram_dqm<=4'hf;
        wait_count<=T_RP-1;state<=BURST_PRE;
    end
    BURST_PRE:if(wait_count==0)begin
        if(issued==length)begin burst_ack<=burst_target;state<=IDLE;end
        else begin
            sdram_ba<=burst_address[22:21];sdram_a<=burst_address[20:10];
            command<=ACT;wait_count<=T_RCD-1;state<=BURST_ACT;
        end
    end
    default: state<=POWERUP;
    endcase
    if(!resetn) begin
        burst_ack<=0;burst_valid<=0;burst_data<=0;burst_word<=0;burst_index<=0;
        burst_address<=0;issued<=0;received<=0;length<=0;read_pipe<=0;
        burst_target<=0;burst_writing<=0;last_burst<=0;fault<=0;
        state<=POWERUP;init_count<=0;refresh_count<=0;wait_count<=0;
        ack<=0;dout<=0;ready<=0;drive<=0;command<=NOP;
        sdram_a<=0;sdram_ba<=0;sdram_dqm<=4'hf;
        address<=0;data<=0;mask<=0;writing<=0;request<=0;dq_out<=0;
    end
end
endmodule
