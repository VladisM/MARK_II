-- Transmitter for UART from MARK II project
--
-- this transmitter supports only 8N1 format
-- and doesn't support FIFO buffer
--
-- tx_data      - byte to send
-- tx_send      - start sending with this signal
-- tx_int_req   - interrupt request when transmitting is completed
-- tx_busy_flag - signalization of transmitting
-- tx           - this is output TX pin 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity transmitter is
    port(
        res: in std_logic;
        clk_baud: in std_logic;
        tx_data: in unsigned(7 downto 0);
        tx_send: in std_logic;
        tx_int_req: out std_logic;
        tx_busy_flag: out std_logic;
        tx: out std_logic
    );
end entity transmitter;

architecture transmitter_arch of transmitter is 
    
    --for FSM 
    type tx_states is (idle, start_bit, b0, b1, b2, b3, b4, b5, b6, b7, stop_bit);
    signal tx_state: tx_states;
    
    signal sel_asyn, sel: std_logic_vector(3 downto 0);     -- this is select signal for output mux
    signal tx_int_req_asyn, tx_busy_flag_asyn: std_logic;   -- this is usefull for make output synchronous
    signal send_started_asyn, send_started: std_logic;      -- this will reset RS ff for holding "send" input
    signal send_reg: std_logic;
    
begin

    --this is output value selector
    process(sel, tx_data) is begin
        case sel is
            when x"0" => tx <= '1';
            when x"1" => tx <= std_logic(tx_data(0));
            when x"2" => tx <= std_logic(tx_data(1));
            when x"3" => tx <= std_logic(tx_data(2));
            when x"4" => tx <= std_logic(tx_data(3));
            when x"5" => tx <= std_logic(tx_data(4));
            when x"6" => tx <= std_logic(tx_data(5));
            when x"7" => tx <= std_logic(tx_data(6));
            when x"8" => tx <= std_logic(tx_data(7));
            when x"9" => tx <= '0';
            when others => tx <= '-';
        end case;
    end process;
    
    -- logic for solving next state
    process(res, clk_baud) is begin
        if res = '1' then
            tx_state <= idle;
        elsif rising_edge(clk_baud) then
            case tx_state is
                when idle =>
                    if send_reg = '1' then
                        tx_state <= start_bit;
                    else
                        tx_state <= idle;
                    end if;
                when start_bit => tx_state <= b0;
                when b0 => tx_state <= b1;
                when b1 => tx_state <= b2;
                when b2 => tx_state <= b3;
                when b3 => tx_state <= b4;
                when b4 => tx_state <= b5;
                when b5 => tx_state <= b6;
                when b6 => tx_state <= b7;
                when b7 => tx_state <= stop_bit;
                when stop_bit => tx_state <= idle;
            end case;
        end if;
    end process;
    
    --output functions
    process(tx_state) is begin
        case tx_state is
            when idle =>
                sel_asyn <= x"0"; tx_busy_flag_asyn <= '0'; tx_int_req_asyn <= '0'; send_started_asyn <= '0';
            when start_bit =>
                sel_asyn <= x"9"; tx_busy_flag_asyn <= '1'; tx_int_req_asyn <= '0'; send_started_asyn <= '1';
            when b0 =>
                sel_asyn <= x"1"; tx_busy_flag_asyn <= '1'; tx_int_req_asyn <= '0'; send_started_asyn <= '0';
            when b1 =>
                sel_asyn <= x"2"; tx_busy_flag_asyn <= '1'; tx_int_req_asyn <= '0'; send_started_asyn <= '0';
            when b2 =>
                sel_asyn <= x"3"; tx_busy_flag_asyn <= '1'; tx_int_req_asyn <= '0'; send_started_asyn <= '0';
            when b3 =>
                sel_asyn <= x"4"; tx_busy_flag_asyn <= '1'; tx_int_req_asyn <= '0'; send_started_asyn <= '0';
            when b4 =>
                sel_asyn <= x"5"; tx_busy_flag_asyn <= '1'; tx_int_req_asyn <= '0'; send_started_asyn <= '0';
            when b5 =>
                sel_asyn <= x"6"; tx_busy_flag_asyn <= '1'; tx_int_req_asyn <= '0'; send_started_asyn <= '0';
            when b6 =>
                sel_asyn <= x"7"; tx_busy_flag_asyn <= '1'; tx_int_req_asyn <= '0'; send_started_asyn <= '0';
            when b7 =>
                sel_asyn <= x"8"; tx_busy_flag_asyn <= '1'; tx_int_req_asyn <= '0'; send_started_asyn <= '0';
            when stop_bit =>
                sel_asyn <= x"0"; tx_busy_flag_asyn <= '1'; tx_int_req_asyn <= '1'; send_started_asyn <= '0';
        end case;
    end process;
    
    --make outputs from FSM synchronous
    process(res, clk_baud, sel_asyn, tx_busy_flag_asyn, tx_int_req_asyn) is begin
        if res = '1' then
            sel <= x"0";
            tx_busy_flag <= '0';
            tx_int_req <= '0';
            send_started <= '0';
        elsif falling_edge(clk_baud) then
            sel <= sel_asyn;
            tx_busy_flag <= tx_busy_flag_asyn;
            tx_int_req <= tx_int_req_asyn;
            send_started <= send_started_asyn;
        end if;
    end process;
    
    --RSff for "send" input
    process(res, tx_send, send_started) is begin
        if (res or send_started) = '1' then
            send_reg <= '0';
        elsif rising_edge(tx_send) then
            send_reg <= '1';
        end if;
    end process;
    
end architecture transmitter_arch;
