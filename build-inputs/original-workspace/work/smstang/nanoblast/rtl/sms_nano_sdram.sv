// Byte-access SDR SDRAM controller for the Nano20K integrated 8MiB x32 memory.
// Single synchronous request-toggle channel; hold request payload until ack.
// Address: bank[22:21], row[20:10], column[9:2], byte lane[1:0].
// Phase-shifted SDRAM clock is supplied by the future board PLL wrapper.
// Conservative BL1 / CL2 timing; controller supports 27..66.7MHz only.
module sms_nano_sdram #(
    parameter integer FREQ=54_000_000,
    parameter integer INIT_CYCLES=(FREQ+4999)/5000,
    parameter integer REFRESH_CYCLES=FREQ/128_000
)(
    input wire clk, resetn,
    input wire bg_enable,bg_req,input wire[19:0]bg_addr,
    output reg bg_ack=0,bg_valid=0,output reg[31:0]bg_data=0,output reg[8:0]bg_word=0,
    input wire req, wr,
    input wire [22:0] addr,
    input wire [7:0] din,
    output reg ack=0,
    output reg [7:0] dout=0,
    output reg ready=0,
    inout wire [31:0] sdram_dq,
    output reg [10:0] sdram_a=0,
    output reg [1:0] sdram_ba=0,
    output reg [3:0] sdram_dqm=4'hf,
    output wire sdram_cs_n,sdram_ras_n,sdram_cas_n,sdram_we_n,
    output wire sdram_cke
);
localparam [3:0] NOP=4'b0111, PRE=4'b0010, REF=4'b0001,
                 MODE=4'b0000, ACT=4'b0011, READ=4'b0101, WRITE=4'b0100;
reg [3:0] command=NOP;
assign {sdram_cs_n,sdram_ras_n,sdram_cas_n,sdram_we_n}=command;
assign sdram_cke=1'b1;
reg drive=0;
reg [31:0] dq_out=0;
assign sdram_dq=drive?dq_out:32'bz;
localparam integer T_RCD=2, T_RP=2, T_RFC=5, T_WR=2;
localparam [3:0] POWERUP=0, INIT_PRE=1, INIT_REF1=2, INIT_REF2=3,
                 INIT_MODE=4, IDLE=5, ACT_WAIT=6, READ_WAIT=7,
                 WRITE_HOLD=8, WRITE_WAIT=9, REF_WAIT=10,
                 BG_ACT=11,BG_READ=12,BG_DRAIN=13,BG_PRE=14;
reg [3:0] state=POWERUP;
reg [$clog2(INIT_CYCLES+1)-1:0] init_count=0;
reg [$clog2(REFRESH_CYCLES+1)-1:0] refresh_count=0;
reg [3:0] wait_count=0;
reg [22:0] address=0;
reg [7:0] data=0;
reg writing=0, request=0;
reg[22:0]bg_address=0;reg[8:0]bg_issued=0,bg_received=0;
reg[2:0]bg_pipe=0;reg bg_target=0;
initial begin
    if(FREQ<27_000_000||FREQ>66_700_000) $fatal(1,"Unsupported SDRAM clock");
end
always @(posedge clk) begin
    command<=NOP;bg_valid<=0;
    bg_pipe<={bg_pipe[1:0],1'b0};
    if(bg_pipe[2])begin
        bg_data<=sdram_dq;bg_word<=bg_received;bg_valid<=1;
        bg_received<=bg_received+1'b1;
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
        command<=MODE;sdram_ba<=0;sdram_a<=11'h020; // sequential BL1, CAS2
        wait_count<=1;state<=INIT_MODE;
    end
    INIT_MODE: if(wait_count==0) begin ready<=1;refresh_count<=0;state<=IDLE;end
    IDLE: if(refresh_count==REFRESH_CYCLES) begin
        // Refresh has priority so a stream of cartridge requests cannot starve it.
        command<=REF;refresh_count<=0;wait_count<=T_RFC-1;state<=REF_WAIT;
    end else if(bg_enable&&bg_req!=bg_ack)begin
        bg_address<=23'h600000+bg_addr;bg_target<=bg_req;
        bg_issued<=0;bg_received<=0;
        sdram_ba<=2'b11;sdram_a<=bg_addr[19:10];
        command<=ACT;wait_count<=T_RCD-1;state<=BG_ACT;
    end else if(req!=ack) begin
        address<=addr;data<=din;writing<=wr;request<=req;
        sdram_ba<=addr[22:21];sdram_a<=addr[20:10];
        command<=ACT;wait_count<=T_RCD-1;state<=ACT_WAIT;
    end
    ACT_WAIT: if(wait_count==0) begin
        sdram_a<={1'b1,2'b00,address[9:2]}; // A10 auto-precharge
        if(writing) begin
            command<=WRITE;sdram_dqm<=~(4'b0001<<address[1:0]);
            dq_out<={4{data}};drive<=1;state<=WRITE_HOLD;
        end else begin
            command<=READ;sdram_dqm<=0;wait_count<=2;state<=READ_WAIT;
        end
    end
    READ_WAIT: if(wait_count==0) begin
        dout<=sdram_dq >> (8*address[1:0]);
        ack<=request;sdram_dqm<=4'hf;state<=IDLE;
    end
    WRITE_HOLD: begin
        drive<=0;sdram_dqm<=4'hf;
        // tWR plus tRP after the sampled WRITE before another ACT or REF.
        wait_count<=T_WR+T_RP-2;state<=WRITE_WAIT;
    end
    WRITE_WAIT: if(wait_count==0) begin ack<=request;state<=IDLE;end
    REF_WAIT: if(wait_count==0) state<=IDLE;
    BG_ACT: if(wait_count==0)state<=BG_READ;
    BG_READ:begin
        command<=READ;sdram_a<={3'b000,bg_address[9:2]};sdram_dqm<=0;
        bg_pipe[0]<=1;bg_issued<=bg_issued+1'b1;bg_address<=bg_address+4;
        if(bg_issued==319||bg_address[9:2]==255)state<=BG_DRAIN;
    end
    BG_DRAIN:if(bg_pipe==0)begin
        command<=PRE;sdram_a<=11'b10000000000;sdram_dqm<=4'hf;
        wait_count<=T_RP-1;state<=BG_PRE;
    end
    BG_PRE:if(wait_count==0)begin
        if(bg_issued==320)begin bg_ack<=bg_target;state<=IDLE;end
        else begin
            sdram_a<=bg_address[20:10];command<=ACT;
            wait_count<=T_RCD-1;state<=BG_ACT;
        end
    end
    default: state<=POWERUP;
    endcase
    if(!resetn) begin
        bg_ack<=0;bg_valid<=0;bg_data<=0;bg_word<=0;bg_address<=0;
        bg_issued<=0;bg_received<=0;bg_pipe<=0;bg_target<=0;
        state<=POWERUP;init_count<=0;refresh_count<=0;wait_count<=0;
        ack<=0;dout<=0;ready<=0;drive<=0;command<=NOP;
        sdram_a<=0;sdram_ba<=0;sdram_dqm<=4'hf;
        address<=0;data<=0;writing<=0;request<=0;
    end
end
endmodule
