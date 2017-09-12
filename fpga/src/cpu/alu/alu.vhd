library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library lpm;
use lpm.all;

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
        lpm_pipeline       : natural;
        lpm_representation : string;
        lpm_widtha         : natural;
        lpm_widthb         : natural;
        lpm_widthp         : natural
    );
    port (
        aclr    : in std_logic ;
        clock   : in std_logic ;
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
        generic map ("maximize_speed=9", 1, "unsigned", 32, 32, 32)
        port map (res_s, clk, data_b_vect, data_a_vect, mulu_res);

    mul_signed_0 : lpm_mult
        generic map ("maximize_speed=9", 1, "signed", 32, 32, 32)
        port map (res_s, clk, data_b_vect, data_a_vect, muls_res);

    div_unsigned_0: lpm_divide
        generic map ("unsigned", "maximize_speed=6,lpm_remainderpositive=true", "unsigned", 1, 32, 32)
        port map (res_s, clk,divu_remain, data_b_vect, data_a_vect, divu_res);

    div_signed_0: lpm_divide
        generic map ("signed", "maximize_speed=6,lpm_remainderpositive=true", "signed", 1, 32, 32)
        port map (res_s, clk,divs_remain, data_b_vect, data_a_vect, divs_res);

    --add
    adder: process(res, clk) is
        variable result_v_add_v: unsigned(31 downto 0);
    begin
        if res = '1' then
            result_v_add_v := (others => '0');
        elsif rising_edge(clk) then
            result_v_add_v := dataa + datab;
        end if;
        add_res <= std_logic_vector(result_v_add_v);
    end process;

    --sub
    substraction: process(res, clk) is
        variable result_v_sub_v: unsigned(31 downto 0);
    begin
        if res = '1' then
            result_v_sub_v := (others => '0');
        elsif rising_edge(clk) then
            result_v_sub_v := dataa - datab;
        end if;
        sub_res <= std_logic_vector(result_v_sub_v);
    end process;

    --inc
    increment: process(res, clk) is
        variable result_v_inc: unsigned(31 downto 0);
    begin
        if res = '1' then
            result_v_inc := (others => '0');
        elsif rising_edge(clk) then
            result_v_inc := dataa + 1;
        end if;
        inc_res <= std_logic_vector(result_v_inc);
    end process;

    --dec
    decrement: process(res, clk) is
        variable result_v_dec: unsigned(31 downto 0);
    begin
        if res = '1' then
            result_v_dec := (others => '0');
        elsif rising_edge(clk) then
            result_v_dec := dataa - 1;
        end if;
        dec_res <= std_logic_vector(result_v_dec);
    end process;

    --and
    bitwiseand: process(res, clk) is
        variable result_v_and: unsigned(31 downto 0);
    begin
        if res = '1' then
            result_v_and := (others => '0');
        elsif rising_edge(clk) then
            result_v_and := dataa and datab;
        end if;
        and_res <= std_logic_vector(result_v_and);
    end process;

    --or
    bitwiseor: process(res, clk) is
        variable result_v_or: unsigned(31 downto 0);
    begin
        if res = '1' then
            result_v_or := (others => '0');
        elsif rising_edge(clk) then
            result_v_or := dataa or datab;
        end if;
        or_res <= std_logic_vector(result_v_or);
    end process;

    --xor
    bitwisexor: process(res, clk) is
        variable result_v_xor: unsigned(31 downto 0);
    begin
        if res = '1' then
            result_v_xor := (others => '0');
        elsif rising_edge(clk) then
            result_v_xor := dataa xor datab;
        end if;
        xor_res <= std_logic_vector(result_v_xor);
    end process;

    --not
    bitwisenot: process(res, clk) is
        variable result_v_not: unsigned(31 downto 0);
    begin
        if res = '1' then
            result_v_not := (others => '0');
        elsif rising_edge(clk) then
            result_v_not := not(dataa);
        end if;
        not_res <= std_logic_vector(result_v_not);
    end process;

    --mvil
    mvilsupp: process(res, clk) is
        variable result_v_mvil: unsigned(31 downto 0);
    begin
        if res = '1' then
            result_v_mvil := (others => '0');
        elsif rising_edge(clk) then
            result_v_mvil := dataa(31 downto 16) & datab(15 downto 0);
        end if;
        mvil_res <= std_logic_vector(result_v_mvil);
    end process;

    --mvih
    mvihsupp: process(res, clk) is
        variable result_v_mvih: unsigned(31 downto 0);
    begin
        if res = '1' then
            result_v_mvih := (others => '0');
        elsif rising_edge(clk) then
            result_v_mvih := datab(15 downto 0) & dataa(15 downto 0);
        end if;
        mvih_res <= std_logic_vector(result_v_mvih);
    end process;

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
