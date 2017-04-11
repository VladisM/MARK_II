library ieee;
use ieee.std_logic_1164.all;

entity int_fsm is
    port(
        clk: in std_logic;
        res: in std_logic;
        int_raw: in std_logic;
        intrq: out std_logic
    );
end entity int_fsm;

architecture int_fsm_arch of int_fsm is
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
    
end architecture int_fsm_arch;
