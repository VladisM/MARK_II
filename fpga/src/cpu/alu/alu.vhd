library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lpm;
use lpm.all;

-- operation       op     cycle
-- mulu            0x0    0
-- muls            0x1    0
-- divu            0x2    32
-- divs            0x3    32
-- divu_remain     0x4    32
-- divs_remain     0x5    32
-- add             0x6    0
-- sub             0x7    0
-- inc             0x8    0
-- dec             0x9    0
-- and             0xa    0
-- or              0xb    0
-- xor             0xc    0
-- mvil            0xd    0
-- mvih            0xe    0
-- not             0xf    0

entity alu is
    port(
        clk: in std_logic;
        res: in std_logic;
        en: in std_logic;
        opcode: in std_logic_vector(3 downto 0);
        dataa: in unsigned(31 downto 0);
        datab: in unsigned(31 downto 0);
        result: out unsigned(31 downto 0)
    );
end entity alu;

architecture alu_arch of alu is

    component lpm_mult
    generic (
        lpm_hint           : string;
        lpm_representation : string;
        lpm_widtha         : natural;
        lpm_widthb         : natural;
        lpm_widthp         : natural
    );
    port (
        datab   : in std_logic_vector (31 downto 0);
        dataa   : in std_logic_vector (31 downto 0);
        result  : out std_logic_vector (31 downto 0)
    );
    end component;

    component lpm_divide
    generic (
        lpm_drepresentation : string;
        lpm_hint            : string;
        lpm_nrepresentation : string;
        lpm_pipeline        : natural;
        lpm_widthd          : natural;
        lpm_widthn          : natural
    );
    port (
        aclr     : in std_logic ;
        clock    : in std_logic ;
        remain   : out std_logic_vector (31 downto 0);
        denom    : in std_logic_vector (31 downto 0);
        numer    : in std_logic_vector (31 downto 0);
        quotient : out std_logic_vector (31 downto 0)
    );
    end component;


    signal res_s: std_logic;
    signal data_a_vect, data_b_vect: std_logic_vector(31 downto 0);

    signal mulu_res, muls_res: std_logic_vector(31 downto 0);
    signal divu_res, divs_res: std_logic_vector(31 downto 0);
    signal divu_remain, divs_remain: std_logic_vector(31 downto 0);
    signal add_res, sub_res, inc_res, dec_res, and_res, or_res, xor_res,
           mvil_res, mvih_res, not_res: std_logic_vector(31 downto 0);

    signal result_raw: std_logic_vector(31 downto 0);

begin

    data_a_vect <= std_logic_vector(dataa);
    data_b_vect <= std_logic_vector(datab);

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

    mul_unsigned_0 : lpm_mult
        generic map ("maximize_speed=9", "unsigned", 32, 32, 32)
        port map (data_b_vect, data_a_vect, mulu_res);

    mul_signed_0 : lpm_mult
        generic map ("maximize_speed=9", "signed", 32, 32, 32)
        port map (data_b_vect, data_a_vect, muls_res);

    div_unsigned_0: lpm_divide
        generic map ("unsigned", "maximize_speed=9,lpm_remainderpositive=true", "unsigned", 32, 32, 32)
        port map (res_s, clk,divu_remain, data_b_vect, data_a_vect, divu_res);

    div_signed_0: lpm_divide
        generic map ("signed", "maximize_speed=9,lpm_remainderpositive=true", "signed", 32, 32, 32)
        port map (res_s, clk,divs_remain, data_b_vect, data_a_vect, divs_res);

    --add
    add_res <= std_logic_vector(dataa + datab);

    --sub
    sub_res <= std_logic_vector(dataa - datab);

    --inc
    inc_res <= std_logic_vector(dataa + 1);

    --dec
    dec_res <= std_logic_vector(dataa - 1);

    --and
    and_res <= std_logic_vector(dataa and datab);

    --or
    or_res <= std_logic_vector(dataa or datab);

    --xor
    xor_res <= std_logic_vector(dataa xor datab);

    --not
    not_res <= std_logic_vector(not(dataa));

    --mvil
    mvil_res <= std_logic_vector(datab(31 downto 16) & dataa(15 downto 0));

    --mvih
    mvih_res <= std_logic_vector(dataa(15 downto 0) & datab(15 downto 0));

    --select result
    result_raw <=
        mulu_res    when (opcode = x"0") else
        muls_res    when (opcode = x"1") else
        divu_res    when (opcode = x"2") else
        divs_res    when (opcode = x"3") else
        divu_remain when (opcode = x"4") else
        divs_remain when (opcode = x"5") else
        add_res     when (opcode = x"6") else
        sub_res     when (opcode = x"7") else
        inc_res     when (opcode = x"8") else
        dec_res     when (opcode = x"9") else
        and_res     when (opcode = x"a") else
        or_res      when (opcode = x"b") else
        xor_res     when (opcode = x"c") else
        mvil_res    when (opcode = x"d") else
        mvih_res    when (opcode = x"e") else
        not_res;

    --tri state output control
    result <= unsigned(result_raw) when en = '1' else (others => 'Z');

end architecture alu_arch;
