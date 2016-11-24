library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpu is
    port(
        clk: in std_logic;
        res: in std_logic;
        int: in std_logic;
        int_accept: out std_logic;
        int_completed: out std_logic;
        address: out std_logic_vector(17 downto 0);
        data_mosi: out std_logic_vector(31 downto 0);
        data_miso: in std_logic_vector(31 downto 0);
        WR: out std_logic;
        RD: out std_logic
    );
end entity cpu;

architecture cpu_arch of cpu is
    
    component alu is
        generic(
            WIDE: natural := 32
        );
        port(
            opcode: in std_logic_vector(3 downto 0);    
            eqv: out std_logic;                         
            lt: out std_logic;  
            ltu: out std_logic; 
            ge: out std_logic;                         
            geu: out std_logic;                         
            data: inout signed((WIDE-1) downto 0);
            oe: in std_logic;
            wrA: in std_logic;
            wrB: in std_logic;
            res: in std_logic;
            clk: in std_logic
        );
    end component alu;
    component regs is
        generic(
            WIDE: natural := 32
        );
        port(
            data: inout signed((WIDE - 1) downto 0);
            res: in std_logic;
            clk: in std_logic;
            wr: in std_logic_vector(15 downto 0);
            oe: in std_logic_vector(15 downto 0)
        );
    end component regs;
    component bus_interface is 
        port(
            data: inout signed(31 downto 0);
            res: in std_logic;
            clk: in std_logic;
            address: out std_logic_vector(17 downto 0);
            data_mosi: out std_logic_vector(31 downto 0);
            data_miso: in std_logic_vector(31 downto 0);
            WRadd: in std_logic;
            WRdat: in std_logic;
            RDdat: in std_logic
        );
    end component bus_interface;
    component instruction_decoder is 
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
    end component instruction_decoder;
    component instruction_register is
        generic(
            WIDE: natural := 32
        );
        port(
            data: inout signed((WIDE - 1) downto 0);
            instruction: out std_logic_vector(31 downto 0);
            res: in std_logic;
            wr: in std_logic
        );
    end component instruction_register;
    component instruction_argument is 
        port(
            databus: inout signed(31 downto 0);
            input_data: in std_logic_vector(31 downto 0);
            oe: in std_logic
        );
    end component instruction_argument;
        

    signal databus: signed(31 downto 0);
    
    --control signals between registers and instruction decoder
    signal regs_wr_select, regs_oe_select: std_logic_vector(15 downto 0);
    
    --control signal between alu and instructrion decoder
    signal alu_eqv, alu_lt, alu_ltu, alu_ge, alu_geu: std_logic;
    signal alu_oe, alu_wrA, alu_wrB: std_logic;
    signal alu_opcode: std_logic_vector(3 downto 0);
    
    --control signal between external bus controller and instruction decoder
    signal bus_ext_WR, bus_ext_RD, bus_WRadd, bus_WRdat, bus_RDdat: std_logic;
    
    --control signals between instruction register and instruction decoder
    signal instruction_word: std_logic_vector(31 downto 0); 
    signal instruction_reg_wr: std_logic;
    
    --control signals between  instruction argument and instruction decoder
    signal ins_arg_input: std_logic_vector(31 downto 0);
    signal ins_arg_oe: std_logic;
    
begin
    
    --registers
    regs0: regs
        generic map(WIDE => 32)
        port map(databus, res, clk, regs_wr_select, regs_oe_select);
    
    --ALU 
    alu0: alu
        generic map(WIDE => 32)
        port map(alu_opcode, alu_eqv, alu_lt, alu_ltu, alu_ge, alu_geu, databus, alu_oe, alu_wrA, alu_wrB, res, clk);
    
    --external bus
    extbus0: bus_interface
        port map(databus, res, clk, address, data_mosi, data_miso, bus_WRadd, bus_WRdat, bus_RDdat);
    RD <= bus_ext_RD;
    WR <= bus_ext_WR;
   
    --instruction register
    ir0: instruction_register
        generic map(WIDE => 32)
        port map(databus, instruction_word, res, instruction_reg_wr);
   
    --instruction argument
    ia0: instruction_argument
        port map(databus, ins_arg_input, ins_arg_oe);    
    
    --instruction decoder
    id0: instruction_decoder
        port map(
            --main control inputs
            res, clk, int,
            --regs
            regs_wr_select, regs_oe_select,
            --ALU
            alu_lt, alu_ltu, alu_ge, alu_geu, alu_eqv, alu_oe, alu_wrA, alu_wrB, alu_opcode,
            --external BUS
            bus_ext_WR, bus_ext_RD, bus_WRadd, bus_WRdat, bus_RDdat,
            --instruction register
            instruction_word, instruction_reg_wr,
            --instruction argument
            ins_arg_input, ins_arg_oe,
            --control outputs
            int_accept, int_completed
        );
            
end architecture cpu_arch;
