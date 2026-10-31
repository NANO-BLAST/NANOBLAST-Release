// CONDITIONAL audit only: Etron EM638325 Rev3.2, -7 reference limits.
// The actual Gowin SiP die/speed grade and inter-die skew are UNVERIFIED.
// Do not use this profile as evidence of device-specific signoff.
// Gowin's raw I/O report omits forwarded-clock endpoint latency here.
// Its violation count is NOT a system-level result. Generate SDF and run
// tests/audit_sdram_sdf.py to include the full routed forwarded-clock path.
// FCLK=64.8MHz; CLKOUTP PSDA=10/16 period = 225 degrees.
create_generated_clock -name sdram_io -source [get_ports {sys_clk}] -multiply_by 12 -divide_by 5 -phase 225 [get_pins {pll_nes/rpll_inst/CLKOUTP}]

// CL2 tAC(max)=6.5ns, tOH(min)=2.5ns. Unknown SiP skew is not modeled.
set_input_delay -clock sdram_io -max 6.5 [get_ports {IO_sdram_dq*}]
set_input_delay -clock sdram_io -min 2.5 [get_ports {IO_sdram_dq*}]
// SDR command/address/mask/write-data setup 1.5ns, hold 1.0ns.
set_output_delay -clock sdram_io -max 1.5 [get_ports {O_sdram_addr* O_sdram_ba* O_sdram_cs_n O_sdram_wen_n O_sdram_ras_n O_sdram_cas_n O_sdram_cke O_sdram_dqm* IO_sdram_dq*}]
set_output_delay -clock sdram_io -min -1.0 [get_ports {O_sdram_addr* O_sdram_ba* O_sdram_cs_n O_sdram_wen_n O_sdram_ras_n O_sdram_cas_n O_sdram_cke O_sdram_dqm* IO_sdram_dq*}]
report_timing -setup -from [get_ports {IO_sdram_dq*}] -max_paths 40 -max_common_paths 1
report_timing -hold -from [get_ports {IO_sdram_dq*}] -max_paths 40 -max_common_paths 1
report_timing -setup -to [get_ports {O_sdram_addr* O_sdram_ba* O_sdram_cs_n O_sdram_wen_n O_sdram_ras_n O_sdram_cas_n O_sdram_dqm* IO_sdram_dq*}] -max_paths 60 -max_common_paths 1
report_timing -hold -to [get_ports {O_sdram_addr* O_sdram_ba* O_sdram_cs_n O_sdram_wen_n O_sdram_ras_n O_sdram_cas_n O_sdram_dqm* IO_sdram_dq*}] -max_paths 60 -max_common_paths 1

// Report the actual forwarded-clock output path as a separate audit item.
report_timing -setup -from [get_pins {pll_nes/rpll_inst/CLKOUTP}] -to [get_ports {O_sdram_clk}] -max_paths 5
