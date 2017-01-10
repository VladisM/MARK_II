library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MARK_II is
    port(
        --constrol signals
        clk: in std_logic;
        res: in std_logic;
        --gpio
        port_a: inout std_logic_vector(7 downto 0);
        port_b: inout std_logic_vector(7 downto 0);
        --PWM
        pwm_A: out std_logic;
        pwm_ext_clk_A: in std_logic;
        pwm_B: out std_logic;
        pwm_ext_clk_B: in std_logic;
        --uart
        clk_uart: in std_logic;
        tx0: out std_logic;
        rx0: in std_logic
    );
end entity MARK_II;

architecture MARK_II_arch of MARK_II is 

    component cpu is
        port(
            clk: in std_logic;
            res: in std_logic;
            int: in std_logic_vector(31 downto 0);
            int_accept: out std_logic;
            int_completed: out std_logic;
            address: out std_logic_vector(19 downto 0);
            data_mosi: out std_logic_vector(31 downto 0);
            data_miso: in std_logic_vector(31 downto 0);
            WR: out std_logic;
            RD: out std_logic
        );
    end component cpu;
    
    component gpio is 
		  generic(
			   BASE_ADDRESS: unsigned(19 downto 0) := x"00000";    --base address of the GPIO 
			   GPIO_WIDE: natural := 32;       --wide of the gpios
			   BUS_WIDE:natural := 32		--wide of the data bus
		  );
		  port(
			  clk: in std_logic;
			  res: in std_logic;
			  address: in std_logic_vector(19 downto 0);
			  data_mosi: in std_logic_vector((BUS_WIDE-1) downto 0);
			  data_miso: out std_logic_vector((BUS_WIDE-1) downto 0);
			  WR: in std_logic;
			  RD: in std_logic;
			  --outputs
			  port_a: inout std_logic_vector((GPIO_WIDE-1) downto 0);
			  port_b: inout std_logic_vector((GPIO_WIDE-1) downto 0)
        );
    end component gpio;
    
    component ram is
        generic(
            BASE_ADDRESS: unsigned(19 downto 0) := x"00000"    --base address of the RAM 
        );
        port(
            clk: in std_logic;
            address: in std_logic_vector(19 downto 0);
            data_mosi: in std_logic_vector(31 downto 0);
            data_miso: out std_logic_vector(31 downto 0); 
            WR: in std_logic;
            RD: in std_logic
        );
    end component ram;
    
    component rom is
        generic(
            BASE_ADDRESS: unsigned(19 downto 0) := x"00000"    --base address of the ROM 
        );
        port(
            clk: in std_logic;
            address: in std_logic_vector(19 downto 0);
            data_mosi: in std_logic_vector(31 downto 0);
            data_miso: out std_logic_vector(31 downto 0); 
            WR: in std_logic;
            RD: in std_logic
        );
    end component rom;
    
    component pwm is 
        generic(
            BASE_ADDRESS: unsigned(19 downto 0) := x"00000";    --base address
            TIMER_WIDE: natural := 4;
            BUS_WIDE: natural := 32
        );
        port(
            --main bus interface
            clk: in std_logic;
            res: in std_logic;
            address: in std_logic_vector(19 downto 0);
            data_mosi: in std_logic_vector((BUS_WIDE - 1) downto 0);
            data_miso: out std_logic_vector((BUS_WIDE - 1) downto 0);
            WR: in std_logic;
            RD: in std_logic;
            --pwm
            pwm: out std_logic;
            ext_clk: in std_logic
        );
    end component pwm;
    
    component intController is 
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
            int_req: in std_logic_vector(31 downto 0);      --peripherals may request interrupt with this signal
            int_accept: in std_logic;                       --from the CPU
            int_completed: in std_logic;                    --from the CPU
            int_cpu_req: out std_logic_vector(31 downto 0)  --connect this to the CPU, this is cpu interrupt
            
        );
    end component intController;

    component uart is 
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
            rx: in std_logic;
            clk_uart: in std_logic
        );
    end component uart;

    --interconnect between CPU and intController
    signal int_accept, int_completed: std_logic;
    signal int: std_logic_vector(31 downto 0);

    --signal for internal bus
    signal bus_address: std_logic_vector(19 downto 0);
    signal bus_data_mosi, bus_data_miso: std_logic_vector(31 downto 0);
    signal bus_WR, bus_RD: std_logic;
    signal int_req: std_logic_vector(31 downto 0) := x"00000000";
begin

    --main cpu
    cpu_0: cpu
        port map(clk, res, int, int_accept, int_completed, bus_address, bus_data_mosi, bus_data_miso, bus_WR, bus_RD);
    
	 --gpio block    (0x100 - 0x103)
    gpio_0: gpio
        generic map(x"00100", 8, 32)
        port map(clk, res, bus_address, bus_data_mosi, bus_data_miso, bus_WR, bus_RD, port_a, port_b);
    
    --PWM generator A (0x104 - 0x105)
    pwm_0: pwm
        generic map(x"00104", 16, 32)
        port map(clk, res, bus_address, bus_data_mosi, bus_data_miso, bus_WR, bus_RD, pwm_A, pwm_ext_clk_A);
    
    --PWM generator B (0x106 - 0x107)
    pwm_1: pwm
        generic map(x"00106", 16, 32)
        port map(clk, res, bus_address, bus_data_mosi, bus_data_miso, bus_WR, bus_RD, pwm_B, pwm_ext_clk_B);
        
    --ram memory    (0x400 - 0x7FF)
    ram_0: ram
        generic map(x"00400")
        port map(clk, bus_address, bus_data_mosi, bus_data_miso, bus_WR, bus_RD);
    
    --rom memory    (0x000 - 0x0FF)
    rom_0: rom
        generic map(x"00000")
        port map(clk, bus_address, bus_data_mosi, bus_data_miso, bus_WR, bus_RD);
        
    --interrupt controller (0x108)
    int_cont_0: intController
        generic map(x"00108")
        port map(clk, res, bus_address, bus_data_mosi, bus_data_miso, bus_WR, bus_RD, int_req, int_accept, int_completed, int);

    --uart (0x10A - 0x10B) (tx int => 8, rx int => 9)
    uart_0: uart
        generic map(x"0010A")
        port map(clk, res, bus_address, bus_data_mosi, bus_data_miso, bus_WR, bus_RD, int_req(8), int_req(9), tx0, rx0, clk_uart);
end architecture MARK_II_arch;
