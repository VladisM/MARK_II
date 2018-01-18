library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bus_interface is
    generic(
        BASE_ADDRESS: unsigned(23 downto 0) := x"000000"
    );
    port(
        --bus
        clk: in std_logic;
        res: in std_logic;
        address: in std_logic_vector(23 downto 0);
        data_mosi: in std_logic_vector(31 downto 0);
        data_miso: out std_logic_vector(31 downto 0);
        WR: in std_logic;
        RD: in std_logic;
        ack: out std_logic;
        --fifos
        wrfifo_datain: out std_logic_vector(54 downto 0);
        wrfifo_write: out std_logic;
        wrfifo_wrempty: in std_logic;
        rdfifo_address_datain: out std_logic_vector(22 downto 0);
        rdfifo_address_we: out std_logic;
        rdfifo_address_wrempty: in std_logic;
        rdfifo_data_rdreq: out std_logic;
        rdfifo_data_dataout: in std_logic_vector(31 downto 0);
        rdfifo_data_rdempty: in std_logic
    );
end entity bus_interface;

architecture bus_interface_arch of bus_interface is
    
    signal miso_en, cs: std_logic;
    
    type fsm_state_type is (idle, rd_state, wr_state, wait_for_data,read_data, ack_state);
    signal fsm_state: fsm_state_type;
    
begin

    wrfifo_datain <= address(22 downto 0) & data_mosi;
    rdfifo_address_datain <= address(22 downto 0);
    data_miso <= rdfifo_data_dataout when miso_en = '1' else (others => 'Z');
    
    process(address) is begin
        if (unsigned(address) >= BASE_ADDRESS and unsigned(address) <= (BASE_ADDRESS + (2**23)-1)) then
            cs <= '1';
        else
            cs <= '0';
        end if;
    end process;
    
    process(clk) is
    begin
        if rising_edge(clk) then
            if res = '1' then
                fsm_state <= idle;
            else
                case fsm_state is
                    when idle =>
                        if (RD = '1') and (cs = '1') and (rdfifo_address_wrempty = '1') then
                            fsm_state <= rd_state;
                        elsif (WR = '1') and (cs = '1') and (wrfifo_wrempty = '1') then
                            fsm_state <= wr_state;
                        else
                            fsm_state <= idle;
                        end if;                        
                    when rd_state =>
                        fsm_state <= wait_for_data;
                    when wr_state =>
                        fsm_state <= ack_state;
                    when wait_for_data =>
                        if rdfifo_data_rdempty = '0' then
                            fsm_state <= read_data;
                        else
                            fsm_state <= wait_for_data;
                        end if;
                    when read_data =>
                        fsm_state <= ack_state;
                    when ack_state =>
                        fsm_state <= idle;
                end case;
            end if;
        end if;
    end process;    
    
    process(fsm_state) is
    begin
        case fsm_state is
            when idle =>
                rdfifo_data_rdreq <= '0'; rdfifo_address_we <= '0'; wrfifo_write <= '0'; ack <= '0';
            when rd_state =>
                rdfifo_data_rdreq <= '0'; rdfifo_address_we <= '1'; wrfifo_write <= '0'; ack <= '0';
            when wr_state =>
                rdfifo_data_rdreq <= '0'; rdfifo_address_we <= '0'; wrfifo_write <= '1'; ack <= '0';
            when wait_for_data =>
                rdfifo_data_rdreq <= '0'; rdfifo_address_we <= '0'; wrfifo_write <= '0'; ack <= '0';
            when read_data =>
                rdfifo_data_rdreq <= '1'; rdfifo_address_we <= '0'; wrfifo_write <= '0'; ack <= '0';
            when ack_state =>
                rdfifo_data_rdreq <= '0'; rdfifo_address_we <= '0'; wrfifo_write <= '0'; ack <= '1';
        end case;
    end process;
    
    miso_en <= '1' when (cs = '1') and (RD = '1') else '0';
    
end architecture bus_interface_arch;
