// SPDX-License-Identifier: GPL-3.0-or-later
// Derived from Jose Tejada's jtframe_fir.v (2026), preserving its two-phase MAC.
// Separate coefficient/L/R banks allow Gowin block-RAM inference. Sample RAM
// reads move to the coefficient phase; multiplication and output timing remain
// in their original phases. Checked cycle-for-cycle against the pinned source.
module jtframe_fir #(
    parameter [7:0] KMAX=8'd68,
    parameter COEFFS="filter.hex"
)(
    input rst,clk,sample,
    input signed [15:0] l_in,r_in,
    output reg signed [15:0] l_out,r_out
);
reg signed [15:0] coefficients[0:127];
reg signed [15:0] left_ram[0:127],right_ram[0:127];
reg [6:0] pt_wr,pt_rd;
reg [7:0] cnt;
reg st;
reg signed [35:0] acc_l,acc_r;
reg signed [15:0] coeff,left_value,right_value;
reg signed [31:0] p_l,p_r;
initial begin
    $readmemh({COEFFS,".coeff"},coefficients);
    $readmemh({COEFFS,".left"},left_ram);
    $readmemh({COEFFS,".right"},right_ram);
end
function signed [35:0] ext(input signed [31:0] p);
    ext={{4{p[31]}},p};
endfunction
function [6:0] loop_inc(input [6:0] s);
    loop_inc = s == KMAX[6:0]-7'd1 ? 7'd0 : s+7'd1;
endfunction
function signed [15:0] sat(input signed [35:0] a);
    sat = a[35:32] == {4{a[31]}} ? a[31:16] : {a[35],{15{~a[35]}}};
endfunction
always @(posedge clk)begin
    if(!rst && sample)begin
        left_ram[pt_wr]<=l_in;
        right_ram[pt_wr]<=r_in;
    end
    if(!rst && !sample && cnt<KMAX && st==0)begin
        coeff<=coefficients[cnt[6:0]];
        left_value<=left_ram[pt_rd];
        right_value<=right_ram[pt_rd];
    end
end
always @(posedge clk)begin
    if(rst)begin
        l_out<=0;r_out<=0;pt_rd<=0;pt_wr<=0;cnt<=0;
        acc_l<=0;acc_r<=0;p_l<=0;p_r<=0;
    end else if(sample)begin
        pt_rd<=pt_wr;cnt<=0;pt_wr<=loop_inc(pt_wr);
        acc_l<=0;acc_r<=0;p_l<=0;p_r<=0;st<=0;
    end else if(cnt<KMAX)begin
        st<=~st;
        if(st==1)begin
            p_l<=left_value*coeff;p_r<=right_value*coeff;
            acc_l<=acc_l+ext(p_l);acc_r<=acc_r+ext(p_r);
            cnt<=cnt+8'd1;pt_rd<=loop_inc(pt_rd);
        end
    end else begin
        l_out<=sat(acc_l);r_out<=sat(acc_r);
    end
end
endmodule
