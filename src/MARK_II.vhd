library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MARK_II is
    port(
        --constrol signals
        clk: in std_logic;
        res: in std_logic;
        
        --gpio
        porta: inout std_logic_vector(7 downto 0);
        portb: inout std_logic_vector(7 downto 0);
        
        --timers
        tim0_pwma: out std_logic;
        tim0_pwmb: out std_logic;
        tim1_pwma: out std_logic;
        tim1_pwmb: out std_logic;
        tim2_pwma: out std_logic;
        tim2_pwmb: out std_logic;
        tim3_pwma: out std_logic;
        tim3_pwmb: out std_logic;
        
        --uarts
        tx0: out std_logic;
        rx0: in std_logic;
        tx1: out std_logic;
        rx1: in std_logic;
        tx2: out std_logic;
        rx2: in std_logic;
        
        --vga
        h_sync: out std_logic;
        v_sync: out std_logic;
        red: out std_logic_vector(1 downto 0);
        green: out std_logic_vector(1 downto 0);
        blue: out std_logic_vector(1 downto 0);
        
        --keyboard
        ps2clk: in std_logic;
        ps2dat: in std_logic
    );
end entity MARK_II;

architecture MARK_II_arch of MARK_II is
    
    attribute chip_pin : string;
    
    attribute chip_pin of clk           : signal is "R8";
    attribute chip_pin of res           : signal is "J15";     
    
    attribute chip_pin of porta         : signal is "L3, B1, F3, D1, A11, B13, A13, A15";
    attribute chip_pin of portb         : signal is "A2, A3, B3, B4, A4, B5, A5, D5";
    
    attribute chip_pin of tim0_pwma     : signal is "B6";
    attribute chip_pin of tim0_pwmb     : signal is "A6";
    attribute chip_pin of tim1_pwma     : signal is "B7";
    attribute chip_pin of tim1_pwmb     : signal is "D6";
    attribute chip_pin of tim2_pwma     : signal is "A7";
    attribute chip_pin of tim2_pwmb     : signal is "C6";
    attribute chip_pin of tim3_pwma     : signal is "C8";
    attribute chip_pin of tim3_pwmb     : signal is "E6";
    
    attribute chip_pin of tx0           : signal is "J16";
    attribute chip_pin of rx0           : signal is "J13";
    attribute chip_pin of tx1           : signal is "K15";
    attribute chip_pin of rx1           : signal is "N14";
    attribute chip_pin of tx2           : signal is "E11";
    attribute chip_pin of rx2           : signal is "E10";
    
    attribute chip_pin of h_sync        : signal is "L14";
    attribute chip_pin of v_sync        : signal is "M10";
    attribute chip_pin of red           : signal is "N15,R14";
    attribute chip_pin of green         : signal is "N16,P15";
    attribute chip_pin of blue          : signal is "P16,R16";
    
    attribute chip_pin of ps2clk        : signal is "L16";
    attribute chip_pin of ps2dat        : signal is "L15";
    
    component clkControl is
        port(
            clk: in std_logic;
            res: in std_logic;
            enclk2: out std_logic;
            enclk4: out std_logic;
            enclk8: out std_logic
        );
    end component clkControl;

    component cpu is
        port(
            --system interface
            clk: in std_logic;
            res: in std_logic;
            --bus interface
            address: out unsigned(23 downto 0);
            data_mosi: out unsigned(31 downto 0);
            data_miso: in unsigned(31 downto 0);
            we: out std_logic;
            oe: out std_logic;
            ack: in std_logic;
            --interrupts
            int: in std_logic_vector(31 downto 0);
            int_accept: out std_logic;
            int_completed: out std_logic
        );
    end component cpu;

    component intController is
        generic(
            BASE_ADDRESS: unsigned(23 downto 0) := x"000000"    --base address
        );
        port(
            --bus
            clk: in std_logic;
            res: in std_logic;
            address: in unsigned(23 downto 0);
            data_mosi: in unsigned(31 downto 0);
            data_miso: out unsigned(31 downto 0);
            WR: in std_logic;
            RD: in std_logic;
            ack: out std_logic;
            --device
            int_req: in std_logic_vector(31 downto 0);      --peripherals may request interrupt with this signal
            int_accept: in std_logic;                       --from the CPU
            int_completed: in std_logic;                    --from the CPU
            int_cpu_req: out std_logic_vector(31 downto 0)  --connect this to the CPU, this is cpu interrupt
        );
    end component intController;

    component gpio is
        generic(
            BASE_ADDRESS: unsigned(23 downto 0) := x"000000";    --base address of the GPIO
            GPIO_WIDE: natural := 32       --wide of the gpios
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
            --outputs
            port_a: inout std_logic_vector((GPIO_WIDE-1) downto 0);
            port_b: inout std_logic_vector((GPIO_WIDE-1) downto 0)
        );
    end component gpio;

    component rom is
        generic(
            BASE_ADDRESS: unsigned(23 downto 0) := x"000000"    --base address of the ROM
        );
        port(
            clk: in std_logic;
            address: in unsigned(23 downto 0);
            data_mosi: in unsigned(31 downto 0);
            data_miso: out unsigned(31 downto 0);
            WR: in std_logic;
            RD: in std_logic;
            ack: out std_logic
        );
    end component rom;

    component ram is
        generic(
            BASE_ADDRESS: unsigned(23 downto 0) := x"000000";    --base address of the RAM 
            ADDRESS_WIDE: natural := 8  --default address range  
        );
        port(
            clk: in std_logic;
            address: in unsigned(23 downto 0);
            data_mosi: in unsigned(31 downto 0);
            data_miso: out unsigned(31 downto 0);
            WR: in std_logic;
            RD: in std_logic;
            ack: out std_logic
        );
    end component ram;

    component systim is
        generic(
            BASE_ADDRESS: unsigned(23 downto 0) := x"000000"    --base address
        );
        port(
            --bus
            clk: in std_logic;
            res: in std_logic;
            address: in unsigned(23 downto 0);
            data_mosi: in unsigned(31 downto 0);
            data_miso: out unsigned(31 downto 0);
            WR: in std_logic;
            RD: in std_logic;
            ack: out std_logic;
            --device
            intrq: out std_logic
        );
    end component systim;

    component timer is
        generic(
            BASE_ADDRESS: unsigned(23 downto 0) := x"000000"    --base address
        );
        port(
            --bus
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
            pwma: out std_logic;
            pwmb: out std_logic;
            intrq: out std_logic
        );
    end component;

    component uart is
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
            --device
            rx: in std_logic;
            tx: out std_logic;
            rx_int: out std_logic;
            tx_int: out std_logic
        );
    end component uart;

    component vga is
        generic(
            BASE_ADDRESS: unsigned(23 downto 0) := x"000000"    --base address of the RAM
        );
        port(
            clk_bus: in std_logic;
            address: in unsigned(23 downto 0);
            data_mosi: in unsigned(31 downto 0);
            data_miso: out unsigned(31 downto 0);
            WR: in std_logic;
            RD: in std_logic;
            ack: out std_logic;
            --device
            clk_31M5: in std_logic;
            h_sync: out std_logic;
            v_sync: out std_logic;
            red: out std_logic_vector(1 downto 0);
            green: out std_logic_vector(1 downto 0);
            blue: out std_logic_vector(1 downto 0)
        );
    end component vga;

    component ps2 is
        generic(
            BASE_ADDRESS: unsigned(23 downto 0) := x"000000"
        );
        port(
            clk: in std_logic;
            res: in std_logic;
            address: in unsigned(23 downto 0);
            data_miso: out unsigned(31 downto 0);
            RD: in std_logic;
            ack: out std_logic;
            --device
            ps2clk: in std_logic;
            ps2dat: in std_logic;
            intrq: out std_logic
        );
    end component ps2;

    component pll
        port(
            inclk0: in std_logic:= '0';
            c0: out std_logic;
            c1: out std_logic
        );
    end component;

    --signal for internal bus
    signal bus_address: unsigned(23 downto 0);
    signal bus_data_mosi, bus_data_miso: unsigned(31 downto 0);
    signal bus_ack, bus_WR, bus_RD: std_logic;
    signal int_req: std_logic_vector(31 downto 0) := x"00000000";

    --signal for interconnect CPU and int controller
    signal intCompleted, intAccepted: std_logic;
    signal intCPUReq: std_logic_vector(31 downto 0);

    signal enclk2, enclk4, enclk8: std_logic;

    signal clk_31M5: std_logic;     -- 31,5 MHz clk for vga
    signal clki: std_logic;         -- 14,4 MHz clk for all others

    signal resi: std_logic;         --inverted reset
    
    signal rom_ack, ram_ack, int_ack, gpio_ack, systim_ack, vga_ack, tim0_ack, ram1_ack,
           tim1_ack,tim2_ack,tim3_ack, uart0_ack, uart1_ack, uart2_ack, ps2_ack : std_logic;

begin
    
    resi <= not(res);
    
    pll0: pll
        port map(clk, clki, clk_31M5);

    clk0: clkControl
        port map(clki, resi, enclk2, enclk4, enclk8);

    cpu0: cpu
        port map(clki, resi, bus_address, bus_data_mosi, bus_data_miso, bus_WR, bus_RD, bus_ack, intCPUReq, intAccepted, intCompleted);

    int0: intController
        generic map(x"000108")
        port map(clki, resi, bus_address, bus_data_mosi, bus_data_miso, bus_WR, bus_RD, int_ack, int_req, intAccepted, intCompleted, intCPUReq);

    gpio0: gpio
        generic map(x"000100", 8)
        port map(clki, resi, bus_address, bus_data_mosi, bus_data_miso, bus_WR, bus_RD, gpio_ack, porta, portb);

    rom0: rom
        generic map(x"000000")
        port map(clki, bus_address, bus_data_mosi, bus_data_miso, bus_WR, bus_RD, rom_ack);

    ram0: ram
        generic map(x"000400", 10)
        port map(clki, bus_address, bus_data_mosi, bus_data_miso, bus_WR, bus_RD, ram_ack);

    systim0: systim
        generic map(x"000104")
        port map(clki, resi, bus_address, bus_data_mosi, bus_data_miso, bus_WR, bus_RD, systim_ack, int_req(0));

    tim0: timer
        generic map(x"000110")
        port map(clki, resi, bus_address, bus_data_mosi, bus_data_miso, bus_WR, bus_RD, tim0_ack, enclk2, enclk4, enclk8, tim0_pwma, tim0_pwmb, int_req(14));

    tim1: timer
        generic map(x"000114")
        port map(clki, resi, bus_address, bus_data_mosi, bus_data_miso, bus_WR, bus_RD, tim1_ack, enclk2, enclk4, enclk8, tim1_pwma, tim1_pwmb, int_req(15));

    tim2: timer
        generic map(x"000118")
        port map(clki, resi, bus_address, bus_data_mosi, bus_data_miso, bus_WR, bus_RD, tim2_ack, enclk2, enclk4, enclk8, tim2_pwma, tim2_pwmb, int_req(16));

    tim3: timer
        generic map(x"00011C")
        port map(clki, resi, bus_address, bus_data_mosi, bus_data_miso, bus_WR, bus_RD, tim3_ack, enclk2, enclk4, enclk8, tim3_pwma, tim3_pwmb, int_req(17));

    uart0: uart
        generic map(x"00010A")
        port map(clki, resi, bus_address, bus_data_mosi, bus_data_miso, bus_WR, bus_RD, uart0_ack, rx0, tx0, int_req(9), int_req(8));

    uart1: uart
        generic map(x"00010C")
        port map(clki, resi, bus_address, bus_data_mosi, bus_data_miso, bus_WR, bus_RD, uart1_ack, rx1, tx1, int_req(11), int_req(10));

    uart2: uart
        generic map(x"00010E")
        port map(clki, resi, bus_address, bus_data_mosi, bus_data_miso, bus_WR, bus_RD, uart2_ack, rx2, tx2, int_req(13), int_req(12));

    vga0: vga
        generic map(x"001000")
        port map(clki, bus_address, bus_data_mosi, bus_data_miso, bus_WR, bus_RD, vga_ack, clk_31M5, h_sync, v_sync, red, green, blue);

    ps2keyboard0: ps2
        generic map(x"000109")
        port map(clki, resi, bus_address, bus_data_miso, bus_RD, ps2_ack, ps2clk, ps2dat, int_req(18));

    ram1: ram
        generic map(x"100000", 13)
        port map(clki, bus_address, bus_data_mosi, bus_data_miso, bus_WR, bus_RD, ram1_ack);
        
    bus_ack <=
        rom_ack or ram_ack or int_ack or gpio_ack or systim_ack or vga_ack or tim0_ack or 
        tim1_ack or tim2_ack or tim3_ack or uart0_ack or uart1_ack or uart2_ack or ps2_ack or ram1_ack;

end architecture MARK_II_arch;
