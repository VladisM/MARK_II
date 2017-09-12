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
            zero: out std_logic_vector(15 downto 0)
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

    signal data_a, data_b, data_c: unsigned(31 downto 0);
    signal zero_flags: std_logic_vector(15 downto 0);

begin

    regfile0: regfile
        port map(clk, res, data_a, data_b, data_c, regfile0_data_a_regsel,
                 regfile0_data_b_regsel, regfile0_data_c_regsel, regfile0_we,
                 regfile0_data_a_oe, regfile0_data_b_oe, zero_flags);

    fpu0: fpu
        port map(clk, res, fpu0_en, fpu0_opcode, data_a, data_b, data_c);

    comp0: comparator
        port map(res, clk, cmp0_en, cmp0_opcode, data_a, data_b, data_c);

    barrel0: barrel
        port map(clk, res, barrel0_en, barrel0_dir, barrel0_mode, data_a, data_b, data_c);

    alu0: alu
        port map(clk, res, alu0_en, alu0_opcode, data_a, data_b, data_c);












            -- this all control signals (should be connected into ID)
            --regfile
            data_a_regsel: in std_logic_vector(3 downto 0);
            data_b_regsel: in std_logic_vector(3 downto 0);
            data_c_regsel: in std_logic_vector(3 downto 0);
            we: in std_logic;
            data_a_oe: in std_logic;
            data_b_oe: in std_logic;
            --fpu
            en: in std_logic;
            opcode: in std_logic_vector(1 downto 0);
            --cmp
            en: in std_logic;
            opcode: in std_logic_vector(3 downto 0);
            --barrel
            en: in std_logic;
            dir: in std_logic;
            mode: in std_logic_vector(1 downto 0);
            --alu
            en: in std_logic;
            opcode: in std_logic_vector(3 downto 0);

end architecture cpu_arch
