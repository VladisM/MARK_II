entity id is
    port(
        clk: in std_logic;
        res: in std_logic;
        instruction_word: in std_logic_vector(31 downto 0);
        instruction_we: out std_logic;
        --regfile
        regfile0_data_a_regsel: out std_logic_vector(3 downto 0);
        regfile0_data_b_regsel: out std_logic_vector(3 downto 0);
        regfile0_data_c_regsel: out std_logic_vector(3 downto 0);
        regfile0_we: out std_logic;
        regfile0_data_a_oe: out std_logic;
        regfile0_data_b_oe: out std_logic;
        zero_flags: in std_logic_vector(15 downto 0);
        --fpu
        fpu0_en: out std_logic;
        fpu0_opcode: out std_logic_vector(1 downto 0);
        --cmp
        cmp0_en: out std_logic;
        cmp0_opcode: out std_logic_vector(3 downto 0);
        --barrel
        barrel0_en: out std_logic;
        barrel0_dir: out std_logic;
        barrel0_mode: out std_logic_vector(1 downto 0);
        --alu
        alu0_en: out std_logic;
        alu0_opcode: out std_logic_vector(3 downto 0);
        --bus
        miso_oe:  out std_logic;
        --cpu
        we: out std_logic;
        oe: out std_logic;
        ack: in std_logic;
        int: in std_logic;
        int_address: in unsigned(23 downto 0);
        int_accept: out std_logic;
        int_completed: out std_logic
    );
end entity id;

architecture id_arch of id is

begin

end architecture id_arch;
