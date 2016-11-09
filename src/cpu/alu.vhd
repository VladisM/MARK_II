library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--opcode    operation
--0x0       A+B
--0x1       A-B
--0x2       A or B
--0x3       A and B
--0x4       ~A
--0x5       A xor B
--0x6       A<<1
--0x7       A>>1
--0x8       A+1
--0x9       A-1
entity alu is
    generic(
        WIDE: natural := 32
    );
    port(
        opcode: in std_logic_vector(3 downto 0);      --operation
        eqv: out std_logic;                           -- op A == op B
        lt: out std_logic;                            -- A < B signed
        ltu: out std_logic;                           -- A < B  unsigned
        ge: out std_logic;                            -- A >= B signed
        geu: out std_logic;                           -- A >= B unsigned                                         
        data: inout signed((WIDE-1) downto 0);
        oe: in std_logic;
        wrA: in std_logic;
        wrB: in std_logic;
        res: in std_logic;
        clk: in std_logic
    );
end entity alu;

architecture alu_arch of alu is 
    signal result, opA, opB: signed((WIDE-1) downto 0);
begin
    
    --reg for operand A
    process(data, res, wrA, clk) is begin
        if(res = '1') then
            opA <= (others => '0');
        elsif(rising_edge(clk)) then
            if (wrA = '1') then 
                opA <= data;
            end if;
        end if;
    end process;
    
    --reg for operand B
    process(data, res, wrB, clk) is begin
        if(res = '1') then
            opB <= (others => '0');
        elsif(rising_edge(clk)) then
            if (wrB = '1') then
                opB <= data;
            end if;
        end if;
    end process;
    
    --alu core
    with opcode select result <= 
        opA + opB when "0000",
        opA - opB when "0001",
        opA or opB when "0010",
        opA and opB when "0011",
        not(opA) when "0100",
        opA xor opB when "0101",
        signed(rotate_left(unsigned(opA), 1)) when "0110",
        signed(rotate_right(unsigned(opA), 1)) when "0111",
        opA + 1 when "1000",
        opA - 1 when "1001",
        opA when others;

    --flags
    eqv <= '1' when opA = opB else '0';
    
    process(opA, opB) is begin
        if opA < opB then
            lt <= '1';
        else
            lt <= '0';
        end if;
    end process;
    
    process(opA, opB) is begin
        if unsigned(opA) < unsigned(opB) then
            ltu <= '1';
        else
            ltu <= '0';
        end if;
    end process;
    
    process(opA, opB) is begin
        if opA >= opB then
            ge <= '1';
        else
            ge <= '0';
        end if;
    end process;
    
    process(opA, opB) is begin
        if unsigned(opA) >= unsigned(opB) then
            geu <= '1';
        else
            geu <= '0';
        end if;
    end process;   
    
    --tri state output
    with oe select data <= result when '1', (others => 'Z') when others;
    
end architecture;
   
