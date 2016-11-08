library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instruction_register is
    generic(
        WIDE: natural := 32
    );
    port(
        data: inout signed((WIDE - 1) downto 0);
        instruction: out std_logic_vector(31 downto 0);
        res: in std_logic;
        wr: in std_logic
    );
end entity instruction_register;

architecture instruction_register_arch of instruction_register is
    --signal for data of the flip flop
    signal internal_data: signed((WIDE - 1) downto 0);
    
begin
    
    --D flip flop 
    process(res, wr) is begin
        if(res = '1') then 
            internal_data <= (others => '0');
        elsif(rising_edge(wr)) then
            internal_data <= data;
        end if;
    end process;
    
    instruction <= std_logic_vector(internal_data);
    
end architecture instruction_register_arch;