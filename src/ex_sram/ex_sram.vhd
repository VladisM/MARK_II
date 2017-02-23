library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ex_sram is 
    generic(
        BASE_ADDRESS: unsigned(23 downto 0) := x"000000"
    );
    port(
        clk: in std_logic;
        res: in std_logic;
        address: in unsigned(23 downto 0);
        data_mosi: in unsigned(31 downto 0);
        data_miso: out unsigned(31 downto 0); 
        WR: in std_logic;
        RD: in std_logic;
        ack: out std_logic;
        --device
        sram_address: out unsigned(17 downto 0);
        sram_data: inout unsigned(15 downto 0);
        sram_oe: out std_logic;
        sram_we: out std_logic
    );
end entity ex_sram;

architecture ex_sram_arch of ex_sram is

    signal cs: std_logic;
    
    --control signals for registers
    signal loadadd, incadd: std_logic;
    signal wordsel, datain_oe, datain_wr: std_logic;
    signal wr_high, wr_low, dataout_oe: std_logic;
    
    type statetype is (idle, write0, write1, write2, write3, write4, read0, read1, read2);
    signal state: statetype;
    
    signal selected: unsigned(15 downto 0);
    signal datamosi_reg: unsigned(31 downto 0);
    signal dataout: unsigned(31 downto 0);
begin

    add_reg:
    process(clk, res, loadadd, incadd, address) is 
        variable address_v: unsigned(17 downto 0);
    begin
        if rising_edge(clk) then
            if res = '1' then 
                address_v := (others => '0');
            elsif loadadd = '1' then
                address_v := address(16 downto 0) & '0';
            elsif incadd = '1' then
                address_v := address_v(17 downto 1) & '1';
            end if;
        end if;
        sram_address <= address_v;
    end process;
    
    datain_reg:
    process(clk, res, wordsel, datain_oe, datain_wr,  data_mosi) is
        variable datamosi_v: unsigned(31 downto 0);
    begin
        if rising_edge(clk) then
            if res = '1' then
                datamosi_v := (others => '0');
            elsif datain_wr = '1' then
                datamosi_v := data_mosi;
            end if;
        end if;
       
       datamosi_reg <= datamosi_v;
       
    end process;
    
    with wordsel select selected <= datamosi_reg(31 downto 16) when '1', datamosi_reg(15 downto 0) when others;
    
    with datain_oe select sram_data <= selected when '1', (others => 'Z') when others;
    
    dataout_high_reg:
    process(clk, res, wr_high, wr_low, dataout_oe, sram_data) is
        variable dataout_high_v: unsigned(15 downto 0);
    begin        
        if rising_edge(clk) then
            if res = '1' then
                dataout_high_v := (others => '0');
            elsif wr_high = '1' then
                dataout_high_v := sram_data;
            end if;
        end if;
        
        dataout(31 downto 16) <= dataout_high_v;
    end process;
    
    dataout_low_reg:
    process(clk, res, wr_high, wr_low, dataout_oe, sram_data) is
        variable dataout_low_v: unsigned(15 downto 0);
    begin
        if rising_edge(clk) then
            if res = '1' then
                dataout_low_v := (others => '0');            
            elsif wr_low = '1' then
                dataout_low_v := sram_data;
            end if;
        end if;
        
        dataout(15 downto 0) <= dataout_low_v;
    end process;
    
    
    with dataout_oe select data_miso <= dataout when '1', (others => 'Z') when others;
    
    address_decoder:
    process(address) is begin
        if (address >= BASE_ADDRESS and address <= (BASE_ADDRESS + 2**17 - 1)) then
            cs <= '1';
        else
            cs <= '0';
        end if;
    end process;
    
    process(clk, res, WR, RD, cs) is
    begin
        if(rising_edge(clk)) then
            if res = '1' then 
                state <= idle;
            else
                case state is
                    when idle =>
                        if cs = '1' and RD = '1' then
                            state <= read0;
                        elsif cs = '1' and WR = '1' then
                            state <= write0;
                        else
                            state <= idle;
                        end if;
                    when write0 => state <= write1;
                    when write1 => state <= write2;
                    when write2 => state <= write3;
                    when write3 => state <= write4;
                    when write4 =>
                        if WR = '0' then
                            state <= idle;
                        else
                            state <= write4;
                        end if;                    
                    when read0 => state <= read1;
                    when read1 => state <= read2;
                    when read2 =>
                        if RD = '0' then
                            state <= idle;
                        else
                            state <= read2;
                        end if;                    
                end case;
            end if;
        end if;
    end process;

    process(state) is begin
        case state is
            when idle => 
                loadadd <= '1'; incadd <= '0'; 
                wordsel <= '0'; datain_oe <= '0'; datain_wr <= '1'; 
                wr_high <= '0'; wr_low <= '0'; dataout_oe <= '0'; 
                sram_oe <= '1'; sram_we <= '1'; ack <= '0';                
            
            when write0 =>
                loadadd <= '0'; incadd <= '0'; 
                wordsel <= '0'; datain_oe <= '1'; datain_wr <= '0'; 
                wr_high <= '0'; wr_low <= '0'; dataout_oe <= '0'; 
                sram_oe <= '1'; sram_we <= '0'; ack <= '0';
            when write1 =>
                loadadd <= '0'; incadd <= '1'; 
                wordsel <= '0'; datain_oe <= '1'; datain_wr <= '0'; 
                wr_high <= '0'; wr_low <= '0'; dataout_oe <= '0'; 
                sram_oe <= '1'; sram_we <= '1'; ack <= '0';
            when write2 =>
                loadadd <= '0'; incadd <= '0'; 
                wordsel <= '1'; datain_oe <= '1'; datain_wr <= '0'; 
                wr_high <= '0'; wr_low <= '0'; dataout_oe <= '0'; 
                sram_oe <= '1'; sram_we <= '1'; ack <= '0';
            when write3 =>
                loadadd <= '0'; incadd <= '0'; 
                wordsel <= '1'; datain_oe <= '1'; datain_wr <= '0'; 
                wr_high <= '0'; wr_low <= '0'; dataout_oe <= '0'; 
                sram_oe <= '1'; sram_we <= '0'; ack <= '1';
            when write4 =>
                loadadd <= '0'; incadd <= '0'; 
                wordsel <= '0'; datain_oe <= '0'; datain_wr <= '0'; 
                wr_high <= '0'; wr_low <= '0'; dataout_oe <= '0'; 
                sram_oe <= '1'; sram_we <= '1'; ack <= '1';                
            
            when read0 =>
                loadadd <= '0'; incadd <= '1'; 
                wordsel <= '0'; datain_oe <= '0'; datain_wr <= '0'; 
                wr_high <= '0'; wr_low <= '1'; dataout_oe <= '0'; 
                sram_oe <= '0'; sram_we <= '1'; ack <= '0';
            when read1 =>
                loadadd <= '0'; incadd <= '0'; 
                wordsel <= '0'; datain_oe <= '0'; datain_wr <= '0'; 
                wr_high <= '1'; wr_low <= '0'; dataout_oe <= '0'; 
                sram_oe <= '0'; sram_we <= '1'; ack <= '0';
            when read2 =>
                loadadd <= '0'; incadd <= '0'; 
                wordsel <= '0'; datain_oe <= '0'; datain_wr <= '0'; 
                wr_high <= '0'; wr_low <= '0'; dataout_oe <= '1'; 
                sram_oe <= '1'; sram_we <= '1'; ack <= '1';
                
        end case;
    end process;

end architecture ex_sram_arch;
