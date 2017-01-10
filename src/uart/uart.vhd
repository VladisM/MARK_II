library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart is 
    port(
        clk: in std_logic;
        res: in std_logic;
        
        tx_data: in unsigned(7 downto 0);
        tx_busy: out std_logic;
        tx_send: in std_logic;
        tx_int_req: out std_logic;
        rx_data: out unsigned(7 downto 0);
        rx_int_req: out std_logic;
        rx_completed: out std_logic;
        
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
    
    signal clk_baud, clk_16x_baud: std_logic;
    
begin

    baudgen_0: baudgen
        port map(res, x"0040", clk, clk_baud, clk_16x_baud);
    reciever_0: reciever
        port map(res, clk, clk_16x_baud, rx, rx_int_req, rx_completed, rx_data);
    transmitter_0: transmitter
        port map(res, clk_baud, tx_data, tx_send, tx_int_req, tx_busy, tx);

end architecture uart_arch;
