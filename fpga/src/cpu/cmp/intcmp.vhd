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
    process(dataa, datab) is begin
        if unsigned(dataa) = unsigned(datab) then
            aeb <= '1';
        else
            aeb <= '0';
        end if;
    end process;

    -- comparator for signed A > B
    process(dataa, datab) is begin
        if signed(dataa) > signed(datab) then
            agb <= '1';
        else
            agb <= '0';
        end if;
    end process;

    -- comparator for signed A < B
    process(dataa, datab) is begin
        if signed(dataa) < signed(datab) then
            alb <= '1';
        else
            alb <= '0';
        end if;
    end process;

    -- comparator for unsigned A > B
    process(dataa, datab) is begin
        if unsigned(dataa) > unsigned(datab) then
            agb_u <= '1';
        else
            agb_u <= '0';
        end if;
    end process;

    -- comparator for unsigned A < B
    process(dataa, datab) is begin
        if unsigned(dataa) < unsigned(datab) then
            alb_u <= '1';
        else
            alb_u <= '0';
        end if;
    end process;

    -- compute all others flags
    aneb <= not(aeb);
    ageb <= agb or aeb;
    aleb <= alb or aeb;
    ageb_u <= agb_u or aeb;
    aleb_u <= alb_u or aeb;

end architecture intcmp_arch;
