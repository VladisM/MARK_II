library ieee, lpm;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use lpm.lpm_components.all;

entity rom is
    generic(
        BASE_ADDRESS: unsigned(23 downto 0) := x"000000"    --base address of the ROM 
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
end entity rom;

architecture rom_arch of rom is 
    signal data_for_read: std_logic_vector(31 downto 0);
    --signal thats represent chip select
    signal cs: std_logic;
begin
    -- read only memory 
    mem:lpm_rom 
        generic map(
            lpm_widthad => 8,
            lpm_outdata => "UNREGISTERED",
            lpm_address_control => "REGISTERED",
            lpm_file => "../src/rom/rom.mif",
            lpm_width => 32
        ) 
        port map(
            inclock=>clk, 
            address=>std_logic_vector(address(7 downto 0)), 
            q=>data_for_read
        );   
    
    --chip select
    process(address) is begin
        if((unsigned(address) >= BASE_ADDRESS) and (unsigned(address) <= (BASE_ADDRESS + 255))) then
            cs <= '1';
        else
            cs <= '0';
        end if;
    end process;
    
    --tri state outputs
    data_miso <= unsigned(data_for_read) when (cs = '1' and RD = '1') else (others => 'Z');

    ack <= '1' when (cs = '1' and RD = '1') else 'Z';

end architecture rom_arch;
