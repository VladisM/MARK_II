library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity baudgen is
    port(
        clk: in std_logic;
        res: in std_logic;
        n: in unsigned(15 downto 0);
        baud16_clk_en: out std_logic
    );
end entity baudgen;

architecture baudgen_arch of baudgen is

begin

    baud_div:
    process(clk, res) is
        variable count: unsigned(15 downto 0);
        variable clkenvar: std_logic;
    begin
        
        if rising_edge(clk) then
            if res = '1' then
                count := (others => '0');
                clkenvar := '0';
            elsif count = n then
                count := (others => '0');
                clkenvar := '1';
            else
                count := count + 1;
                clkenvar := '0';
            end if;
        end if;
        
        baud16_clk_en <= clkenvar;
        
    end process;
   
end architecture baudgen_arch;