-- Core for UART
--
-- Part of MARK II project. For informations about license, please
-- see file /LICENSE .
--
-- author: Vladislav Mlejnecký
-- email: v.mlejnecky@seznam.cz

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_core is
    port(
        clk_sys: in std_logic;      --system clock
        clk_uart: in std_logic;     --uart clock (14,4?)
        res: in std_logic;          --reset
        tx: out std_logic;          --tx TLE pin
        rx: in std_logic;           --rx TLE pin

        rx_data_output: out unsigned(7 downto 0); --rx data read from fifo
        rx_data_count: out unsigned(5 downto 0);  --byte count in fifo
        rx_data_rdreq: in std_logic;              --request read from rx fifo

        tx_data_input: in unsigned(7 downto 0);   --tx data write into fifo
        tx_data_count: out unsigned(5 downto 0);  --byte count in tx fifo
        tx_data_wrreq: in std_logic;              --request write into tx fifo

        n: in unsigned(15 downto 0);    --control signals
        txen: in std_logic;
        rxen: in std_logic;

        tx_done: out std_logic; --byte sended
        rx_done: out std_logic --byte recieved
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
            en: in std_logic;
            clk: in std_logic;
            res: in std_logic;
            baud16_clk_en: in std_logic;
            tx_data: in unsigned(7 downto 0);
            tx: out std_logic;
            tx_dcfifo_rdreq: out std_logic;
            tx_dcfifo_rdusedw: in std_logic_vector(5 downto 0);
            tx_sended: out std_logic
        );
    end component transmitter;

    component reciever is
        port(
            en: in std_logic;
            clk: in std_logic;
            res: in std_logic;
            rx: in std_logic;
            baud16_clk_en: in std_logic;
            rx_data: out unsigned(7 downto 0);
            rx_done: out std_logic
        );
    end component reciever;

    component dcfifo is
        generic(
            intended_device_family: string;
            lpm_numwords: natural;
            lpm_showahead: string;
            lpm_type: string;
            lpm_width: natural;
            lpm_widthu: natural;
            overflow_checking: string;
            rdsync_delaypipe: natural;
            read_aclr_synch: string;
            underflow_checking: string;
            use_eab: string;
            write_aclr_synch: string;
            wrsync_delaypipe: natural;
            add_usedw_msb_bit: string
        );
        port(
            rdclk   : in std_logic ;
            q       : out std_logic_vector (7 downto 0);
            wrclk   : in std_logic ;
            wrreq   : in std_logic ;
            wrusedw : out std_logic_vector (5 downto 0);
            aclr    : in std_logic ;
            data    : in std_logic_vector (7 downto 0);
            rdreq   : in std_logic ;
            rdusedw : out std_logic_vector (5 downto 0)
        );
    end component;

    signal baud16_clk_en: std_logic;
    signal rx_data: unsigned(7 downto 0);
    signal rx_dcfifo_q: std_logic_vector(7 downto 0);
    signal rx_dcfifo_rdusedw: std_logic_vector(5 downto 0);
    signal tx_dcfifo_data: std_logic_vector(7 downto 0);
    signal tx_dcfifo_wrusedw: std_logic_vector(5 downto 0);
    signal tx_data: unsigned(7 downto 0);
    signal tx_dcfifo_rdreq: std_logic;
    signal tx_dcfifo_rdusedw: std_logic_vector(5 downto 0);
    signal n_uart: unsigned(15 downto 0);
    signal rx_dcfifo_data: std_logic_vector(7 downto 0);
    signal tx_dcfifo_q: std_logic_vector(7 downto 0);
    signal tx_en_sync, rx_en_sync: std_logic;
    signal rx_done_uart, tx_done_uart: std_logic;

    signal rx_done_raw, tx_done_raw: std_logic;

    type statetype is (idle, come, waittocompleted);
    signal tx_done_state: statetype;
    signal rx_done_state: statetype;

begin

    --clk_uart domain

    baudgen0: baudgen
        port map(clk_uart, res, n_uart, baud16_clk_en);

    transmitter0: transmitter
        port map(tx_en_sync, clk_uart, res, baud16_clk_en, tx_data, tx, tx_dcfifo_rdreq, tx_dcfifo_rdusedw, tx_done_uart);

    reciever0: reciever
        port map(rx_en_sync, clk_uart, res, rx, baud16_clk_en, rx_data, rx_done_uart);

    rx_dcfifo_data <= std_logic_vector(rx_data);
    tx_data <= unsigned(tx_dcfifo_q);

    --crossing clk domains

    rx_dcfifo : dcfifo
    generic map (
        intended_device_family => "cyclone iv e",
        lpm_numwords => 32,
        lpm_showahead => "off",
        lpm_type => "dcfifo",
        lpm_width => 8,
        lpm_widthu => 6,
        overflow_checking => "on",
        rdsync_delaypipe => 4,
        read_aclr_synch => "on",
        underflow_checking => "on",
        use_eab => "on",
        write_aclr_synch => "on",
        wrsync_delaypipe => 4,
        add_usedw_msb_bit => "ON"
    )
    port map (
        rdclk => clk_sys,
        wrclk => clk_uart,
        wrreq => rx_done_uart,
        aclr => res,
        data => rx_dcfifo_data,
        rdreq => rx_data_rdreq,
        q => rx_dcfifo_q,
        wrusedw => open,
        rdusedw => rx_dcfifo_rdusedw
    );

    tx_dcfifo : dcfifo
    generic map (
        intended_device_family => "cyclone iv e",
        lpm_numwords => 32,
        lpm_showahead => "off",
        lpm_type => "dcfifo",
        lpm_width => 8,
        lpm_widthu => 6,
        overflow_checking => "on",
        rdsync_delaypipe => 4,
        read_aclr_synch => "on",
        underflow_checking => "on",
        use_eab => "on",
        write_aclr_synch => "on",
        wrsync_delaypipe => 4,
        add_usedw_msb_bit => "ON"
    )
    port map (
        rdclk => clk_uart,
        wrclk => clk_sys,
        wrreq => tx_data_wrreq,
        aclr => res,
        data => tx_dcfifo_data,
        rdreq => tx_dcfifo_rdreq,
        q => tx_dcfifo_q,
        wrusedw => tx_dcfifo_wrusedw,
        rdusedw => tx_dcfifo_rdusedw
    );

    --from sys to uart
    process(clk_uart) is
        variable n_d1: unsigned(15 downto 0);
        variable n_d2: unsigned(15 downto 0);
        variable txen_1: std_logic;
        variable txen_2: std_logic;
        variable rxen_1: std_logic;
        variable rxen_2: std_logic;
    begin
        if rising_edge(clk_uart) then
            if res = '1' then
                n_d1 := (others => '0');
                n_d2 := (others => '0');
                txen_1 := '0';
                txen_2 := '0';
                rxen_1 := '0';
                rxen_2 := '0';
            else
                n_d2 := n_d1;
                n_d1 := n;
                txen_2 := txen_1;
                txen_1 := txen;
                rxen_2 := rxen_1;
                rxen_1 := rxen;
            end if;
        end if;

        n_uart <= n_d2;
        rx_en_sync <= rxen_2;
        tx_en_sync <= txen_2;
    end process;

    --from uart to sys
    process(clk_sys) is
        variable rx_done_1: std_logic;
        variable rx_done_2: std_logic;
        variable tx_done_1: std_logic;
        variable tx_done_2: std_logic;
    begin
        if rising_edge(clk_sys) then
            if res = '1' then
                rx_done_2 := '0';
                rx_done_1 := '0';
                tx_done_2 := '0';
                tx_done_1 := '0';
            else
                rx_done_2 := rx_done_1;
                rx_done_1 := rx_done_uart;
                tx_done_2 := tx_done_1;
                tx_done_1 := tx_done_uart;
            end if;
        end if;
        tx_done_raw <= tx_done_2;
        rx_done_raw <= rx_done_2;
    end process;

    --sysclk domain

    rx_data_output <= unsigned(rx_dcfifo_q);
    rx_data_count <= unsigned(rx_dcfifo_rdusedw);

    tx_dcfifo_data <= std_logic_vector(tx_data_input);
    tx_data_count <= unsigned(tx_dcfifo_wrusedw);

    process(clk_sys) is
    begin
        if(rising_edge(clk_sys)) then
            if(res = '1') then
                tx_done_state <= idle;
            else
                case tx_done_state is
                    when idle =>
                        if (tx_done_raw = '1') then
                            tx_done_state <= come;
                        else
                            tx_done_state <= idle;
                        end if;
                    when come => tx_done_state <= waittocompleted;
                    when waittocompleted =>
                        if(tx_done_raw = '1') then
                            tx_done_state <= waittocompleted;
                        else
                            tx_done_state <= idle;
                        end if;
                end case;
            end if;
        end if;
    end process;

    process(tx_done_state) is
    begin
        case tx_done_state is
            when idle => tx_done <= '0';
            when come => tx_done <= '1';
            when waittocompleted => tx_done <= '0';
        end case;
    end process;

    process(clk_sys) is
    begin
        if(rising_edge(clk_sys)) then
            if(res = '1') then
                rx_done_state <= idle;
            else
                case rx_done_state is
                    when idle =>
                        if (rx_done_raw = '1') then
                            rx_done_state <= come;
                        else
                            rx_done_state <= idle;
                        end if;
                    when come => rx_done_state <= waittocompleted;
                    when waittocompleted =>
                        if(rx_done_raw = '1') then
                            rx_done_state <= waittocompleted;
                        else
                            rx_done_state <= idle;
                        end if;
                end case;
            end if;
        end if;
    end process;

    process(rx_done_state) is
    begin
        case rx_done_state is
            when idle => rx_done <= '0';
            when come => rx_done <= '1';
            when waittocompleted => rx_done <= '0';
        end case;
    end process;

end architecture uart_core_arch;

