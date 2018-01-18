-- System timer for MARK-II
--
-- Part of MARK II project. For informations about license, please
-- see file /LICENSE .
--
-- author: Vladislav Mlejnecký
-- email: v.mlejnecky@seznam.cz

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity systim is
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
end entity systim;

architecture systim_arch of systim is
    signal counter: unsigned(23 downto 0);

    --control register
    signal control_reg: unsigned(24 downto 0);
    signal top: unsigned(23 downto 0);
    signal timeren: std_logic;

    signal compare_match: std_logic;

    --for bus interface
    signal reg_sel: std_logic_vector(1 downto 0);
    signal clear_from_write: std_logic; --clear the counter when value is writen to its register

begin

    --this is core timer
    process (clk, res, compare_match, clear_from_write)
        variable cnt: unsigned(23 downto 0) := (others => '0');
    begin
        if(rising_edge(clk)) then
            if (res = '1' or clear_from_write = '1' or compare_match = '1') then
                cnt := (others => '0');
            elsif(timeren = '1') then
                cnt := cnt + 1;
            end if;
        end if;

        counter <= cnt;
    end process;

    --comparator
    process(top, counter) is begin
        if(counter = top) then
            compare_match <= '1';
        else
            compare_match <= '0';
        end if;
    end process;

    --for interrupts
    intrq <= compare_match;

    --control
    top <= control_reg(23 downto 0);
    timeren <= control_reg(24);

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
                control_reg <= unsigned(data_mosi(24 downto 0));
            end if;
        end if;
    end process;

    --output from registers
    data_miso <= "0000000" & std_logic_vector(control_reg) when (RD = '1' and reg_sel = "01") else
                 x"00"     & std_logic_vector(counter)     when (RD = '1' and reg_sel = "10") else (others => 'Z');

    --generate signal when there is write acces to counter
    process(WR, reg_sel) is begin
        if(WR = '1' and reg_sel = "10") then
            clear_from_write <= '1';
        else
            clear_from_write <= '0';
        end if;
    end process;

    ack <= '1' when ((WR = '1' and reg_sel /= "00") or (RD = '1' and reg_sel /= "00")) else '0';

end architecture systim_arch;

