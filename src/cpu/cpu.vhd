library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpu is
    port(
        --system interface
        clk: in std_logic;
        res: in std_logic;
        --bus interface
        address: out unsigned(23 downto 0);
        data_mosi: out unsigned(31 downto 0);
        data_miso: in unsigned(31 downto 0);
        we: out std_logic;
        oe: out std_logic;
        ack: in std_logic;
        --interrupts
        int: in std_logic_vector(31 downto 0);
        int_accept: out std_logic;
        int_completed: out std_logic
    );
end entity cpu;

architecture cpu_arch of cpu is

    component reg is 
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
    end component reg;
    
    component reg_tristate is 
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
    end component reg_tristate;
    
    component reg_zero_tristate is 
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
    end component reg_zero_tristate;
    
    component reg_zero_tristate_counter is 
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
    end component reg_zero_tristate_counter;

    component reg_zero_tristate_counter_permaout is 
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
    end component reg_zero_tristate_counter_permaout;

    component tristate is 
        generic(
            WIDE: natural := 32
        );
        port(
            DataIn: in unsigned((WIDE-1) downto 0);
            DataOut: out unsigned((WIDE-1) downto 0);
            En: in std_logic
        );
    end component tristate;
    
    component comparator is
        generic(
            WIDE: natural := 32
        );
        port(
            OpCode: in std_logic_vector(2 downto 0);
            OpA: in unsigned((WIDE-1) downto 0);
            OpB: in unsigned((WIDE-1) downto 0);
            Result: out std_logic
        );
    end component comparator;
    
    component alu is
        generic(
            WIDE: natural := 32
        );
        port(
            OpCode: in std_logic_vector(3 downto 0);
            OpA: in unsigned((WIDE-1) downto 0);
            OpB: in unsigned((WIDE-1) downto 0);
            Result: out unsigned((WIDE-1) downto 0)
        );
    end component alu;
    
    component barrel_shifter is
        port(
            Data: in unsigned(31 downto 0);
            Result: out unsigned(31 downto 0);
            Distance: in std_logic_vector(3 downto 0);
            Direction: in std_logic;
            Mode: in std_logic
        );
    end component;

    component condition is 
        port(
            zeroFlag: in std_logic_vector(15 downto 0);
            regSel: in std_logic_vector(3 downto 0);
            flag: out std_logic
        );
    end component condition;

    component id is
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
    end component id;


    --signals for ID
    signal aluOpCode: std_logic_vector(3 downto 0);
    signal aluOE: std_logic;
    signal aluOpAWE, aluOpBWE: std_logic;
    
    signal compOpCode: std_logic_vector(2 downto 0);
    signal compOE: std_logic;
    signal compOpAWE, compOpBWE: std_logic;
    
    signal barDistance: std_logic_vector(3 downto 0);
    signal barDir, barMode, barOE, barOpAWE: std_logic;
    
    signal regOE: std_logic_vector(15 downto 0);
    signal regWE: std_logic_vector(15 downto 0);
    signal incSP, decSP, incPC, decPC: std_logic;
    
    signal instructionWord: unsigned(31 downto 0);
    signal instRegWE: std_logic;
    
    signal instructionArgument: unsigned(31 downto 0);
    signal instrArgOE: std_logic;
    
    signal addrRegWE: std_logic;
    signal mosiRegWE: std_logic;
    signal misoOE: std_logic;

    signal addressSel: std_logic;
    
    signal zeroFlag: std_logic;
    signal flagRegSel: std_logic_vector(3 downto 0);

    --signals for interconnect
    signal dataBUS: unsigned(31 downto 0);
    signal aluopA, aluopB, aluResult: unsigned(31 downto 0);
    signal compopA, compopB: unsigned(31 downto 0);
    signal compResult: std_logic;
    signal baropA, barResult: unsigned(31 downto 0);
    signal regZeroFlag: std_logic_vector(15 downto 0);
    signal ActualPC: unsigned(31 downto 0);
    signal addressReg: unsigned(23 downto 0);
    
begin
    
    --This is an ALU
    alu0: alu
        generic map(32)
        port map(aluOpCode, aluopA, aluopB, aluResult);
    
    aluoutput0: tristate
        generic map(32)
        port map(aluResult, dataBUS, aluOE);

    aluopAreg0: reg
        generic map(32)
        port map(clk, res, dataBUS, aluopA, aluOpAWE);
        
    aluopBreg0: reg
        generic map(32)
        port map(clk, res, dataBUS, aluopB, aluOpBWE);
        
    --There is comparator
    com0: comparator
        generic map(32)
        port map(compOpCode, compopA, compopB, compResult);
    
    compoutput0: tristate 
        generic map(32)
        port map(x"0000000" & "000" & compResult, dataBUS, compOE);
        
    compopAreg0: reg
        generic map(32)
        port map(clk, res, dataBUS, compopA, compOpAWE);
        
    compopBreg0: reg
        generic map(32)
        port map(clk, res, dataBUS, compopB, compOpBWE);
        
    --Barrel shifter
    barrel0: barrel_shifter
        port map(baropA, barResult, barDistance, barDir, barMode);

    barreloutput0: tristate
        generic map(32)
        port map(barResult, dataBUS, barOE);      
          
    baropAreg0: reg
        generic map(32)
        port map(clk, res, dataBUS, baropA, barOpAWE);
        
    --R0 zero register
    R0: tristate
        generic map(32)
        port map(x"00000000", dataBUS, regOE(0));
    
    regZeroFlag(0) <= '1';
    
    --R1
    R1: reg_zero_tristate
        generic map(32)
        port map(clk, res, dataBUS, dataBUS, regWE(1), regOE(1), regZeroFlag(1));
    
    --R2
    R2: reg_zero_tristate
        generic map(32)
        port map(clk, res, dataBUS, dataBUS, regWE(2), regOE(2), regZeroFlag(2));
        
    --R3
    R3: reg_zero_tristate
        generic map(32)
        port map(clk, res, dataBUS, dataBUS, regWE(3), regOE(3), regZeroFlag(3));
        
    --R4
    R4: reg_zero_tristate
        generic map(32)
        port map(clk, res, dataBUS, dataBUS, regWE(4), regOE(4), regZeroFlag(4));
        
    --R5
    R5: reg_zero_tristate
        generic map(32)
        port map(clk, res, dataBUS, dataBUS, regWE(5), regOE(5), regZeroFlag(5));
        
    --R6
    R6: reg_zero_tristate
        generic map(32)
        port map(clk, res, dataBUS, dataBUS, regWE(6), regOE(6), regZeroFlag(6));
        
    --R7
    R7: reg_zero_tristate
        generic map(32)
        port map(clk, res, dataBUS, dataBUS, regWE(7), regOE(7), regZeroFlag(7));
        
    --R8
    R8: reg_zero_tristate
        generic map(32)
        port map(clk, res, dataBUS, dataBUS, regWE(8), regOE(8), regZeroFlag(8));
        
    --R9
    R9: reg_zero_tristate
        generic map(32)
        port map(clk, res, dataBUS, dataBUS, regWE(9), regOE(9), regZeroFlag(9));
        
    --R10
    R10: reg_zero_tristate
        generic map(32)
        port map(clk, res, dataBUS, dataBUS, regWE(10), regOE(10), regZeroFlag(10));
        
    --R11
    R11: reg_zero_tristate
        generic map(32)
        port map(clk, res, dataBUS, dataBUS, regWE(11), regOE(11), regZeroFlag(11));
    
    --R12
    R12: reg_zero_tristate
        generic map(32)
        port map(clk, res, dataBUS, dataBUS, regWE(12), regOE(12), regZeroFlag(12));
        
    --R13
    R13: reg_zero_tristate
        generic map(32)
        port map(clk, res, dataBUS, dataBUS, regWE(13), regOE(13), regZeroFlag(13));
        
    --R14 stack pointer
    R14: reg_zero_tristate_counter
        generic map(32)
        port map(clk, res, dataBUS, dataBUS, regWE(14), regOE(14), incSP, decSP, regZeroFlag(14));
    
    --R15 program counter
    R15: reg_zero_tristate_counter_permaout
        generic map(32)
        port map(clk, res, dataBUS, dataBUS, regWE(15), regOE(15), incPC, decPC, regZeroFlag(15), actualPC);
    
    --Instruction register
    IR0: reg
        generic map(32)
        port map(clk, res, dataBUS, instructionWord, instRegWE);
    
    --Instruction argument
    IA0: tristate
        generic map(32)
        port map(instructionArgument, dataBUS, instrArgOE);
        
    --external bus interface
    Addrreg0: reg
        generic map(24)
        port map(clk, res, dataBUS(23 downto 0), addressReg, addrRegWE);
    
    dataMOSIreg0: reg
        generic map(32)
        port map(clk, res, dataBUS, data_mosi, mosiRegWE); 
        
    misoInput0: tristate
        generic map(32)
        port map(data_miso, dataBUS, misoOE);

    address <= actualPC(23 downto 0) when (addressSel = '1') else addressReg;
    
    --condition detector
    
    cond0: condition
        port map(regZeroFlag, flagRegSel, zeroFlag);
    
    --Instruction decoder
    id0: id
    port map(
        clk, res,
        int, int_accept, int_completed,
        aluOpCode, aluOE, aluOpAWE, aluOpBWE,
        compOpCode, compOE, compOpAWE, compOpBWE,
        barDistance, barDir, barMode, barOE, barOpAWE,
        regOE, regWE, incSP, decSP, incPC, decPC,
        instructionWord, instRegWE,
        instructionArgument, instrArgOE,
        addrRegWE, mosiRegWE, misoOE, we, oe, ack, addressSel,
        zeroFlag, flagRegSel
    );
        
end architecture cpu_arch;
