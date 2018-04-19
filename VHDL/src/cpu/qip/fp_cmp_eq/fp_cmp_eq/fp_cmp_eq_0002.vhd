-- ------------------------------------------------------------------------- 
-- High Level Design Compiler for Intel(R) FPGAs Version 17.0 (Release Build #595)
-- Quartus Prime development tool and MATLAB/Simulink Interface
-- 
-- Legal Notice: Copyright 2017 Intel Corporation.  All rights reserved.
-- Your use of  Intel Corporation's design tools,  logic functions and other
-- software and  tools, and its AMPP partner logic functions, and any output
-- files any  of the foregoing (including  device programming  or simulation
-- files), and  any associated  documentation  or information  are expressly
-- subject  to the terms and  conditions of the  Intel FPGA Software License
-- Agreement, Intel MegaCore Function License Agreement, or other applicable
-- license agreement,  including,  without limitation,  that your use is for
-- the  sole  purpose of  programming  logic devices  manufactured by  Intel
-- and  sold by Intel  or its authorized  distributors. Please refer  to the
-- applicable agreement for further details.
-- ---------------------------------------------------------------------------

-- VHDL created from fp_cmp_eq_0002
-- VHDL created on Thu Feb 15 17:01:50 2018


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
use IEEE.MATH_REAL.all;
use std.TextIO.all;
use work.dspba_library_package.all;

LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;
LIBRARY lpm;
USE lpm.lpm_components.all;

entity fp_cmp_eq_0002 is
    port (
        a : in std_logic_vector(31 downto 0);  -- float32_m23
        b : in std_logic_vector(31 downto 0);  -- float32_m23
        q : out std_logic_vector(0 downto 0);  -- ufix1
        clk : in std_logic;
        areset : in std_logic
    );
end fp_cmp_eq_0002;

architecture normal of fp_cmp_eq_0002 is

    attribute altera_attribute : string;
    attribute altera_attribute of normal : architecture is "-name AUTO_SHIFT_REGISTER_RECOGNITION OFF; -name PHYSICAL_SYNTHESIS_REGISTER_DUPLICATION ON; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 10037; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 15400; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 12020; -name MESSAGE_DISABLE 12030; -name MESSAGE_DISABLE 12010; -name MESSAGE_DISABLE 12110; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 13410; -name MESSAGE_DISABLE 113007";
    
    signal GND_q : STD_LOGIC_VECTOR (0 downto 0);
    signal VCC_q : STD_LOGIC_VECTOR (0 downto 0);
    signal cstAllOWE_uid6_fpCompareTest_q : STD_LOGIC_VECTOR (7 downto 0);
    signal cstZeroWF_uid7_fpCompareTest_q : STD_LOGIC_VECTOR (22 downto 0);
    signal cstAllZWE_uid8_fpCompareTest_q : STD_LOGIC_VECTOR (7 downto 0);
    signal excZ_x_uid11_fpCompareTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal expXIsMax_uid12_fpCompareTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal fracXIsZero_uid13_fpCompareTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal fracXIsNotZero_uid14_fpCompareTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excN_x_uid16_fpCompareTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excZ_y_uid25_fpCompareTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal expXIsMax_uid26_fpCompareTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal fracXIsZero_uid27_fpCompareTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal fracXIsNotZero_uid28_fpCompareTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excN_y_uid30_fpCompareTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal oneIsNaN_uid34_fpCompareTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal bothZero_uid54_fpCompareTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal rCmp_uid57_fpCompareTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal r_uid58_fpCompareTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal rPostExc_uid59_fpCompareTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal rPostExc_uid59_fpCompareTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal exp_x_uid9_fpCompareTest_merged_bit_select_b : STD_LOGIC_VECTOR (7 downto 0);
    signal exp_x_uid9_fpCompareTest_merged_bit_select_c : STD_LOGIC_VECTOR (22 downto 0);
    signal exp_y_uid23_fpCompareTest_merged_bit_select_b : STD_LOGIC_VECTOR (7 downto 0);
    signal exp_y_uid23_fpCompareTest_merged_bit_select_c : STD_LOGIC_VECTOR (22 downto 0);

begin


    -- GND(CONSTANT,0)
    GND_q <= "0";

    -- cstAllZWE_uid8_fpCompareTest(CONSTANT,7)
    cstAllZWE_uid8_fpCompareTest_q <= "00000000";

    -- exp_y_uid23_fpCompareTest_merged_bit_select(BITSELECT,61)@0
    exp_y_uid23_fpCompareTest_merged_bit_select_b <= STD_LOGIC_VECTOR(b(30 downto 23));
    exp_y_uid23_fpCompareTest_merged_bit_select_c <= STD_LOGIC_VECTOR(b(22 downto 0));

    -- excZ_y_uid25_fpCompareTest(LOGICAL,24)@0
    excZ_y_uid25_fpCompareTest_q <= "1" WHEN exp_y_uid23_fpCompareTest_merged_bit_select_b = cstAllZWE_uid8_fpCompareTest_q ELSE "0";

    -- exp_x_uid9_fpCompareTest_merged_bit_select(BITSELECT,60)@0
    exp_x_uid9_fpCompareTest_merged_bit_select_b <= STD_LOGIC_VECTOR(a(30 downto 23));
    exp_x_uid9_fpCompareTest_merged_bit_select_c <= STD_LOGIC_VECTOR(a(22 downto 0));

    -- excZ_x_uid11_fpCompareTest(LOGICAL,10)@0
    excZ_x_uid11_fpCompareTest_q <= "1" WHEN exp_x_uid9_fpCompareTest_merged_bit_select_b = cstAllZWE_uid8_fpCompareTest_q ELSE "0";

    -- bothZero_uid54_fpCompareTest(LOGICAL,53)@0
    bothZero_uid54_fpCompareTest_q <= excZ_x_uid11_fpCompareTest_q and excZ_y_uid25_fpCompareTest_q;

    -- rCmp_uid57_fpCompareTest(LOGICAL,56)@0
    rCmp_uid57_fpCompareTest_q <= "1" WHEN a = b ELSE "0";

    -- r_uid58_fpCompareTest(LOGICAL,57)@0
    r_uid58_fpCompareTest_q <= rCmp_uid57_fpCompareTest_q or bothZero_uid54_fpCompareTest_q;

    -- cstZeroWF_uid7_fpCompareTest(CONSTANT,6)
    cstZeroWF_uid7_fpCompareTest_q <= "00000000000000000000000";

    -- fracXIsZero_uid27_fpCompareTest(LOGICAL,26)@0
    fracXIsZero_uid27_fpCompareTest_q <= "1" WHEN cstZeroWF_uid7_fpCompareTest_q = exp_y_uid23_fpCompareTest_merged_bit_select_c ELSE "0";

    -- fracXIsNotZero_uid28_fpCompareTest(LOGICAL,27)@0
    fracXIsNotZero_uid28_fpCompareTest_q <= not (fracXIsZero_uid27_fpCompareTest_q);

    -- cstAllOWE_uid6_fpCompareTest(CONSTANT,5)
    cstAllOWE_uid6_fpCompareTest_q <= "11111111";

    -- expXIsMax_uid26_fpCompareTest(LOGICAL,25)@0
    expXIsMax_uid26_fpCompareTest_q <= "1" WHEN exp_y_uid23_fpCompareTest_merged_bit_select_b = cstAllOWE_uid6_fpCompareTest_q ELSE "0";

    -- excN_y_uid30_fpCompareTest(LOGICAL,29)@0
    excN_y_uid30_fpCompareTest_q <= expXIsMax_uid26_fpCompareTest_q and fracXIsNotZero_uid28_fpCompareTest_q;

    -- fracXIsZero_uid13_fpCompareTest(LOGICAL,12)@0
    fracXIsZero_uid13_fpCompareTest_q <= "1" WHEN cstZeroWF_uid7_fpCompareTest_q = exp_x_uid9_fpCompareTest_merged_bit_select_c ELSE "0";

    -- fracXIsNotZero_uid14_fpCompareTest(LOGICAL,13)@0
    fracXIsNotZero_uid14_fpCompareTest_q <= not (fracXIsZero_uid13_fpCompareTest_q);

    -- expXIsMax_uid12_fpCompareTest(LOGICAL,11)@0
    expXIsMax_uid12_fpCompareTest_q <= "1" WHEN exp_x_uid9_fpCompareTest_merged_bit_select_b = cstAllOWE_uid6_fpCompareTest_q ELSE "0";

    -- excN_x_uid16_fpCompareTest(LOGICAL,15)@0
    excN_x_uid16_fpCompareTest_q <= expXIsMax_uid12_fpCompareTest_q and fracXIsNotZero_uid14_fpCompareTest_q;

    -- oneIsNaN_uid34_fpCompareTest(LOGICAL,33)@0
    oneIsNaN_uid34_fpCompareTest_q <= excN_x_uid16_fpCompareTest_q or excN_y_uid30_fpCompareTest_q;

    -- VCC(CONSTANT,1)
    VCC_q <= "1";

    -- rPostExc_uid59_fpCompareTest(MUX,58)@0
    rPostExc_uid59_fpCompareTest_s <= oneIsNaN_uid34_fpCompareTest_q;
    rPostExc_uid59_fpCompareTest_combproc: PROCESS (rPostExc_uid59_fpCompareTest_s, r_uid58_fpCompareTest_q, GND_q)
    BEGIN
        CASE (rPostExc_uid59_fpCompareTest_s) IS
            WHEN "0" => rPostExc_uid59_fpCompareTest_q <= r_uid58_fpCompareTest_q;
            WHEN "1" => rPostExc_uid59_fpCompareTest_q <= GND_q;
            WHEN OTHERS => rPostExc_uid59_fpCompareTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- xOut(GPOUT,4)@0
    q <= rPostExc_uid59_fpCompareTest_q;

END normal;
