library ieee;
use ieee.std_logic_1164.all;

entity writer is
    port(
        --system
        clk: in std_logic;
        res: in std_logic;
        --fifo interface
        wrfifo_read: out std_logic;
        wrfifo_dataout: in std_logic_vector(54 downto 0);
        wrfifo_rdempty: in std_logic;    
        --sdram interface
        wr_addr: out std_logic_vector(23 downto 0);
        wr_data: out std_logic_vector(15 downto 0);
        wr_enable: out std_logic;
        busy: in std_logic
    );
end entity writer;

architecture writer_arch of writer is 
    
    --signal for selecting address (1 for addr from fifo +1; 0 otherwise) (also controlling data)
    signal addr_sel: std_logic;
    
    -- this is for FSM that control writing into memory
    type writer_fsm_type is (idle, busy_1, read_from_fifo, write_datareg, write_low, busy_2, write_high, busy_3);
    signal writer_fsm: writer_fsm_type;
    
    -- signal write enable for data reg (contain data form fifo)
    signal we_datafifo: std_logic;
    
    -- this is register contain data from fifo
    signal fifodata: std_logic_vector(54 downto 0);
    
begin

    wr_addr(23 downto 1) <= fifodata(54 downto 32);
    wr_addr(0) <= addr_sel;
    
    wr_data <= fifodata(15 downto 0) when (addr_sel = '0') else fifodata(31 downto 16);

    process(clk) is
        variable data_var: std_logic_vector(54 downto 0);
    begin
        if rising_edge(clk) then
            if res = '1' then
                data_var := (others => '0');
            else
                if we_datafifo = '1' then
                    data_var := wrfifo_dataout;
                end if;
            end if;
        end if;
        fifodata <= data_var;
    end process;
        
    process(clk) is 
    begin
        if rising_edge(clk) then
            if res= '1' then
                writer_fsm <= idle;
            else
                case writer_fsm is
                    when idle => 
                        if wrfifo_rdempty = '0' then
                            if busy = '0' then
                                writer_fsm <= read_from_fifo;
                            else
                                writer_fsm <= busy_1;
                            end if;
                        else
                            writer_fsm <= idle;
                        end if;                        
                    when busy_1 =>
                        if busy = '0' then
                            writer_fsm <= read_from_fifo;
                        else
                            writer_fsm <= busy_1;
                        end if;                        
                    when read_from_fifo =>
                        writer_fsm <= write_datareg;                        
                    when write_datareg =>
                        writer_fsm <= write_low;
                    when write_low =>
                        writer_fsm <= busy_2;
                    when busy_2 =>
                        if busy = '0' then
                            writer_fsm <= write_high;
                        else
                            writer_fsm <= busy_2;
                        end if;                        
                    when write_high =>
                        writer_fsm <= busy_3;                        
                    when busy_3 =>
                        if busy = '0' then
                            writer_fsm <= idle;
                        else
                            writer_fsm <= busy_3;
                        end if;               
                end case;
            end if;
        end if;
    end process;
                        
    process(writer_fsm) is
    begin  
        case writer_fsm is
            when idle =>
                we_datafifo <= '0'; addr_sel <= '0'; wr_enable <= '0'; wrfifo_read <= '0';
            when busy_1 =>
                we_datafifo <= '0'; addr_sel <= '0'; wr_enable <= '0'; wrfifo_read <= '0';
            when read_from_fifo =>
                we_datafifo <= '0'; addr_sel <= '0'; wr_enable <= '0'; wrfifo_read <= '1';            
            when write_datareg =>
                we_datafifo <= '1'; addr_sel <= '0'; wr_enable <= '0'; wrfifo_read <= '0';            
            when write_low =>
                we_datafifo <= '0'; addr_sel <= '0'; wr_enable <= '1'; wrfifo_read <= '0';            
            when busy_2 =>
                we_datafifo <= '0'; addr_sel <= '0'; wr_enable <= '0'; wrfifo_read <= '0';            
            when write_high =>
                we_datafifo <= '0'; addr_sel <= '1'; wr_enable <= '1'; wrfifo_read <= '0';            
            when busy_3 =>
                we_datafifo <= '0'; addr_sel <= '0'; wr_enable <= '0'; wrfifo_read <= '0';
        end case;
    end process;
    
end architecture;
