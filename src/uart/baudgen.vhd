-- baudrate generator for UART from MARK II project
-- 
-- set n_factor to generate variouse baudrates,
-- n_factor = clk_uart / ( 2 * baudrate )
-- for example:
-- 	let clk_uart is 18,4320 MHz 
--		n_factor = 30720 for   300 baud
--					   7680 for  1200 baud
--					    960 for  9600 baud
--                  80 for 115,2 kbaud
--
--	clk_uart - input F, baudrates are derived from this
-- clk_baud - output F for transmitter
-- clk_16x_baud - output F for reciever

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity baudgen is
	port(
		res: in std_logic;
		n_factor: in unsigned(15 downto 0);
		clk_uart: in std_logic;
		clk_baud: out std_logic;
		clk_16x_baud: out std_logic
	);
end entity baudgen;

architecture baudgen_arch of baudgen is

	signal baud_counter: unsigned(15 downto 0);
	signal baud_16x_counter: unsigned(11 downto 0);

	signal baud_counter_match: std_logic;
	signal baud_16x_counter_match: std_logic;
	
	
begin
	
	-- counter for baud_clk
	process(res, baud_counter_match, clk_uart) is 
		variable baud_cnt: unsigned(15 downto 0);
	begin
		if( (res or baud_counter_match) = '1' ) then
			baud_cnt := x"0000";
		elsif( rising_edge(clk_uart) ) then
			baud_cnt := baud_cnt + 1;
		end if;
		baud_counter <= baud_cnt;
	end process;
	
	-- comparator for baud_clk
	process(baud_counter, n_factor) is 
	begin
		if(baud_counter = n_factor) then
			baud_counter_match <= '1';
		else
			baud_counter_match <= '0';
		end if;
	end process;
	
	-- output divide with 2 for baud_clk
	process(baud_counter_match, res) is
		variable baud_div: std_logic;
	begin
		if (res = '1') then
			baud_div := '0';
		elsif (rising_edge(baud_counter_match)) then
			baud_div := not(baud_div);
		end if;
		clk_baud <= baud_div;
	end process;
	
	
	-- counter for baud_16x_clk
	process(res, baud_16x_counter_match, clk_uart) is 
		variable baud_16x_cnt: unsigned(11 downto 0);
	begin
		if( (res or baud_16x_counter_match) = '1' ) then
			baud_16x_cnt := x"000";
		elsif( rising_edge(clk_uart) ) then
			baud_16x_cnt := baud_16x_cnt + 1;
		end if;
		baud_16x_counter <= baud_16x_cnt;
	end process;
	
	-- comparator for baud_16x_clk
	process(baud_16x_counter, n_factor) is 
	begin
		if(baud_16x_counter = n_factor(15 downto 4)) then
			baud_16x_counter_match <= '1';
		else
			baud_16x_counter_match <= '0';
		end if;
	end process;
	
	-- output divide with 2 for baud_16x_clk
	process(baud_16x_counter_match, res) is
		variable baud_16x_div: std_logic;
	begin
		if (res = '1') then
			baud_16x_div := '0';
		elsif (rising_edge(baud_16x_counter_match)) then
			baud_16x_div := not(baud_16x_div);
		end if;
		clk_16x_baud <= baud_16x_div;
	end process;
	
end architecture baudgen_arch;