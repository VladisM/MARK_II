--PWM generator for MARK_II
--
-- registers
-- offset +0: compare register
-- offset +1: control register (see line 210 for details)

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pwm is 
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
end entity pwm;

architecture pwm_arch of pwm is 

    --signal for 
    signal timer: unsigned((TIMER_WIDE - 1) downto 0);
         
    --this is signal for reset pwm out
    signal timer_overflow: std_logic;
     
    --signalize counter reach top
    signal timer_top_reached: std_logic;

    --control PWM output
    signal pwm_set: std_logic := '0';
    signal pwm_res: std_logic := '0';
     
    --divided clock signals
    signal clk_d1: std_logic;
    signal clk_d2: std_logic;
    signal clk_d4: std_logic;
    signal clk_d8: std_logic;
     
    --clock for timer
    signal timer_clk: std_logic;
    
    --chip select signal
    signal cs: std_logic_vector(1 downto 0);
    
    --registers
    signal control_reg, compare_reg: unsigned((BUS_WIDE - 1) downto 0);
        
    --control signals from settings
    signal max_count, set_count: unsigned((TIMER_WIDE-1) downto 0);
    signal set_div: std_logic_vector(1 downto 0);
    signal enable_limit, negate_output, set_ext_clk: std_logic;
    
    --signal for generating pwm output (controled negation)
    signal pwm_raw, pwmn_raw: std_logic;
    
begin
    
   process (res, timer_clk, timer, timer_top_reached)
        --this is where timer is stored (register)
        variable timer_var: unsigned(TIMER_WIDE downto 0);
    begin
        
        if(res = '1' or timer_top_reached= '1') then
                timer_var := (others => '0');
        elsif(rising_edge(timer_clk)) then
            timer_var := timer_var + 1;
            
            --overflow check
            if(timer = ((2**TIMER_WIDE)-1)) then
                timer_overflow <= '1';
            else
                timer_overflow <= '0';
            end if;
            
        end if;

        --output
        timer <= timer_var((TIMER_WIDE - 1) downto 0);
    end process;
    
    --seting PWM output
    process(timer, set_count) is begin 
        if(set_count = timer) then
            pwm_set <= '1';
        else
            pwm_set <= '0';
        end if;
    end process;
        
    --reseting PWM output
    pwm_res <= timer_overflow or timer_top_reached;
    process(timer, max_count, enable_limit) is begin
        if(timer = max_count and enable_limit = '1') then
            timer_top_reached <= '1';
        else
            timer_top_reached <= '0';
        end if;
    end process;
    
    --output RS flip flip for PWM generator
    process(pwm_set, pwm_res, res) is begin
        if(res = '1') then
            pwm_raw <= '0';
            pwmn_raw <= '1';
        elsif(pwm_set = '1' and pwm_res = '0') then
            pwm_raw <= '1';
            pwmn_raw <= '0';
        elsif(pwm_set = '0' and pwm_res = '1') then
            pwm_raw <= '0';
            pwmn_raw <= '1';
        end if;
    end process;
    
    --pwm output
    with negate_output select pwm <= pwmn_raw when '1', pwm_raw when others;
    
    --divide with 2
    process(clk_d1) is begin
        if (rising_edge(clk_d1)) then 
            clk_d2 <= not(clk_d2);
        end if;
    end process;
    
    --divide by 4
    process(clk_d2) is begin
        if (rising_edge(clk_d2)) then
            clk_d4 <= not(clk_d4);
        end if;
    end process;
    
    --divide by 8
    process(clk_d4) is begin
        if (rising_edge(clk_d4)) then
            clk_d8 <= not(clk_d8);
        end if;
    end process;
    
    --divider mux
    with set_div select timer_clk <= clk_d1 when "00", clk_d2 when "01", clk_d4 when "10", clk_d8 when others;
    
    --external/internal clk switch
    with set_ext_clk select clk_d1 <= ext_clk when '1', clk when others;
    
    --there is interface
    
    --chip select
    process(address) is begin
        if(unsigned(address) = BASE_ADDRESS) then
            cs <= "01";
        elsif(unsigned(address) = (BASE_ADDRESS + 1)) then
            cs <= "10";
        else
            cs <= "00";
        end if;
    end process;
    
    --comapre register
    process(clk, res, cs, WR, data_mosi) is begin
        if(res = '1') then 
            compare_reg <= (others => '0');
        elsif(rising_edge(clk)) then
            if(WR = '1' and cs = "01") then
                compare_reg <= unsigned(data_mosi);
            end if;
        end if;
    end process;
    
    --compare register output
    process(cs, RD, compare_reg) is begin
        if(cs = "01" and RD = '1') then
            data_miso <= std_logic_vector(compare_reg);
        else
            data_miso <= (others => 'Z');
        end if;
    end process;
        
    --control register
    process(clk, res, cs, WR, data_mosi) is begin
        if(res = '1') then 
            control_reg <= (others => '0');
        elsif(rising_edge(clk)) then
            if(WR = '1' and cs = "10") then
                control_reg <= unsigned(data_mosi);
            end if;
        end if;
    end process;
    
    --control register output
    process(cs, RD, control_reg) is begin
        if(cs = "10" and RD = '1') then
            data_miso <= std_logic_vector(control_reg);
        else
            data_miso <= (others => 'Z');
        end if;
    end process;
    
    --output from compare register into pwm generator
    set_count <= compare_reg((TIMER_WIDE - 1) downto 0);
    
    --output from control register into pwm generator
    max_count <= control_reg((TIMER_WIDE - 1) downto 0);
    set_ext_clk <= control_reg(BUS_WIDE - 1);
    enable_limit <= control_reg(BUS_WIDE - 2);
    set_div <= std_logic_vector(control_reg((BUS_WIDE - 3) downto (BUS_WIDE - 4)));
    negate_output <= control_reg(BUS_WIDE - 5);
    
end architecture pwm_arch;
