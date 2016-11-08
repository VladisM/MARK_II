library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MARK_II is
    port(
        --constrol signals
        clk: in std_logic;
        res: in std_logic;
        int: in std_logic;
        int_accept: out std_logic;
        int_completed: out std_logic;
        --gpio
        port_a: inout std_logic_vector(31 downto 0);
        port_b: inout std_logic_vector(31 downto 0);
        --PWM
        pwm_A: out std_logic;
        pwm_ext_clk_A: in std_logic;
        pwm_B: out std_logic;
        pwm_ext_clk_B: in std_logic;
        --debug part
        deb_address_bus: out std_logic_vector(17 downto 0);
        deb_bus_RE: out std_logic;
        deb_bus_WE: out std_logic;
        deb_data_mosi: out std_logic_vector(31 downto 0);
        deb_data_miso: out std_logic_vector(31 downto 0);
        deb_regs_wr_select: out std_logic_vector(15 downto 0);
        deb_regs_oe_select: out std_logic_vector(15 downto 0);
        deb_alu_lt: out std_logic;
        deb_alu_ltu: out std_logic;
        deb_alu_ge: out std_logic; 
        deb_alu_geu: out std_logic;
        deb_alu_eqv: out std_logic;
        deb_alu_oe: out std_logic; 
        deb_alu_wrA: out std_logic;
        deb_alu_wrB: out std_logic;
        deb_alu_opcode: out std_logic_vector(3 downto 0);
        deb_bus_ext_WR: out std_logic;
        deb_bus_ext_RD: out std_logic;
        deb_bus_WRadd: out std_logic;
        deb_bus_WRdat: out std_logic;
        deb_bus_RDdat: out std_logic;
        deb_instruction_word: out std_logic_vector(31 downto 0);
        deb_instruction_reg_wr: out std_logic;
        deb_ins_arg_input: out std_logic_vector(31 downto 0);
        deb_ins_arg_oe: out std_logic;
        deb_databus: out std_logic_vector(31 downto 0)
        --end debug part
    );
end entity MARK_II;

architecture MARK_II_arch of MARK_II is 

    component cpu is
        port(
            clk: in std_logic;
            res: in std_logic;
            int: in std_logic;
            int_accept: out std_logic;
            int_completed: out std_logic;
            address: out std_logic_vector(17 downto 0);
            data_mosi: out std_logic_vector(31 downto 0);
            data_miso: in std_logic_vector(31 downto 0);
            WR: out std_logic;
            RD: out std_logic;
            --debug part
            deb_regs_wr_select: out std_logic_vector(15 downto 0);
            deb_regs_oe_select: out std_logic_vector(15 downto 0);
            deb_alu_lt: out std_logic;
            deb_alu_ltu: out std_logic;
            deb_alu_ge: out std_logic; 
            deb_alu_geu: out std_logic;
            deb_alu_eqv: out std_logic;
            deb_alu_oe: out std_logic; 
            deb_alu_wrA: out std_logic;
            deb_alu_wrB: out std_logic;
            deb_alu_opcode: out std_logic_vector(3 downto 0);
            deb_bus_ext_WR: out std_logic;
            deb_bus_ext_RD: out std_logic;
            deb_bus_WRadd: out std_logic;
            deb_bus_WRdat: out std_logic;
            deb_bus_RDdat: out std_logic;
            deb_instruction_word: out std_logic_vector(31 downto 0);
            deb_instruction_reg_wr: out std_logic;
            deb_ins_arg_input: out std_logic_vector(31 downto 0);
            deb_ins_arg_oe: out std_logic;
            deb_databus: out std_logic_vector(31 downto 0)
            --end debug part
        );
    end component cpu;
    
    component gpio is 
        generic(
            BASE_ADDRESS: unsigned(17 downto 0) := "000000000000000000";    --base address of the GPIO 
            WIDE: natural := 32       --wide of the whole gpio
        );
        port(
        clk: in std_logic;
        res: in std_logic;
        address: in std_logic_vector(17 downto 0);
        data_mosi: in std_logic_vector((WIDE-1) downto 0);
        data_miso: out std_logic_vector((WIDE-1) downto 0);
        WR: in std_logic;
        RD: in std_logic;
        port_a: inout std_logic_vector((WIDE-1) downto 0);
        port_b: inout std_logic_vector((WIDE-1) downto 0)
        );
    end component gpio;
    
    component ram is
        generic(
            BASE_ADDRESS: unsigned(17 downto 0) := "000000000000000000"    --base address of the RAM 
        );
        port(
            clk: in std_logic;
            address: in std_logic_vector(17 downto 0);
            data_mosi: in std_logic_vector(31 downto 0);
            data_miso: out std_logic_vector(31 downto 0); 
            WR: in std_logic;
            RD: in std_logic
        );
    end component ram;
    
    component rom is
        generic(
            BASE_ADDRESS: unsigned(17 downto 0) := "000000000000000000"    --base address of the ROM 
        );
        port(
            clk: in std_logic;
            address: in std_logic_vector(17 downto 0);
            data_mosi: in std_logic_vector(31 downto 0);
            data_miso: out std_logic_vector(31 downto 0); 
            WR: in std_logic;
            RD: in std_logic
        );
    end component rom;
    
    component pwm is 
        generic(
            BASE_ADDRESS: unsigned(17 downto 0) := "000000000000000000";    --base address
            TIMER_WIDE: natural := 4;
            BUS_WIDE: natural := 32
        );
        port(
            --main bus interface
            clk: in std_logic;
            res: in std_logic;
            address: in std_logic_vector(17 downto 0);
            data_mosi: in std_logic_vector((BUS_WIDE - 1) downto 0);
            data_miso: out std_logic_vector((BUS_WIDE - 1) downto 0);
            WR: in std_logic;
            RD: in std_logic;
            --pwm
            pwm: out std_logic;
            ext_clk: in std_logic
        );
    end component pwm;
        
    --signal for internal bus
    signal bus_address: std_logic_vector(17 downto 0);
    signal bus_data_mosi, bus_data_miso: std_logic_vector(31 downto 0);
    signal bus_WR, bus_RD: std_logic;
    
begin

    --main cpu
    cpu_0: cpu
        port map(clk, res, int, int_accept, int_completed, bus_address, bus_data_mosi, bus_data_miso, bus_WR, bus_RD,
        --debug part
        deb_regs_wr_select, 
        deb_regs_oe_select, 
        deb_alu_lt,
        deb_alu_ltu,
        deb_alu_ge, 
        deb_alu_geu,
        deb_alu_eqv,
        deb_alu_oe, 
        deb_alu_wrA,
        deb_alu_wrB,
        deb_alu_opcode,
        deb_bus_ext_WR,
        deb_bus_ext_RD,
        deb_bus_WRadd,
        deb_bus_WRdat,
        deb_bus_RDdat,
        deb_instruction_word, 
        deb_instruction_reg_wr,
        deb_ins_arg_input, 
        deb_ins_arg_oe,
        deb_databus
        --end of debug part        
        );
    
    --gpio block    (0x100 - 0x103)
    gpio_0: gpio
        generic map("000000000100000000", 32)
        port map(clk, res, bus_address, bus_data_mosi, bus_data_miso, bus_WR, bus_RD, port_a, port_b);
    
    --PWM generator A (0x104 - 0x105)
    pwm_0: pwm
        generic map("000000000100000100", 16, 32)
        port map(clk, res, bus_address, bus_data_mosi, bus_data_miso, bus_WR, bus_RD, pwm_A, pwm_ext_clk_A);
    
    --PWM generator B (0x106 - 0x107)
    pwm_1: pwm
        generic map("000000000100000110", 16, 32)
        port map(clk, res, bus_address, bus_data_mosi, bus_data_miso, bus_WR, bus_RD, pwm_B, pwm_ext_clk_B);
        
    --ram memory    (0x400 - 0x7FF)
    ram_0: ram
        generic map("000000010000000000")
        port map(clk, bus_address, bus_data_mosi, bus_data_miso, bus_WR, bus_RD);
    
    --rom memory    (0x000 - 0x0FF)
    rom_0: rom
        generic map("000000000000000000")
        port map(clk, bus_address, bus_data_mosi, bus_data_miso, bus_WR, bus_RD);
        
    
    --debug
    deb_address_bus <= bus_address;
    deb_bus_RE <= bus_RD;
    deb_bus_WE <= bus_WR;
    deb_data_mosi <= bus_data_mosi;
    deb_data_miso <= bus_data_miso;
    
end architecture MARK_II_arch;
