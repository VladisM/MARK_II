-- Interrupt controller peripheral
--
-- Part of MARK II project. For informations about license, please
-- see file /LICENSE .
--
-- author: Vladislav Mlejnecký
-- email: v.mlejnecky@seznam.cz

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
        address: in std_logic_vector(23 downto 0);
        data_mosi: in std_logic_vector(31 downto 0);
        data_miso: out std_logic_vector(31 downto 0);
        WR: in std_logic;
        RD: in std_logic;
        ack: out std_logic;
        --device
        int_req: in std_logic_vector(15 downto 0);      --peripherals may request interrupt with this signal
        int_accept: in std_logic;                       --from the CPU
        int_completed: in std_logic;                    --from the CPU
        int_cpu_address: out std_logic_vector(23 downto 0);  --connect this to the CPU, this is address of ISR
        int_cpu_rq: out std_logic
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
            intFiltred: in std_logic_vector(15 downto 0);
            int_cpu_addr_sel: out std_logic_vector(3 downto 0);
            int_cpu_rq: out std_logic;
            int_taken: out std_logic_vector(15 downto 0);
            int_accept: in std_logic;
            int_completed: in std_logic
        );
    end component intFSM;

    component vector_reg is
        port(
            clk: in std_logic;
            res: in std_logic;
            we_a: in std_logic;
            we_b: in std_logic;
            data_mosi: in std_logic_vector(31 downto 0);
            q: out std_logic_vector(23 downto 0)
        );
    end component vector_reg;

    --chip select signal for mask register
    signal reg_sel_int_msk: std_logic;

    signal interrupt_mask_reg: std_logic_vector(15 downto 0); --interrupt mask

    signal intTaken: std_logic_vector(15 downto 0); --signal from FSM to RSFF, this reset FF after interrupt is taken
    signal intRaw: std_logic_vector(15 downto 0); --unmasked signals
    signal intFiltred: std_logic_vector(15 downto 0); --masked int signals
    signal int_cpu_addr_sel: std_logic_vector(3 downto 0);

    signal reg_sel_vector: std_logic_vector(15 downto 0);
    signal selected_miso_vector: std_logic_vector(23 downto 0);

    signal vector_0, vector_1, vector_2, vector_3, vector_4, vector_5,
    vector_6, vector_7, vector_8, vector_9, vector_10, vector_11, vector_12,
    vector_13, vector_14, vector_15: std_logic_vector(23 downto 0);

begin

    --chip select
    process(address) is begin
        if(unsigned(address) = BASE_ADDRESS)then
            reg_sel_int_msk <= '1';
        else
            reg_sel_int_msk <= '0';
        end if;
    end process;

    --register for interrupt mask
    process(clk, res, WR, data_mosi, reg_sel_int_msk) is begin
        if rising_edge(clk) then
            if(res = '1') then
                interrupt_mask_reg <= (others => '0');
            elsif (WR = '1' and reg_sel_int_msk = '1') then
                interrupt_mask_reg <= data_mosi(15 downto 0);
            end if;
        end if;
    end process;

    --output from register
    data_miso <= x"0000" & interrupt_mask_reg when (RD = '1' and reg_sel_int_msk = '1') else (others => 'Z');

    ack <= '1' when
        (WR = '1' and reg_sel_int_msk = '1') or
        (RD = '1' and reg_sel_int_msk = '1') or
        (RD = '1' and reg_sel_vector /= x"0000") or
        (WR = '1' and reg_sel_vector /= x"0000")
        else '0';

    --this is 32 RS flip flops, for asynchronous inputs
    gen_intrsff:
    for I in 15 downto 0 generate
        intRSFF_gen: intRSFF port map(clk, res, int_req(I), intTaken(I), intRaw(I));
    end generate gen_intrsff;

    --interrupt mask
    intFiltred <= intRaw and interrupt_mask_reg;

    --FSM which control interrupts
    fsm: intFSM
        port map(res, clk, intFiltred, int_cpu_addr_sel, int_cpu_rq, intTaken, int_accept, int_completed);

    reg_sel_vector(0) <= '1' when (unsigned(address) = (BASE_ADDRESS + 1)) else '0';
    reg_sel_vector(1) <= '1' when (unsigned(address) = (BASE_ADDRESS + 2)) else '0';
    reg_sel_vector(2) <= '1' when (unsigned(address) = (BASE_ADDRESS + 3)) else '0';
    reg_sel_vector(3) <= '1' when (unsigned(address) = (BASE_ADDRESS + 4)) else '0';
    reg_sel_vector(4) <= '1' when (unsigned(address) = (BASE_ADDRESS + 5)) else '0';
    reg_sel_vector(5) <= '1' when (unsigned(address) = (BASE_ADDRESS + 6)) else '0';
    reg_sel_vector(6) <= '1' when (unsigned(address) = (BASE_ADDRESS + 7)) else '0';
    reg_sel_vector(7) <= '1' when (unsigned(address) = (BASE_ADDRESS + 8)) else '0';
    reg_sel_vector(8) <= '1' when (unsigned(address) = (BASE_ADDRESS + 9)) else '0';
    reg_sel_vector(9) <= '1' when (unsigned(address) = (BASE_ADDRESS + 10)) else '0';
    reg_sel_vector(10) <= '1' when (unsigned(address) = (BASE_ADDRESS + 11)) else '0';
    reg_sel_vector(11) <= '1' when (unsigned(address) = (BASE_ADDRESS + 12)) else '0';
    reg_sel_vector(12) <= '1' when (unsigned(address) = (BASE_ADDRESS + 13)) else '0';
    reg_sel_vector(13) <= '1' when (unsigned(address) = (BASE_ADDRESS + 14)) else '0';
    reg_sel_vector(14) <= '1' when (unsigned(address) = (BASE_ADDRESS + 15)) else '0';
    reg_sel_vector(15) <= '1' when (unsigned(address) = (BASE_ADDRESS + 16)) else '0';

    vectorreg0: vector_reg port map(clk, res, reg_sel_vector(0), WR, data_mosi, vector_0);
    vectorreg1: vector_reg port map(clk, res, reg_sel_vector(1), WR, data_mosi, vector_1);
    vectorreg2: vector_reg port map(clk, res, reg_sel_vector(2), WR, data_mosi, vector_2);
    vectorreg3: vector_reg port map(clk, res, reg_sel_vector(3), WR, data_mosi, vector_3);
    vectorreg4: vector_reg port map(clk, res, reg_sel_vector(4), WR, data_mosi, vector_4);
    vectorreg5: vector_reg port map(clk, res, reg_sel_vector(5), WR, data_mosi, vector_5);
    vectorreg6: vector_reg port map(clk, res, reg_sel_vector(6), WR, data_mosi, vector_6);
    vectorreg7: vector_reg port map(clk, res, reg_sel_vector(7), WR, data_mosi, vector_7);
    vectorreg8: vector_reg port map(clk, res, reg_sel_vector(8), WR, data_mosi, vector_8);
    vectorreg9: vector_reg port map(clk, res, reg_sel_vector(9), WR, data_mosi, vector_9);
    vectorreg10: vector_reg port map(clk, res, reg_sel_vector(10), WR, data_mosi, vector_10);
    vectorreg11: vector_reg port map(clk, res, reg_sel_vector(11), WR, data_mosi, vector_11);
    vectorreg12: vector_reg port map(clk, res, reg_sel_vector(12), WR, data_mosi, vector_12);
    vectorreg13: vector_reg port map(clk, res, reg_sel_vector(13), WR, data_mosi, vector_13);
    vectorreg14: vector_reg port map(clk, res, reg_sel_vector(14), WR, data_mosi, vector_14);
    vectorreg15: vector_reg port map(clk, res, reg_sel_vector(15), WR, data_mosi, vector_15);

    process(reg_sel_vector, vector_0, vector_1, vector_2, vector_3, vector_4,
    vector_5, vector_6, vector_7, vector_8, vector_9, vector_10, vector_11,
    vector_12, vector_13, vector_14, vector_15) is begin
        case reg_sel_vector is
            when x"0001" => selected_miso_vector <= vector_0;
            when x"0002" => selected_miso_vector <= vector_1;
            when x"0004" => selected_miso_vector <= vector_2;
            when x"0008" => selected_miso_vector <= vector_3;
            when x"0010" => selected_miso_vector <= vector_4;
            when x"0020" => selected_miso_vector <= vector_5;
            when x"0040" => selected_miso_vector <= vector_6;
            when x"0080" => selected_miso_vector <= vector_7;
            when x"0100" => selected_miso_vector <= vector_8;
            when x"0200" => selected_miso_vector <= vector_9;
            when x"0400" => selected_miso_vector <= vector_10;
            when x"0800" => selected_miso_vector <= vector_11;
            when x"1000" => selected_miso_vector <= vector_12;
            when x"2000" => selected_miso_vector <= vector_13;
            when x"4000" => selected_miso_vector <= vector_14;
            when others => selected_miso_vector <= vector_15;
        end case;
    end process;

    process(RD, reg_sel_vector, selected_miso_vector) is begin
        if ((RD = '1') and (reg_sel_vector /= x"0000")) then
            data_miso <= x"00" & selected_miso_vector;
        else
            data_miso <= (others => 'Z');
        end if;
    end process;

    process(int_cpu_addr_sel, vector_0, vector_1, vector_2, vector_3, vector_4,
    vector_5, vector_6, vector_7, vector_8, vector_9, vector_10, vector_11,
    vector_12, vector_13, vector_14, vector_15) is begin
        case int_cpu_addr_sel is
            when "0000" => int_cpu_address <= vector_0;
            when "0001" => int_cpu_address <= vector_1;
            when "0010" => int_cpu_address <= vector_2;
            when "0011" => int_cpu_address <= vector_3;
            when "0100" => int_cpu_address <= vector_4;
            when "0101" => int_cpu_address <= vector_5;
            when "0110" => int_cpu_address <= vector_6;
            when "0111" => int_cpu_address <= vector_7;
            when "1000" => int_cpu_address <= vector_8;
            when "1001" => int_cpu_address <= vector_9;
            when "1010" => int_cpu_address <= vector_10;
            when "1011" => int_cpu_address <= vector_11;
            when "1100" => int_cpu_address <= vector_12;
            when "1101" => int_cpu_address <= vector_13;
            when "1110" => int_cpu_address <= vector_14;
            when others  => int_cpu_address <= vector_15;
        end case;
    end process;

end architecture intControllerArch;

library ieee;
use ieee.std_logic_1164.all;

entity vector_reg is
    port(
        clk: in std_logic;
        res: in std_logic;
        we_a: in std_logic;
        we_b: in std_logic;
        data_mosi: in std_logic_vector(31 downto 0);
        q: out std_logic_vector(23 downto 0)
    );
end entity vector_reg;

architecture vector_reg_arch of vector_reg is
begin
    process(clk) is
        variable vector: std_logic_vector(23 downto 0);
    begin
        if rising_edge(clk) then
            if res = '1' then
                vector := (others => '0');
            elsif we_a = '1' and we_b = '1' then
                vector := data_mosi(23 downto 0);
            end if;
        end if;
        q <= vector;
    end process;
end architecture vector_reg_arch;

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
        intFiltred: in std_logic_vector(15 downto 0);
        int_cpu_addr_sel: out std_logic_vector(3 downto 0);
        int_cpu_rq: out std_logic;
        int_taken: out std_logic_vector(15 downto 0);
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
        setint15, clearint15
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
            when start =>                 int_taken <= x"0000"; int_cpu_addr_sel <= "0000"; int_cpu_rq <= '0';
            when wait_for_int_come =>     int_taken <= x"0000"; int_cpu_addr_sel <= "0000"; int_cpu_rq <= '0';
            when wait_for_int_complete => int_taken <= x"0000"; int_cpu_addr_sel <= "0000"; int_cpu_rq <= '0';

            when setint0 =>  int_taken <= x"0000"; int_cpu_addr_sel <= "0000"; int_cpu_rq <= '1';
            when setint1 =>  int_taken <= x"0000"; int_cpu_addr_sel <= "0001"; int_cpu_rq <= '1';
            when setint2 =>  int_taken <= x"0000"; int_cpu_addr_sel <= "0010"; int_cpu_rq <= '1';
            when setint3 =>  int_taken <= x"0000"; int_cpu_addr_sel <= "0011"; int_cpu_rq <= '1';
            when setint4 =>  int_taken <= x"0000"; int_cpu_addr_sel <= "0100"; int_cpu_rq <= '1';
            when setint5 =>  int_taken <= x"0000"; int_cpu_addr_sel <= "0101"; int_cpu_rq <= '1';
            when setint6 =>  int_taken <= x"0000"; int_cpu_addr_sel <= "0110"; int_cpu_rq <= '1';
            when setint7 =>  int_taken <= x"0000"; int_cpu_addr_sel <= "0111"; int_cpu_rq <= '1';
            when setint8 =>  int_taken <= x"0000"; int_cpu_addr_sel <= "1000"; int_cpu_rq <= '1';
            when setint9 =>  int_taken <= x"0000"; int_cpu_addr_sel <= "1001"; int_cpu_rq <= '1';
            when setint10 => int_taken <= x"0000"; int_cpu_addr_sel <= "1010"; int_cpu_rq <= '1';
            when setint11 => int_taken <= x"0000"; int_cpu_addr_sel <= "1011"; int_cpu_rq <= '1';
            when setint12 => int_taken <= x"0000"; int_cpu_addr_sel <= "1100"; int_cpu_rq <= '1';
            when setint13 => int_taken <= x"0000"; int_cpu_addr_sel <= "1101"; int_cpu_rq <= '1';
            when setint14 => int_taken <= x"0000"; int_cpu_addr_sel <= "1110"; int_cpu_rq <= '1';
            when setint15 => int_taken <= x"0000"; int_cpu_addr_sel <= "1111"; int_cpu_rq <= '1';

            when clearint0 =>  int_taken <= x"0001"; int_cpu_addr_sel <= "0000"; int_cpu_rq <= '0';
            when clearint1 =>  int_taken <= x"0002"; int_cpu_addr_sel <= "0000"; int_cpu_rq <= '0';
            when clearint2 =>  int_taken <= x"0004"; int_cpu_addr_sel <= "0000"; int_cpu_rq <= '0';
            when clearint3 =>  int_taken <= x"0008"; int_cpu_addr_sel <= "0000"; int_cpu_rq <= '0';
            when clearint4 =>  int_taken <= x"0010"; int_cpu_addr_sel <= "0000"; int_cpu_rq <= '0';
            when clearint5 =>  int_taken <= x"0020"; int_cpu_addr_sel <= "0000"; int_cpu_rq <= '0';
            when clearint6 =>  int_taken <= x"0040"; int_cpu_addr_sel <= "0000"; int_cpu_rq <= '0';
            when clearint7 =>  int_taken <= x"0080"; int_cpu_addr_sel <= "0000"; int_cpu_rq <= '0';
            when clearint8 =>  int_taken <= x"0100"; int_cpu_addr_sel <= "0000"; int_cpu_rq <= '0';
            when clearint9 =>  int_taken <= x"0200"; int_cpu_addr_sel <= "0000"; int_cpu_rq <= '0';
            when clearint10 => int_taken <= x"0400"; int_cpu_addr_sel <= "0000"; int_cpu_rq <= '0';
            when clearint11 => int_taken <= x"0800"; int_cpu_addr_sel <= "0000"; int_cpu_rq <= '0';
            when clearint12 => int_taken <= x"1000"; int_cpu_addr_sel <= "0000"; int_cpu_rq <= '0';
            when clearint13 => int_taken <= x"2000"; int_cpu_addr_sel <= "0000"; int_cpu_rq <= '0';
            when clearint14 => int_taken <= x"4000"; int_cpu_addr_sel <= "0000"; int_cpu_rq <= '0';
            when clearint15 => int_taken <= x"8000"; int_cpu_addr_sel <= "0000"; int_cpu_rq <= '0';

        end case;
    end process;

end architecture intFSMArch;


