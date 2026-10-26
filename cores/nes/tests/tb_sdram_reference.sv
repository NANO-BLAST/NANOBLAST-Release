`timescale 1ns/1ps
// Conditional command audit, not an identification of the actual SiP die.
// Observe external commands on the forwarded SDRAM clock, without looking
// inside the controller. Etron EM638325 Rev3.2 table16 reference limits.
module sdram_command_audit #(parameter real RCD=21.0, RP=21.0,
    RAS=42.0, RC=63.0, RFC=63.0, RRD=14.0, PERIOD=15.432098)(
    input clk, resetn, input [3:0] command,
    input [10:0] address, input [1:0] bank);
    real activated[0:3], ready[0:3], written[0:3], read_at[0:3];
    real previous_act=-1000000, previous_refresh=-1000000;
    real refresh_ready=0, max_refresh_gap=0, first_command=-1;
    real minimum_rcd=1000000;
    real refresh_history[0:4095], max_4096_span=0, refresh_span;
    integer refresh_window_errors=0;
    reg [3:0] open_bank=0;
    integer acts=0,reads=0,writes=0,refreshes=0;
    integer rcd_errors=0,other_errors=0;
    function real later(input real a,b); later=a>b?a:b; endfunction
    initial for(integer b=0;b<4;b=b+1) begin
        activated[b]=-1000000;ready[b]=0;
        written[b]=-1000000;read_at[b]=-1000000;
    end
    always @(posedge clk) if(resetn && command!=4'b1111) begin
        if(first_command<0) first_command=$realtime;
        if($realtime+0.002<refresh_ready)other_errors=other_errors+1;
        case(command)
            4'b0011:begin
                acts=acts+1;
                if(open_bank[bank] || $realtime+0.002<ready[bank] ||
                   $realtime-activated[bank]+0.002<RC ||
                   $realtime-previous_act+0.002<RRD)other_errors=other_errors+1;
                activated[bank]=$realtime;previous_act=$realtime;
                open_bank[bank]=1;
            end
            4'b0101,4'b0100:begin
                if(!open_bank[bank])other_errors=other_errors+1;
                if($realtime-activated[bank]<minimum_rcd)
                    minimum_rcd=$realtime-activated[bank];
                if($realtime-activated[bank]+0.002<RCD)rcd_errors=rcd_errors+1;
                if(command==4'b0100)begin
                    writes=writes+1;written[bank]=$realtime;
                end else begin reads=reads+1;read_at[bank]=$realtime;end
                if(address[10])begin
                    // BL1 auto-precharge waits for tRAS and completion of
                    // the read burst or two-cycle write recovery, then tRP.
                    ready[bank]=later(activated[bank]+RAS,
                        $realtime+(command==4'b0100 ? 2.0 : 1.0)*PERIOD)+RP;
                    open_bank[bank]=0;
                end
            end
            4'b0010:begin
                for(integer b=0;b<4;b=b+1)if(address[10] || b==bank)begin
                    if(open_bank[b] && ($realtime-activated[b]+0.002<RAS ||
                       $realtime-written[b]+0.002<2.0*PERIOD ||
                       $realtime-read_at[b]+0.002<PERIOD))other_errors=other_errors+1;
                    ready[b]=later(ready[b],$realtime+RP);open_bank[b]=0;
                end
            end
            4'b0001:begin
                if(refreshes>=4096)begin
                    refresh_span=$realtime-refresh_history[refreshes%4096];
                    if(refresh_span>max_4096_span)max_4096_span=refresh_span;
                    if(refresh_span>64000000.002)refresh_window_errors=refresh_window_errors+1;
                end
                refresh_history[refreshes%4096]=$realtime;
                refreshes=refreshes+1;
                for(integer b=0;b<4;b=b+1)
                    if(open_bank[b] || $realtime+0.002<ready[b])other_errors=other_errors+1;
                if(previous_refresh>0 && $realtime-previous_refresh>max_refresh_gap)
                    max_refresh_gap=$realtime-previous_refresh;
                previous_refresh=$realtime;refresh_ready=$realtime+RFC;
            end
            4'b0000:begin
                if(open_bank!=0)other_errors=other_errors+1;
                refresh_ready=$realtime+2.0*PERIOD;
            end
            default:other_errors=other_errors+1;
        endcase
    end
endmodule

module tb_sdram_reference #(parameter RUN_NS=5000000);
    // Reuse existing mixed NES/RV/background traffic, but observe commands
    // on a separate forwarded clock instead of its functional data fixture.
    tb_background #(.STOP_AFTER_FRAMES(20),.TIMEOUT_NS(250000000)) traffic();
    reg memory_clock=0;
    always @(traffic.fclk)memory_clock<=#9.645061 traffic.fclk;
    wire [3:0] command={traffic.ncs,traffic.nras,traffic.ncas,traffic.nwe};
    sdram_command_audit reference7(memory_clock,traffic.resetn,command,traffic.a,traffic.ba);
    sdram_command_audit #(.RCD(18.0),.RP(18.0),.RC(60.0),.RFC(60.0),.RRD(12.0))
        reference6(memory_clock,traffic.resetn,command,traffic.a,traffic.ba);
    // Sensitivity control only: deliberately permit the one-cycle tRCD.
    // This is NOT a claimed device specification or compliance profile.
    sdram_command_audit #(.RCD(15.0))
        sensitivity(memory_clock,traffic.resetn,command,traffic.a,traffic.ba);
    initial begin
        #RUN_NS;
        $display("Reference -7: ACT=%0d READ=%0d WRITE=%0d REFRESH=%0d minimum tRCD=%0.3f ns, tRCD violations=%0d, other command violations=%0d, max refresh gap=%0.3f ns",
            reference7.acts,reference7.reads,reference7.writes,reference7.refreshes,
            reference7.minimum_rcd,reference7.rcd_errors,reference7.other_errors,reference7.max_refresh_gap);
        $display("Reference -6: tRCD violations=%0d, other command violations=%0d",reference6.rcd_errors,reference6.other_errors);
        $display("4096-refresh rolling span: maximum=%0.3f ns, windows exceeding 64ms=%0d",reference7.max_4096_span,reference7.refresh_window_errors);
        if(RUN_NS>64000000 && reference7.refreshes<=4096)$fatal(1,"no complete refresh window");
        if(reference7.reads<1000 || reference7.writes<100 || reference7.refreshes<100)
            $fatal(1,"insufficient mixed traffic");
        if(reference7.rcd_errors==0 || reference6.rcd_errors==0)
            $fatal(1,"reference checker failed to detect one-cycle tRCD");
        if(sensitivity.rcd_errors!=0 || sensitivity.other_errors!=0)
            $fatal(1,"command sensitivity control failed: %0d/%0d",sensitivity.rcd_errors,sensitivity.other_errors);
        $display("PASS checker sensitivity/coverage; REFERENCE DEVICE COMPLIANCE FAILS. Actual SiP limits remain unverified.");
        $finish;
    end
endmodule
