library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clkgen is 
    port(
        res: in std_logic;
        clk_ext: in std_logic;
        res_out: out std_logic;
        clk_sdram: out std_logic;
        clk_sdram_shift: out std_logic
    );
end entity clkgen;

architecture clkgen_arch of clkgen is

    component pll is
        port (
            inclk0  : in std_logic  := '0';
            c0      : out std_logic ;
            c1      : out std_logic ;
            locked  : out std_logic 
        );
    end component pll;

    signal locked: std_logic;
    
begin

    res_out <= res or not(locked);
    
    pll1: pll
        port map( clk_ext, clk_sdram, clk_sdram_shift, locked);
    
end architecture clkgen_arch;
