library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity timer is
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
end entity;

architecture timer_arch of timer is

    component core is
        port(
            clk: in std_logic;
            res: in std_logic;
            aclear: in std_logic;
            pwma: out std_logic;
            pwmb: out std_logic;
            intrq: out std_logic;
            control: in std_logic_vector(6 downto 0);
            ocra: in unsigned(15 downto 0);
            ocrb: in unsigned(15 downto 0);
            timerCount: out unsigned(15 downto 0);
            enclk2: in std_logic;
            enclk4: in std_logic;
            enclk8: in std_logic
        );
    end component core;
    
    component timer_int_fsm is
        port(
            clk: in std_logic;
            res: in std_logic;
            int_raw: in std_logic;
            intrq: out std_logic
        );
    end component timer_int_fsm;

    signal reg_sel: std_logic_vector(3 downto 0);
    signal OCRAreg, OCRBreg: unsigned(15 downto 0);
    signal TCCR: std_logic_vector(6 downto 0);
    signal clear_from_write, int_raw: std_logic;
    signal timerValue: unsigned(15 downto 0);
    
begin

    core0: core
        port map(clk, res, clear_from_write, pwma, pwmb, int_raw, TCCR, OCRAreg, OCRBreg, timerValue, enclk2, enclk4, enclk8);
        
    intfsm: timer_int_fsm
        port map(clk, res, int_raw, intrq);
    
    --chip select
    process(address) is begin
        if (address = BASE_ADDRESS)then
            reg_sel <= "0001"; -- TCCR
        elsif (address = (BASE_ADDRESS + 1)) then
            reg_sel <= "0010"; -- OCRA
        elsif (address = (BASE_ADDRESS + 2)) then
            reg_sel <= "0100"; -- OCRB
        elsif (address = (BASE_ADDRESS + 3)) then
            reg_sel <= "1000"; -- TCR
        else
            reg_sel <= "0000";
        end if;
    end process;
    
    --registers
    process(clk, res, WR, data_mosi, reg_sel) is begin
        if rising_edge(clk) then
            if res = '1' then
                OCRAreg <= x"0000";
                OCRBreg <= x"0000";
                TCCR <= "0000000";
            elsif(reg_sel = "0001" and WR = '1') then
                TCCR <= std_logic_vector(data_mosi(6 downto 0));
            elsif(reg_sel = "0010" and WR = '1') then
                OCRAreg <= data_mosi(15 downto 0);
            elsif(reg_sel = "0100" and WR = '1') then
                OCRBreg <= data_mosi(15 downto 0);
            end if;
        end if;
    end process;
    
    --output from registers
    data_miso <= x"000000" & "0" & unsigned(TCCR) when (RD = '1' and reg_sel = "0001") else
                 x"0000"         & OCRAreg        when (RD = '1' and reg_sel = "0010") else 
                 x"0000"         & OCRBreg        when (RD = '1' and reg_sel = "0100") else
                 x"0000"         & timerValue     when (RD = '1' and reg_sel = "1000") else (others => 'Z');
    
    ack <= '1' when ((WR = '1' and reg_sel /= "0000") or (RD = '1' and reg_sel /= "0000")) else 'Z';
    
    
    --generate signal whenever there is write acces
    process(WR, reg_sel) is begin
        if(WR = '1' and reg_sel = "1000") then
            clear_from_write <= '1';
        else
            clear_from_write <= '0';
        end if;
    end process;
    
end architecture timer_arch;      



library ieee;
use ieee.std_logic_1164.all;

entity timer_int_fsm is
    port(
        clk: in std_logic;
        res: in std_logic;
        int_raw: in std_logic;
        intrq: out std_logic
    );
end entity timer_int_fsm;

architecture timer_int_fsm_arch of timer_int_fsm is
    type statetype is (idle, intcome, waittocompleted);
    signal state: statetype;
begin
    process(clk, res, int_raw) is
    begin
        if(rising_edge(clk)) then
            if(res = '1') then 
                state <= idle;
            else
                case state is
                    when idle =>
                        if (int_raw = '1') then
                            state <= intcome;
                        else
                            state <= idle;
                        end if;
                    when intcome => state <= waittocompleted;
                    when waittocompleted =>
                        if(int_raw = '1') then 
                            state <= waittocompleted;
                        else
                            state <= idle;
                        end if;
                end case;
            end if;
        end if;
    end process;
    
    process(state) is begin
        case state is
            when idle => intrq <= '0';
            when intcome => intrq <= '1';
            when waittocompleted => intrq <= '0';
        end case;
    end process;
    
end architecture timer_int_fsm_arch;
