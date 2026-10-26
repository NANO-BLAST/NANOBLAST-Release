// Two simultaneous whole-word writes and asynchronous reads, using replicated
// single-write memories. A logical word is A xor B. Port 1 wins a collision.
// This avoids a large flip-flop bank on devices without dual-write LUT RAM.
module snes_xor_ram #(
    parameter WIDTH=16, READ_PORTS=2
) (
    input wire CLK,
    input wire [1:0] WE,
    input wire [5:0] WR_ADDR,
    input wire [2*WIDTH-1:0] WR_DATA,
    input wire [READ_PORTS*3-1:0] RD_ADDR,
    output wire [READ_PORTS*WIDTH-1:0] RD_DATA
);
    (* ram_style="distributed" *) reg [WIDTH-1:0] bank_a[0:7];
    (* ram_style="distributed" *) reg [WIDTH-1:0] bank_b[0:7];
    wire [2:0] addr_a=WR_ADDR[2:0],addr_b=WR_ADDR[5:3];
    initial begin
        for(integer i=0;i<8;i=i+1) begin bank_a[i]=0;bank_b[i]=0;end
    end
    always @(posedge CLK) begin
        if(WE[0] && !(WE[1] && addr_a==addr_b))
            bank_a[addr_a]<=WR_DATA[WIDTH-1:0]^bank_b[addr_a];
        if(WE[1]) bank_b[addr_b]<=WR_DATA[2*WIDTH-1:WIDTH]^bank_a[addr_b];
    end
    for(genvar p=0;p<READ_PORTS;p=p+1) begin: read_port
        assign RD_DATA[p*WIDTH+:WIDTH]=bank_a[RD_ADDR[p*3+:3]]^bank_b[RD_ADDR[p*3+:3]];
    end
endmodule
