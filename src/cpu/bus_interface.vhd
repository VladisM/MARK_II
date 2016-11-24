library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bus_interface is 
    port(
        data: inout signed(31 downto 0);
        res: in std_logic;
        clk: in std_logic;
        address: out std_logic_vector(15 downto 0);
        data_mosi: out std_logic_vector(31 downto 0);
        data_miso: in std_logic_vector(31 downto 0);
        WRadd: in std_logic;
        WRdat: in std_logic;
        RDdat: in std_logic
    );
end entity bus_interface;

architecture bus_interface_arch of bus_interface is 

begin
    
    --reg for address
    process(data, res, WRadd, clk) is begin
        if(res = '1') then
            address <= (others => '0');
        elsif(rising_edge(clk)) then
            if(WRadd = '1') then
                address <= std_logic_vector(data(15 downto 0));
            end if;
        end if;
    end process;
    
    --reg for output data bus
    process(data, res, WRdat, clk) is begin
        if(res = '1') then
            data_mosi <= (others => '0');
        elsif(rising_edge(clk)) then
            if(WRdat = '1') then 
                data_mosi <= std_logic_vector(data);
            end if;
        end if;
    end process;
    
    --input data bus
    with RDdat select data <= signed(data_miso) when '1', (others => 'Z') when others;
    
end architecture bus_interface_arch;