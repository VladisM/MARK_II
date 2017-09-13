library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Simple FPU based on Altera FP megafunctions.
--
-- Latency of all operations are from 5 to 7 cycles.
--
-- opcode is select operation:
--   00 - subtraction    - 7 cycles
--   01 - multiplication - 5 cycles
--   10 - division       - 6 cycles
--   11 - addition       - 7 cycles

entity fpu is
    port(
        clk: in std_logic;
        res: in std_logic;
        en: in std_logic;
        opcode: in std_logic_vector(1 downto 0);
        data_a: in unsigned(31 downto 0);
        data_b: in unsigned(31 downto 0);
        result: out unsigned(31 downto 0)
    );
end entity fpu;

architecture fpu_arch of fpu is

    component sub is port(
        aclr        : in std_logic;
        clk_en      : in std_logic;
        clock       : in std_logic;
        dataa       : in std_logic_vector (31 downto 0);
        datab       : in std_logic_vector (31 downto 0);
        result      : out std_logic_vector (31 downto 0) );
    end component sub;
    component mul is port(
        aclr        : in std_logic;
        clk_en      : in std_logic;
        clock       : in std_logic;
        dataa       : in std_logic_vector (31 downto 0);
        datab       : in std_logic_vector (31 downto 0);
        result      : out std_logic_vector (31 downto 0) );
    end component mul;
    component div is port(
        aclr        : in std_logic;
        clk_en      : in std_logic;
        clock       : in std_logic;
        dataa       : in std_logic_vector (31 downto 0);
        datab       : in std_logic_vector (31 downto 0);
        result      : out std_logic_vector (31 downto 0) );
    end component div;
    component add is port(
        aclr        : in std_logic;
        clk_en      : in std_logic;
        clock       : in std_logic;
        dataa       : in std_logic_vector (31 downto 0);
        datab       : in std_logic_vector (31 downto 0);
        result      : out std_logic_vector (31 downto 0) );
    end component add;

    signal result_sub, result_mul, result_div, result_mul_raw, result_div_raw, result_add: std_logic_vector(31 downto 0);
    signal result_vect, data_a_vect, data_b_vect: std_logic_vector(31 downto 0);
    signal res_sync : std_logic;

begin

    -- Prepare input data for FPU
    data_a_vect <= std_logic_vector(data_a);
    data_b_vect <= std_logic_vector(data_b);

    -- Initialize FP cores
    fpsub0: sub
        port map(res_sync, '1', clk, data_a_vect, data_b_vect, result_sub);

    fpmul0: mul
        port map(res_sync, '1', clk, data_a_vect, data_b_vect, result_mul);

    fpdiv0: div
        port map(res_sync, '1', clk, data_a_vect, data_b_vect, result_div);

    fpadd0: add
        port map(res_sync, '1', clk, data_a_vect, data_b_vect, result_add);

    -- Synchronize reset for FP cores
    process(clk) is
        variable res_v: std_logic;
    begin
        if rising_edge(clk) then
            if res = '1' then
                res_v := '1';
            else
                res_v := '0';
            end if;
        end if;
        res_sync <= res_v;
    end process;

    -- Result multiplexer
    result_vect <=
        result_sub when ((opcode = "00") and (en = '1')) else
        result_mul when ((opcode = "01") and (en = '1')) else
        result_div when ((opcode = "10") and (en = '1')) else
        result_add when ((opcode = "11") and (en = '1')) else
        (others => 'Z');
    
    -- Convert result
    result <= unsigned(result_vect);
        
end fpu_arch;