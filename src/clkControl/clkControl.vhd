library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clkControl is
    port(
        clk: in std_logic;
        res: in std_logic;
        enclk2: out std_logic;
        enclk4: out std_logic;
        enclk8: out std_logic
    );
end entity clkControl;

architecture clk_arch of clkControl is
    
begin

    process(clk) is
        variable var: unsigned(2 downto 0);
    begin
        if falling_edge(clk) then
            if res = '1' then
                var := "000";
            else
                var := var + 1;
            end if;
        end if;
        enclk2 <= var(0);
        enclk4 <= var(0) and var(1);
        enclk8 <= var(0) and var(1) and var(2);
    end process;
    
end architecture clk_arch;
