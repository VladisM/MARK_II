library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpu is
    port(
        --system interface
        clk: in std_logic;
        res: in std_logic;
        --bus interface
        address: out std_logic_vector(23 downto 0);
        data_mosi: out std_logic_vector(31 downto 0);
        data_miso: in std_logic_vector(31 downto 0);
        we: out std_logic;
        oe: out std_logic;
        ack: in std_logic;
        swirq: out std_logic;
        --interrupts
        int: in std_logic;
        int_address: in std_logic_vector(23 downto 0);
        int_accept: out std_logic;
        int_completed: out std_logic
    );
end entity cpu;

architecture cpu_arch of cpu is
    component id is
        port(
            clk: in std_logic;
            res: in std_logic;

            instr_opcode: in std_logic_vector(7 downto 0);
            flag: in std_logic;
            ack: in std_logic;
            int: in std_logic;

            swirq: out std_logic;
            we: out std_logic;
            oe: out std_logic;
            int_accept: out std_logic;
            int_completed: out std_logic;
            data_c_sel: out std_logic_vector(2 downto 0);
            data_a_sel: out std_logic_vector(3 downto 0);
            data_b_sel: out std_logic_vector(2 downto 0);
            force_we_reg_14: out std_logic;
            inc_r14: out std_logic;
            inc_r15: out std_logic;
            dec_r15: out std_logic;
            instruction_we: out std_logic;
            regfile_c_we: out std_logic
        );
    end component id;
    component regfile_reg is port(
        clk: in std_logic;
        res: in std_logic;
        we: in std_logic;
        inc: in std_logic;
        dec: in std_logic;
        datain: in std_logic_vector(31 downto 0);
        dataout: buffer std_logic_vector(31 downto 0) );
    end component regfile_reg;
    component comparator is port(
        res: in std_logic;
        clk: in std_logic;
        opcode: in std_logic_vector(3 downto 0);
        data_a: in std_logic_vector(31 downto 0);
        data_b: in std_logic_vector(31 downto 0);
        output: out std_logic_vector(31 downto 0) );
    end component comparator;
    component mul is port(
        aclr        : in std_logic;
        clock       : in std_logic;
        dataa       : in std_logic_vector (31 downto 0);
        datab       : in std_logic_vector (31 downto 0);
        result      : out std_logic_vector (31 downto 0) );
    end component mul;
    component div is port(
        aclr        : in std_logic;
        clock       : in std_logic;
        dataa       : in std_logic_vector (31 downto 0);
        datab       : in std_logic_vector (31 downto 0);
        result      : out std_logic_vector (31 downto 0) );
    end component div;
    component add is port(
        aclr        : in std_logic ;
        add_sub     : in std_logic ;
        clock       : in std_logic ;
        dataa       : in std_logic_vector (31 downto 0);
        datab       : in std_logic_vector (31 downto 0);
        result      : out std_logic_vector (31 downto 0) );
    end component add;
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
            result  : out std_logic_vector (63 downto 0)
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

    -- main bus signals
    signal data_a, data_b, data_c: std_logic_vector(31 downto 0);

    -- partial results
    signal
        result_fpsub, result_fpmul, result_fpdiv, result_fpadd, result_log,
        result_rot, result_ari, divu_res, divs_res,
        divu_remain, divs_remain, add_res, sub_res, inc_res, dec_res, and_res,
        or_res, xor_res, mvil_res, mvih_res, not_res
    : std_logic_vector(31 downto 0);
    signal
        mulu_res, muls_res
    : std_logic_vector(63 downto 0);

    signal
        fp_addsub
    : std_logic;

    -- register values
    signal
        reg00_q, reg01_q, reg02_q, reg03_q, reg04_q, reg05_q, reg06_q, reg07_q,
        reg08_q, reg09_q, reg10_q, reg11_q, reg12_q, reg13_q, reg14_q, reg15_q
    : std_logic_vector(31 downto 0);

    -- register we
    signal
        reg00_we, reg01_we, reg02_we, reg03_we, reg04_we, reg05_we, reg06_we, reg07_we,
        reg08_we, reg09_we, reg10_we, reg11_we, reg12_we, reg13_we, reg14_we, reg15_we
    : std_logic;

    -- results from main parts
    signal
        fpu_result, comp_result, alu_result, barrel_result
    : std_logic_vector(31 downto 0);

    signal
        regfile_a, regfile_b
    : std_logic_vector(31 downto 0);
    signal
        zero_flag
    : std_logic_vector(15 downto 0);

    signal instruction_word: std_logic_vector(31 downto 0);
    signal res_sync: std_logic;

    --control signals from ID
    signal instr_opcode: std_logic_vector(7 downto 0);
    signal data_c_sel: std_logic_vector(2 downto 0);
    signal data_a_sel: std_logic_vector(3 downto 0);
    signal data_b_sel: std_logic_vector(2 downto 0);
    signal force_we_reg_14: std_logic;
    signal inc_r14, inc_r15, dec_r15: std_logic;
    signal instruction_we: std_logic;
    signal regfile_c_we: std_logic;
    signal flag: std_logic;

begin

    -- instruction register
    instr_reg0: process(clk) is
        variable instruction_var: std_logic_vector(31 downto 0);
    begin
        if rising_edge(clk) then
            if res = '1' then
                instruction_var := (others => '0');
            elsif instruction_we = '1' then
                instruction_var := data_miso;
            end if;
        end if;
        instruction_word <= instruction_var;
    end process;

    -- Synchronize reset for some MF
    process(clk) is
        variable res_v1: std_logic;
        variable res_v2: std_logic;
    begin
        if rising_edge(clk) then
            res_v2 := res_v1;
            res_v1 := res;
        end if;
        res_sync <= res_v2;
    end process;


    -- Initialize FP cores
    --   00 - subtraction    - 7 cycles
    --   01 - multiplication - 5 cycles
    --   10 - division       - 6 cycles
    --   11 - addition       - 7 cycles
    fpmul0: mul
        port map(res_sync, clk, data_a, data_b, result_fpmul);

    fpdiv0: div
        port map(res_sync, clk, data_a, data_b, result_fpdiv);

    fpadd0: add
        port map(res_sync, fp_addsub, clk, data_a, data_b, result_fpadd);

    result_fpsub <= result_fpadd;

    fp_addsub <= '0' when (instruction_word(21 downto 20) = "00") else '1';

    fpu_result <=
        result_fpsub when (instruction_word(21 downto 20) = "00") else
        result_fpmul when (instruction_word(21 downto 20) = "01") else
        result_fpdiv when (instruction_word(21 downto 20) = "10") else
        result_fpadd;

    -- barrel cores
    shift_log_0: lpm_clshift
        generic map ("logical", 32, 5)
        port map (data_a, instruction_word(20), data_b(4 downto 0), result_log);

    shift_rot_0: lpm_clshift
        generic map ("rotate", 32, 5)
        port map (data_a, instruction_word(20), data_b(4 downto 0), result_rot);

    shift_ari_0: lpm_clshift
        generic map ("arithmetic", 32, 5)
        port map (data_a, instruction_word(20), data_b(4 downto 0), result_ari);

    barrel_result <=
        result_log when (instruction_word(22 downto 21) = "00") else
        result_rot when (instruction_word(22 downto 21) = "01") else
        result_ari;


    -- ALU
    mul_unsigned_0 : lpm_mult
        generic map ("maximize_speed=9", "unsigned", 32, 32, 64)
        port map (data_b, data_a, mulu_res);

    mul_signed_0 : lpm_mult
        generic map ("maximize_speed=9", "signed", 32, 32, 64)
        port map (data_b, data_a, muls_res);

    div_unsigned_0: lpm_divide
        generic map ("unsigned", "maximize_speed=9,lpm_remainderpositive=true", "unsigned", 16, 32, 32)
        port map (res_sync, clk,divu_remain, data_b, data_a, divu_res);

    div_signed_0: lpm_divide
        generic map ("signed", "maximize_speed=9,lpm_remainderpositive=true", "signed", 16, 32, 32)
        port map (res_sync, clk,divs_remain, data_b, data_a, divs_res);

    --add
    add_res <= std_logic_vector(unsigned(data_a) + unsigned(data_b));

    --sub
    sub_res <= std_logic_vector(unsigned(data_a) - unsigned(data_b));

    --inc
    inc_res <= std_logic_vector(unsigned(data_a) + 1);

    --dec
    dec_res <= std_logic_vector(unsigned(data_a) - 1);

    --and
    and_res <= data_a and data_b;

    --or
    or_res <= data_a or data_b;

    --xor
    xor_res <= data_a xor data_b;

    --not
    not_res <= not(data_a);

    -- alu select result
    alu_result <=
        mulu_res(31 downto 0)    when (instruction_word(23 downto 20) = x"0") else
        muls_res(31 downto 0)    when (instruction_word(23 downto 20) = x"1") else
        divu_res                 when (instruction_word(23 downto 20) = x"2") else
        divs_res                 when (instruction_word(23 downto 20) = x"3") else
        divu_remain              when (instruction_word(23 downto 20) = x"4") else
        divs_remain              when (instruction_word(23 downto 20) = x"5") else
        add_res                  when (instruction_word(23 downto 20) = x"6") else
        sub_res                  when (instruction_word(23 downto 20) = x"7") else
        inc_res                  when (instruction_word(23 downto 20) = x"8") else
        dec_res                  when (instruction_word(23 downto 20) = x"9") else
        and_res                  when (instruction_word(23 downto 20) = x"a") else
        or_res                   when (instruction_word(23 downto 20) = x"b") else
        xor_res                  when (instruction_word(23 downto 20) = x"c") else
        not_res;

    -- FP and INT comparator
    comp0: comparator
        port map(res_sync, clk, instruction_word(23 downto 20), data_a, data_b, comp_result);

    -- register file
    reg00_q <= (others => '0');

    reg01: regfile_reg
        port map(clk, res, reg01_we, '0', '0', data_c, reg01_q);

    reg02: regfile_reg
        port map(clk, res, reg02_we, '0', '0', data_c, reg02_q);

    reg03: regfile_reg
        port map(clk, res, reg03_we, '0', '0', data_c, reg03_q);

    reg04: regfile_reg
        port map(clk, res, reg04_we, '0', '0', data_c, reg04_q);

    reg05: regfile_reg
        port map(clk, res, reg05_we, '0', '0', data_c, reg05_q);

    reg06: regfile_reg
        port map(clk, res, reg06_we, '0', '0', data_c, reg06_q);

    reg07: regfile_reg
        port map(clk, res, reg07_we, '0', '0', data_c, reg07_q);

    reg08: regfile_reg
        port map(clk, res, reg08_we, '0', '0', data_c, reg08_q);

    reg09: regfile_reg
        port map(clk, res, reg09_we, '0', '0', data_c, reg09_q);

    reg10: regfile_reg
        port map(clk, res, reg10_we, '0', '0', data_c, reg10_q);

    reg11: regfile_reg
        port map(clk, res, reg11_we, '0', '0', data_c, reg11_q);

    reg12: regfile_reg
        port map(clk, res, reg12_we, '0', '0', data_c, reg12_q);

    reg13: regfile_reg
        port map(clk, res, reg13_we, '0', '0', data_c, reg13_q);

    reg14: regfile_reg
        port map(clk, res, reg14_we, inc_r14, '0', data_c, reg14_q);

    reg15: regfile_reg
        port map(clk, res, reg15_we, inc_r15, dec_r15, data_c, reg15_q);

    reg01_we <= '1' when ((regfile_c_we = '1') and (instruction_word(3 downto 0) = x"1")) else '0';
    reg02_we <= '1' when ((regfile_c_we = '1') and (instruction_word(3 downto 0) = x"2")) else '0';
    reg03_we <= '1' when ((regfile_c_we = '1') and (instruction_word(3 downto 0) = x"3")) else '0';
    reg04_we <= '1' when ((regfile_c_we = '1') and (instruction_word(3 downto 0) = x"4")) else '0';
    reg05_we <= '1' when ((regfile_c_we = '1') and (instruction_word(3 downto 0) = x"5")) else '0';
    reg06_we <= '1' when ((regfile_c_we = '1') and (instruction_word(3 downto 0) = x"6")) else '0';
    reg07_we <= '1' when ((regfile_c_we = '1') and (instruction_word(3 downto 0) = x"7")) else '0';
    reg08_we <= '1' when ((regfile_c_we = '1') and (instruction_word(3 downto 0) = x"8")) else '0';
    reg09_we <= '1' when ((regfile_c_we = '1') and (instruction_word(3 downto 0) = x"9")) else '0';
    reg10_we <= '1' when ((regfile_c_we = '1') and (instruction_word(3 downto 0) = x"a")) else '0';
    reg11_we <= '1' when ((regfile_c_we = '1') and (instruction_word(3 downto 0) = x"b")) else '0';
    reg12_we <= '1' when ((regfile_c_we = '1') and (instruction_word(3 downto 0) = x"c")) else '0';
    reg13_we <= '1' when ((regfile_c_we = '1') and (instruction_word(3 downto 0) = x"d")) else '0';
    reg14_we <= '1' when (((regfile_c_we = '1') and (instruction_word(3 downto 0) = x"e")) or (force_we_reg_14 = '1')) else '0';
    reg15_we <= '1' when ((regfile_c_we = '1') and (instruction_word(3 downto 0) = x"f")) else '0';

    regfile_a <=
        reg00_q when instruction_word(11 downto 8) = x"0" else
        reg01_q when instruction_word(11 downto 8) = x"1" else
        reg02_q when instruction_word(11 downto 8) = x"2" else
        reg03_q when instruction_word(11 downto 8) = x"3" else
        reg04_q when instruction_word(11 downto 8) = x"4" else
        reg05_q when instruction_word(11 downto 8) = x"5" else
        reg06_q when instruction_word(11 downto 8) = x"6" else
        reg07_q when instruction_word(11 downto 8) = x"7" else
        reg08_q when instruction_word(11 downto 8) = x"8" else
        reg09_q when instruction_word(11 downto 8) = x"9" else
        reg10_q when instruction_word(11 downto 8) = x"a" else
        reg11_q when instruction_word(11 downto 8) = x"b" else
        reg12_q when instruction_word(11 downto 8) = x"c" else
        reg13_q when instruction_word(11 downto 8) = x"d" else
        reg14_q when instruction_word(11 downto 8) = x"e" else
        reg15_q;

    regfile_b <=
        reg00_q when instruction_word(7 downto 4) = x"0" else
        reg01_q when instruction_word(7 downto 4) = x"1" else
        reg02_q when instruction_word(7 downto 4) = x"2" else
        reg03_q when instruction_word(7 downto 4) = x"3" else
        reg04_q when instruction_word(7 downto 4) = x"4" else
        reg05_q when instruction_word(7 downto 4) = x"5" else
        reg06_q when instruction_word(7 downto 4) = x"6" else
        reg07_q when instruction_word(7 downto 4) = x"7" else
        reg08_q when instruction_word(7 downto 4) = x"8" else
        reg09_q when instruction_word(7 downto 4) = x"9" else
        reg10_q when instruction_word(7 downto 4) = x"a" else
        reg11_q when instruction_word(7 downto 4) = x"b" else
        reg12_q when instruction_word(7 downto 4) = x"c" else
        reg13_q when instruction_word(7 downto 4) = x"d" else
        reg14_q when instruction_word(7 downto 4) = x"e" else
        reg15_q;

    zero_flag(0) <= '1' when (reg00_q = x"00000000") else '0';
    zero_flag(1) <= '1' when (reg01_q = x"00000000") else '0';
    zero_flag(2) <= '1' when (reg02_q = x"00000000") else '0';
    zero_flag(3) <= '1' when (reg03_q = x"00000000") else '0';
    zero_flag(4) <= '1' when (reg04_q = x"00000000") else '0';
    zero_flag(5) <= '1' when (reg05_q = x"00000000") else '0';
    zero_flag(6) <= '1' when (reg06_q = x"00000000") else '0';
    zero_flag(7) <= '1' when (reg07_q = x"00000000") else '0';
    zero_flag(8) <= '1' when (reg08_q = x"00000000") else '0';
    zero_flag(9) <= '1' when (reg09_q = x"00000000") else '0';
    zero_flag(10) <= '1' when (reg10_q = x"00000000") else '0';
    zero_flag(11) <= '1' when (reg11_q = x"00000000") else '0';
    zero_flag(12) <= '1' when (reg12_q = x"00000000") else '0';
    zero_flag(13) <= '1' when (reg13_q = x"00000000") else '0';
    zero_flag(14) <= '1' when (reg14_q = x"00000000") else '0';
    zero_flag(15) <= '1' when (reg15_q = x"00000000") else '0';

    flag <=
        zero_flag(0) when instruction_word(23 downto 20) = x"0" else
        zero_flag(1) when instruction_word(23 downto 20) = x"1" else
        zero_flag(2) when instruction_word(23 downto 20) = x"2" else
        zero_flag(3) when instruction_word(23 downto 20) = x"3" else
        zero_flag(4) when instruction_word(23 downto 20) = x"4" else
        zero_flag(5) when instruction_word(23 downto 20) = x"5" else
        zero_flag(6) when instruction_word(23 downto 20) = x"6" else
        zero_flag(7) when instruction_word(23 downto 20) = x"7" else
        zero_flag(8) when instruction_word(23 downto 20) = x"8" else
        zero_flag(9) when instruction_word(23 downto 20) = x"9" else
        zero_flag(10) when instruction_word(23 downto 20) = x"a" else
        zero_flag(11) when instruction_word(23 downto 20) = x"b" else
        zero_flag(12) when instruction_word(23 downto 20) = x"c" else
        zero_flag(13) when instruction_word(23 downto 20) = x"d" else
        zero_flag(14) when instruction_word(23 downto 20) = x"e" else
        zero_flag(15);

    data_b <=
        regfile_b                               when data_b_sel = "000" else    --register file
        regfile_a                               when data_b_sel = "001" else    --show register A on busB (speed up CALLI)
        reg14_q                                 when data_b_sel = "010" else    --PC
        x"00" & instruction_word(27 downto 4)   when data_b_sel = "011" else    --call argument format
        reg00_q;                                                                --reg 0

    data_a <=
        x"00" & instruction_word(27 downto 4)                                   when data_a_sel = "0000" else --mvia, call and ld format
        x"00" & instruction_word(27 downto 24) & instruction_word(19 downto 0)  when data_a_sel = "0001" else --branch format
        x"00" & instruction_word(27 downto 8) & instruction_word(3 downto 0)    when data_a_sel = "0010" else --st format
        x"0000" & instruction_word(23 downto 8)                                 when data_a_sel = "0011" else --mvih mvil
        x"00" & int_address                                                     when data_a_sel = "0100" else --interrupt addr
        reg14_q                                                                 when data_a_sel = "0101" else --PC
        reg15_q                                                                 when data_a_sel = "0110" else --SP
        x"00" & std_logic_vector(unsigned(reg15_q(23 downto 0)) + 1)            when data_a_sel = "0111" else --SP+1
        x"00" & std_logic_vector(unsigned(reg15_q(23 downto 0)) - 1)            when data_a_sel = "1000" else --SP-1
        regfile_a;                                                                                            --register file

    data_c <=
        fpu_result                                  when data_c_sel = "000" else  --fpu
        comp_result                                 when data_c_sel = "001" else  --comparator
        alu_result                                  when data_c_sel = "010" else  --alu
        barrel_result                               when data_c_sel = "011" else  --barrel
        data_miso                                   when data_c_sel = "100" else  --miso bus
        data_b(31 downto 16) & data_a(15 downto 0)  when data_c_sel = "101" else  --alu mvil
        data_a(15 downto 0) & data_b(15 downto 0)   when data_c_sel = "110" else  --alu mvih
        data_a or data_b;                                                         --alu A or B

    address <= data_a(23 downto 0);
    data_mosi <= data_b;

    id0: id
        port map(
            clk, res, instruction_word(31 downto 24), flag, ack, int, swirq, we, oe,
            int_accept, int_completed, data_c_sel, data_a_sel, data_b_sel,
            force_we_reg_14, inc_r14, inc_r15, dec_r15, instruction_we,
            regfile_c_we
        );
end architecture cpu_arch;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity regfile_reg is
    port(
        clk: in std_logic;
        res: in std_logic;
        we: in std_logic;
        inc: in std_logic;
        dec: in std_logic;
        datain: in std_logic_vector(31 downto 0);
        dataout: out std_logic_vector(31 downto 0)
    );
end entity regfile_reg;

architecture regfile_reg_arch of regfile_reg is begin

    process(clk) is
        variable reg_var: std_logic_vector(31 downto 0);
    begin
        if rising_edge(clk) then
            if (res = '1') then
                reg_var := (others => '0');
            elsif (inc = '1') then
                reg_var := std_logic_vector(unsigned(reg_var) + 1);
            elsif (dec = '1') then
                reg_var := std_logic_vector(unsigned(reg_var) - 1);
            elsif (we = '1') then
                reg_var := datain;
            end if;
        end if;
        dataout <= reg_var;
    end process;

end architecture regfile_reg_arch;

library ieee;
use ieee.std_logic_1164.all;

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
        opcode: in std_logic_vector(3 downto 0);
        data_a: in std_logic_vector(31 downto 0);
        data_b: in std_logic_vector(31 downto 0);
        output: out std_logic_vector(31 downto 0)
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

    --results
    signal fp_aeb, fp_agb, fp_ageb, fp_alb, fp_aleb, fp_aneb: std_logic;
    signal int_aeb, int_aneb, int_agb, int_ageb, int_alb, int_aleb, int_agb_u, int_ageb_u, int_alb_u, int_aleb_u : std_logic;

    signal result: std_logic;

begin

    --initialize comparators
    fpcmp0: fpcmp
        port map(res, clk, data_a, data_b, fp_aeb, fp_agb,
        fp_ageb, fp_alb, fp_aleb, fp_aneb);

    intcmp0: intcmp
        port map(data_a, data_b, int_aeb, int_aneb,
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
    output <= (x"0000000" & "000" & result);

end architecture comp_arch;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity intcmp is
    port(
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

architecture intcmp_arch of intcmp is begin

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
