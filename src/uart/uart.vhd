-- simple UART for MARK II project
--
-- this uart support only 8N1 format (8 data bits, 1 stop bit, no parity)
--
-- there are two reg, data register and control register,
-- data register consist of two independet regs, one for TX data and
-- second for RX data, what register will be used depend on operation
-- RX for reading and TX for writing
--
-- transmitter is triggered by writing into TX reg
--
-- don't forget configure baud rate, see baudrate source for more details
--
-- baseaddress - data reg
-- baseaddress + 1 - configuration reg
--
-- config reg
-- b15 downto b0 - n_factor for baudgen
-- b16 - tx busy flag
--
-- interrupt is triggered when byte is recieved or sending is completed
-- for disabling interrupt use interrupt controller

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart is 
    generic(
        BASE_ADDRESS: unsigned(19 downto 0) := x"00000"    --base address
    );
    port(
        --bus
		clk: in std_logic;
        res: in std_logic;
        address: in std_logic_vector(19 downto 0);
        data_mosi: in std_logic_vector(31 downto 0);
        data_miso: out std_logic_vector(31 downto 0);
        WR: in std_logic;
        RD: in std_logic;
        --device
        tx_int_req: out std_logic;
        rx_int_req: out std_logic;
        tx: out std_logic;
        rx: in std_logic
    );
end entity uart;

architecture uart_arch of uart is 

    component baudgen is
        port(
            res: in std_logic;
            n_factor: in unsigned(15 downto 0);
            clk_uart: in std_logic;
            clk_baud: out std_logic;
            clk_16x_baud: out std_logic
        );
    end component baudgen;
    component reciever is
        port(
            res: in std_logic;
            clk_uart: in std_logic;
            clk_16x_baud: in std_logic;
            rx: in std_logic;
            rx_int_req: out std_logic;
            rx_rec_com: buffer std_logic;
            rx_data: out unsigned(7 downto 0)
        );
    end component reciever;
    component transmitter is
        port(
            res: in std_logic;
            clk_baud: in std_logic;
            tx_data: in unsigned(7 downto 0);
            tx_send: in std_logic;
            tx_int_req: out std_logic;
            tx_busy_flag: out std_logic;
            tx: out std_logic
        );
    end component transmitter;

    --clock signals for reciever and transmitter
    signal clk_baud, clk_16x_baud: std_logic;

    --this chip select for bus interface
    signal reg_sel: std_logic_vector(1 downto 0);

    --data register for sending
    signal tx_data: unsigned(7 downto 0);

    --b15 downto b0 - n_factor
    --b16           - tx busy flag
    signal control_reg: std_logic_vector(31 downto 0);
    signal n_factor: unsigned(15 downto 0);
    
    --send data signal, activated by write into TX reg
    signal tx_send: std_logic;
    
    --data from reciever
    signal rx_data: unsigned(7 downto 0);
begin

    --chip select
    process(address) is begin
        if (unsigned(address) = BASE_ADDRESS)then
            reg_sel <= "01";
        elsif ((unsigned(address)) = (BASE_ADDRESS + 1)) then
            reg_sel <= "10";
        else
            reg_sel <= "00";
        end if;
    end process;
    
    --registers
    process(clk, res, WR, data_mosi, reg_sel) is begin
        if res = '1' then
            tx_data <= (others => '0');
            n_factor <= (others => '0');
        elsif rising_edge(clk) then
            if (WR = '1' and reg_sel = "01") then
                tx_data <= unsigned(data_mosi(7 downto 0));
            elsif(WR = '1' and reg_sel = "10") then
                n_factor <= unsigned(data_mosi(15 downto 0));
            end if;
        end if;
    end process;
    
    --output from registers
    data_miso <= x"000000" & std_logic_vector(rx_data) when (RD = '1' and reg_sel = "01") else
                 control_reg when (RD = '1' and reg_sel = "10") else
                 (others => 'Z');

    --start sending when data is written into TX reg
    process(WR, reg_sel) is begin
        if( WR = '1' and reg_sel = "01") then
            tx_send <= '1';
        else
            tx_send <= '0';
        end if;
    end process;
    
    baudgen_0: baudgen
        port map(res, unsigned(control_reg(15 downto 0)), clk, clk_baud, clk_16x_baud);
    reciever_0: reciever
        port map(res, clk, clk_16x_baud, rx, rx_int_req, open, rx_data);
    transmitter_0: transmitter
        port map(res, clk_baud, tx_data, tx_send, tx_int_req, control_reg(16), tx);
    
    control_reg(15 downto 0) <= std_logic_vector(n_factor);
end architecture uart_arch;
