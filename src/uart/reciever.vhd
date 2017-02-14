library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reciever is
    port(
        clk: in std_logic;
        res: in std_logic;
        rx: in std_logic;
        baud16_clk_en: in std_logic;
        rx_data: out unsigned(7 downto 0);
        rx_intrq: out std_logic
    );
end entity reciever;

architecture reciever_arch of reciever is
    
    type tx_state_type is (idle, start_sync, wait_for_sync, sync, wait_b0, get_b0, wait_b1, get_b1,wait_b2, get_b2,
                           wait_b3, get_b3,wait_b4, get_b4,wait_b5, get_b5,wait_b6, get_b6,wait_b7, get_b7,
                           wait_stopbit, store_data);
    
    signal state: tx_state_type; -- state for RX FSM
    
    signal sipo_val: unsigned(7 downto 0);
    signal rx_rec_com, res_counter, shift_sipo_reg: std_logic; -- control signals for RX FSM
    signal baud_clk_en: std_logic; -- this is an baud clock
    signal count: unsigned(3 downto 0); -- this is rx counter value 
    
    
begin

    sipo_reg:
    process(res, clk, rx, shift_sipo_reg) is 
        variable sipo_var: unsigned(7 downto 0);
    begin
        if rising_edge(clk) then
            if res = '1' then
                sipo_var := (others => '0');
            elsif shift_sipo_reg = '1' then
                sipo_var(6 downto 0) := sipo_var(7 downto 1);
                sipo_var(7) := rx;
            end if;
        end if;
        sipo_val <= sipo_var;
    end process;
    
    rx_out_reg:
    process(res, clk, rx_rec_com) is 
        variable out_reg: unsigned(7 downto 0);
    begin
        if rising_edge(clk) then
            if(res = '1') then
                out_reg := (others => '0');
            elsif rx_rec_com = '1' then
                out_reg := sipo_val;
            end if;
        end if;
        rx_data <= out_reg;
    end process;
    
    rxcounter:
    process(clk, res) is
        variable counter: unsigned(3 downto 0);
    begin
        if rising_edge(clk) then
            if res = '1' then
                counter := (others => '0');
            elsif res_counter = '1' then
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
    
    process(clk, res, count, baud_clk_en, rx) is
    begin
        if rising_edge(clk) then
            if res = '1' then
                state <= idle;
            else
                case state is
                    when idle =>
                        if rx = '0' then
                            state <= start_sync;
                        else
                            state <= idle;
                        end if;
                        
                    when start_sync => state <= wait_for_sync;    
                        
                    when wait_for_sync =>
                        if count = "0111" then
                            state <= sync;
                        else
                            state <= wait_for_sync;
                        end if;
                    when sync => state <= wait_b0;
                    
                    when wait_b0 =>
                        if baud_clk_en = '1' then 
                            state <= get_b0;
                        else
                            state <= wait_b0;
                        end if;
                    when get_b0 => state <= wait_b1;
                    
                    when wait_b1 =>
                        if baud_clk_en = '1' then 
                            state <= get_b1;
                        else
                            state <= wait_b1;
                        end if;
                    when get_b1 => state <= wait_b2;
                    
                    when wait_b2 =>
                        if baud_clk_en = '1' then 
                            state <= get_b2;
                        else
                            state <= wait_b2;
                        end if;
                    when get_b2 => state <= wait_b3;
                    
                    when wait_b3 =>
                        if baud_clk_en = '1' then 
                            state <= get_b3;
                        else
                            state <= wait_b3;
                        end if;
                    when get_b3 => state <= wait_b4;
                    
                    when wait_b4 =>
                        if baud_clk_en = '1' then 
                            state <= get_b4;
                        else
                            state <= wait_b4;
                        end if;
                    when get_b4 => state <= wait_b5;
                    
                    when wait_b5 =>
                        if baud_clk_en = '1' then 
                            state <= get_b5;
                        else
                            state <= wait_b5;
                        end if;
                    when get_b5 => state <= wait_b6;
                    
                    when wait_b6 =>
                        if baud_clk_en = '1' then 
                            state <= get_b6;
                        else
                            state <= wait_b6;
                        end if;
                    when get_b6 => state <= wait_b7;
                    
                    when wait_b7 =>
                        if baud_clk_en = '1' then 
                            state <= get_b7;
                        else
                            state <= wait_b7;
                        end if;
                    when get_b7 => state <= wait_stopbit;
                    
                    when wait_stopbit =>
                        if baud_clk_en = '1' then 
                            state <= store_data;
                        else
                            state <= wait_stopbit;
                        end if;
                    when store_data => state <= idle;
                end case;
            end if;
        end if;
    end process;
    
    process(state) is
    begin
        case state is 
            when idle =>            rx_rec_com <= '0'; res_counter <= '0'; shift_sipo_reg <= '0'; rx_intrq <= '0';
            when start_sync =>      rx_rec_com <= '0'; res_counter <= '1'; shift_sipo_reg <= '0'; rx_intrq <= '0';
            when wait_for_sync =>   rx_rec_com <= '0'; res_counter <= '0'; shift_sipo_reg <= '0'; rx_intrq <= '0';
            when sync =>            rx_rec_com <= '0'; res_counter <= '1'; shift_sipo_reg <= '0'; rx_intrq <= '0';
            when wait_b0 =>         rx_rec_com <= '0'; res_counter <= '0'; shift_sipo_reg <= '0'; rx_intrq <= '0';
            when get_b0 =>          rx_rec_com <= '0'; res_counter <= '0'; shift_sipo_reg <= '1'; rx_intrq <= '0';
            when wait_b1 =>         rx_rec_com <= '0'; res_counter <= '0'; shift_sipo_reg <= '0'; rx_intrq <= '0';
            when get_b1 =>          rx_rec_com <= '0'; res_counter <= '0'; shift_sipo_reg <= '1'; rx_intrq <= '0';
            when wait_b2 =>         rx_rec_com <= '0'; res_counter <= '0'; shift_sipo_reg <= '0'; rx_intrq <= '0';
            when get_b2 =>          rx_rec_com <= '0'; res_counter <= '0'; shift_sipo_reg <= '1'; rx_intrq <= '0';
            when wait_b3 =>         rx_rec_com <= '0'; res_counter <= '0'; shift_sipo_reg <= '0'; rx_intrq <= '0';
            when get_b3 =>          rx_rec_com <= '0'; res_counter <= '0'; shift_sipo_reg <= '1'; rx_intrq <= '0';
            when wait_b4 =>         rx_rec_com <= '0'; res_counter <= '0'; shift_sipo_reg <= '0'; rx_intrq <= '0';
            when get_b4 =>          rx_rec_com <= '0'; res_counter <= '0'; shift_sipo_reg <= '1'; rx_intrq <= '0';
            when wait_b5 =>         rx_rec_com <= '0'; res_counter <= '0'; shift_sipo_reg <= '0'; rx_intrq <= '0';
            when get_b5 =>          rx_rec_com <= '0'; res_counter <= '0'; shift_sipo_reg <= '1'; rx_intrq <= '0';
            when wait_b6 =>         rx_rec_com <= '0'; res_counter <= '0'; shift_sipo_reg <= '0'; rx_intrq <= '0';
            when get_b6 =>          rx_rec_com <= '0'; res_counter <= '0'; shift_sipo_reg <= '1'; rx_intrq <= '0';
            when wait_b7 =>         rx_rec_com <= '0'; res_counter <= '0'; shift_sipo_reg <= '0'; rx_intrq <= '0';
            when get_b7 =>          rx_rec_com <= '0'; res_counter <= '0'; shift_sipo_reg <= '1'; rx_intrq <= '0';
            when wait_stopbit =>    rx_rec_com <= '0'; res_counter <= '0'; shift_sipo_reg <= '0'; rx_intrq <= '0';
            when store_data =>      rx_rec_com <= '1'; res_counter <= '0'; shift_sipo_reg <= '0'; rx_intrq <= '1';
        end case;
    end process;
    
end architecture reciever_arch;