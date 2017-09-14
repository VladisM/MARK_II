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
        int: in std_logic;
        int_address: in unsigned(23 downto 0);
        int_accept: out std_logic;
        int_completed: out std_logic
    );
end entity cpu;

architecture cpu_arch of cpu is

    component regfile is
        port(
            clk: in std_logic;
            res: in std_logic;
            dataa: out unsigned(31 downto 0);
            datab: out unsigned(31 downto 0);
            datac: in unsigned(31 downto 0);
            data_a_regsel: in std_logic_vector(3 downto 0);
            data_b_regsel: in std_logic_vector(3 downto 0);
            data_c_regsel: in std_logic_vector(3 downto 0);
            we: in std_logic;
            data_a_oe: in std_logic;
            data_b_oe: in std_logic;
            zero: out std_logic_vector(15 downto 0);
            inc_r14: in std_logic;
            inc_r15: in std_logic;
            dec_r14: in std_logic;
            dec_r15: in std_logic;
            q_r15: out unsigned(23 downto 0)
        );
    end component regfile;
    component fpu is
        port(
            clk: in std_logic;
            res: in std_logic;
            en: in std_logic;
            opcode: in std_logic_vector(1 downto 0);
            data_a: in unsigned(31 downto 0);
            data_b: in unsigned(31 downto 0);
            result: out unsigned(31 downto 0)
        );
    end component fpu;
    component comparator is
        port(
            res: in std_logic;
            clk: in std_logic;
            en: in std_logic;
            opcode: in std_logic_vector(3 downto 0);
            data_a: in unsigned(31 downto 0);
            data_b: in unsigned(31 downto 0);
            output: out unsigned(31 downto 0)
        );
    end component comparator;
    component barrel is
        port(
            clk: in std_logic;
            res: in std_logic;
            en: in std_logic;
            dir: in std_logic;
            mode: in std_logic_vector(1 downto 0);
            dataa: in unsigned(31 downto 0);
            datab: in unsigned(31 downto 0);
            result: out unsigned(31 downto 0)
        );
    end component barrel;
    component alu is
        port(
            clk: in std_logic;
            res: in std_logic;
            en: in std_logic;
            opcode: in std_logic_vector(3 downto 0);
            dataa: in unsigned(31 downto 0);
            datab: in unsigned(31 downto 0);
            result: out unsigned(31 downto 0)
        );
    end component alu;
    component id is
        port(
            clk: in std_logic;
            res: in std_logic;
            instruction_word: in std_logic_vector(31 downto 0);
            instruction_we: out std_logic;
            regfile0_data_a_regsel: out std_logic_vector(3 downto 0);
            regfile0_data_b_regsel: out std_logic_vector(3 downto 0);
            regfile0_data_c_regsel: out std_logic_vector(3 downto 0);
            regfile0_we: out std_logic;
            regfile0_data_a_oe: out std_logic;
            regfile0_data_b_oe: out std_logic;
            zero_flags: in std_logic_vector(15 downto 0);
            fpu0_en: out std_logic;
            fpu0_opcode: out std_logic_vector(1 downto 0);
            cmp0_en: out std_logic;
            cmp0_opcode: out std_logic_vector(3 downto 0);
            barrel0_en: out std_logic;
            barrel0_dir: out std_logic;
            barrel0_mode: out std_logic_vector(1 downto 0);
            alu0_en: out std_logic;
            alu0_opcode: out std_logic_vector(3 downto 0);
            miso_oe:  out std_logic;
            arg_oe: out std_logic;
            argument: out unsigned(31 downto 0);
            we: out std_logic;
            oe: out std_logic;
            ack: in std_logic;
            int: in std_logic;
            int_address: in unsigned(23 downto 0);
            int_accept: out std_logic;
            int_completed: out std_logic;
            inc_r14: out std_logic;
            inc_r15: out std_logic;
            dec_r14: out std_logic;
            dec_r15: out std_logic;
            address_alu_oe: out std_logic;
            address_alu_opcode: out std_logic
        );
    end component id;

    signal data_a, data_b, data_c: unsigned(31 downto 0);

    signal zero_flags: std_logic_vector(15 downto 0);
    signal regfile0_data_a_regsel: std_logic_vector(3 downto 0);
    signal regfile0_data_b_regsel: std_logic_vector(3 downto 0);
    signal regfile0_data_c_regsel: std_logic_vector(3 downto 0);
    signal regfile0_we: std_logic;
    signal regfile0_data_a_oe: std_logic;
    signal regfile0_data_b_oe: std_logic;
    signal fpu0_en: std_logic;
    signal fpu0_opcode: std_logic_vector(1 downto 0);
    signal cmp0_en: std_logic;
    signal cmp0_opcode: std_logic_vector(3 downto 0);
    signal barrel0_en: std_logic;
    signal barrel0_dir: std_logic;
    signal barrel0_mode: std_logic_vector(1 downto 0);
    signal alu0_en: std_logic;
    signal alu0_opcode: std_logic_vector(3 downto 0);
    signal miso_oe:  std_logic;
    signal instruction_word: std_logic_vector(31 downto 0);
    signal instruction_we: std_logic;
    signal arg_oe: std_logic;
    signal argument: unsigned(31 downto 0);
    signal inc_r14: std_logic;
    signal inc_r15: std_logic;
    signal dec_r14: std_logic;
    signal dec_r15: std_logic;
    signal address_alu_oe: std_logic;
    signal reg15_q: unsigned(23 downto 0);
    signal address_alu_result: unsigned(23 downto 0);
    signal address_alu_opcode: std_logic;

begin

    regfile0: regfile
        port map(clk, res, data_a, data_b, data_c, regfile0_data_a_regsel,
                 regfile0_data_b_regsel, regfile0_data_c_regsel, regfile0_we,
                 regfile0_data_a_oe, regfile0_data_b_oe, zero_flags, reg15_q);

    fpu0: fpu
        port map(clk, res, fpu0_en, fpu0_opcode, data_a, data_b, data_c);

    comp0: comparator
        port map(res, clk, cmp0_en, cmp0_opcode, data_a, data_b, data_c);

    barrel0: barrel
        port map(clk, res, barrel0_en, barrel0_dir, barrel0_mode, data_a, data_b, data_c);

    alu0: alu
        port map(clk, res, alu0_en, alu0_opcode, data_a, data_b, data_c);


    address_alu_result <= (reg15_q + 1) when address_alu_opcode = '1' else (reg15_q - 1);

    --bus interface
    address <= data_a(23 downto 0) when address_alu_oe = '0' else address_alu_result;
    data_mosi <= data_b;
    data_c <= data_miso when miso_oe = '1' else (others => 'Z');

    instr_reg0: process(clk) is
        variable instruction_var: std_logic_vector(31 downto 0);
    begin
        if rising_edge(clk) then
            if res = '1' then
                instruction_var := (others => '0');
            elsif instruction_we = '1' then
                instruction_var := std_logic_vector(data_miso);
            end if;
        end if;
        instruction_word <= instruction_var;
    end process;

    data_a <= argument when (arg_oe = '1') else (others => 'Z');

    id0: id
        port map(clk, res, instruction_word, instruction_we, regfile0_data_a_regsel,
                 regfile0_data_b_regsel, regfile0_data_c_regsel, regfile0_we,
                 regfile0_data_a_oe, regfile0_data_b_oe, fpu0_en, fpu0_opcode,
                 cmp0_en, cmp0_opcode, barrel0_en, barrel0_dir, barrel0_mode,
                 alu0_en, alu0_opcode, miso_oe, arg_oe, argument, we, oe, ack,
                 int, int_address, int_accept, int_completed, inc_r14, inc_r15,
                 dec_r14, dec_r15, address_alu_oe, address_alu_opcode);

end architecture cpu_arch;
