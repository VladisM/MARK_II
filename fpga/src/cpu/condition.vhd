-- Part of CPU logic
--
-- Part of MARK II project. For informations about license, please
-- see file /LICENSE .
--
-- author: Vladislav Mlejnecký
-- email: v.mlejnecky@seznam.cz

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity condition is
    port(
        zeroFlag: in std_logic_vector(15 downto 0);
        regSel: in std_logic_vector(3 downto 0);
        flag: out std_logic
    );
end entity condition;

architecture condition_arch of condition is
begin

    with regSel select flag <=
        zeroFlag(0)  when "0000",
        zeroFlag(1)  when "0001",
        zeroFlag(2)  when "0010",
        zeroFlag(3)  when "0011",
        zeroFlag(4)  when "0100",
        zeroFlag(5)  when "0101",
        zeroFlag(6)  when "0110",
        zeroFlag(7)  when "0111",
        zeroFlag(8)  when "1000",
        zeroFlag(9)  when "1001",
        zeroFlag(10) when "1010",
        zeroFlag(11) when "1011",
        zeroFlag(12) when "1100",
        zeroFlag(13) when "1101",
        zeroFlag(14) when "1110",
        zeroFlag(15) when others;

end architecture condition_arch;
