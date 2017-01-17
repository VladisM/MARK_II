library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity timer is
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
        clk_timer: in std_logic;
        pwma: out std_logic;
        pwmb: out std_logic;
        intrq: out std_logic
    );
end entity;

architecture timer_arch of timer is
    --control signals for timer
    signal timeren,en_compare_match_intrq,pwmen,en_overflow_intrq,en_clear_on_compare_match: std_logic;
    
    signal overflow: std_logic;
    signal counter: unsigned(15 downto 0);
    
    signal compare_match_a: std_logic;
    signal compare_match_b: std_logic;
    
    signal OCRAreg: unsigned(15 downto 0);
    signal OCRBreg: unsigned(15 downto 0);
    signal TCCR: unsigned(4 downto 0);
    
    signal reg_sel: std_logic_vector(3 downto 0);
    
    signal clear: std_logic;
    
begin

    --this is core timer
    process (clk_timer, res, clear, reg_sel, WR, data_mosi)
        variable cnt: unsigned(16 downto 0) := (others => '0');
    begin
        if (clear = '1') then
            cnt := (others => '0');
        elsif(reg_sel = "1000" and WR = '1') then --preset
            cnt := '0' & unsigned(data_mosi(15 downto 0));
        elsif(rising_edge(clk_timer)) then
            if(timeren = '1') then
                cnt := cnt + 1;
            end if;
        end if;
        
        counter <= cnt(15 downto 0);
        overflow <= cnt(16);
    end process;

    --comparator for OCRA
    process(OCRAreg, counter) is begin
        if(counter = OCRAreg) then
            compare_match_a <= '1';
        else
            compare_match_a <= '0';
        end if;
    end process;
    
    --comparator for OCRB
    process(OCRBreg, counter) is begin
        if(counter = OCRBreg) then
            compare_match_b <= '1';
        else
            compare_match_b <= '0';
        end if;
    end process;
    
    --PWM A
    process(compare_match_a, res, overflow) is 
        variable q: std_logic;
    begin
        if(res or overflow) = '1' then
            q := '0';
        elsif(rising_edge(compare_match_a)) then
            if(pwmen = '1') then
                q := '1';
            end if;
        end if;
        pwma <= not(q);
    end process;
    
    --PWM B
    process(compare_match_b, res, overflow) is 
        variable q: std_logic;
    begin
        if(res or overflow) = '1' then
            q := '0';
        elsif(rising_edge(compare_match_b)) then
            if(pwmen = '1') then
                q := '1';
            end if;
        end if;
        pwmb <= not(q);
    end process;
    
    --for clear timer
    clear <= res or overflow or (compare_match_a and en_clear_on_compare_match);
    
    --for interrupts
    intrq <= (compare_match_a and en_compare_match_intrq) or (overflow and en_overflow_intrq);
    
    pwmen <= TCCR(0);
    en_compare_match_intrq <= TCCR(1);
    en_overflow_intrq <= TCCR(2);
    en_clear_on_compare_match <= TCCR(3);
    timeren <= TCCR(4);
    
    -----------------
    --bus interface
    
    --chip select
    process(address) is begin
        if (unsigned(address) = BASE_ADDRESS)then
            reg_sel <= "0001"; -- TCCR
        elsif ((unsigned(address)) = (BASE_ADDRESS + 1)) then
            reg_sel <= "0010"; -- OCRA
        elsif ((unsigned(address)) = (BASE_ADDRESS + 2)) then
            reg_sel <= "0100"; -- OCRB
        elsif ((unsigned(address)) = (BASE_ADDRESS + 3)) then
            reg_sel <= "1000"; -- TCNR
        else
            reg_sel <= "0000";
        end if;
    end process;
    
    --registers
    process(clk, res, WR, data_mosi, reg_sel) is begin
        if res = '1' then
            OCRAreg <= x"0000";
            OCRBreg <= x"0000";
            TCCR <= "00000";
        elsif rising_edge(clk) then
            if(reg_sel = "0001" and WR = '1') then
                TCCR <= unsigned(data_mosi(4 downto 0));
            elsif(reg_sel = "0010" and WR = '1') then
                OCRAreg <= unsigned(data_mosi(15 downto 0));
            elsif(reg_sel = "0100" and WR = '1') then
                OCRBreg <= unsigned(data_mosi(15 downto 0));
            end if;
        end if;
    end process;
    
    --output from registers
    data_miso <= x"000000" & "000" & std_logic_vector(TCCR) when (RD = '1' and reg_sel = "0001") else
                 x"0000" & std_logic_vector(OCRAreg)        when (RD = '1' and reg_sel = "0010") else
                 x"0000" & std_logic_vector(OCRBreg)        when (RD = '1' and reg_sel = "0100") else
                 x"0000" & std_logic_vector(counter)        when (RD = '1' and reg_sel = "1000") else (others => 'Z');
             
end architecture timer_arch;
        
