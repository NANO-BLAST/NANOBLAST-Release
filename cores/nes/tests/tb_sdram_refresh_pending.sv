`timescale 1ns/1ps
// Deliberately saturate NES slots beyond the refresh deadline, then allow
// an idle slot. Check sticky pending state and RV handshake progress.
// This verifies scheduling, not SDRAM data contents or electrical timing.
module tb_sdram_refresh_pending;
    reg clk=0,resetn=0,clkref=0,saturate=0,nes_read=0,nes_write=0,read_turn=0;
    always #7.716049 clk=~clk;
    integer phase=0,refreshes=0,rv_completed=0,completed_before;
    always @(posedge clk)begin phase<=phase==5 ? 0 : phase+1;clkref<=phase>=2 && phase<5;end
    reg rv_req=0;wire rv_ack,busy;
    reg [20:0] rv_address=0;
    wire [3:0] command;wire [31:0] dq;
    sdram_nes #(.BACKGROUND(1)) dut(.clk(clk),.resetn(resetn),.clkref(clkref),.busy(busy),
        .SDRAM_DQ(dq),.SDRAM_nCS(command[3]),.SDRAM_nRAS(command[2]),
        .SDRAM_nCAS(command[1]),.SDRAM_nWE(command[0]),
        .addrA(22'd0),.weA(1'b0),.dinA(8'd0),.oeA(1'b0),
        .addrB(22'd0),.weB(nes_write),.dinB(8'd0),.oeB(nes_read),
        .rv_addr(rv_address),.rv_din(16'h1234),.rv_ds(2'b11),
        .rv_req(rv_req),.rv_req_ack(rv_ack),.rv_we(1'b1),
        .bg_enable(1'b0),.bg_req(1'b0),.bg_addr(20'd0));
    always @(negedge clk)if(!busy && resetn)begin
        if(phase==5)read_turn=~read_turn;
        nes_read=saturate && phase>=5 && read_turn;
        nes_write=saturate && phase>=5 && !read_turn;
        if(rv_ack==rv_req)begin rv_req=~rv_req;rv_address=rv_address+1;end
    end
    reg previous_ack=0;
    always @(posedge clk)if(!busy && resetn)begin
        if(command==4'b0001)refreshes=refreshes+1;
        if(rv_ack!=previous_ack)rv_completed=rv_completed+1;
        previous_ack=rv_ack;
    end
    initial begin
        repeat(10)@(negedge clk);resetn=1;
        wait(!busy);saturate=1;
        #30000;
        if(!dut.need_refresh || dut.refresh_cnt!=501)
            $fatal(1,"pending refresh lost during saturation: pending=%b count=%0d",dut.need_refresh,dut.refresh_cnt);
        completed_before=rv_completed;
        saturate=0;#3000;
        if(refreshes==0 || dut.need_refresh || rv_completed<=completed_before)
            $fatal(1,"refresh/RV did not resume: refreshes=%0d pending=%b RV=%0d",refreshes,dut.need_refresh,rv_completed);
        $display("PASS sticky refresh deadline under saturated NES traffic; refresh serviced and queued RV writes resume (%0d completions)",rv_completed);
        $finish;
    end
    initial begin #500000;$fatal(1,"timeout");end
endmodule
