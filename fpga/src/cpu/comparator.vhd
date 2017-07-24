-- Part of CPU logic, comparator
--
-- Part of MARK II project. For informations about license, please
-- see file /LICENSE .
--
-- author: Vladislav Mlejnecký
-- email: v.mlejnecky@seznam.cz

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- OpCode | Condition        | Name
----------|------------------|--------
-- 0      | A == B           | EQ
-- 1      | A != B           | NEQ
-- 2      | A <  B signed    | L
-- 3      | A <  B unsigned  | LU
-- 4      | A >= B signed    | GE
-- 5      | A >= B unsigned  | GEU

entity comparator is
    generic(
        WIDE: natural := 32
    );
    port(
        OpCode: in std_logic_vector(2 downto 0);
        OpA: in unsigned((WIDE-1) downto 0);
        OpB: in unsigned((WIDE-1) downto 0);
        Result: out std_logic
    );
end entity comparator;

architecture comparator_arch of comparator is
begin

    process(OpA, OpB, OpCode) is
    begin

        case OpCode is
            when "000" =>
                if(OpA = OpB) then Result <= '1'; else Result <= '0'; end if;
            when "001" =>
                if(OpA = OpB) then Result <= '0'; else Result <= '1'; end if;
            when "010" =>
                if(signed(OpA) < signed(OpB)) then Result <= '0'; else Result <= '1'; end if;
            when "011" =>
                if(OpA < OpB) then Result <= '0'; else Result <= '1'; end if;
            when "100" =>
                if(signed(OpA) >= signed(OpB)) then Result <= '0'; else Result <= '1'; end if;
            when "101" =>
                if(OpA >= OpB) then Result <= '0'; else Result <= '1'; end if;
            when others =>
                Result <= '0';
        end case;

    end process;

end architecture comparator_arch;

