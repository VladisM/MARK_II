library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ps2core is 
    port(
        clk: in std_logic;
        res: in std_logic;
        byte_out: out unsigned(7 downto 0);
        byte_recieved: out std_logic;
        ps2clk: in std_logic;
        ps2dat: in std_logic
    );
end entity ps2core;

architecture ps2core_arch of ps2core is
    
    type statetype is (
        idle, start_bit, wait0, sample0, wait1, sample1, wait2, sample2, wait3, sample3,
        wait4, sample4, wait5, sample5, wait6, sample6, wait7, sample7, wait_parity, sample_parity, interrupt
    );
    signal ps2_state: statetype;

    signal ps2clk_synch, ps2dat_synch: std_logic;
    signal sample_dat: std_logic;
    signal ps2clk_fall: std_logic;
    
begin
    
    process(clk, res, ps2clk, ps2dat) is 
        variable ps2clk_var: std_logic_vector(1 downto 0);
        variable ps2dat_var: std_logic_vector(1 downto 0);
    begin
        if rising_edge(clk) then
            if res = '1' then
                ps2clk_var := "11";
                ps2dat_var := "11";
            else
                ps2dat_var(1) := ps2dat_var(0);
                ps2dat_var(0) := ps2dat;       
                
                ps2clk_var(1) := ps2clk_var(0);
                ps2clk_var(0) := ps2clk;
            end if;
        end if;
        ps2clk_synch <= ps2clk_var(1);
        ps2dat_synch <= ps2dat_var(1);
    end process;
    
    sipo_shift_reg:
    process(clk, res, ps2dat_synch, sample_dat) is
        variable data_reg: unsigned(8 downto 0);
    begin
        if rising_edge(clk) then
            if res = '1' then
                data_reg := (others => '0');
            elsif sample_dat = '1' then 
                data_reg(7 downto 0) := data_reg(8 downto 1);
                data_reg(8) := ps2dat_synch;
            end if;
        end if;
        byte_out <= data_reg(7 downto 0);
    end process; 
    
    ps2clk_fall_detec:
    process(clk, res, ps2clk_synch) is
        variable counter: std_logic_vector(1 downto 0);
    begin
        if rising_edge(clk) then
            if res = '1' then
                counter := "00";
            else
                counter(1) := counter(0);
                counter(0) := ps2clk_synch;
            end if;
        end if; 
        
        ps2clk_fall <= counter(1) and not(counter(0));
    end process;
    
    FSM_transit_functions:
    process(clk, res, ps2dat_synch, ps2clk_fall) is
    begin
        if rising_edge(clk) then
            if res = '1' then
                ps2_state <= idle;
            else
                case ps2_state is
                    when idle =>
                        if ps2clk_fall = '1' and ps2dat_synch = '0' then
                            ps2_state <= start_bit;
                        else
                            ps2_state <= idle;
                        end if;
                    when start_bit =>
                        ps2_state <= wait0;
                    
                    when wait0 => 
                        if ps2clk_fall = '1' then
                            ps2_state <= sample0;
                        else
                            ps2_state <= wait0;
                        end if;    
                    when sample0 =>
                        ps2_state <= wait1;
                        
                    when wait1 => 
                        if ps2clk_fall = '1' then
                            ps2_state <= sample1;
                        else
                            ps2_state <= wait1;
                        end if;    
                    when sample1 =>
                        ps2_state <= wait2;    
                    
                    when wait2 => 
                        if ps2clk_fall = '1' then
                            ps2_state <= sample2;
                        else
                            ps2_state <= wait2;
                        end if;    
                    when sample2 =>
                        ps2_state <= wait3;
                        
                    when wait3 => 
                        if ps2clk_fall = '1' then
                            ps2_state <= sample3;
                        else
                            ps2_state <= wait3;
                        end if;    
                    when sample3 =>
                        ps2_state <= wait4;
                        
                    when wait4 => 
                        if ps2clk_fall = '1' then
                            ps2_state <= sample4;
                        else
                            ps2_state <= wait4;
                        end if;    
                    when sample4 =>
                        ps2_state <= wait5;
                        
                    when wait5 => 
                        if ps2clk_fall = '1' then
                            ps2_state <= sample5;
                        else
                            ps2_state <= wait5;
                        end if;    
                    when sample5 =>
                        ps2_state <= wait6;
                    
                    when wait6 => 
                        if ps2clk_fall = '1' then
                            ps2_state <= sample6;
                        else
                            ps2_state <= wait6;
                        end if;    
                    when sample6 =>
                        ps2_state <= wait7;
                    
                    when wait7 => 
                        if ps2clk_fall = '1' then
                            ps2_state <= sample7;
                        else
                            ps2_state <= wait7;
                        end if;    
                    when sample7 =>
                        ps2_state <= wait_parity;
                    
                    when wait_parity =>
                        if ps2clk_fall = '1' then
                            ps2_state <= sample_parity;
                        else
                            ps2_state <= wait_parity;
                        end if;
                    when sample_parity =>
                        ps2_state <= interrupt;
                    when interrupt =>
                        ps2_state <= idle;
                end case;
            end if;
        end if;
    end process;
    
    FSM_output_functions:
    process(ps2_state) is 
    begin
        case ps2_state is            
            when idle          => byte_recieved <= '0'; sample_dat <= '0'; 
            when start_bit     => byte_recieved <= '0'; sample_dat <= '0'; 
            when wait0         => byte_recieved <= '0'; sample_dat <= '0'; 
            when sample0       => byte_recieved <= '0'; sample_dat <= '1'; 
            when wait1         => byte_recieved <= '0'; sample_dat <= '0'; 
            when sample1       => byte_recieved <= '0'; sample_dat <= '1'; 
            when wait2         => byte_recieved <= '0'; sample_dat <= '0'; 
            when sample2       => byte_recieved <= '0'; sample_dat <= '1'; 
            when wait3         => byte_recieved <= '0'; sample_dat <= '0'; 
            when sample3       => byte_recieved <= '0'; sample_dat <= '1'; 
            when wait4         => byte_recieved <= '0'; sample_dat <= '0'; 
            when sample4       => byte_recieved <= '0'; sample_dat <= '1'; 
            when wait5         => byte_recieved <= '0'; sample_dat <= '0'; 
            when sample5       => byte_recieved <= '0'; sample_dat <= '1'; 
            when wait6         => byte_recieved <= '0'; sample_dat <= '0'; 
            when sample6       => byte_recieved <= '0'; sample_dat <= '1'; 
            when wait7         => byte_recieved <= '0'; sample_dat <= '0'; 
            when sample7       => byte_recieved <= '0'; sample_dat <= '1'; 
            when wait_parity   => byte_recieved <= '0'; sample_dat <= '0'; 
            when sample_parity => byte_recieved <= '0'; sample_dat <= '1'; 
            when interrupt     => byte_recieved <= '1'; sample_dat <= '0'; 
        end case;
    end process;
    
end architecture ps2core_arch;