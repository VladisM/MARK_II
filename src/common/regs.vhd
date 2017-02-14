library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg is 
    generic(
        WIDE : natural := 32
    );
    port(
        clk: in std_logic;
        res: in std_logic;
        DataIn: in unsigned((WIDE-1) downto 0);
        DataOut: out unsigned((WIDE-1) downto 0);
        WE: in std_logic
    );
end entity reg;

architecture reg_arch of reg is

begin
    
    process(clk, res) is
        variable reg_var: unsigned((WIDE-1) downto 0);
    begin
        if (rising_edge(clk)) then
            if (res = '1') then
                reg_var := (others => '0');                
            elsif (WE = '1') then
                reg_var := DataIn;
            end if;
        end if;
        
        DataOut <= reg_var;
        
    end process;

end architecture reg_arch;
  
    
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg_tristate is  
    generic(
        WIDE : natural := 32
    );
    port(
        clk: in std_logic;
        res: in std_logic;
        DataIn: in unsigned((WIDE-1) downto 0);
        DataOut: out unsigned((WIDE-1) downto 0);
        WE: in std_logic;
        OE: in std_logic
    );
end entity reg_tristate;

architecture reg_tristate_arch of reg_tristate is
    signal storedData: unsigned((WIDE-1) downto 0);
begin
    
    process(clk, res) is
        variable reg_var: unsigned((WIDE-1) downto 0);
    begin
        
        if (rising_edge(clk)) then
            if (res = '1') then
                reg_var := (others => '0');                
            elsif (WE = '1') then
                reg_var := DataIn;
            end if;
        end if;
        
        storedData <= reg_var;
        
    end process;

    DataOut <= storedData when (OE = '1') else (others => 'Z');

end architecture reg_tristate_arch;
    
    
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg_zero_tristate is 
    generic(
        WIDE : natural := 32
    );
    port(
        clk: in std_logic;
        res: in std_logic;
        DataIn: in unsigned((WIDE-1) downto 0);
        DataOut: out unsigned((WIDE-1) downto 0);
        WE: in std_logic;
        OE: in std_logic;
        ZeroFlag: out std_logic
    );
end entity reg_zero_tristate;

architecture reg_zero_tristate_arch of reg_zero_tristate is
    signal storedData: unsigned((WIDE-1) downto 0);
    constant zero: unsigned((WIDE-1) downto 0) := (others => '0');
begin
    
    process(clk, res) is
        variable reg_var: unsigned((WIDE-1) downto 0);
    begin
        
        if (rising_edge(clk)) then
            if (res = '1') then
                reg_var := (others => '0');                
            elsif (WE = '1') then
                reg_var := DataIn;
            end if;
        end if;
        
        storedData <= reg_var;
        
    end process;

    process(storedData) is
    begin
        if(storedData = zero) then
            ZeroFlag <= '1';
        else
            ZeroFlag <= '0';
        end if;
    end process;

    DataOut <= storedData when (OE = '1') else (others => 'Z');

end architecture reg_zero_tristate_arch;

    
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg_zero_tristate_counter is 
    generic(
        WIDE : natural := 32
    );
    port(
        clk: in std_logic;
        res: in std_logic;
        DataIn: in unsigned((WIDE-1) downto 0);
        DataOut: out unsigned((WIDE-1) downto 0);
        WE: in std_logic;
        OE: in std_logic;
        inc: in std_logic;
        dec: in std_logic;
        ZeroFlag: out std_logic
    );
end entity reg_zero_tristate_counter;

architecture reg_zero_tristate_counter_arch of reg_zero_tristate_counter is
    signal storedData: unsigned((WIDE-1) downto 0);
    constant zero : unsigned((WIDE-1) downto 0) := (others => '0');
begin
    
    process(clk, res) is
        variable reg_var: unsigned((WIDE-1) downto 0);
    begin

        if (rising_edge(clk)) then
            if (res = '1') then
                reg_var := (others => '0');
            elsif (WE = '1') then
                reg_var := DataIn;
            elsif (inc = '1') then 
                reg_var := reg_var + 1;
            elsif (dec = '1') then 
                reg_var := reg_var - 1;
            end if;
        end if;
        
        storedData <= reg_var;
        
    end process;

    process(storedData) is
    begin
        if(storedData = zero) then
            ZeroFlag <= '1';
        else
            ZeroFlag <= '0';
        end if;
    end process;

    DataOut <= storedData when (OE = '1') else (others => 'Z');

end architecture reg_zero_tristate_counter_arch;    
    
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg_zero_tristate_counter_permaout is 
    generic(
        WIDE : natural := 32
    );
    port(
        clk: in std_logic;
        res: in std_logic;
        DataIn: in unsigned((WIDE-1) downto 0);
        DataOut: out unsigned((WIDE-1) downto 0);
        WE: in std_logic;
        OE: in std_logic;
        inc: in std_logic;
        dec: in std_logic;
        ZeroFlag: out std_logic;
        permaout: out unsigned((WIDE -1) downto 0)
    );
end entity reg_zero_tristate_counter_permaout;

architecture reg_zero_tristate_counter_permaout_arch of reg_zero_tristate_counter_permaout is
    signal storedData: unsigned((WIDE-1) downto 0);
    constant zero : unsigned((WIDE-1) downto 0) := (others => '0');
begin
    
    process(clk, res) is
        variable reg_var: unsigned((WIDE-1) downto 0);
    begin
        
        if (rising_edge(clk)) then
            if (res = '1') then
                reg_var := (others => '0');
            elsif (WE = '1') then
                reg_var := DataIn;
            elsif (inc = '1') then 
                reg_var := reg_var + 1;
            elsif (dec = '1') then 
                reg_var := reg_var - 1;
            end if;
        end if;
        
        storedData <= reg_var;
    end process;

    process(storedData) is
    begin
        if(storedData = zero) then
            ZeroFlag <= '1';
        else
            ZeroFlag <= '0';
        end if;
    end process;

    DataOut <= storedData when (OE = '1') else (others => 'Z');

    permaout <= storedData;

end architecture reg_zero_tristate_counter_permaout_arch;    
    
