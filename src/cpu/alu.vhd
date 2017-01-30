library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--opcode    operation
--0x0       A and B
--0x1       A or B
--0x2       A xor B
--0x3       A + B
--0x4       A - B
--0x5       A + 1
--0x6       A - 1
--0x7		MVIL support, set lower half of opA to lower half of opB
--0x8 		MVIH support, set higher half of opA to....

entity alu is
    generic(
        WIDE: natural := 32
    );
    port(
        OpCode: in std_logic_vector(3 downto 0);
        OpA: in unsigned((WIDE-1) downto 0);
        OpB: in unsigned((WIDE-1) downto 0);
        Result: out unsigned((WIDE-1) downto 0)
    );
end entity alu;

architecture alu_arch of alu is 
begin

    --alu core
    with OpCode select Result <= 
        OpA and OpB when "0000",
        OpA or  OpB when "0001",
        OpA xor OpB when "0010",
        OpA + OpB   when "0011",
        OpA - OpB   when "0100",
        OpA + 1     when "0101",
        OpA - 1     when "0110",
        opA(31 downto 16) & opB(15 downto 0) when "0111",        
        opB(31 downto 16) & opA(15 downto 0) when "1000",  
        OpA when others;
    
end architecture;
   
