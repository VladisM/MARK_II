library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity core is
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
end entity core;

architecture core_arch of core is
    
    signal enClearOnCompareMatch, enTimer, enOwfInt, enCompareInt, enPwm: std_logic;
    signal clksel: std_logic_vector(1 downto 0);
    
    signal selectedclken: std_logic;
    
    signal compareMatchA, compareMatchB: std_logic;
    signal timerValue: unsigned(15 downto 0);
    
    signal Zero, Top: std_logic;
    
begin

    enClearOnCompareMatch <= control(0);
    enTimer <=  control(1);
    enOwfInt <=  control(2);
    enCompareInt <=  control(3);
    enPwm <=  control(4);
    clksel <= control(6 downto 5);
    
    selectedclken <= '1'    when clksel = "00" else
                     enclk2 when clksel = "01" else
                     enclk4 when clksel = "10" else
                     enclk8 when clksel = "11" else '-';
    
    
    process(clk, res, aclear) is
        variable timerVar: unsigned(15 downto 0);
    begin
        if(aclear = '1') then
            timerVar := (others => '0');
        elsif(rising_edge(clk)) then
            if(res = '1') then
                timerVar := (others => '0');
            elsif(compareMatchA = '1' and enClearOnCompareMatch = '1') then
                timerVar := (others => '0');
            elsif(enTimer = '1' and selectedclken = '1') then
                timerVar := timerVar + 1;
            end if;
        end if;
        
        timerValue <= timerVar;
    end process;
    
    timerCount <= timerValue;
    
    zeroComparator:
    process(timerValue)is begin
        if(timerValue = x"0000") then
            Zero <= '1';
        else
            Zero <= '0';
        end if;
    end process;
                
    topComparator:
    process(timerValue)is begin
        if(timerValue = x"FFFF") then
            Top <= '1';
        else
            Top <= '0';
        end if;
    end process;            
    
    ocracomp:
    process(timerValue, ocra)is begin
        if(timerValue = ocra) then
            compareMatchA <= '1';
        else
            compareMatchA <= '0';
        end if;
    end process;            
                
    ocrbcomp:
    process(timerValue, ocrb)is begin
        if(timerValue = ocrb) then
            compareMatchB <= '1';
        else
            compareMatchB <= '0';
        end if;
    end process;                       
    
    pwma_gen:
    process(clk, compareMatchA, Zero) is
        variable pwmaVar: std_logic;
    begin
        if(rising_edge(clk)) then
            if(compareMatchA = '1') then
                pwmaVar := '0';
            elsif(Zero = '1' and enPwm = '1') then
                pwmaVar := '1';
            end if;
        end if;
        
        pwma <= pwmaVar;
    end process;
                
    pwmb_gen:
    process(clk, compareMatchB, Zero) is
        variable pwmbVar: std_logic;
    begin
        if(rising_edge(clk)) then
            if(compareMatchB = '1') then
                pwmbVar := '0';
            elsif(Zero = '1' and enPwm = '1') then
                pwmbVar := '1';
            end if;
        end if;
        
        pwmb <= pwmbVar;
    end process;
                
    intrq <= (Top and enOwfInt) or (CompareMatchA and enCompareInt);

end architecture;
