library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity intController is 
    generic(
        BASE_ADDRESS: unsigned(23 downto 0) := x"00000"    --base address
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
        --device
		int_req: in std_logic_vector(31 downto 0);      --peripherals may request interrupt with this signal
        int_accept: in std_logic;                       --from the CPU
        int_completed: in std_logic;                    --from the CPU
		int_cpu_req: out std_logic_vector(31 downto 0)  --connect this to the CPU, this is cpu interrupt
		
    );
end entity intController;

architecture intControllerArch of intController is

    --this is one rs flip flop
    component intRSFF is
        port(
            clk: in std_logic;
            res: in std_logic;
            intSet: in std_logic;
            intTaken: in std_logic;
            intOut: out std_logic
        );
    end component intRSFF;
    
    --FSM for interrupt control
    component intFSM is 
        port(
            res: in std_logic;
            clk: in std_logic;
            intFiltred: in std_logic_vector(31 downto 0);
            int_cpu_req: out std_logic_vector(31 downto 0);
            int_taken: out std_logic_vector(31 downto 0);
            int_accept: in std_logic;
            int_completed: in std_logic
        );
    end component intFSM;

    --chip select signal for mask register
    signal reg_sel: std_logic;
    
    signal interrupt_mask_reg: std_logic_vector(31 downto 0); --interrupt mask
    
    signal intTaken: std_logic_vector(31 downto 0); --signal from FSM to RSFF, this reset FF after interrupt is taken
    signal intRaw: std_logic_vector(31 downto 0); --unmasked signals
    signal intFiltred: std_logic_vector(31 downto 0); --masked int signals
    
begin

    --chip select
    process(address) is begin
        if(unsigned(address) = BASE_ADDRESS)then
            reg_sel <= '1';
        else
            reg_sel <= '0';
        end if;
    end process;

    --register for interrupt mask
    process(clk, res, WR, data_mosi, reg_sel) is begin
        if rising_edge(clk) then
            if(res = '1') then
                interrupt_mask_reg <= (others => '0');
            elsif (WR = '1' and reg_sel = '1') then
                interrupt_mask_reg <= std_logic_vector(data_mosi);
            end if;
        end if;
    end process;
    
    --output from register
    data_miso <= unsigned(interrupt_mask_reg) when (RD = '1' and reg_sel = '1') else (others => 'Z');
    
    ack <= '1' when (WR = '1' and reg_sel = '1') or (RD = '1' and reg_sel = '1') else '0';
    
    --this is 32 RS flip flops, for asynchronous inputs
    gen_intrsff:
    for I in 31 downto 0 generate
        intRSFF_gen: intRSFF port map(clk, res, int_req(I), intTaken(I), intRaw(I));
    end generate gen_intrsff;
    
    --interrupt mask 
    intFiltred <= intRaw and interrupt_mask_reg;
	
    --FSM which control interrupts
    fsm: intFSM
        port map(res, clk, intFiltred, int_cpu_req, intTaken, int_accept, int_completed);
    
end architecture intControllerArch;



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity intRSFF is
    port(
        clk: in std_logic;
        res: in std_logic;
        intSet: in std_logic;
        intTaken: in std_logic;
        intOut: out std_logic
    );
end entity intRSFF;

architecture intRSFFArch of intRSFF is     
begin
    
    process(clk, res, intSet, intTaken) is 
        variable var: std_logic;
    begin
        
        if(rising_edge(clk))then
            if(intTaken = '1' or res = '1') then
                var := '0';
            elsif(intSet = '1') then
                var := '1';
            end if;
        end if;
        
        intOut <= var;
        
    end process;
    
    
end architecture intRSFFArch;
    

    
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity intFSM is
    port(
        res: in std_logic;
        clk: in std_logic;
        intFiltred: in std_logic_vector(31 downto 0);
        int_cpu_req: out std_logic_vector(31 downto 0);
        int_taken: out std_logic_vector(31 downto 0);
		int_accept: in std_logic;
        int_completed: in std_logic
    );
end entity intFSM;

architecture intFSMArch of intFSM is
    
    --states for FSM
    type states is (
        start, wait_for_int_come, wait_for_int_complete, 
        setint0, clearint0, setint1, clearint1, setint2, clearint2,
        setint3, clearint3, setint4, clearint4, setint5, clearint5,
        setint6, clearint6, setint7, clearint7, setint8, clearint8,
        setint9, clearint9, setint10, clearint10, setint11, clearint11,
        setint12, clearint12, setint13, clearint13, setint14, clearint14,
        setint15, clearint15, setint16, clearint16, setint17, clearint17,
        setint18, clearint18, setint19, clearint19, setint20, clearint20,
        setint21, clearint21, setint22, clearint22, setint23, clearint23,
        setint24, clearint24, setint25, clearint25, setint26, clearint26,
        setint27, clearint27, setint28, clearint28, setint29, clearint29,
        setint30, clearint30, setint31, clearint31
    );
    
    --this is reg holding state
    signal state: states;
    
begin
    
    --logic to set up next state
    process (clk, res, intFiltred, int_accept, int_completed) begin
        if (rising_edge(clk)) then
            if res = '1' then
                state <= start;
            else
                case state is
                    when start => state <= wait_for_int_come;
                    
                    when wait_for_int_come =>   --this is also priority decoder :) 
                        if    intFiltred(0)  = '1' then state <= setint0;
                        elsif intFiltred(1)  = '1' then state <= setint1;
                        elsif intFiltred(2)  = '1' then state <= setint2;
                        elsif intFiltred(3)  = '1' then state <= setint3;                   
                        elsif intFiltred(4)  = '1' then state <= setint4;
                        elsif intFiltred(5)  = '1' then state <= setint5;
                        elsif intFiltred(6)  = '1' then state <= setint6;
                        elsif intFiltred(7)  = '1' then state <= setint7;                   
                        elsif intFiltred(8)  = '1' then state <= setint8;
                        elsif intFiltred(9)  = '1' then state <= setint9;
                        elsif intFiltred(10) = '1' then state <= setint10;
                        elsif intFiltred(11) = '1' then state <= setint11;                  
                        elsif intFiltred(12) = '1' then state <= setint12;
                        elsif intFiltred(13) = '1' then state <= setint13;
                        elsif intFiltred(14) = '1' then state <= setint14;
                        elsif intFiltred(15) = '1' then state <= setint15;                   
                        elsif intFiltred(16) = '1' then state <= setint16;
                        elsif intFiltred(17) = '1' then state <= setint17;
                        elsif intFiltred(18) = '1' then state <= setint18;
                        elsif intFiltred(19) = '1' then state <= setint19;                   
                        elsif intFiltred(20) = '1' then state <= setint20;
                        elsif intFiltred(21) = '1' then state <= setint21;
                        elsif intFiltred(22) = '1' then state <= setint22;
                        elsif intFiltred(23) = '1' then state <= setint23;                   
                        elsif intFiltred(24) = '1' then state <= setint24;
                        elsif intFiltred(25) = '1' then state <= setint25;
                        elsif intFiltred(26) = '1' then state <= setint26;
                        elsif intFiltred(27) = '1' then state <= setint27;                                       
                        elsif intFiltred(28) = '1' then state <= setint28;
                        elsif intFiltred(29) = '1' then state <= setint29;
                        elsif intFiltred(30) = '1' then state <= setint30;
                        elsif intFiltred(31) = '1' then state <= setint31;
                        else state <= start;                    
                        end if;
                        
                    --ugly things, waiting for CPU take interrupt routine
                    when setint0 => if(int_accept = '1') then state <= clearint0; else state <= setint0; end if;
                    when setint1 => if(int_accept = '1') then state <= clearint1; else state <= setint1; end if;
                    when setint2 => if(int_accept = '1') then state <= clearint2; else state <= setint2; end if;
                    when setint3 => if(int_accept = '1') then state <= clearint3; else state <= setint3; end if;
                    when setint4 => if(int_accept = '1') then state <= clearint4; else state <= setint4; end if;
                    when setint5 => if(int_accept = '1') then state <= clearint5; else state <= setint5; end if;
                    when setint6 => if(int_accept = '1') then state <= clearint6; else state <= setint6; end if;
                    when setint7 => if(int_accept = '1') then state <= clearint7; else state <= setint7; end if;
                    when setint8 => if(int_accept = '1') then state <= clearint8; else state <= setint8; end if;
                    when setint9 => if(int_accept = '1') then state <= clearint9; else state <= setint9; end if;
                    when setint10 => if(int_accept = '1') then state <= clearint10; else state <= setint10; end if;
                    when setint11 => if(int_accept = '1') then state <= clearint11; else state <= setint11; end if;
                    when setint12 => if(int_accept = '1') then state <= clearint12; else state <= setint12; end if;
                    when setint13 => if(int_accept = '1') then state <= clearint13; else state <= setint13; end if;
                    when setint14 => if(int_accept = '1') then state <= clearint14; else state <= setint14; end if;
                    when setint15 => if(int_accept = '1') then state <= clearint15; else state <= setint15; end if;
                    when setint16 => if(int_accept = '1') then state <= clearint16; else state <= setint16; end if;
                    when setint17 => if(int_accept = '1') then state <= clearint17; else state <= setint17; end if;
                    when setint18 => if(int_accept = '1') then state <= clearint18; else state <= setint18; end if;
                    when setint19 => if(int_accept = '1') then state <= clearint19; else state <= setint19; end if;
                    when setint20 => if(int_accept = '1') then state <= clearint20; else state <= setint20; end if;
                    when setint21 => if(int_accept = '1') then state <= clearint21; else state <= setint21; end if;
                    when setint22 => if(int_accept = '1') then state <= clearint22; else state <= setint22; end if;
                    when setint23 => if(int_accept = '1') then state <= clearint23; else state <= setint23; end if;
                    when setint24 => if(int_accept = '1') then state <= clearint24; else state <= setint24; end if;
                    when setint25 => if(int_accept = '1') then state <= clearint25; else state <= setint25; end if;
                    when setint26 => if(int_accept = '1') then state <= clearint26; else state <= setint26; end if;
                    when setint27 => if(int_accept = '1') then state <= clearint27; else state <= setint27; end if;
                    when setint28 => if(int_accept = '1') then state <= clearint28; else state <= setint28; end if;
                    when setint29 => if(int_accept = '1') then state <= clearint29; else state <= setint29; end if;
                    when setint30 => if(int_accept = '1') then state <= clearint30; else state <= setint30; end if;
                    when setint31 => if(int_accept = '1') then state <= clearint31; else state <= setint31; end if;
                    
                    --clearint will reset RS flip flop so, next interrupt can be catch
                    when clearint0 => state <= wait_for_int_complete;
                    when clearint1 => state <= wait_for_int_complete;
                    when clearint2 => state <= wait_for_int_complete;
                    when clearint3 => state <= wait_for_int_complete;
                    when clearint4 => state <= wait_for_int_complete;
                    when clearint5 => state <= wait_for_int_complete;
                    when clearint6 => state <= wait_for_int_complete;
                    when clearint7 => state <= wait_for_int_complete;
                    when clearint8 => state <= wait_for_int_complete;
                    when clearint9 => state <= wait_for_int_complete;
                    when clearint10 => state <= wait_for_int_complete;
                    when clearint11 => state <= wait_for_int_complete;
                    when clearint12 => state <= wait_for_int_complete;
                    when clearint13 => state <= wait_for_int_complete;
                    when clearint14 => state <= wait_for_int_complete;
                    when clearint15 => state <= wait_for_int_complete;
                    when clearint16 => state <= wait_for_int_complete;
                    when clearint17 => state <= wait_for_int_complete;
                    when clearint18 => state <= wait_for_int_complete;
                    when clearint19 => state <= wait_for_int_complete;
                    when clearint20 => state <= wait_for_int_complete;
                    when clearint21 => state <= wait_for_int_complete;
                    when clearint22 => state <= wait_for_int_complete;
                    when clearint23 => state <= wait_for_int_complete;
                    when clearint24 => state <= wait_for_int_complete;
                    when clearint25 => state <= wait_for_int_complete;
                    when clearint26 => state <= wait_for_int_complete;
                    when clearint27 => state <= wait_for_int_complete;
                    when clearint28 => state <= wait_for_int_complete;
                    when clearint29 => state <= wait_for_int_complete;
                    when clearint30 => state <= wait_for_int_complete;
                    when clearint31 => state <= wait_for_int_complete;
                    
                    --but we also waiting for interrupt routine is completed, there isn't nested interrupts
                    when wait_for_int_complete => 
                        if(int_completed = '1') then state <= wait_for_int_come;
                        else state <= wait_for_int_complete;
                        end if;
                end case;
            end if;
        end if;
    end process;

    process (state) begin
        case state is
            when start =>                 int_taken <= x"00000000"; int_cpu_req <= x"00000000";
            when wait_for_int_come =>     int_taken <= x"00000000"; int_cpu_req <= x"00000000";
            when wait_for_int_complete => int_taken <= x"00000000"; int_cpu_req <= x"00000000";
            
            when setint0 =>  int_taken <= x"00000000"; int_cpu_req <= x"00000001";
            when setint1 =>  int_taken <= x"00000000"; int_cpu_req <= x"00000002";
            when setint2 =>  int_taken <= x"00000000"; int_cpu_req <= x"00000004";
            when setint3 =>  int_taken <= x"00000000"; int_cpu_req <= x"00000008";
            when setint4 =>  int_taken <= x"00000000"; int_cpu_req <= x"00000010";
            when setint5 =>  int_taken <= x"00000000"; int_cpu_req <= x"00000020";
            when setint6 =>  int_taken <= x"00000000"; int_cpu_req <= x"00000040";
            when setint7 =>  int_taken <= x"00000000"; int_cpu_req <= x"00000080";
            when setint8 =>  int_taken <= x"00000000"; int_cpu_req <= x"00000100";
            when setint9 =>  int_taken <= x"00000000"; int_cpu_req <= x"00000200";
            when setint10 => int_taken <= x"00000000"; int_cpu_req <= x"00000400";
            when setint11 => int_taken <= x"00000000"; int_cpu_req <= x"00000800";
            when setint12 => int_taken <= x"00000000"; int_cpu_req <= x"00001000";
            when setint13 => int_taken <= x"00000000"; int_cpu_req <= x"00002000";
            when setint14 => int_taken <= x"00000000"; int_cpu_req <= x"00004000";
            when setint15 => int_taken <= x"00000000"; int_cpu_req <= x"00008000";
            when setint16 => int_taken <= x"00000000"; int_cpu_req <= x"00010000";
            when setint17 => int_taken <= x"00000000"; int_cpu_req <= x"00020000";
            when setint18 => int_taken <= x"00000000"; int_cpu_req <= x"00040000";
            when setint19 => int_taken <= x"00000000"; int_cpu_req <= x"00080000";
            when setint20 => int_taken <= x"00000000"; int_cpu_req <= x"00100000";
            when setint21 => int_taken <= x"00000000"; int_cpu_req <= x"00200000";
            when setint22 => int_taken <= x"00000000"; int_cpu_req <= x"00400000";
            when setint23 => int_taken <= x"00000000"; int_cpu_req <= x"00800000";
            when setint24 => int_taken <= x"00000000"; int_cpu_req <= x"01000000";
            when setint25 => int_taken <= x"00000000"; int_cpu_req <= x"02000000";
            when setint26 => int_taken <= x"00000000"; int_cpu_req <= x"04000000";
            when setint27 => int_taken <= x"00000000"; int_cpu_req <= x"08000000";
            when setint28 => int_taken <= x"00000000"; int_cpu_req <= x"10000000";
            when setint29 => int_taken <= x"00000000"; int_cpu_req <= x"20000000";
            when setint30 => int_taken <= x"00000000"; int_cpu_req <= x"40000000";
            when setint31 => int_taken <= x"00000000"; int_cpu_req <= x"80000000";      
            
            when clearint0 =>  int_taken <= x"00000001"; int_cpu_req <= x"00000000";
            when clearint1 =>  int_taken <= x"00000002"; int_cpu_req <= x"00000000";
            when clearint2 =>  int_taken <= x"00000004"; int_cpu_req <= x"00000000";
            when clearint3 =>  int_taken <= x"00000008"; int_cpu_req <= x"00000000";
            when clearint4 =>  int_taken <= x"00000010"; int_cpu_req <= x"00000000";
            when clearint5 =>  int_taken <= x"00000020"; int_cpu_req <= x"00000000";
            when clearint6 =>  int_taken <= x"00000040"; int_cpu_req <= x"00000000";
            when clearint7 =>  int_taken <= x"00000080"; int_cpu_req <= x"00000000";
            when clearint8 =>  int_taken <= x"00000100"; int_cpu_req <= x"00000000";
            when clearint9 =>  int_taken <= x"00000200"; int_cpu_req <= x"00000000";
            when clearint10 => int_taken <= x"00000400"; int_cpu_req <= x"00000000";
            when clearint11 => int_taken <= x"00000800"; int_cpu_req <= x"00000000";
            when clearint12 => int_taken <= x"00001000"; int_cpu_req <= x"00000000";
            when clearint13 => int_taken <= x"00002000"; int_cpu_req <= x"00000000";
            when clearint14 => int_taken <= x"00004000"; int_cpu_req <= x"00000000";
            when clearint15 => int_taken <= x"00008000"; int_cpu_req <= x"00000000";
            when clearint16 => int_taken <= x"00010000"; int_cpu_req <= x"00000000";
            when clearint17 => int_taken <= x"00020000"; int_cpu_req <= x"00000000";
            when clearint18 => int_taken <= x"00040000"; int_cpu_req <= x"00000000";
            when clearint19 => int_taken <= x"00080000"; int_cpu_req <= x"00000000";
            when clearint20 => int_taken <= x"00100000"; int_cpu_req <= x"00000000";
            when clearint21 => int_taken <= x"00200000"; int_cpu_req <= x"00000000";
            when clearint22 => int_taken <= x"00400000"; int_cpu_req <= x"00000000";
            when clearint23 => int_taken <= x"00800000"; int_cpu_req <= x"00000000";
            when clearint24 => int_taken <= x"01000000"; int_cpu_req <= x"00000000";
            when clearint25 => int_taken <= x"02000000"; int_cpu_req <= x"00000000";
            when clearint26 => int_taken <= x"04000000"; int_cpu_req <= x"00000000";
            when clearint27 => int_taken <= x"08000000"; int_cpu_req <= x"00000000";
            when clearint28 => int_taken <= x"10000000"; int_cpu_req <= x"00000000";
            when clearint29 => int_taken <= x"20000000"; int_cpu_req <= x"00000000";
            when clearint30 => int_taken <= x"40000000"; int_cpu_req <= x"00000000";
            when clearint31 => int_taken <= x"80000000"; int_cpu_req <= x"00000000";
            
        end case;
    end process;
    
end architecture intFSMArch;


