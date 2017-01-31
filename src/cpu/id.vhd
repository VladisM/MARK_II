library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity id is
    port(
        clk: in std_logic;
        res: in std_logic;

        int: in std_logic_vector(31 downto 0);
        int_accept: out std_logic;
        int_completed: out std_logic;

        aluOpCode: out std_logic_vector(3 downto 0);
        aluOE: out std_logic;
        aluOpAWE: out std_logic;
        aluOpBWE: out std_logic;
        
        compOpCode: out std_logic_vector(2 downto 0);
        compOE: out std_logic;
        compOpAWE: out std_logic;
        compOpBWE: out std_logic;
        
        barDistance: out std_logic_vector(3 downto 0);
        barDir: out std_logic;
        barMode: out std_logic;
        barOE: out std_logic;
        barOpAWE: out std_logic;
        
        regOE: out std_logic_vector(15 downto 0);
        regWE: out std_logic_vector(15 downto 0);
        incSP: out std_logic;
        decSP: out std_logic;
        incPC: out std_logic;
        decPC: out std_logic;
        
        instructionWord: in unsigned(31 downto 0);
        instRegWE: out std_logic;
        
        instructionArgument: out unsigned(31 downto 0);
        instrArgOE: out std_logic;
        
        addrRegWE: out std_logic;
        mosiRegWE: out std_logic;
        misoOE: out std_logic;

        wr: out std_logic;
        rd: out std_logic;
        ack: in std_logic;

        addressSel: out std_logic;
        
        zeroFlag: in std_logic;
        flagRegSel: out std_logic_vector(3 downto 0)
    );
end entity id;

architecture id_arch of id is
    type state_type is (
        load_instruction_0, load_instruction_1, load_instruction_2, load_instruction_3,
        and0, and1, and2,
        or0, or1, or2,
        xor0, xor1, xor2,
        add0, add1, add2,
        sub0, sub1, sub2,
        cmp0, cmp1, cmp2,
        inc0, inc1,
        dec0, dec1,
        lsl0, lsl1,
        lsr0, lsr1,
        rol0, rol1,
        ror0, ror1,
        mov0,
        call0, call1, call2, call3,
        calli0, calli1, calli2, calli3,
        ret0, ret1, ret2, ret3,
        reti0, reti1, reti2, reti3,
        push0, push1, push2,
        pop0, pop1, pop2, pop3,
        ld0, ld1, ld2,
        ldi0, ldi1, ldi2,
        st0, st1, st2,
        sti0, sti1, sti2,
        mvil0, mvil1, mvil2,
        mvih0, mvih1, mvih2,
        bz0, bz1,
        bnz0, bnz1,
        bzi0, bzi1,
        bnzi0, bnzi1,
        interrupt0, interrupt1, interrupt2, interrupt3
    );

    signal state: state_type;

    signal interrupt_pending: std_logic;
    signal interrupt_vector: unsigned(31 downto 0);

    signal regs_oe, regs_we: std_logic;
    signal regs_we_dest, regs_oe_dest: unsigned(3 downto 0);

    
begin
    
    --logic to set up next state
    process(res, clk, ack, zeroFlag, interrupt_pending, interrupt_vector, instructionWord) is        
    begin
        if(rising_edge(clk)) then
            if(res = '1') then
                state <= load_instruction_0;
            else
                case state is
                    when load_instruction_0 => state <= load_instruction_1;
                    when load_instruction_1 =>
                        case ack is 
                            when '1' => state <= load_instruction_2;
                            when others => state <= load_instruction_1;
                        end case;
                    when load_instruction_2 => state <= load_instruction_3;
                    when load_instruction_3 =>
                        if instructionWord(31) = '1' then
                            case instructionWord(30 downto 28) is
                                when "000" => state <= call0;
                                when "001" => state <= ld0;
                                when "010" => state <= st0;
                                when "011" => state <= bz0;
                                when others => state <= bnz0;
                            end case;
                        elsif instructionWord(28) = '1' then
                            case instructionWord(20) is
                                when '1' => state <= mvih0;
                                when others => state <= mvil0;
                            end case;
                        elsif instructionWord(24) = '1' then
                            case instructionWord(19 downto 16) is
                                when "0000" => state <= cmp0;
                                when "0001" => state <= and0;
                                when "0010" => state <= or0;
                                when "0011" => state <= xor0;
                                when "0100" => state <= add0;
                                when "0101" => state <= sub0;
                                when "0110" => state <= inc0;
                                when "0111" => state <= dec0;
                                when "1000" => state <= lsl0;
                                when "1001" => state <= lsr0;
                                when "1010" => state <= rol0;
                                when others => state <= ror0;
                            end case;
                        elsif instructionWord(16) = '1' then
                            case instructionWord(10 downto 8) is
                                when "000" => state <= ldi0;
                                when "001" => state <= sti0;
                                when "010" => state <= bzi0;
                                when "011" => state <= bnzi0;
                                when others => state <= mov0;
                            end case;   
                        elsif instructionWord(12) = '1' then
                            case instructionWord(5 downto 4) is
                                when "00" => state <= calli0;
                                when "01" => state <= push0;
                                when others => state <= pop0;
                            end case;                 
                        elsif instructionWord(8) = '1' then
                            case instructionWord(0) is
                                when '1' => state <= reti0;
                                when others => state <= ret0;
                            end case;
                        else
                            state <= load_instruction_0;
                        end if;
                    when and0 => state <= and1;
                    when and1 => state <= and2;
                    when and2 => 
                        case interrupt_pending is
                            when '1' => state <= interrupt0;
                            when others => state <= load_instruction_0;
                        end case;
                    when or0 => state <= or1;
                    when or1 => state <= or2;
                    when or2 =>
                        case interrupt_pending is
                            when '1' => state <= interrupt0;
                            when others => state <= load_instruction_0;
                        end case;
                    when xor0 => state <= xor1;
                    when xor1 => state <= xor2;
                    when xor2 =>
                        case interrupt_pending is
                            when '1' => state <= interrupt0;
                            when others => state <= load_instruction_0;
                        end case;
                    when add0 => state <= add1;
                    when add1 => state <= add2;
                    when add2 =>
                        case interrupt_pending is
                            when '1' => state <= interrupt0;
                            when others => state <= load_instruction_0;
                        end case;
                    when sub0 => state <= sub1;
                    when sub1 => state <= sub2;
                    when sub2 =>
                        case interrupt_pending is
                            when '1' => state <= interrupt0;
                            when others => state <= load_instruction_0;
                        end case;
                    when cmp0 => state <= cmp1;
                    when cmp1 => state <= cmp2;
                    when cmp2 =>
                        case interrupt_pending is
                            when '1' => state <= interrupt0;
                            when others => state <= load_instruction_0;
                        end case;
                    when inc0 => state <= inc1;
                    when inc1 =>
                        case interrupt_pending is
                            when '1' => state <= interrupt0;
                            when others => state <= load_instruction_0;
                        end case;
                    when dec0 => state <= dec1;
                    when dec1 =>
                        case interrupt_pending is
                            when '1' => state <= interrupt0;
                            when others => state <= load_instruction_0;
                        end case;
                    when lsl0 => state <= lsl1;
                    when lsl1 =>
                        case interrupt_pending is
                            when '1' => state <= interrupt0;
                            when others => state <= load_instruction_0;
                        end case;
                    when lsr0 => state <= lsr1;
                    when lsr1 =>
                        case interrupt_pending is
                            when '1' => state <= interrupt0;
                            when others => state <= load_instruction_0;
                        end case;
                    when rol0 => state <= rol1;
                    when rol1 =>
                        case interrupt_pending is
                            when '1' => state <= interrupt0;
                            when others => state <= load_instruction_0;
                        end case;
                    when ror0 => state <= ror1;
                    when ror1 =>
                        case interrupt_pending is
                            when '1' => state <= interrupt0;
                            when others => state <= load_instruction_0;
                        end case;
                    when mov0 =>
                        case interrupt_pending is
                            when '1' => state <= interrupt0;
                            when others => state <= load_instruction_0;
                        end case;
                    when call0 => state <= call1;
                    when call1 => state <= call2;
                    when call2 => 
                        case ack is 
                            when '1' => state <= call3;
                            when others => state <= call2;
                        end case;
                    when call3 => 
                        case interrupt_pending is
                            when '1' => state <= interrupt0;
                            when others => state <= load_instruction_0;
                        end case;
                    when calli0 => state <= calli1;
                    when calli1 => state <= calli2;
                    when calli2 => 
                        case ack is 
                            when '1' => state <= calli3;
                            when others => state <= calli2;
                        end case;
                    when calli3 =>
                        case interrupt_pending is
                            when '1' => state <= interrupt0;
                            when others => state <= load_instruction_0;
                        end case;
                    when ret0 => state <= ret1;
                    when ret1 => state <= ret2;
                    when ret2 => 
                        case ack is 
                            when '1' => state <= ret3;
                            when others => state <= ret2;
                        end case;
                    when ret3 =>
                        case interrupt_pending is
                            when '1' => state <= interrupt0;
                            when others => state <= load_instruction_0;
                        end case;
                    when reti0 => state <= reti1;
                    when reti1 => state <= reti2;
                    when reti2 => 
                        case ack is 
                            when '1' => state <= reti3;
                            when others => state <= reti2;
                        end case;
                    when reti3 => 
                        case interrupt_pending is
                            when '1' => state <= interrupt0;
                            when others => state <= load_instruction_0;
                        end case;
                    when push0 => state <= push1;
                    when push1 => state <= push2;
                    when push2 => 
                        case ack is
                            when '1' => 
                                case interrupt_pending is
                                    when '1' => state <= interrupt0;
                                    when others => state <= load_instruction_0;
                                end case;
                            when others => state <= push2;
                        end case;
                    when pop0 => state <= pop1;
                    when pop1 => state <= pop2;
                    when pop2 => 
                        case ack is 
                            when '1' => state <= pop3;
                            when others => state <= pop2;
                        end case;
                    when pop3 => 
                        case interrupt_pending is
                            when '1' => state <= interrupt0;
                            when others => state <= load_instruction_0;
                        end case;
                    when ld0 => state <= ld1;
                    when ld1 => 
                        case ack is 
                            when '1' => state <= ld2;
                            when others => state <= ld1;
                        end case;
                    when ld2 =>                     
                        case interrupt_pending is
                            when '1' => state <= interrupt0;
                            when others => state <= load_instruction_0;
                        end case;
                    when ldi0 => state <= ldi1;
                    when ldi1 => 
                        case ack is 
                            when '1' => state <= ldi2;
                            when others => state <= ldi1;
                        end case;
                    when ldi2 =>                     
                        case interrupt_pending is
                            when '1' => state <= interrupt0;
                            when others => state <= load_instruction_0;
                        end case;
                    when st0 => state <= st1;
                    when st1 => state <= st2;
                    when st2 => 
                        case ack is
                            when '1' =>
                                case interrupt_pending is
                                    when '1' => state <= interrupt0;
                                    when others => state <= load_instruction_0;
                                end case;
                            when others => state <= st2;
                        end case;
                    when sti0 => state <= sti1;
                    when sti1 => state <= sti2;
                    when sti2 => 
                        case ack is
                            when '1' =>
                                case interrupt_pending is
                                    when '1' => state <= interrupt0;
                                    when others => state <= load_instruction_0;
                                end case;
                            when others => state <= sti2;
                        end case;
                    when mvil0 => state <= mvil1;
                    when mvil1 => state <= mvil2;
                    when mvil2 =>
                        case interrupt_pending is
                            when '1' => state <= interrupt0;
                            when others => state <= load_instruction_0;
                        end case;
                    when mvih0 => state <= mvih1;
                    when mvih1 => state <= mvih2;
                    when mvih2 =>
                        case interrupt_pending is
                            when '1' => state <= interrupt0;
                            when others => state <= load_instruction_0;
                        end case;
                    when bz0 =>
                        case zeroFlag is
                            when '1' => state <= bz1;
                            when others =>
                                case interrupt_pending is
                                    when '1' => state <= interrupt0;
                                    when others => state <= load_instruction_0;
                                end case;
                        end case;
                    when bz1 =>
                        case interrupt_pending is
                            when '1' => state <= interrupt0;
                            when others => state <= load_instruction_0;
                        end case;
                    when bnz0 =>
                        case zeroFlag is
                            when '0' => state <= bnz1;
                            when others =>
                                case interrupt_pending is
                                    when '1' => state <= interrupt0;
                                    when others => state <= load_instruction_0;
                                end case;
                        end case;
                    when bnz1 =>
                        case interrupt_pending is
                            when '1' => state <= interrupt0;
                            when others => state <= load_instruction_0;
                        end case;
                    when bzi0 =>
                        case zeroFlag is
                            when '1' => state <= bzi1;
                            when others =>
                                case interrupt_pending is
                                    when '1' => state <= interrupt0;
                                    when others => state <= load_instruction_0;
                                end case;
                        end case;
                    when bzi1 =>
                        case interrupt_pending is
                            when '1' => state <= interrupt0;
                            when others => state <= load_instruction_0;
                        end case;
                    when bnzi0 =>
                        case zeroFlag is
                            when '0' => state <= bnzi1;
                            when others =>
                                case interrupt_pending is
                                    when '1' => state <= interrupt0;
                                    when others => state <= load_instruction_0;
                                end case;
                        end case;
                    when bnzi1 =>
                        case interrupt_pending is
                            when '1' => state <= interrupt0;
                            when others => state <= load_instruction_0;
                        end case;
                    when interrupt0 => state <= interrupt1;
                    when interrupt1 => state <= interrupt2;
                    when interrupt2 => 
                        case ack is 
                            when '1' => state <= interrupt3;
                            when others => state <= interrupt2;
                        end case;
                    when interrupt3 => state <= load_instruction_0;
                end case;
            end if;
        end if;
    end process;

    --output functions
    process(state, instructionWord, interrupt_vector) is
    begin
        case state is
            when load_instruction_0 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"0"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '0'; regs_oe_dest <= x"0"; regs_we <= '0'; regs_we_dest <= x"0";
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '1';
                wr <= '0'; rd <= '1';
                addressSel <= '1'; flagRegSel <= x"0";
            when load_instruction_1 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"0"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '0'; regs_oe_dest <= x"0"; regs_we <= '0'; regs_we_dest <= x"0";
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '1';
                wr <= '0'; rd <= '1';
                addressSel <= '1'; flagRegSel <= x"0";
            when load_instruction_2 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"0"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '0'; regs_oe_dest <= x"0"; regs_we <= '0'; regs_we_dest <= x"0";
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '1';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '1';
                wr <= '0'; rd <= '1';
                addressSel <= '1'; flagRegSel <= x"0";                
            when load_instruction_3 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"0"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '0'; regs_oe_dest <= x"0"; regs_we <= '0'; regs_we_dest <= x"0";
                incSP <= '0'; decSP <= '0'; incPC <= '1'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '0'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";

            --AND instruction
            when and0 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"0"; aluoe <= '0'; aluOpAwe <= '1'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '1'; regs_oe_dest <= instructionWord(7 downto 4); regs_we <= '0'; regs_we_dest <= x"0";
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '0'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";
            when and1 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"0"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '1';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '1'; regs_oe_dest <= instructionWord(3 downto 0); regs_we <= '0'; regs_we_dest <= x"0";
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '0'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";
            when and2 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"0"; aluoe <= '1'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '0'; regs_oe_dest <= x"0"; regs_we <= '1'; regs_we_dest <= instructionWord(11 downto 8);
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '0'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";                

            --OR instruction
            when or0 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"1"; aluoe <= '0'; aluOpAwe <= '1'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '1'; regs_oe_dest <= instructionWord(7 downto 4); regs_we <= '0'; regs_we_dest <= x"0";
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '0'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";
            when or1 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"1"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '1';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '1'; regs_oe_dest <= instructionWord(3 downto 0); regs_we <= '0'; regs_we_dest <= x"0";
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '0'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";
            when or2 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"1"; aluoe <= '1'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '0'; regs_oe_dest <= x"0"; regs_we <= '1'; regs_we_dest <= instructionWord(11 downto 8);
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '0'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";    

            --XOR instruction
            when xor0 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"2"; aluoe <= '0'; aluOpAwe <= '1'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '1'; regs_oe_dest <= instructionWord(7 downto 4); regs_we <= '0'; regs_we_dest <= x"0";
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '0'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";
            when xor1 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"2"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '1';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '1'; regs_oe_dest <= instructionWord(3 downto 0); regs_we <= '0'; regs_we_dest <= x"0";
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '0'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";
            when xor2 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"2"; aluoe <= '1'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '0'; regs_oe_dest <= x"0"; regs_we <= '1'; regs_we_dest <= instructionWord(11 downto 8);
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '0'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";   
        --ADD instruction
            when add0 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"3"; aluoe <= '0'; aluOpAwe <= '1'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '1'; regs_oe_dest <= instructionWord(7 downto 4); regs_we <= '0'; regs_we_dest <= x"0";
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '0'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";
            when add1 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"3"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '1';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '1'; regs_oe_dest <= instructionWord(3 downto 0); regs_we <= '0'; regs_we_dest <= x"0";
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '0'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";
            when add2 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"3"; aluoe <= '1'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '0'; regs_oe_dest <= x"0"; regs_we <= '1'; regs_we_dest <= instructionWord(11 downto 8);
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '0'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";

            --SUB instruction
            when sub0 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"4"; aluoe <= '0'; aluOpAwe <= '1'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '1'; regs_oe_dest <= instructionWord(7 downto 4); regs_we <= '0'; regs_we_dest <= x"0";
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '0'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";
            when sub1 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"4"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '1';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '1'; regs_oe_dest <= instructionWord(3 downto 0); regs_we <= '0'; regs_we_dest <= x"0";
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '0'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";
            when sub2 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"4"; aluoe <= '1'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '0'; regs_oe_dest <= x"0"; regs_we <= '1'; regs_we_dest <= instructionWord(11 downto 8);
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '0'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";   
            --CMP instruction
            when cmp0 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"0"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= std_logic_vector(instructionWord(14 downto 12)); compoe <= '0'; compOpAwe <= '1'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '1'; regs_oe_dest <= instructionWord(7 downto 4); regs_we <= '0'; regs_we_dest <= x"0";
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '0'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";
            when cmp1 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"0"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= std_logic_vector(instructionWord(14 downto 12)); compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '1';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '1'; regs_oe_dest <= instructionWord(3 downto 0); regs_we <= '0'; regs_we_dest <= x"0";
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '0'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";
            when cmp2 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"0"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= std_logic_vector(instructionWord(14 downto 12)); compoe <= '1'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '0'; regs_oe_dest <= x"0"; regs_we <= '1'; regs_we_dest <= instructionWord(11 downto 8);
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '0'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";

            --INC instruction
            when inc0 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"5"; aluoe <= '0'; aluOpAwe <= '1'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '1'; regs_oe_dest <= instructionWord(7 downto 4); regs_we <= '0'; regs_we_dest <= x"0";
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '0'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";
            when inc1 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"5"; aluoe <= '1'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '0'; regs_oe_dest <= x"0"; regs_we <= '1'; regs_we_dest <= instructionWord(11 downto 8);
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '0'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";
            --DEC instruction
            when dec0 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"6"; aluoe <= '0'; aluOpAwe <= '1'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '1'; regs_oe_dest <= instructionWord(7 downto 4); regs_we <= '0'; regs_we_dest <= x"0";
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '0'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";
            when dec1 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"6"; aluoe <= '1'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '0'; regs_oe_dest <= x"0"; regs_we <= '1'; regs_we_dest <= instructionWord(11 downto 8);
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '0'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";


            --LSL instruction
            when lsl0 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"0"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= std_logic_vector(instructionWord(15 downto 12)); barDir <= '1'; barMode <= '0'; baroe <= '0'; barOpAwe <= '1';
                regs_oe <= '1'; regs_oe_dest <= instructionWord(7 downto 4); regs_we <= '0'; regs_we_dest <= x"0";
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '0'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";
            when lsl1 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"0"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= std_logic_vector(instructionWord(15 downto 12)); barDir <= '1'; barMode <= '0'; baroe <= '1'; barOpAwe <= '0';
                regs_oe <= '0'; regs_oe_dest <= x"0"; regs_we <= '1'; regs_we_dest <= instructionWord(11 downto 8);
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '0'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";   
            --LSR instruction
            when lsr0 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"0"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= std_logic_vector(instructionWord(15 downto 12)); barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '1';
                regs_oe <= '1'; regs_oe_dest <= instructionWord(7 downto 4); regs_we <= '0'; regs_we_dest <= x"0";
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '0'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";
            when lsr1 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"0"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= std_logic_vector(instructionWord(15 downto 12)); barDir <= '0'; barMode <= '0'; baroe <= '1'; barOpAwe <= '0';
                regs_oe <= '0'; regs_oe_dest <= x"0"; regs_we <= '1'; regs_we_dest <= instructionWord(11 downto 8);
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '0'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";   

            --rol instruction
            when rol0 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"0"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= std_logic_vector(instructionWord(15 downto 12)); barDir <= '1'; barMode <= '0'; baroe <= '0'; barOpAwe <= '1';
                regs_oe <= '1'; regs_oe_dest <= instructionWord(7 downto 4); regs_we <= '0'; regs_we_dest <= x"0";
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '0'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";
            when rol1 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"0"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= std_logic_vector(instructionWord(15 downto 12)); barDir <= '1'; barMode <= '0'; baroe <= '1'; barOpAwe <= '0';
                regs_oe <= '0'; regs_oe_dest <= x"0"; regs_we <= '1'; regs_we_dest <= instructionWord(11 downto 8);
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '0'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";   

            --ror instruction
            when ror0 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"0"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= std_logic_vector(instructionWord(15 downto 12)); barDir <= '0'; barMode <= '1'; baroe <= '0'; barOpAwe <= '1';
                regs_oe <= '1'; regs_oe_dest <= instructionWord(7 downto 4); regs_we <= '0'; regs_we_dest <= x"0";
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '0'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";
            when ror1 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"0"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= std_logic_vector(instructionWord(15 downto 12)); barDir <= '0'; barMode <= '1'; baroe <= '1'; barOpAwe <= '0';
                regs_oe <= '0'; regs_oe_dest <= x"0"; regs_we <= '1'; regs_we_dest <= instructionWord(11 downto 8);
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '0'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";

            --MOV instruction
            when mov0 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"0"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '1'; regs_oe_dest <= instructionWord(3 downto 0); regs_we <= '1'; regs_we_dest <= instructionWord(7 downto 4);
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '0'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";

            --RET instruction
            when ret0 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"0"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '0'; regs_oe_dest <= x"0"; regs_we <= '0'; regs_we_dest <= x"0";
                incSP <= '1'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '0'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";
            when ret1 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"0"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '1'; regs_oe_dest <= x"E"; regs_we <= '0'; regs_we_dest <= x"0";
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '1'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '0'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";
            when ret2 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"0"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '0'; regs_oe_dest <= x"0"; regs_we <= '0'; regs_we_dest <= x"0";
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '0'; rd <= '1';
                addressSel <= '0'; flagRegSel <= x"0";
            when ret3 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"0"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '0'; regs_oe_dest <= x"0"; regs_we <= '1'; regs_we_dest <= x"F";
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '1';
                wr <= '0'; rd <= '1';
                addressSel <= '0'; flagRegSel <= x"0";
            
            --RETI instruction
            when reti0 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"0"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '0'; regs_oe_dest <= x"0"; regs_we <= '0'; regs_we_dest <= x"0";
                incSP <= '1'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '0'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";
            when reti1 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"0"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '1'; regs_oe_dest <= x"E"; regs_we <= '0'; regs_we_dest <= x"0";
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '1'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '0'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";
            when reti2 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"0"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '0'; regs_oe_dest <= x"0"; regs_we <= '0'; regs_we_dest <= x"0";
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '0'; rd <= '1';
                addressSel <= '0'; flagRegSel <= x"0";
            when reti3 =>
                int_accept <= '0'; int_completed <= '1';
                aluOpCode <= x"0"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '0'; regs_oe_dest <= x"0"; regs_we <= '1'; regs_we_dest <= x"F";
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '1';
                wr <= '0'; rd <= '1';
                addressSel <= '0'; flagRegSel <= x"0";

            --POP instruction
            when pop0 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"0"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '0'; regs_oe_dest <= x"0"; regs_we <= '0'; regs_we_dest <= x"0";
                incSP <= '1'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '0'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";
            when pop1 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"0"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '1'; regs_oe_dest <= x"E"; regs_we <= '0'; regs_we_dest <= x"0";
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '1'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '0'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";
            when pop2 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"0"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '0'; regs_oe_dest <= x"0"; regs_we <= '0'; regs_we_dest <= x"0";
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '0'; rd <= '1';
                addressSel <= '0'; flagRegSel <= x"0";
            when pop3 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"0"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '0'; regs_oe_dest <= x"0"; regs_we <= '1'; regs_we_dest <= instructionWord(3 downto 0);
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '1';
                wr <= '0'; rd <= '1';
                addressSel <= '0'; flagRegSel <= x"0";


            --push instruction
            when push0 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"0"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '1'; regs_oe_dest <= x"E"; regs_we <= '0'; regs_we_dest <= x"0";
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '1'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '0'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";
            when push1 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"0"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '1'; regs_oe_dest <= instructionWord(3 downto 0); regs_we <= '0'; regs_we_dest <= x"0";
                incSP <= '0'; decSP <= '1'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '1'; misooe <= '0';
                wr <= '0'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";
            when push2 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"0"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '0'; regs_oe_dest <= x"0"; regs_we <= '0'; regs_we_dest <= x"0";
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '1'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";
            
            -- call instruction
            when call0 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"0"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '1'; regs_oe_dest <= x"E"; regs_we <= '0'; regs_we_dest <= x"0";
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '1'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '0'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";
            when call1 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"0"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '1'; regs_oe_dest <= x"F"; regs_we <= '0'; regs_we_dest <= x"0";
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '1'; misooe <= '0';
                wr <= '0'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";
            when call2 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"0"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '0'; regs_oe_dest <= x"0"; regs_we <= '0'; regs_we_dest <= x"0";
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '1'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";
            when call3 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"0"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '0'; regs_oe_dest <= x"0"; regs_we <= '1'; regs_we_dest <= x"F";
                incSP <= '0'; decSP <= '1'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00" & instructionWord(23 downto 0); instrArgoe <= '1';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '0'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";

            -- calli instruction
            when calli0 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"0"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '1'; regs_oe_dest <= x"E"; regs_we <= '0'; regs_we_dest <= x"0";
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '1'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '0'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";
            when calli1 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"0"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '1'; regs_oe_dest <= x"F"; regs_we <= '0'; regs_we_dest <= x"0";
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '1'; misooe <= '0';
                wr <= '0'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";
            when calli2 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"0"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '0'; regs_oe_dest <= x"0"; regs_we <= '0'; regs_we_dest <= x"0";
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '1'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";
            when calli3 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"0"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '1'; regs_oe_dest <= instructionWord(3 downto 0); regs_we <= '1'; regs_we_dest <= x"F";
                incSP <= '0'; decSP <= '1'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '0'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";



            --sti instruction
            when sti0 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"0"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '1'; regs_oe_dest <= instructionWord(7 downto 4); regs_we <= '0'; regs_we_dest <= x"0";
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '1'; misooe <= '0';
                wr <= '0'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";
            when sti1 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"0"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '1'; regs_oe_dest <= instructionWord(3 downto 0); regs_we <= '0'; regs_we_dest <= x"0";
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '1'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '0'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";
            when sti2 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"0"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '0'; regs_oe_dest <= x"0"; regs_we <= '0'; regs_we_dest <= x"0";
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '1'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";
            
            --st instruction
            when st0 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"0"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '1'; regs_oe_dest <= instructionWord(27 downto 24); regs_we <= '0'; regs_we_dest <= x"0";
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '1'; misooe <= '0';
                wr <= '0'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";
            when st1 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"0"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '0'; regs_oe_dest <= x"0"; regs_we <= '0'; regs_we_dest <= x"0";
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00" & instructionWord(23 downto 0); instrArgoe <= '1';
                addrRegwe <= '1'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '0'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";
            when st2 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"0"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '0'; regs_oe_dest <= x"0"; regs_we <= '0'; regs_we_dest <= x"0";
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '1'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";




            --interrupts
            when interrupt0 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"0"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '1'; regs_oe_dest <= x"E"; regs_we <= '0'; regs_we_dest <= x"0";
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '1'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '0'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";
            when interrupt1 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"0"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '1'; regs_oe_dest <= x"F"; regs_we <= '0'; regs_we_dest <= x"0";
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '1'; misooe <= '0';
                wr <= '0'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";
            when interrupt2 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"0"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '0'; regs_oe_dest <= x"0"; regs_we <= '0'; regs_we_dest <= x"0";
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '1'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";
            when interrupt3 =>
                int_accept <= '1'; int_completed <= '0';
                aluOpCode <= x"0"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '0'; regs_oe_dest <= x"0"; regs_we <= '1'; regs_we_dest <= x"F";
                incSP <= '0'; decSP <= '1'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= interrupt_vector; instrArgoe <= '1';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '0'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";

            --MVIL instruction
            when mvil0 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"7"; aluoe <= '0'; aluOpAwe <= '1'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '1'; regs_oe_dest <= instructionWord(19 downto 16); regs_we <= '0'; regs_we_dest <= x"0";
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '0'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";
            when mvil1 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"7"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '1';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '0'; regs_oe_dest <= x"0"; regs_we <= '0'; regs_we_dest <= x"0";
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"0000" & instructionWord(15 downto 0); instrArgoe <= '1';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '0'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";
            when mvil2 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"7"; aluoe <= '1'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '0'; regs_oe_dest <= x"0"; regs_we <= '1'; regs_we_dest <= instructionWord(19 downto 16);
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '0'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";   


            --MVIH instruction
            when mvih0 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"8"; aluoe <= '0'; aluOpAwe <= '1'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '1'; regs_oe_dest <= instructionWord(19 downto 16); regs_we <= '0'; regs_we_dest <= x"0";
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '0'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";
            when mvih1 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"8"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '1';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '0'; regs_oe_dest <= x"0"; regs_we <= '0'; regs_we_dest <= x"0";
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"0000" & instructionWord(15 downto 0); instrArgoe <= '1';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '0'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";
            when mvih2 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"8"; aluoe <= '1'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '0'; regs_oe_dest <= x"0"; regs_we <= '1'; regs_we_dest <= instructionWord(19 downto 16);
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '0'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";   



            --LD instruction
            when ld0 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"0"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '0'; regs_oe_dest <= x"0"; regs_we <= '0'; regs_we_dest <= x"0";
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00" & instructionWord(23 downto 0); instrArgoe <= '1';
                addrRegwe <= '1'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '0'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";
            when ld1 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"0"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '0'; regs_oe_dest <= x"0"; regs_we <= '0'; regs_we_dest <= x"0";
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '0'; rd <= '1';
                addressSel <= '0'; flagRegSel <= x"0";
            when ld2 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"0"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '0'; regs_oe_dest <= x"0"; regs_we <= '1'; regs_we_dest <= instructionWord(27 downto 24);
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '1';
                wr <= '0'; rd <= '1';
                addressSel <= '0'; flagRegSel <= x"0";

            --LDI instruction
            when ldi0 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"0"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '1'; regs_oe_dest <= instructionWord(3 downto 0); regs_we <= '0'; regs_we_dest <= x"0";
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '1'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '0'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";
            when ldi1 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"0"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '0'; regs_oe_dest <= x"0"; regs_we <= '0'; regs_we_dest <= x"0";
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '0'; rd <= '1';
                addressSel <= '0'; flagRegSel <= x"0";
            when ldi2 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"0"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '0'; regs_oe_dest <= x"0"; regs_we <= '1'; regs_we_dest <= instructionWord(7 downto 4);
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '1';
                wr <= '0'; rd <= '1';
                addressSel <= '0'; flagRegSel <= x"0";        
            
            --BZ instruction
            when bz0 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"0"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '0'; regs_oe_dest <= x"0"; regs_we <= '0'; regs_we_dest <= x"0";
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '0'; rd <= '0';
                addressSel <= '0'; flagRegSel <= std_logic_vector(instructionWord(27 downto 24));
            when bz1 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"0"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '0'; regs_oe_dest <= x"0"; regs_we <= '1'; regs_we_dest <= x"F";
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00" & instructionWord(23 downto 0); instrArgoe <= '1';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '0'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";

            --BNZ instruction
            when bnz0 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"0"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '0'; regs_oe_dest <= x"0"; regs_we <= '0'; regs_we_dest <= x"0";
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '0'; rd <= '0';
                addressSel <= '0'; flagRegSel <= std_logic_vector(instructionWord(27 downto 24));
            when bnz1 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"0"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '0'; regs_oe_dest <= x"0"; regs_we <= '1'; regs_we_dest <= x"F";
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00" & instructionWord(23 downto 0); instrArgoe <= '1';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '0'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";

            --BZI instruction
            when bzi0 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"0"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '0'; regs_oe_dest <= x"0"; regs_we <= '0'; regs_we_dest <= x"0";
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '0'; rd <= '0';
                addressSel <= '0'; flagRegSel <= std_logic_vector(instructionWord(7 downto 4));
            when bzi1 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"0"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '1'; regs_oe_dest <= instructionWord(3 downto 0); regs_we <= '1'; regs_we_dest <= x"F";
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '0'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";

            --BNZI instruction
            when bnzi0 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"0"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '0'; regs_oe_dest <= x"0"; regs_we <= '0'; regs_we_dest <= x"0";
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '0'; rd <= '0';
                addressSel <= '0'; flagRegSel <= std_logic_vector(instructionWord(7 downto 4));
            when bnzi1 =>
                int_accept <= '0'; int_completed <= '0';
                aluOpCode <= x"0"; aluoe <= '0'; aluOpAwe <= '0'; aluOpBwe <= '0';
                compOpCode <= "000"; compoe <= '0'; compOpAwe <= '0'; compOpBwe <= '0';
                barDistance <= x"0"; barDir <= '0'; barMode <= '0'; baroe <= '0'; barOpAwe <= '0';
                regs_oe <= '1'; regs_oe_dest <= instructionWord(3 downto 0); regs_we <= '1'; regs_we_dest <= x"F";
                incSP <= '0'; decSP <= '0'; incPC <= '0'; decPC <= '0';
                instRegwe <= '0';
                instructionArgument <= x"00000000"; instrArgoe <= '0';
                addrRegwe <= '0'; mosiRegwe <= '0'; misooe <= '0';
                wr <= '0'; rd <= '0';
                addressSel <= '0'; flagRegSel <= x"0";
            
        end case;
    end process;

    --help to recognize interrupt to FSM
    process(int) is begin
        if(int = x"00000000") then
            interrupt_pending <= '0';
        else
            interrupt_pending <= '1';
        end if;
    end process;

    --decode ISR vector
    process(int) is begin
        case int is
            when x"00000001" => interrupt_vector <= x"00000010";
            when x"00000002" => interrupt_vector <= x"00000012";
            when x"00000004" => interrupt_vector <= x"00000014";
            when x"00000008" => interrupt_vector <= x"00000016";
            when x"00000010" => interrupt_vector <= x"00000018";
            when x"00000020" => interrupt_vector <= x"0000001A";
            when x"00000040" => interrupt_vector <= x"0000001C";
            when x"00000080" => interrupt_vector <= x"0000001E";
            when x"00000100" => interrupt_vector <= x"00000020";
            when x"00000200" => interrupt_vector <= x"00000022";
            when x"00000400" => interrupt_vector <= x"00000024";
            when x"00000800" => interrupt_vector <= x"00000026";
            when x"00001000" => interrupt_vector <= x"00000028";
            when x"00002000" => interrupt_vector <= x"0000002A";
            when x"00004000" => interrupt_vector <= x"0000002C";
            when x"00008000" => interrupt_vector <= x"0000002E";
            when x"00010000" => interrupt_vector <= x"00000030";
            when x"00020000" => interrupt_vector <= x"00000032";
            when x"00040000" => interrupt_vector <= x"00000034";
            when x"00080000" => interrupt_vector <= x"00000036";
            when x"00100000" => interrupt_vector <= x"00000038";
            when x"00200000" => interrupt_vector <= x"0000003A";
            when x"00400000" => interrupt_vector <= x"0000003C";
            when x"00800000" => interrupt_vector <= x"0000003E";
            when x"01000000" => interrupt_vector <= x"00000040";
            when x"02000000" => interrupt_vector <= x"00000042";
            when x"04000000" => interrupt_vector <= x"00000044";
            when x"08000000" => interrupt_vector <= x"00000046";
            when x"10000000" => interrupt_vector <= x"00000048";
            when x"20000000" => interrupt_vector <= x"0000004A";
            when x"40000000" => interrupt_vector <= x"0000004C";
            when x"80000000" => interrupt_vector <= x"0000004E";
            when others => interrupt_vector <= x"00000000";
        end case;
    end process;
    
    --decoders for registers control signals
    process(regs_oe_dest, regs_oe) is begin
        if    (regs_oe_dest = x"0" and regs_oe = '1') then regOE <= x"0001";
        elsif (regs_oe_dest = x"1" and regs_oe = '1') then regOE <= x"0002";
        elsif (regs_oe_dest = x"2" and regs_oe = '1') then regOE <= x"0004";
        elsif (regs_oe_dest = x"3" and regs_oe = '1') then regOE <= x"0008";
        elsif (regs_oe_dest = x"4" and regs_oe = '1') then regOE <= x"0010";
        elsif (regs_oe_dest = x"5" and regs_oe = '1') then regOE <= x"0020";
        elsif (regs_oe_dest = x"6" and regs_oe = '1') then regOE <= x"0040";
        elsif (regs_oe_dest = x"7" and regs_oe = '1') then regOE <= x"0080";
        elsif (regs_oe_dest = x"8" and regs_oe = '1') then regOE <= x"0100";
        elsif (regs_oe_dest = x"9" and regs_oe = '1') then regOE <= x"0200";
        elsif (regs_oe_dest = x"A" and regs_oe = '1') then regOE <= x"0400";
        elsif (regs_oe_dest = x"B" and regs_oe = '1') then regOE <= x"0800";
        elsif (regs_oe_dest = x"C" and regs_oe = '1') then regOE <= x"1000";
        elsif (regs_oe_dest = x"D" and regs_oe = '1') then regOE <= x"2000";
        elsif (regs_oe_dest = x"E" and regs_oe = '1') then regOE <= x"4000";
        elsif (regs_oe_dest = x"F" and regs_oe = '1') then regOE <= x"8000";
        else regOE <= x"0000";
        end if;
    end process;
    
    process(regs_we_dest, regs_we) is begin
        if    (regs_we_dest = x"0" and regs_we = '1') then regWE <= x"0001";
        elsif (regs_we_dest = x"1" and regs_we = '1') then regWE <= x"0002";
        elsif (regs_we_dest = x"2" and regs_we = '1') then regWE <= x"0004";
        elsif (regs_we_dest = x"3" and regs_we = '1') then regWE <= x"0008";
        elsif (regs_we_dest = x"4" and regs_we = '1') then regWE <= x"0010";
        elsif (regs_we_dest = x"5" and regs_we = '1') then regWE <= x"0020";
        elsif (regs_we_dest = x"6" and regs_we = '1') then regWE <= x"0040";
        elsif (regs_we_dest = x"7" and regs_we = '1') then regWE <= x"0080";
        elsif (regs_we_dest = x"8" and regs_we = '1') then regWE <= x"0100";
        elsif (regs_we_dest = x"9" and regs_we = '1') then regWE <= x"0200";
        elsif (regs_we_dest = x"A" and regs_we = '1') then regWE <= x"0400";
        elsif (regs_we_dest = x"B" and regs_we = '1') then regWE <= x"0800";
        elsif (regs_we_dest = x"C" and regs_we = '1') then regWE <= x"1000";
        elsif (regs_we_dest = x"D" and regs_we = '1') then regWE <= x"2000";
        elsif (regs_we_dest = x"E" and regs_we = '1') then regWE <= x"4000";
        elsif (regs_we_dest = x"F" and regs_we = '1') then regWE <= x"8000";
        else regWE <= x"0000";
        end if;
    end process;


end architecture id_arch;
