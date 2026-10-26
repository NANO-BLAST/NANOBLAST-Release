// Two four-sample stereo banks in small distributed RAM. Prefetch runs between
// audio arrivals and HDMI audio packets; the output remains stable throughout
// packet transmission. Read/write conflicts give the incoming sample priority.
module snes_hdmi_audio_buffer #(
    parameter WIDTH=16
) (
    input wire clk,reset,push,used,packet_busy,
    input wire [2*WIDTH-1:0] sample_data,
    output reg ready=0,
    output reg [8*WIDTH-1:0] packet_data
);
    (* ram_style="distributed" *) reg [2*WIDTH-1:0] memory[0:7];
    reg [2:0] write_addr=0,read_addr=0;
    reg [1:0] complete=0;
    reg fetching=0,read_pending=0;
    reg [1:0] pending_index=0;
    reg [2*WIDTH-1:0] read_data;
    wire next_bank=complete[write_addr[2]] ? write_addr[2] : !write_addr[2];
    // A read captures on this edge; the control process consumes it next edge.
    always @(posedge clk) begin
        if(push)memory[write_addr]<=sample_data;
        else read_data<=memory[read_addr];
    end
    always @(posedge clk) begin
        if(reset)begin
            write_addr<=0;complete<=0;ready<=0;fetching<=0;read_pending<=0;
        end else begin
            read_pending<=0;
            if(used)ready<=0;
            if(fetching && !push)begin
                read_pending<=1;pending_index<=read_addr[1:0];
                if(read_addr[1:0]==3)fetching<=0;
                else read_addr<=read_addr+3'd1;
            end
            if(read_pending)begin
                packet_data[pending_index*2*WIDTH+:2*WIDTH]<=read_data;
                if(pending_index==3)ready<=1;
            end
            if(!ready && !fetching && !read_pending && !packet_busy && complete!=0)begin
                read_addr<={next_bank,2'b0};complete[next_bank]<=0;fetching<=1;
            end
            if(push)begin
                write_addr<=write_addr+3'd1;
                if(write_addr[1:0]==3)complete[write_addr[2]]<=1;
            end
        end
    end
endmodule
