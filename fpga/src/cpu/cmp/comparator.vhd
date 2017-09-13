library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- function    opcode  cycles
-- fp_aeb      0       1
-- fp_agb      1       1
-- fp_ageb     2       1
-- fp_alb      3       1
-- fp_aleb     4       1
-- fp_aneb     5       1
-- int_aeb     6       0
-- int_aneb    7       0
-- int_agb     8       0
-- int_ageb    9       0
-- int_alb     A       0
-- int_aleb    B       0
-- int_agb_u   C       0
-- int_ageb_u  D       0
-- int_alb_u   E       0
-- int_aleb_u  F       0


entity comparator is
    port(
        res: in std_logic;
        clk: in std_logic;
        en: in std_logic;
        opcode: in std_logic_vector(3 downto 0);
        data_a: in unsigned(31 downto 0);
        data_b: in unsigned(31 downto 0);
        output: out unsigned(31 downto 0)
    );
end entity comparator;

architecture comp_arch of comparator is

    component fpcmp is port(
        aclr  : in std_logic;
        clock : in std_logic;
        dataa : in std_logic_vector (31 downto 0);
        datab : in std_logic_vector (31 downto 0);
        aeb   : out std_logic;
        agb   : out std_logic;
        ageb  : out std_logic;
        alb   : out std_logic;
        aleb  : out std_logic;
        aneb  : out std_logic );
    end component fpcmp;

    component intcmp is port(
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
        aleb_u: out std_logic );
    end component intcmp;

    --synchronized reset
    signal res_sync: std_logic;

    --converted input vectors
    signal data_a_vect, data_b_vect: std_logic_vector(31 downto 0);

    --results
    signal fp_aeb, fp_agb, fp_ageb, fp_alb, fp_aleb, fp_aneb: std_logic;
    signal int_aeb, int_aneb, int_agb, int_ageb, int_alb, int_aleb, int_agb_u, int_ageb_u, int_alb_u, int_aleb_u : std_logic;

    signal result: std_logic;

begin

    --synchronize reset
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
        res_sync <= res_v;
    end process;

    --convert type of inputs
    data_a_vect <= std_logic_vector(data_a);
    data_b_vect <= std_logic_vector(data_b);

    --initialize comparators
    fpcmp0: fpcmp
        port map(res_sync, clk, data_a_vect, data_b_vect, fp_aeb, fp_agb,
        fp_ageb, fp_alb, fp_aleb, fp_aneb);

    intcmp0: intcmp
        port map(clk, res_sync, data_a_vect, data_b_vect, int_aeb, int_aneb,
        int_agb, int_ageb, int_alb, int_aleb, int_agb_u, int_ageb_u, int_alb_u,
        int_aleb_u);

    -- result selector
    result <=
        fp_aeb     when (opcode = x"0") else
        fp_agb     when (opcode = x"1") else
        fp_ageb    when (opcode = x"2") else
        fp_alb     when (opcode = x"3") else
        fp_aleb    when (opcode = x"4") else
        fp_aneb    when (opcode = x"5") else
        int_aeb    when (opcode = x"6") else
        int_aneb   when (opcode = x"7") else
        int_agb    when (opcode = x"8") else
        int_ageb   when (opcode = x"9") else
        int_alb    when (opcode = x"A") else
        int_aleb   when (opcode = x"B") else
        int_agb_u  when (opcode = x"C") else
        int_ageb_u when (opcode = x"D") else
        int_alb_u  when (opcode = x"E") else
        int_aleb_u;

    -- output generator
    output <= (x"0000000" & "000" & result) when (en = '1') else (others => 'Z');

end architecture comp_arch;
