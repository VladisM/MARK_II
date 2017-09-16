library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lpm;
use lpm.all;

-- opcode mode
-- 00     logical
-- 01     rotate
-- 10     arithmetical
-- 11     don't care

-- dir
-- 0 - left (toward the MSB)
-- 1 - right (toward the LSB)

entity barrel is
    port(
        clk: in std_logic;
        res: in std_logic;
        en: in std_logic;
        dir: in std_logic;
        mode: in std_logic_vector(1 downto 0);
        dataa: in unsigned(31 downto 0);
        datab: in unsigned(31 downto 0);
        result: out unsigned(31 downto 0)
    );
end entity barrel;

architecture barrel_arch of barrel is

    component lpm_clshift
        generic (
            lpm_shifttype : string;
            lpm_width     : natural;
            lpm_widthdist : natural
        );
        port(
            data      : in std_logic_vector (31 downto 0);
            direction : in std_logic ;
            distance  : in std_logic_vector (4 downto 0);
            result    : out std_logic_vector (31 downto 0)
        );
    end component;

    signal res_s: std_logic;
    signal data_a_vect, data_b_vect: std_logic_vector(31 downto 0);
    signal result_log, result_rot, result_ari: std_logic_vector(31 downto 0);

begin

    data_a_vect <= std_logic_vector(dataa);
    data_b_vect <= std_logic_vector(datab);

    shift_log_0: lpm_clshift
        generic map ("logical", 32, 5)
        port map (data_a_vect, dir, data_b_vect(4 downto 0), result_log);

    shift_rot_0: lpm_clshift
        generic map ("rotate", 32, 5)
        port map (data_a_vect, dir, data_b_vect(4 downto 0), result_rot);

    shift_ari_0: lpm_clshift
        generic map ("arithmetic", 32, 5)
        port map (data_a_vect, dir, data_b_vect(4 downto 0), result_ari);

    process(clk) is
        variable res_v: std_logic;
    begin
        if rising_edge(clk) then
            if res = '1' then
                res_v := '1';
            else
                res_v := '0';
            end if;
        end if;
        res_s <= res_v;
    end process;

    result <=
        unsigned(result_log) when ((mode = "00") and (en = '1')) else
        unsigned(result_rot) when ((mode = "01") and (en = '1')) else
        unsigned(result_ari) when ((mode = "10") and (en = '1')) else
        (others => 'Z');

end architecture barrel_arch;
