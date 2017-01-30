library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity transmitter is
    port(
        res: in std_logic;
        clk: in std_logic;
        clk_baud: in std_logic;
        tx_data: in unsigned(7 downto 0);
        tx_send: in std_logic;
        tx_int_req: out std_logic;
        tx: out std_logic
    );
end entity transmitter;

architecture transmitter_arch of transmitter is 
    
    component int_fsm is
        port(
            clk: in std_logic;
            res: in std_logic;
            int_raw: in std_logic;
            intrq: out std_logic
        );
    end component int_fsm;

    
    --for FSM 
    type tx_states is (idle, start_bit, resstartbit, b0, resb0, b1, resb1, b2, resb2, b3, resb3, b4, resb4, b5, resb5, b6, resb6, b7, resb7, stop_bit, resstopbit);
    signal tx_state: tx_states;
    
    signal sel: std_logic_vector(3 downto 0);     -- this is select signal for output mux
    signal send_started: std_logic;      -- this will reset RS ff for holding "send" input
    signal send_reg: std_logic;
    
    signal intrq: std_logic;
    
    signal counter: unsigned(4 downto 0);
    signal reset_counter: std_logic;
    
    
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
    process(res, clk_baud, clk) is begin
        if rising_edge(clk) then
            if res = '1' then
                tx_state <= idle;
            else
                case tx_state is
                
                    when idle =>
                        if send_reg = '1' then
                            tx_state <= start_bit;
                        else
                            tx_state <= idle;
                        end if;
                        
                    when start_bit => 
                        if(counter = "10000") then
                            tx_state <= resstartbit;
                        else
                            tx_state <= start_bit;
                        end if;
                    when resstartbit => tx_state <= b0;
                    
                    when b0 => 
                        if(counter = "10000") then
                            tx_state <= resb0;
                        else
                            tx_state <= b0;
                        end if;
                    when resb0 => tx_state <= b1;
                    
                    when b1 => 
                        if(counter = "10000") then
                            tx_state <= resb1;
                        else
                            tx_state <= b1;
                        end if;
                    when resb1 => tx_state <= b2;
                    
                    when b2 => 
                        if(counter = "10000") then
                            tx_state <= resb2;
                        else
                            tx_state <= b2;
                        end if;
                    when resb2 => tx_state <= b3;
                    
                    when b3 => 
                        if(counter = "10000") then
                            tx_state <= resb3;
                        else
                            tx_state <= b3;
                        end if;
                    when resb3 => tx_state <= b4;
                    
                    when b4 => 
                        if(counter = "10000") then
                            tx_state <= resb4;
                        else
                            tx_state <= b4;
                        end if;
                    when resb4 => tx_state <= b5;
                    
                    when b5 => 
                        if(counter = "10000") then
                            tx_state <= resb5;
                        else
                            tx_state <= b5;
                        end if;
                    when resb5 => tx_state <= b6;
                    
                    when b6 => 
                        if(counter = "10000") then
                            tx_state <= resb6;
                        else
                            tx_state <= b6;
                        end if;
                    when resb6 => tx_state <= b7;
                    
                    when b7 => 
                        if(counter = "10000") then
                            tx_state <= resb7;
                        else
                            tx_state <= b7;
                        end if;
                    when resb7 => tx_state <= stop_bit;
                    
                    when stop_bit => 
                        if(counter = "10000") then
                            tx_state <= resstopbit;
                        else
                            tx_state <= stop_bit;
                        end if;
                    when resstopbit => tx_state <= idle;
                    
                end case;
            end if;
        end if;
    end process;
    
    --output functions
    process(tx_state) is begin
        case tx_state is
            when idle =>
                sel <= x"0"; intrq <= '0'; send_started <= '0'; reset_counter <= '0';
            when start_bit =>
                sel <= x"9"; intrq <= '0'; send_started <= '1'; reset_counter <= '0';
            when b0 =>
                sel <= x"1"; intrq <= '0'; send_started <= '0'; reset_counter <= '0';
            when b1 =>
                sel <= x"2"; intrq <= '0'; send_started <= '0'; reset_counter <= '0';
            when b2 =>
                sel <= x"3"; intrq <= '0'; send_started <= '0'; reset_counter <= '0';
            when b3 =>
                sel <= x"4"; intrq <= '0'; send_started <= '0'; reset_counter <= '0';
            when b4 =>
                sel <= x"5"; intrq <= '0'; send_started <= '0'; reset_counter <= '0';
            when b5 =>
                sel <= x"6"; intrq <= '0'; send_started <= '0'; reset_counter <= '0';
            when b6 =>
                sel <= x"7"; intrq <= '0'; send_started <= '0'; reset_counter <= '0';
            when b7 =>
                sel <= x"8"; intrq <= '0'; send_started <= '0'; reset_counter <= '0';
            when stop_bit =>
                sel <= x"0"; intrq <= '1'; send_started <= '0'; reset_counter <= '0';            
            when resstartbit =>
                sel <= x"9"; intrq <= '0'; send_started <= '0'; reset_counter <= '1';
            when resb0 =>
                sel <= x"1"; intrq <= '0'; send_started <= '0'; reset_counter <= '1';
            when resb1 =>
                sel <= x"2"; intrq <= '0'; send_started <= '0'; reset_counter <= '1';
            when resb2 =>
                sel <= x"3"; intrq <= '0'; send_started <= '0'; reset_counter <= '1';
            when resb3 =>
                sel <= x"4"; intrq <= '0'; send_started <= '0'; reset_counter <= '1';
            when resb4 =>
                sel <= x"5"; intrq <= '0'; send_started <= '0'; reset_counter <= '1';
            when resb5 =>
                sel <= x"6"; intrq <= '0'; send_started <= '0'; reset_counter <= '1';
            when resb6 =>
                sel <= x"7"; intrq <= '0'; send_started <= '0'; reset_counter <= '1';
            when resb7 =>
                sel <= x"8"; intrq <= '0'; send_started <= '0'; reset_counter <= '1';
            when resstopbit =>
                sel <= x"0"; intrq <= '0'; send_started <= '0'; reset_counter <= '1';
        end case;
    end process;
    
    --RSff for "send" input
    process(clk, res, tx_send, send_started) is begin
        if rising_edge(clk) then
            if (res or send_started) = '1' then
                send_reg <= '0';
            elsif tx_send = '1' then
                send_reg <= '1';
            end if;
        end if;
    end process;
    
    int_fsm0: int_fsm
        port map(clk, res, intrq, tx_int_req);
    
end architecture transmitter_arch;
