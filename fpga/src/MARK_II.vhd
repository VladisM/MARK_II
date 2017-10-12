-- Top level entity, MARK_II SoC
--
-- Part of MARK II project. For informations about license, please
-- see file /LICENSE .
--
-- author: Vladislav Mlejnecký
-- email: v.mlejnecky@seznam.cz

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MARK_II is
    port(
        --control signals
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
        ps2dat: in std_logic;
        
        --sdram
        sdram_addr: out std_logic_vector(12 downto 0);
        sdram_bank_addr: out std_logic_vector(1 downto 0);
        sdram_data: inout std_logic_vector(15 downto 0);
        sdram_clock_enable: out std_logic;
        sdram_cs_n: out std_logic;
        sdram_ras_n: out std_logic;
        sdram_cas_n: out std_logic;
        sdram_we_n: out std_logic;
        sdram_data_mask_low: out std_logic;
        sdram_data_mask_high: out std_logic;
        sdram_clk: out std_logic
    );
end entity MARK_II;

architecture MARK_II_arch of MARK_II is

    component cpu is
        port(
            --system interface
            clk: in std_logic;
            res: in std_logic;
            --bus interface
            address: out std_logic_vector(23 downto 0);
            data_mosi: out std_logic_vector(31 downto 0);
            data_miso: in std_logic_vector(31 downto 0);
            we: out std_logic;
            oe: out std_logic;
            ack: in std_logic;
            swirq: out std_logic;
            --interrupts
            int: in std_logic;
            int_address: in std_logic_vector(23 downto 0);
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
            address: in std_logic_vector(23 downto 0);
            data_mosi: in std_logic_vector(31 downto 0);
            data_miso: out std_logic_vector(31 downto 0);
            WR: in std_logic;
            RD: in std_logic;
            ack: out std_logic;
            --device
            int_req: in std_logic_vector(15 downto 0);      --peripherals may request interrupt with this signal
            int_accept: in std_logic;                       --from the CPU
            int_completed: in std_logic;                    --from the CPU
            int_cpu_address: out std_logic_vector(23 downto 0);  --connect this to the CPU, this is address of ISR
            int_cpu_rq: out std_logic
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
            address: in std_logic_vector(23 downto 0);
            data_mosi: in std_logic_vector(31 downto 0);
            data_miso: out std_logic_vector(31 downto 0);
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
            res: in std_logic;
            address: in std_logic_vector(23 downto 0);
            data_mosi: in std_logic_vector(31 downto 0);
            data_miso: out std_logic_vector(31 downto 0);
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
            res: in std_logic;
            address: in std_logic_vector(23 downto 0);
            data_mosi: in std_logic_vector(31 downto 0);
            data_miso: out std_logic_vector(31 downto 0);
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
            address: in std_logic_vector(23 downto 0);
            data_mosi: in std_logic_vector(31 downto 0);
            data_miso: out std_logic_vector(31 downto 0);
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
            address: in std_logic_vector(23 downto 0);
            data_mosi: in std_logic_vector(31 downto 0);
            data_miso: out std_logic_vector(31 downto 0);
            WR: in std_logic;
            RD: in std_logic;
            ack: out std_logic;
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
            address: in std_logic_vector(23 downto 0);
            data_mosi: in std_logic_vector(31 downto 0);
            data_miso: out std_logic_vector(31 downto 0);
            WR: in std_logic;
            RD: in std_logic;
            ack: out std_logic;
            --device
            clk_uart: in std_logic;
            rx: in std_logic;
            tx: out std_logic;
            intrq: out std_logic
        );
    end component uart;

    component vga is
        generic(
            BASE_ADDRESS: unsigned(23 downto 0) := x"000000"    --base address of the RAM
        );
        port(
            clk_bus: in std_logic;
            res: in std_logic;
            address: in std_logic_vector(23 downto 0);
            data_mosi: in std_logic_vector(31 downto 0);
            data_miso: out std_logic_vector(31 downto 0);
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
            address: in std_logic_vector(23 downto 0);
            data_miso: out std_logic_vector(31 downto 0);
            RD: in std_logic;
            ack: out std_logic;
            --device
            ps2clk: in std_logic;
            ps2dat: in std_logic;
            intrq: out std_logic
        );
    end component ps2;

    component clkgen is 
        port(
            res: in std_logic;
            clk_ext: in std_logic;
            res_out: out std_logic;
            clk_sys: out std_logic;
            clk_sdram: out std_logic;
            clk_vga: out std_logic;
            clk_uart: out std_logic;
            clk_sdram_ext: out std_logic
        );
    end component clkgen;

    component sdram is
        generic(
            BASE_ADDRESS: unsigned(23 downto 0) := x"000000"
        );
        port(
            --bus interface
            clk: in std_logic;
            res: in std_logic;
            address: in std_logic_vector(23 downto 0);
            data_mosi: in std_logic_vector(31 downto 0);
            data_miso: out std_logic_vector(31 downto 0);
            WR: in std_logic;
            RD: in std_logic;
            ack: out std_logic;
            
            -- device specific interface
            clk_sdram: in std_logic;

            -- sdram interface
            addr: out std_logic_vector(12 downto 0);
            bank_addr: out std_logic_vector(1 downto 0);
            data: inout std_logic_vector(15 downto 0);
            clock_enable: out std_logic;
            cs_n: out std_logic;
            ras_n: out std_logic;
            cas_n: out std_logic;
            we_n: out std_logic;
            data_mask_low: out std_logic;
            data_mask_high: out std_logic
        );
    end component sdram;
    
    --signal for internal bus
    signal bus_address: std_logic_vector(23 downto 0);
    signal bus_data_mosi, bus_data_miso: std_logic_vector(31 downto 0);
    signal bus_ack, bus_WR, bus_RD: std_logic;
    signal int_req: std_logic_vector(15 downto 0) := x"0000";

    --signal for interconnect CPU and int controller
    signal intCompleted, intAccepted: std_logic;
    signal intCPUReq: std_logic;
    signal intAddress: std_logic_vector(23 downto 0);

    signal clk_31M5: std_logic;     -- 31,5 MHz clk for vga
    signal clk_uart: std_logic;     -- 14,4 MHz clk for uarts
    signal clk_sys: std_logic;      -- 50 MHz clk for system (CPU and buses)
    signal clk_sdram: std_logic;    -- 100 MHz clk for SDRAM driver

    signal resi: std_logic;         --internal reset

    signal rom_ack, ram_ack, int_ack, gpio_ack, systim_ack, vga_ack, tim0_ack, ram1_ack,
           tim1_ack,tim2_ack,tim3_ack, uart0_ack, uart1_ack, uart2_ack, ps2_ack, sdram_ack : std_logic;

begin

    clkgen0: clkgen
        port map(res, clk, resi, clk_sys, clk_sdram, clk_31M5, clk_uart, sdram_clk);
    
    cpu0: cpu
        port map(clk_sys, resi, bus_address, bus_data_mosi, bus_data_miso, bus_WR, bus_RD, bus_ack, int_req(0), intCPUReq, intAddress, intAccepted, intCompleted);

    int0: intController
        generic map(x"00010F")
        port map(clk_sys, resi, bus_address, bus_data_mosi, bus_data_miso, bus_WR, bus_RD, int_ack, int_req, intAccepted, intCompleted, intAddress, intCPUReq);

    systim0: systim
        generic map(x"000104")
        port map(clk_sys, resi, bus_address, bus_data_mosi, bus_data_miso, bus_WR, bus_RD, systim_ack, int_req(1));

    gpio0: gpio
        generic map(x"000100", 8)
        port map(clk_sys, resi, bus_address, bus_data_mosi, bus_data_miso, bus_WR, bus_RD, gpio_ack, porta, portb);

    rom0: rom
        generic map(x"000000")
        port map(clk_sys, resi, bus_address, bus_data_mosi, bus_data_miso, bus_WR, bus_RD, rom_ack);

    ram0: ram
        generic map(x"000400", 10)
        port map(clk_sys, resi, bus_address, bus_data_mosi, bus_data_miso, bus_WR, bus_RD, ram_ack);

    tim0: timer
        generic map(x"000120")
        port map(clk_sys, resi, bus_address, bus_data_mosi, bus_data_miso, bus_WR, bus_RD, tim0_ack, tim0_pwma, tim0_pwmb, int_req(12));

    tim1: timer
        generic map(x"000124")
        port map(clk_sys, resi, bus_address, bus_data_mosi, bus_data_miso, bus_WR, bus_RD, tim1_ack, tim1_pwma, tim1_pwmb, int_req(13));

    tim2: timer
        generic map(x"000128")
        port map(clk_sys, resi, bus_address, bus_data_mosi, bus_data_miso, bus_WR, bus_RD, tim2_ack, tim2_pwma, tim2_pwmb, int_req(14));

    tim3: timer
        generic map(x"00012C")
        port map(clk_sys, resi, bus_address, bus_data_mosi, bus_data_miso, bus_WR, bus_RD, tim3_ack, tim3_pwma, tim3_pwmb, int_req(15));

    uart0: uart
        generic map(x"000130")
        port map(clk_sys, resi, bus_address, bus_data_mosi, bus_data_miso, bus_WR, bus_RD, uart0_ack, clk_uart, rx0, tx0, int_req(8));

    uart1: uart
        generic map(x"000134")
        port map(clk_sys, resi, bus_address, bus_data_mosi, bus_data_miso, bus_WR, bus_RD, uart1_ack, clk_uart, rx1, tx1, int_req(9));

    uart2: uart
        generic map(x"000138")
        port map(clk_sys, resi, bus_address, bus_data_mosi, bus_data_miso, bus_WR, bus_RD, uart2_ack, clk_uart, rx2, tx2, int_req(10));

    vga0: vga
        generic map(x"001000")
        port map(clk_sys, resi, bus_address, bus_data_mosi, bus_data_miso, bus_WR, bus_RD, vga_ack, clk_31M5, h_sync, v_sync, red, green, blue);

    ps2keyboard0: ps2
        generic map(x"000106")
        port map(clk_sys, resi, bus_address, bus_data_miso, bus_RD, ps2_ack, ps2clk, ps2dat, int_req(11));

    ram1: ram
        generic map(x"100000", 13)
        port map(clk_sys, resi, bus_address, bus_data_mosi, bus_data_miso, bus_WR, bus_RD, ram1_ack);
    
    sdram0: sdram
        generic map(x"800000")
        port map(clk_sys, resi, bus_address, bus_data_mosi, bus_data_miso, bus_WR, bus_RD, sdram_ack,
                 clk_sdram, sdram_addr, sdram_bank_addr, sdram_data, sdram_clock_enable, sdram_cs_n, 
                 sdram_ras_n, sdram_cas_n, sdram_we_n, sdram_data_mask_low, sdram_data_mask_high);
    
    
    bus_ack <=
        rom_ack or ram_ack or int_ack or gpio_ack or systim_ack or vga_ack or tim0_ack or
        tim1_ack or tim2_ack or tim3_ack or uart0_ack or uart1_ack or uart2_ack or ps2_ack or ram1_ack or sdram_ack;

end architecture MARK_II_arch;
