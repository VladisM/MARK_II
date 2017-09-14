library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity regfile is
    port(
        clk: in std_logic;
        res: in std_logic;
        dataa: out unsigned(31 downto 0);
        datab: out unsigned(31 downto 0);
        datac: in unsigned(31 downto 0);
        data_a_regsel: in std_logic_vector(3 downto 0);
        data_b_regsel: in std_logic_vector(3 downto 0);
        data_c_regsel: in std_logic_vector(3 downto 0);
        we: in std_logic;
        data_a_oe: in std_logic;
        data_b_oe: in std_logic;
        zero: out std_logic_vector(15 downto 0);
        inc_r14: in std_logic;
        inc_r15: in std_logic;
        dec_r14: in std_logic;
        dec_r15: in std_logic;
        q_r15: out unsigned(23 downto 0)
    );
end entity regfile;

architecture regfile_arch of regfile is

    component regfile_reg is port(
        clk: in std_logic;
        res: in std_logic;
        we: in std_logic;
        inc: in std_logic;
        dec: in std_logic;
        datain: in unsigned(31 downto 0);
        dataout: buffer unsigned(31 downto 0);
        zero_flag: out std_logic );
    end component regfile_reg;

    signal reg00_q, reg01_q, reg02_q, reg03_q, reg04_q, reg05_q, reg06_q, reg07_q,
           reg08_q, reg09_q, reg10_q, reg11_q, reg12_q, reg13_q, reg14_q, reg15_q: unsigned(31 downto 0);

    signal reg00_we, reg01_we, reg02_we, reg03_we, reg04_we, reg05_we, reg06_we, reg07_we,
           reg08_we, reg09_we, reg10_we, reg11_we, reg12_we, reg13_we, reg14_we, reg15_we: std_logic;

    signal reg00_zf, reg01_zf, reg02_zf, reg03_zf, reg04_zf, reg05_zf, reg06_zf, reg07_zf,
           reg08_zf, reg09_zf, reg10_zf, reg11_zf, reg12_zf, reg13_zf, reg14_zf, reg15_zf: std_logic;

begin

    reg00_q <= (others => '0');
    reg00_zf <= '0';

    reg01: regfile_reg
        port map(clk, res, 0, 0, reg01_we, datac, reg01_q, reg01_zf);

    reg02: regfile_reg
        port map(clk, res, 0, 0, reg02_we, datac, reg02_q, reg02_zf);

    reg03: regfile_reg
        port map(clk, res, 0, 0, reg03_we, datac, reg03_q, reg03_zf);

    reg04: regfile_reg
        port map(clk, res, 0, 0, reg04_we, datac, reg04_q, reg04_zf);

    reg05: regfile_reg
        port map(clk, res, 0, 0, reg05_we, datac, reg05_q, reg05_zf);

    reg06: regfile_reg
        port map(clk, res, 0, 0, reg06_we, datac, reg06_q, reg06_zf);

    reg07: regfile_reg
        port map(clk, res, 0, 0, reg07_we, datac, reg07_q, reg07_zf);

    reg08: regfile_reg
        port map(clk, res, 0, 0, reg08_we, datac, reg08_q, reg08_zf);

    reg09: regfile_reg
        port map(clk, res, 0, 0, reg09_we, datac, reg09_q, reg09_zf);

    reg10: regfile_reg
        port map(clk, res, 0, 0, reg10_we, datac, reg10_q, reg10_zf);

    reg11: regfile_reg
        port map(clk, res, 0, 0, reg11_we, datac, reg11_q, reg11_zf);

    reg12: regfile_reg
        port map(clk, res, 0, 0, reg12_we, datac, reg12_q, reg12_zf);

    reg13: regfile_reg
        port map(clk, res, 0, 0, reg13_we, datac, reg13_q, reg13_zf);

    reg14: regfile_reg
        port map(clk, res, inc_r14, dec_r14, reg14_we, datac, reg14_q, reg14_zf);

    reg15: regfile_reg
        port map(clk, res, inc_r15, dec_r15, reg15_we, datac, reg15_q, reg15_zf);

    reg01_we <= '1' when ((we = '1') and (data_c_regsel = x"1")) else '0';
    reg02_we <= '1' when ((we = '1') and (data_c_regsel = x"2")) else '0';
    reg03_we <= '1' when ((we = '1') and (data_c_regsel = x"3")) else '0';
    reg04_we <= '1' when ((we = '1') and (data_c_regsel = x"4")) else '0';
    reg05_we <= '1' when ((we = '1') and (data_c_regsel = x"5")) else '0';
    reg06_we <= '1' when ((we = '1') and (data_c_regsel = x"6")) else '0';
    reg07_we <= '1' when ((we = '1') and (data_c_regsel = x"7")) else '0';
    reg08_we <= '1' when ((we = '1') and (data_c_regsel = x"8")) else '0';
    reg09_we <= '1' when ((we = '1') and (data_c_regsel = x"9")) else '0';
    reg10_we <= '1' when ((we = '1') and (data_c_regsel = x"a")) else '0';
    reg11_we <= '1' when ((we = '1') and (data_c_regsel = x"b")) else '0';
    reg12_we <= '1' when ((we = '1') and (data_c_regsel = x"c")) else '0';
    reg13_we <= '1' when ((we = '1') and (data_c_regsel = x"d")) else '0';
    reg14_we <= '1' when ((we = '1') and (data_c_regsel = x"e")) else '0';
    reg15_we <= '1' when ((we = '1') and (data_c_regsel = x"f")) else '0';

    dataa <=
        reg00_q when ((data_a_oe = '1') and (data_a_regsel = x"0")) else
        reg01_q when ((data_a_oe = '1') and (data_a_regsel = x"1")) else
        reg02_q when ((data_a_oe = '1') and (data_a_regsel = x"2")) else
        reg03_q when ((data_a_oe = '1') and (data_a_regsel = x"3")) else
        reg04_q when ((data_a_oe = '1') and (data_a_regsel = x"4")) else
        reg05_q when ((data_a_oe = '1') and (data_a_regsel = x"5")) else
        reg06_q when ((data_a_oe = '1') and (data_a_regsel = x"6")) else
        reg07_q when ((data_a_oe = '1') and (data_a_regsel = x"7")) else
        reg08_q when ((data_a_oe = '1') and (data_a_regsel = x"8")) else
        reg09_q when ((data_a_oe = '1') and (data_a_regsel = x"9")) else
        reg10_q when ((data_a_oe = '1') and (data_a_regsel = x"a")) else
        reg11_q when ((data_a_oe = '1') and (data_a_regsel = x"b")) else
        reg12_q when ((data_a_oe = '1') and (data_a_regsel = x"c")) else
        reg13_q when ((data_a_oe = '1') and (data_a_regsel = x"d")) else
        reg14_q when ((data_a_oe = '1') and (data_a_regsel = x"e")) else
        reg15_q when ((data_a_oe = '1') and (data_a_regsel = x"f")) else
        (others => 'Z');

    datab <=
        reg00_q when ((data_b_oe = '1') and (data_b_regsel = x"0")) else
        reg01_q when ((data_b_oe = '1') and (data_b_regsel = x"1")) else
        reg02_q when ((data_b_oe = '1') and (data_b_regsel = x"2")) else
        reg03_q when ((data_b_oe = '1') and (data_b_regsel = x"3")) else
        reg04_q when ((data_b_oe = '1') and (data_b_regsel = x"4")) else
        reg05_q when ((data_b_oe = '1') and (data_b_regsel = x"5")) else
        reg06_q when ((data_b_oe = '1') and (data_b_regsel = x"6")) else
        reg07_q when ((data_b_oe = '1') and (data_b_regsel = x"7")) else
        reg08_q when ((data_b_oe = '1') and (data_b_regsel = x"8")) else
        reg09_q when ((data_b_oe = '1') and (data_b_regsel = x"9")) else
        reg10_q when ((data_b_oe = '1') and (data_b_regsel = x"a")) else
        reg11_q when ((data_b_oe = '1') and (data_b_regsel = x"b")) else
        reg12_q when ((data_b_oe = '1') and (data_b_regsel = x"c")) else
        reg13_q when ((data_b_oe = '1') and (data_b_regsel = x"d")) else
        reg14_q when ((data_b_oe = '1') and (data_b_regsel = x"e")) else
        reg15_q when ((data_b_oe = '1') and (data_b_regsel = x"f")) else
        (others => 'Z');

    zero(0) <= reg00_zf;
    zero(1) <= reg01_zf;
    zero(2) <= reg02_zf;
    zero(3) <= reg03_zf;
    zero(4) <= reg04_zf;
    zero(5) <= reg05_zf;
    zero(6) <= reg06_zf;
    zero(7) <= reg07_zf;
    zero(8) <= reg08_zf;
    zero(9) <= reg09_zf;
    zero(10) <= reg10_zf;
    zero(11) <= reg11_zf;
    zero(12) <= reg12_zf;
    zero(13) <= reg13_zf;
    zero(14) <= reg14_zf;
    zero(15) <= reg15_zf;

    q_r15 <= reg15_q(23 downto 0);

end architecture regfile_arch;
