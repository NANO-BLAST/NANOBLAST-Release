create_clock -name sys_clk -period 37.037037 [get_ports {sys_clk}]
create_clock -name main -period 37.037037 [get_nets {clk}]
create_clock -name hclk5 -period 2.693603 [get_nets {hclk5}]
create_generated_clock -name hclk -source [get_nets {hclk5}] -master_clock hclk5 -divide_by 5 [get_nets {hclk}]

// Main and video PLL domains communicate through explicit CDC handshakes.
set_clock_groups -asynchronous -group [get_clocks {main}] -group [get_clocks {hclk hclk5}]


// No inherited VerilogBoy engine timing exceptions.
