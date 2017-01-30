library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_core is 
    port(
        res: in std_logic;
        clk: in std_logic;
        tx: out std_logic;
        rx: in std_logic;
        tx_int: out std_logic;
        rx_int: out std_logic;
        n: in unsigned(15 downto 0);
        clksel: in std_logic_vector(1 downto 0);
        rx_data: out unsigned(7 downto 0);
        tx_data: in unsigned(7 downto 0);
        send: in std_logic;
        enclk2: in std_logic;
        enclk4: in std_logic;
        enclk8: in std_logic
    );
end entity uart_core;

architecture uart_core_arch of uart_core is 

    component reciever is
        port(
            res: in std_logic;
            clk: in std_logic;
            clk_baud: in std_logic;
            rx: in std_logic;
            rx_int_req: out std_logic;
            rx_data: out unsigned(7 downto 0)
        );
    end component reciever;
    component transmitter is
        port(
            res: in std_logic;
            clk: in std_logic;
            clk_baud: in std_logic;
            tx_data: in unsigned(7 downto 0);
            tx_send: in std_logic;
            tx_int_req: out std_logic;
            tx: out std_logic
        );
    end component transmitter;
    component baudgen is
        port(
            res: in std_logic;
            n_factor: in unsigned(15 downto 0);
            clk: in std_logic;
            clk_baud: out std_logic;
            clken: in std_logic
        );
    end component baudgen;
    
    signal clk_baud: std_logic;
    signal selectedclken: std_logic;
    
    
begin
    
    selectedclken <= '1'    when clksel = "00" else
                     enclk2 when clksel = "01" else
                     enclk4 when clksel = "10" else
                     enclk8 when clksel = "11" else '-';
                     
    reciever0: reciever
        port map(res, clk, clk_baud, rx, rx_int, rx_data);
    
    transmitter0: transmitter
        port map(res, clk, clk_baud, tx_data, send, tx_int, tx);
        
    baudgen0: baudgen
        port map(res, n, clk, clk_baud, selectedclken);
    
end architecture uart_core_arch;



