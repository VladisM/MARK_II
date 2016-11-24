-- Signle port RAM based on Quartus II VHDL Template

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram is
    generic(
        BASE_ADDRESS: unsigned(15 downto 0) := x"0000"    --base address of the RAM 
    );
    port(
        clk: in std_logic;
        address: in std_logic_vector(15 downto 0);
        data_mosi: in std_logic_vector(31 downto 0);
        data_miso: out std_logic_vector(31 downto 0); 
        WR: in std_logic;
        RD: in std_logic
    );
end entity ram;

architecture ram_arch of ram is
    -- Build a 2-D array type for the RAM
    subtype word_t is std_logic_vector(31 downto 0);
    type memory_t is array(1023 downto 0) of word_t;

    -- Declare the RAM signal.  
    signal ram : memory_t;
    
    --register for address
    signal reg_address: std_logic_vector(9 downto 0);
    
    --select this block, from address decoder
    signal cs: std_logic;
begin
    process(address) is begin
        if (unsigned(address) >= BASE_ADDRESS and unsigned(address) <= (BASE_ADDRESS + 1023)) then
            cs <= '1';
        else
            cs <= '0';
        end if;
    end process;
    
    process(clk, WR, address, data_mosi, cs) begin
        if(rising_edge(clk)) then
            if(WR = '1' and cs = '1') then
                ram(to_integer(unsigned(address))) <= data_mosi;
            end if;
            reg_address <= address(9 downto 0);
        end if;
    end process;
    
    --output from ram
    data_miso <= ram(to_integer(unsigned(reg_address))) when ((RD = '1') and (cs = '1')) else (others => 'Z');
    
end architecture ram_arch;
