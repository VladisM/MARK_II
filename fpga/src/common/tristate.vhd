-- Tristate port (something like 74HC244)
--
-- Part of MARK II project. For informations about license, please
-- see file /LICENSE .
--
-- author: Vladislav Mlejnecký
-- email: v.mlejnecky@seznam.cz

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tristate is
    generic(
        WIDE: natural := 32
    );
    port(
        DataIn: in unsigned((WIDE-1) downto 0);
        DataOut: out unsigned((WIDE-1) downto 0);
        En: in std_logic
    );
end entity tristate;

architecture tristate_arch of tristate is

begin

    DataOut <= DataIn when (En = '1') else (others => 'Z');

end architecture tristate_arch;
