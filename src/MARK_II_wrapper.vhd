-- This is wrapper intended for DE2 board from Terasic. Set this as main
-- entity.
--
-- Part of MARK II project.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MARK_II_wrapper is 
    port(
        clk50: in std_logic;
        res: in std_logic;
        
        porta: inout std_logic_vector(7 downto 0);
        
        uart0_rx:  in std_logic;
        uart0_tx: out std_logic;
        
        vga_r: out unsigned(9 downto 0);
        vga_g: out unsigned(9 downto 0);
        vga_b: out unsigned(9 downto 0);
        vga_clk: buffer std_logic;
        vga_blank: out std_logic;
        vga_hs: out std_logic;
        vga_vs: out std_logic;
        vga_sync: out std_logic;
        
        sram_address: out unsigned(17 downto 0);
        sram_data: inout unsigned(15 downto 0);
        sram_oe: out std_logic;
        sram_we: out std_logic;
        sram_ce: out std_logic;
        sram_ube: out std_logic;
        sram_lbe: out std_logic;
        
        ps2clk: in std_logic; 
        ps2dat: in std_logic
    );
end entity MARK_II_wrapper;

architecture MARK_II_wrapper_arch of MARK_II_wrapper is

    attribute chip_pin : string;
    
    attribute chip_pin of clk50         : signal is "N2";
    attribute chip_pin of res           : signal is "G26";     
    attribute chip_pin of porta         : signal is "Y18, AA20, U17, U18, V18, W19, AF22, AE22";
    attribute chip_pin of uart0_tx      : signal is "B25";
    attribute chip_pin of uart0_rx      : signal is "C25";
    attribute chip_pin of vga_r         : signal is "E10, F11, H12, H11, A8, C9, D9, G10, F10, C8";
    attribute chip_pin of vga_g         : signal is "D12, E12, D11, G11, A10, B10, D10, C10, A9, B9";
    attribute chip_pin of vga_b         : signal is "B12, C12, B11, C11, J11, J10, G12, F12, J14, J13";
    attribute chip_pin of vga_clk       : signal is "B8";
    attribute chip_pin of vga_blank     : signal is "D6";
    attribute chip_pin of vga_hs        : signal is "A7";
    attribute chip_pin of vga_vs        : signal is "D8";
    attribute chip_pin of vga_sync      : signal is "B7";    
    attribute chip_pin of sram_address  : signal is "AC8 ,AB8 ,Y10 ,W10 ,W8 ,AC7 ,V9 ,V10 ,AD7 ,AD6 ,AF5 ,AE5 ,AD5 ,AD4 ,AC6 ,AC5 ,AF4 ,AE4";
    attribute chip_pin of sram_data     : signal is "AC10, AC9, W12, W11, AF8, AE8, AF7, AE7, Y11, AA11, AB10, AA10, AA9, AF6, AE6, AD8";
    attribute chip_pin of sram_oe       : signal is "AD10";
    attribute chip_pin of sram_we       : signal is "AE10";
    attribute chip_pin of sram_ce       : signal is "AC11";
    attribute chip_pin of sram_ube      : signal is "AF9";
    attribute chip_pin of sram_lbe      : signal is "AE9";    
    attribute chip_pin of ps2dat        : signal is "C24";
    attribute chip_pin of ps2clk        : signal is "D26";
    
    component MARK_II is
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
            red: out std_logic;
            green: out std_logic;
            blue: out std_logic;
            px_clk: out std_logic;
            --sram
            sram_address: out unsigned(17 downto 0);
            sram_data: inout unsigned(15 downto 0);
            sram_oe: out std_logic;
            sram_we: out std_logic;
            --keyboard
            ps2clk: in std_logic; 
            ps2dat: in std_logic
        );
    end component MARK_II;

    signal red, green, blue: std_logic;
    signal vga_hs_i, vga_vs_i: std_logic;
    
begin

    SoC0: MARK_II
        port map(
            --control
            clk50, not(res), 
            --gpio
            porta, open, 
            --timers
            open, open, open, open, open, open, open, open, 
            --uarts
            uart0_tx, uart0_rx, open, '1', open, '1', 
            --vga
            vga_hs_i, vga_vs_i, red, green, blue, vga_clk,
            --sram
            sram_address, sram_data, sram_oe, sram_we,
            --keyboard
            ps2clk, ps2dat
        );   
    
    
    vga_r <= (others => red);
    vga_g <= (others => green);
    vga_b <= (others => blue);
    
    vga_blank <= '1';
    vga_sync <= '0';
    
    process(vga_clk, vga_hs_i, vga_vs_i) is
        variable vga_hs_v, vga_vs_v: std_logic;
    begin
        if rising_edge(vga_clk) then
            vga_hs_v := vga_hs_i;
            vga_vs_v := vga_vs_i;
        end if;
        vga_hs <= vga_hs_v;
        vga_vs <= vga_vs_v;
    end process;
        
    sram_ce <= '0';
    sram_ube <= '0';
    sram_lbe <= '0';
    
end architecture MARK_II_wrapper_arch;
