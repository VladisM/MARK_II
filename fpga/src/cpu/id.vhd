library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity id is
    port(
        clk: in std_logic;
        res: in std_logic;

        instr_opcode: in std_logic_vector(7 downto 0);
        flag: in std_logic;
        ack: in std_logic;
        int: in std_logic;

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
end entity id;

architecture id_arch of id is


    type id_state_type is (
        start, start_inc, start_inc_intcmp, start_dec, start_wait, start_decode, start_calli, start_call,
        intrq, intrq_set, intrq_inc, intrq_inc_set, intrq_dec, intrq_dec_set, intrq_calli, intrq_call,

        ret, reti,
        call, calli,
        pop, push,
        ld, ldi, st, sti,
        bz_bnz_set, bzi_bnzi_set,
        mvil, mvih, mvia, barrel, alu,
        cmpi, cmpf, cmpf_2,
        div, div_w0, div_w1, div_w2, div_w3, div_w4, div_w5, div_w6, div_w7,
        div_w8, div_w9, div_w10, div_w11, div_w12, div_w13, div_w14, div_done,
        faddsub, faddsub_w0, faddsub_w1, faddsub_w2, faddsub_w3, faddsub_w4,
        faddsub_w5, faddsub_done,
        fdiv, fdiv_w0, fdiv_w1, fdiv_w2, fdiv_w3, fdiv_w4, fdiv_done,
        fmul, fmul_w0, fmul_w1, fmul_w2, fmul_w3, fmul_done
    );

    signal id_state: id_state_type;

    constant data_a_arg_mvia: std_logic_vector(3 downto 0) := "0000";
    constant data_a_arg_branch: std_logic_vector(3 downto 0) := "0001";
    constant data_a_arg_st: std_logic_vector(3 downto 0) := "0010";
    constant data_a_arg_mvi: std_logic_vector(3 downto 0) := "0011";
    constant data_a_int_addr: std_logic_vector(3 downto 0) := "0100";
    constant data_a_pc: std_logic_vector(3 downto 0) := "0101";
    constant data_a_sp: std_logic_vector(3 downto 0) := "0110";
    constant data_a_sp_plus: std_logic_vector(3 downto 0) := "0111";
    constant data_a_sp_minus: std_logic_vector(3 downto 0) := "1000";
    constant data_a_regfile: std_logic_vector(3 downto 0) := "1001";

    constant data_b_regfile: std_logic_vector(2 downto 0) := "000";
    constant data_b_regfile_a: std_logic_vector(2 downto 0) := "001";
    constant data_b_pc: std_logic_vector(2 downto 0) := "010";
    constant data_b_arg_call: std_logic_vector(2 downto 0) := "011";
    constant data_b_reg0: std_logic_vector(2 downto 0) := "100";

    constant data_c_fpu: std_logic_vector(2 downto 0) := "000";
    constant data_c_cmp: std_logic_vector(2 downto 0) := "001";
    constant data_c_alu: std_logic_vector(2 downto 0) := "010";
    constant data_c_barrel: std_logic_vector(2 downto 0) := "011";
    constant data_c_miso: std_logic_vector(2 downto 0) := "100";
    constant data_c_mvil: std_logic_vector(2 downto 0) := "101";
    constant data_c_mvih: std_logic_vector(2 downto 0) := "110";
    constant data_c_aorb: std_logic_vector(2 downto 0) := "111";

    constant data_a_dontcare: std_logic_vector(3 downto 0) := "----";
    constant data_b_dontcare: std_logic_vector(2 downto 0) := "---";
    constant data_c_dontcare: std_logic_vector(2 downto 0) := "---";

begin


    decoder: process(clk) is
    begin
        if rising_edge(clk) then
            if res = '1' then
                id_state <= start;
            else
                case id_state is
                    when start =>
                        case ack is
                            when '1' => id_state <= start_decode;
                            when others => id_state <= start_wait;
                        end case;
                    when start_inc =>
                        case ack is
                            when '1' => id_state <= start_decode;
                            when others => id_state <= start_wait;
                        end case;
                    when start_calli =>
                        case ack is
                            when '1' => id_state <= start_decode;
                            when others => id_state <= start_wait;
                        end case;
                    when start_call =>
                        case ack is
                            when '1' => id_state <= start_decode;
                            when others => id_state <= start_wait;
                        end case;
                    when start_inc_intcmp =>
                        case ack is
                            when '1' => id_state <= start_decode;
                            when others => id_state <= start_wait;
                        end case;
                    when start_dec =>
                        case ack is
                            when '1' => id_state <= start_decode;
                            when others => id_state <= start_wait;
                        end case;
                    when start_wait =>
                        case ack is
                            when '1' => id_state <= start_decode;
                            when others => id_state <= start_wait;
                        end case;
                    when start_decode =>
                        case instr_opcode(7) is
                            when '1' =>
                                case instr_opcode(6 downto 4) is
                                    when "000" => id_state <= call;
                                    when "001" => id_state <= ld;
                                    when "010" => id_state <= st;
                                    when "011" =>
                                        case flag is
                                            when '1' => id_state <= bz_bnz_set;
                                            when others =>
                                                case int is
                                                    when '1' => id_state <= intrq_inc;
                                                    when others => id_state <= start_inc;
                                                end case;
                                        end case;
                                    when "100" =>
                                        case flag is
                                            when '0' => id_state <= bz_bnz_set;
                                            when others =>
                                                case int is
                                                    when '1' => id_state <= intrq_inc;
                                                    when others => id_state <= start_inc;
                                                end case;
                                        end case;
                                    when "101" => id_state <= mvia;
                                    when others => id_state <= start;
                                end case;
                            when others =>
                                case instr_opcode(4 downto 0) is
                                    when "00001" => id_state <= ret;
                                    when "00010" => id_state <= reti;
                                    when "00011" => id_state <= calli;
                                    when "00100" => id_state <= push;
                                    when "00101" => id_state <= pop;
                                    when "00110" => id_state <= ldi;
                                    when "00111" => id_state <= sti;

                                    when "01000" =>
                                        case flag is
                                            when '0' => id_state <= bzi_bnzi_set;
                                            when others =>
                                                case int is
                                                    when '1' => id_state <= intrq_inc;
                                                    when others => id_state <= start_inc;
                                                end case;
                                        end case;
                                    when "01001" =>
                                        case flag is
                                            when '1' => id_state <= bzi_bnzi_set;
                                            when others =>
                                                case int is
                                                    when '1' => id_state <= intrq_inc;
                                                    when others => id_state <= start_inc;
                                                end case;
                                        end case;

                                    when "01010" => id_state <= cmpi;
                                    when "01011" => id_state <= cmpf;
                                    when "01100" => id_state <= alu;
                                    when "01101" => id_state <= div;
                                    when "01110" => id_state <= barrel;
                                    when "01111" => id_state <= faddsub;
                                    when "10000" => id_state <= fmul;
                                    when "10001" => id_state <= fdiv;
                                    when "10010" => id_state <= mvil;
                                    when "10011" => id_state <= mvih;
                                    when others => id_state <= start;
                                end case;
                        end case;
                    when intrq =>
                        case ack is
                            when '1' => id_state <= intrq_set;
                            when others => id_state <= intrq;
                        end case;
                    when intrq_set =>
                        id_state <= start;
                    when intrq_calli =>
                        case ack is
                            when '1' => id_state <= intrq_set;
                            when others => id_state <= intrq_calli;
                        end case;
                    when intrq_call =>
                        case ack is
                            when '1' => id_state <= intrq_set;
                            when others => id_state <= intrq_call;
                        end case;
                    when intrq_inc =>
                        case ack is
                            when '1' => id_state <= intrq_inc_set;
                            when others => id_state <= intrq_inc;
                        end case;
                    when intrq_inc_set =>
                        id_state <= start_inc;

                    when intrq_dec =>
                        case ack is
                            when '1' => id_state <= intrq_dec_set;
                            when others => id_state <= intrq_dec;
                        end case;
                    when intrq_dec_set =>
                        id_state <= start;

                    when ret =>
                        case ack is
                            when '1' =>
                                case int is
                                    when '1' => id_state <= intrq_inc;
                                    when others => id_state <= start_inc;
                                end case;
                            when others => id_state <= ret;
                        end case;
                    when reti =>
                        case ack is
                            when '1' => id_state <= start_inc_intcmp;
                            when others => id_state <= reti;
                        end case;

                    when call =>
                        case ack is
                            when '1' =>
                                case int is
                                    when '1' => id_state <= intrq_call;
                                    when others => id_state <= start_call;
                                end case;
                            when others => id_state <= call;
                        end case;

                    when calli =>
                        case ack is
                            when '1' =>
                                case int is
                                    when '1' => id_state <= intrq_calli;
                                    when others => id_state <= start_calli;
                                end case;
                            when others => id_state <= calli;
                        end case;

                    when pop =>
                        case ack is
                            when '1' =>
                                case int is
                                    when '1' => id_state <= intrq_inc;
                                    when others => id_state <= start_inc;
                                end case;
                            when others => id_state <= pop;
                        end case;

                    when push =>
                        case ack is
                            when '1' =>
                                case int is
                                    when '1' => id_state <= intrq_dec;
                                    when others => id_state <= start_dec;
                                end case;
                            when others => id_state <= push;
                        end case;

                    when ld =>
                        case ack is
                            when '1' =>
                                case int is
                                    when '1' => id_state <= intrq;
                                    when others => id_state <= start;
                                end case;
                            when others => id_state <= ld;
                        end case;
                    when ldi =>
                        case ack is
                            when '1' =>
                                case int is
                                    when '1' => id_state <= intrq;
                                    when others => id_state <= start;
                                end case;
                            when others => id_state <= ldi;
                        end case;
                    when st =>
                        case ack is
                            when '1' =>
                                case int is
                                    when '1' => id_state <= intrq;
                                    when others => id_state <= start;
                                end case;
                            when others => id_state <= st;
                        end case;
                    when sti =>
                        case ack is
                            when '1' =>
                                case int is
                                    when '1' => id_state <= intrq;
                                    when others => id_state <= start;
                                end case;
                            when others => id_state <= sti;
                        end case;


                    when bz_bnz_set =>
                        case int is
                            when '1' => id_state <= intrq;
                            when others => id_state <= start;
                        end case;


                    when bzi_bnzi_set =>
                        case int is
                            when '1' => id_state <= intrq;
                            when others => id_state <= start;
                        end case;

                    when mvil =>
                        case int is
                            when '1' => id_state <= intrq;
                            when others => id_state <= start;
                        end case;
                    when mvih =>
                        case int is
                            when '1' => id_state <= intrq;
                            when others => id_state <= start;
                        end case;
                    when mvia =>
                        case int is
                            when '1' => id_state <= intrq;
                            when others => id_state <= start;
                        end case;
                    when barrel =>
                        case int is
                            when '1' => id_state <= intrq;
                            when others => id_state <= start;
                        end case;
                    when alu =>
                        case int is
                            when '1' => id_state <= intrq;
                            when others => id_state <= start;
                        end case;

                    when cmpi =>
                        case int is
                            when '1' => id_state <= intrq;
                            when others => id_state <= start;
                        end case;
                    when cmpf => id_state <= cmpf_2;
                    when cmpf_2 =>
                        case int is
                            when '1' => id_state <= intrq;
                            when others => id_state <= start;
                        end case;

                    when div     => id_state <= div_w0;
                    when div_w0  => id_state <= div_w1;
                    when div_w1  => id_state <= div_w2;
                    when div_w2  => id_state <= div_w3;
                    when div_w3  => id_state <= div_w4;
                    when div_w4  => id_state <= div_w5;
                    when div_w5  => id_state <= div_w6;
                    when div_w6  => id_state <= div_w7;
                    when div_w7  => id_state <= div_w8;
                    when div_w8  => id_state <= div_w9;
                    when div_w9  => id_state <= div_w10;
                    when div_w10 => id_state <= div_w11;
                    when div_w11 => id_state <= div_w12;
                    when div_w12 => id_state <= div_w13;
                    when div_w13 => id_state <= div_w14;
                    when div_w14 => id_state <= div_done;

                    when div_done =>
                        case int is
                            when '1' => id_state <= intrq;
                            when others => id_state <= start;
                        end case;

                    when faddsub      => id_state <= faddsub_w0;
                    when faddsub_w0   => id_state <= faddsub_w1;
                    when faddsub_w1   => id_state <= faddsub_w2;
                    when faddsub_w2   => id_state <= faddsub_w3;
                    when faddsub_w3   => id_state <= faddsub_w4;
                    when faddsub_w4   => id_state <= faddsub_w5;
                    when faddsub_w5   => id_state <= faddsub_done;
                    when faddsub_done =>
                        case int is
                            when '1' => id_state <= intrq;
                            when others => id_state <= start;
                        end case;

                    when fmul      => id_state <= fmul_w0;
                    when fmul_w0   => id_state <= fmul_w1;
                    when fmul_w1   => id_state <= fmul_w2;
                    when fmul_w2   => id_state <= fmul_w3;
                    when fmul_w3   => id_state <= fmul_done;
                    when fmul_done =>
                        case int is
                            when '1' => id_state <= intrq;
                            when others => id_state <= start;
                        end case;

                    when fdiv      => id_state <= fdiv_w0;
                    when fdiv_w0   => id_state <= fdiv_w1;
                    when fdiv_w1   => id_state <= fdiv_w2;
                    when fdiv_w2   => id_state <= fdiv_w3;
                    when fdiv_w3   => id_state <= fdiv_w4;
                    when fdiv_w4   => id_state <= fdiv_done;
                    when fdiv_done =>
                        case int is
                            when '1' => id_state <= intrq;
                            when others => id_state <= start;
                        end case;

                end case;
            end if;
        end if;
    end process;


    outputs: process(id_state) is begin

        case id_state is

            when start =>
                we <= '0'; oe <= '0'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '1'; force_we_reg_14 <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '0';
                data_a_sel <= data_a_pc;
                data_b_sel <= data_b_dontcare;
                data_c_sel <= data_c_dontcare;
                regfile_c_we <= '0';

            when start_inc =>
                we <= '0'; oe <= '1'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '1'; force_we_reg_14 <= '0';
                inc_r14 <= '0'; inc_r15 <= '1'; dec_r15 <= '0';
                data_a_sel <= data_a_pc;
                data_b_sel <= data_b_dontcare;
                data_c_sel <= data_c_dontcare;
                regfile_c_we <= '0';

            when start_inc_intcmp =>
                we <= '0'; oe <= '1'; int_accept <= '0'; int_completed <= '1';
                instruction_we <= '1'; force_we_reg_14 <= '0';
                inc_r14 <= '0'; inc_r15 <= '1'; dec_r15 <= '0';
                data_a_sel <= data_a_pc;
                data_b_sel <= data_b_dontcare;
                data_c_sel <= data_c_dontcare;
                regfile_c_we <= '0';

            when start_dec =>
                we <= '0'; oe <= '1'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '1'; force_we_reg_14 <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '1';
                data_a_sel <= data_a_pc;
                data_b_sel <= data_b_dontcare;
                data_c_sel <= data_c_dontcare;
                regfile_c_we <= '0';

            when start_wait =>
                we <= '0'; oe <= '1'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '1'; force_we_reg_14 <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '0';
                data_a_sel <= data_a_pc;
                data_b_sel <= data_b_dontcare;
                data_c_sel <= data_c_dontcare;
                regfile_c_we <= '0';

            when start_decode =>
                we <= '0'; oe <= '0'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '0'; force_we_reg_14 <= '0';
                inc_r14 <= '1'; inc_r15 <= '0'; dec_r15 <= '0';
                data_a_sel <= data_a_dontcare;
                data_b_sel <= data_b_dontcare;
                data_c_sel <= data_c_dontcare;
                regfile_c_we <= '0';

            when start_calli =>
                we <= '0'; oe <= '1'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '1'; force_we_reg_14 <= '1';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '1';
                data_a_sel <= data_a_regfile;
                data_b_sel <= data_b_reg0;
                data_c_sel <= data_c_aorb;
                regfile_c_we <= '0';

            when start_call =>
                we <= '0'; oe <= '1'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '1'; force_we_reg_14 <= '1';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '1';
                data_a_sel <= data_a_arg_mvia;
                data_b_sel <= data_b_reg0;
                data_c_sel <= data_c_aorb;
                regfile_c_we <= '0';

            when ret =>
                we <= '0'; oe <= '1'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '0'; force_we_reg_14 <= '1';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '0';
                data_a_sel <= data_a_sp_plus;
                data_b_sel <= data_b_dontcare;
                data_c_sel <= data_c_miso;
                regfile_c_we <= '0';

            when reti =>
                we <= '0'; oe <= '1'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '0'; force_we_reg_14 <= '1';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '0';
                data_a_sel <= data_a_sp_plus;
                data_b_sel <= data_b_dontcare;
                data_c_sel <= data_c_miso;
                regfile_c_we <= '0';

            when call =>
                we <= '1'; oe <= '0'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '0'; force_we_reg_14 <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '0';
                data_a_sel <= data_a_sp;
                data_b_sel <= data_b_pc;
                data_c_sel <= data_c_dontcare;
                regfile_c_we <= '0';

            when calli =>
                we <= '1'; oe <= '0'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '0'; force_we_reg_14 <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '0';
                data_a_sel <= data_a_sp;
                data_b_sel <= data_b_pc;
                data_c_sel <= data_c_dontcare;
                regfile_c_we <= '0';

            when pop =>
                we <= '0'; oe <= '1'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '0'; force_we_reg_14 <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '0';
                data_a_sel <= data_a_sp_plus;
                data_b_sel <= data_b_dontcare;
                data_c_sel <= data_c_miso;
                regfile_c_we <= '1';

            when push =>
                we <= '1'; oe <= '0'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '0'; force_we_reg_14 <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '0';
                data_a_sel <= data_a_sp;
                data_b_sel <= data_b_regfile;
                data_c_sel <= data_c_dontcare;
                regfile_c_we <= '0';

            when ld =>
                we <= '0'; oe <= '1'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '0'; force_we_reg_14 <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '0';
                data_a_sel <= data_a_arg_mvia;
                data_b_sel <= data_b_dontcare;
                data_c_sel <= data_c_miso;
                regfile_c_we <= '1';

            when ldi =>
                we <= '0'; oe <= '1'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '0'; force_we_reg_14 <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '0';
                data_a_sel <= data_a_regfile;
                data_b_sel <= data_b_dontcare;
                data_c_sel <= data_c_miso;
                regfile_c_we <= '1';

            when st =>
                we <= '1'; oe <= '0'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '0'; force_we_reg_14 <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '0';
                data_a_sel <= data_a_arg_st;
                data_b_sel <= data_b_regfile;
                data_c_sel <= data_c_dontcare;
                regfile_c_we <= '0';

            when sti =>
                we <= '1'; oe <= '0'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '0'; force_we_reg_14 <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '0';
                data_a_sel <= data_a_regfile;
                data_b_sel <= data_b_regfile;
                data_c_sel <= data_c_dontcare;
                regfile_c_we <= '0';

            when bz_bnz_set =>
                we <= '0'; oe <= '0'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '0'; force_we_reg_14 <= '1';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '0';
                data_a_sel <= data_a_arg_branch;
                data_b_sel <= data_b_reg0;
                data_c_sel <= data_c_aorb;
                regfile_c_we <= '0';

            when bzi_bnzi_set =>
                we <= '0'; oe <= '0'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '0'; force_we_reg_14 <= '1';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '0';
                data_a_sel <= data_a_regfile;
                data_b_sel <= data_b_reg0;
                data_c_sel <= data_c_aorb;
                regfile_c_we <= '0';

            when mvil =>
                we <= '0'; oe <= '0'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '0'; force_we_reg_14 <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '0';
                data_a_sel <= data_a_arg_mvi;
                data_b_sel <= data_b_regfile;
                data_c_sel <= data_c_mvil;
                regfile_c_we <= '1';

            when mvih =>
                we <= '0'; oe <= '0'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '0'; force_we_reg_14 <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '0';
                data_a_sel <= data_a_arg_mvi;
                data_b_sel <= data_b_regfile;
                data_c_sel <= data_c_mvih;
                regfile_c_we <= '0';

            when mvia =>
                we <= '0'; oe <= '0'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '0'; force_we_reg_14 <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '0';
                data_a_sel <= data_a_arg_mvia;
                data_b_sel <= data_b_reg0;
                data_c_sel <= data_c_aorb;
                regfile_c_we <= '1';

            when barrel =>
                we <= '0'; oe <= '0'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '0'; force_we_reg_14 <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '0';
                data_a_sel <= data_a_regfile;
                data_b_sel <= data_b_regfile;
                data_c_sel <= data_c_barrel;
                regfile_c_we <= '1';

            when alu =>
                we <= '0'; oe <= '0'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '0'; force_we_reg_14 <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '0';
                data_a_sel <= data_a_regfile;
                data_b_sel <= data_b_regfile;
                data_c_sel <= data_c_alu;
                regfile_c_we <= '1';

            when cmpi =>
                we <= '0'; oe <= '0'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '0'; force_we_reg_14 <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '0';
                data_a_sel <= data_a_regfile;
                data_b_sel <= data_b_regfile;
                data_c_sel <= data_c_cmp;
                regfile_c_we <= '1';

            when cmpf =>
                we <= '0'; oe <= '0'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '0'; force_we_reg_14 <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '0';
                data_a_sel <= data_a_regfile;
                data_b_sel <= data_b_regfile;
                data_c_sel <= data_c_cmp;
                regfile_c_we <= '0';

            when cmpf_2 =>
                we <= '0'; oe <= '0'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '0'; force_we_reg_14 <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '0';
                data_a_sel <= data_a_regfile;
                data_b_sel <= data_b_regfile;
                data_c_sel <= data_c_cmp;
                regfile_c_we <= '1';

            when div =>
                we <= '0'; oe <= '0'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '0'; force_we_reg_14 <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '0';
                data_a_sel <= data_a_regfile;
                data_b_sel <= data_b_regfile;
                data_c_sel <= data_c_alu;
                regfile_c_we <= '0';

            when div_w0 =>
                we <= '0'; oe <= '0'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '0'; force_we_reg_14 <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '0';
                data_a_sel <= data_a_regfile;
                data_b_sel <= data_b_regfile;
                data_c_sel <= data_c_alu;
                regfile_c_we <= '0';

            when div_w1 =>
                we <= '0'; oe <= '0'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '0'; force_we_reg_14 <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '0';
                data_a_sel <= data_a_regfile;
                data_b_sel <= data_b_regfile;
                data_c_sel <= data_c_alu;
                regfile_c_we <= '0';

            when div_w2 =>
                we <= '0'; oe <= '0'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '0'; force_we_reg_14 <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '0';
                data_a_sel <= data_a_regfile;
                data_b_sel <= data_b_regfile;
                data_c_sel <= data_c_alu;
                regfile_c_we <= '0';

            when div_w3 =>
                we <= '0'; oe <= '0'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '0'; force_we_reg_14 <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '0';
                data_a_sel <= data_a_regfile;
                data_b_sel <= data_b_regfile;
                data_c_sel <= data_c_alu;
                regfile_c_we <= '0';

            when div_w4 =>
                we <= '0'; oe <= '0'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '0'; force_we_reg_14 <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '0';
                data_a_sel <= data_a_regfile;
                data_b_sel <= data_b_regfile;
                data_c_sel <= data_c_alu;
                regfile_c_we <= '0';

            when div_w5 =>
                we <= '0'; oe <= '0'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '0'; force_we_reg_14 <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '0';
                data_a_sel <= data_a_regfile;
                data_b_sel <= data_b_regfile;
                data_c_sel <= data_c_alu;
                regfile_c_we <= '0';

            when div_w6 =>
                we <= '0'; oe <= '0'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '0'; force_we_reg_14 <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '0';
                data_a_sel <= data_a_regfile;
                data_b_sel <= data_b_regfile;
                data_c_sel <= data_c_alu;
                regfile_c_we <= '0';

            when div_w7 =>
                we <= '0'; oe <= '0'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '0'; force_we_reg_14 <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '0';
                data_a_sel <= data_a_regfile;
                data_b_sel <= data_b_regfile;
                data_c_sel <= data_c_alu;
                regfile_c_we <= '0';

            when div_w8 =>
                we <= '0'; oe <= '0'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '0'; force_we_reg_14 <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '0';
                data_a_sel <= data_a_regfile;
                data_b_sel <= data_b_regfile;
                data_c_sel <= data_c_alu;
                regfile_c_we <= '0';

            when div_w9 =>
                we <= '0'; oe <= '0'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '0'; force_we_reg_14 <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '0';
                data_a_sel <= data_a_regfile;
                data_b_sel <= data_b_regfile;
                data_c_sel <= data_c_alu;
                regfile_c_we <= '0';

            when div_w10 =>
                we <= '0'; oe <= '0'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '0'; force_we_reg_14 <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '0';
                data_a_sel <= data_a_regfile;
                data_b_sel <= data_b_regfile;
                data_c_sel <= data_c_alu;
                regfile_c_we <= '0';

            when div_w11 =>
                we <= '0'; oe <= '0'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '0'; force_we_reg_14 <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '0';
                data_a_sel <= data_a_regfile;
                data_b_sel <= data_b_regfile;
                data_c_sel <= data_c_alu;
                regfile_c_we <= '0';

            when div_w12 =>
                we <= '0'; oe <= '0'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '0'; force_we_reg_14 <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '0';
                data_a_sel <= data_a_regfile;
                data_b_sel <= data_b_regfile;
                data_c_sel <= data_c_alu;
                regfile_c_we <= '0';

            when div_w13 =>
                we <= '0'; oe <= '0'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '0'; force_we_reg_14 <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '0';
                data_a_sel <= data_a_regfile;
                data_b_sel <= data_b_regfile;
                data_c_sel <= data_c_alu;
                regfile_c_we <= '0';

            when div_w14 =>
                we <= '0'; oe <= '0'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '0'; force_we_reg_14 <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '0';
                data_a_sel <= data_a_regfile;
                data_b_sel <= data_b_regfile;
                data_c_sel <= data_c_alu;
                regfile_c_we <= '0';

            when div_done =>
                we <= '0'; oe <= '0'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '0'; force_we_reg_14 <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '0';
                data_a_sel <= data_a_regfile;
                data_b_sel <= data_b_regfile;
                data_c_sel <= data_c_alu;
                regfile_c_we <= '1';

            when faddsub =>
                we <= '0'; oe <= '0'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '0'; force_we_reg_14 <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '0';
                data_a_sel <= data_a_regfile;
                data_b_sel <= data_b_regfile;
                data_c_sel <= data_c_fpu;
                regfile_c_we <= '0';

            when faddsub_w0 =>
                we <= '0'; oe <= '0'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '0'; force_we_reg_14 <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '0';
                data_a_sel <= data_a_regfile;
                data_b_sel <= data_b_regfile;
                data_c_sel <= data_c_fpu;
                regfile_c_we <= '0';

            when faddsub_w1 =>
                we <= '0'; oe <= '0'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '0'; force_we_reg_14 <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '0';
                data_a_sel <= data_a_regfile;
                data_b_sel <= data_b_regfile;
                data_c_sel <= data_c_fpu;
                regfile_c_we <= '0';

            when faddsub_w2 =>
                we <= '0'; oe <= '0'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '0'; force_we_reg_14 <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '0';
                data_a_sel <= data_a_regfile;
                data_b_sel <= data_b_regfile;
                data_c_sel <= data_c_fpu;
                regfile_c_we <= '0';

            when faddsub_w3 =>
                we <= '0'; oe <= '0'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '0'; force_we_reg_14 <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '0';
                data_a_sel <= data_a_regfile;
                data_b_sel <= data_b_regfile;
                data_c_sel <= data_c_fpu;
                regfile_c_we <= '0';

            when faddsub_w4 =>
                we <= '0'; oe <= '0'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '0'; force_we_reg_14 <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '0';
                data_a_sel <= data_a_regfile;
                data_b_sel <= data_b_regfile;
                data_c_sel <= data_c_fpu;
                regfile_c_we <= '0';

            when faddsub_w5 =>
                we <= '0'; oe <= '0'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '0'; force_we_reg_14 <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '0';
                data_a_sel <= data_a_regfile;
                data_b_sel <= data_b_regfile;
                data_c_sel <= data_c_fpu;
                regfile_c_we <= '0';

            when faddsub_done =>
                we <= '0'; oe <= '0'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '0'; force_we_reg_14 <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '0';
                data_a_sel <= data_a_regfile;
                data_b_sel <= data_b_regfile;
                data_c_sel <= data_c_fpu;
                regfile_c_we <= '1';

            when fdiv =>
                we <= '0'; oe <= '0'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '0'; force_we_reg_14 <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '0';
                data_a_sel <= data_a_regfile;
                data_b_sel <= data_b_regfile;
                data_c_sel <= data_c_fpu;
                regfile_c_we <= '0';

            when fdiv_w0 =>
                we <= '0'; oe <= '0'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '0'; force_we_reg_14 <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '0';
                data_a_sel <= data_a_regfile;
                data_b_sel <= data_b_regfile;
                data_c_sel <= data_c_fpu;
                regfile_c_we <= '0';

            when fdiv_w1 =>
                we <= '0'; oe <= '0'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '0'; force_we_reg_14 <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '0';
                data_a_sel <= data_a_regfile;
                data_b_sel <= data_b_regfile;
                data_c_sel <= data_c_fpu;
                regfile_c_we <= '0';

            when fdiv_w2 =>
                we <= '0'; oe <= '0'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '0'; force_we_reg_14 <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '0';
                data_a_sel <= data_a_regfile;
                data_b_sel <= data_b_regfile;
                data_c_sel <= data_c_fpu;
                regfile_c_we <= '0';

            when fdiv_w3 =>
                we <= '0'; oe <= '0'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '0'; force_we_reg_14 <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '0';
                data_a_sel <= data_a_regfile;
                data_b_sel <= data_b_regfile;
                data_c_sel <= data_c_fpu;
                regfile_c_we <= '0';

            when fdiv_w4 =>
                we <= '0'; oe <= '0'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '0'; force_we_reg_14 <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '0';
                data_a_sel <= data_a_regfile;
                data_b_sel <= data_b_regfile;
                data_c_sel <= data_c_fpu;
                regfile_c_we <= '0';

            when fdiv_done =>
                we <= '0'; oe <= '0'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '0'; force_we_reg_14 <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '0';
                data_a_sel <= data_a_regfile;
                data_b_sel <= data_b_regfile;
                data_c_sel <= data_c_fpu;
                regfile_c_we <= '1';

            when fmul =>
                we <= '0'; oe <= '0'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '0'; force_we_reg_14 <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '0';
                data_a_sel <= data_a_regfile;
                data_b_sel <= data_b_regfile;
                data_c_sel <= data_c_fpu;
                regfile_c_we <= '0';

            when fmul_w0 =>
                we <= '0'; oe <= '0'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '0'; force_we_reg_14 <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '0';
                data_a_sel <= data_a_regfile;
                data_b_sel <= data_b_regfile;
                data_c_sel <= data_c_fpu;
                regfile_c_we <= '0';

            when fmul_w1 =>
                we <= '0'; oe <= '0'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '0'; force_we_reg_14 <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '0';
                data_a_sel <= data_a_regfile;
                data_b_sel <= data_b_regfile;
                data_c_sel <= data_c_fpu;
                regfile_c_we <= '0';

            when fmul_w2 =>
                we <= '0'; oe <= '0'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '0'; force_we_reg_14 <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '0';
                data_a_sel <= data_a_regfile;
                data_b_sel <= data_b_regfile;
                data_c_sel <= data_c_fpu;
                regfile_c_we <= '0';

            when fmul_w3 =>
                we <= '0'; oe <= '0'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '0'; force_we_reg_14 <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '0';
                data_a_sel <= data_a_regfile;
                data_b_sel <= data_b_regfile;
                data_c_sel <= data_c_fpu;
                regfile_c_we <= '0';

            when fmul_done =>
                we <= '0'; oe <= '0'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '0'; force_we_reg_14 <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '0';
                data_a_sel <= data_a_regfile;
                data_b_sel <= data_b_regfile;
                data_c_sel <= data_c_fpu;
                regfile_c_we <= '1';

            when intrq =>
                we <= '1'; oe <= '0'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '0'; force_we_reg_14 <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '0';
                data_a_sel <= data_a_sp;
                data_b_sel <= data_b_pc;
                data_c_sel <= data_c_dontcare;
                regfile_c_we <= '0';

            when intrq_set =>
                we <= '0'; oe <= '0'; int_accept <= '1'; int_completed <= '0';
                instruction_we <= '0'; force_we_reg_14 <= '1';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '1';
                data_a_sel <= data_a_int_addr;
                data_b_sel <= data_b_reg0;
                data_c_sel <= data_c_aorb;
                regfile_c_we <= '0';

            when intrq_inc =>
                we <= '1'; oe <= '0'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '0'; force_we_reg_14 <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '0';
                data_a_sel <= data_a_sp_plus;
                data_b_sel <= data_b_pc;
                data_c_sel <= data_c_dontcare;
                regfile_c_we <= '0';

            when intrq_inc_set =>
                we <= '0'; oe <= '0'; int_accept <= '1'; int_completed <= '0';
                instruction_we <= '0'; force_we_reg_14 <= '1';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '0';
                data_a_sel <= data_a_int_addr;
                data_b_sel <= data_b_reg0;
                data_c_sel <= data_c_aorb;
                regfile_c_we <= '0';

            when intrq_dec =>
                we <= '1'; oe <= '0'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '0'; force_we_reg_14 <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '0';
                data_a_sel <= data_a_sp_minus;
                data_b_sel <= data_b_pc;
                data_c_sel <= data_c_dontcare;
                regfile_c_we <= '0';

            when intrq_dec_set =>
                we <= '0'; oe <= '0'; int_accept <= '1'; int_completed <= '0';
                instruction_we <= '0'; force_we_reg_14 <= '1';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '1';
                data_a_sel <= data_a_int_addr;
                data_b_sel <= data_b_reg0;
                data_c_sel <= data_c_aorb;
                regfile_c_we <= '0';

            when intrq_call =>
                we <= '1'; oe <= '0'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '0'; force_we_reg_14 <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '0';
                data_a_sel <= data_a_sp;
                data_b_sel <= data_b_arg_call;
                data_c_sel <= data_c_dontcare;
                regfile_c_we <= '0';

            when intrq_calli =>
                we <= '1'; oe <= '0'; int_accept <= '0'; int_completed <= '0';
                instruction_we <= '0'; force_we_reg_14 <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r15 <= '0';
                data_a_sel <= data_a_sp;
                data_b_sel <= data_b_regfile_a;
                data_c_sel <= data_c_dontcare;
                regfile_c_we <= '0';

        end case;
    end process;

end architecture id_arch;
