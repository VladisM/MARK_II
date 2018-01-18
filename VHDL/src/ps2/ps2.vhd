-- PS2 wrapper, peripheral for MARK-II
--
-- Part of MARK II project. For informations about license, please
-- see file /LICENSE .
--
-- author: Vladislav Mlejnecký
-- email: v.mlejnecky@seznam.cz


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ps2 is
    generic(
        BASE_ADDRESS: unsigned(23 downto 0) := x"000000"
    );
    port(
        clk: in std_logic;
        res: in std_logic;
        address: in std_logic_vector(23 downto 0);
        data_miso: out std_logic_vector(31 downto 0);
        RD: in std_logic;
        ack: out std_logic;
        --device
        ps2clk: in std_logic;
        ps2dat: in std_logic;
        intrq: out std_logic
    );
end entity ps2;

architecture ps2_arch of ps2 is

    component ps2core is
        port(
            clk: in std_logic;
            res: in std_logic;
            byte_out: out unsigned(7 downto 0);
            byte_recieved: out std_logic;
            ps2clk: in std_logic;
            ps2dat: in std_logic
        );
    end component ps2core;

    signal byte: unsigned(7 downto 0);
    signal cs: std_logic;

begin

    ps2core0: ps2core
        port map(clk, res, byte, intrq, ps2clk, ps2dat);


    process(address) is
    begin
        if unsigned(address) = BASE_ADDRESS then
            cs <= '1';
        else
            cs <= '0';
        end if;
    end process;

    data_miso <= std_logic_vector( x"000000" & byte ) when (RD = '1' and cs = '1') else (others => 'Z');

    ack <= '1' when (RD = '1' and cs = '1') else '0';

end architecture ps2_arch;
