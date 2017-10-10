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

    component sdram_controller
         generic(
              row_width: integer:= 13;
              col_width: integer:= 9;
              bank_width: integer:= 2;
              sdraddr_width: integer:= 13;
              haddr_width: integer:= 24;
              clk_frequency: integer:= 133;
              refresh_time: integer:= 32;
              refresh_count: integer:= 8192
         );
         port(
              wr_addr: in std_logic_vector(haddr_width-1 downto 0);
              wr_data: in std_logic_vector(15 downto 0);
              wr_enable: in std_logic;

              rd_addr: in std_logic_vector(haddr_width-1 downto 0);
              rd_data: out std_logic_vector(15 downto 0);
              rd_ready: out std_logic;
              rd_enable: in std_logic;

              busy: out std_logic;

              rst_n: in std_logic;
              clk: in std_logic;

              addr: out std_logic_vector(sdraddr_width-1 downto 0);
              bank_addr: out std_logic_vector(bank_width-1 downto 0);
              data: inout std_logic_vector(15 downto 0);
              clock_enable: out std_logic;
              cs_n: out std_logic;
              ras_n: out std_logic;
              cas_n: out std_logic;
              we_n: out std_logic;
              data_mask_low: out std_logic;
              data_mask_high: out std_logic
         );
    end component;
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
    
    component writer is
        port(
            --system
            clk: in std_logic;
            res: in std_logic;
            --fifo interface
            wrfifo_read: out std_logic;
            wrfifo_dataout: in std_logic_vector(54 downto 0);
            wrfifo_rdempty: in std_logic;    
            --sdram interface
            wr_addr: out std_logic_vector(23 downto 0);
            wr_data: out std_logic_vector(15 downto 0);
            wr_enable: out std_logic;
            busy: in std_logic
        );
    end component writer;
    
    component reader is
        port(
            -- system
            clk: in std_logic;
            res: in std_logic;
            -- fifo
            rdfifo_address_q: in std_logic_vector(22 downto 0);
            rdfifo_address_rdempty: in std_logic;
            rdfifo_address_rdreq: out std_logic;    
            rdfifo_data_datain: out std_logic_vector(31 downto 0);
            rdfifo_data_wremty: in std_logic;
            rdfifo_data_wrreq: out std_logic;
            -- sdram
            rd_addr: out std_logic_vector(23 downto 0);
            rd_data: in std_logic_vector(15 downto 0);
            rd_ready: in std_logic;
            rd_enable: out std_logic;
            busy: in std_logic
        );
    end component reader;
    
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


    --reset signal for sdram driver
    signal rst_n: std_logic;
    
    --control signals for sdram driver    
    signal wr_addr: std_logic_vector(23 downto 0);
    signal wr_data: std_logic_vector(15 downto 0);
    signal wr_enable: std_logic;
    signal rd_addr: std_logic_vector(23 downto 0);
    signal rd_data: std_logic_vector(15 downto 0);
    signal rd_ready: std_logic;
    signal rd_enable: std_logic;
    signal busy: std_logic;
    
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
    
begin
    
    rst_n <= not(res);
    
    ----------------------------
    -- SDRAM CLK domain
    
    sd0: sdram_controller
        generic map(13, 9, 2, 13, 24, 133, 32, 8192)
        port map(
            wr_addr, wr_data, wr_enable, rd_addr, rd_data, rd_ready,
            rd_enable, busy, rst_n, clk_sdram, addr, bank_addr, data,
            clock_enable, cs_n, ras_n, cas_n, we_n, data_mask_low,
            data_mask_high
        );
    
    wr0: writer
        port map(        
            clk_sdram, res, wrfifo_read, wrfifo_dataout, 
            wrfifo_rdempty, wr_addr, wr_data, wr_enable, busy        
        );
        
    rd0: reader
        port map(
            clk_sdram, res, rdfifo_address_q, rdfifo_address_rdempty,
            rdfifo_address_rdreq, rdfifo_data_datain, rdfifo_data_wremty,
            rdfifo_data_wrreq, rd_addr, rd_data, rd_ready, rd_enable, busy
        );
        
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
