-- Signle port RAM based on Quartus II VHDL Template

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram is
    generic(
        BASE_ADDRESS: unsigned(23 downto 0) := x"000000"    --base address of the RAM 
    );
    port(
        clk: in std_logic;
        address: in unsigned(23 downto 0);
        data_mosi: in unsigned(31 downto 0);
        data_miso: out unsigned(31 downto 0); 
        WR: in std_logic;
        RD: in std_logic;
        ack: out std_logic
    );
end entity ram;

architecture ram_arch of ram is
    -- Build a 2-D array type for the RAM
    subtype word_t is unsigned(31 downto 0);
    type memory_t is array(1023 downto 0) of word_t;

    -- Declare the RAM signal.  
    signal ram : memory_t;
    
    --register for address
    signal reg_address: unsigned(9 downto 0);
    
    --select this block, from address decoder
    signal cs: std_logic;
begin
    process(address) is begin
        if (address >= BASE_ADDRESS and address <= (BASE_ADDRESS + 1023)) then
            cs <= '1';
        else
            cs <= '0';
        end if;
    end process;
    
    process(clk, WR, address, data_mosi, cs) begin
        if(rising_edge(clk)) then
            if(WR = '1' and cs = '1') then
                ram(to_integer(address)) <= data_mosi;
            end if;
            reg_address <= address(9 downto 0);
        end if;
    end process;
    
    --output from ram
    data_miso <= ram(to_integer(reg_address)) when ((RD = '1') and (cs = '1')) else (others => 'Z');

    ack <= '1' when ((WR = '1' and cs = '1') or (RD = '1' and cs = '1')) else '0';

end architecture ram_arch;
