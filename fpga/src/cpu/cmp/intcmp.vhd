library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity intcmp is
    port(
        clk: in std_logic;
        res: in std_logic;
        dataa: in std_logic_vector(31 downto 0);
        datab:  in std_logic_vector(31 downto 0);
        aeb: buffer std_logic;
        aneb: out std_logic;
        agb: buffer std_logic;
        ageb: out std_logic;
        alb: buffer std_logic;
        aleb: out std_logic;
        agb_u: buffer std_logic;
        ageb_u: out std_logic;
        alb_u: buffer std_logic;
        aleb_u: out std_logic
    );
end entity intcmp;

architecture intcmp_arch of intcmp is

begin

    -- comparator for A == B
    process(clk, res) is
        variable aeb_v: std_logic;
    begin
        if res = '1' then
            aeb_v := '0';
        elsif rising_edge(clk) then
            if unsigned(dataa) = unsigned(datab) then
                aeb_v := '1';
            else
                aeb_v := '0';
            end if;
        end if;
        aeb <= aeb_v;
    end process;

    -- comparator for signed A > B
    process(clk, res) is
        variable agb_v: std_logic;
    begin
        if res = '1' then
            agb_v := '0';
        elsif rising_edge(clk) then
            if signed(dataa) > signed(datab) then
                agb_v := '1';
            else
                agb_v := '0';
            end if;
        end if;
        agb <= agb_v;
    end process;

    -- comparator for signed A < B
    process(clk, res) is
        variable alb_v: std_logic;
    begin
        if res = '1' then
            alb_v := '0';
        elsif rising_edge(clk) then
            if signed(dataa) < signed(datab) then
                alb_v := '1';
            else
                alb_v := '0';
            end if;
        end if;
        alb <= alb_v;
    end process;

    -- comparator for unsigned A > B
    process(clk, res) is
        variable agbu_v: std_logic;
    begin
        if res = '1' then
            agbu_v := '0';
        elsif rising_edge(clk) then
            if unsigned(dataa) > unsigned(datab) then
                agbu_v := '1';
            else
                agbu_v := '0';
            end if;
        end if;
        agb_u <= agbu_v;
    end process;

    -- comparator for unsigned A < B
    process(clk, res) is
        variable albu_v: std_logic;
    begin
        if res = '1' then
            albu_v := '0';
        elsif rising_edge(clk) then
            if unsigned(dataa) < unsigned(datab) then
                albu_v := '1';
            else
                albu_v := '0';
            end if;
        end if;
        alb_u <= albu_v;
    end process;

    -- compute all others flags
    aneb <= not(aeb);
    ageb <= agb or aeb;
    aleb <= alb or aeb;
    ageb_u <= agb_u or aeb;
    aleb_u <= alb_u or aeb;

end architecture intcmp_arch;
