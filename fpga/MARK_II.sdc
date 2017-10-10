create_clock -name "clk" -period 20.000ns [get_ports {clk}]

derive_pll_clocks -create_base_clocks
derive_clock_uncertainty

set vga_clk clkgen0|pll0|altpll_component|auto_generated|pll1|clk[0]
set uart_clk clkgen0|pll0|altpll_component|auto_generated|pll1|clk[1]
set sdram_clk clkgen0|pll1|altpll_component|auto_generated|pll1|clk[0]
set sdram_ext_clk clkgen0|pll1|altpll_component|auto_generated|pll1|clk[1]

set_false_path -from [get_clocks {clk}] -to $uart_clk
set_false_path -from $uart_clk -to [get_clocks {clk}]
