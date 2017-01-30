library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart is
    generic(
        BASE_ADDRESS: unsigned(23 downto 0) := x"000000"    --base address of the GPIO 
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
        enclk2: in std_logic;
        enclk4: in std_logic;
        enclk8: in std_logic;
        --device
        rx: in std_logic;
        tx: out std_logic;
        rx_int: out std_logic;
        tx_int: out std_logic
    );
end entity uart;

architecture uart_arch of uart is

    component reg is 
        generic(
            WIDE : natural := 32
        );
        port(
            clk: in std_logic;
            res: in std_logic;
            DataIn: in unsigned((WIDE-1) downto 0);
            DataOut: out unsigned((WIDE-1) downto 0);
            WE: in std_logic
        );
    end component reg;
    component tristate is 
        generic(
            WIDE: natural := 32
        );
        port(
            DataIn: in unsigned((WIDE-1) downto 0);
            DataOut: out unsigned((WIDE-1) downto 0);
            En: in std_logic
        );
    end component tristate;
    component uart_core is 
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
    end component uart_core;

    signal rxdata: unsigned(7 downto 0);
    signal txdata: unsigned(7 downto 0);
    signal send: std_logic;
    
    signal reg_sel: std_logic_vector(1 downto 0);

    signal controlregwe, controlregoe, txregwe, rxregoe: std_logic;
    signal controlreg: unsigned(17 downto 0);
begin

    --chip select
    process(address) is begin
        if (address = BASE_ADDRESS)then
            reg_sel <= "01";
        elsif (address = (BASE_ADDRESS + 1)) then
            reg_sel <= "10";
        else
            reg_sel <= "00";
        end if;
    end process;

    controlregwe <= reg_sel(1) and WR;
    txregwe <= reg_sel(0) and WR;

    regControl0: reg
        generic map(18)
        port map(clk, res, data_mosi(17 downto 0), controlreg, controlregwe);

    txregdata: reg
        generic map(8)
        port map(clk, res, data_mosi(7 downto 0), txdata, txregwe);    

    uartcore0: uart_core
        port map(res, clk, tx, rx, tx_int, rx_int, controlreg(15 downto 0), std_logic_vector(controlreg(17 downto 16)), rxdata, txdata, txregwe, enclk2, enclk4, enclk8);

    ack <= '1' when ((WR = '1' and reg_sel /= "00") or (RD = '1' and reg_sel /= "00")) else 'Z';
    
    data_miso <= x"000" & "00" & controlreg when RD = '1' and reg_sel = "01" else
                 x"000000" & rxdata when RD = '1' and reg_sel = "10" else (others => 'Z');
    
 end architecture uart_arch;