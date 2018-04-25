-- Simple 16bit Timer with prescaler
--
-- Part of MARK II project. For informations about license, please
-- see file /LICENSE .
--
-- author: Vladislav Mlejnecký
-- email: v.mlejnecky@seznam.cz

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity timer is
    generic(
        BASE_ADDRESS: unsigned(23 downto 0) := x"000000"    --base address
    );
    port(
        --bus
        clk: in std_logic;
        res: in std_logic;
        address: in std_logic_vector(23 downto 0);
        data_mosi: in std_logic_vector(31 downto 0);
        data_miso: out std_logic_vector(31 downto 0);
        WR: in std_logic;
        RD: in std_logic;
        ack: out std_logic;
        --device
        intrq: out std_logic
    );
end entity timer;

architecture timer_arch of timer is

    signal compare_match, clear_from_write: std_logic;
    signal counter: std_logic_vector(15 downto 0);

    --control_reg
    signal timeren, intrqen: std_logic;
    signal prescaler_sel: std_logic_vector(2 downto 0);
    signal set_val: std_logic_vector(15 downto 0);
    signal control_reg: std_logic_vector(31 downto 0) := (others => '0');

    -- signals for prescaler
    signal enclk2, enclk4, enclk8, enclk16, clk_en: std_logic := '0';

    -- bus interface signals
    signal reg_sel: std_logic_vector(1 downto 0);

begin

    --internal counter
    process (clk) is
        variable cnt: unsigned(15 downto 0) := (others => '0');
    begin
        if(rising_edge(clk)) then
            if (res = '1' or clear_from_write = '1' or compare_match = '1') then
                cnt := (others => '0');
            elsif(timeren = '1' and clk_en = '1') then
                cnt := cnt + 1;
            end if;
        end if;

        counter <= std_logic_vector(cnt);
    end process;

    --comparator
    process(counter, set_val) is
    begin
        if counter = set_val then
            compare_match <= '1';
        else
            compare_match <= '0';
        end if;
    end process;

    intrq <= intrqen and compare_match;

    set_val <= control_reg(15 downto 0);
    timeren <= control_reg(16);
    intrqen <= control_reg(17);
    prescaler_sel <= control_reg(20 downto 18);

    --clk divider/prescaler
    process(clk) is
        variable var: unsigned(3 downto 0);
    begin
        if falling_edge(clk) then
            if res = '1' then
                var := "0000";
            else
                var := var + 1;
            end if;
        end if;
        enclk2 <= var(0);
        enclk4 <= var(0) and var(1);
        enclk8 <= var(0) and var(1) and var(2);
        enclk16 <= var(0) and var(1) and var(2) and var(3);
    end process;

    process(prescaler_sel, enclk2, enclk4, enclk8, enclk16) is
    begin
        case prescaler_sel is
            when "000" => clk_en <= '1';
            when "001" => clk_en <= enclk2;
            when "010" => clk_en <= enclk4;
            when "011" => clk_en <= enclk8;
            when others => clk_en <= enclk16;
        end case;
    end process;

    -----------------
    --bus interface

    --chip select
    process(address) is begin
        if    (unsigned(address) = BASE_ADDRESS) then
            reg_sel <= "01"; -- control register
        elsif (unsigned(address) = (BASE_ADDRESS + 1)) then
            reg_sel <= "10"; -- counter
        else
            reg_sel <= "00";
        end if;
    end process;

    --registers
    process(clk, res, WR, data_mosi, reg_sel) is begin
        if rising_edge(clk) then
            if res = '1' then
                control_reg <= (others => '0');
            elsif (reg_sel = "01" and WR = '1') then
                control_reg <= data_mosi(31 downto 0);
            end if;
        end if;
    end process;

    --output from registers
    data_miso <= control_reg       when (RD = '1' and reg_sel = "01") else
                 x"0000" & counter when (RD = '1' and reg_sel = "10") else (others => 'Z');

    --generate signal when there is write acces to counter
    process(WR, reg_sel) is begin
        if(WR = '1' and reg_sel = "10") then
            clear_from_write <= '1';
        else
            clear_from_write <= '0';
        end if;
    end process;

    ack <= '1' when ((WR = '1' and reg_sel /= "00") or (RD = '1' and reg_sel /= "00")) else '0';

end architecture timer_arch;
