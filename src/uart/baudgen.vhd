library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity baudgen is
    port(
        res: in std_logic;
        n_factor: in unsigned(15 downto 0);
        clk: in std_logic;
        clk_baud: out std_logic;
        clken: in std_logic
    );
end entity baudgen;

architecture baudgen_arch of baudgen is
    signal clk_baud_i: std_logic;
begin
    
    process(clken, res, clk) is 
        variable baud_cnt: unsigned(15 downto 0);
        variable clk_var: std_logic;
    begin
        if rising_edge(clk) then
            
            clk_var := '0';
            
            if res = '1' then
                baud_cnt := (others => '0');
                clk_var := '0';
            elsif baud_cnt = n_factor then
                baud_cnt := (others => '0');
                clk_var := '1';
            elsif clken = '1' then
                baud_cnt := baud_cnt + 1;
            end if;
               
        end if;
        clk_baud_i <= clk_var;
    end process;
    
    clk_baud <= clk_baud_i;
    
end architecture baudgen_arch;
