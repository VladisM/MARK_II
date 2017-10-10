library ieee;
use ieee.std_logic_1164.all;

entity reader is
    port(
        -- system
        clk: in std_logic;
        res: in std_logic;
        -- fifo
        rdfifo_address_q: in std_logic_vector(22 downto 0);
        rdfifo_address_rdempty: in std_logic;
        rdfifo_address_rdreq: out std_logic;    
        rdfifo_data_datain: out std_logic_vector(31 downto 0);
        rdfifo_data_wremty: in std_logic;
        rdfifo_data_wrreq: out std_logic;
        -- sdram
        rd_addr: out std_logic_vector(23 downto 0);
        rd_data: in std_logic_vector(15 downto 0);
        rd_ready: in std_logic;
        rd_enable: out std_logic;
        busy: in std_logic
    );
end entity reader;

architecture reader_arch of reader is
    
    signal wr_data_upp, wr_data_low, wr_addr_reg, addr_sel: std_logic;
    
    type reader_fsm_type is (
        idle, busy_1, read_from_fifo, write_addr_reg, read_low_byte, 
        wait_1, write_data_to_low_reg, read_upp_byte, wait_2, 
        write_data_to_upp_reg, wait_3, write_to_fifo
    );    
    signal reader_fsm: reader_fsm_type;
    
    
begin
    
    --register for data from sdram
    process(clk) is 
        variable data_low_var: std_logic_vector(15 downto 0);
        variable data_upp_var: std_logic_vector(15 downto 0);
    begin
        if rising_edge(clk) then
            if res = '1' then
                data_low_var := (others => '0');
                data_upp_var := (others => '0');
            else
                if wr_data_low = '1' then
                    data_low_var := rd_data;
                end if;
                
                if wr_data_upp = '1' then
                    data_upp_var := rd_data;
                end if;
            end if;
        end if;        
        rdfifo_data_datain <= data_upp_var & data_low_var;        
    end process;
    
    -- register for address
    process(clk, addr_sel) is
        variable addr_var: std_logic_vector(22 downto 0);
    begin
        if rising_edge(clk) then
            if res = '1' then
                addr_var := (others => '0');
            else
                if wr_addr_reg = '1' then
                    addr_var := rdfifo_address_q;
                end if;
            end if;
            
        end if;
        rd_addr <= addr_var & addr_sel;
    end process;
        
    process(clk) is
    begin
        if rising_edge(clk) then 
            if res = '1' then
                reader_fsm <= idle;
            else
                case reader_fsm is
                    when idle =>                     
                        if rdfifo_address_rdempty = '0' then
                            if busy = '1' then
                                reader_fsm <= busy_1;
                            else
                                reader_fsm <= read_from_fifo;
                            end if;
                        else
                            reader_fsm <= idle;
                        end if;                        
                    when busy_1 => 
                        if busy = '1' then
                            reader_fsm <= busy_1;
                        else
                            reader_fsm <= read_from_fifo;
                        end if;
                    when read_from_fifo => 
                        reader_fsm <= write_addr_reg;
                    when write_addr_reg => 
                        reader_fsm <= read_low_byte;
                    when read_low_byte => 
                        reader_fsm <= wait_1;
                    when wait_1 => 
                        if rd_ready = '1' then
                            reader_fsm <= write_data_to_low_reg;
                        else
                            reader_fsm <= wait_1;
                        end if;
                    when write_data_to_low_reg => 
                        reader_fsm <= read_upp_byte;
                    when read_upp_byte => 
                        reader_fsm <= wait_2;                    
                    when wait_2 => 
                        if rd_ready = '1' then
                            reader_fsm <= write_data_to_upp_reg;
                        else
                            reader_fsm <= wait_2;
                        end if;
                    when write_data_to_upp_reg => 
                        reader_fsm <= wait_3;
                    when wait_3 =>
                        if rdfifo_data_wremty = '1' then
                            reader_fsm <= write_to_fifo;
                        else
                            reader_fsm <= wait_3;
                        end if;
                    when write_to_fifo => 
                        reader_fsm <= idle;
                end case;
            end if;
        end if;
    end process;
    
    process(reader_fsm) is
    begin
        case reader_fsm is
            when idle =>  
                rd_enable <= '0'; rdfifo_data_wrreq <= '0'; rdfifo_address_rdreq <= '0';
                wr_data_upp <= '0'; wr_data_low <= '0'; wr_addr_reg <= '0'; addr_sel <= '0';
                
            when busy_1 =>   
                rd_enable <= '0'; rdfifo_data_wrreq <= '0'; rdfifo_address_rdreq <= '0';
                wr_data_upp <= '0'; wr_data_low <= '0'; wr_addr_reg <= '0'; addr_sel <= '0';
                
            when read_from_fifo =>   
                rd_enable <= '0'; rdfifo_data_wrreq <= '0'; rdfifo_address_rdreq <= '1';
                wr_data_upp <= '0'; wr_data_low <= '0'; wr_addr_reg <= '0'; addr_sel <= '0';
                
            when write_addr_reg =>   
                rd_enable <= '0'; rdfifo_data_wrreq <= '0'; rdfifo_address_rdreq <= '0';
                wr_data_upp <= '0'; wr_data_low <= '0'; wr_addr_reg <= '1'; addr_sel <= '0';
                
            when read_low_byte =>   
                rd_enable <= '1'; rdfifo_data_wrreq <= '0'; rdfifo_address_rdreq <= '0';
                wr_data_upp <= '0'; wr_data_low <= '0'; wr_addr_reg <= '0'; addr_sel <= '0';
                
            when wait_1 =>   
                rd_enable <= '0'; rdfifo_data_wrreq <= '0'; rdfifo_address_rdreq <= '0';
                wr_data_upp <= '0'; wr_data_low <= '0'; wr_addr_reg <= '0'; addr_sel <= '0';
                
            when write_data_to_low_reg =>   
                rd_enable <= '0'; rdfifo_data_wrreq <= '0'; rdfifo_address_rdreq <= '0';
                wr_data_upp <= '0'; wr_data_low <= '1'; wr_addr_reg <= '0'; addr_sel <= '0';
                
            when read_upp_byte =>   
                rd_enable <= '1'; rdfifo_data_wrreq <= '0'; rdfifo_address_rdreq <= '0';
                wr_data_upp <= '0'; wr_data_low <= '0'; wr_addr_reg <= '0'; addr_sel <= '1';
                
            when wait_2 =>   
                rd_enable <= '0'; rdfifo_data_wrreq <= '0'; rdfifo_address_rdreq <= '0';
                wr_data_upp <= '0'; wr_data_low <= '0'; wr_addr_reg <= '0'; addr_sel <= '0';
                
            when write_data_to_upp_reg =>   
                rd_enable <= '0'; rdfifo_data_wrreq <= '0'; rdfifo_address_rdreq <= '0';
                wr_data_upp <= '1'; wr_data_low <= '0'; wr_addr_reg <= '0'; addr_sel <= '0';
                
            when wait_3 =>   
                rd_enable <= '0'; rdfifo_data_wrreq <= '0'; rdfifo_address_rdreq <= '0';
                wr_data_upp <= '0'; wr_data_low <= '0'; wr_addr_reg <= '0'; addr_sel <= '0';
                
            when write_to_fifo =>   
                rd_enable <= '0'; rdfifo_data_wrreq <= '1'; rdfifo_address_rdreq <= '0';
                wr_data_upp <= '0'; wr_data_low <= '0'; wr_addr_reg <= '0'; addr_sel <= '0';
        end case;        
    end process;
    
end architecture reader_arch;
