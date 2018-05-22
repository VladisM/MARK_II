library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lfsr is
	generic(
        BASE_ADDRESS: unsigned(23 downto 0) := x"000000"
    );
    port(
        clk: in std_logic;
        res: in std_logic;
        address: in std_logic_vector(23 downto 0);
        data_mosi: in std_logic_vector(31 downto 0);
        data_miso: out std_logic_vector(31 downto 0);
        WR: in std_logic;
        RD: in std_logic;
        ack: out std_logic
    );    
end entity lfsr;

architecture lfsr_arch of lfsr is

	signal random_data: std_logic_vector(31 downto 0);
	signal cs: std_logic;
	
begin
	
	process(address) is
    begin
        if unsigned(address) = BASE_ADDRESS then
            cs <= '1';
        else
            cs <= '0';
        end if;
    end process;

	-- base lfsr	
    process(clk) is
        variable q: unsigned(31 downto 0);
        variable xored: std_logic;
    begin
        if rising_edge(clk) then
            if res = '1' then
                q := x"00000001";
            else
                xored := q(0) xor q(1) xor q(21) xor q(31);
                q(31 downto 0) := q(30 downto 0) & xored;
            end if;
        end if;
        random_data <= std_logic_vector(q);
    end process;
		
	data_miso <= random_data when (RD = '1' and cs = '1') else (others => 'Z');
	ack <= '1' when (RD = '1' and cs = '1') else '0';
	
end architecture;
