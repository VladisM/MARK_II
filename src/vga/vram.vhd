-- Dual port Video RAM
--
-- Part of MARK II SoC project.
--
--
-- Due to bug in Cyclone II, this file have to be synthetized with
-- following parameter:
--
--      CYCLONEII_SAFE_WRITE RESTRUCTURE
--
-- See M4K issue in Cyclone II errata sheet for more details.


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vram is
    port(
        clk_a   : in std_logic;
        addr_a  : in unsigned(11 downto 0);
        data_a  : in unsigned(14 downto 0);
        we_a    : in std_logic;
        q_a     : out unsigned(14 downto 0);
        clk_b   : in std_logic;
        addr_b  : in unsigned(11 downto 0);
        q_b     : out unsigned(14 downto 0)
    );
end entity vram;

architecture vram_arch of vram is

    subtype word_t is unsigned(14 downto 0);
    type memory_t is array(2**12-1 downto 0) of word_t;

    shared variable ram : memory_t;

begin

    process(clk_a)
    begin
        if(rising_edge(clk_a)) then
            if(we_a = '1') then
                ram(to_integer(addr_a)) := data_a;
            end if;
            q_a <= ram(to_integer(addr_a));
        end if;
    end process;

    process(clk_b)
    begin
        if(rising_edge(clk_b)) then
            q_b <= ram(to_integer(addr_b));
        end if;
    end process;
end architecture vram_arch;
