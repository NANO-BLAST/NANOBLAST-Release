// Audit profile: accurate root frequency and explicit HDMI PLL/divider chain.
// No timing exceptions in this first pass.
create_clock -name clk -period 37.037037 [get_ports {sys_clk}]
create_generated_clock -name hclk5 -source [get_ports {sys_clk}] -multiply_by 55 -divide_by 4 [get_pins {pll_hdmi/rpll_inst/CLKOUT}]
create_generated_clock -name pixel -source [get_pins {pll_hdmi/rpll_inst/CLKOUT}] -divide_by 5 [get_pins {div5/CLKOUT}]
report_timing -hold -max_paths 100 -max_common_paths 1
report_timing -setup -max_paths 100 -max_common_paths 1
