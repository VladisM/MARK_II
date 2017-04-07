library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_core is 
    port(
        clk: in std_logic;
        res: in std_logic;
        n: in unsigned(15 downto 0);
        send: in std_logic;
        tx: out std_logic;
        tx_data: in unsigned(7 downto 0);
        tx_intrq: out std_logic;
        rx: in std_logic;
        rx_data: out unsigned(7 downto 0);
        rx_intrq: out std_logic
    );
end entity uart_core;

architecture uart_core_arch of uart_core is

    component baudgen is
        port(
            clk: in std_logic;
            res: in std_logic;
            n: in unsigned(15 downto 0);
            baud16_clk_en: out std_logic
        );
    end component baudgen;

    component transmitter is 
        port(
            clk: in std_logic;
            res: in std_logic;
            baud16_clk_en: in std_logic;
            tx_data: in unsigned(7 downto 0);
            tx: out std_logic;
            tx_intrq: out std_logic;
            send: in std_logic
        );
    end component transmitter;
    component reciever is
        port(
            clk: in std_logic;
            res: in std_logic;
            rx: in std_logic;
            baud16_clk_en: in std_logic;
            rx_data: out unsigned(7 downto 0);
            rx_intrq: out std_logic
        );
    end component reciever;

    signal baud16_clk_en: std_logic;
begin
    baudgen0: baudgen
        port map(clk, res, n, baud16_clk_en);
        
    transmitter0: transmitter
        port map(clk, res, baud16_clk_en, tx_data, tx, tx_intrq, send);
        
    reciever0: reciever
        port  map(clk, res, rx, baud16_clk_en, rx_data, rx_intrq);
        
end architecture uart_core_arch;
    
