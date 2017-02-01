library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity transmitter is 
    port(
        clk: in std_logic;
        res: in std_logic;
        baud16_clk_en: in std_logic;
        tx_data: in unsigned(7 downto 0);
        tx: out std_logic;
        tx_intrq: out std_logic;
        send: in std_logic
    );
end entity transmitter;

architecture transmitter_arch of transmitter is
    signal count: unsigned(3 downto 0);
    signal baud_clk_en: std_logic;
    
    type tx_state_type is (idle,sample_data, set_startbit, wait_startbit, set_b0, wait_b0, set_b1, wait_b1,
                      set_b2, wait_b2, set_b3, wait_b3, set_b4, wait_b4, set_b5, wait_b5,
                      set_b6, wait_b6, set_b7, wait_b7, set_stopbit, wait_stopbit, set_flags);
    signal state: tx_state_type;
    
    signal send_reg, send_started: std_logic;
    
    signal shift_data, load_data: std_logic;
    signal sync_counter: std_logic;
begin
    txcounter:
    process(clk, res) is
        variable counter: unsigned(3 downto 0);
    begin
        if rising_edge(clk) then
            if res = '1' then
                counter := (others => '0');
            elsif sync_counter = '1' then
                counter := (others => '0');
            elsif baud16_clk_en = '1' then
                counter := counter + 1;
            end if;
        end if;
        count <= counter;
    end process;
    
    process(count, baud16_clk_en) is
    begin
        if count = x"F" then
            baud_clk_en <= baud16_clk_en;
        else
            baud_clk_en <= '0';
        end if;
    end process;
    
    process(clk, res, send, send_started) is begin
        if rising_edge(clk) then
            if res = '1' then
                send_reg <= '0';
            elsif send_started = '1' then
                send_reg <= '0';
            elsif send = '1' then
                send_reg <= '1';
            end if;
        end if;
    end process;
    
    process(clk, res, baud_clk_en) is begin
        if rising_edge(clk) then
            if res = '1' then
                state <= idle;
            else
                case state is
                    when idle =>
                        if send_reg = '1' then
                            state <= sample_data;
                        else
                            state <= idle;
                        end if;
                    when sample_data => state <= set_startbit;
                    when set_startbit => state <= wait_startbit;
                    when wait_startbit =>
                        if baud_clk_en = '1' then
                            state <= set_b0;
                        else
                            state <= wait_startbit;
                        end if;
                    
                    when set_b0 => state <= wait_b0;
                    when wait_b0 =>
                        if baud_clk_en = '1' then
                            state <= set_b1;
                        else
                            state <= wait_b0;
                        end if;
                        
                    when set_b1 => state <= wait_b1;
                    when wait_b1 =>
                        if baud_clk_en = '1' then
                            state <= set_b2;
                        else
                            state <= wait_b1;
                        end if;
                    
                    when set_b2 => state <= wait_b2;
                    when wait_b2 =>
                        if baud_clk_en = '1' then
                            state <= set_b3;
                        else
                            state <= wait_b2;
                        end if;
                        
                    when set_b3 => state <= wait_b3;
                    when wait_b3 =>
                        if baud_clk_en = '1' then
                            state <= set_b4;
                        else
                            state <= wait_b3;
                        end if;
                    
                    when set_b4 => state <= wait_b4;
                    when wait_b4 =>
                        if baud_clk_en = '1' then
                            state <= set_b5;
                        else
                            state <= wait_b4;
                        end if;
                    
                    when set_b5 => state <= wait_b5;
                    when wait_b5 =>
                        if baud_clk_en = '1' then
                            state <= set_b6;
                        else
                            state <= wait_b5;
                        end if;
                    
                    when set_b6 => state <= wait_b6;
                    when wait_b6 =>
                        if baud_clk_en = '1' then
                            state <= set_b7;
                        else
                            state <= wait_b6;
                        end if;
            
                    when set_b7 => state <= wait_b7;
                    when wait_b7 =>
                        if baud_clk_en = '1' then
                            state <= set_stopbit;
                        else
                            state <= wait_b7;
                        end if;
                        
                    when set_stopbit => state <= wait_stopbit;
                    when wait_stopbit =>
                        if baud_clk_en = '1' then
                            state <= set_flags;
                        else
                            state <= wait_stopbit;
                        end if;
                    
                    when set_flags => state <= idle;
                end case;
            end if;
        end if;
    end process;
    
    process(state) is begin
        case state is 
            when idle  =>
                send_started <= '0'; shift_data <= '0'; load_data <= '0'; tx_intrq <= '0'; sync_counter <= '0';
            when sample_data =>
                send_started <= '1'; shift_data <= '0'; load_data <= '1'; tx_intrq <= '0'; sync_counter <= '0';
            when set_startbit =>
                send_started <= '0'; shift_data <= '1'; load_data <= '0'; tx_intrq <= '0'; sync_counter <= '1';
            when wait_startbit =>
                send_started <= '0'; shift_data <= '0'; load_data <= '0'; tx_intrq <= '0'; sync_counter <= '0';
            when set_b0 =>
                send_started <= '0'; shift_data <= '1'; load_data <= '0'; tx_intrq <= '0'; sync_counter <= '0';
            when wait_b0 =>
                send_started <= '0'; shift_data <= '0'; load_data <= '0'; tx_intrq <= '0'; sync_counter <= '0';
            when set_b1 =>
                send_started <= '0'; shift_data <= '1'; load_data <= '0'; tx_intrq <= '0'; sync_counter <= '0';
            when wait_b1 =>
                send_started <= '0'; shift_data <= '0'; load_data <= '0'; tx_intrq <= '0'; sync_counter <= '0';
            when set_b2 =>
                send_started <= '0'; shift_data <= '1'; load_data <= '0'; tx_intrq <= '0'; sync_counter <= '0';
            when wait_b2 =>
                send_started <= '0'; shift_data <= '0'; load_data <= '0'; tx_intrq <= '0'; sync_counter <= '0';
            when set_b3 =>
                send_started <= '0'; shift_data <= '1'; load_data <= '0'; tx_intrq <= '0'; sync_counter <= '0';
            when wait_b3 =>
                send_started <= '0'; shift_data <= '0'; load_data <= '0'; tx_intrq <= '0'; sync_counter <= '0';
            when set_b4 =>
                send_started <= '0'; shift_data <= '1'; load_data <= '0'; tx_intrq <= '0'; sync_counter <= '0';
            when wait_b4 =>
                send_started <= '0'; shift_data <= '0'; load_data <= '0'; tx_intrq <= '0'; sync_counter <= '0';
            when set_b5 =>
                send_started <= '0'; shift_data <= '1'; load_data <= '0'; tx_intrq <= '0'; sync_counter <= '0';
            when wait_b5 =>
                send_started <= '0'; shift_data <= '0'; load_data <= '0'; tx_intrq <= '0'; sync_counter <= '0';
            when set_b6 =>
                send_started <= '0'; shift_data <= '1'; load_data <= '0'; tx_intrq <= '0'; sync_counter <= '0';
            when wait_b6 =>
                send_started <= '0'; shift_data <= '0'; load_data <= '0'; tx_intrq <= '0'; sync_counter <= '0';
            when set_b7 =>
                send_started <= '0'; shift_data <= '1'; load_data <= '0'; tx_intrq <= '0'; sync_counter <= '0';
            when wait_b7 =>
                send_started <= '0'; shift_data <= '0'; load_data <= '0'; tx_intrq <= '0'; sync_counter <= '0';
            when set_stopbit =>
                send_started <= '0'; shift_data <= '1'; load_data <= '0'; tx_intrq <= '0'; sync_counter <= '0';
            when wait_stopbit =>
                send_started <= '0'; shift_data <= '0'; load_data <= '0'; tx_intrq <= '0'; sync_counter <= '0';
            when set_flags =>
                send_started <= '0'; shift_data <= '0'; load_data <= '0'; tx_intrq <= '1'; sync_counter <= '0';
        end case;
    end process;
    
    process(clk, res, shift_data, load_data) is
        variable data: std_logic_vector(10 downto 0);
    begin
        if rising_edge(clk) then
            if res = '1' then
                data := (others => '1');
            elsif load_data = '1' then
                data := '1' & std_logic_vector(tx_data) & '0' & '1';
            elsif shift_data = '1' then
                data(9 downto 0) := data(10 downto 1);
                data(10) := '1';
            end if;
        end if;
        tx <= data(0);
    end process;
    
end architecture transmitter_arch;