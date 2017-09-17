library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity id is
    port(
        clk: in std_logic;
        res: in std_logic;
        instruction_word: in std_logic_vector(31 downto 0);
        instruction_we: out std_logic;
        --regfile
        regfile0_data_a_regsel: out std_logic_vector(3 downto 0);
        regfile0_data_b_regsel: out std_logic_vector(3 downto 0);
        regfile0_data_c_regsel: out std_logic_vector(3 downto 0);
        regfile0_we: out std_logic;
        regfile0_data_a_oe: out std_logic;
        regfile0_data_b_oe: out std_logic;
        zero_flags: in std_logic_vector(15 downto 0);
        --fpu
        fpu0_en: out std_logic;
        fpu0_opcode: out std_logic_vector(1 downto 0);
        --cmp
        cmp0_en: out std_logic;
        cmp0_opcode: out std_logic_vector(3 downto 0);
        --barrel
        barrel0_en: out std_logic;
        barrel0_dir: out std_logic;
        barrel0_mode: out std_logic_vector(1 downto 0);
        --alu
        alu0_en: out std_logic;
        alu0_opcode: out std_logic_vector(3 downto 0);
        --bus
        miso_oe:  out std_logic;
        --argument
        arg_oe: out std_logic;
        argument: out unsigned(31 downto 0);
        --cpu
        we: out std_logic;
        oe: out std_logic;
        ack: in std_logic;
        int: in std_logic;
        int_address: in unsigned(23 downto 0);
        int_accept: out std_logic;
        int_completed: out std_logic;
        inc_r14: out std_logic;
        inc_r15: out std_logic;
        dec_r14: out std_logic;
        dec_r15: out std_logic;
        address_alu_oe: out std_logic;
        address_alu_opcode: out std_logic
    );
end entity id;

architecture id_arch of id is

    signal flag: std_logic;
    signal flag_sel: std_logic_vector(3 downto 0);

    type id_state_type is (
        start, start_inc, start_dec, start_wait, start_decode,
        intrq, intrq_set, intrq_inc, intrq_inc_set, intrq_dec, intrq_dec_set,
        ret, reti, reti_wait,
        call, call_set, calli, calli_set,
        pop, push,
        ld, ldi, st, sti,
        bz, bnz, bz_bnz_set, bzi, bnzi, bzi_bnzi_set,
        mvi, mvia, barrel, alu,
        cmpi, cmpf, cmpf_2,
        div, div_w0, div_w1, div_w2, div_w3, div_w4, div_w5, div_w6, div_w7,
        div_w8, div_w9, div_w10, div_w11, div_w12, div_w13, div_w14, div_w15,
        div_w16, div_w17, div_w18, div_w19, div_w20, div_w21, div_w22, div_w23,
        div_w24, div_w25, div_w26, div_w27, div_w28, div_w29, div_w30, div_done,
        faddsub, faddsub_w0, faddsub_w1, faddsub_w2, faddsub_w3, faddsub_w4,
        faddsub_w5, faddsub_done,
        fdiv, fdiv_w0, fdiv_w1, fdiv_w2, fdiv_w3, fdiv_w4, fdiv_done,
        fmul, fmul_w0, fmul_w1, fmul_w2, fmul_w3, fmul_done
    );

    signal id_state: id_state_type;
    signal arg_sel: std_logic;
    signal alu_ins: std_logic;

begin

    argument <= (x"00" & unsigned(instruction_word(23 downto 0))) when (arg_sel = '1') else (x"00" & int_address);
    cmp0_opcode  <= instruction_word(23 downto 20);
    alu0_opcode <= instruction_word(23 downto 20) when (alu_ins = '1') else x"b";
    fpu0_opcode <= instruction_word(21 downto 20);
    barrel0_dir <= instruction_word(20);
    barrel0_mode <= instruction_word(22 downto 21);

    flag <=
        zero_flags(0) when flag_sel = x"0" else
        zero_flags(1) when flag_sel = x"1" else
        zero_flags(2) when flag_sel = x"2" else
        zero_flags(3) when flag_sel = x"3" else
        zero_flags(4) when flag_sel = x"4" else
        zero_flags(5) when flag_sel = x"5" else
        zero_flags(6) when flag_sel = x"6" else
        zero_flags(7) when flag_sel = x"7" else
        zero_flags(8) when flag_sel = x"8" else
        zero_flags(9) when flag_sel = x"9" else
        zero_flags(10) when flag_sel = x"a" else
        zero_flags(11) when flag_sel = x"b" else
        zero_flags(12) when flag_sel = x"c" else
        zero_flags(13) when flag_sel = x"d" else
        zero_flags(14) when flag_sel = x"e" else
        zero_flags(15);

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
                        case instruction_word(31) is
                            when '1' =>
                                case instruction_word(30 downto 28) is
                                    when "000" => id_state <= call;
                                    when "001" => id_state <= ld;
                                    when "010" => id_state <= st;
                                    when "011" => id_state <= bz;
                                    when "100" => id_state <= bnz;
                                    when "101" => id_state <= mvia;
                                    when others => id_state <= start;
                                end case;
                            when others =>
                                case instruction_word(28 downto 24) is
                                    when "00000" => id_state <= start;
                                    when "00001" => id_state <= ret;
                                    when "00010" => id_state <= reti;
                                    when "00011" => id_state <= calli;
                                    when "00100" => id_state <= push;
                                    when "00101" => id_state <= pop;
                                    when "00110" => id_state <= ldi;
                                    when "00111" => id_state <= sti;
                                    when "01000" => id_state <= bnzi;
                                    when "01001" => id_state <= bzi;
                                    when "01010" => id_state <= cmpi;
                                    when "01011" => id_state <= cmpf;
                                    when "01100" => id_state <= alu;
                                    when "01101" => id_state <= div;
                                    when "01110" => id_state <= barrel;
                                    when "01111" => id_state <= faddsub;
                                    when "10000" => id_state <= fmul;
                                    when "10001" => id_state <= fdiv;
                                    when "10010" => id_state <= mvi;
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
                            when '1' =>
                                case int is
                                    when '1' => id_state <= intrq_inc;
                                    when others => id_state <= start_inc;
                                end case;
                            when others => id_state <= reti_wait;
                        end case;
                    when reti_wait =>
                        case ack is
                            when '1' =>
                                case int is
                                    when '1' => id_state <= intrq_inc;
                                    when others => id_state <= start_inc;
                                end case;
                            when others => id_state <= reti_wait;
                        end case;

                    when call =>
                        case ack is
                            when '1' => id_state <= call_set;
                            when others => id_state <= call;
                        end case;
                    when call_set =>
                        case int is
                            when '1' => id_state <= intrq;
                            when others => id_state <= start;
                        end case;
                    when calli =>
                        case ack is
                            when '1' => id_state <= calli_set;
                            when others => id_state <= calli;
                        end case;
                    when calli_set =>
                        case int is
                            when '1' => id_state <= intrq;
                            when others => id_state <= start;
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

                    when bz =>
                        case flag is
                            when '1' => id_state <= bz_bnz_set;
                            when others =>
                                case int is
                                    when '1' => id_state <= intrq;
                                    when others => id_state <= start;
                                end case;
                        end case;
                    when bnz =>
                        case flag is
                            when '0' => id_state <= bz_bnz_set;
                            when others =>
                                case int is
                                    when '1' => id_state <= intrq;
                                    when others => id_state <= start;
                                end case;
                        end case;
                    when bz_bnz_set =>
                        case int is
                            when '1' => id_state <= intrq;
                            when others => id_state <= start;
                        end case;

                    when bzi =>
                        case flag is
                            when '1' => id_state <= bzi_bnzi_set;
                            when others =>
                                case int is
                                    when '1' => id_state <= intrq;
                                    when others => id_state <= start;
                                end case;
                        end case;
                    when bnzi =>
                        case flag is
                            when '0' => id_state <= bzi_bnzi_set;
                            when others =>
                                case int is
                                    when '1' => id_state <= intrq;
                                    when others => id_state <= start;
                                end case;
                        end case;
                    when bzi_bnzi_set =>
                        case int is
                            when '1' => id_state <= intrq;
                            when others => id_state <= start;
                        end case;

                    when mvi =>
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
                    when div_w14 => id_state <= div_w15;
                    when div_w15 => id_state <= div_w16;
                    when div_w16 => id_state <= div_w17;
                    when div_w17 => id_state <= div_w18;
                    when div_w18 => id_state <= div_w19;
                    when div_w19 => id_state <= div_w20;
                    when div_w20 => id_state <= div_w21;
                    when div_w21 => id_state <= div_w22;
                    when div_w22 => id_state <= div_w23;
                    when div_w23 => id_state <= div_w24;
                    when div_w24 => id_state <= div_w25;
                    when div_w25 => id_state <= div_w26;
                    when div_w26 => id_state <= div_w27;
                    when div_w27 => id_state <= div_w28;
                    when div_w28 => id_state <= div_w29;
                    when div_w29 => id_state <= div_w30;
                    when div_w30 => id_state <= div_done;

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

    process(id_state, instruction_word, int_address) is
    begin
        case id_state is


            when start=>
                instruction_we <= '1';
                regfile0_data_a_regsel <= x"E"; regfile0_data_b_regsel <= "----"; regfile0_data_c_regsel <= "----";
                regfile0_we <= '0'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '0';
                fpu0_en <= '0'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '0'; alu_ins <= '0';
                miso_oe <= '1'; we <= '0'; oe <= '1'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when start_inc=>
                instruction_we <= '1';
                regfile0_data_a_regsel <= x"E"; regfile0_data_b_regsel <= "----"; regfile0_data_c_regsel <= "----";
                regfile0_we <= '0'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '0';
                fpu0_en <= '0'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '0'; alu_ins <= '0';
                miso_oe <= '1'; we <= '0'; oe <= '1'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '1'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when start_dec=>
                instruction_we <= '1';
                regfile0_data_a_regsel <= x"E"; regfile0_data_b_regsel <= "----"; regfile0_data_c_regsel <= "----";
                regfile0_we <= '0'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '0';
                fpu0_en <= '0'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '0'; alu_ins <= '0';
                miso_oe <= '1'; we <= '0'; oe <= '1'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '1';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when start_wait=>
                instruction_we <= '1';
                regfile0_data_a_regsel <= x"E"; regfile0_data_b_regsel <= "----"; regfile0_data_c_regsel <= "----";
                regfile0_we <= '0'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '0';
                fpu0_en <= '0'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '0'; alu_ins <= '0';
                miso_oe <= '1'; we <= '0'; oe <= '1'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when start_decode=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= "----"; regfile0_data_b_regsel <= "----"; regfile0_data_c_regsel <= "----";
                regfile0_we <= '0'; regfile0_data_a_oe <= '0'; regfile0_data_b_oe <= '0';
                fpu0_en <= '0'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '0'; alu_ins <= '0';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '1'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when intrq=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= x"F"; regfile0_data_b_regsel <= x"E"; regfile0_data_c_regsel <= "----";
                regfile0_we <= '0'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '1';
                fpu0_en <= '0'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '0'; alu_ins <= '0';
                miso_oe <= '0'; we <= '1'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when intrq_set=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= "----"; regfile0_data_b_regsel <= "----"; regfile0_data_c_regsel <= x"E";
                regfile0_we <= '1'; regfile0_data_a_oe <= '0'; regfile0_data_b_oe <= '1';
                fpu0_en <= '0'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '1'; alu_ins <= '0';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '1'; arg_sel <= '0';
                int_accept <= '1'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '1'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when intrq_inc=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= "----"; regfile0_data_b_regsel <= x"E"; regfile0_data_c_regsel <= "----";
                regfile0_we <= '0'; regfile0_data_a_oe <= '0'; regfile0_data_b_oe <= '1';
                fpu0_en <= '0'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '0'; alu_ins <= '0';
                miso_oe <= '0'; we <= '1'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '1'; address_alu_opcode <= '1'; flag_sel <= "----";

            when intrq_inc_set=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= "----"; regfile0_data_b_regsel <= "----"; regfile0_data_c_regsel <= x"E";
                regfile0_we <= '1'; regfile0_data_a_oe <= '0'; regfile0_data_b_oe <= '1';
                fpu0_en <= '0'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '1'; alu_ins <= '0';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '1'; arg_sel <= '0';
                int_accept <= '1'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '1'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when intrq_dec=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= "----"; regfile0_data_b_regsel <= x"E"; regfile0_data_c_regsel <= "----";
                regfile0_we <= '0'; regfile0_data_a_oe <= '0'; regfile0_data_b_oe <= '1';
                fpu0_en <= '0'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '0'; alu_ins <= '0';
                miso_oe <= '0'; we <= '1'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '1'; address_alu_opcode <= '0'; flag_sel <= "----";

            when intrq_dec_set=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= "----"; regfile0_data_b_regsel <= "----"; regfile0_data_c_regsel <= x"E";
                regfile0_we <= '1'; regfile0_data_a_oe <= '0'; regfile0_data_b_oe <= '1';
                fpu0_en <= '0'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '1'; alu_ins <= '0';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '1'; arg_sel <= '0';
                int_accept <= '1'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when ret=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= "----"; regfile0_data_b_regsel <= "----"; regfile0_data_c_regsel <= x"E";
                regfile0_we <= '1'; regfile0_data_a_oe <= '0'; regfile0_data_b_oe <= '0';
                fpu0_en <= '0'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '0'; alu_ins <= '0';
                miso_oe <= '1'; we <= '0'; oe <= '1'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '1'; address_alu_opcode <= '1'; flag_sel <= "----";

            when reti=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= "----"; regfile0_data_b_regsel <= "----"; regfile0_data_c_regsel <= x"E";
                regfile0_we <= '1'; regfile0_data_a_oe <= '0'; regfile0_data_b_oe <= '0';
                fpu0_en <= '0'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '0'; alu_ins <= '0';
                miso_oe <= '1'; we <= '0'; oe <= '1'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '1';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '1'; address_alu_opcode <= '1'; flag_sel <= "----";

            when reti_wait=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= "----"; regfile0_data_b_regsel <= "----"; regfile0_data_c_regsel <= x"E";
                regfile0_we <= '1'; regfile0_data_a_oe <= '0'; regfile0_data_b_oe <= '0';
                fpu0_en <= '0'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '0'; alu_ins <= '0';
                miso_oe <= '1'; we <= '0'; oe <= '1'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '1'; address_alu_opcode <= '1'; flag_sel <= "----";

            when call=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= x"F"; regfile0_data_b_regsel <= x"E"; regfile0_data_c_regsel <= "----";
                regfile0_we <= '0'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '1';
                fpu0_en <= '0'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '0'; alu_ins <= '0';
                miso_oe <= '0'; we <= '1'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when call_set=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= "----"; regfile0_data_b_regsel <= "----"; regfile0_data_c_regsel <= x"F";
                regfile0_we <= '1'; regfile0_data_a_oe <= '0'; regfile0_data_b_oe <= '1';
                fpu0_en <= '0'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '1'; alu_ins <= '0';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '1'; arg_sel <= '1';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '1';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when calli=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= x"F"; regfile0_data_b_regsel <= x"E"; regfile0_data_c_regsel <= "----";
                regfile0_we <= '0'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '1';
                fpu0_en <= '0'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '0'; alu_ins <= '0';
                miso_oe <= '0'; we <= '1'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when calli_set=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= instruction_word(3 downto 0); regfile0_data_b_regsel <= "----"; regfile0_data_c_regsel <= x"F";
                regfile0_we <= '1'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '1';
                fpu0_en <= '0'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '1'; alu_ins <= '0';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '1';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when push=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= x"f"; regfile0_data_b_regsel <= instruction_word(3 downto 0); regfile0_data_c_regsel <= "----";
                regfile0_we <= '0'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '1';
                fpu0_en <= '0'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '0'; alu_ins <= '0';
                miso_oe <= '0'; we <= '1'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when pop=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= "----"; regfile0_data_b_regsel <= "----"; regfile0_data_c_regsel <= instruction_word(3 downto 0);
                regfile0_we <= '1'; regfile0_data_a_oe <= '0'; regfile0_data_b_oe <= '0';
                fpu0_en <= '0'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '0'; alu_ins <= '0';
                miso_oe <= '1'; we <= '0'; oe <= '1'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '1'; address_alu_opcode <= '1'; flag_sel <= "----";

            when ld=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= "----"; regfile0_data_b_regsel <= "----"; regfile0_data_c_regsel <= instruction_word(27 downto 24);
                regfile0_we <= '1'; regfile0_data_a_oe <= '0'; regfile0_data_b_oe <= '0';
                fpu0_en <= '0'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '0'; alu_ins <= '0';
                miso_oe <= '1'; we <= '0'; oe <= '1'; arg_oe <= '1'; arg_sel <= '1';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when ldi=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= instruction_word(11 downto 8); regfile0_data_b_regsel <= "----"; regfile0_data_c_regsel <= instruction_word(3 downto 0);
                regfile0_we <= '1'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '0';
                fpu0_en <= '0'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '0'; alu_ins <= '0';
                miso_oe <= '1'; we <= '0'; oe <= '1'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when st=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= "----"; regfile0_data_b_regsel <= instruction_word(27 downto 24); regfile0_data_c_regsel <= "----";
                regfile0_we <= '0'; regfile0_data_a_oe <= '0'; regfile0_data_b_oe <= '1';
                fpu0_en <= '0'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '0'; alu_ins <= '0';
                miso_oe <= '0'; we <= '1'; oe <= '0'; arg_oe <= '1'; arg_sel <= '1';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when sti=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= instruction_word(11 downto 8); regfile0_data_b_regsel <= instruction_word(7 downto 4); regfile0_data_c_regsel <= "----";
                regfile0_we <= '0'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '1';
                fpu0_en <= '0'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '0'; alu_ins <= '0';
                miso_oe <= '0'; we <= '1'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when bz=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= "----"; regfile0_data_b_regsel <= "----"; regfile0_data_c_regsel <= "----";
                regfile0_we <= '0'; regfile0_data_a_oe <= '0'; regfile0_data_b_oe <= '0';
                fpu0_en <= '0'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '0'; alu_ins <= '0';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= instruction_word(27 downto 24);

            when bz_bnz_set=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= "----"; regfile0_data_b_regsel <= "----"; regfile0_data_c_regsel <= x"E";
                regfile0_we <= '1'; regfile0_data_a_oe <= '0'; regfile0_data_b_oe <= '1';
                fpu0_en <= '0'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '1'; alu_ins <= '0';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '1'; arg_sel <= '1';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when bnz=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= "----"; regfile0_data_b_regsel <= "----"; regfile0_data_c_regsel <= "----";
                regfile0_we <= '0'; regfile0_data_a_oe <= '0'; regfile0_data_b_oe <= '0';
                fpu0_en <= '0'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '0'; alu_ins <= '0';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= instruction_word(27 downto 24);

            when bzi=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= "----"; regfile0_data_b_regsel <= "----"; regfile0_data_c_regsel <= "----";
                regfile0_we <= '0'; regfile0_data_a_oe <= '0'; regfile0_data_b_oe <= '0';
                fpu0_en <= '0'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '0'; alu_ins <= '0';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= instruction_word(3 downto 0);

            when bnzi=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= "----"; regfile0_data_b_regsel <= "----"; regfile0_data_c_regsel <= "----";
                regfile0_we <= '0'; regfile0_data_a_oe <= '0'; regfile0_data_b_oe <= '0';
                fpu0_en <= '0'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '0'; alu_ins <= '0';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= instruction_word(3 downto 0);

            when bzi_bnzi_set=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= instruction_word(7 downto 4); regfile0_data_b_regsel <= "----"; regfile0_data_c_regsel <= x"E";
                regfile0_we <= '1'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '1';
                fpu0_en <= '0'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '1'; alu_ins <= '0';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when mvi=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= "----"; regfile0_data_b_regsel <= instruction_word(19 downto 16); regfile0_data_c_regsel <= instruction_word(19 downto 16);
                regfile0_we <= '1'; regfile0_data_a_oe <= '0'; regfile0_data_b_oe <= '1';
                fpu0_en <= '0'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '1'; alu_ins <= '1';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '1'; arg_sel <= '1';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when mvia=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= "----"; regfile0_data_b_regsel <= "----"; regfile0_data_c_regsel <= instruction_word(27 downto 24);
                regfile0_we <= '1'; regfile0_data_a_oe <= '0'; regfile0_data_b_oe <= '1';
                fpu0_en <= '0'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '1'; alu_ins <= '0';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '1'; arg_sel <= '1';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when barrel=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= instruction_word(11 downto 8); regfile0_data_b_regsel <= instruction_word(7 downto 4); regfile0_data_c_regsel <= instruction_word(3 downto 0);
                regfile0_we <= '1'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '1';
                fpu0_en <= '0'; cmp0_en <= '0'; barrel0_en <= '1'; alu0_en <= '0'; alu_ins <= '0';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when alu=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= instruction_word(11 downto 8); regfile0_data_b_regsel <= instruction_word(7 downto 4); regfile0_data_c_regsel <= instruction_word(3 downto 0);
                regfile0_we <= '1'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '1';
                fpu0_en <= '0'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '1'; alu_ins <= '1';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when cmpi=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= instruction_word(11 downto 8); regfile0_data_b_regsel <= instruction_word(7 downto 4); regfile0_data_c_regsel <= instruction_word(3 downto 0);
                regfile0_we <= '1'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '1';
                fpu0_en <= '0'; cmp0_en <= '1'; barrel0_en <= '0'; alu0_en <= '0'; alu_ins <= '0';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when cmpf=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= instruction_word(11 downto 8); regfile0_data_b_regsel <= instruction_word(7 downto 4); regfile0_data_c_regsel <= instruction_word(3 downto 0);
                regfile0_we <= '0'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '1';
                fpu0_en <= '0'; cmp0_en <= '1'; barrel0_en <= '0'; alu0_en <= '0'; alu_ins <= '0';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when cmpf_2=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= instruction_word(11 downto 8); regfile0_data_b_regsel <= instruction_word(7 downto 4); regfile0_data_c_regsel <= instruction_word(3 downto 0);
                regfile0_we <= '1'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '1';
                fpu0_en <= '0'; cmp0_en <= '1'; barrel0_en <= '0'; alu0_en <= '0'; alu_ins <= '0';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when div=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= instruction_word(11 downto 8); regfile0_data_b_regsel <= instruction_word(7 downto 4); regfile0_data_c_regsel <= instruction_word(3 downto 0);
                regfile0_we <= '0'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '1';
                fpu0_en <= '0'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '1'; alu_ins <= '1';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when div_w0=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= instruction_word(11 downto 8); regfile0_data_b_regsel <= instruction_word(7 downto 4); regfile0_data_c_regsel <= instruction_word(3 downto 0);
                regfile0_we <= '0'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '1';
                fpu0_en <= '0'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '1'; alu_ins <= '1';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when div_w1=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= instruction_word(11 downto 8); regfile0_data_b_regsel <= instruction_word(7 downto 4); regfile0_data_c_regsel <= instruction_word(3 downto 0);
                regfile0_we <= '0'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '1';
                fpu0_en <= '0'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '1'; alu_ins <= '1';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when div_w2=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= instruction_word(11 downto 8); regfile0_data_b_regsel <= instruction_word(7 downto 4); regfile0_data_c_regsel <= instruction_word(3 downto 0);
                regfile0_we <= '0'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '1';
                fpu0_en <= '0'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '1'; alu_ins <= '1';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when div_w3=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= instruction_word(11 downto 8); regfile0_data_b_regsel <= instruction_word(7 downto 4); regfile0_data_c_regsel <= instruction_word(3 downto 0);
                regfile0_we <= '0'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '1';
                fpu0_en <= '0'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '1'; alu_ins <= '1';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when div_w4=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= instruction_word(11 downto 8); regfile0_data_b_regsel <= instruction_word(7 downto 4); regfile0_data_c_regsel <= instruction_word(3 downto 0);
                regfile0_we <= '0'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '1';
                fpu0_en <= '0'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '1'; alu_ins <= '1';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when div_w5=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= instruction_word(11 downto 8); regfile0_data_b_regsel <= instruction_word(7 downto 4); regfile0_data_c_regsel <= instruction_word(3 downto 0);
                regfile0_we <= '0'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '1';
                fpu0_en <= '0'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '1'; alu_ins <= '1';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when div_w6=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= instruction_word(11 downto 8); regfile0_data_b_regsel <= instruction_word(7 downto 4); regfile0_data_c_regsel <= instruction_word(3 downto 0);
                regfile0_we <= '0'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '1';
                fpu0_en <= '0'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '1'; alu_ins <= '1';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when div_w7=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= instruction_word(11 downto 8); regfile0_data_b_regsel <= instruction_word(7 downto 4); regfile0_data_c_regsel <= instruction_word(3 downto 0);
                regfile0_we <= '0'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '1';
                fpu0_en <= '0'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '1'; alu_ins <= '1';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when div_w8=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= instruction_word(11 downto 8); regfile0_data_b_regsel <= instruction_word(7 downto 4); regfile0_data_c_regsel <= instruction_word(3 downto 0);
                regfile0_we <= '0'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '1';
                fpu0_en <= '0'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '1'; alu_ins <= '1';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when div_w9=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= instruction_word(11 downto 8); regfile0_data_b_regsel <= instruction_word(7 downto 4); regfile0_data_c_regsel <= instruction_word(3 downto 0);
                regfile0_we <= '0'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '1';
                fpu0_en <= '0'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '1'; alu_ins <= '1';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when div_w10=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= instruction_word(11 downto 8); regfile0_data_b_regsel <= instruction_word(7 downto 4); regfile0_data_c_regsel <= instruction_word(3 downto 0);
                regfile0_we <= '0'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '1';
                fpu0_en <= '0'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '1'; alu_ins <= '1';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when div_w11=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= instruction_word(11 downto 8); regfile0_data_b_regsel <= instruction_word(7 downto 4); regfile0_data_c_regsel <= instruction_word(3 downto 0);
                regfile0_we <= '0'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '1';
                fpu0_en <= '0'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '1'; alu_ins <= '1';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when div_w12=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= instruction_word(11 downto 8); regfile0_data_b_regsel <= instruction_word(7 downto 4); regfile0_data_c_regsel <= instruction_word(3 downto 0);
                regfile0_we <= '0'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '1';
                fpu0_en <= '0'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '1'; alu_ins <= '1';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when div_w13=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= instruction_word(11 downto 8); regfile0_data_b_regsel <= instruction_word(7 downto 4); regfile0_data_c_regsel <= instruction_word(3 downto 0);
                regfile0_we <= '0'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '1';
                fpu0_en <= '0'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '1'; alu_ins <= '1';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when div_w14=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= instruction_word(11 downto 8); regfile0_data_b_regsel <= instruction_word(7 downto 4); regfile0_data_c_regsel <= instruction_word(3 downto 0);
                regfile0_we <= '0'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '1';
                fpu0_en <= '0'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '1'; alu_ins <= '1';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when div_w15=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= instruction_word(11 downto 8); regfile0_data_b_regsel <= instruction_word(7 downto 4); regfile0_data_c_regsel <= instruction_word(3 downto 0);
                regfile0_we <= '0'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '1';
                fpu0_en <= '0'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '1'; alu_ins <= '1';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when div_w16=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= instruction_word(11 downto 8); regfile0_data_b_regsel <= instruction_word(7 downto 4); regfile0_data_c_regsel <= instruction_word(3 downto 0);
                regfile0_we <= '0'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '1';
                fpu0_en <= '0'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '1'; alu_ins <= '1';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when div_w17=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= instruction_word(11 downto 8); regfile0_data_b_regsel <= instruction_word(7 downto 4); regfile0_data_c_regsel <= instruction_word(3 downto 0);
                regfile0_we <= '0'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '1';
                fpu0_en <= '0'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '1'; alu_ins <= '1';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when div_w18=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= instruction_word(11 downto 8); regfile0_data_b_regsel <= instruction_word(7 downto 4); regfile0_data_c_regsel <= instruction_word(3 downto 0);
                regfile0_we <= '0'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '1';
                fpu0_en <= '0'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '1'; alu_ins <= '1';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when div_w19=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= instruction_word(11 downto 8); regfile0_data_b_regsel <= instruction_word(7 downto 4); regfile0_data_c_regsel <= instruction_word(3 downto 0);
                regfile0_we <= '0'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '1';
                fpu0_en <= '0'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '1'; alu_ins <= '1';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when div_w20=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= instruction_word(11 downto 8); regfile0_data_b_regsel <= instruction_word(7 downto 4); regfile0_data_c_regsel <= instruction_word(3 downto 0);
                regfile0_we <= '0'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '1';
                fpu0_en <= '0'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '1'; alu_ins <= '1';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when div_w21=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= instruction_word(11 downto 8); regfile0_data_b_regsel <= instruction_word(7 downto 4); regfile0_data_c_regsel <= instruction_word(3 downto 0);
                regfile0_we <= '0'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '1';
                fpu0_en <= '0'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '1'; alu_ins <= '1';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when div_w22=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= instruction_word(11 downto 8); regfile0_data_b_regsel <= instruction_word(7 downto 4); regfile0_data_c_regsel <= instruction_word(3 downto 0);
                regfile0_we <= '0'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '1';
                fpu0_en <= '0'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '1'; alu_ins <= '1';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when div_w23=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= instruction_word(11 downto 8); regfile0_data_b_regsel <= instruction_word(7 downto 4); regfile0_data_c_regsel <= instruction_word(3 downto 0);
                regfile0_we <= '0'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '1';
                fpu0_en <= '0'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '1'; alu_ins <= '1';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when div_w24=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= instruction_word(11 downto 8); regfile0_data_b_regsel <= instruction_word(7 downto 4); regfile0_data_c_regsel <= instruction_word(3 downto 0);
                regfile0_we <= '0'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '1';
                fpu0_en <= '0'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '1'; alu_ins <= '1';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when div_w25=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= instruction_word(11 downto 8); regfile0_data_b_regsel <= instruction_word(7 downto 4); regfile0_data_c_regsel <= instruction_word(3 downto 0);
                regfile0_we <= '0'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '1';
                fpu0_en <= '0'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '1'; alu_ins <= '1';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when div_w26=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= instruction_word(11 downto 8); regfile0_data_b_regsel <= instruction_word(7 downto 4); regfile0_data_c_regsel <= instruction_word(3 downto 0);
                regfile0_we <= '0'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '1';
                fpu0_en <= '0'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '1'; alu_ins <= '1';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when div_w27=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= instruction_word(11 downto 8); regfile0_data_b_regsel <= instruction_word(7 downto 4); regfile0_data_c_regsel <= instruction_word(3 downto 0);
                regfile0_we <= '0'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '1';
                fpu0_en <= '0'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '1'; alu_ins <= '1';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when div_w28=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= instruction_word(11 downto 8); regfile0_data_b_regsel <= instruction_word(7 downto 4); regfile0_data_c_regsel <= instruction_word(3 downto 0);
                regfile0_we <= '0'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '1';
                fpu0_en <= '0'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '1'; alu_ins <= '1';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when div_w29=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= instruction_word(11 downto 8); regfile0_data_b_regsel <= instruction_word(7 downto 4); regfile0_data_c_regsel <= instruction_word(3 downto 0);
                regfile0_we <= '0'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '1';
                fpu0_en <= '0'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '1'; alu_ins <= '1';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when div_w30=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= instruction_word(11 downto 8); regfile0_data_b_regsel <= instruction_word(7 downto 4); regfile0_data_c_regsel <= instruction_word(3 downto 0);
                regfile0_we <= '0'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '1';
                fpu0_en <= '0'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '1'; alu_ins <= '1';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when div_done=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= instruction_word(11 downto 8); regfile0_data_b_regsel <= instruction_word(7 downto 4); regfile0_data_c_regsel <= instruction_word(3 downto 0);
                regfile0_we <= '1'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '1';
                fpu0_en <= '0'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '1'; alu_ins <= '1';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when faddsub=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= instruction_word(11 downto 8); regfile0_data_b_regsel <= instruction_word(7 downto 4); regfile0_data_c_regsel <= instruction_word(3 downto 0);
                regfile0_we <= '0'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '1';
                fpu0_en <= '1'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '0'; alu_ins <= '0';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when faddsub_w0=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= instruction_word(11 downto 8); regfile0_data_b_regsel <= instruction_word(7 downto 4); regfile0_data_c_regsel <= instruction_word(3 downto 0);
                regfile0_we <= '0'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '1';
                fpu0_en <= '1'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '0'; alu_ins <= '0';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when faddsub_w1=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= instruction_word(11 downto 8); regfile0_data_b_regsel <= instruction_word(7 downto 4); regfile0_data_c_regsel <= instruction_word(3 downto 0);
                regfile0_we <= '0'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '1';
                fpu0_en <= '1'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '0'; alu_ins <= '0';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when faddsub_w2=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= instruction_word(11 downto 8); regfile0_data_b_regsel <= instruction_word(7 downto 4); regfile0_data_c_regsel <= instruction_word(3 downto 0);
                regfile0_we <= '0'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '1';
                fpu0_en <= '1'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '0'; alu_ins <= '0';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when faddsub_w3=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= instruction_word(11 downto 8); regfile0_data_b_regsel <= instruction_word(7 downto 4); regfile0_data_c_regsel <= instruction_word(3 downto 0);
                regfile0_we <= '0'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '1';
                fpu0_en <= '1'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '0'; alu_ins <= '0';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when faddsub_w4=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= instruction_word(11 downto 8); regfile0_data_b_regsel <= instruction_word(7 downto 4); regfile0_data_c_regsel <= instruction_word(3 downto 0);
                regfile0_we <= '0'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '1';
                fpu0_en <= '1'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '0'; alu_ins <= '0';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when faddsub_w5=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= instruction_word(11 downto 8); regfile0_data_b_regsel <= instruction_word(7 downto 4); regfile0_data_c_regsel <= instruction_word(3 downto 0);
                regfile0_we <= '0'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '1';
                fpu0_en <= '1'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '0'; alu_ins <= '0';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when faddsub_done=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= instruction_word(11 downto 8); regfile0_data_b_regsel <= instruction_word(7 downto 4); regfile0_data_c_regsel <= instruction_word(3 downto 0);
                regfile0_we <= '1'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '1';
                fpu0_en <= '1'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '0'; alu_ins <= '0';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when fdiv=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= instruction_word(11 downto 8); regfile0_data_b_regsel <= instruction_word(7 downto 4); regfile0_data_c_regsel <= instruction_word(3 downto 0);
                regfile0_we <= '0'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '1';
                fpu0_en <= '1'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '0'; alu_ins <= '0';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when fdiv_w0=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= instruction_word(11 downto 8); regfile0_data_b_regsel <= instruction_word(7 downto 4); regfile0_data_c_regsel <= instruction_word(3 downto 0);
                regfile0_we <= '0'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '1';
                fpu0_en <= '1'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '0'; alu_ins <= '0';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when fdiv_w1=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= instruction_word(11 downto 8); regfile0_data_b_regsel <= instruction_word(7 downto 4); regfile0_data_c_regsel <= instruction_word(3 downto 0);
                regfile0_we <= '0'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '1';
                fpu0_en <= '1'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '0'; alu_ins <= '0';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when fdiv_w2=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= instruction_word(11 downto 8); regfile0_data_b_regsel <= instruction_word(7 downto 4); regfile0_data_c_regsel <= instruction_word(3 downto 0);
                regfile0_we <= '0'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '1';
                fpu0_en <= '1'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '0'; alu_ins <= '0';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when fdiv_w3=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= instruction_word(11 downto 8); regfile0_data_b_regsel <= instruction_word(7 downto 4); regfile0_data_c_regsel <= instruction_word(3 downto 0);
                regfile0_we <= '0'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '1';
                fpu0_en <= '1'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '0'; alu_ins <= '0';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when fdiv_w4=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= instruction_word(11 downto 8); regfile0_data_b_regsel <= instruction_word(7 downto 4); regfile0_data_c_regsel <= instruction_word(3 downto 0);
                regfile0_we <= '0'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '1';
                fpu0_en <= '1'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '0'; alu_ins <= '0';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when fdiv_done=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= instruction_word(11 downto 8); regfile0_data_b_regsel <= instruction_word(7 downto 4); regfile0_data_c_regsel <= instruction_word(3 downto 0);
                regfile0_we <= '1'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '1';
                fpu0_en <= '1'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '0'; alu_ins <= '0';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when fmul=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= instruction_word(11 downto 8); regfile0_data_b_regsel <= instruction_word(7 downto 4); regfile0_data_c_regsel <= instruction_word(3 downto 0);
                regfile0_we <= '0'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '1';
                fpu0_en <= '1'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '0'; alu_ins <= '0';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when fmul_w0=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= instruction_word(11 downto 8); regfile0_data_b_regsel <= instruction_word(7 downto 4); regfile0_data_c_regsel <= instruction_word(3 downto 0);
                regfile0_we <= '0'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '1';
                fpu0_en <= '1'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '0'; alu_ins <= '0';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when fmul_w1=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= instruction_word(11 downto 8); regfile0_data_b_regsel <= instruction_word(7 downto 4); regfile0_data_c_regsel <= instruction_word(3 downto 0);
                regfile0_we <= '0'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '1';
                fpu0_en <= '1'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '0'; alu_ins <= '0';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when fmul_w2=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= instruction_word(11 downto 8); regfile0_data_b_regsel <= instruction_word(7 downto 4); regfile0_data_c_regsel <= instruction_word(3 downto 0);
                regfile0_we <= '0'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '1';
                fpu0_en <= '1'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '0'; alu_ins <= '0';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when fmul_w3=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= instruction_word(11 downto 8); regfile0_data_b_regsel <= instruction_word(7 downto 4); regfile0_data_c_regsel <= instruction_word(3 downto 0);
                regfile0_we <= '0'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '1';
                fpu0_en <= '1'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '0'; alu_ins <= '0';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

            when fmul_done=>
                instruction_we <= '0';
                regfile0_data_a_regsel <= instruction_word(11 downto 8); regfile0_data_b_regsel <= instruction_word(7 downto 4); regfile0_data_c_regsel <= instruction_word(3 downto 0);
                regfile0_we <= '1'; regfile0_data_a_oe <= '1'; regfile0_data_b_oe <= '1';
                fpu0_en <= '1'; cmp0_en <= '0'; barrel0_en <= '0'; alu0_en <= '0'; alu_ins <= '0';
                miso_oe <= '0'; we <= '0'; oe <= '0'; arg_oe <= '0'; arg_sel <= '0';
                int_accept <= '0'; int_completed <= '0';
                inc_r14 <= '0'; inc_r15 <= '0'; dec_r14 <= '0'; dec_r15 <= '0';
                address_alu_oe <= '0'; address_alu_opcode <= '0'; flag_sel <= "----";

        end case;
    end process;

end architecture id_arch;
