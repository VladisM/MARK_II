library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity regs is
    generic(
        WIDE: natural := 32
    );
    port(
        data: inout signed((WIDE - 1) downto 0);
        res: in std_logic;
        clk: in std_logic;
        wr: in std_logic_vector(15 downto 0);
        oe: in std_logic_vector(15 downto 0)
    );
end entity regs;

architecture regs_arch of regs is

    component reg is
        generic(
            WIDE: natural := 32
        );
        port(
            data: inout signed((WIDE - 1) downto 0);
            res: in std_logic;
            clk: in std_logic;
            we: in std_logic;
            oe: in std_logic
        );
    end component reg;
    
    signal wr_decoded, oe_decoded: std_logic_vector(15 downto 0);
    
begin
    --registers
    gen_reg:
    for I in 1 to 15 generate
        reg_x: reg
            generic map(WIDE => 32) 
            port map(data, res, clk, wr(I), oe(I));
    end generate gen_reg;
    
    --reg 0 is always zero
    process(oe) is begin
        if(oe = x"0001") then
            data <= (others => '0');
        else
            data <= (others => 'Z');
        end if;
    end process;

end architecture regs_arch;                                      




library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg is
    generic(
        WIDE: natural := 32
    );
    port(
        data: inout signed((WIDE - 1) downto 0);
        res: in std_logic;
        clk: in std_logic;
        we: in std_logic;
        oe: in std_logic
    );
end entity reg;

architecture reg_arch of reg is
    --signal for data of the flip flop
    signal internal_data: signed((WIDE - 1) downto 0);
    
begin
    
    --D flip flop 
    process(res, we, clk) is begin
        if(res = '1') then 
            internal_data <= (others => '0');
        elsif(rising_edge(clk)) then
            if(we = '1') then 
                internal_data <= data;
            end if;
        end if;
    end process;
    
    --tri state output
    with oe select data <= internal_data when '1', (others => 'Z') when others;
    
end architecture reg_arch;

