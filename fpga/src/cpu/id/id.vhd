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
        int, int_wait, int_set, int_inc, int_inc_wait, int_inc_set, int_dec,
        int_dec_wait, int_dec_set,
        ret, ret_wait, reti, reti_wait,
        call, call_wait, call_set, calli, calli_wait, calli_set,
        pop, pop_wait,
        push, push_wait,
        ld, ld_wait, ldi, ldi_wait, st, st_wait, sti, sti_wait,
        bz, bz_set, bnz, bnz_set,
        mvi, mvia, barrel, alu,
        cmpi, cmpf, cmpf_2,
        div, div_w0, div_w1, div_w2, div_w3, div_w4, div_w5, div_w6, div_w7,
        div_w8, div_w9, div_w10, div_w11, div_w12, div_w13, div_w14, div_w15,
        div_w16, div_w17, div_w18, div_w19, div_w20, div_w21, div_w22, div_w23,
        div_w24, div_w25, div_w26, div_w27, div_w28, div_w29, div_w30, div_done,
        faddsub, faddsub_w0, faddsub_w1, faddsub_w2, faddsub_w3, faddsub_w4,
        faddsub_w5, faddsub_done,
        fdiv, fdiv_w0, fdiv_w1, fdiv_w2, fdiv_w3, fdiv_w4, fdiv_done,
        fmul, fmul_w0, fmul_w1, fmul_w2, fmul_w3, fmul_done,
    );

    signal id_state: id_state_type;

begin

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
                case state is
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
                        -- dekóduj tady instrukce!
                        id_state <= start;

                    when int =>
                        case ack is
                            when '1' => id_state <= int_set;
                            when others => id_state <= int_wait;
                        end case;
                    when int_wait =>
                        case ack is
                            when '1' => id_state <= int_set;
                            when others => id_state <= int_wait;
                        end case;
                    when int_set =>
                        id_state <= start;

                    when int_inc =>
                        case ack is
                            when '1' => id_state <= int_inc_set;
                            when others => id_state <= int_inc_wait;
                        end case;
                    when int_inc_wait =>
                        case ack is
                            when '1' => id_state <= int_inc_set;
                            when others => id_state <= int_inc_wait;
                        end case;
                    when int_inc_set =>
                        id_state <= start_inc;

                    when int_dec =>
                        case ack is
                            when '1' => id_state <= int_dec_set;
                            when others => id_state <= int_dec_wait;
                        end case;
                    when int_dec_wait =>
                        case ack is
                            when '1' => id_state <= int_dec_set;
                            when others => id_state <= int_dec_wait;
                        end case;
                    when int_dec_set =>
                        id_state <= start;

                    when ret =>
                        case ack is
                            when '1' =>
                                case int is
                                    when '1' => id_state <= int_inc;
                                    when others => id_state <= start_inc;
                                end case;
                            when others => id_state <= ret_wait;
                        end case;
                    when ret_wait =>
                        case ack is
                            when '1' =>
                                case int is
                                    when '1' => id_state <= int_inc;
                                    when others => id_state <= start_inc;
                                end case;
                            when others => id_state <= ret_wait;
                        end case;
                    when reti =>
                        case ack is
                            when '1' =>
                                case int is
                                    when '1' => id_state <= int_inc;
                                    when others => id_state <= start_inc;
                                end case;
                            when others => id_state <= reti_wait;
                        end case;
                    when reti_wait =>
                        case ack is
                            when '1' =>
                                case int is
                                    when '1' => id_state <= int_inc;
                                    when others => id_state <= start_inc;
                                end case;
                            when others => id_state <= reti_wait;
                        end case;

                    when call =>
                        case ack is
                            when '1' => id_state <= call_set;
                            when others => id_state <= call_wait;
                        end case;
                    when call_wait =>
                        case ack is
                            when '1' => id_state <= call_set;
                            when others => id_state <= call_wait;
                        end case;
                    when call_set =>
                        case int is =>
                            when '1' => id_state <= int;
                            when others => id_state <= start;
                        end case;
                    when calli =>
                        case ack is
                            when '1' => id_state <= calli_set;
                            when others => id_state <= calli_wait;
                        end case;
                    when calli_wait =>
                        case ack is
                            when '1' => id_state <= calli_set;
                            when others => id_state <= calli_wait;
                        end case;
                    when calli_set =>
                        case int is =>
                            when '1' => id_state <= int;
                            when others => id_state <= start;
                        end case;

                    when pop =>
                        case ack is
                            when '1' =>
                                case int is =>
                                    when '1' => id_state <= int_inc;
                                    when others => id_state <= start_inc;
                                end case;
                            when others => id_state <= pop_wait;
                        end case;
                    when pop_wait =>
                        case ack is
                            when '1' =>
                                case int is =>
                                    when '1' => id_state <= int_inc;
                                    when others => id_state <= start_inc;
                                end case;
                            when others => id_state <= pop_wait;
                        end case;

                    when push =>
                        case ack is
                            when '1' =>
                                case int is =>
                                    when '1' => id_state <= int_dec;
                                    when others => id_state <= start_dec;
                                end case;
                            when others => id_state <= push_wait;
                        end case;
                    when push_wait =>
                        case ack is
                            when '1' =>
                                case int is =>
                                    when '1' => id_state <= int_dec;
                                    when others => id_state <= start_dec;
                                end case;
                            when others => id_state <= push_wait;
                        end case;

                    when ld =>
                        case ack is
                            when '1' =>
                                case int is =>
                                    when '1' => id_state <= int;
                                    when others => id_state <= start;
                                end case;
                            when others => id_state <= ld_wait;
                        end case;
                    when ld_wait =>
                        case ack is
                            when '1' =>
                                case int is =>
                                    when '1' => id_state <= int;
                                    when others => id_state <= start;
                                end case;
                            when others => id_state <= ld_wait;
                        end case;
                    when ldi =>
                        case ack is
                            when '1' =>
                                case int is =>
                                    when '1' => id_state <= int;
                                    when others => id_state <= start;
                                end case;
                            when others => id_state <= ldi_wait;
                        end case;
                    when ldi_wait =>
                        case ack is
                            when '1' =>
                                case int is =>
                                    when '1' => id_state <= int;
                                    when others => id_state <= start;
                                end case;
                            when others => id_state <= ldi_wait;
                        end case;
                    when st =>
                        case ack is
                            when '1' =>
                                case int is =>
                                    when '1' => id_state <= int;
                                    when others => id_state <= start;
                                end case;
                            when others => id_state <= st_wait;
                        end case;
                    when st_wait =>
                        case ack is
                            when '1' =>
                                case int is =>
                                    when '1' => id_state <= int;
                                    when others => id_state <= start;
                                end case;
                            when others => id_state <= st_wait;
                        end case;
                    when sti =>
                        case ack is
                            when '1' =>
                                case int is =>
                                    when '1' => id_state <= int;
                                    when others => id_state <= start;
                                end case;
                            when others => id_state <= sti_wait;
                        end case;
                    when sti_wait =>
                        case ack is
                            when '1' =>
                                case int is =>
                                    when '1' => id_state <= int;
                                    when others => id_state <= start;
                                end case;
                            when others => id_state <= sti_wait;
                        end case;

                    when bz =>
                        case flag is
                            when '1' => id_state <= bz_set;
                            when others =>
                                case int is
                                    when '1' => id_state <= int;
                                    when others => id_state <= start;
                                end case;
                        end case;
                    when bz_set =>
                        case int is
                            when '1' => id_state <= int;
                            when others => id_state <= start;
                        end case;
                    when bzi =>
                        case flag is
                            when '1' => id_state <= bzi_set;
                            when others =>
                                case int is
                                    when '1' => id_state <= int;
                                    when others => id_state <= start;
                                end case;
                        end case;
                    when bzi_set =>
                        case int is
                            when '1' => id_state <= int;
                            when others => id_state <= start;
                        end case;
                    when bnz =>
                        case flag is
                            when '0' => id_state <= bnz_set;
                            when others =>
                                case int is
                                    when '1' => id_state <= int;
                                    when others => id_state <= start;
                                end case;
                        end case;
                    when bnz_set =>
                        case int is
                            when '1' => id_state <= int;
                            when others => id_state <= start;
                        end case;
                    when bnzi =>
                        case flag is
                            when '0' => id_state <= bnzi_set;
                            when others =>
                                case int is
                                    when '1' => id_state <= int;
                                    when others => id_state <= start;
                                end case;
                        end case;
                    when bnzi_set =>
                        case int is
                            when '1' => id_state <= int;
                            when others => id_state <= start;
                        end case;

                    when mvi =>
                        case int is
                            when '1' => id_state <= int;
                            when others => id_state <= start;
                        end case;
                    when mvia =>
                        case int is
                            when '1' => id_state <= int;
                            when others => id_state <= start;
                        end case;
                    when barrel =>
                        case int is
                            when '1' => id_state <= int;
                            when others => id_state <= start;
                        end case;
                    when alu =>
                        case int is
                            when '1' => id_state <= int;
                            when others => id_state <= start;
                        end case;

                    when cmpi =>
                        case int is
                            when '1' => id_state <= int;
                            when others => id_state <= start;
                        end case;
                    when cmpf => id_state <= cmpf_2;
                    when cmpf_2 =>
                        case int is
                            when '1' => id_state <= int;
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
                            when '1' => id_state <= int;
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
                            when '1' => id_state <= int;
                            when others => id_state <= start;
                        end case;

                    when fmul      => id_state <= fmul_w0;
                    when fmul_w0   => id_state <= fmul_w1;
                    when fmul_w1   => id_state <= fmul_w2;
                    when fmul_w2   => id_state <= fmul_w3;
                    when fmul_w3   => id_state <= fmul_done;
                    when fmul_done =>
                        case int is
                            when '1' => id_state <= int;
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
                            when '1' => id_state <= int;
                            when others => id_state <= start;
                        end case;

                end case;
            end if;
        end if;
    end process;

end architecture id_arch;
