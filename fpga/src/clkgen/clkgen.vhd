library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clkgen is 
    port(
        res: in std_logic;
        clk_ext: in std_logic;
        res_out: out std_logic;
        clk_sys: out std_logic;
        clk_vga: out std_logic;
        clk_uart: out std_logic        
    );
end entity clkgen;

architecture clkgen_arch of clkgen is

    component pll_peripherals is port(
            inclk0 : in std_logic := '0';
            c0 : out std_logic;
            c1 : out std_logic);
    end component pll_peripherals;
    
begin

    res_out <= not(res);
    
    pll0: pll_peripherals 
        port map(clk_ext, clk_vga, clk_uart);
    
    clk_sys <= clk_ext;
    
end architecture clkgen_arch;
