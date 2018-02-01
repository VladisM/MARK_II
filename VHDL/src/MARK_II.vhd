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
        --rs232
        uart1_rts: out std_logic:= '1';
        uart1_txd: out std_logic:= '1';
        uart1_dtr: out std_logic:= '1';
        uart1_dcd: in std_logic;
        uart1_dsr: in std_logic;
        uart1_rxd: in std_logic;
        uart1_cts: in std_logic;
        uart1_ri: in std_logic;
        
        --vga
        vga_hs: out std_logic:= '0';
        vga_vs: out std_logic:= '0';
        vga_r: out std_logic_vector(2 downto 0):= "000";
        vga_g: out std_logic_vector(2 downto 0):= "000";
        vga_b: out std_logic_vector(1 downto 0):= "00";
        
        --ps2 keyboard
        kb_clk: in std_logic;
        kb_dat: in std_logic;
        
        --ps2 mouse
        ms_clk: in std_logic;
        ms_dat: in std_logic;
                
        --debug uart
        uart0_txd: out std_logic:= '1';
        uart0_rxd: in std_logic;
        uart0_cbus: in std_logic_vector(1 downto 0);
        
        --ethernet
        enc_int: in std_logic;
        enc_cs: out std_logic:= '1';
        enc_si: out std_logic:= '0';
        enc_so: in std_logic;
        enc_sck: out std_logic:= '0';
        
        --audio
        i2s_bck: out std_logic:= '0';
        i2s_din: out std_logic:= '0';
        i2s_lrck: out std_logic:= '0';
        
        --i2c devices
        scl: inout std_logic:= 'Z';
        sda: inout std_logic:= 'Z';
        
        --rtc
        rtc_mfp: in std_logic;
        
        --microSD
        sd_dat: inout std_logic_vector(3 downto 0):= "ZZZZ";
        sd_cmd: out std_logic:= '0';
        sd_clk: out std_logic:= '0';
        
        --flash
        flash_cs: out std_logic:= '0';
        flash_sck: out std_logic:= '0';
        flash_so: in std_logic;
        flash_si: out std_logic:= '0';
        
        --sdram
        sdram_a: out std_logic_vector(12 downto 0):= '0' & x"000";
        sdram_dq: inout std_logic_vector(7 downto 0):= "ZZZZZZZZ";
        sdram_ba: out std_logic_vector(1 downto 0):= "00";
        sdram_ras: out std_logic:= '0';
        sdram_cas: out std_logic:= '0';
        sdram_we: out std_logic:= '0';
        sdram_clk: out std_logic:= '0';
        
        --expansion
        ex_cmd: out std_logic_vector(3 downto 0):= x"0";
        ex_dq: inout std_logic_vector(7 downto 0):= "ZZZZZZZZ";
        
        --oscil
        clk_25M: in std_logic;
        clk_18M432: in std_logic;
        clk_22M5792: in std_logic;
        
        --pwrmng
        pwrmng_rx: in std_logic;
        pwrmng_tx: out std_logic:= '1';
        pwrmng_res: in std_logic;
        
        --misc
        res: buffer std_logic:= '0'
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
            red: out std_logic_vector(2 downto 0);
            green: out std_logic_vector(2 downto 0);
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
            clk_sdram: out std_logic;
            clk_sdram_shift: out std_logic
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
			sdram_a: out std_logic_vector(12 downto 0);
			sdram_ba: out std_logic_vector(1 downto 0);
			sdram_dq: inout std_logic_vector(7 downto 0);
			sdram_ras: out std_logic;
			sdram_cas: out std_logic;
			sdram_we: out std_logic
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

    signal rom_ack, ram0_ack, ram1_ack, int_ack, systim_ack, vga_ack, uart0_ack, uart1_ack, uart2_ack, ps2_0_ack, ps2_1_ack, dram0_ack: std_logic;
	
    signal clk_uart, clk_vga, clk_sys, clk_audio, clk_sdram: std_logic;
	
begin
	
	--clk def
	clk_uart <= clk_18M432;
	clk_vga <= clk_25M;
	clk_sys <= clk_25M;
	clk_audio <= clk_22M5792;
	
	clkgen0: clkgen
		port map(pwrmng_res, clk_25M, res, clk_sdram, sdram_clk);
	
	--CPU parts
	cpu0: cpu
        port map(
			clk_sys, res, bus_address, bus_data_mosi, bus_data_miso, bus_WR, bus_RD,
			bus_ack, int_req(0), intCPUReq, intAddress, intAccepted, intCompleted
		);

    int0: intController
        generic map(x"00010F")
        port map(
			clk_sys, res, bus_address, bus_data_mosi, bus_data_miso, bus_WR, bus_RD,
			int_ack, int_req, intAccepted, intCompleted, intAddress, intCPUReq
		);

    systim0: systim
        generic map(x"000104")
        port map(
			clk_sys, res, bus_address, bus_data_mosi, bus_data_miso, bus_WR, bus_RD,
			systim_ack, int_req(1)
		);
	
	--peripherals
    rom0: rom
        generic map(x"000000")
        port map(
			clk_sys, res, bus_address, bus_data_mosi, bus_data_miso, bus_WR, bus_RD,
			rom_ack
		);

    ram0: ram
        generic map(x"000400", 10)
        port map(
			clk_sys, res, bus_address, bus_data_mosi, bus_data_miso, bus_WR, bus_RD,
			ram0_ack
		);

    uart0: uart
        generic map(x"000130")
        port map(
			clk_sys, res, bus_address, bus_data_mosi, bus_data_miso, bus_WR, bus_RD,
			uart0_ack, clk_uart, uart0_rxd, uart0_txd, int_req(8)
		);

    uart1: uart
        generic map(x"000134")
        port map(
			clk_sys, res, bus_address, bus_data_mosi, bus_data_miso, bus_WR, bus_RD,
			uart1_ack, clk_uart, uart1_rxd, uart1_txd, int_req(9)
		);

    uart2: uart
        generic map(x"000138")
        port map(
			clk_sys, res, bus_address, bus_data_mosi, bus_data_miso, bus_WR, bus_RD,
			uart2_ack, clk_uart, pwrmng_rx, pwrmng_tx, int_req(10)
		);

    vga0: vga
        generic map(x"001000")
        port map(
			clk_sys, res, bus_address, bus_data_mosi, bus_data_miso, bus_WR, bus_RD,
			vga_ack, clk_vga, vga_hs, vga_vs, vga_r, vga_g, vga_b
		);

    ps2_0: ps2
        generic map(x"000106")
        port map(
			clk_sys, res, bus_address, bus_data_miso, bus_RD,
			ps2_0_ack, kb_clk, kb_dat, int_req(11)
		);
	
	ps2_1: ps2
        generic map(x"000107")
        port map(
			clk_sys, res, bus_address, bus_data_miso, bus_RD,
			ps2_1_ack, ms_clk, ms_dat, int_req(12)
		);
    
    ram1: ram
        generic map(x"100000", 13)
        port map(
			clk_sys, res, bus_address, bus_data_mosi, bus_data_miso, bus_WR, bus_RD, 
			ram1_ack
		);
    
    dram0: sdram
		generic map(x"800000")
		port map(
			clk_sys, res, bus_address, bus_data_mosi, bus_data_miso, bus_WR, bus_RD,
			dram0_ack, clk_sdram,
			sdram_a, sdram_ba, sdram_dq, sdram_ras, sdram_cas, sdram_we
		);		
		
    bus_ack <=
		rom_ack or ram0_ack or ram1_ack or int_ack or systim_ack or vga_ack or 
		uart0_ack or uart1_ack or uart2_ack or ps2_0_ack or ps2_1_ack or dram0_ack;

end architecture MARK_II_arch;
