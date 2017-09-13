library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity regfile_reg is
    port(
        clk: in std_logic;
        res: in std_logic;
        we: in std_logic;
        datain: in unsigned(31 downto 0);
        dataout: buffer unsigned(31 downto 0);
        zero_flag: out std_logic
    );
end entity regfile_reg;

architecture regfile_reg_arch of regfile_reg is
begin

    process(clk) is
        variable reg_var: unsigned(31 downto 0);
    begin
        if rising_edge(clk) then
            if (res = '1') then
                reg_var := (others => '0');
            elsif (we = '1') then
                reg_var := datain;
            end if;
        end if;
        dataout <= reg_var;
    end process;

    zero_flag <= '1' when (dataout = x"00000000") else '0';

end architecture regfile_reg_arch;
