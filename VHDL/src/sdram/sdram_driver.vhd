library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sdram_driver is
    port(

        clk_100: in std_logic;
        res: in std_logic;

        address: in std_logic_vector(22 downto 0);
        data_in: in std_logic_vector(31 downto 0);
        data_out: out std_logic_vector(31 downto 0);
        busy: out std_logic;
        wr_req: in std_logic;
        rd_req: in std_logic;
        data_out_ready: out std_logic;
        ack: out std_logic;

        sdram_ras_n: out std_logic;
        sdram_cas_n: out std_logic;
        sdram_we_n: out std_logic;
        sdram_addr: out std_logic_vector(12 downto 0);
        sdram_ba: out std_logic_vector(1 downto 0);
        sdram_data: inout std_logic_vector(7 downto 0)

    );
end entity sdram_driver;

architecture sdram_driver_arch of sdram_driver is
    component data_io_buff is
        port(
            datain: in std_logic_vector (15 downto 0);
            oe: in std_logic_vector (15 downto 0);
            dataio: inout std_logic_vector (15 downto 0);
            dataout: out std_logic_vector (15 downto 0)
        );
    end component;

    --data from sdram (registered)
    signal captured_data: std_logic_vector(7 downto 0);
    --oe control signal for bidir buff
    signal bidir_buff_oe, bidir_buff_oe_buff: std_logic;
    --datainput to bidir buff
    signal bidir_buff_datain, bidir_buff_datain_buff: std_logic_vector(7 downto 0);
    --unregistered output from bidirbuff
    signal sdram_dataout: std_logic_vector(7 downto 0);
    --these signals are controling control outputs for sdram
    signal sdram_addr_unbuff: std_logic_vector(12 downto 0);
    signal sdram_ba_unbuff: std_logic_vector(1 downto 0);
    signal sdram_control: std_logic_vector(2 downto 0);
    --comands for sdram maped into vectors
    constant com_device_deselect: std_logic_vector(2 downto 0):= "000";
    constant com_no_operation: std_logic_vector(2 downto 0):= "111";
    constant com_burst_stop: std_logic_vector(2 downto 0):= "110";
    constant com_read: std_logic_vector(2 downto 0):= "101"; --bank and A0..A9 must be valid; A10 must be low
    constant com_read_precharge: std_logic_vector(2 downto 0):= "101"; --A10 must be high
    constant com_write: std_logic_vector(2 downto 0):= "100"; --A10 must be low
    constant com_write_precharge: std_logic_vector(2 downto 0):= "100";--A10 must be high
    constant com_bank_active: std_logic_vector(2 downto 0):= "011"; --bank and addr must be valid
    constant com_precharge_select_bank: std_logic_vector(2 downto 0):= "010";--bank valid and A10 low; rest of addr dont care
    constant com_precharge_all_banks: std_logic_vector(2 downto 0):= "010"; --A10 high; others dont care
    constant com_cbr_auto_refresh: std_logic_vector(2 downto 0):= "001"; --everything dont care
    constant com_mode_reg_set: std_logic_vector(2 downto 0):= "000"; --bank low; A10 low; A0..A9 valid

    --put this constant on address bus it is configuration register
    -- CAS = 2; burst = 4 words;
    constant mode_register: std_logic_vector(12 downto 0) := "0000000100010";

    --this signal is we into output register
    signal write_input_data_reg: std_logic;

    --clean refresh counter
    signal refresh_counter_clean: std_logic;

    --signalize refresh need
    signal force_refresh: std_logic;

    --for init seq
    signal init_counter_val: unsigned(17 downto 0);
    signal init_counter_clean: std_logic; -- clean startup counter
    --main sdram FSM
    type sdram_fsm_state_type is (
        init_delay, init_precharge, init_precharge_wait,
        init_refresh_0, init_refresh_1,
        init_refresh_2, init_refresh_3,
        init_refresh_4, init_refresh_5,
        init_refresh_6, init_refresh_7,
        init_refresh_0_wait, init_refresh_1_wait,
        init_refresh_2_wait, init_refresh_3_wait,
        init_refresh_4_wait, init_refresh_5_wait,
        init_refresh_6_wait, init_refresh_7_wait,
        init_mode_reg, init_mode_reg_wait, idle,
        autorefresh, autorefresh_wait,
        bank_active, bank_active_nop0, bank_active_nop1,
        write_data, write_nop_0, write_nop_1, write_nop_2, write_nop_3, write_nop_4, write_nop_5, write_nop_6,
        read_command, read_nop_0, read_nop_1, read_nop_2, read_nop_3, read_nop_4, read_nop_5, read_nop_6, read_completed
    );
    signal fsm_state: sdram_fsm_state_type := init_delay;
    attribute FSM_ENCODING : string;
    attribute FSM_ENCODING of fsm_state : signal is "ONE-HOT";

    --address parts
    signal address_ba: std_logic_vector(1 downto 0);
    signal address_row: std_logic_vector(12 downto 0);
    signal address_col: std_logic_vector(9 downto 0);

    --signals from command register
    signal cmd_wr_req: std_logic;
    --~ signal cmd_rd_req: std_logic;
    signal cmd_address: std_logic_vector(22 downto 0);
    signal cmd_data_in: std_logic_vector(31 downto 0);

    signal write_cmd_reg: std_logic;
begin

    --split address into multiple parts
    address_ba <= cmd_address(22 downto 21);
    address_row <= cmd_address(20 downto 8);
    address_col <= cmd_address(7 downto 0) & "00";

    --bidirectional buffer for DQ pins
    sdram_dataout <= sdram_data;
    sdram_data <= bidir_buff_datain_buff when bidir_buff_oe_buff = '1' else (others => 'Z');

    process(clk_100) is
        variable bidir_buff_oe_var: std_logic := '0';
    begin
        if rising_edge(clk_100) then
            if res = '1' then
                bidir_buff_oe_var := '0';
            else
                bidir_buff_oe_var := bidir_buff_oe;
            end if;
        end if;
        bidir_buff_oe_buff <= bidir_buff_oe_var;
    end process;

    process(clk_100) is
        variable bidir_buff_datain_var: std_logic_vector(7 downto 0) := x"00";
    begin
        if rising_edge(clk_100) then
            if res = '1' then
                bidir_buff_datain_var := (others => '0');
            else
                bidir_buff_datain_var := bidir_buff_datain;
            end if;
        end if;
        bidir_buff_datain_buff <= bidir_buff_datain_var;
    end process;

    --register input data from sdram
    process(clk_100) is
        variable captured_data_var: std_logic_vector(7 downto 0) := (others => '0');
    begin
        if rising_edge(clk_100) then
            if res = '1' then
                captured_data_var := (others => '0');
            else
                captured_data_var := sdram_dataout;
            end if;
        end if;
        captured_data <= captured_data_var;
    end process;

    --this is register for dataout
    process(clk_100) is
        variable input_data_register_var_low: std_logic_vector(7 downto 0) := (others => '0');
        variable input_data_register_var_mlow: std_logic_vector(7 downto 0) := (others => '0');
        variable input_data_register_var_mhigh: std_logic_vector(7 downto 0) := (others => '0');
        variable input_data_register_var_high: std_logic_vector(7 downto 0) := (others => '0');
    begin
        if rising_edge(clk_100) then
            if res = '1' then
                input_data_register_var_low   := (others => '0');
                input_data_register_var_mlow  := (others => '0');
                input_data_register_var_mhigh := (others => '0');
                input_data_register_var_high  := (others => '0');
            elsif write_input_data_reg = '1' then
                input_data_register_var_high  := input_data_register_var_mhigh;
                input_data_register_var_mhigh := input_data_register_var_mlow;
                input_data_register_var_mlow  := input_data_register_var_low;
                input_data_register_var_low   := captured_data;
            end if;
        end if;
        data_out <= input_data_register_var_high & input_data_register_var_mhigh & input_data_register_var_mlow & input_data_register_var_low;
    end process;

    --register all outputs
    process(clk_100) is
        variable sdram_ras_n_var: std_logic := '1';
        variable sdram_cas_n_var: std_logic := '1';
        variable sdram_we_n_var: std_logic := '1';
        variable sdram_addr_var: std_logic_vector(12 downto 0) := (others => '0');
        variable sdram_ba_var: std_logic_vector(1 downto 0) := (others => '0');
    begin
        if rising_edge(clk_100) then
            if res = '1' then
                sdram_ras_n_var := '1';
                sdram_cas_n_var := '1';
                sdram_we_n_var := '1';
                sdram_addr_var := (others => '0');
                sdram_ba_var := (others => '0');
            else
                sdram_addr_var := sdram_addr_unbuff;
                sdram_ba_var := sdram_ba_unbuff;
                sdram_ras_n_var := sdram_control(2);
                sdram_cas_n_var := sdram_control(1);
                sdram_we_n_var := sdram_control(0);
            end if;
        end if;
        sdram_ras_n <= sdram_ras_n_var;
        sdram_cas_n <= sdram_cas_n_var;
        sdram_we_n <= sdram_we_n_var;
        sdram_addr <= sdram_addr_var;
        sdram_ba <= sdram_ba_var;
    end process;

    --refresh counter
    process(clk_100) is
        variable counter_var: unsigned(12 downto 0) := (others => '0');
    begin
        if rising_edge(clk_100) then
            if res = '1' or refresh_counter_clean = '1' then
                counter_var := (others => '0');
            else
                counter_var := counter_var + 1;
            end if;
        end if;

        --refresh is needed each 7.8125 us
        --this call it each 4.096 us
        force_refresh <= counter_var(12);
    end process;

    --startup counter
    process(clk_100) is
        variable counter_var: unsigned(17 downto 0) := (others => '0');
    begin
        if rising_edge(clk_100) then
            if res = '1' or init_counter_clean = '1' then
                counter_var := (others => '0');
            else
                counter_var := counter_var + 1;
            end if;
        end if;
        init_counter_val <= counter_var;
    end process;

    --register for command
    process(clk_100) is
        variable wr_req_var: std_logic := '0';
        --~ variable rd_req_var: std_logic := '0';
        variable address_var: std_logic_vector(22 downto 0) := (others => '0');
        variable data_in_var: std_logic_vector(31 downto 0) := (others => '0');
    begin
        if rising_edge(clk_100) then
            if res = '1' then
                wr_req_var := '0';
                --~ rd_req_var := '0';
                address_var := (others => '0');
                data_in_var := (others => '0');
            elsif write_cmd_reg = '1' then
                wr_req_var := wr_req;
                --~ rd_req_var := rd_req;
                address_var := address;
                data_in_var := data_in;
            end if;
        end if;
        cmd_wr_req <= wr_req_var;
        --~ cmd_rd_req <= rd_req_var;
        cmd_address <= address_var;
        cmd_data_in <= data_in_var;
    end process;

    --main fsm
    process(clk_100) is
    begin
        if rising_edge(clk_100) then
            if res = '1' then
                fsm_state <= init_delay;
            else
                case fsm_state is

                    when init_delay =>
                        if init_counter_val = 200000 then
                            fsm_state <= init_precharge;
                        else
                            fsm_state <= init_delay;
                        end if;

                    when init_precharge =>
                        fsm_state <= init_precharge_wait;

                    when init_precharge_wait =>
                        if init_counter_val = 2 then
                            fsm_state <= init_refresh_0;
                        else
                            fsm_state <= init_precharge_wait;
                        end if;

                    when init_refresh_0 =>
                        fsm_state <= init_refresh_0_wait;

                    when init_refresh_0_wait =>
                        if init_counter_val = 7 then
                            fsm_state <= init_refresh_1;
                        else
                            fsm_state <= init_refresh_0_wait;
                        end if;

                    when init_refresh_1 =>
                        fsm_state <= init_refresh_1_wait;

                    when init_refresh_1_wait =>
                        if init_counter_val = 7 then
                            fsm_state <= init_refresh_2;
                        else
                            fsm_state <= init_refresh_1_wait;
                        end if;

                    when init_refresh_2 =>
                        fsm_state <= init_refresh_2_wait;

                    when init_refresh_2_wait =>
                        if init_counter_val = 7 then
                            fsm_state <= init_refresh_3;
                        else
                            fsm_state <= init_refresh_2_wait;
                        end if;

                    when init_refresh_3 =>
                        fsm_state <= init_refresh_3_wait;

                    when init_refresh_3_wait =>
                        if init_counter_val = 7 then
                            fsm_state <= init_refresh_4;
                        else
                            fsm_state <= init_refresh_3_wait;
                        end if;

                    when init_refresh_4 =>
                        fsm_state <= init_refresh_4_wait;

                    when init_refresh_4_wait =>
                        if init_counter_val = 7 then
                            fsm_state <= init_refresh_5;
                        else
                            fsm_state <= init_refresh_4_wait;
                        end if;

                    when init_refresh_5 =>
                        fsm_state <= init_refresh_5_wait;

                    when init_refresh_5_wait =>
                        if init_counter_val = 7 then
                            fsm_state <= init_refresh_6;
                        else
                            fsm_state <= init_refresh_5_wait;
                        end if;

                    when init_refresh_6 =>
                        fsm_state <= init_refresh_6_wait;

                    when init_refresh_6_wait =>
                        if init_counter_val = 7 then
                            fsm_state <= init_refresh_7;
                        else
                            fsm_state <= init_refresh_6_wait;
                        end if;

                    when init_refresh_7 =>
                        fsm_state <= init_refresh_7_wait;

                    when init_refresh_7_wait =>
                        if init_counter_val = 7 then
                            fsm_state <= init_mode_reg;
                        else
                            fsm_state <= init_refresh_7_wait;
                        end if;

                    when init_mode_reg =>
                        fsm_state <= init_mode_reg_wait;

                    when init_mode_reg_wait =>
                        if init_counter_val = 7 then
                            fsm_state <= idle;
                        else
                            fsm_state <= init_mode_reg_wait;
                        end if;

                    --there is idle process
                    when idle =>
                        if force_refresh = '1' then
                            fsm_state <= autorefresh;
                        elsif wr_req = '1' or rd_req = '1' then
                            fsm_state <= bank_active;
                        else
                            fsm_state <= idle;
                        end if;

                    --autorefresh stage
                    when autorefresh =>
                        fsm_state <= autorefresh_wait;

                    when autorefresh_wait =>
                        if init_counter_val = 7 then
                            fsm_state <= idle;
                        else
                            fsm_state <= autorefresh_wait;
                        end if;

                    --active bank and row
                    when bank_active =>
                        fsm_state <= bank_active_nop0;

                    when bank_active_nop0 =>
                        fsm_state <= bank_active_nop1;

                    when bank_active_nop1 =>
                        if cmd_wr_req = '1' then
                            fsm_state <= write_data;
                        else
                            fsm_state <= read_command;
                        end if;

                    -- write data into sdram
                    when write_data =>
                        fsm_state <= write_nop_0;

                    when write_nop_0 =>
                        fsm_state <= write_nop_1;

                    when write_nop_1 =>
                        fsm_state <= write_nop_2;

                    when write_nop_2 =>
                        fsm_state <= write_nop_3;

                    when write_nop_3 =>
                        fsm_state <= write_nop_4;

                    when write_nop_4 =>
                        fsm_state <= write_nop_5;

                    when write_nop_5 =>
                        fsm_state <= write_nop_6;

                    when write_nop_6 =>
                        fsm_state <= idle;

                    --read data block
                    when read_command =>
                        fsm_state <= read_nop_0;

                    when read_nop_0 =>
                        fsm_state <= read_nop_1;

                    when read_nop_1 =>
                        fsm_state <= read_nop_2;

                    when read_nop_2 =>
                        fsm_state <= read_nop_3;

                    when read_nop_3 =>
                        fsm_state <= read_nop_4;

                    when read_nop_4 =>
                        fsm_state <= read_nop_5;

                    when read_nop_5 =>
                        fsm_state <= read_nop_6;

                    when read_nop_6 =>
                        fsm_state <= read_completed;

                    when read_completed =>
                        fsm_state <= idle;

                end case;
            end if;
        end if;
    end process;


    process(fsm_state, address_row, address_ba, address_col, cmd_data_in) is
    begin
        case fsm_state is
            when init_delay =>
                init_counter_clean <= '0';
                refresh_counter_clean <= '0';
                bidir_buff_oe <= '0';
                sdram_control <= com_no_operation;
                sdram_addr_unbuff <= "0000000000000";
                sdram_ba_unbuff <= "00";
                bidir_buff_datain <= x"00";
                busy <= '1';
                write_input_data_reg <= '0';
                data_out_ready <= '0';
                write_cmd_reg <= '0';
                ack <= '0';

            when init_precharge =>
                init_counter_clean <= '1';
                refresh_counter_clean <= '0';
                bidir_buff_oe <= '0';
                sdram_control <= com_precharge_all_banks;
                sdram_addr_unbuff <= "0010000000000";
                sdram_ba_unbuff <= "00";
                bidir_buff_datain <= x"00";
                busy <= '1';
                write_input_data_reg <= '0';
                data_out_ready <= '0';
                write_cmd_reg <= '0';
                ack <= '0';

            when init_precharge_wait =>
                init_counter_clean <= '0';
                refresh_counter_clean <= '0';
                bidir_buff_oe <= '0';
                sdram_control <= com_no_operation;
                sdram_addr_unbuff <= "0000000000000";
                sdram_ba_unbuff <= "00";
                bidir_buff_datain <= x"00";
                busy <= '1';
                write_input_data_reg <= '0';
                data_out_ready <= '0';
                write_cmd_reg <= '0';
                ack <= '0';

            when init_refresh_0 =>
                init_counter_clean <= '1';
                refresh_counter_clean <= '0';
                bidir_buff_oe <= '0';
                sdram_control <= com_cbr_auto_refresh;
                sdram_addr_unbuff <= "0000000000000";
                sdram_ba_unbuff <= "00";
                bidir_buff_datain <= x"00";
                busy <= '1';
                write_input_data_reg <= '0';
                data_out_ready <= '0';
                write_cmd_reg <= '0';
                ack <= '0';

            when init_refresh_0_wait =>
                init_counter_clean <= '0';
                refresh_counter_clean <= '0';
                bidir_buff_oe <= '0';
                sdram_control <= com_no_operation;
                sdram_addr_unbuff <= "0000000000000";
                sdram_ba_unbuff <= "00";
                bidir_buff_datain <= x"00";
                busy <= '1';
                write_input_data_reg <= '0';
                data_out_ready <= '0';
                write_cmd_reg <= '0';
                ack <= '0';

            when init_refresh_1 =>
                init_counter_clean <= '1';
                refresh_counter_clean <= '0';
                bidir_buff_oe <= '0';
                sdram_control <= com_cbr_auto_refresh;
                sdram_addr_unbuff <= "0000000000000";
                sdram_ba_unbuff <= "00";
                bidir_buff_datain <= x"00";
                busy <= '1';
                write_input_data_reg <= '0';
                data_out_ready <= '0';
                write_cmd_reg <= '0';
                ack <= '0';

            when init_refresh_1_wait =>
                init_counter_clean <= '0';
                refresh_counter_clean <= '0';
                bidir_buff_oe <= '0';
                sdram_control <= com_no_operation;
                sdram_addr_unbuff <= "0000000000000";
                sdram_ba_unbuff <= "00";
                bidir_buff_datain <= x"00";
                busy <= '1';
                write_input_data_reg <= '0';
                data_out_ready <= '0';
                write_cmd_reg <= '0';
                ack <= '0';

            when init_refresh_2 =>
                init_counter_clean <= '1';
                refresh_counter_clean <= '0';
                bidir_buff_oe <= '0';
                sdram_control <= com_cbr_auto_refresh;
                sdram_addr_unbuff <= "0000000000000";
                sdram_ba_unbuff <= "00";
                bidir_buff_datain <= x"00";
                busy <= '1';
                write_input_data_reg <= '0';
                data_out_ready <= '0';
                write_cmd_reg <= '0';
                ack <= '0';

            when init_refresh_2_wait =>
                init_counter_clean <= '0';
                refresh_counter_clean <= '0';
                bidir_buff_oe <= '0';
                sdram_control <= com_no_operation;
                sdram_addr_unbuff <= "0000000000000";
                sdram_ba_unbuff <= "00";
                bidir_buff_datain <= x"00";
                busy <= '1';
                write_input_data_reg <= '0';
                data_out_ready <= '0';
                write_cmd_reg <= '0';
                ack <= '0';

            when init_refresh_3 =>
                init_counter_clean <= '1';
                refresh_counter_clean <= '0';
                bidir_buff_oe <= '0';
                sdram_control <= com_cbr_auto_refresh;
                sdram_addr_unbuff <= "0000000000000";
                sdram_ba_unbuff <= "00";
                bidir_buff_datain <= x"00";
                busy <= '1';
                write_input_data_reg <= '0';
                data_out_ready <= '0';
                write_cmd_reg <= '0';
                ack <= '0';

            when init_refresh_3_wait =>
                init_counter_clean <= '0';
                refresh_counter_clean <= '0';
                bidir_buff_oe <= '0';
                sdram_control <= com_no_operation;
                sdram_addr_unbuff <= "0000000000000";
                sdram_ba_unbuff <= "00";
                bidir_buff_datain <= x"00";
                busy <= '1';
                write_input_data_reg <= '0';
                data_out_ready <= '0';
                write_cmd_reg <= '0';
                ack <= '0';

            when init_refresh_4 =>
                init_counter_clean <= '1';
                refresh_counter_clean <= '0';
                bidir_buff_oe <= '0';
                sdram_control <= com_cbr_auto_refresh;
                sdram_addr_unbuff <= "0000000000000";
                sdram_ba_unbuff <= "00";
                bidir_buff_datain <= x"00";
                busy <= '1';
                write_input_data_reg <= '0';
                data_out_ready <= '0';
                write_cmd_reg <= '0';
                ack <= '0';

            when init_refresh_4_wait =>
                init_counter_clean <= '0';
                refresh_counter_clean <= '0';
                bidir_buff_oe <= '0';
                sdram_control <= com_no_operation;
                sdram_addr_unbuff <= "0000000000000";
                sdram_ba_unbuff <= "00";
                bidir_buff_datain <= x"00";
                busy <= '1';
                write_input_data_reg <= '0';
                data_out_ready <= '0';
                write_cmd_reg <= '0';
                ack <= '0';

            when init_refresh_5 =>
                init_counter_clean <= '1';
                refresh_counter_clean <= '0';
                bidir_buff_oe <= '0';
                sdram_control <= com_cbr_auto_refresh;
                sdram_addr_unbuff <= "0000000000000";
                sdram_ba_unbuff <= "00";
                bidir_buff_datain <= x"00";
                busy <= '1';
                write_input_data_reg <= '0';
                data_out_ready <= '0';
                write_cmd_reg <= '0';
                ack <= '0';

            when init_refresh_5_wait =>
                init_counter_clean <= '0';
                refresh_counter_clean <= '0';
                bidir_buff_oe <= '0';
                sdram_control <= com_no_operation;
                sdram_addr_unbuff <= "0000000000000";
                sdram_ba_unbuff <= "00";
                bidir_buff_datain <= x"00";
                busy <= '1';
                write_input_data_reg <= '0';
                data_out_ready <= '0';
                write_cmd_reg <= '0';
                ack <= '0';

            when init_refresh_6 =>
                init_counter_clean <= '1';
                refresh_counter_clean <= '0';
                bidir_buff_oe <= '0';
                sdram_control <= com_cbr_auto_refresh;
                sdram_addr_unbuff <= "0000000000000";
                sdram_ba_unbuff <= "00";
                bidir_buff_datain <= x"00";
                busy <= '1';
                write_input_data_reg <= '0';
                data_out_ready <= '0';
                write_cmd_reg <= '0';
                ack <= '0';

            when init_refresh_6_wait =>
                init_counter_clean <= '0';
                refresh_counter_clean <= '0';
                bidir_buff_oe <= '0';
                sdram_control <= com_no_operation;
                sdram_addr_unbuff <= "0000000000000";
                sdram_ba_unbuff <= "00";
                bidir_buff_datain <= x"00";
                busy <= '1';
                write_input_data_reg <= '0';
                data_out_ready <= '0';
                write_cmd_reg <= '0';
                ack <= '0';

            when init_refresh_7 =>
                init_counter_clean <= '1';
                refresh_counter_clean <= '0';
                bidir_buff_oe <= '0';
                sdram_control <= com_cbr_auto_refresh;
                sdram_addr_unbuff <= "0000000000000";
                sdram_ba_unbuff <= "00";
                bidir_buff_datain <= x"00";
                busy <= '1';
                write_input_data_reg <= '0';
                data_out_ready <= '0';
                write_cmd_reg <= '0';
                ack <= '0';

            when init_refresh_7_wait =>
                init_counter_clean <= '0';
                refresh_counter_clean <= '0';
                bidir_buff_oe <= '0';
                sdram_control <= com_no_operation;
                sdram_addr_unbuff <= "0000000000000";
                sdram_ba_unbuff <= "00";
                bidir_buff_datain <= x"00";
                busy <= '1';
                write_input_data_reg <= '0';
                data_out_ready <= '0';
                write_cmd_reg <= '0';
                ack <= '0';

            when init_mode_reg =>
                init_counter_clean <= '1';
                refresh_counter_clean <= '1';
                bidir_buff_oe <= '0';
                sdram_control <= com_mode_reg_set;
                sdram_addr_unbuff <= mode_register;
                sdram_ba_unbuff <= "00";
                bidir_buff_datain <= x"00";
                busy <= '1';
                write_input_data_reg <= '0';
                data_out_ready <= '0';
                write_cmd_reg <= '0';
                ack <= '0';

            when init_mode_reg_wait =>
                init_counter_clean <= '0';
                refresh_counter_clean <= '0';
                bidir_buff_oe <= '0';
                sdram_control <= com_no_operation;
                sdram_addr_unbuff <= "0000000000000";
                sdram_ba_unbuff <= "00";
                bidir_buff_datain <= x"00";
                busy <= '1';
                write_input_data_reg <= '0';
                data_out_ready <= '0';
                write_cmd_reg <= '0';
                ack <= '0';

            when idle =>
                init_counter_clean <= '0';
                refresh_counter_clean <= '0';
                bidir_buff_oe <= '0';
                sdram_control <= com_no_operation;
                sdram_addr_unbuff <= "0000000000000";
                sdram_ba_unbuff <= "00";
                bidir_buff_datain <= x"00";
                busy <= '0';
                write_input_data_reg <= '0';
                data_out_ready <= '0';
                write_cmd_reg <= '1';
                ack <= '0';

            when autorefresh =>
                init_counter_clean <= '1';
                refresh_counter_clean <= '1';
                bidir_buff_oe <= '0';
                sdram_control <= com_cbr_auto_refresh;
                sdram_addr_unbuff <= "0000000000000";
                sdram_ba_unbuff <= "00";
                bidir_buff_datain <= x"00";
                busy <= '1';
                write_input_data_reg <= '0';
                data_out_ready <= '0';
                write_cmd_reg <= '0';
                ack <= '0';

            when autorefresh_wait =>
                init_counter_clean <= '0';
                refresh_counter_clean <= '0';
                bidir_buff_oe <= '0';
                sdram_control <= com_no_operation;
                sdram_addr_unbuff <= "0000000000000";
                sdram_ba_unbuff <= "00";
                bidir_buff_datain <= x"00";
                busy <= '1';
                write_input_data_reg <= '0';
                data_out_ready <= '0';
                write_cmd_reg <= '0';
                ack <= '0';

            when bank_active =>
                init_counter_clean <= '0';
                refresh_counter_clean <= '0';
                bidir_buff_oe <= '0';
                sdram_control <= com_bank_active;
                sdram_addr_unbuff <= address_row;
                sdram_ba_unbuff <= address_ba;
                bidir_buff_datain <= x"00";
                busy <= '1';
                write_input_data_reg <= '0';
                data_out_ready <= '0';
                write_cmd_reg <= '0';
                ack <= '1';

            when bank_active_nop0 =>
                init_counter_clean <= '0';
                refresh_counter_clean <= '0';
                bidir_buff_oe <= '0';
                sdram_control <= com_no_operation;
                sdram_addr_unbuff <= "0000000000000";
                sdram_ba_unbuff <= "00";
                bidir_buff_datain <= x"00";
                busy <= '1';
                write_input_data_reg <= '0';
                data_out_ready <= '0';
                write_cmd_reg <= '0';
                ack <= '0';

            when bank_active_nop1 =>
                init_counter_clean <= '0';
                refresh_counter_clean <= '0';
                bidir_buff_oe <= '0';
                sdram_control <= com_no_operation;
                sdram_addr_unbuff <= "0000000000000";
                sdram_ba_unbuff <= "00";
                bidir_buff_datain <= x"00";
                busy <= '1';
                write_input_data_reg <= '0';
                data_out_ready <= '0';
                write_cmd_reg <= '0';
                ack <= '0';

            when write_data =>
                init_counter_clean <= '0';
                refresh_counter_clean <= '0';
                bidir_buff_oe <= '1';
                sdram_control <= com_write_precharge;
                sdram_addr_unbuff <= "001" & address_col;
                sdram_ba_unbuff <= address_ba;
                bidir_buff_datain <= cmd_data_in(31 downto 24);
                busy <= '1';
                write_input_data_reg <= '0';
                data_out_ready <= '0';
                write_cmd_reg <= '0';
                ack <= '0';

            when write_nop_0 =>
                init_counter_clean <= '0';
                refresh_counter_clean <= '0';
                bidir_buff_oe <= '1';
                sdram_control <= com_no_operation;
                sdram_addr_unbuff <= "0000000000000";
                sdram_ba_unbuff <= "00";
                bidir_buff_datain <= cmd_data_in(23 downto 16);
                busy <= '1';
                write_input_data_reg <= '0';
                data_out_ready <= '0';
                write_cmd_reg <= '0';
                ack <= '0';

            when write_nop_1 =>
                init_counter_clean <= '0';
                refresh_counter_clean <= '0';
                bidir_buff_oe <= '1';
                sdram_control <= com_no_operation;
                sdram_addr_unbuff <= "0000000000000";
                sdram_ba_unbuff <= "00";
                bidir_buff_datain <= cmd_data_in(15 downto 8);
                busy <= '1';
                write_input_data_reg <= '0';
                data_out_ready <= '0';
                write_cmd_reg <= '0';
                ack <= '0';

            when write_nop_2 =>
                init_counter_clean <= '0';
                refresh_counter_clean <= '0';
                bidir_buff_oe <= '1';
                sdram_control <= com_no_operation;
                sdram_addr_unbuff <= "0000000000000";
                sdram_ba_unbuff <= "00";
                bidir_buff_datain <= cmd_data_in(7 downto 0);
                busy <= '1';
                write_input_data_reg <= '0';
                data_out_ready <= '0';
                write_cmd_reg <= '0';
                ack <= '0';

            when write_nop_3 =>
                init_counter_clean <= '0';
                refresh_counter_clean <= '0';
                bidir_buff_oe <= '0';
                sdram_control <= com_no_operation;
                sdram_addr_unbuff <= "0000000000000";
                sdram_ba_unbuff <= "00";
                bidir_buff_datain <= x"00";
                busy <= '1';
                write_input_data_reg <= '0';
                data_out_ready <= '0';
                write_cmd_reg <= '0';
                ack <= '0';

            when write_nop_4 =>
                init_counter_clean <= '0';
                refresh_counter_clean <= '0';
                bidir_buff_oe <= '0';
                sdram_control <= com_no_operation;
                sdram_addr_unbuff <= "0000000000000";
                sdram_ba_unbuff <= "00";
                bidir_buff_datain <= x"00";
                busy <= '1';
                write_input_data_reg <= '0';
                data_out_ready <= '0';
                write_cmd_reg <= '0';
                ack <= '0';

            when write_nop_5 =>
                init_counter_clean <= '0';
                refresh_counter_clean <= '0';
                bidir_buff_oe <= '0';
                sdram_control <= com_no_operation;
                sdram_addr_unbuff <= "0000000000000";
                sdram_ba_unbuff <= "00";
                bidir_buff_datain <= x"00";
                busy <= '1';
                write_input_data_reg <= '0';
                data_out_ready <= '0';
                write_cmd_reg <= '0';
                ack <= '0';

            when write_nop_6 =>
                init_counter_clean <= '0';
                refresh_counter_clean <= '0';
                bidir_buff_oe <= '0';
                sdram_control <= com_no_operation;
                sdram_addr_unbuff <= "0000000000000";
                sdram_ba_unbuff <= "00";
                bidir_buff_datain <= x"00";
                busy <= '1';
                write_input_data_reg <= '0';
                data_out_ready <= '0';
                write_cmd_reg <= '0';
                ack <= '0';

            when read_command =>
                init_counter_clean <= '0';
                refresh_counter_clean <= '0';
                bidir_buff_oe <= '0';
                sdram_control <= com_read_precharge;
                sdram_addr_unbuff <= "001" & address_col;
                sdram_ba_unbuff <= address_ba;
                bidir_buff_datain <= x"00";
                busy <= '1';
                write_input_data_reg <= '0';
                data_out_ready <= '0';
                write_cmd_reg <= '0';
                ack <= '0';

            when read_nop_0 =>
                init_counter_clean <= '0';
                refresh_counter_clean <= '0';
                bidir_buff_oe <= '0';
                sdram_control <= com_no_operation;
                sdram_addr_unbuff <= "0000000000000";
                sdram_ba_unbuff <= "00";
                bidir_buff_datain <= x"00";
                busy <= '1';
                write_input_data_reg <= '0';
                data_out_ready <= '0';
                write_cmd_reg <= '0';
                ack <= '0';

            when read_nop_1 =>
                init_counter_clean <= '0';
                refresh_counter_clean <= '0';
                bidir_buff_oe <= '0';
                sdram_control <= com_no_operation;
                sdram_addr_unbuff <= "0000000000000";
                sdram_ba_unbuff <= "00";
                bidir_buff_datain <= x"00";
                busy <= '1';
                write_input_data_reg <= '0';
                data_out_ready <= '0';
                write_cmd_reg <= '0';
                ack <= '0';

            when read_nop_2 =>
                init_counter_clean <= '0';
                refresh_counter_clean <= '0';
                bidir_buff_oe <= '0';
                sdram_control <= com_no_operation;
                sdram_addr_unbuff <= "0000000000000";
                sdram_ba_unbuff <= "00";
                bidir_buff_datain <= x"00";
                busy <= '1';
                write_input_data_reg <= '0';
                data_out_ready <= '0';
                write_cmd_reg <= '0';
                ack <= '0';

            when read_nop_3 =>
                init_counter_clean <= '0';
                refresh_counter_clean <= '0';
                bidir_buff_oe <= '0';
                sdram_control <= com_no_operation;
                sdram_addr_unbuff <= "0000000000000";
                sdram_ba_unbuff <= "00";
                bidir_buff_datain <= x"00";
                busy <= '1';
                write_input_data_reg <= '1';
                data_out_ready <= '0';
                write_cmd_reg <= '0';
                ack <= '0';

            when read_nop_4 =>
                init_counter_clean <= '0';
                refresh_counter_clean <= '0';
                bidir_buff_oe <= '0';
                sdram_control <= com_no_operation;
                sdram_addr_unbuff <= "0000000000000";
                sdram_ba_unbuff <= "00";
                bidir_buff_datain <= x"00";
                busy <= '1';
                write_input_data_reg <= '1';
                data_out_ready <= '0';
                write_cmd_reg <= '0';
                ack <= '0';

            when read_nop_5 =>
                init_counter_clean <= '0';
                refresh_counter_clean <= '0';
                bidir_buff_oe <= '0';
                sdram_control <= com_no_operation;
                sdram_addr_unbuff <= "0000000000000";
                sdram_ba_unbuff <= "00";
                bidir_buff_datain <= x"00";
                busy <= '1';
                write_input_data_reg <= '1';
                data_out_ready <= '0';
                write_cmd_reg <= '0';
                ack <= '0';

            when read_nop_6 =>
                init_counter_clean <= '0';
                refresh_counter_clean <= '0';
                bidir_buff_oe <= '0';
                sdram_control <= com_no_operation;
                sdram_addr_unbuff <= "0000000000000";
                sdram_ba_unbuff <= "00";
                bidir_buff_datain <= x"00";
                busy <= '1';
                write_input_data_reg <= '1';
                data_out_ready <= '0';
                write_cmd_reg <= '0';
                ack <= '0';

            when read_completed =>
                init_counter_clean <= '0';
                refresh_counter_clean <= '0';
                bidir_buff_oe <= '0';
                sdram_control <= com_no_operation;
                sdram_addr_unbuff <= "0000000000000";
                sdram_ba_unbuff <= "00";
                bidir_buff_datain <= x"00";
                busy <= '1';
                write_input_data_reg <= '0';
                data_out_ready <= '1';
                write_cmd_reg <= '0';
                ack <= '0';

        end case;
    end process;
end architecture sdram_driver_arch;
