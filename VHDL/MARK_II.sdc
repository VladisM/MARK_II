create_clock -name "clk_25M" -period 40.000ns [get_ports {clk_25M}]
create_clock -name "clk_18M432" -period 54.000ns [get_ports {clk_18M432}]
create_clock -name "clk_22M5792" -period 44.000ns [get_ports {clk_22M5792}]

derive_pll_clocks -create_base_clocks
derive_clock_uncertainty

