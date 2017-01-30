library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reciever is
    port(
        res: in std_logic;
        clk: in std_logic;
        clk_baud: in std_logic;
        rx: in std_logic;
        rx_int_req: out std_logic;
        rx_data: out unsigned(7 downto 0)
    );
end entity reciever;

architecture reciever_arch of reciever is

    type rx_states is (idle, start, wait_for_sync, sync, wait_b0, sample_b0, wait_b1, sample_b1, wait_b2, sample_b2,
                       wait_b3, sample_b3, wait_b4, sample_b4, wait_b5, sample_b5, wait_b6, sample_b6, wait_b7, sample_b7,
                       stop_bit, set_flags);
    
    signal rx_fsm_state: rx_states;

    signal counter: unsigned(4 downto 0);
    signal reset_counter: std_logic;
    
    signal sipo_reg: unsigned(7 downto 0);
    signal shift_sipo_reg: std_logic;
    
    signal rx_rec_com: std_logic;
    
begin

    process(res, clk, clk_baud, reset_counter) is 
        variable counter_var: unsigned(4 downto 0);
    begin
        if rising_edge(clk) then
            if res = '1'  then
                counter_var := (others => '0');
            elsif reset_counter = '1' then
                counter_var := (others => '0');
            elsif clk_baud = '1' then
                counter_var := counter_var + 1;
            end if;
        end if;
        counter <= counter_var;
    end process;

    process(res, clk, rx, shift_sipo_reg) is begin
        if rising_edge(clk) then
            if res = '1' then
                sipo_reg <= (others => '0');
            elsif shift_sipo_reg = '1' then
                sipo_reg(6 downto 0) <= sipo_reg(7 downto 1);
                sipo_reg(7) <= rx;
            end if;
        end if;
    end process;
    
    process(clk, rx, counter, res) is begin
        if rising_edge(clk) then            
            if res = '1' then 
                rx_fsm_state <= idle;
            else
                case rx_fsm_state is
                    when idle => 
                        if(rx = '0') then
                            rx_fsm_state <= start;
                        else
                            rx_fsm_state <= idle;
                        end if;
                    when start => 
                        rx_fsm_state <= wait_for_sync;
                    when wait_for_sync =>
                        if (counter = "01000") then
                            rx_fsm_state <= sync;
                        else
                            rx_fsm_state <= wait_for_sync;
                        end if;
                    when sync =>
                        rx_fsm_state <= wait_b0;
                    when wait_b0 =>
                        if(counter = "10000") then
                            rx_fsm_state <= sample_b0;
                        else
                            rx_fsm_state <= wait_b0;
                        end if;
                    when sample_b0 =>
                        rx_fsm_state <= wait_b1;
                    when wait_b1 =>
                        if(counter = "10000") then
                            rx_fsm_state <= sample_b1;
                        else
                            rx_fsm_state <= wait_b1;
                        end if;
                    when sample_b1 =>
                        rx_fsm_state <= wait_b2;
                    when wait_b2 =>
                        if(counter = "10000") then
                            rx_fsm_state <= sample_b2;
                        else
                            rx_fsm_state <= wait_b2;
                        end if;
                    when sample_b2 =>
                        rx_fsm_state <= wait_b3;
                    when wait_b3 =>
                        if(counter = "10000") then
                            rx_fsm_state <= sample_b3;
                        else
                            rx_fsm_state <= wait_b3;
                        end if;
                    when sample_b3 =>
                        rx_fsm_state <= wait_b4;
                    when wait_b4 =>
                        if(counter = "10000") then
                            rx_fsm_state <= sample_b4;
                        else
                            rx_fsm_state <= wait_b4;
                        end if;
                    when sample_b4 =>
                        rx_fsm_state <= wait_b5;
                    when wait_b5 =>
                        if(counter = "10000") then
                            rx_fsm_state <= sample_b5;
                        else
                            rx_fsm_state <= wait_b5;
                        end if;
                    when sample_b5 =>
                        rx_fsm_state <= wait_b6;
                    when wait_b6 =>
                        if(counter = "10000") then
                            rx_fsm_state <= sample_b6;
                        else
                            rx_fsm_state <= wait_b6;
                        end if;
                    when sample_b6 =>
                        rx_fsm_state <= wait_b7;
                    when wait_b7 =>
                        if(counter = "10000") then
                            rx_fsm_state <= sample_b7;
                        else
                            rx_fsm_state <= wait_b7;
                        end if;
                    when sample_b7 =>
                        rx_fsm_state <= stop_bit;
                    when stop_bit =>
                        if(counter = "10000") then
                            rx_fsm_state <= set_flags;
                        else
                            rx_fsm_state <= stop_bit;
                        end if;
                    when set_flags =>
                        rx_fsm_state <= idle;
                end case;
            end if;
        end if;
    end process;
    
    process(rx_fsm_state) is begin
        case rx_fsm_state is
            when idle =>
                rx_int_req <= '0'; rx_rec_com <= '0'; shift_sipo_reg <= '0'; reset_counter <= '0';
            when start => 
                rx_int_req <= '0'; rx_rec_com <= '0'; shift_sipo_reg <= '0'; reset_counter <= '1';
            when wait_for_sync =>
                rx_int_req <= '0'; rx_rec_com <= '0'; shift_sipo_reg <= '0'; reset_counter <= '0';
            when sync =>
                rx_int_req <= '0'; rx_rec_com <= '0'; shift_sipo_reg <= '0'; reset_counter <= '1';
            when wait_b0 =>
                rx_int_req <= '0'; rx_rec_com <= '0'; shift_sipo_reg <= '0'; reset_counter <= '0';
            when sample_b0 =>
                rx_int_req <= '0'; rx_rec_com <= '0'; shift_sipo_reg <= '1'; reset_counter <= '1';
            when wait_b1 =>
                rx_int_req <= '0'; rx_rec_com <= '0'; shift_sipo_reg <= '0'; reset_counter <= '0';
            when sample_b1 =>
                rx_int_req <= '0'; rx_rec_com <= '0'; shift_sipo_reg <= '1'; reset_counter <= '1';
            when wait_b2 =>
                rx_int_req <= '0'; rx_rec_com <= '0'; shift_sipo_reg <= '0'; reset_counter <= '0';
            when sample_b2 =>
                rx_int_req <= '0'; rx_rec_com <= '0'; shift_sipo_reg <= '1'; reset_counter <= '1';
            when wait_b3 =>
                rx_int_req <= '0'; rx_rec_com <= '0'; shift_sipo_reg <= '0'; reset_counter <= '0';
            when sample_b3 =>
                rx_int_req <= '0'; rx_rec_com <= '0'; shift_sipo_reg <= '1'; reset_counter <= '1';
            when wait_b4 =>
                rx_int_req <= '0'; rx_rec_com <= '0'; shift_sipo_reg <= '0'; reset_counter <= '0';
            when sample_b4 =>
                rx_int_req <= '0'; rx_rec_com <= '0'; shift_sipo_reg <= '1'; reset_counter <= '1';
            when wait_b5 =>
                rx_int_req <= '0'; rx_rec_com <= '0'; shift_sipo_reg <= '0'; reset_counter <= '0';
            when sample_b5 =>
                rx_int_req <= '0'; rx_rec_com <= '0'; shift_sipo_reg <= '1'; reset_counter <= '1';
            when wait_b6 =>
                rx_int_req <= '0'; rx_rec_com <= '0'; shift_sipo_reg <= '0'; reset_counter <= '0';
            when sample_b6 =>
                rx_int_req <= '0'; rx_rec_com <= '0'; shift_sipo_reg <= '1'; reset_counter <= '1';
            when wait_b7 =>
                rx_int_req <= '0'; rx_rec_com <= '0'; shift_sipo_reg <= '0'; reset_counter <= '0';
            when sample_b7 =>
                rx_int_req <= '0'; rx_rec_com <= '0'; shift_sipo_reg <= '1'; reset_counter <= '1';
            when stop_bit =>
                rx_int_req <= '0'; rx_rec_com <= '0'; shift_sipo_reg <= '0'; reset_counter <= '0';
            when set_flags =>
                rx_int_req <= '1'; rx_rec_com <= '1'; shift_sipo_reg <= '0'; reset_counter <= '0';
        end case;
    end process;
    
    process(res, clk, rx_rec_com) is begin
        if rising_edge(clk) then
            if(res = '1') then
                rx_data <= (others => '0');
            elsif rx_rec_com = '1' then
                rx_data <= sipo_reg;
            end if;
        end if;
    end process;
    
end architecture reciever_arch;
