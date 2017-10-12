library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sdram is
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
end entity sdram;

architecture rtl of sdram is

    component SDRAM_Controller is
        generic (
          sdram_address_width : natural;
          sdram_column_bits   : natural;
          sdram_startup_cycles: natural;
          cycles_per_refresh  : natural
        );
        Port ( clk           : in  STD_LOGIC;
               reset         : in  STD_LOGIC;
               
               -- Interface to issue reads or write data
               cmd_ready         : out STD_LOGIC;                     -- '1' when a new command will be acted on
               cmd_enable        : in  STD_LOGIC;                     -- Set to '1' to issue new command (only acted on when cmd_read = '1')
               cmd_wr            : in  STD_LOGIC;                     -- Is this a write?
               cmd_address       : in  STD_LOGIC_VECTOR(sdram_address_width-2 downto 0); -- address to read/write
               cmd_byte_enable   : in  STD_LOGIC_VECTOR(3 downto 0);  -- byte masks for the write command
               cmd_data_in       : in  STD_LOGIC_VECTOR(31 downto 0); -- data for the write command
               
               data_out          : out STD_LOGIC_VECTOR(31 downto 0); -- word read from SDRAM
               data_out_ready    : out STD_LOGIC;                     -- is new data ready?
               
               -- SDRAM signals
               SDRAM_CLK     : out   STD_LOGIC;
               SDRAM_CKE     : out   STD_LOGIC;
               SDRAM_CS      : out   STD_LOGIC;
               SDRAM_RAS     : out   STD_LOGIC;
               SDRAM_CAS     : out   STD_LOGIC;
               SDRAM_WE      : out   STD_LOGIC;
               SDRAM_DQM     : out   STD_LOGIC_VECTOR( 1 downto 0);
               SDRAM_ADDR    : out   STD_LOGIC_VECTOR(12 downto 0);
               SDRAM_BA      : out   STD_LOGIC_VECTOR( 1 downto 0);
               SDRAM_DATA    : inout STD_LOGIC_VECTOR(15 downto 0));
    end component SDRAM_Controller;

    component fifo
        port (
            aclr        : in std_logic  := '0';
            data        : in std_logic_vector (54 downto 0);
            rdclk       : in std_logic ;
            rdreq       : in std_logic ;
            wrclk       : in std_logic ;
            wrreq       : in std_logic ;
            q           : out std_logic_vector (54 downto 0);
            rdempty     : out std_logic ;
            wrempty     : out std_logic 
        );
    end component;
    component fifo_rd_data
        port (
            aclr        : in std_logic  := '0';
            data        : in std_logic_vector (31 downto 0);
            rdclk       : in std_logic ;
            rdreq       : in std_logic ;
            wrclk       : in std_logic ;
            wrreq       : in std_logic ;
            q           : out std_logic_vector (31 downto 0);
            rdempty     : out std_logic ;
            wrempty     : out std_logic 
        );
    end component;
    component fifo_rd_addr
        port (
            aclr        : in std_logic  := '0';
            data        : in std_logic_vector (22 downto 0);
            rdclk       : in std_logic ;
            rdreq       : in std_logic ;
            wrclk       : in std_logic ;
            wrreq       : in std_logic ;
            q           : out std_logic_vector (22 downto 0);
            rdempty     : out std_logic ;
            wrempty     : out std_logic 
        );
    end component;
    
    component bus_interface is
        generic(
            BASE_ADDRESS: unsigned(23 downto 0) := x"000000"
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
            --fifos
            wrfifo_datain: out std_logic_vector(54 downto 0);
            wrfifo_write: out std_logic;
            wrfifo_wrempty: in std_logic;
            rdfifo_address_datain: out std_logic_vector(22 downto 0);
            rdfifo_address_we: out std_logic;
            rdfifo_address_wrempty: in std_logic;
            rdfifo_data_rdreq: out std_logic;
            rdfifo_data_dataout: in std_logic_vector(31 downto 0);
            rdfifo_data_rdempty: in std_logic
        );
    end component bus_interface;

    
    --control signals for sdram driver    
    signal cmd_ready         : std_logic;                     -- '1' when a new command will be acted on
    signal cmd_enable        : std_logic;                     -- set to '1' to issue new command (only acted on when cmd_read = '1')
    signal cmd_wr            : std_logic;                     -- is this a write?
    signal cmd_address       : std_logic_vector(22 downto 0); -- address to read/write
    signal cmd_data_in       : std_logic_vector(31 downto 0); -- data for the write command
    signal data_out          : std_logic_vector(31 downto 0); -- word read from sdram
    signal data_out_ready    : std_logic;                     -- is new data ready?
    
    signal data_mask : std_logic_vector(1 downto 0);
    
    -- following six signals are used for crossing clk domain in data write path
    
    -- these signals are come from writefifo into sdram clk domain
    signal wrfifo_dataout: std_logic_vector(54 downto 0);
    signal wrfifo_read: std_logic;
    signal wrfifo_rdempty: std_logic;    
    
    -- these signals are come from fifo into sys clk domain
    signal wrfifo_datain: std_logic_vector(54 downto 0);
    signal wrfifo_write: std_logic;
    signal wrfifo_wrempty: std_logic;
    
    -- these signals are come from fifo into sdram clk domain
    signal rdfifo_address_q: std_logic_vector(22 downto 0);
    signal rdfifo_address_rdempty: std_logic;
    signal rdfifo_address_rdreq: std_logic;
    
    -- these signal are come from rdfifo into system clk domain
    signal rdfifo_address_datain: std_logic_vector(22 downto 0);
    signal rdfifo_address_we: std_logic;
    signal rdfifo_address_wrempty: std_logic;
    
    -- these signlas are come from sdram clk domain into fifo
    signal rdfifo_data_datain: std_logic_vector(31 downto 0);
    signal rdfifo_data_wrreq: std_logic;
    signal rdfifo_data_wremty: std_logic;
    
    -- these signals are come from system clk domain into fifo
    signal rdfifo_data_dataout: std_logic_vector(31 downto 0);
    signal rdfifo_data_rdreq: std_logic;
    signal rdfifo_data_rdempty: std_logic;
    
    constant clk_freq_mhz : natural := 100;
    
    
    type fsm_state_type is (idle, wrcmd_fifo, wrcmd_write, wrcmd_wait, rdcmd_fiforead, rdcmd_read, rdcmd_wait, rdcmd_fifowrite);
    signal fsm_state: fsm_state_type;
    
begin
    
    
    ----------------------------
    -- SDRAM CLK domain
  
    dram0: SDRAM_Controller
        generic map(
            24, 9, 101 * clk_freq_mhz, (64000*clk_freq_mhz)/8192-1
        )
        port map(
            clk_sdram, res,
            
            cmd_ready, cmd_enable, cmd_wr, cmd_address, "1111", 
            cmd_data_in, data_out, data_out_ready,
            
            open, clock_enable, cs_n, ras_n, cas_n, we_n, 
            data_mask, addr, bank_addr, data            
            
        );
        
    rdfifo_data_datain <= data_out;
    cmd_data_in <= wrfifo_dataout(31 downto 0);
    cmd_address <= wrfifo_dataout(54 downto 32) when cmd_wr = '1' else rdfifo_address_q;
    
    data_mask_low <= data_mask(0);
    data_mask_high <= data_mask(1);
    
    --~ signal rdfifo_address_rdempty: std_logic;
    --~ signal rdfifo_data_wremty: std_logic;
    --~ signal wrfifo_rdempty: std_logic;    
    --~ cmd_ready
    --~ data_out_ready
    
    process(clk_sdram) is
    begin
        if rising_edge(clk_sdram) then
            if res = '1' then
                fsm_state <= idle;
            else
                case fsm_state is
                    when idle =>
                        if cmd_ready = '1' then
                            if wrfifo_rdempty = '0' then
                                fsm_state <= wrcmd_fifo;
                            elsif rdfifo_address_rdempty = '0' then
                                fsm_state <= rdcmd_fiforead;
                            else
                                fsm_state <= idle;
                            end if;
                        else
                            fsm_state <= idle;
                        end if;
                    when wrcmd_fifo =>
                        fsm_state <= wrcmd_write;
                    when wrcmd_write =>
                        fsm_state <= wrcmd_wait;
                    when wrcmd_wait =>
                        if cmd_ready = '1' then
                            fsm_state <= idle;
                        else
                            fsm_state <= wrcmd_wait;
                        end if;                        
                    when rdcmd_fiforead =>
                        fsm_state <= rdcmd_read;
                    when rdcmd_read =>
                        fsm_state <= rdcmd_wait;
                    when rdcmd_wait =>
                        if data_out_ready = '1' then 
                            if rdfifo_data_wremty = '1' then
                                fsm_state <= rdcmd_fifowrite;
                            else
                                fsm_state <= rdcmd_wait;
                            end if;
                        else
                            fsm_state <= rdcmd_wait;
                        end if;
                    when rdcmd_fifowrite =>
                        fsm_state <= idle;
                end case;
            end if;
        end if;
    end process;
    
    process(fsm_state) is
    begin
        case fsm_state is
            when idle =>
                cmd_enable <= '0'; cmd_wr <= '0'; rdfifo_address_rdreq <= '0'; rdfifo_data_wrreq <= '0'; wrfifo_read <= '0';
            when wrcmd_fifo =>
                cmd_enable <= '0'; cmd_wr <= '1'; rdfifo_address_rdreq <= '0'; rdfifo_data_wrreq <= '0'; wrfifo_read <= '1';
            when wrcmd_write =>
                cmd_enable <= '1'; cmd_wr <= '1'; rdfifo_address_rdreq <= '0'; rdfifo_data_wrreq <= '0'; wrfifo_read <= '0';
            when wrcmd_wait =>
                cmd_enable <= '0'; cmd_wr <= '0'; rdfifo_address_rdreq <= '0'; rdfifo_data_wrreq <= '0'; wrfifo_read <= '0';
            when rdcmd_fiforead =>
                cmd_enable <= '0'; cmd_wr <= '0'; rdfifo_address_rdreq <= '1'; rdfifo_data_wrreq <= '0'; wrfifo_read <= '0';
            when rdcmd_read =>
                cmd_enable <= '1'; cmd_wr <= '0'; rdfifo_address_rdreq <= '0'; rdfifo_data_wrreq <= '0'; wrfifo_read <= '0';
            when rdcmd_wait =>
                cmd_enable <= '0'; cmd_wr <= '0'; rdfifo_address_rdreq <= '0'; rdfifo_data_wrreq <= '0'; wrfifo_read <= '0';
            when rdcmd_fifowrite =>
                cmd_enable <= '0'; cmd_wr <= '0'; rdfifo_address_rdreq <= '0'; rdfifo_data_wrreq <= '1'; wrfifo_read <= '0';
        end case;
    end process;
    
    --~ cmd_enable
    --~ cmd_wr
    --~ signal rdfifo_address_rdreq: std_logic;
    --~ signal rdfifo_data_wrreq: std_logic;
    --~ signal wrfifo_read: std_logic;
    
    
    ----------------------------    
    -- CLK domain crossing
    
    wrfifo0: fifo
        port map(
            res, wrfifo_datain, clk_sdram, wrfifo_read, clk, 
            wrfifo_write, wrfifo_dataout, wrfifo_rdempty, 
            wrfifo_wrempty
        );        
                
    rdfifo_address0: fifo_rd_addr
        port map(            
            res, rdfifo_address_datain, clk_sdram, rdfifo_address_rdreq, clk, 
            rdfifo_address_we, rdfifo_address_q, rdfifo_address_rdempty,
            rdfifo_address_wrempty
        );
        
    rdfifo_data0: fifo_rd_data
        port map(
            res, rdfifo_data_datain, clk, rdfifo_data_rdreq, clk_sdram, 
            rdfifo_data_wrreq, rdfifo_data_dataout, rdfifo_data_rdempty,
            rdfifo_data_wremty        
        );
    
    ----------------------------    
    -- System CLK domain

    bi0: bus_interface
        generic map(
            BASE_ADDRESS
        )
        port map(
            clk, res, address, data_mosi, data_miso, WR, RD, ack, 
            wrfifo_datain, wrfifo_write, wrfifo_wrempty, 
            rdfifo_address_datain, rdfifo_address_we, 
            rdfifo_address_wrempty, rdfifo_data_rdreq, 
            rdfifo_data_dataout, rdfifo_data_rdempty        
        );
        
end architecture rtl;      
