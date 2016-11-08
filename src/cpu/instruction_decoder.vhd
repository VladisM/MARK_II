library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instruction_decoder is 
    port(
        --main control inputs
        res: in std_logic;
        clk: in std_logic;
        int: in std_logic;
        --regs
        regs_wr_select: out std_logic_vector(15 downto 0);
        regs_oe_select: out std_logic_vector(15 downto 0);
        --ALU
        alu_lt: in std_logic;  
        alu_ltu: in std_logic; 
        alu_ge: in std_logic;                         
        alu_geu: in std_logic; 
        alu_eqv: in std_logic;
        alu_oe: out std_logic;
        alu_wrA: out std_logic;
        alu_wrB: out std_logic;
        alu_opcode: out std_logic_vector(3 downto 0);
        --external BUS
        bus_ext_WR: out std_logic;
        bus_ext_RD: out std_logic;
        bus_WRadd: out std_logic;
        bus_WRdat: out std_logic;
        bus_RDdat: out std_logic;
        --instruction register
        instruction_word: in std_logic_vector(31 downto 0);
        instruction_reg_wr: out std_logic;
        --instruction argument
        ins_arg_input: out std_logic_vector(31 downto 0);
        ins_arg_oe: out std_logic;
        --control outputs
        int_accept: buffer std_logic;
        int_completed: out std_logic
    );
end entity instruction_decoder;

--It is fucking large state machine 
architecture instruction_decoder_arch of instruction_decoder is
    -- states of the FSM
    type state_type is (
        --this is just for start program decoder it's do nothing interesting
        start,
        --following states are for load instruction and increment proogram counter
        load_instr_inc_pc_0, load_instr_inc_pc_1, load_instr_inc_pc_2, load_instr_inc_pc_3, load_instr_inc_pc_4, load_instr_inc_pc_5,
        
        --mov instruction
        mov_0, mov_1,
        --LD instruction
        ld_0, ld_1, ld_2, ld_3,
        --ST instriction
        st_0, st_1, st_2, st_3, st_4, st_5,
        --call instruction
        call_0, call_1, call_2, call_3, call_4, call_5, call_6, call_7,
        --ret instruction
        ret_0, ret_1, ret_2, ret_3, ret_4, ret_5,
        --ADD instruction
        add_0, add_1, add_2, add_3, add_4, add_5,
        --SUB instruction
        sub_0, sub_1, sub_2, sub_3, sub_4, sub_5,
        --OR instruction
        or_0, or_1, or_2, or_3, or_4, or_5,
        --AND instruction
        and_0, and_1, and_2, and_3, and_4, and_5,
        --XOR instruction
        xor_0, xor_1, xor_2, xor_3, xor_4, xor_5,
        --NOT instruction
        not_0, not_1, not_2, not_3,
        --ROR instruction
        ror_0, ror_1, ror_2, ror_3,
        --ROL instruction
        rol_0, rol_1, rol_2, rol_3,
        --INC instruction
        inc_0, inc_1, inc_2, inc_3,
        --DEC instruction
        dec_0, dec_1, dec_2, dec_3,
        --BEQ instruction
        beq_0, beq_1, beq_2, beq_3, beq_4, beq_5,
        --BNE instruction
        bne_0, bne_1, bne_2, bne_3, bne_4, bne_5,
        --BLT instruction
        blt_0, blt_1, blt_2, blt_3, blt_4, blt_5,
        --BLTU instruction
        bltu_0, bltu_1, bltu_2, bltu_3, bltu_4, bltu_5,
        --BGE instruction
        bge_0, bge_1, bge_2, bge_3, bge_4, bge_5,
        --BGEU instruction
        bgeu_0, bgeu_1, bgeu_2, bgeu_3, bgeu_4, bgeu_5,
        --reti instruction
        reti_0, reti_1, reti_2, reti_3, reti_4, reti_5,
        --mvil instruction
        mvil_0, mvil_1, mvil_2, mvil_3, mvil_4, mvil_5,
        --mvih instruction
        mvih_0, mvih_1, mvih_2, mvih_3, mvih_4, mvih_5,
        
        
        --this is states for save pc into stack and decrement stack pointer 
        save_pc_dec_sp_0, save_pc_dec_sp_1, save_pc_dec_sp_2, save_pc_dec_sp_3, save_pc_dec_sp_4, save_pc_dec_sp_5,  
        --set interrupt vector
        set_int_vec_0, set_int_vec_1
    );
    -- reg for current state
    signal state   : state_type;
    
    -- this signal is for register control signals
    signal regs_wr_dest, regs_oe_dest: std_logic_vector(3 downto 0);
    signal regs_wr, regs_oe: std_logic;
    
    --this is for synchronous outputs
    signal asyn_regs_wr_select: std_logic_vector(15 downto 0);
    signal asyn_regs_oe_select: std_logic_vector(15 downto 0);
    signal asyn_alu_oe: std_logic;
    signal asyn_alu_wrA: std_logic;
    signal asyn_alu_wrB: std_logic;
    signal asyn_alu_opcode: std_logic_vector(3 downto 0);
    signal asyn_bus_ext_WR: std_logic;
    signal asyn_bus_ext_RD: std_logic;
    signal asyn_bus_WRadd: std_logic;
    signal asyn_bus_WRdat: std_logic;
    signal asyn_bus_RDdat: std_logic;
    signal asyn_instruction_reg_wr: std_logic;
    signal asyn_ins_arg_input: std_logic_vector(31 downto 0);
    signal asyn_ins_arg_oe: std_logic;
    signal asyn_int_completed: std_logic;
    
    --register for assychronous interrupt input
    signal interrupt_pending: std_logic;
        
begin
    
    --logic to set next state
    process (clk, res, int, alu_eqv, alu_lt, alu_ltu, alu_ge, alu_geu, instruction_word) begin
        if res = '1' then
            state <= start;
        elsif (rising_edge(clk)) then
            case state is
                --cpu started or reseted
                when start => state <= load_instr_inc_pc_0;
                
                -- load instruction and increment pc
                when load_instr_inc_pc_0 => state <= load_instr_inc_pc_1;
                when load_instr_inc_pc_1 => state <= load_instr_inc_pc_2;
                when load_instr_inc_pc_2 => state <= load_instr_inc_pc_3;
                when load_instr_inc_pc_3 => state <= load_instr_inc_pc_4;
                when load_instr_inc_pc_4 => state <= load_instr_inc_pc_5;
                when load_instr_inc_pc_5 =>  --we have instruction loaded so we must decide what instruction is it and execute it
                    if    instruction_word(31 downto 26) = "000000" then state <= mov_0;
                    elsif instruction_word(31 downto 26) = "000001" then state <= ld_0;
                    elsif instruction_word(31 downto 26) = "000010" then state <= st_0;
                    elsif instruction_word(31 downto 26) = "000011" then state <= mvil_0;
                    elsif instruction_word(31 downto 26) = "000100" then state <= call_0;
                    elsif instruction_word(31 downto 26) = "000101" then state <= ret_0;
                    elsif instruction_word(31 downto 26) = "000110" then state <= beq_0;
                    elsif instruction_word(31 downto 26) = "000111" then state <= bne_0;
                    elsif instruction_word(31 downto 26) = "001000" then state <= add_0;
                    elsif instruction_word(31 downto 26) = "001001" then state <= sub_0;
                    elsif instruction_word(31 downto 26) = "001010" then state <= or_0;
                    elsif instruction_word(31 downto 26) = "001011" then state <= and_0;
                    elsif instruction_word(31 downto 26) = "001100" then state <= not_0;
                    elsif instruction_word(31 downto 26) = "001101" then state <= xor_0;
                    elsif instruction_word(31 downto 26) = "001110" then state <= rol_0;                
                    elsif instruction_word(31 downto 26) = "001111" then state <= ror_0;                
                    elsif instruction_word(31 downto 26) = "010000" then state <= blt_0;
                    elsif instruction_word(31 downto 26) = "010001" then state <= bltu_0;
                    elsif instruction_word(31 downto 26) = "010010" then state <= bge_0;
                    elsif instruction_word(31 downto 26) = "010011" then state <= bgeu_0;
                    elsif instruction_word(31 downto 26) = "010100" then state <= inc_0;
                    elsif instruction_word(31 downto 26) = "010101" then state <= dec_0;
                    elsif instruction_word(31 downto 26) = "010110" then state <= mvih_0;
                    elsif instruction_word(31 downto 26) = "010111" then state <= reti_0;
                    else state <= start;
                    end if;
               
                --MOV instruction execution
                when mov_0 => state <= mov_1;
                when mov_1 => 
                    if interrupt_pending = '1' then
                        state <= save_pc_dec_sp_0;
                    else 
                        state <= load_instr_inc_pc_0;
                    end if;
                --execute LD
                when ld_0 => state <= ld_1;
                when ld_1 => state <= ld_2;
                when ld_2 => state <= ld_3;
                when ld_3 =>
                    if interrupt_pending = '1' then
                        state <= save_pc_dec_sp_0;
                    else 
                        state <= load_instr_inc_pc_0;
                    end if;
                --execute ST
                when st_0 => state <= st_1;
                when st_1 => state <= st_2;
                when st_2 => state <= st_3;
                when st_3 => state <= st_4;
                when st_4 => state <= st_5;
                when st_5 =>
                    if interrupt_pending = '1' then
                        state <= save_pc_dec_sp_0;
                    else 
                        state <= load_instr_inc_pc_0;
                    end if;              

                --MVIL
                when mvil_0 => state <= mvil_1;
                when mvil_1 => state <= mvil_2;
                when mvil_2 => state <= mvil_3;
                when mvil_3 => state <= mvil_4;
                when mvil_4 => state <= mvil_5;                
                when mvil_5 => 
                    if interrupt_pending = '1' then
                        state <= save_pc_dec_sp_0;
                    else 
                        state <= load_instr_inc_pc_0;
                    end if;
                    
                --MVIH
                when mvih_0 => state <= mvih_1;
                when mvih_1 => state <= mvih_2;
                when mvih_2 => state <= mvih_3;
                when mvih_3 => state <= mvih_4;
                when mvih_4 => state <= mvih_5;                
                when mvih_5 => 
                    if interrupt_pending = '1' then
                        state <= save_pc_dec_sp_0;
                    else 
                        state <= load_instr_inc_pc_0;
                    end if;
                    
                --CALL
                when call_0 => state <= call_1;
                when call_1 => state <= call_2;
                when call_2 => state <= call_3;
                when call_3 => state <= call_4;
                when call_4 => state <= call_5;
                when call_5 => state <= call_6;
                when call_6 => state <= call_7;
                when call_7 =>
                    if interrupt_pending = '1' then
                        state <= save_pc_dec_sp_0;
                    else
                        state <= load_instr_inc_pc_0;
                    end if;
                --RET
                when ret_0 => state <= ret_1;
                when ret_1 => state <= ret_2;
                when ret_2 => state <= ret_3;
                when ret_3 => state <= ret_4;
                when ret_4 => state <= ret_5;
                when ret_5 =>
                    if interrupt_pending = '1' then
                        state <= save_pc_dec_sp_0;
                    else
                        state <= load_instr_inc_pc_0;
                    end if;
                    
                --ADD
                when add_0 => state <= add_1;
                when add_1 => state <= add_2;
                when add_2 => state <= add_3;
                when add_3 => state <= add_4;
                when add_4 => state <= add_5;
                when add_5 =>
                    if interrupt_pending = '1' then
                        state <= save_pc_dec_sp_0;
                    else
                        state <= load_instr_inc_pc_0;
                    end if;
                    
                --SUB
                when sub_0 => state <= sub_1;
                when sub_1 => state <= sub_2;
                when sub_2 => state <= sub_3;
                when sub_3 => state <= sub_4;
                when sub_4 => state <= sub_5;
                when sub_5 =>
                    if interrupt_pending = '1' then
                        state <= save_pc_dec_sp_0;
                    else
                        state <= load_instr_inc_pc_0;
                    end if;
                    
                --OR
                when or_0 => state <= or_1;
                when or_1 => state <= or_2;
                when or_2 => state <= or_3;
                when or_3 => state <= or_4;
                when or_4 => state <= or_5;
                when or_5 =>
                    if interrupt_pending = '1' then
                        state <= save_pc_dec_sp_0;
                    else
                        state <= load_instr_inc_pc_0;
                    end if;
                    
                --AND
                when and_0 => state <= and_1;
                when and_1 => state <= and_2;
                when and_2 => state <= and_3;
                when and_3 => state <= and_4;
                when and_4 => state <= and_5;
                when and_5 =>
                    if interrupt_pending = '1' then
                        state <= save_pc_dec_sp_0;
                    else
                        state <= load_instr_inc_pc_0;
                    end if;
                    
                --XOR
                when xor_0 => state <= xor_1;
                when xor_1 => state <= xor_2;
                when xor_2 => state <= xor_3;
                when xor_3 => state <= xor_4;
                when xor_4 => state <= xor_5;
                when xor_5 =>
                    if interrupt_pending = '1' then
                        state <= save_pc_dec_sp_0;
                    else
                        state <= load_instr_inc_pc_0;
                    end if;
                    
                --NOT instruction
                when not_0 => state <= not_1;
                when not_1 => state <= not_2;
                when not_2 => state <= not_3;
                when not_3 =>
                    if interrupt_pending = '1' then
                        state <= save_pc_dec_sp_0;
                    else
                        state <= load_instr_inc_pc_0;
                    end if;
                    
                --ROR instruction
                when ror_0 => state <= ror_1;
                when ror_1 => state <= ror_2;
                when ror_2 => state <= ror_3;
                when ror_3 =>
                    if interrupt_pending = '1' then
                        state <= save_pc_dec_sp_0;
                    else
                        state <= load_instr_inc_pc_0;
                    end if;
                    
                --ROL instruction
                when rol_0 => state <= rol_1;
                when rol_1 => state <= rol_2;
                when rol_2 => state <= rol_3;
                when rol_3 =>
                    if interrupt_pending = '1' then
                        state <= save_pc_dec_sp_0;
                    else
                        state <= load_instr_inc_pc_0;
                    end if;
                    
                --INC instruction
                when inc_0 => state <= inc_1;
                when inc_1 => state <= inc_2;
                when inc_2 => state <= inc_3;
                when inc_3 =>
                    if interrupt_pending = '1' then
                        state <= save_pc_dec_sp_0;
                    else
                        state <= load_instr_inc_pc_0;
                    end if;
                    
                --DEC instruction
                when dec_0 => state <= dec_1;
                when dec_1 => state <= dec_2;
                when dec_2 => state <= dec_3;
                when dec_3 =>
                    if interrupt_pending = '1' then
                        state <= save_pc_dec_sp_0;
                    else
                        state <= load_instr_inc_pc_0;
                    end if;
                
                --BEQ instruction
                when beq_0 => state <= beq_1;
                when beq_1 => state <= beq_2;
                when beq_2 => state <= beq_3;
                when beq_3 => state <= beq_4;
                when beq_4 =>
                    if alu_eqv = '1' then
                        state <= beq_5;
                    else
                        if interrupt_pending = '1' then
                            state <= save_pc_dec_sp_0;
                        else
                            state <= load_instr_inc_pc_0;
                        end if;
                    end if;
                when beq_5 =>
                    if interrupt_pending = '1' then
                        state <= save_pc_dec_sp_0;
                    else
                        state <= load_instr_inc_pc_0;
                    end if;
                
                --BNE instruction
                when bne_0 => state <= bne_1;
                when bne_1 => state <= bne_2;
                when bne_2 => state <= bne_3;
                when bne_3 => state <= bne_4;
                when bne_4 =>
                    if alu_eqv = '0' then
                        state <= bne_5;
                    else
                        if interrupt_pending = '1' then
                            state <= save_pc_dec_sp_0;
                        else
                            state <= load_instr_inc_pc_0;
                        end if;
                    end if;
                when bne_5 =>
                    if interrupt_pending = '1' then
                        state <= save_pc_dec_sp_0;
                    else
                        state <= load_instr_inc_pc_0;
                    end if;
                
                --BLT instruction
                when blt_0 => state <= blt_1;
                when blt_1 => state <= blt_2;
                when blt_2 => state <= blt_3;
                when blt_3 => state <= blt_4;
                when blt_4 =>
                    if alu_lt = '1' then
                        state <= blt_5;
                    else
                        if interrupt_pending = '1' then
                            state <= save_pc_dec_sp_0;
                        else
                            state <= load_instr_inc_pc_0;
                        end if;
                    end if;
                when blt_5 =>
                    if interrupt_pending = '1' then
                        state <= save_pc_dec_sp_0;
                    else
                        state <= load_instr_inc_pc_0;
                    end if;
                
                --BLTU instruction
                when bltu_0 => state <= bltu_1;
                when bltu_1 => state <= bltu_2;
                when bltu_2 => state <= bltu_3;
                when bltu_3 => state <= bltu_4;
                when bltu_4 =>
                    if alu_ltu = '1' then
                        state <= bltu_5;
                    else
                        if interrupt_pending = '1' then
                            state <= save_pc_dec_sp_0;
                        else
                            state <= load_instr_inc_pc_0;
                        end if;
                    end if;
                when bltu_5 =>
                    if interrupt_pending = '1' then
                        state <= save_pc_dec_sp_0;
                    else
                        state <= load_instr_inc_pc_0;
                    end if;
                
                --BGE instruction
                when bge_0 => state <= bge_1;
                when bge_1 => state <= bge_2;
                when bge_2 => state <= bge_3;
                when bge_3 => state <= bge_4;
                when bge_4 =>
                    if alu_ge = '1' then
                        state <= bge_5;
                    else
                        if interrupt_pending = '1' then
                            state <= save_pc_dec_sp_0;
                        else
                            state <= load_instr_inc_pc_0;
                        end if;
                    end if;
                when bge_5 =>
                    if interrupt_pending = '1' then
                        state <= save_pc_dec_sp_0;
                    else
                        state <= load_instr_inc_pc_0;
                    end if;
                
                --BGEU instruction
                when bgeu_0 => state <= bgeu_1;
                when bgeu_1 => state <= bgeu_2;
                when bgeu_2 => state <= bgeu_3;
                when bgeu_3 => state <= bgeu_4;
                when bgeu_4 =>
                    if alu_geu = '1' then
                        state <= bgeu_5;
                    else
                        if interrupt_pending = '1' then
                            state <= save_pc_dec_sp_0;
                        else
                            state <= load_instr_inc_pc_0;
                        end if;
                    end if;
                when bgeu_5 =>
                    if interrupt_pending = '1' then
                        state <= save_pc_dec_sp_0;
                    else
                        state <= load_instr_inc_pc_0;
                    end if;
                    
                --RETI
                when reti_0 => state <= reti_1;
                when reti_1 => state <= reti_2;
                when reti_2 => state <= reti_3;
                when reti_3 => state <= reti_4;
                when reti_4 => state <= reti_5;
                when reti_5 =>
                    if interrupt_pending = '1' then
                        state <= save_pc_dec_sp_0;
                    else
                        state <= load_instr_inc_pc_0;
                    end if;
                    
                --save program counter, this is prediction for interrupt routine
                when save_pc_dec_sp_0 => state <= save_pc_dec_sp_1;
                when save_pc_dec_sp_1 => state <= save_pc_dec_sp_2;
                when save_pc_dec_sp_2 => state <= save_pc_dec_sp_3;
                when save_pc_dec_sp_3 => state <= save_pc_dec_sp_4;
                when save_pc_dec_sp_4 => state <= save_pc_dec_sp_5;
                when save_pc_dec_sp_5 => state <= set_int_vec_0; --next stage is set interrupt vector
                
                --insert interrupt vector into program counter
                when set_int_vec_0 => state <= set_int_vec_1;
                when set_int_vec_1 => state <= load_instr_inc_pc_0; --return back to start and execute first instruction in interrupt routine :) 
            end case;
        end if;
    end process;
    
    --outputs, this will be fucking long... 
    process (state, clk, instruction_word) begin
        case state is
            --start of the instruction decoder
            when start => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '0'; regs_oe <= '0'; regs_wr_dest <= x"0"; regs_oe_dest <= x"0";                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"0";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
            
            
            --load instruction and increment proogram counter
            when load_instr_inc_pc_0 => 
                asyn_int_completed <= '0'; int_accept <= '0'; 
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= x"E";                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"8";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
                
            when load_instr_inc_pc_1 => 
                asyn_int_completed <= '0'; int_accept <= '0'; 
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= x"E";                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '1'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"8";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '1'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
                
            when load_instr_inc_pc_2 => 
                asyn_int_completed <= '0'; int_accept <= '0'; 
                regs_wr <= '0'; regs_oe <= '0'; regs_wr_dest <= x"0"; regs_oe_dest <= x"0";                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"8";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '1'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '1'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
                
            when load_instr_inc_pc_3 => 
                asyn_int_completed <= '0'; int_accept <= '0'; 
                regs_wr <= '0'; regs_oe <= '0'; regs_wr_dest <= x"0"; regs_oe_dest <= x"0";                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"8";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '1'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '1'; --external BUS
                asyn_instruction_reg_wr <= '1';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
                
            when load_instr_inc_pc_4 => 
                asyn_int_completed <= '0'; int_accept <= '0'; 
                regs_wr <= '0'; regs_oe <= '0'; regs_wr_dest <= x"E"; regs_oe_dest <= x"0";                 --regs
                asyn_alu_oe <= '1'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"8";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
                
            when load_instr_inc_pc_5 => 
                asyn_int_completed <= '0'; int_accept <= '0'; 
                regs_wr <= '1'; regs_oe <= '0'; regs_wr_dest <= x"E"; regs_oe_dest <= x"0";                 --regs
                asyn_alu_oe <= '1'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"8";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
            
            
            --save pc into stack and decrement stack pointer 
            when save_pc_dec_sp_0 => 
                asyn_int_completed <= '0'; int_accept <= '1';  
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= x"F";                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"0";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
                
            when save_pc_dec_sp_1 => 
                asyn_int_completed <= '0'; int_accept <= '0'; 
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= x"F";                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '1'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"0";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '1'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
                
            when save_pc_dec_sp_2 => 
                asyn_int_completed <= '0'; int_accept <= '0'; 
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= x"E";                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"9";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
                
            when save_pc_dec_sp_3 => 
                asyn_int_completed <= '0'; int_accept <= '0';             
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= x"E";                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"9";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '1'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
                
            when save_pc_dec_sp_4 => 
                asyn_int_completed <= '0'; int_accept <= '0'; 
                regs_wr <= '0'; regs_oe <= '0'; regs_wr_dest <= x"F"; regs_oe_dest <= x"0";                 --regs
                asyn_alu_oe <= '1'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"9";                          --ALU
                asyn_bus_ext_WR <= '1'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
                
            when save_pc_dec_sp_5 => 
                asyn_int_completed <= '0'; int_accept <= '0'; 
                regs_wr <= '1'; regs_oe <= '0'; regs_wr_dest <= x"F"; regs_oe_dest <= x"0";                 --regs
                asyn_alu_oe <= '1'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"9";                          --ALU
                asyn_bus_ext_WR <= '1'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
            
            --set interrupt vector
            when set_int_vec_0 => 
                asyn_int_completed <= '0'; int_accept <= '0'; 
                regs_wr <= '0'; regs_oe <= '0'; regs_wr_dest <= x"E"; regs_oe_dest <= x"0";                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"0";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000010"; asyn_ins_arg_oe <= '1';                                            --IA
                
            when set_int_vec_1 => 
                asyn_int_completed <= '0'; int_accept <= '0'; 
                regs_wr <= '1'; regs_oe <= '0'; regs_wr_dest <= x"E"; regs_oe_dest <= x"0";                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"0";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000010"; asyn_ins_arg_oe <= '1';                                            --IA
                
            --instruction MOV
            when mov_0 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= instruction_word(21 downto 18); regs_oe_dest <= instruction_word(25 downto 22);--regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"0";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
            
            when mov_1 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '1'; regs_oe <= '1'; regs_wr_dest <= instruction_word(21 downto 18); regs_oe_dest <= instruction_word(25 downto 22);--regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"0";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA    
                
                
            --instruction LD
            when ld_0 => 
                asyn_int_completed <= '0'; int_accept <= '0'; 
                regs_wr <= '0'; regs_oe <= '0'; regs_wr_dest <= instruction_word(21 downto 18); regs_oe_dest <= x"0";                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"0";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= "00000000000000" & instruction_word(17 downto 0); asyn_ins_arg_oe <= '1';                                            --IA
                
            when ld_1 => 
                asyn_int_completed <= '0'; int_accept <= '0'; 
                regs_wr <= '0'; regs_oe <= '0'; regs_wr_dest <= instruction_word(21 downto 18); regs_oe_dest <= x"0";                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"0";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '1'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= "00000000000000" & instruction_word(17 downto 0); asyn_ins_arg_oe <= '1';                      
                
            when ld_2 => 
                asyn_int_completed <= '0'; int_accept <= '0'; 
                regs_wr <= '0'; regs_oe <= '0'; regs_wr_dest <= instruction_word(21 downto 18); regs_oe_dest <= x"0";                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"0";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '1'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '1'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
                
            when ld_3 => 
                asyn_int_completed <= '0'; int_accept <= '0'; 
                regs_wr <= '1'; regs_oe <= '0'; regs_wr_dest <= instruction_word(21 downto 18); regs_oe_dest <= x"0";                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"0";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '1'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '1'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA    

            
            -- instruction ST
            when st_0 => 
                asyn_int_completed <= '0'; int_accept <= '0'; 
                regs_wr <= '0'; regs_oe <= '0'; regs_wr_dest <= x"0"; regs_oe_dest <= instruction_word(25 downto 22);                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"0";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= "00000000000000" & instruction_word(17 downto 0); asyn_ins_arg_oe <= '1';                                            --IA
            
            when st_1 => 
                asyn_int_completed <= '0'; int_accept <= '0'; 
                regs_wr <= '0'; regs_oe <= '0'; regs_wr_dest <= x"0"; regs_oe_dest <= instruction_word(25 downto 22);                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"0";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '1'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= "00000000000000" & instruction_word(17 downto 0); asyn_ins_arg_oe <= '1';                                            --IA
            
            when st_2 => 
                asyn_int_completed <= '0'; int_accept <= '0'; 
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= instruction_word(25 downto 22);                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"0";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
            
            when st_3 => 
                asyn_int_completed <= '0'; int_accept <= '0'; 
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= instruction_word(25 downto 22);                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"0";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '1'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
            
            when st_4 => 
                asyn_int_completed <= '0'; int_accept <= '0'; 
                regs_wr <= '0'; regs_oe <= '0'; regs_wr_dest <= x"0"; regs_oe_dest <= x"0";                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"0";                          --ALU
                asyn_bus_ext_WR <= '1'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
             
             when st_5 => 
                asyn_int_completed <= '0'; int_accept <= '0'; 
                regs_wr <= '0'; regs_oe <= '0'; regs_wr_dest <= x"0"; regs_oe_dest <= x"0";                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"0";                          --ALU
                asyn_bus_ext_WR <= '1'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
            
--            --MVI instruction
--            when mvi_0 => 
--                asyn_int_completed <= '0'; int_accept <= '0'; 
--                regs_wr <= '0'; regs_oe <= '0'; regs_wr_dest <= instruction_word(21 downto 18); regs_oe_dest <= x"0";                 --regs
--                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"0";                          --ALU
--                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
--                asyn_instruction_reg_wr <= '0';                                                                  --IR
--                asyn_ins_arg_input <= "00000000000000" & instruction_word(17 downto 0); asyn_ins_arg_oe <= '1';            --IA
--                
--            when mvi_1 => 
--                asyn_int_completed <= '0'; int_accept <= '0'; 
--                regs_wr <= '1'; regs_oe <= '0'; regs_wr_dest <= instruction_word(21 downto 18); regs_oe_dest <= x"0";                 --regs
--                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"0";                          --ALU
--                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
--                asyn_instruction_reg_wr <= '0';                                                                  --IR
--                asyn_ins_arg_input <= "00000000000000" & instruction_word(17 downto 0); asyn_ins_arg_oe <= '1';          --IA                
            
            --instruction CALL
            when call_0 => 
                asyn_int_completed <= '0'; int_accept <= '0';  
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= x"F";                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"0";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
                
            when call_1 => 
                asyn_int_completed <= '0'; int_accept <= '0'; 
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= x"F";                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '1'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"0";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '1'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
                
            when call_2 => 
                asyn_int_completed <= '0'; int_accept <= '0'; 
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= x"E";                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"9";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
                
            when call_3 => 
                asyn_int_completed <= '0'; int_accept <= '0';             
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= x"E";                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"9";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '1'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
                
            when call_4 => 
                asyn_int_completed <= '0'; int_accept <= '0'; 
                regs_wr <= '0'; regs_oe <= '0'; regs_wr_dest <= x"0"; regs_oe_dest <= x"F";                 --regs
                asyn_alu_oe <= '1'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"9";                          --ALU
                asyn_bus_ext_WR <= '1'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
                
            when call_5 => 
                asyn_int_completed <= '0'; int_accept <= '0'; 
                regs_wr <= '1'; regs_oe <= '0'; regs_wr_dest <= x"0"; regs_oe_dest <= x"F";                 --regs
                asyn_alu_oe <= '1'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"9";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
             
            when call_6 => 
                asyn_int_completed <= '0'; int_accept <= '0'; 
                regs_wr <= '0'; regs_oe <= '0'; regs_wr_dest <= x"0"; regs_oe_dest <= x"E";                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"0";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= "00000000000000" & instruction_word(17 downto 0); asyn_ins_arg_oe <= '1';                                            --IA
                
            when call_7 => 
                asyn_int_completed <= '0'; int_accept <= '0'; 
                regs_wr <= '1'; regs_oe <= '0'; regs_wr_dest <= x"0"; regs_oe_dest <= x"E";                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"0";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= "00000000000000" & instruction_word(17 downto 0); asyn_ins_arg_oe <= '1';                            --IA  
              
            -- Instruction RET 
            when ret_0 => 
                asyn_int_completed <= '0'; int_accept <= '0'; 
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= x"F";                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"0";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA           
            when ret_1 => 
                asyn_int_completed <= '0'; int_accept <= '0'; 
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= x"F";                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '1'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"0";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '1'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA         
            when ret_2 => 
                asyn_int_completed <= '0'; int_accept <= '0'; 
                regs_wr <= '0'; regs_oe <= '0'; regs_wr_dest <= x"E"; regs_oe_dest <= x"0";                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"8";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '1'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '1'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA            
            when ret_3 => 
                asyn_int_completed <= '0'; int_accept <= '0'; 
                regs_wr <= '1'; regs_oe <= '0'; regs_wr_dest <= x"E"; regs_oe_dest <= x"0";                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"8";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '1'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '1'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
            when ret_4 => 
                asyn_int_completed <= '0'; int_accept <= '0'; 
                regs_wr <= '0'; regs_oe <= '0'; regs_wr_dest <= x"F"; regs_oe_dest <= x"0";                 --regs
                asyn_alu_oe <= '1'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"8";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA            
            when ret_5 => 
                asyn_int_completed <= '0'; int_accept <= '0'; 
                regs_wr <= '1'; regs_oe <= '0'; regs_wr_dest <= x"F"; regs_oe_dest <= x"0";                 --regs
                asyn_alu_oe <= '1'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"8";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
               
            --instruction ADD
            when add_0 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= instruction_word(25 downto 22);                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"0";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
            when add_1 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= instruction_word(25 downto 22);                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '1'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"0";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
            when add_2 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= instruction_word(21 downto 18);                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"0";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
            when add_3 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= instruction_word(21 downto 18);                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '1'; asyn_alu_opcode <= x"0";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';   
            when add_4 => 
                asyn_int_completed <= '0'; int_accept <= '0'; 
                regs_wr <= '0'; regs_oe <= '0'; regs_wr_dest <= instruction_word(25 downto 22); regs_oe_dest <= x"0";                 --regs
                asyn_alu_oe <= '1'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"0";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
            when add_5 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '1'; regs_oe <= '0'; regs_wr_dest <= instruction_word(25 downto 22); regs_oe_dest <= x"0";                 --regs
                asyn_alu_oe <= '1'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"0";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
            
            --instruction SUB
            when sub_0 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= instruction_word(25 downto 22);                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"1";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
            when sub_1 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= instruction_word(25 downto 22);                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '1'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"1";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
            when sub_2 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= instruction_word(21 downto 18);                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"1";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
            when sub_3 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= instruction_word(21 downto 18);                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '1'; asyn_alu_opcode <= x"1";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';   
            when sub_4 => 
                asyn_int_completed <= '0'; int_accept <= '0'; 
                regs_wr <= '0'; regs_oe <= '0'; regs_wr_dest <= instruction_word(25 downto 22); regs_oe_dest <= x"0";                 --regs
                asyn_alu_oe <= '1'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"1";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
            when sub_5 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '1'; regs_oe <= '0'; regs_wr_dest <= instruction_word(25 downto 22); regs_oe_dest <= x"0";                 --regs
                asyn_alu_oe <= '1'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"1";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
                
            --instruction OR
            when or_0 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= instruction_word(25 downto 22);                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"2";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
            when or_1 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= instruction_word(25 downto 22);                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '1'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"2";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
            when or_2 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= instruction_word(21 downto 18);                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"2";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
            when or_3 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= instruction_word(21 downto 18);                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '1'; asyn_alu_opcode <= x"2";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';   
            when or_4 => 
                asyn_int_completed <= '0'; int_accept <= '0'; 
                regs_wr <= '0'; regs_oe <= '0'; regs_wr_dest <= instruction_word(25 downto 22); regs_oe_dest <= x"0";                 --regs
                asyn_alu_oe <= '1'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"2";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
            when or_5 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '1'; regs_oe <= '0'; regs_wr_dest <= instruction_word(25 downto 22); regs_oe_dest <= x"0";                 --regs
                asyn_alu_oe <= '1'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"2";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
            
            --instruction AND
            when and_0 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= instruction_word(25 downto 22);                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"3";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
            when and_1 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= instruction_word(25 downto 22);                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '1'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"3";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
            when and_2 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= instruction_word(21 downto 18);                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"3";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
            when and_3 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= instruction_word(21 downto 18);                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '1'; asyn_alu_opcode <= x"3";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';   
            when and_4 => 
                asyn_int_completed <= '0'; int_accept <= '0'; 
                regs_wr <= '0'; regs_oe <= '0'; regs_wr_dest <= instruction_word(25 downto 22); regs_oe_dest <= x"0";                 --regs
                asyn_alu_oe <= '1'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"3";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
            when and_5 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '1'; regs_oe <= '0'; regs_wr_dest <= instruction_word(25 downto 22); regs_oe_dest <= x"0";                 --regs
                asyn_alu_oe <= '1'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"3";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
                
            --instruction XOR
            when xor_0 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= instruction_word(25 downto 22);                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"5";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
            when xor_1 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= instruction_word(25 downto 22);                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '1'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"5";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
            when xor_2 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= instruction_word(21 downto 18);                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"5";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
            when xor_3 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= instruction_word(21 downto 18);                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '1'; asyn_alu_opcode <= x"5";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';   
            when xor_4 => 
                asyn_int_completed <= '0'; int_accept <= '0'; 
                regs_wr <= '0'; regs_oe <= '0'; regs_wr_dest <= instruction_word(25 downto 22); regs_oe_dest <= x"0";                 --regs
                asyn_alu_oe <= '1'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"5";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
            when xor_5 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '1'; regs_oe <= '0'; regs_wr_dest <= instruction_word(25 downto 22); regs_oe_dest <= x"0";                 --regs
                asyn_alu_oe <= '1'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"5";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
                
            --Instruction NOT
            when not_0 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= instruction_word(25 downto 22);                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"4";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
            when not_1 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= instruction_word(25 downto 22);                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '1'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"4";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA    
            when not_2 => 
                asyn_int_completed <= '0'; int_accept <= '0'; 
                regs_wr <= '0'; regs_oe <= '0'; regs_wr_dest <= instruction_word(25 downto 22); regs_oe_dest <= x"0";                 --regs
                asyn_alu_oe <= '1'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"4";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
            when not_3 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '1'; regs_oe <= '0'; regs_wr_dest <= instruction_word(25 downto 22); regs_oe_dest <= x"0";                 --regs
                asyn_alu_oe <= '1'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"4";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
            
            --Instruction ROR
            when ror_0 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= instruction_word(25 downto 22);                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"6";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
            when ror_1 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= instruction_word(25 downto 22);                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '1'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"6";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA    
            when ror_2 => 
                asyn_int_completed <= '0'; int_accept <= '0'; 
                regs_wr <= '0'; regs_oe <= '0'; regs_wr_dest <= instruction_word(25 downto 22); regs_oe_dest <= x"0";                 --regs
                asyn_alu_oe <= '1'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"6";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
            when ror_3 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '1'; regs_oe <= '0'; regs_wr_dest <= instruction_word(25 downto 22); regs_oe_dest <= x"0";                 --regs
                asyn_alu_oe <= '1'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"6";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
                
            --Instruction ROL
            when rol_0 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= instruction_word(25 downto 22);                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"7";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
            when rol_1 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= instruction_word(25 downto 22);                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '1'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"7";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA    
            when rol_2 => 
                asyn_int_completed <= '0'; int_accept <= '0'; 
                regs_wr <= '0'; regs_oe <= '0'; regs_wr_dest <= instruction_word(25 downto 22); regs_oe_dest <= x"0";                 --regs
                asyn_alu_oe <= '1'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"7";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
            when rol_3 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '1'; regs_oe <= '0'; regs_wr_dest <= instruction_word(25 downto 22); regs_oe_dest <= x"0";                 --regs
                asyn_alu_oe <= '1'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"7";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
                
            --Instruction INC
            when inc_0 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= instruction_word(25 downto 22);                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"8";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
            when inc_1 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= instruction_word(25 downto 22);                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '1'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"8";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA    
            when inc_2 => 
                asyn_int_completed <= '0'; int_accept <= '0'; 
                regs_wr <= '0'; regs_oe <= '0'; regs_wr_dest <= instruction_word(25 downto 22); regs_oe_dest <= x"0";                 --regs
                asyn_alu_oe <= '1'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"8";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
            when inc_3 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '1'; regs_oe <= '0'; regs_wr_dest <= instruction_word(25 downto 22); regs_oe_dest <= x"0";                 --regs
                asyn_alu_oe <= '1'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"8";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA    
                
            --Instruction DEC
            when dec_0 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= instruction_word(25 downto 22);                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"9";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
            when dec_1 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= instruction_word(25 downto 22);                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '1'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"9";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA    
            when dec_2 => 
                asyn_int_completed <= '0'; int_accept <= '0'; 
                regs_wr <= '0'; regs_oe <= '0'; regs_wr_dest <= instruction_word(25 downto 22); regs_oe_dest <= x"0";                 --regs
                asyn_alu_oe <= '1'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"9";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
            when dec_3 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '1'; regs_oe <= '0'; regs_wr_dest <= instruction_word(25 downto 22); regs_oe_dest <= x"0";                 --regs
                asyn_alu_oe <= '1'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"9";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA    
              
            --instruction BEQ
            when beq_0 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= instruction_word(25 downto 22);                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"0";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
            when beq_1 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= instruction_word(25 downto 22);                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '1'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"0";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
            when beq_2 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= instruction_word(21 downto 18);                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"0";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
            when beq_3 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= instruction_word(21 downto 18);                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '1'; asyn_alu_opcode <= x"0";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
            when beq_4 => 
                asyn_int_completed <= '0'; int_accept <= '0'; 
                regs_wr <= '0'; regs_oe <= '0'; regs_wr_dest <= x"E"; regs_oe_dest <= x"0";                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"0";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= "00000000000000" & instruction_word(17 downto 0); asyn_ins_arg_oe <= '1';       --IA    
            when beq_5 => 
                asyn_int_completed <= '0'; int_accept <= '0'; 
                regs_wr <= '1'; regs_oe <= '0'; regs_wr_dest <= x"E"; regs_oe_dest <= x"0";                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"0";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= "00000000000000" & instruction_word(17 downto 0); asyn_ins_arg_oe <= '1';       --IA    
                
            --instruction BNE
            when bne_0 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= instruction_word(25 downto 22);                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"0";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
            when bne_1 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= instruction_word(25 downto 22);                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '1'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"0";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
            when bne_2 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= instruction_word(21 downto 18);                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"0";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
            when bne_3 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= instruction_word(21 downto 18);                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '1'; asyn_alu_opcode <= x"0";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
            when bne_4 => 
                asyn_int_completed <= '0'; int_accept <= '0'; 
                regs_wr <= '0'; regs_oe <= '0'; regs_wr_dest <= x"E"; regs_oe_dest <= x"0";                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"0";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= "00000000000000" & instruction_word(17 downto 0); asyn_ins_arg_oe <= '1';       --IA    
            when bne_5 => 
                asyn_int_completed <= '0'; int_accept <= '0'; 
                regs_wr <= '1'; regs_oe <= '0'; regs_wr_dest <= x"E"; regs_oe_dest <= x"0";                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"0";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= "00000000000000" & instruction_word(17 downto 0); asyn_ins_arg_oe <= '1';       --IA        
            
            --instruction blt
            when blt_0 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= instruction_word(25 downto 22);                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"0";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
            when blt_1 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= instruction_word(25 downto 22);                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '1'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"0";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
            when blt_2 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= instruction_word(21 downto 18);                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"0";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
            when blt_3 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= instruction_word(21 downto 18);                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '1'; asyn_alu_opcode <= x"0";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
            when blt_4 => 
                asyn_int_completed <= '0'; int_accept <= '0'; 
                regs_wr <= '0'; regs_oe <= '0'; regs_wr_dest <= x"E"; regs_oe_dest <= x"0";                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"0";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= "00000000000000" & instruction_word(17 downto 0); asyn_ins_arg_oe <= '1';       --IA    
            when blt_5 => 
                asyn_int_completed <= '0'; int_accept <= '0'; 
                regs_wr <= '1'; regs_oe <= '0'; regs_wr_dest <= x"E"; regs_oe_dest <= x"0";                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"0";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= "00000000000000" & instruction_word(17 downto 0); asyn_ins_arg_oe <= '1';       --IA        
                
            --instruction bltu
            when bltu_0 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= instruction_word(25 downto 22);                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"0";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
            when bltu_1 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= instruction_word(25 downto 22);                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '1'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"0";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
            when bltu_2 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= instruction_word(21 downto 18);                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"0";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
            when bltu_3 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= instruction_word(21 downto 18);                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '1'; asyn_alu_opcode <= x"0";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
            when bltu_4 => 
                asyn_int_completed <= '0'; int_accept <= '0'; 
                regs_wr <= '0'; regs_oe <= '0'; regs_wr_dest <= x"E"; regs_oe_dest <= x"0";                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"0";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= "00000000000000" & instruction_word(17 downto 0); asyn_ins_arg_oe <= '1';       --IA    
            when bltu_5 => 
                asyn_int_completed <= '0'; int_accept <= '0'; 
                regs_wr <= '1'; regs_oe <= '0'; regs_wr_dest <= x"E"; regs_oe_dest <= x"0";                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"0";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= "00000000000000" & instruction_word(17 downto 0); asyn_ins_arg_oe <= '1';       --IA      
                
            --instruction bge
            when bge_0 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= instruction_word(25 downto 22);                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"0";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
            when bge_1 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= instruction_word(25 downto 22);                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '1'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"0";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
            when bge_2 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= instruction_word(21 downto 18);                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"0";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
            when bge_3 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= instruction_word(21 downto 18);                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '1'; asyn_alu_opcode <= x"0";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
            when bge_4 => 
                asyn_int_completed <= '0'; int_accept <= '0'; 
                regs_wr <= '0'; regs_oe <= '0'; regs_wr_dest <= x"E"; regs_oe_dest <= x"0";                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"0";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= "00000000000000" & instruction_word(17 downto 0); asyn_ins_arg_oe <= '1';       --IA    
            when bge_5 => 
                asyn_int_completed <= '0'; int_accept <= '0'; 
                regs_wr <= '1'; regs_oe <= '0'; regs_wr_dest <= x"E"; regs_oe_dest <= x"0";                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"0";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= "00000000000000" & instruction_word(17 downto 0); asyn_ins_arg_oe <= '1';       --IA       
                
            --instruction bgeu
            when bgeu_0 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= instruction_word(25 downto 22);                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"0";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
            when bgeu_1 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= instruction_word(25 downto 22);                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '1'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"0";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
            when bgeu_2 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= instruction_word(21 downto 18);                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"0";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
            when bgeu_3 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= instruction_word(21 downto 18);                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '1'; asyn_alu_opcode <= x"0";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
            when bgeu_4 => 
                asyn_int_completed <= '0'; int_accept <= '0'; 
                regs_wr <= '0'; regs_oe <= '0'; regs_wr_dest <= x"E"; regs_oe_dest <= x"0";                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"0";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= "00000000000000" & instruction_word(17 downto 0); asyn_ins_arg_oe <= '1';       --IA    
            when bgeu_5 => 
                asyn_int_completed <= '0'; int_accept <= '0'; 
                regs_wr <= '1'; regs_oe <= '0'; regs_wr_dest <= x"E"; regs_oe_dest <= x"0";                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"0";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= "00000000000000" & instruction_word(17 downto 0); asyn_ins_arg_oe <= '1';       --IA          
                
            -- Instruction RET 
            when reti_0 => 
                asyn_int_completed <= '0'; int_accept <= '0'; 
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= x"F";                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"0";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA           
            when reti_1 => 
                asyn_int_completed <= '0'; int_accept <= '0'; 
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= x"F";                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '1'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"0";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '1'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA         
            when reti_2 => 
                asyn_int_completed <= '0'; int_accept <= '0'; 
                regs_wr <= '0'; regs_oe <= '0'; regs_wr_dest <= x"E"; regs_oe_dest <= x"0";                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"8";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '1'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '1'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA            
            when reti_3 => 
                asyn_int_completed <= '0'; int_accept <= '0'; 
                regs_wr <= '1'; regs_oe <= '0'; regs_wr_dest <= x"E"; regs_oe_dest <= x"0";                 --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"8";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '1'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '1'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
            when reti_4 => 
                asyn_int_completed <= '0'; int_accept <= '0'; 
                regs_wr <= '0'; regs_oe <= '0'; regs_wr_dest <= x"F"; regs_oe_dest <= x"0";                 --regs
                asyn_alu_oe <= '1'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"8";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA            
            when reti_5 => 
                asyn_int_completed <= '1'; int_accept <= '0'; 
                regs_wr <= '1'; regs_oe <= '0'; regs_wr_dest <= x"F"; regs_oe_dest <= x"0";                 --regs
                asyn_alu_oe <= '1'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"8";                          --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';                                                                  --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';                                            --IA
               
            --MVIL instruction
            when mvil_0 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= instruction_word(21 downto 18);      --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"2";      --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';          --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';     --IA
            when mvil_1 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= instruction_word(21 downto 18);      --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '1'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"2";      --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';          --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';     --IA
            when mvil_2 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '0'; regs_oe <= '0'; regs_wr_dest <= x"0"; regs_oe_dest <= x"0";      --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"2";      --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';          --IR
                asyn_ins_arg_input <= "00000000000000" & instruction_word(17 downto 0); asyn_ins_arg_oe <= '1';       --IA 
            when mvil_3 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '0'; regs_oe <= '0'; regs_wr_dest <= x"0"; regs_oe_dest <= x"0";      --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '1'; asyn_alu_opcode <= x"2";      --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';          --IR
                asyn_ins_arg_input <= "00000000000000" & instruction_word(17 downto 0); asyn_ins_arg_oe <= '1';       --IA 
            when mvil_4 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '0'; regs_oe <= '0'; regs_wr_dest <= x"0"; regs_oe_dest <= x"0";      --regs
                asyn_alu_oe <= '1'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"2";      --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';          --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';     --IA
            when mvil_5 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '1'; regs_oe <= '0'; regs_wr_dest <= instruction_word(21 downto 18); regs_oe_dest <= x"0";      --regs
                asyn_alu_oe <= '1'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"2";      --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';          --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';     --IA
                
            --MVIH instruction
            when mvih_0 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= instruction_word(21 downto 18);      --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"2";      --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';          --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';     --IA
            when mvih_1 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '0'; regs_oe <= '1'; regs_wr_dest <= x"0"; regs_oe_dest <= instruction_word(21 downto 18);      --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '1'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"2";      --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';          --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';     --IA
            when mvih_2 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '0'; regs_oe <= '0'; regs_wr_dest <= x"0"; regs_oe_dest <= x"0";      --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"2";      --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';          --IR
                asyn_ins_arg_input <= instruction_word(17 downto 0) & "00000000000000"; asyn_ins_arg_oe <= '1';       --IA 
            when mvih_3 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '0'; regs_oe <= '0'; regs_wr_dest <= x"0"; regs_oe_dest <= x"0";      --regs
                asyn_alu_oe <= '0'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '1'; asyn_alu_opcode <= x"2";      --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';          --IR
                asyn_ins_arg_input <= instruction_word(17 downto 0) & "00000000000000"; asyn_ins_arg_oe <= '1';       --IA 
            when mvih_4 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '0'; regs_oe <= '0'; regs_wr_dest <= x"0"; regs_oe_dest <= x"0";      --regs
                asyn_alu_oe <= '1'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"2";      --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';          --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';     --IA
            when mvih_5 => 
                asyn_int_completed <= '0'; int_accept <= '0';
                regs_wr <= '1'; regs_oe <= '0'; regs_wr_dest <= instruction_word(21 downto 18); regs_oe_dest <= x"0";      --regs
                asyn_alu_oe <= '1'; asyn_alu_wrA <= '0'; asyn_alu_wrB <= '0'; asyn_alu_opcode <= x"2";      --ALU
                asyn_bus_ext_WR <= '0'; asyn_bus_ext_RD <= '0'; asyn_bus_WRadd <= '0'; asyn_bus_WRdat <= '0'; asyn_bus_RDdat <= '0'; --external BUS
                asyn_instruction_reg_wr <= '0';          --IR
                asyn_ins_arg_input <= x"00000000"; asyn_ins_arg_oe <= '0';     --IA
        end case;
    end process;
    
    --decoders for registers control signals
    process(regs_oe_dest, regs_oe) is begin
        if    (regs_oe_dest = x"0" and regs_oe = '1') then asyn_regs_oe_select <= x"0001";
        elsif (regs_oe_dest = x"1" and regs_oe = '1') then asyn_regs_oe_select <= x"0002";
        elsif (regs_oe_dest = x"2" and regs_oe = '1') then asyn_regs_oe_select <= x"0004";
        elsif (regs_oe_dest = x"3" and regs_oe = '1') then asyn_regs_oe_select <= x"0008";
        elsif (regs_oe_dest = x"4" and regs_oe = '1') then asyn_regs_oe_select <= x"0010";
        elsif (regs_oe_dest = x"5" and regs_oe = '1') then asyn_regs_oe_select <= x"0020";
        elsif (regs_oe_dest = x"6" and regs_oe = '1') then asyn_regs_oe_select <= x"0040";
        elsif (regs_oe_dest = x"7" and regs_oe = '1') then asyn_regs_oe_select <= x"0080";
        elsif (regs_oe_dest = x"8" and regs_oe = '1') then asyn_regs_oe_select <= x"0100";
        elsif (regs_oe_dest = x"9" and regs_oe = '1') then asyn_regs_oe_select <= x"0200";
        elsif (regs_oe_dest = x"A" and regs_oe = '1') then asyn_regs_oe_select <= x"0400";
        elsif (regs_oe_dest = x"B" and regs_oe = '1') then asyn_regs_oe_select <= x"0800";
        elsif (regs_oe_dest = x"C" and regs_oe = '1') then asyn_regs_oe_select <= x"1000";
        elsif (regs_oe_dest = x"D" and regs_oe = '1') then asyn_regs_oe_select <= x"2000";
        elsif (regs_oe_dest = x"E" and regs_oe = '1') then asyn_regs_oe_select <= x"4000";
        elsif (regs_oe_dest = x"F" and regs_oe = '1') then asyn_regs_oe_select <= x"8000";
        else asyn_regs_oe_select <= x"0000";
        end if;
    end process;
    
    process(regs_wr_dest, regs_wr) is begin
        if    (regs_wr_dest = x"0" and regs_wr = '1') then asyn_regs_wr_select <= x"0001";
        elsif (regs_wr_dest = x"1" and regs_wr = '1') then asyn_regs_wr_select <= x"0002";
        elsif (regs_wr_dest = x"2" and regs_wr = '1') then asyn_regs_wr_select <= x"0004";
        elsif (regs_wr_dest = x"3" and regs_wr = '1') then asyn_regs_wr_select <= x"0008";
        elsif (regs_wr_dest = x"4" and regs_wr = '1') then asyn_regs_wr_select <= x"0010";
        elsif (regs_wr_dest = x"5" and regs_wr = '1') then asyn_regs_wr_select <= x"0020";
        elsif (regs_wr_dest = x"6" and regs_wr = '1') then asyn_regs_wr_select <= x"0040";
        elsif (regs_wr_dest = x"7" and regs_wr = '1') then asyn_regs_wr_select <= x"0080";
        elsif (regs_wr_dest = x"8" and regs_wr = '1') then asyn_regs_wr_select <= x"0100";
        elsif (regs_wr_dest = x"9" and regs_wr = '1') then asyn_regs_wr_select <= x"0200";
        elsif (regs_wr_dest = x"A" and regs_wr = '1') then asyn_regs_wr_select <= x"0400";
        elsif (regs_wr_dest = x"B" and regs_wr = '1') then asyn_regs_wr_select <= x"0800";
        elsif (regs_wr_dest = x"C" and regs_wr = '1') then asyn_regs_wr_select <= x"1000";
        elsif (regs_wr_dest = x"D" and regs_wr = '1') then asyn_regs_wr_select <= x"2000";
        elsif (regs_wr_dest = x"E" and regs_wr = '1') then asyn_regs_wr_select <= x"4000";
        elsif (regs_wr_dest = x"F" and regs_wr = '1') then asyn_regs_wr_select <= x"8000";
        else asyn_regs_wr_select <= x"0000";
        end if;
    end process;
    
    --outputs register (this make outputs synchronous)
    process (clk, res, asyn_regs_wr_select, asyn_regs_oe_select, asyn_alu_oe, asyn_alu_wrA, asyn_alu_wrB, asyn_alu_opcode,
             asyn_bus_ext_WR, asyn_bus_ext_RD, asyn_bus_WRadd, asyn_bus_WRdat, asyn_bus_RDdat, asyn_instruction_reg_wr,
             asyn_ins_arg_input, asyn_ins_arg_oe) is begin
        
        if(res = '1') then
            regs_wr_select <= x"0000";
            regs_oe_select <= x"0000"; 
            alu_oe <= '0';
            alu_wrA <= '0';
            alu_wrB <= '0';
            alu_opcode  <= x"0";
            bus_ext_WR <= '0';
            bus_ext_RD <= '0';
            bus_WRadd <= '0';
            bus_WRdat <= '0';
            bus_RDdat <= '0';
            instruction_reg_wr  <= '0';
            ins_arg_input <= x"00000000";
            ins_arg_oe <= '0';
            int_completed <= '0';
        elsif(falling_edge(clk)) then
            regs_wr_select <= asyn_regs_wr_select;
            regs_oe_select <= asyn_regs_oe_select;
            alu_oe <= asyn_alu_oe;
            alu_wrA <= asyn_alu_wrA;
            alu_wrB <= asyn_alu_wrB;
            alu_opcode <= asyn_alu_opcode;
            bus_ext_WR <= asyn_bus_ext_WR;
            bus_ext_RD <= asyn_bus_ext_RD;
            bus_WRadd <= asyn_bus_WRadd;
            bus_WRdat <= asyn_bus_WRdat;
            bus_RDdat <= asyn_bus_RDdat;
            instruction_reg_wr <= asyn_instruction_reg_wr;
            ins_arg_input <= asyn_ins_arg_input;
            ins_arg_oe <= asyn_ins_arg_oe;
            int_completed <= asyn_int_completed;
        end if;
    end process;
    
    --this is RS latch for interrupt
    process(res, int, int_accept)is begin
        if res = '1' then
            interrupt_pending <= '0';
        elsif int_accept = '1' then
            interrupt_pending <= '0';
        elsif rising_edge(int) then 
            interrupt_pending <= '1';
        end if;
    end process;
end architecture instruction_decoder_arch;
