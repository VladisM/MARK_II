library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instruction_argument is 
    port(
        databus: inout signed(31 downto 0);
        input_data: in std_logic_vector(31 downto 0);
        oe: in std_logic
    );
end entity instruction_argument;

architecture instruction_argument_arch of instruction_argument is begin

    with oe select databus <= signed(input_data) when '1', (others => 'Z') when others;

end architecture instruction_argument_arch;