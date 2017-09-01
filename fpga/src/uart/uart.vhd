-- Top level entity of UART peripheral.
--
-- Part of MARK II project. For informations about license, please
-- see file /LICENSE .
--
-- author: Vladislav Mlejnecký
-- email: v.mlejnecky@seznam.cz

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart is
    generic(
        BASE_ADDRESS: unsigned(23 downto 0) := x"000000"    --base address of UART
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
        clk_uart: in std_logic;
        rx: in std_logic;
        tx: out std_logic;
        intrq: out std_logic
    );
end entity uart;

architecture uart_arch of uart is

    component flag is
        port(
            clk: in std_logic;
            res: in std_logic;
            set: in std_logic;
            clear: in std_logic;
            q: out std_logic
        );
    end component flag;

    component uart_core is
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
    end component uart_core;

    signal reg_sel: std_logic_vector(3 downto 0);

    signal rx_data_output: unsigned(7 downto 0);
    signal rx_data_count: unsigned(5 downto 0);
    signal rx_data_rdreq: std_logic;
    signal tx_data_input: unsigned(7 downto 0);
    signal tx_data_count: unsigned(5 downto 0);
    signal tx_data_wrreq: std_logic;
    signal n: unsigned(15 downto 0);
    signal txen: std_logic;
    signal rxen: std_logic;
    signal tx_done: std_logic;
    signal rx_done: std_logic;

    signal control_reg: std_logic_vector(24 downto 0);

    signal tx_intrq, tx_halfbuff_intrq, tx_emptybuff_intrq: std_logic;
    signal rx_intrq, rx_halfbuff_intrq, rx_fullbuff_intrq: std_logic;

    signal tx_int_flag, tx_int_buffhalf_flag, tx_int_buffempty_flag: std_logic;
    signal rx_int_flag, rx_int_buffhalf_flag, rx_int_bufffull_flag: std_logic;

    signal tx_buff_empty, tx_buff_half, rx_buff_full, rx_buff_half: std_logic;

    signal status_reg: std_logic_vector(17 downto 0);
    signal flagread: std_logic;

    type fsm_state_type is (idle, write0, write1, write2, read0, read1, read2);
    signal fsm_state: fsm_state_type;


begin

    --chip select
    process(address) is begin
        if (address = BASE_ADDRESS)then
            reg_sel <= "0001";  --TX reg
        elsif (address = (BASE_ADDRESS + 1)) then
            reg_sel <= "0010";  --RX reg
        elsif (address = (BASE_ADDRESS + 2)) then
            reg_sel <= "0100";  --status reg
        elsif (address = (BASE_ADDRESS + 3)) then
            reg_sel <= "1000";  --control reg
        else
            reg_sel <= "0000";
        end if;
    end process;

    uart_core0: uart_core
        port map(clk, clk_uart, res, tx, rx, rx_data_output, rx_data_count, rx_data_rdreq,
                 tx_data_input, tx_data_count, tx_data_wrreq, unsigned(control_reg(15 downto 0)),
                 control_reg(17), control_reg(16), tx_done, rx_done);

    intrq <= control_reg(18) and (tx_intrq or tx_halfbuff_intrq or tx_emptybuff_intrq
                                  or rx_intrq or rx_halfbuff_intrq or rx_fullbuff_intrq);

    tx_intrq <= control_reg(24) and tx_done and not(tx_int_flag);
    tx_halfbuff_intrq <= control_reg(23) and tx_buff_half and not(tx_int_buffhalf_flag);
    tx_emptybuff_intrq <= control_reg(22) and tx_buff_empty and not(tx_int_buffempty_flag);
    rx_intrq <= control_reg(21) and rx_done and not(rx_int_flag);
    rx_halfbuff_intrq <= control_reg(20) and rx_buff_half and not(rx_int_buffhalf_flag);
    rx_fullbuff_intrq <= control_reg(19) and rx_buff_full and not(rx_int_bufffull_flag);

    process(tx_data_count) is
    begin
        if tx_data_count = "000000" then
            tx_buff_empty <= '1';
        else
            tx_buff_empty <= '0';
        end if;
    end process;

    process(tx_data_count) is
    begin
        if tx_data_count = "010000" then
            tx_buff_half <= '1';
        else
            tx_buff_half <= '0';
        end if;
    end process;

    process(rx_data_count) is
    begin
        if rx_data_count = "100000" then
            rx_buff_full <= '1';
        else
            rx_buff_full <= '0';
        end if;
    end process;

    process(rx_data_count) is
    begin
        if rx_data_count = "010000" then
            rx_buff_half <= '1';
        else
            rx_buff_half <= '0';
        end if;
    end process;


    flag_tx_int: flag
        port map(clk, res, tx_intrq, flagread, tx_int_flag);

    flag_tx_buffhalf_int: flag
        port map(clk, res, tx_halfbuff_intrq, flagread, tx_int_buffhalf_flag);

    flag_tx_bufffull_int: flag
        port map(clk, res, tx_emptybuff_intrq, flagread, tx_int_buffempty_flag);

    flag_rx_int: flag
        port map(clk, res, rx_intrq, flagread, rx_int_flag);

    flag_rx_buffhalf_int: flag
        port map(clk, res, rx_halfbuff_intrq, flagread, rx_int_buffhalf_flag);

    flag_rx_bufffull_int: flag
        port map(clk, res, rx_fullbuff_intrq, flagread, rx_int_bufffull_flag);

    process(clk) is
        variable control_reg_v: std_logic_vector(24 downto 0);
    begin
        if rising_edge(clk) then
            if res = '1' then
                control_reg_v := (others => '0');
            elsif ((WR = '1') and (reg_sel = "1000")) then
                control_reg_v := std_logic_vector(data_mosi(24 downto 0));
            end if;
        end if;
        control_reg <= control_reg_v;
    end process;

    status_reg(5 downto 0) <= std_logic_vector(rx_data_count);
    status_reg(11 downto 6) <= std_logic_vector(tx_data_count);
    status_reg(12) <= rx_int_bufffull_flag;
    status_reg(13) <= rx_int_buffhalf_flag;
    status_reg(14) <= rx_int_flag;
    status_reg(15) <= tx_int_buffempty_flag;
    status_reg(16) <= tx_int_buffhalf_flag;
    status_reg(17) <= tx_int_flag;

    process(RD, reg_sel) is
    begin
        if((RD = '1') and (reg_sel = "0100")) then
            flagread <= '1';
        else
            flagread <= '0';
        end if;
    end process;

    process(clk) is
    begin
        if rising_edge(clk) then
            if res = '1' then
                fsm_state <= idle;
            else
                case fsm_state is
                    when idle =>
                        if ((RD = '1') and (reg_sel /= "0000")) then
                            case reg_sel is
                                when "0010" => fsm_state <= read1;
                                when others => fsm_state <= read0;
                            end case;
                        elsif ((WR = '1') and (reg_sel /= "0000")) then
                            case reg_sel is
                                when "0001" => fsm_state <= write1;
                                when others => fsm_state <= write0;
                            end case;
                        else
                            fsm_state <= idle;
                        end if;
                    when write0 =>
                        case WR is
                            when '1' => fsm_state <= write0;
                            when others => fsm_state <= idle;
                        end case;
                    when write1 => fsm_state <= write2;
                    when write2 =>
                        case WR is
                            when '1' => fsm_state <= write2;
                            when others => fsm_state <= idle;
                        end case;
                    when read0 =>
                        case RD is
                            when '1' => fsm_state <= read0;
                            when others => fsm_state <= idle;
                        end case;
                    when read1 => fsm_state <= read2;
                    when read2 =>
                        case RD is
                            when '1' => fsm_state <= read2;
                            when others => fsm_state <= idle;
                        end case;
                end case;
            end if;
        end if;
    end process;

    process(fsm_state, reg_sel, rx_data_output, status_reg, control_reg) is
    begin
        case fsm_state is
            when idle=>
                data_miso <= (others => 'Z');
                ack <= '0';
                tx_data_wrreq <= '0';
                rx_data_rdreq <= '0';

            when write0=>
                data_miso <= (others => 'Z');
                ack <= '1';
                tx_data_wrreq <= '0';
                rx_data_rdreq <= '0';

            when write1=>
                data_miso <= (others => 'Z');
                ack <= '0';
                tx_data_wrreq <= '1';
                rx_data_rdreq <= '0';

            when write2=>
                data_miso <= (others => 'Z');
                ack <= '1';
                tx_data_wrreq <= '0';
                rx_data_rdreq <= '0';

            when read0=>
                case reg_sel is
                    when "0001" => data_miso <= (others => 'Z');
                    when "0100" => data_miso <= x"00" & "000000" & unsigned(status_reg);
                    when "1000" => data_miso <= "0000000" & unsigned(control_reg);
                    when others => data_miso <= (others => 'Z');
                end case;
                ack <= '1';
                tx_data_wrreq <= '0';
                rx_data_rdreq <= '0';

            when read1=>
                data_miso <= x"000000" & rx_data_output;
                ack <= '0';
                tx_data_wrreq <= '0';
                rx_data_rdreq <= '1';

            when read2=>
                data_miso <= x"000000" & rx_data_output;
                ack <= '1';
                tx_data_wrreq <= '0';
                rx_data_rdreq <= '0';

        end case;
    end process;

    tx_data_input <= data_mosi(7 downto 0);

end architecture uart_arch;




library ieee;
use ieee.std_logic_1164.all;

entity flag is
    port(
        clk: in std_logic;
        res: in std_logic;
        set: in std_logic;
        clear: in std_logic;
        q: out std_logic
    );
end entity flag;

architecture flag_arch of flag is

begin

    process(clk) is
        variable flag_v: std_logic;
    begin
        if rising_edge(clk) then
            if ((res = '1') or (clear = '1')) then
                flag_v := '0';
            elsif set = '1' then
                flag_v := '1';
            end if;
        end if;

        q <= flag_v;
    end process;

end architecture flag_arch;


