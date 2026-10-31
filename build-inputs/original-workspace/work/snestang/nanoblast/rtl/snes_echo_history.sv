// The eight FIR samples are a circular memory rather than sixteen shift registers.
// A count masks unwritten locations, preserving the DSP's synchronous zero reset
// without resetting the RAM itself. Logical index 0 is oldest, index 7 newest.
module snes_echo_history (
    input wire clk, resetn, write_enable, channel,
    input wire [14:0] sample_data,
    input wire [2:0] read_index,
    output wire signed [14:0] left_sample, right_sample
);
    (* ram_style="distributed" *) reg [14:0] left_mem [0:7];
    (* ram_style="distributed" *) reg [14:0] right_mem [0:7];
    reg [2:0] left_head, right_head;
    reg [3:0] left_count, right_count;
    wire [2:0] left_addr=left_head+read_index;
    wire [2:0] right_addr=right_head+read_index;
    assign left_sample=({1'b0,read_index}+left_count >= 4'd8) ? left_mem[left_addr] : 15'd0;
    assign right_sample=({1'b0,read_index}+right_count >= 4'd8) ? right_mem[right_addr] : 15'd0;

    always @(posedge clk) begin
        if (resetn && write_enable && !channel) left_mem[left_head] <= sample_data;
        if (resetn && write_enable && channel) right_mem[right_head] <= sample_data;
        if (!resetn) begin
            left_head<=0;right_head<=0;left_count<=0;right_count<=0;
        end else if (write_enable) begin
            if (!channel) begin
                left_head<=left_head+3'd1;
                if (left_count<8) left_count<=left_count+4'd1;
            end else begin
                right_head<=right_head+3'd1;
                if (right_count<8) right_count<=right_count+4'd1;
            end
        end
    end
endmodule
