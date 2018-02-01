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

-- VHDL created from fp_div_0002
-- VHDL created on Thu Feb 15 13:09:40 2018


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

entity fp_div_0002 is
    port (
        a : in std_logic_vector(31 downto 0);  -- float32_m23
        b : in std_logic_vector(31 downto 0);  -- float32_m23
        q : out std_logic_vector(31 downto 0);  -- float32_m23
        clk : in std_logic;
        areset : in std_logic
    );
end fp_div_0002;

architecture normal of fp_div_0002 is

    attribute altera_attribute : string;
    attribute altera_attribute of normal : architecture is "-name AUTO_SHIFT_REGISTER_RECOGNITION OFF; -name PHYSICAL_SYNTHESIS_REGISTER_DUPLICATION ON; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 10037; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 15400; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 12020; -name MESSAGE_DISABLE 12030; -name MESSAGE_DISABLE 12010; -name MESSAGE_DISABLE 12110; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 13410; -name MESSAGE_DISABLE 113007";
    
    signal GND_q : STD_LOGIC_VECTOR (0 downto 0);
    signal VCC_q : STD_LOGIC_VECTOR (0 downto 0);
    signal cstBiasM1_uid6_fpDivTest_q : STD_LOGIC_VECTOR (7 downto 0);
    signal expX_uid9_fpDivTest_b : STD_LOGIC_VECTOR (7 downto 0);
    signal fracX_uid10_fpDivTest_b : STD_LOGIC_VECTOR (22 downto 0);
    signal signX_uid11_fpDivTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal expY_uid12_fpDivTest_b : STD_LOGIC_VECTOR (7 downto 0);
    signal fracY_uid13_fpDivTest_b : STD_LOGIC_VECTOR (22 downto 0);
    signal signY_uid14_fpDivTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal paddingY_uid15_fpDivTest_q : STD_LOGIC_VECTOR (22 downto 0);
    signal updatedY_uid16_fpDivTest_q : STD_LOGIC_VECTOR (23 downto 0);
    signal fracYZero_uid15_fpDivTest_a : STD_LOGIC_VECTOR (23 downto 0);
    signal fracYZero_uid15_fpDivTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal fracYZero_uid15_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal cstAllOWE_uid18_fpDivTest_q : STD_LOGIC_VECTOR (7 downto 0);
    signal cstAllZWE_uid20_fpDivTest_q : STD_LOGIC_VECTOR (7 downto 0);
    signal excZ_x_uid23_fpDivTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal excZ_x_uid23_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal expXIsMax_uid24_fpDivTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal expXIsMax_uid24_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal fracXIsZero_uid25_fpDivTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal fracXIsZero_uid25_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal fracXIsNotZero_uid26_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excI_x_uid27_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excN_x_uid28_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal invExpXIsMax_uid29_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal InvExpXIsZero_uid30_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excR_x_uid31_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excZ_y_uid37_fpDivTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal excZ_y_uid37_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal expXIsMax_uid38_fpDivTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal expXIsMax_uid38_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal fracXIsZero_uid39_fpDivTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal fracXIsZero_uid39_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal fracXIsNotZero_uid40_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excI_y_uid41_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excN_y_uid42_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal invExpXIsMax_uid43_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal InvExpXIsZero_uid44_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excR_y_uid45_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal signR_uid46_fpDivTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal signR_uid46_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal expXmY_uid47_fpDivTest_a : STD_LOGIC_VECTOR (8 downto 0);
    signal expXmY_uid47_fpDivTest_b : STD_LOGIC_VECTOR (8 downto 0);
    signal expXmY_uid47_fpDivTest_o : STD_LOGIC_VECTOR (8 downto 0);
    signal expXmY_uid47_fpDivTest_q : STD_LOGIC_VECTOR (8 downto 0);
    signal expR_uid48_fpDivTest_a : STD_LOGIC_VECTOR (10 downto 0);
    signal expR_uid48_fpDivTest_b : STD_LOGIC_VECTOR (10 downto 0);
    signal expR_uid48_fpDivTest_o : STD_LOGIC_VECTOR (10 downto 0);
    signal expR_uid48_fpDivTest_q : STD_LOGIC_VECTOR (9 downto 0);
    signal yAddr_uid51_fpDivTest_b : STD_LOGIC_VECTOR (8 downto 0);
    signal yPE_uid52_fpDivTest_b : STD_LOGIC_VECTOR (13 downto 0);
    signal fracYPostZ_uid56_fpDivTest_qi : STD_LOGIC_VECTOR (0 downto 0);
    signal fracYPostZ_uid56_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal lOAdded_uid58_fpDivTest_q : STD_LOGIC_VECTOR (23 downto 0);
    signal oFracXSE_bottomExtension_uid61_fpDivTest_q : STD_LOGIC_VECTOR (1 downto 0);
    signal oFracXSE_mergedSignalTM_uid63_fpDivTest_q : STD_LOGIC_VECTOR (25 downto 0);
    signal divValPreNormS_uid65_fpDivTest_b : STD_LOGIC_VECTOR (25 downto 0);
    signal divValPreNormTrunc_uid66_fpDivTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal divValPreNormTrunc_uid66_fpDivTest_q : STD_LOGIC_VECTOR (25 downto 0);
    signal norm_uid67_fpDivTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal divValPreNormHigh_uid68_fpDivTest_in : STD_LOGIC_VECTOR (24 downto 0);
    signal divValPreNormHigh_uid68_fpDivTest_b : STD_LOGIC_VECTOR (23 downto 0);
    signal divValPreNormLow_uid69_fpDivTest_in : STD_LOGIC_VECTOR (23 downto 0);
    signal divValPreNormLow_uid69_fpDivTest_b : STD_LOGIC_VECTOR (23 downto 0);
    signal normFracRnd_uid70_fpDivTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal normFracRnd_uid70_fpDivTest_q : STD_LOGIC_VECTOR (23 downto 0);
    signal expFracRnd_uid71_fpDivTest_q : STD_LOGIC_VECTOR (33 downto 0);
    signal rndOp_uid75_fpDivTest_q : STD_LOGIC_VECTOR (24 downto 0);
    signal expFracPostRnd_uid76_fpDivTest_a : STD_LOGIC_VECTOR (35 downto 0);
    signal expFracPostRnd_uid76_fpDivTest_b : STD_LOGIC_VECTOR (35 downto 0);
    signal expFracPostRnd_uid76_fpDivTest_o : STD_LOGIC_VECTOR (35 downto 0);
    signal expFracPostRnd_uid76_fpDivTest_q : STD_LOGIC_VECTOR (34 downto 0);
    signal fracRPreExc_uid78_fpDivTest_in : STD_LOGIC_VECTOR (23 downto 0);
    signal fracRPreExc_uid78_fpDivTest_b : STD_LOGIC_VECTOR (22 downto 0);
    signal excRPreExc_uid79_fpDivTest_in : STD_LOGIC_VECTOR (31 downto 0);
    signal excRPreExc_uid79_fpDivTest_b : STD_LOGIC_VECTOR (7 downto 0);
    signal expRExt_uid80_fpDivTest_b : STD_LOGIC_VECTOR (10 downto 0);
    signal expUdf_uid81_fpDivTest_a : STD_LOGIC_VECTOR (12 downto 0);
    signal expUdf_uid81_fpDivTest_b : STD_LOGIC_VECTOR (12 downto 0);
    signal expUdf_uid81_fpDivTest_o : STD_LOGIC_VECTOR (12 downto 0);
    signal expUdf_uid81_fpDivTest_n : STD_LOGIC_VECTOR (0 downto 0);
    signal expOvf_uid84_fpDivTest_a : STD_LOGIC_VECTOR (12 downto 0);
    signal expOvf_uid84_fpDivTest_b : STD_LOGIC_VECTOR (12 downto 0);
    signal expOvf_uid84_fpDivTest_o : STD_LOGIC_VECTOR (12 downto 0);
    signal expOvf_uid84_fpDivTest_n : STD_LOGIC_VECTOR (0 downto 0);
    signal zeroOverReg_uid85_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal regOverRegWithUf_uid86_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal xRegOrZero_uid87_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal regOrZeroOverInf_uid88_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excRZero_uid89_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excXRYZ_uid90_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excXRYROvf_uid91_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excXIYZ_uid92_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excXIYR_uid93_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excRInf_uid94_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excXZYZ_uid95_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excXIYI_uid96_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excRNaN_uid97_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal concExc_uid98_fpDivTest_q : STD_LOGIC_VECTOR (2 downto 0);
    signal excREnc_uid99_fpDivTest_q : STD_LOGIC_VECTOR (1 downto 0);
    signal oneFracRPostExc2_uid100_fpDivTest_q : STD_LOGIC_VECTOR (22 downto 0);
    signal fracRPostExc_uid103_fpDivTest_s : STD_LOGIC_VECTOR (1 downto 0);
    signal fracRPostExc_uid103_fpDivTest_q : STD_LOGIC_VECTOR (22 downto 0);
    signal expRPostExc_uid107_fpDivTest_s : STD_LOGIC_VECTOR (1 downto 0);
    signal expRPostExc_uid107_fpDivTest_q : STD_LOGIC_VECTOR (7 downto 0);
    signal invExcRNaN_uid108_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal sRPostExc_uid109_fpDivTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal divR_uid110_fpDivTest_q : STD_LOGIC_VECTOR (31 downto 0);
    signal os_uid114_invTables_q : STD_LOGIC_VECTOR (30 downto 0);
    signal os_uid118_invTables_q : STD_LOGIC_VECTOR (20 downto 0);
    signal yT1_uid126_invPolyEval_b : STD_LOGIC_VECTOR (11 downto 0);
    signal rndBit_uid128_invPolyEval_q : STD_LOGIC_VECTOR (1 downto 0);
    signal cIncludingRoundingBit_uid129_invPolyEval_q : STD_LOGIC_VECTOR (22 downto 0);
    signal ts1_uid131_invPolyEval_a : STD_LOGIC_VECTOR (23 downto 0);
    signal ts1_uid131_invPolyEval_b : STD_LOGIC_VECTOR (23 downto 0);
    signal ts1_uid131_invPolyEval_o : STD_LOGIC_VECTOR (23 downto 0);
    signal ts1_uid131_invPolyEval_q : STD_LOGIC_VECTOR (23 downto 0);
    signal s1_uid132_invPolyEval_b : STD_LOGIC_VECTOR (22 downto 0);
    signal rndBit_uid135_invPolyEval_q : STD_LOGIC_VECTOR (2 downto 0);
    signal cIncludingRoundingBit_uid136_invPolyEval_q : STD_LOGIC_VECTOR (33 downto 0);
    signal ts2_uid138_invPolyEval_a : STD_LOGIC_VECTOR (34 downto 0);
    signal ts2_uid138_invPolyEval_b : STD_LOGIC_VECTOR (34 downto 0);
    signal ts2_uid138_invPolyEval_o : STD_LOGIC_VECTOR (34 downto 0);
    signal ts2_uid138_invPolyEval_q : STD_LOGIC_VECTOR (34 downto 0);
    signal s2_uid139_invPolyEval_b : STD_LOGIC_VECTOR (33 downto 0);
    signal topRangeX_uid149_prodDivPreNormProd_uid60_fpDivTest_b : STD_LOGIC_VECTOR (17 downto 0);
    signal topRangeY_uid150_prodDivPreNormProd_uid60_fpDivTest_b : STD_LOGIC_VECTOR (17 downto 0);
    signal aboveLeftX_uid155_prodDivPreNormProd_uid60_fpDivTest_b : STD_LOGIC_VECTOR (8 downto 0);
    signal aboveLeftY_bottomExtension_uid156_prodDivPreNormProd_uid60_fpDivTest_q : STD_LOGIC_VECTOR (2 downto 0);
    signal aboveLeftY_bottomRange_uid157_prodDivPreNormProd_uid60_fpDivTest_in : STD_LOGIC_VECTOR (5 downto 0);
    signal aboveLeftY_bottomRange_uid157_prodDivPreNormProd_uid60_fpDivTest_b : STD_LOGIC_VECTOR (5 downto 0);
    signal aboveLeftY_mergedSignalTM_uid158_prodDivPreNormProd_uid60_fpDivTest_q : STD_LOGIC_VECTOR (8 downto 0);
    signal rightBottomX_bottomRange_uid161_prodDivPreNormProd_uid60_fpDivTest_in : STD_LOGIC_VECTOR (7 downto 0);
    signal rightBottomX_bottomRange_uid161_prodDivPreNormProd_uid60_fpDivTest_b : STD_LOGIC_VECTOR (7 downto 0);
    signal rightBottomX_mergedSignalTM_uid162_prodDivPreNormProd_uid60_fpDivTest_q : STD_LOGIC_VECTOR (8 downto 0);
    signal rightBottomY_uid164_prodDivPreNormProd_uid60_fpDivTest_b : STD_LOGIC_VECTOR (8 downto 0);
    signal rightBottomX_uid168_prodDivPreNormProd_uid60_fpDivTest_in : STD_LOGIC_VECTOR (16 downto 0);
    signal rightBottomX_uid168_prodDivPreNormProd_uid60_fpDivTest_b : STD_LOGIC_VECTOR (4 downto 0);
    signal rightBottomY_uid169_prodDivPreNormProd_uid60_fpDivTest_in : STD_LOGIC_VECTOR (5 downto 0);
    signal rightBottomY_uid169_prodDivPreNormProd_uid60_fpDivTest_b : STD_LOGIC_VECTOR (4 downto 0);
    signal aboveLeftX_uid170_prodDivPreNormProd_uid60_fpDivTest_in : STD_LOGIC_VECTOR (7 downto 0);
    signal aboveLeftX_uid170_prodDivPreNormProd_uid60_fpDivTest_b : STD_LOGIC_VECTOR (4 downto 0);
    signal aboveLeftY_uid171_prodDivPreNormProd_uid60_fpDivTest_in : STD_LOGIC_VECTOR (14 downto 0);
    signal aboveLeftY_uid171_prodDivPreNormProd_uid60_fpDivTest_b : STD_LOGIC_VECTOR (4 downto 0);
    signal n0_uid177_prodDivPreNormProd_uid60_fpDivTest_b : STD_LOGIC_VECTOR (3 downto 0);
    signal n1_uid178_prodDivPreNormProd_uid60_fpDivTest_b : STD_LOGIC_VECTOR (3 downto 0);
    signal n0_uid179_prodDivPreNormProd_uid60_fpDivTest_b : STD_LOGIC_VECTOR (3 downto 0);
    signal n1_uid180_prodDivPreNormProd_uid60_fpDivTest_b : STD_LOGIC_VECTOR (3 downto 0);
    signal n0_uid185_prodDivPreNormProd_uid60_fpDivTest_b : STD_LOGIC_VECTOR (2 downto 0);
    signal n1_uid186_prodDivPreNormProd_uid60_fpDivTest_b : STD_LOGIC_VECTOR (2 downto 0);
    signal n0_uid187_prodDivPreNormProd_uid60_fpDivTest_b : STD_LOGIC_VECTOR (2 downto 0);
    signal n1_uid188_prodDivPreNormProd_uid60_fpDivTest_b : STD_LOGIC_VECTOR (2 downto 0);
    signal n0_uid193_prodDivPreNormProd_uid60_fpDivTest_b : STD_LOGIC_VECTOR (1 downto 0);
    signal n1_uid194_prodDivPreNormProd_uid60_fpDivTest_b : STD_LOGIC_VECTOR (1 downto 0);
    signal n0_uid195_prodDivPreNormProd_uid60_fpDivTest_b : STD_LOGIC_VECTOR (1 downto 0);
    signal n1_uid196_prodDivPreNormProd_uid60_fpDivTest_b : STD_LOGIC_VECTOR (1 downto 0);
    signal sm0_uid207_prodDivPreNormProd_uid60_fpDivTest_a0 : STD_LOGIC_VECTOR (17 downto 0);
    signal sm0_uid207_prodDivPreNormProd_uid60_fpDivTest_b0 : STD_LOGIC_VECTOR (17 downto 0);
    signal sm0_uid207_prodDivPreNormProd_uid60_fpDivTest_s1 : STD_LOGIC_VECTOR (35 downto 0);
    signal sm0_uid207_prodDivPreNormProd_uid60_fpDivTest_reset : std_logic;
    signal sm0_uid207_prodDivPreNormProd_uid60_fpDivTest_q : STD_LOGIC_VECTOR (35 downto 0);
    signal sm0_uid208_prodDivPreNormProd_uid60_fpDivTest_a0 : STD_LOGIC_VECTOR (8 downto 0);
    signal sm0_uid208_prodDivPreNormProd_uid60_fpDivTest_b0 : STD_LOGIC_VECTOR (8 downto 0);
    signal sm0_uid208_prodDivPreNormProd_uid60_fpDivTest_s1 : STD_LOGIC_VECTOR (17 downto 0);
    signal sm0_uid208_prodDivPreNormProd_uid60_fpDivTest_reset : std_logic;
    signal sm0_uid208_prodDivPreNormProd_uid60_fpDivTest_q : STD_LOGIC_VECTOR (17 downto 0);
    signal sm1_uid209_prodDivPreNormProd_uid60_fpDivTest_a0 : STD_LOGIC_VECTOR (8 downto 0);
    signal sm1_uid209_prodDivPreNormProd_uid60_fpDivTest_b0 : STD_LOGIC_VECTOR (8 downto 0);
    signal sm1_uid209_prodDivPreNormProd_uid60_fpDivTest_s1 : STD_LOGIC_VECTOR (17 downto 0);
    signal sm1_uid209_prodDivPreNormProd_uid60_fpDivTest_reset : std_logic;
    signal sm1_uid209_prodDivPreNormProd_uid60_fpDivTest_q : STD_LOGIC_VECTOR (17 downto 0);
    signal sm0_uid210_prodDivPreNormProd_uid60_fpDivTest_a0 : STD_LOGIC_VECTOR (1 downto 0);
    signal sm0_uid210_prodDivPreNormProd_uid60_fpDivTest_b0 : STD_LOGIC_VECTOR (1 downto 0);
    signal sm0_uid210_prodDivPreNormProd_uid60_fpDivTest_s1 : STD_LOGIC_VECTOR (3 downto 0);
    signal sm0_uid210_prodDivPreNormProd_uid60_fpDivTest_reset : std_logic;
    signal sm0_uid210_prodDivPreNormProd_uid60_fpDivTest_q : STD_LOGIC_VECTOR (3 downto 0);
    signal sm1_uid211_prodDivPreNormProd_uid60_fpDivTest_a0 : STD_LOGIC_VECTOR (1 downto 0);
    signal sm1_uid211_prodDivPreNormProd_uid60_fpDivTest_b0 : STD_LOGIC_VECTOR (1 downto 0);
    signal sm1_uid211_prodDivPreNormProd_uid60_fpDivTest_s1 : STD_LOGIC_VECTOR (3 downto 0);
    signal sm1_uid211_prodDivPreNormProd_uid60_fpDivTest_reset : std_logic;
    signal sm1_uid211_prodDivPreNormProd_uid60_fpDivTest_q : STD_LOGIC_VECTOR (3 downto 0);
    signal lev1_a0_uid212_prodDivPreNormProd_uid60_fpDivTest_a : STD_LOGIC_VECTOR (36 downto 0);
    signal lev1_a0_uid212_prodDivPreNormProd_uid60_fpDivTest_b : STD_LOGIC_VECTOR (36 downto 0);
    signal lev1_a0_uid212_prodDivPreNormProd_uid60_fpDivTest_o : STD_LOGIC_VECTOR (36 downto 0);
    signal lev1_a0_uid212_prodDivPreNormProd_uid60_fpDivTest_q : STD_LOGIC_VECTOR (36 downto 0);
    signal lev1_a1high_uid215_prodDivPreNormProd_uid60_fpDivTest_a : STD_LOGIC_VECTOR (13 downto 0);
    signal lev1_a1high_uid215_prodDivPreNormProd_uid60_fpDivTest_b : STD_LOGIC_VECTOR (13 downto 0);
    signal lev1_a1high_uid215_prodDivPreNormProd_uid60_fpDivTest_o : STD_LOGIC_VECTOR (13 downto 0);
    signal lev1_a1high_uid215_prodDivPreNormProd_uid60_fpDivTest_q : STD_LOGIC_VECTOR (13 downto 0);
    signal lev1_a1_uid216_prodDivPreNormProd_uid60_fpDivTest_q : STD_LOGIC_VECTOR (18 downto 0);
    signal lev2_a0_uid217_prodDivPreNormProd_uid60_fpDivTest_a : STD_LOGIC_VECTOR (37 downto 0);
    signal lev2_a0_uid217_prodDivPreNormProd_uid60_fpDivTest_b : STD_LOGIC_VECTOR (37 downto 0);
    signal lev2_a0_uid217_prodDivPreNormProd_uid60_fpDivTest_o : STD_LOGIC_VECTOR (37 downto 0);
    signal lev2_a0_uid217_prodDivPreNormProd_uid60_fpDivTest_q : STD_LOGIC_VECTOR (37 downto 0);
    signal lev3_a0high_uid220_prodDivPreNormProd_uid60_fpDivTest_a : STD_LOGIC_VECTOR (33 downto 0);
    signal lev3_a0high_uid220_prodDivPreNormProd_uid60_fpDivTest_b : STD_LOGIC_VECTOR (33 downto 0);
    signal lev3_a0high_uid220_prodDivPreNormProd_uid60_fpDivTest_o : STD_LOGIC_VECTOR (33 downto 0);
    signal lev3_a0high_uid220_prodDivPreNormProd_uid60_fpDivTest_q : STD_LOGIC_VECTOR (33 downto 0);
    signal lev3_a0_uid221_prodDivPreNormProd_uid60_fpDivTest_q : STD_LOGIC_VECTOR (38 downto 0);
    signal osig_uid222_prodDivPreNormProd_uid60_fpDivTest_in : STD_LOGIC_VECTOR (35 downto 0);
    signal osig_uid222_prodDivPreNormProd_uid60_fpDivTest_b : STD_LOGIC_VECTOR (26 downto 0);
    signal nx_mergedSignalTM_uid226_pT1_uid127_invPolyEval_q : STD_LOGIC_VECTOR (12 downto 0);
    signal topRangeX_bottomExtension_uid239_pT1_uid127_invPolyEval_q : STD_LOGIC_VECTOR (3 downto 0);
    signal topRangeX_mergedSignalTM_uid241_pT1_uid127_invPolyEval_q : STD_LOGIC_VECTOR (16 downto 0);
    signal topRangeY_bottomExtension_uid243_pT1_uid127_invPolyEval_q : STD_LOGIC_VECTOR (4 downto 0);
    signal topRangeY_mergedSignalTM_uid245_pT1_uid127_invPolyEval_q : STD_LOGIC_VECTOR (16 downto 0);
    signal sm0_uid247_pT1_uid127_invPolyEval_a0 : STD_LOGIC_VECTOR (16 downto 0);
    signal sm0_uid247_pT1_uid127_invPolyEval_b0 : STD_LOGIC_VECTOR (16 downto 0);
    signal sm0_uid247_pT1_uid127_invPolyEval_s1 : STD_LOGIC_VECTOR (33 downto 0);
    signal sm0_uid247_pT1_uid127_invPolyEval_reset : std_logic;
    signal sm0_uid247_pT1_uid127_invPolyEval_q : STD_LOGIC_VECTOR (33 downto 0);
    signal osig_uid248_pT1_uid127_invPolyEval_in : STD_LOGIC_VECTOR (32 downto 0);
    signal osig_uid248_pT1_uid127_invPolyEval_b : STD_LOGIC_VECTOR (13 downto 0);
    signal nx_mergedSignalTM_uid252_pT2_uid134_invPolyEval_q : STD_LOGIC_VECTOR (14 downto 0);
    signal topRangeX_mergedSignalTM_uid264_pT2_uid134_invPolyEval_q : STD_LOGIC_VECTOR (16 downto 0);
    signal topRangeY_uid266_pT2_uid134_invPolyEval_b : STD_LOGIC_VECTOR (16 downto 0);
    signal aboveLeftX_uid272_pT2_uid134_invPolyEval_b : STD_LOGIC_VECTOR (7 downto 0);
    signal aboveLeftY_bottomRange_uid274_pT2_uid134_invPolyEval_in : STD_LOGIC_VECTOR (5 downto 0);
    signal aboveLeftY_bottomRange_uid274_pT2_uid134_invPolyEval_b : STD_LOGIC_VECTOR (5 downto 0);
    signal aboveLeftY_mergedSignalTM_uid275_pT2_uid134_invPolyEval_q : STD_LOGIC_VECTOR (7 downto 0);
    signal rightBottomX_uid283_pT2_uid134_invPolyEval_in : STD_LOGIC_VECTOR (6 downto 0);
    signal rightBottomX_uid283_pT2_uid134_invPolyEval_b : STD_LOGIC_VECTOR (4 downto 0);
    signal rightBottomY_uid284_pT2_uid134_invPolyEval_in : STD_LOGIC_VECTOR (5 downto 0);
    signal rightBottomY_uid284_pT2_uid134_invPolyEval_b : STD_LOGIC_VECTOR (4 downto 0);
    signal n0_uid293_pT2_uid134_invPolyEval_b : STD_LOGIC_VECTOR (3 downto 0);
    signal n1_uid294_pT2_uid134_invPolyEval_b : STD_LOGIC_VECTOR (3 downto 0);
    signal n0_uid301_pT2_uid134_invPolyEval_b : STD_LOGIC_VECTOR (2 downto 0);
    signal n1_uid302_pT2_uid134_invPolyEval_b : STD_LOGIC_VECTOR (2 downto 0);
    signal sm0_uid315_pT2_uid134_invPolyEval_a0 : STD_LOGIC_VECTOR (16 downto 0);
    signal sm0_uid315_pT2_uid134_invPolyEval_b0 : STD_LOGIC_VECTOR (16 downto 0);
    signal sm0_uid315_pT2_uid134_invPolyEval_s1 : STD_LOGIC_VECTOR (33 downto 0);
    signal sm0_uid315_pT2_uid134_invPolyEval_reset : std_logic;
    signal sm0_uid315_pT2_uid134_invPolyEval_q : STD_LOGIC_VECTOR (33 downto 0);
    signal sm0_uid316_pT2_uid134_invPolyEval_a0 : STD_LOGIC_VECTOR (7 downto 0);
    signal sm0_uid316_pT2_uid134_invPolyEval_b0 : STD_LOGIC_VECTOR (8 downto 0);
    signal sm0_uid316_pT2_uid134_invPolyEval_s1 : STD_LOGIC_VECTOR (16 downto 0);
    signal sm0_uid316_pT2_uid134_invPolyEval_reset : std_logic;
    signal sm0_uid316_pT2_uid134_invPolyEval_q : STD_LOGIC_VECTOR (15 downto 0);
    signal sm0_uid317_pT2_uid134_invPolyEval_a0 : STD_LOGIC_VECTOR (2 downto 0);
    signal sm0_uid317_pT2_uid134_invPolyEval_b0 : STD_LOGIC_VECTOR (2 downto 0);
    signal sm0_uid317_pT2_uid134_invPolyEval_s1 : STD_LOGIC_VECTOR (5 downto 0);
    signal sm0_uid317_pT2_uid134_invPolyEval_reset : std_logic;
    signal sm0_uid317_pT2_uid134_invPolyEval_q : STD_LOGIC_VECTOR (5 downto 0);
    signal lowRangeA_uid318_pT2_uid134_invPolyEval_in : STD_LOGIC_VECTOR (0 downto 0);
    signal lowRangeA_uid318_pT2_uid134_invPolyEval_b : STD_LOGIC_VECTOR (0 downto 0);
    signal highABits_uid319_pT2_uid134_invPolyEval_b : STD_LOGIC_VECTOR (32 downto 0);
    signal lev1_a0high_uid320_pT2_uid134_invPolyEval_a : STD_LOGIC_VECTOR (33 downto 0);
    signal lev1_a0high_uid320_pT2_uid134_invPolyEval_b : STD_LOGIC_VECTOR (33 downto 0);
    signal lev1_a0high_uid320_pT2_uid134_invPolyEval_o : STD_LOGIC_VECTOR (33 downto 0);
    signal lev1_a0high_uid320_pT2_uid134_invPolyEval_q : STD_LOGIC_VECTOR (33 downto 0);
    signal lev1_a0_uid321_pT2_uid134_invPolyEval_q : STD_LOGIC_VECTOR (34 downto 0);
    signal lowRangeA_uid322_pT2_uid134_invPolyEval_in : STD_LOGIC_VECTOR (2 downto 0);
    signal lowRangeA_uid322_pT2_uid134_invPolyEval_b : STD_LOGIC_VECTOR (2 downto 0);
    signal highABits_uid323_pT2_uid134_invPolyEval_b : STD_LOGIC_VECTOR (31 downto 0);
    signal lev2_a0high_uid324_pT2_uid134_invPolyEval_a : STD_LOGIC_VECTOR (33 downto 0);
    signal lev2_a0high_uid324_pT2_uid134_invPolyEval_b : STD_LOGIC_VECTOR (33 downto 0);
    signal lev2_a0high_uid324_pT2_uid134_invPolyEval_o : STD_LOGIC_VECTOR (33 downto 0);
    signal lev2_a0high_uid324_pT2_uid134_invPolyEval_q : STD_LOGIC_VECTOR (32 downto 0);
    signal lev2_a0_uid325_pT2_uid134_invPolyEval_q : STD_LOGIC_VECTOR (35 downto 0);
    signal osig_uid326_pT2_uid134_invPolyEval_in : STD_LOGIC_VECTOR (32 downto 0);
    signal osig_uid326_pT2_uid134_invPolyEval_b : STD_LOGIC_VECTOR (24 downto 0);
    signal memoryC0_uid112_invTables_lutmem_reset0 : std_logic;
    signal memoryC0_uid112_invTables_lutmem_ia : STD_LOGIC_VECTOR (17 downto 0);
    signal memoryC0_uid112_invTables_lutmem_aa : STD_LOGIC_VECTOR (8 downto 0);
    signal memoryC0_uid112_invTables_lutmem_ab : STD_LOGIC_VECTOR (8 downto 0);
    signal memoryC0_uid112_invTables_lutmem_ir : STD_LOGIC_VECTOR (17 downto 0);
    signal memoryC0_uid112_invTables_lutmem_r : STD_LOGIC_VECTOR (17 downto 0);
    signal memoryC0_uid113_invTables_lutmem_reset0 : std_logic;
    signal memoryC0_uid113_invTables_lutmem_ia : STD_LOGIC_VECTOR (12 downto 0);
    signal memoryC0_uid113_invTables_lutmem_aa : STD_LOGIC_VECTOR (8 downto 0);
    signal memoryC0_uid113_invTables_lutmem_ab : STD_LOGIC_VECTOR (8 downto 0);
    signal memoryC0_uid113_invTables_lutmem_ir : STD_LOGIC_VECTOR (12 downto 0);
    signal memoryC0_uid113_invTables_lutmem_r : STD_LOGIC_VECTOR (12 downto 0);
    signal memoryC1_uid116_invTables_lutmem_reset0 : std_logic;
    signal memoryC1_uid116_invTables_lutmem_ia : STD_LOGIC_VECTOR (17 downto 0);
    signal memoryC1_uid116_invTables_lutmem_aa : STD_LOGIC_VECTOR (8 downto 0);
    signal memoryC1_uid116_invTables_lutmem_ab : STD_LOGIC_VECTOR (8 downto 0);
    signal memoryC1_uid116_invTables_lutmem_ir : STD_LOGIC_VECTOR (17 downto 0);
    signal memoryC1_uid116_invTables_lutmem_r : STD_LOGIC_VECTOR (17 downto 0);
    signal memoryC1_uid117_invTables_lutmem_reset0 : std_logic;
    signal memoryC1_uid117_invTables_lutmem_ia : STD_LOGIC_VECTOR (2 downto 0);
    signal memoryC1_uid117_invTables_lutmem_aa : STD_LOGIC_VECTOR (8 downto 0);
    signal memoryC1_uid117_invTables_lutmem_ab : STD_LOGIC_VECTOR (8 downto 0);
    signal memoryC1_uid117_invTables_lutmem_ir : STD_LOGIC_VECTOR (2 downto 0);
    signal memoryC1_uid117_invTables_lutmem_r : STD_LOGIC_VECTOR (2 downto 0);
    signal memoryC2_uid120_invTables_lutmem_reset0 : std_logic;
    signal memoryC2_uid120_invTables_lutmem_ia : STD_LOGIC_VECTOR (11 downto 0);
    signal memoryC2_uid120_invTables_lutmem_aa : STD_LOGIC_VECTOR (8 downto 0);
    signal memoryC2_uid120_invTables_lutmem_ab : STD_LOGIC_VECTOR (8 downto 0);
    signal memoryC2_uid120_invTables_lutmem_ir : STD_LOGIC_VECTOR (11 downto 0);
    signal memoryC2_uid120_invTables_lutmem_r : STD_LOGIC_VECTOR (11 downto 0);
    signal invY_uid54_fpDivTest_merged_bit_select_in : STD_LOGIC_VECTOR (31 downto 0);
    signal invY_uid54_fpDivTest_merged_bit_select_b : STD_LOGIC_VECTOR (25 downto 0);
    signal invY_uid54_fpDivTest_merged_bit_select_c : STD_LOGIC_VECTOR (0 downto 0);
    signal lowRangeA_uid213_prodDivPreNormProd_uid60_fpDivTest_merged_bit_select_b : STD_LOGIC_VECTOR (4 downto 0);
    signal lowRangeA_uid213_prodDivPreNormProd_uid60_fpDivTest_merged_bit_select_c : STD_LOGIC_VECTOR (12 downto 0);
    signal lowRangeA_uid218_prodDivPreNormProd_uid60_fpDivTest_merged_bit_select_b : STD_LOGIC_VECTOR (4 downto 0);
    signal lowRangeA_uid218_prodDivPreNormProd_uid60_fpDivTest_merged_bit_select_c : STD_LOGIC_VECTOR (32 downto 0);
    signal redist0_lOAdded_uid58_fpDivTest_q_2_q : STD_LOGIC_VECTOR (23 downto 0);
    signal redist1_fracYPostZ_uid56_fpDivTest_q_2_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist2_yPE_uid52_fpDivTest_b_2_q : STD_LOGIC_VECTOR (13 downto 0);
    signal redist3_yPE_uid52_fpDivTest_b_4_q : STD_LOGIC_VECTOR (13 downto 0);
    signal redist4_yAddr_uid51_fpDivTest_b_2_q : STD_LOGIC_VECTOR (8 downto 0);
    signal redist5_yAddr_uid51_fpDivTest_b_4_q : STD_LOGIC_VECTOR (8 downto 0);
    signal redist6_expXmY_uid47_fpDivTest_q_8_q : STD_LOGIC_VECTOR (8 downto 0);
    signal redist7_signR_uid46_fpDivTest_q_8_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist8_fracXIsZero_uid39_fpDivTest_q_8_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist9_expXIsMax_uid38_fpDivTest_q_8_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist10_excZ_y_uid37_fpDivTest_q_8_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist11_fracXIsZero_uid25_fpDivTest_q_2_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist12_expXIsMax_uid24_fpDivTest_q_8_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist13_excZ_x_uid23_fpDivTest_q_8_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist14_fracYZero_uid15_fpDivTest_q_6_q : STD_LOGIC_VECTOR (0 downto 0);
    signal redist15_fracX_uid10_fpDivTest_b_6_q : STD_LOGIC_VECTOR (22 downto 0);

begin


    -- fracY_uid13_fpDivTest(BITSELECT,12)@0
    fracY_uid13_fpDivTest_b <= b(22 downto 0);

    -- paddingY_uid15_fpDivTest(CONSTANT,14)
    paddingY_uid15_fpDivTest_q <= "00000000000000000000000";

    -- fracXIsZero_uid39_fpDivTest(LOGICAL,38)@0 + 1
    fracXIsZero_uid39_fpDivTest_qi <= "1" WHEN paddingY_uid15_fpDivTest_q = fracY_uid13_fpDivTest_b ELSE "0";
    fracXIsZero_uid39_fpDivTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => fracXIsZero_uid39_fpDivTest_qi, xout => fracXIsZero_uid39_fpDivTest_q, clk => clk, aclr => areset );

    -- redist8_fracXIsZero_uid39_fpDivTest_q_8(DELAY,343)
    redist8_fracXIsZero_uid39_fpDivTest_q_8 : dspba_delay
    GENERIC MAP ( width => 1, depth => 7, reset_kind => "ASYNC" )
    PORT MAP ( xin => fracXIsZero_uid39_fpDivTest_q, xout => redist8_fracXIsZero_uid39_fpDivTest_q_8_q, clk => clk, aclr => areset );

    -- cstAllOWE_uid18_fpDivTest(CONSTANT,17)
    cstAllOWE_uid18_fpDivTest_q <= "11111111";

    -- expY_uid12_fpDivTest(BITSELECT,11)@0
    expY_uid12_fpDivTest_b <= b(30 downto 23);

    -- expXIsMax_uid38_fpDivTest(LOGICAL,37)@0 + 1
    expXIsMax_uid38_fpDivTest_qi <= "1" WHEN expY_uid12_fpDivTest_b = cstAllOWE_uid18_fpDivTest_q ELSE "0";
    expXIsMax_uid38_fpDivTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => expXIsMax_uid38_fpDivTest_qi, xout => expXIsMax_uid38_fpDivTest_q, clk => clk, aclr => areset );

    -- redist9_expXIsMax_uid38_fpDivTest_q_8(DELAY,344)
    redist9_expXIsMax_uid38_fpDivTest_q_8 : dspba_delay
    GENERIC MAP ( width => 1, depth => 7, reset_kind => "ASYNC" )
    PORT MAP ( xin => expXIsMax_uid38_fpDivTest_q, xout => redist9_expXIsMax_uid38_fpDivTest_q_8_q, clk => clk, aclr => areset );

    -- excI_y_uid41_fpDivTest(LOGICAL,40)@8
    excI_y_uid41_fpDivTest_q <= redist9_expXIsMax_uid38_fpDivTest_q_8_q and redist8_fracXIsZero_uid39_fpDivTest_q_8_q;

    -- fracX_uid10_fpDivTest(BITSELECT,9)@0
    fracX_uid10_fpDivTest_b <= a(22 downto 0);

    -- redist15_fracX_uid10_fpDivTest_b_6(DELAY,350)
    redist15_fracX_uid10_fpDivTest_b_6 : dspba_delay
    GENERIC MAP ( width => 23, depth => 6, reset_kind => "ASYNC" )
    PORT MAP ( xin => fracX_uid10_fpDivTest_b, xout => redist15_fracX_uid10_fpDivTest_b_6_q, clk => clk, aclr => areset );

    -- fracXIsZero_uid25_fpDivTest(LOGICAL,24)@6 + 1
    fracXIsZero_uid25_fpDivTest_qi <= "1" WHEN paddingY_uid15_fpDivTest_q = redist15_fracX_uid10_fpDivTest_b_6_q ELSE "0";
    fracXIsZero_uid25_fpDivTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => fracXIsZero_uid25_fpDivTest_qi, xout => fracXIsZero_uid25_fpDivTest_q, clk => clk, aclr => areset );

    -- redist11_fracXIsZero_uid25_fpDivTest_q_2(DELAY,346)
    redist11_fracXIsZero_uid25_fpDivTest_q_2 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => fracXIsZero_uid25_fpDivTest_q, xout => redist11_fracXIsZero_uid25_fpDivTest_q_2_q, clk => clk, aclr => areset );

    -- expX_uid9_fpDivTest(BITSELECT,8)@0
    expX_uid9_fpDivTest_b <= a(30 downto 23);

    -- expXIsMax_uid24_fpDivTest(LOGICAL,23)@0 + 1
    expXIsMax_uid24_fpDivTest_qi <= "1" WHEN expX_uid9_fpDivTest_b = cstAllOWE_uid18_fpDivTest_q ELSE "0";
    expXIsMax_uid24_fpDivTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => expXIsMax_uid24_fpDivTest_qi, xout => expXIsMax_uid24_fpDivTest_q, clk => clk, aclr => areset );

    -- redist12_expXIsMax_uid24_fpDivTest_q_8(DELAY,347)
    redist12_expXIsMax_uid24_fpDivTest_q_8 : dspba_delay
    GENERIC MAP ( width => 1, depth => 7, reset_kind => "ASYNC" )
    PORT MAP ( xin => expXIsMax_uid24_fpDivTest_q, xout => redist12_expXIsMax_uid24_fpDivTest_q_8_q, clk => clk, aclr => areset );

    -- excI_x_uid27_fpDivTest(LOGICAL,26)@8
    excI_x_uid27_fpDivTest_q <= redist12_expXIsMax_uid24_fpDivTest_q_8_q and redist11_fracXIsZero_uid25_fpDivTest_q_2_q;

    -- excXIYI_uid96_fpDivTest(LOGICAL,95)@8
    excXIYI_uid96_fpDivTest_q <= excI_x_uid27_fpDivTest_q and excI_y_uid41_fpDivTest_q;

    -- fracXIsNotZero_uid40_fpDivTest(LOGICAL,39)@8
    fracXIsNotZero_uid40_fpDivTest_q <= not (redist8_fracXIsZero_uid39_fpDivTest_q_8_q);

    -- excN_y_uid42_fpDivTest(LOGICAL,41)@8
    excN_y_uid42_fpDivTest_q <= redist9_expXIsMax_uid38_fpDivTest_q_8_q and fracXIsNotZero_uid40_fpDivTest_q;

    -- fracXIsNotZero_uid26_fpDivTest(LOGICAL,25)@8
    fracXIsNotZero_uid26_fpDivTest_q <= not (redist11_fracXIsZero_uid25_fpDivTest_q_2_q);

    -- excN_x_uid28_fpDivTest(LOGICAL,27)@8
    excN_x_uid28_fpDivTest_q <= redist12_expXIsMax_uid24_fpDivTest_q_8_q and fracXIsNotZero_uid26_fpDivTest_q;

    -- cstAllZWE_uid20_fpDivTest(CONSTANT,19)
    cstAllZWE_uid20_fpDivTest_q <= "00000000";

    -- excZ_y_uid37_fpDivTest(LOGICAL,36)@0 + 1
    excZ_y_uid37_fpDivTest_qi <= "1" WHEN expY_uid12_fpDivTest_b = cstAllZWE_uid20_fpDivTest_q ELSE "0";
    excZ_y_uid37_fpDivTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => excZ_y_uid37_fpDivTest_qi, xout => excZ_y_uid37_fpDivTest_q, clk => clk, aclr => areset );

    -- redist10_excZ_y_uid37_fpDivTest_q_8(DELAY,345)
    redist10_excZ_y_uid37_fpDivTest_q_8 : dspba_delay
    GENERIC MAP ( width => 1, depth => 7, reset_kind => "ASYNC" )
    PORT MAP ( xin => excZ_y_uid37_fpDivTest_q, xout => redist10_excZ_y_uid37_fpDivTest_q_8_q, clk => clk, aclr => areset );

    -- excZ_x_uid23_fpDivTest(LOGICAL,22)@0 + 1
    excZ_x_uid23_fpDivTest_qi <= "1" WHEN expX_uid9_fpDivTest_b = cstAllZWE_uid20_fpDivTest_q ELSE "0";
    excZ_x_uid23_fpDivTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => excZ_x_uid23_fpDivTest_qi, xout => excZ_x_uid23_fpDivTest_q, clk => clk, aclr => areset );

    -- redist13_excZ_x_uid23_fpDivTest_q_8(DELAY,348)
    redist13_excZ_x_uid23_fpDivTest_q_8 : dspba_delay
    GENERIC MAP ( width => 1, depth => 7, reset_kind => "ASYNC" )
    PORT MAP ( xin => excZ_x_uid23_fpDivTest_q, xout => redist13_excZ_x_uid23_fpDivTest_q_8_q, clk => clk, aclr => areset );

    -- excXZYZ_uid95_fpDivTest(LOGICAL,94)@8
    excXZYZ_uid95_fpDivTest_q <= redist13_excZ_x_uid23_fpDivTest_q_8_q and redist10_excZ_y_uid37_fpDivTest_q_8_q;

    -- excRNaN_uid97_fpDivTest(LOGICAL,96)@8
    excRNaN_uid97_fpDivTest_q <= excXZYZ_uid95_fpDivTest_q or excN_x_uid28_fpDivTest_q or excN_y_uid42_fpDivTest_q or excXIYI_uid96_fpDivTest_q;

    -- invExcRNaN_uid108_fpDivTest(LOGICAL,107)@8
    invExcRNaN_uid108_fpDivTest_q <= not (excRNaN_uid97_fpDivTest_q);

    -- signY_uid14_fpDivTest(BITSELECT,13)@0
    signY_uid14_fpDivTest_b <= STD_LOGIC_VECTOR(b(31 downto 31));

    -- signX_uid11_fpDivTest(BITSELECT,10)@0
    signX_uid11_fpDivTest_b <= STD_LOGIC_VECTOR(a(31 downto 31));

    -- signR_uid46_fpDivTest(LOGICAL,45)@0 + 1
    signR_uid46_fpDivTest_qi <= signX_uid11_fpDivTest_b xor signY_uid14_fpDivTest_b;
    signR_uid46_fpDivTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => signR_uid46_fpDivTest_qi, xout => signR_uid46_fpDivTest_q, clk => clk, aclr => areset );

    -- redist7_signR_uid46_fpDivTest_q_8(DELAY,342)
    redist7_signR_uid46_fpDivTest_q_8 : dspba_delay
    GENERIC MAP ( width => 1, depth => 7, reset_kind => "ASYNC" )
    PORT MAP ( xin => signR_uid46_fpDivTest_q, xout => redist7_signR_uid46_fpDivTest_q_8_q, clk => clk, aclr => areset );

    -- VCC(CONSTANT,1)
    VCC_q <= "1";

    -- sRPostExc_uid109_fpDivTest(LOGICAL,108)@8
    sRPostExc_uid109_fpDivTest_q <= redist7_signR_uid46_fpDivTest_q_8_q and invExcRNaN_uid108_fpDivTest_q;

    -- lOAdded_uid58_fpDivTest(BITJOIN,57)@6
    lOAdded_uid58_fpDivTest_q <= VCC_q & redist15_fracX_uid10_fpDivTest_b_6_q;

    -- redist0_lOAdded_uid58_fpDivTest_q_2(DELAY,335)
    redist0_lOAdded_uid58_fpDivTest_q_2 : dspba_delay
    GENERIC MAP ( width => 24, depth => 2, reset_kind => "ASYNC" )
    PORT MAP ( xin => lOAdded_uid58_fpDivTest_q, xout => redist0_lOAdded_uid58_fpDivTest_q_2_q, clk => clk, aclr => areset );

    -- oFracXSE_bottomExtension_uid61_fpDivTest(CONSTANT,60)
    oFracXSE_bottomExtension_uid61_fpDivTest_q <= "00";

    -- oFracXSE_mergedSignalTM_uid63_fpDivTest(BITJOIN,62)@8
    oFracXSE_mergedSignalTM_uid63_fpDivTest_q <= redist0_lOAdded_uid58_fpDivTest_q_2_q & oFracXSE_bottomExtension_uid61_fpDivTest_q;

    -- aboveLeftY_uid171_prodDivPreNormProd_uid60_fpDivTest(BITSELECT,170)@6
    aboveLeftY_uid171_prodDivPreNormProd_uid60_fpDivTest_in <= lOAdded_uid58_fpDivTest_q(14 downto 0);
    aboveLeftY_uid171_prodDivPreNormProd_uid60_fpDivTest_b <= aboveLeftY_uid171_prodDivPreNormProd_uid60_fpDivTest_in(14 downto 10);

    -- n1_uid180_prodDivPreNormProd_uid60_fpDivTest(BITSELECT,179)@6
    n1_uid180_prodDivPreNormProd_uid60_fpDivTest_b <= aboveLeftY_uid171_prodDivPreNormProd_uid60_fpDivTest_b(4 downto 1);

    -- n1_uid188_prodDivPreNormProd_uid60_fpDivTest(BITSELECT,187)@6
    n1_uid188_prodDivPreNormProd_uid60_fpDivTest_b <= n1_uid180_prodDivPreNormProd_uid60_fpDivTest_b(3 downto 1);

    -- n1_uid196_prodDivPreNormProd_uid60_fpDivTest(BITSELECT,195)@6
    n1_uid196_prodDivPreNormProd_uid60_fpDivTest_b <= n1_uid188_prodDivPreNormProd_uid60_fpDivTest_b(2 downto 1);

    -- yAddr_uid51_fpDivTest(BITSELECT,50)@0
    yAddr_uid51_fpDivTest_b <= fracY_uid13_fpDivTest_b(22 downto 14);

    -- memoryC2_uid120_invTables_lutmem(DUALMEM,331)@0 + 2
    memoryC2_uid120_invTables_lutmem_aa <= yAddr_uid51_fpDivTest_b;
    memoryC2_uid120_invTables_lutmem_reset0 <= areset;
    memoryC2_uid120_invTables_lutmem_dmem : altsyncram
    GENERIC MAP (
        ram_block_type => "M9K",
        operation_mode => "ROM",
        width_a => 12,
        widthad_a => 9,
        numwords_a => 512,
        lpm_type => "altsyncram",
        width_byteena_a => 1,
        outdata_reg_a => "CLOCK0",
        outdata_aclr_a => "CLEAR0",
        clock_enable_input_a => "NORMAL",
        power_up_uninitialized => "FALSE",
        init_file => "fp_div_0002_memoryC2_uid120_invTables_lutmem.hex",
        init_file_layout => "PORT_A",
        intended_device_family => "MAX 10"
    )
    PORT MAP (
        clocken0 => VCC_q(0),
        aclr0 => memoryC2_uid120_invTables_lutmem_reset0,
        clock0 => clk,
        address_a => memoryC2_uid120_invTables_lutmem_aa,
        q_a => memoryC2_uid120_invTables_lutmem_ir
    );
    memoryC2_uid120_invTables_lutmem_r <= memoryC2_uid120_invTables_lutmem_ir(11 downto 0);

    -- topRangeY_bottomExtension_uid243_pT1_uid127_invPolyEval(CONSTANT,242)
    topRangeY_bottomExtension_uid243_pT1_uid127_invPolyEval_q <= "00000";

    -- topRangeY_mergedSignalTM_uid245_pT1_uid127_invPolyEval(BITJOIN,244)@2
    topRangeY_mergedSignalTM_uid245_pT1_uid127_invPolyEval_q <= memoryC2_uid120_invTables_lutmem_r & topRangeY_bottomExtension_uid243_pT1_uid127_invPolyEval_q;

    -- GND(CONSTANT,0)
    GND_q <= "0";

    -- yPE_uid52_fpDivTest(BITSELECT,51)@0
    yPE_uid52_fpDivTest_b <= b(13 downto 0);

    -- redist2_yPE_uid52_fpDivTest_b_2(DELAY,337)
    redist2_yPE_uid52_fpDivTest_b_2 : dspba_delay
    GENERIC MAP ( width => 14, depth => 2, reset_kind => "ASYNC" )
    PORT MAP ( xin => yPE_uid52_fpDivTest_b, xout => redist2_yPE_uid52_fpDivTest_b_2_q, clk => clk, aclr => areset );

    -- yT1_uid126_invPolyEval(BITSELECT,125)@2
    yT1_uid126_invPolyEval_b <= redist2_yPE_uid52_fpDivTest_b_2_q(13 downto 2);

    -- nx_mergedSignalTM_uid226_pT1_uid127_invPolyEval(BITJOIN,225)@2
    nx_mergedSignalTM_uid226_pT1_uid127_invPolyEval_q <= GND_q & yT1_uid126_invPolyEval_b;

    -- topRangeX_bottomExtension_uid239_pT1_uid127_invPolyEval(CONSTANT,238)
    topRangeX_bottomExtension_uid239_pT1_uid127_invPolyEval_q <= "0000";

    -- topRangeX_mergedSignalTM_uid241_pT1_uid127_invPolyEval(BITJOIN,240)@2
    topRangeX_mergedSignalTM_uid241_pT1_uid127_invPolyEval_q <= nx_mergedSignalTM_uid226_pT1_uid127_invPolyEval_q & topRangeX_bottomExtension_uid239_pT1_uid127_invPolyEval_q;

    -- sm0_uid247_pT1_uid127_invPolyEval(MULT,246)@2 + 2
    sm0_uid247_pT1_uid127_invPolyEval_a0 <= STD_LOGIC_VECTOR(topRangeX_mergedSignalTM_uid241_pT1_uid127_invPolyEval_q);
    sm0_uid247_pT1_uid127_invPolyEval_b0 <= STD_LOGIC_VECTOR(topRangeY_mergedSignalTM_uid245_pT1_uid127_invPolyEval_q);
    sm0_uid247_pT1_uid127_invPolyEval_reset <= areset;
    sm0_uid247_pT1_uid127_invPolyEval_component : lpm_mult
    GENERIC MAP (
        lpm_widtha => 17,
        lpm_widthb => 17,
        lpm_widthp => 34,
        lpm_widths => 1,
        lpm_type => "LPM_MULT",
        lpm_representation => "SIGNED",
        lpm_hint => "DEDICATED_MULTIPLIER_CIRCUITRY=YES, MAXIMIZE_SPEED=5",
        lpm_pipeline => 2
    )
    PORT MAP (
        dataa => sm0_uid247_pT1_uid127_invPolyEval_a0,
        datab => sm0_uid247_pT1_uid127_invPolyEval_b0,
        clken => VCC_q(0),
        aclr => sm0_uid247_pT1_uid127_invPolyEval_reset,
        clock => clk,
        result => sm0_uid247_pT1_uid127_invPolyEval_s1
    );
    sm0_uid247_pT1_uid127_invPolyEval_q <= sm0_uid247_pT1_uid127_invPolyEval_s1;

    -- osig_uid248_pT1_uid127_invPolyEval(BITSELECT,247)@4
    osig_uid248_pT1_uid127_invPolyEval_in <= STD_LOGIC_VECTOR(sm0_uid247_pT1_uid127_invPolyEval_q(32 downto 0));
    osig_uid248_pT1_uid127_invPolyEval_b <= STD_LOGIC_VECTOR(osig_uid248_pT1_uid127_invPolyEval_in(32 downto 19));

    -- redist4_yAddr_uid51_fpDivTest_b_2(DELAY,339)
    redist4_yAddr_uid51_fpDivTest_b_2 : dspba_delay
    GENERIC MAP ( width => 9, depth => 2, reset_kind => "ASYNC" )
    PORT MAP ( xin => yAddr_uid51_fpDivTest_b, xout => redist4_yAddr_uid51_fpDivTest_b_2_q, clk => clk, aclr => areset );

    -- memoryC1_uid117_invTables_lutmem(DUALMEM,330)@2 + 2
    memoryC1_uid117_invTables_lutmem_aa <= redist4_yAddr_uid51_fpDivTest_b_2_q;
    memoryC1_uid117_invTables_lutmem_reset0 <= areset;
    memoryC1_uid117_invTables_lutmem_dmem : altsyncram
    GENERIC MAP (
        ram_block_type => "M9K",
        operation_mode => "ROM",
        width_a => 3,
        widthad_a => 9,
        numwords_a => 512,
        lpm_type => "altsyncram",
        width_byteena_a => 1,
        outdata_reg_a => "CLOCK0",
        outdata_aclr_a => "CLEAR0",
        clock_enable_input_a => "NORMAL",
        power_up_uninitialized => "FALSE",
        init_file => "fp_div_0002_memoryC1_uid117_invTables_lutmem.hex",
        init_file_layout => "PORT_A",
        intended_device_family => "MAX 10"
    )
    PORT MAP (
        clocken0 => VCC_q(0),
        aclr0 => memoryC1_uid117_invTables_lutmem_reset0,
        clock0 => clk,
        address_a => memoryC1_uid117_invTables_lutmem_aa,
        q_a => memoryC1_uid117_invTables_lutmem_ir
    );
    memoryC1_uid117_invTables_lutmem_r <= memoryC1_uid117_invTables_lutmem_ir(2 downto 0);

    -- memoryC1_uid116_invTables_lutmem(DUALMEM,329)@2 + 2
    memoryC1_uid116_invTables_lutmem_aa <= redist4_yAddr_uid51_fpDivTest_b_2_q;
    memoryC1_uid116_invTables_lutmem_reset0 <= areset;
    memoryC1_uid116_invTables_lutmem_dmem : altsyncram
    GENERIC MAP (
        ram_block_type => "M9K",
        operation_mode => "ROM",
        width_a => 18,
        widthad_a => 9,
        numwords_a => 512,
        lpm_type => "altsyncram",
        width_byteena_a => 1,
        outdata_reg_a => "CLOCK0",
        outdata_aclr_a => "CLEAR0",
        clock_enable_input_a => "NORMAL",
        power_up_uninitialized => "FALSE",
        init_file => "fp_div_0002_memoryC1_uid116_invTables_lutmem.hex",
        init_file_layout => "PORT_A",
        intended_device_family => "MAX 10"
    )
    PORT MAP (
        clocken0 => VCC_q(0),
        aclr0 => memoryC1_uid116_invTables_lutmem_reset0,
        clock0 => clk,
        address_a => memoryC1_uid116_invTables_lutmem_aa,
        q_a => memoryC1_uid116_invTables_lutmem_ir
    );
    memoryC1_uid116_invTables_lutmem_r <= memoryC1_uid116_invTables_lutmem_ir(17 downto 0);

    -- os_uid118_invTables(BITJOIN,117)@4
    os_uid118_invTables_q <= memoryC1_uid117_invTables_lutmem_r & memoryC1_uid116_invTables_lutmem_r;

    -- rndBit_uid128_invPolyEval(CONSTANT,127)
    rndBit_uid128_invPolyEval_q <= "01";

    -- cIncludingRoundingBit_uid129_invPolyEval(BITJOIN,128)@4
    cIncludingRoundingBit_uid129_invPolyEval_q <= os_uid118_invTables_q & rndBit_uid128_invPolyEval_q;

    -- ts1_uid131_invPolyEval(ADD,130)@4
    ts1_uid131_invPolyEval_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((23 downto 23 => cIncludingRoundingBit_uid129_invPolyEval_q(22)) & cIncludingRoundingBit_uid129_invPolyEval_q));
    ts1_uid131_invPolyEval_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((23 downto 14 => osig_uid248_pT1_uid127_invPolyEval_b(13)) & osig_uid248_pT1_uid127_invPolyEval_b));
    ts1_uid131_invPolyEval_o <= STD_LOGIC_VECTOR(SIGNED(ts1_uid131_invPolyEval_a) + SIGNED(ts1_uid131_invPolyEval_b));
    ts1_uid131_invPolyEval_q <= ts1_uid131_invPolyEval_o(23 downto 0);

    -- s1_uid132_invPolyEval(BITSELECT,131)@4
    s1_uid132_invPolyEval_b <= STD_LOGIC_VECTOR(ts1_uid131_invPolyEval_q(23 downto 1));

    -- rightBottomY_uid284_pT2_uid134_invPolyEval(BITSELECT,283)@4
    rightBottomY_uid284_pT2_uid134_invPolyEval_in <= s1_uid132_invPolyEval_b(5 downto 0);
    rightBottomY_uid284_pT2_uid134_invPolyEval_b <= rightBottomY_uid284_pT2_uid134_invPolyEval_in(5 downto 1);

    -- n1_uid294_pT2_uid134_invPolyEval(BITSELECT,293)@4
    n1_uid294_pT2_uid134_invPolyEval_b <= rightBottomY_uid284_pT2_uid134_invPolyEval_b(4 downto 1);

    -- n1_uid302_pT2_uid134_invPolyEval(BITSELECT,301)@4
    n1_uid302_pT2_uid134_invPolyEval_b <= n1_uid294_pT2_uid134_invPolyEval_b(3 downto 1);

    -- redist3_yPE_uid52_fpDivTest_b_4(DELAY,338)
    redist3_yPE_uid52_fpDivTest_b_4 : dspba_delay
    GENERIC MAP ( width => 14, depth => 2, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist2_yPE_uid52_fpDivTest_b_2_q, xout => redist3_yPE_uid52_fpDivTest_b_4_q, clk => clk, aclr => areset );

    -- nx_mergedSignalTM_uid252_pT2_uid134_invPolyEval(BITJOIN,251)@4
    nx_mergedSignalTM_uid252_pT2_uid134_invPolyEval_q <= GND_q & redist3_yPE_uid52_fpDivTest_b_4_q;

    -- rightBottomX_uid283_pT2_uid134_invPolyEval(BITSELECT,282)@4
    rightBottomX_uid283_pT2_uid134_invPolyEval_in <= nx_mergedSignalTM_uid252_pT2_uid134_invPolyEval_q(6 downto 0);
    rightBottomX_uid283_pT2_uid134_invPolyEval_b <= rightBottomX_uid283_pT2_uid134_invPolyEval_in(6 downto 2);

    -- n0_uid293_pT2_uid134_invPolyEval(BITSELECT,292)@4
    n0_uid293_pT2_uid134_invPolyEval_b <= rightBottomX_uid283_pT2_uid134_invPolyEval_b(4 downto 1);

    -- n0_uid301_pT2_uid134_invPolyEval(BITSELECT,300)@4
    n0_uid301_pT2_uid134_invPolyEval_b <= n0_uid293_pT2_uid134_invPolyEval_b(3 downto 1);

    -- sm0_uid317_pT2_uid134_invPolyEval(MULT,316)@4 + 2
    sm0_uid317_pT2_uid134_invPolyEval_a0 <= n0_uid301_pT2_uid134_invPolyEval_b;
    sm0_uid317_pT2_uid134_invPolyEval_b0 <= n1_uid302_pT2_uid134_invPolyEval_b;
    sm0_uid317_pT2_uid134_invPolyEval_reset <= areset;
    sm0_uid317_pT2_uid134_invPolyEval_component : lpm_mult
    GENERIC MAP (
        lpm_widtha => 3,
        lpm_widthb => 3,
        lpm_widthp => 6,
        lpm_widths => 1,
        lpm_type => "LPM_MULT",
        lpm_representation => "UNSIGNED",
        lpm_hint => "DEDICATED_MULTIPLIER_CIRCUITRY=NO, MAXIMIZE_SPEED=5",
        lpm_pipeline => 2
    )
    PORT MAP (
        dataa => sm0_uid317_pT2_uid134_invPolyEval_a0,
        datab => sm0_uid317_pT2_uid134_invPolyEval_b0,
        clken => VCC_q(0),
        aclr => sm0_uid317_pT2_uid134_invPolyEval_reset,
        clock => clk,
        result => sm0_uid317_pT2_uid134_invPolyEval_s1
    );
    sm0_uid317_pT2_uid134_invPolyEval_q <= sm0_uid317_pT2_uid134_invPolyEval_s1;

    -- aboveLeftY_bottomRange_uid274_pT2_uid134_invPolyEval(BITSELECT,273)@4
    aboveLeftY_bottomRange_uid274_pT2_uid134_invPolyEval_in <= STD_LOGIC_VECTOR(s1_uid132_invPolyEval_b(5 downto 0));
    aboveLeftY_bottomRange_uid274_pT2_uid134_invPolyEval_b <= STD_LOGIC_VECTOR(aboveLeftY_bottomRange_uid274_pT2_uid134_invPolyEval_in(5 downto 0));

    -- aboveLeftY_mergedSignalTM_uid275_pT2_uid134_invPolyEval(BITJOIN,274)@4
    aboveLeftY_mergedSignalTM_uid275_pT2_uid134_invPolyEval_q <= aboveLeftY_bottomRange_uid274_pT2_uid134_invPolyEval_b & oFracXSE_bottomExtension_uid61_fpDivTest_q;

    -- aboveLeftX_uid272_pT2_uid134_invPolyEval(BITSELECT,271)@4
    aboveLeftX_uid272_pT2_uid134_invPolyEval_b <= STD_LOGIC_VECTOR(nx_mergedSignalTM_uid252_pT2_uid134_invPolyEval_q(14 downto 7));

    -- sm0_uid316_pT2_uid134_invPolyEval(MULT,315)@4 + 2
    sm0_uid316_pT2_uid134_invPolyEval_a0 <= STD_LOGIC_VECTOR(aboveLeftX_uid272_pT2_uid134_invPolyEval_b);
    sm0_uid316_pT2_uid134_invPolyEval_b0 <= '0' & aboveLeftY_mergedSignalTM_uid275_pT2_uid134_invPolyEval_q;
    sm0_uid316_pT2_uid134_invPolyEval_reset <= areset;
    sm0_uid316_pT2_uid134_invPolyEval_component : lpm_mult
    GENERIC MAP (
        lpm_widtha => 8,
        lpm_widthb => 9,
        lpm_widthp => 17,
        lpm_widths => 1,
        lpm_type => "LPM_MULT",
        lpm_representation => "SIGNED",
        lpm_hint => "DEDICATED_MULTIPLIER_CIRCUITRY=YES, MAXIMIZE_SPEED=5",
        lpm_pipeline => 2
    )
    PORT MAP (
        dataa => sm0_uid316_pT2_uid134_invPolyEval_a0,
        datab => sm0_uid316_pT2_uid134_invPolyEval_b0,
        clken => VCC_q(0),
        aclr => sm0_uid316_pT2_uid134_invPolyEval_reset,
        clock => clk,
        result => sm0_uid316_pT2_uid134_invPolyEval_s1
    );
    sm0_uid316_pT2_uid134_invPolyEval_q <= sm0_uid316_pT2_uid134_invPolyEval_s1(15 downto 0);

    -- topRangeY_uid266_pT2_uid134_invPolyEval(BITSELECT,265)@4
    topRangeY_uid266_pT2_uid134_invPolyEval_b <= STD_LOGIC_VECTOR(s1_uid132_invPolyEval_b(22 downto 6));

    -- topRangeX_mergedSignalTM_uid264_pT2_uid134_invPolyEval(BITJOIN,263)@4
    topRangeX_mergedSignalTM_uid264_pT2_uid134_invPolyEval_q <= nx_mergedSignalTM_uid252_pT2_uid134_invPolyEval_q & oFracXSE_bottomExtension_uid61_fpDivTest_q;

    -- sm0_uid315_pT2_uid134_invPolyEval(MULT,314)@4 + 2
    sm0_uid315_pT2_uid134_invPolyEval_a0 <= STD_LOGIC_VECTOR(topRangeX_mergedSignalTM_uid264_pT2_uid134_invPolyEval_q);
    sm0_uid315_pT2_uid134_invPolyEval_b0 <= STD_LOGIC_VECTOR(topRangeY_uid266_pT2_uid134_invPolyEval_b);
    sm0_uid315_pT2_uid134_invPolyEval_reset <= areset;
    sm0_uid315_pT2_uid134_invPolyEval_component : lpm_mult
    GENERIC MAP (
        lpm_widtha => 17,
        lpm_widthb => 17,
        lpm_widthp => 34,
        lpm_widths => 1,
        lpm_type => "LPM_MULT",
        lpm_representation => "SIGNED",
        lpm_hint => "DEDICATED_MULTIPLIER_CIRCUITRY=YES, MAXIMIZE_SPEED=5",
        lpm_pipeline => 2
    )
    PORT MAP (
        dataa => sm0_uid315_pT2_uid134_invPolyEval_a0,
        datab => sm0_uid315_pT2_uid134_invPolyEval_b0,
        clken => VCC_q(0),
        aclr => sm0_uid315_pT2_uid134_invPolyEval_reset,
        clock => clk,
        result => sm0_uid315_pT2_uid134_invPolyEval_s1
    );
    sm0_uid315_pT2_uid134_invPolyEval_q <= sm0_uid315_pT2_uid134_invPolyEval_s1;

    -- highABits_uid319_pT2_uid134_invPolyEval(BITSELECT,318)@6
    highABits_uid319_pT2_uid134_invPolyEval_b <= STD_LOGIC_VECTOR(sm0_uid315_pT2_uid134_invPolyEval_q(33 downto 1));

    -- lev1_a0high_uid320_pT2_uid134_invPolyEval(ADD,319)@6
    lev1_a0high_uid320_pT2_uid134_invPolyEval_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((33 downto 33 => highABits_uid319_pT2_uid134_invPolyEval_b(32)) & highABits_uid319_pT2_uid134_invPolyEval_b));
    lev1_a0high_uid320_pT2_uid134_invPolyEval_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((33 downto 16 => sm0_uid316_pT2_uid134_invPolyEval_q(15)) & sm0_uid316_pT2_uid134_invPolyEval_q));
    lev1_a0high_uid320_pT2_uid134_invPolyEval_o <= STD_LOGIC_VECTOR(SIGNED(lev1_a0high_uid320_pT2_uid134_invPolyEval_a) + SIGNED(lev1_a0high_uid320_pT2_uid134_invPolyEval_b));
    lev1_a0high_uid320_pT2_uid134_invPolyEval_q <= lev1_a0high_uid320_pT2_uid134_invPolyEval_o(33 downto 0);

    -- lowRangeA_uid318_pT2_uid134_invPolyEval(BITSELECT,317)@6
    lowRangeA_uid318_pT2_uid134_invPolyEval_in <= sm0_uid315_pT2_uid134_invPolyEval_q(0 downto 0);
    lowRangeA_uid318_pT2_uid134_invPolyEval_b <= lowRangeA_uid318_pT2_uid134_invPolyEval_in(0 downto 0);

    -- lev1_a0_uid321_pT2_uid134_invPolyEval(BITJOIN,320)@6
    lev1_a0_uid321_pT2_uid134_invPolyEval_q <= lev1_a0high_uid320_pT2_uid134_invPolyEval_q & lowRangeA_uid318_pT2_uid134_invPolyEval_b;

    -- highABits_uid323_pT2_uid134_invPolyEval(BITSELECT,322)@6
    highABits_uid323_pT2_uid134_invPolyEval_b <= STD_LOGIC_VECTOR(lev1_a0_uid321_pT2_uid134_invPolyEval_q(34 downto 3));

    -- lev2_a0high_uid324_pT2_uid134_invPolyEval(ADD,323)@6
    lev2_a0high_uid324_pT2_uid134_invPolyEval_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((33 downto 32 => highABits_uid323_pT2_uid134_invPolyEval_b(31)) & highABits_uid323_pT2_uid134_invPolyEval_b));
    lev2_a0high_uid324_pT2_uid134_invPolyEval_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR("0" & "000000000000000000000000000" & sm0_uid317_pT2_uid134_invPolyEval_q));
    lev2_a0high_uid324_pT2_uid134_invPolyEval_o <= STD_LOGIC_VECTOR(SIGNED(lev2_a0high_uid324_pT2_uid134_invPolyEval_a) + SIGNED(lev2_a0high_uid324_pT2_uid134_invPolyEval_b));
    lev2_a0high_uid324_pT2_uid134_invPolyEval_q <= lev2_a0high_uid324_pT2_uid134_invPolyEval_o(32 downto 0);

    -- lowRangeA_uid322_pT2_uid134_invPolyEval(BITSELECT,321)@6
    lowRangeA_uid322_pT2_uid134_invPolyEval_in <= lev1_a0_uid321_pT2_uid134_invPolyEval_q(2 downto 0);
    lowRangeA_uid322_pT2_uid134_invPolyEval_b <= lowRangeA_uid322_pT2_uid134_invPolyEval_in(2 downto 0);

    -- lev2_a0_uid325_pT2_uid134_invPolyEval(BITJOIN,324)@6
    lev2_a0_uid325_pT2_uid134_invPolyEval_q <= lev2_a0high_uid324_pT2_uid134_invPolyEval_q & lowRangeA_uid322_pT2_uid134_invPolyEval_b;

    -- osig_uid326_pT2_uid134_invPolyEval(BITSELECT,325)@6
    osig_uid326_pT2_uid134_invPolyEval_in <= STD_LOGIC_VECTOR(lev2_a0_uid325_pT2_uid134_invPolyEval_q(32 downto 0));
    osig_uid326_pT2_uid134_invPolyEval_b <= STD_LOGIC_VECTOR(osig_uid326_pT2_uid134_invPolyEval_in(32 downto 8));

    -- redist5_yAddr_uid51_fpDivTest_b_4(DELAY,340)
    redist5_yAddr_uid51_fpDivTest_b_4 : dspba_delay
    GENERIC MAP ( width => 9, depth => 2, reset_kind => "ASYNC" )
    PORT MAP ( xin => redist4_yAddr_uid51_fpDivTest_b_2_q, xout => redist5_yAddr_uid51_fpDivTest_b_4_q, clk => clk, aclr => areset );

    -- memoryC0_uid113_invTables_lutmem(DUALMEM,328)@4 + 2
    memoryC0_uid113_invTables_lutmem_aa <= redist5_yAddr_uid51_fpDivTest_b_4_q;
    memoryC0_uid113_invTables_lutmem_reset0 <= areset;
    memoryC0_uid113_invTables_lutmem_dmem : altsyncram
    GENERIC MAP (
        ram_block_type => "M9K",
        operation_mode => "ROM",
        width_a => 13,
        widthad_a => 9,
        numwords_a => 512,
        lpm_type => "altsyncram",
        width_byteena_a => 1,
        outdata_reg_a => "CLOCK0",
        outdata_aclr_a => "CLEAR0",
        clock_enable_input_a => "NORMAL",
        power_up_uninitialized => "FALSE",
        init_file => "fp_div_0002_memoryC0_uid113_invTables_lutmem.hex",
        init_file_layout => "PORT_A",
        intended_device_family => "MAX 10"
    )
    PORT MAP (
        clocken0 => VCC_q(0),
        aclr0 => memoryC0_uid113_invTables_lutmem_reset0,
        clock0 => clk,
        address_a => memoryC0_uid113_invTables_lutmem_aa,
        q_a => memoryC0_uid113_invTables_lutmem_ir
    );
    memoryC0_uid113_invTables_lutmem_r <= memoryC0_uid113_invTables_lutmem_ir(12 downto 0);

    -- memoryC0_uid112_invTables_lutmem(DUALMEM,327)@4 + 2
    memoryC0_uid112_invTables_lutmem_aa <= redist5_yAddr_uid51_fpDivTest_b_4_q;
    memoryC0_uid112_invTables_lutmem_reset0 <= areset;
    memoryC0_uid112_invTables_lutmem_dmem : altsyncram
    GENERIC MAP (
        ram_block_type => "M9K",
        operation_mode => "ROM",
        width_a => 18,
        widthad_a => 9,
        numwords_a => 512,
        lpm_type => "altsyncram",
        width_byteena_a => 1,
        outdata_reg_a => "CLOCK0",
        outdata_aclr_a => "CLEAR0",
        clock_enable_input_a => "NORMAL",
        power_up_uninitialized => "FALSE",
        init_file => "fp_div_0002_memoryC0_uid112_invTables_lutmem.hex",
        init_file_layout => "PORT_A",
        intended_device_family => "MAX 10"
    )
    PORT MAP (
        clocken0 => VCC_q(0),
        aclr0 => memoryC0_uid112_invTables_lutmem_reset0,
        clock0 => clk,
        address_a => memoryC0_uid112_invTables_lutmem_aa,
        q_a => memoryC0_uid112_invTables_lutmem_ir
    );
    memoryC0_uid112_invTables_lutmem_r <= memoryC0_uid112_invTables_lutmem_ir(17 downto 0);

    -- os_uid114_invTables(BITJOIN,113)@6
    os_uid114_invTables_q <= memoryC0_uid113_invTables_lutmem_r & memoryC0_uid112_invTables_lutmem_r;

    -- rndBit_uid135_invPolyEval(CONSTANT,134)
    rndBit_uid135_invPolyEval_q <= "001";

    -- cIncludingRoundingBit_uid136_invPolyEval(BITJOIN,135)@6
    cIncludingRoundingBit_uid136_invPolyEval_q <= os_uid114_invTables_q & rndBit_uid135_invPolyEval_q;

    -- ts2_uid138_invPolyEval(ADD,137)@6
    ts2_uid138_invPolyEval_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((34 downto 34 => cIncludingRoundingBit_uid136_invPolyEval_q(33)) & cIncludingRoundingBit_uid136_invPolyEval_q));
    ts2_uid138_invPolyEval_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((34 downto 25 => osig_uid326_pT2_uid134_invPolyEval_b(24)) & osig_uid326_pT2_uid134_invPolyEval_b));
    ts2_uid138_invPolyEval_o <= STD_LOGIC_VECTOR(SIGNED(ts2_uid138_invPolyEval_a) + SIGNED(ts2_uid138_invPolyEval_b));
    ts2_uid138_invPolyEval_q <= ts2_uid138_invPolyEval_o(34 downto 0);

    -- s2_uid139_invPolyEval(BITSELECT,138)@6
    s2_uid139_invPolyEval_b <= STD_LOGIC_VECTOR(ts2_uid138_invPolyEval_q(34 downto 1));

    -- invY_uid54_fpDivTest_merged_bit_select(BITSELECT,332)@6
    invY_uid54_fpDivTest_merged_bit_select_in <= s2_uid139_invPolyEval_b(31 downto 0);
    invY_uid54_fpDivTest_merged_bit_select_b <= invY_uid54_fpDivTest_merged_bit_select_in(30 downto 5);
    invY_uid54_fpDivTest_merged_bit_select_c <= invY_uid54_fpDivTest_merged_bit_select_in(31 downto 31);

    -- aboveLeftX_uid170_prodDivPreNormProd_uid60_fpDivTest(BITSELECT,169)@6
    aboveLeftX_uid170_prodDivPreNormProd_uid60_fpDivTest_in <= invY_uid54_fpDivTest_merged_bit_select_b(7 downto 0);
    aboveLeftX_uid170_prodDivPreNormProd_uid60_fpDivTest_b <= aboveLeftX_uid170_prodDivPreNormProd_uid60_fpDivTest_in(7 downto 3);

    -- n0_uid179_prodDivPreNormProd_uid60_fpDivTest(BITSELECT,178)@6
    n0_uid179_prodDivPreNormProd_uid60_fpDivTest_b <= aboveLeftX_uid170_prodDivPreNormProd_uid60_fpDivTest_b(4 downto 1);

    -- n0_uid187_prodDivPreNormProd_uid60_fpDivTest(BITSELECT,186)@6
    n0_uid187_prodDivPreNormProd_uid60_fpDivTest_b <= n0_uid179_prodDivPreNormProd_uid60_fpDivTest_b(3 downto 1);

    -- n0_uid195_prodDivPreNormProd_uid60_fpDivTest(BITSELECT,194)@6
    n0_uid195_prodDivPreNormProd_uid60_fpDivTest_b <= n0_uid187_prodDivPreNormProd_uid60_fpDivTest_b(2 downto 1);

    -- sm1_uid211_prodDivPreNormProd_uid60_fpDivTest(MULT,210)@6 + 2
    sm1_uid211_prodDivPreNormProd_uid60_fpDivTest_a0 <= n0_uid195_prodDivPreNormProd_uid60_fpDivTest_b;
    sm1_uid211_prodDivPreNormProd_uid60_fpDivTest_b0 <= n1_uid196_prodDivPreNormProd_uid60_fpDivTest_b;
    sm1_uid211_prodDivPreNormProd_uid60_fpDivTest_reset <= areset;
    sm1_uid211_prodDivPreNormProd_uid60_fpDivTest_component : lpm_mult
    GENERIC MAP (
        lpm_widtha => 2,
        lpm_widthb => 2,
        lpm_widthp => 4,
        lpm_widths => 1,
        lpm_type => "LPM_MULT",
        lpm_representation => "UNSIGNED",
        lpm_hint => "DEDICATED_MULTIPLIER_CIRCUITRY=NO, MAXIMIZE_SPEED=5",
        lpm_pipeline => 2
    )
    PORT MAP (
        dataa => sm1_uid211_prodDivPreNormProd_uid60_fpDivTest_a0,
        datab => sm1_uid211_prodDivPreNormProd_uid60_fpDivTest_b0,
        clken => VCC_q(0),
        aclr => sm1_uid211_prodDivPreNormProd_uid60_fpDivTest_reset,
        clock => clk,
        result => sm1_uid211_prodDivPreNormProd_uid60_fpDivTest_s1
    );
    sm1_uid211_prodDivPreNormProd_uid60_fpDivTest_q <= sm1_uid211_prodDivPreNormProd_uid60_fpDivTest_s1;

    -- lev3_a0high_uid220_prodDivPreNormProd_uid60_fpDivTest(ADD,219)@8
    lev3_a0high_uid220_prodDivPreNormProd_uid60_fpDivTest_a <= STD_LOGIC_VECTOR("0" & lowRangeA_uid218_prodDivPreNormProd_uid60_fpDivTest_merged_bit_select_c);
    lev3_a0high_uid220_prodDivPreNormProd_uid60_fpDivTest_b <= STD_LOGIC_VECTOR("000000000000000000000000000000" & sm1_uid211_prodDivPreNormProd_uid60_fpDivTest_q);
    lev3_a0high_uid220_prodDivPreNormProd_uid60_fpDivTest_o <= STD_LOGIC_VECTOR(UNSIGNED(lev3_a0high_uid220_prodDivPreNormProd_uid60_fpDivTest_a) + UNSIGNED(lev3_a0high_uid220_prodDivPreNormProd_uid60_fpDivTest_b));
    lev3_a0high_uid220_prodDivPreNormProd_uid60_fpDivTest_q <= lev3_a0high_uid220_prodDivPreNormProd_uid60_fpDivTest_o(33 downto 0);

    -- rightBottomY_uid169_prodDivPreNormProd_uid60_fpDivTest(BITSELECT,168)@6
    rightBottomY_uid169_prodDivPreNormProd_uid60_fpDivTest_in <= lOAdded_uid58_fpDivTest_q(5 downto 0);
    rightBottomY_uid169_prodDivPreNormProd_uid60_fpDivTest_b <= rightBottomY_uid169_prodDivPreNormProd_uid60_fpDivTest_in(5 downto 1);

    -- n1_uid178_prodDivPreNormProd_uid60_fpDivTest(BITSELECT,177)@6
    n1_uid178_prodDivPreNormProd_uid60_fpDivTest_b <= rightBottomY_uid169_prodDivPreNormProd_uid60_fpDivTest_b(4 downto 1);

    -- n1_uid186_prodDivPreNormProd_uid60_fpDivTest(BITSELECT,185)@6
    n1_uid186_prodDivPreNormProd_uid60_fpDivTest_b <= n1_uid178_prodDivPreNormProd_uid60_fpDivTest_b(3 downto 1);

    -- n1_uid194_prodDivPreNormProd_uid60_fpDivTest(BITSELECT,193)@6
    n1_uid194_prodDivPreNormProd_uid60_fpDivTest_b <= n1_uid186_prodDivPreNormProd_uid60_fpDivTest_b(2 downto 1);

    -- rightBottomX_uid168_prodDivPreNormProd_uid60_fpDivTest(BITSELECT,167)@6
    rightBottomX_uid168_prodDivPreNormProd_uid60_fpDivTest_in <= invY_uid54_fpDivTest_merged_bit_select_b(16 downto 0);
    rightBottomX_uid168_prodDivPreNormProd_uid60_fpDivTest_b <= rightBottomX_uid168_prodDivPreNormProd_uid60_fpDivTest_in(16 downto 12);

    -- n0_uid177_prodDivPreNormProd_uid60_fpDivTest(BITSELECT,176)@6
    n0_uid177_prodDivPreNormProd_uid60_fpDivTest_b <= rightBottomX_uid168_prodDivPreNormProd_uid60_fpDivTest_b(4 downto 1);

    -- n0_uid185_prodDivPreNormProd_uid60_fpDivTest(BITSELECT,184)@6
    n0_uid185_prodDivPreNormProd_uid60_fpDivTest_b <= n0_uid177_prodDivPreNormProd_uid60_fpDivTest_b(3 downto 1);

    -- n0_uid193_prodDivPreNormProd_uid60_fpDivTest(BITSELECT,192)@6
    n0_uid193_prodDivPreNormProd_uid60_fpDivTest_b <= n0_uid185_prodDivPreNormProd_uid60_fpDivTest_b(2 downto 1);

    -- sm0_uid210_prodDivPreNormProd_uid60_fpDivTest(MULT,209)@6 + 2
    sm0_uid210_prodDivPreNormProd_uid60_fpDivTest_a0 <= n0_uid193_prodDivPreNormProd_uid60_fpDivTest_b;
    sm0_uid210_prodDivPreNormProd_uid60_fpDivTest_b0 <= n1_uid194_prodDivPreNormProd_uid60_fpDivTest_b;
    sm0_uid210_prodDivPreNormProd_uid60_fpDivTest_reset <= areset;
    sm0_uid210_prodDivPreNormProd_uid60_fpDivTest_component : lpm_mult
    GENERIC MAP (
        lpm_widtha => 2,
        lpm_widthb => 2,
        lpm_widthp => 4,
        lpm_widths => 1,
        lpm_type => "LPM_MULT",
        lpm_representation => "UNSIGNED",
        lpm_hint => "DEDICATED_MULTIPLIER_CIRCUITRY=NO, MAXIMIZE_SPEED=5",
        lpm_pipeline => 2
    )
    PORT MAP (
        dataa => sm0_uid210_prodDivPreNormProd_uid60_fpDivTest_a0,
        datab => sm0_uid210_prodDivPreNormProd_uid60_fpDivTest_b0,
        clken => VCC_q(0),
        aclr => sm0_uid210_prodDivPreNormProd_uid60_fpDivTest_reset,
        clock => clk,
        result => sm0_uid210_prodDivPreNormProd_uid60_fpDivTest_s1
    );
    sm0_uid210_prodDivPreNormProd_uid60_fpDivTest_q <= sm0_uid210_prodDivPreNormProd_uid60_fpDivTest_s1;

    -- lev1_a1high_uid215_prodDivPreNormProd_uid60_fpDivTest(ADD,214)@8
    lev1_a1high_uid215_prodDivPreNormProd_uid60_fpDivTest_a <= STD_LOGIC_VECTOR("0" & lowRangeA_uid213_prodDivPreNormProd_uid60_fpDivTest_merged_bit_select_c);
    lev1_a1high_uid215_prodDivPreNormProd_uid60_fpDivTest_b <= STD_LOGIC_VECTOR("0000000000" & sm0_uid210_prodDivPreNormProd_uid60_fpDivTest_q);
    lev1_a1high_uid215_prodDivPreNormProd_uid60_fpDivTest_o <= STD_LOGIC_VECTOR(UNSIGNED(lev1_a1high_uid215_prodDivPreNormProd_uid60_fpDivTest_a) + UNSIGNED(lev1_a1high_uid215_prodDivPreNormProd_uid60_fpDivTest_b));
    lev1_a1high_uid215_prodDivPreNormProd_uid60_fpDivTest_q <= lev1_a1high_uid215_prodDivPreNormProd_uid60_fpDivTest_o(13 downto 0);

    -- rightBottomY_uid164_prodDivPreNormProd_uid60_fpDivTest(BITSELECT,163)@6
    rightBottomY_uid164_prodDivPreNormProd_uid60_fpDivTest_b <= lOAdded_uid58_fpDivTest_q(23 downto 15);

    -- rightBottomX_bottomRange_uid161_prodDivPreNormProd_uid60_fpDivTest(BITSELECT,160)@6
    rightBottomX_bottomRange_uid161_prodDivPreNormProd_uid60_fpDivTest_in <= invY_uid54_fpDivTest_merged_bit_select_b(7 downto 0);
    rightBottomX_bottomRange_uid161_prodDivPreNormProd_uid60_fpDivTest_b <= rightBottomX_bottomRange_uid161_prodDivPreNormProd_uid60_fpDivTest_in(7 downto 0);

    -- rightBottomX_mergedSignalTM_uid162_prodDivPreNormProd_uid60_fpDivTest(BITJOIN,161)@6
    rightBottomX_mergedSignalTM_uid162_prodDivPreNormProd_uid60_fpDivTest_q <= rightBottomX_bottomRange_uid161_prodDivPreNormProd_uid60_fpDivTest_b & GND_q;

    -- sm1_uid209_prodDivPreNormProd_uid60_fpDivTest(MULT,208)@6 + 2
    sm1_uid209_prodDivPreNormProd_uid60_fpDivTest_a0 <= rightBottomX_mergedSignalTM_uid162_prodDivPreNormProd_uid60_fpDivTest_q;
    sm1_uid209_prodDivPreNormProd_uid60_fpDivTest_b0 <= rightBottomY_uid164_prodDivPreNormProd_uid60_fpDivTest_b;
    sm1_uid209_prodDivPreNormProd_uid60_fpDivTest_reset <= areset;
    sm1_uid209_prodDivPreNormProd_uid60_fpDivTest_component : lpm_mult
    GENERIC MAP (
        lpm_widtha => 9,
        lpm_widthb => 9,
        lpm_widthp => 18,
        lpm_widths => 1,
        lpm_type => "LPM_MULT",
        lpm_representation => "UNSIGNED",
        lpm_hint => "DEDICATED_MULTIPLIER_CIRCUITRY=YES, MAXIMIZE_SPEED=5",
        lpm_pipeline => 2
    )
    PORT MAP (
        dataa => sm1_uid209_prodDivPreNormProd_uid60_fpDivTest_a0,
        datab => sm1_uid209_prodDivPreNormProd_uid60_fpDivTest_b0,
        clken => VCC_q(0),
        aclr => sm1_uid209_prodDivPreNormProd_uid60_fpDivTest_reset,
        clock => clk,
        result => sm1_uid209_prodDivPreNormProd_uid60_fpDivTest_s1
    );
    sm1_uid209_prodDivPreNormProd_uid60_fpDivTest_q <= sm1_uid209_prodDivPreNormProd_uid60_fpDivTest_s1;

    -- lowRangeA_uid213_prodDivPreNormProd_uid60_fpDivTest_merged_bit_select(BITSELECT,333)@8
    lowRangeA_uid213_prodDivPreNormProd_uid60_fpDivTest_merged_bit_select_b <= sm1_uid209_prodDivPreNormProd_uid60_fpDivTest_q(4 downto 0);
    lowRangeA_uid213_prodDivPreNormProd_uid60_fpDivTest_merged_bit_select_c <= sm1_uid209_prodDivPreNormProd_uid60_fpDivTest_q(17 downto 5);

    -- lev1_a1_uid216_prodDivPreNormProd_uid60_fpDivTest(BITJOIN,215)@8
    lev1_a1_uid216_prodDivPreNormProd_uid60_fpDivTest_q <= lev1_a1high_uid215_prodDivPreNormProd_uid60_fpDivTest_q & lowRangeA_uid213_prodDivPreNormProd_uid60_fpDivTest_merged_bit_select_b;

    -- aboveLeftY_bottomRange_uid157_prodDivPreNormProd_uid60_fpDivTest(BITSELECT,156)@6
    aboveLeftY_bottomRange_uid157_prodDivPreNormProd_uid60_fpDivTest_in <= lOAdded_uid58_fpDivTest_q(5 downto 0);
    aboveLeftY_bottomRange_uid157_prodDivPreNormProd_uid60_fpDivTest_b <= aboveLeftY_bottomRange_uid157_prodDivPreNormProd_uid60_fpDivTest_in(5 downto 0);

    -- aboveLeftY_bottomExtension_uid156_prodDivPreNormProd_uid60_fpDivTest(CONSTANT,155)
    aboveLeftY_bottomExtension_uid156_prodDivPreNormProd_uid60_fpDivTest_q <= "000";

    -- aboveLeftY_mergedSignalTM_uid158_prodDivPreNormProd_uid60_fpDivTest(BITJOIN,157)@6
    aboveLeftY_mergedSignalTM_uid158_prodDivPreNormProd_uid60_fpDivTest_q <= aboveLeftY_bottomRange_uid157_prodDivPreNormProd_uid60_fpDivTest_b & aboveLeftY_bottomExtension_uid156_prodDivPreNormProd_uid60_fpDivTest_q;

    -- aboveLeftX_uid155_prodDivPreNormProd_uid60_fpDivTest(BITSELECT,154)@6
    aboveLeftX_uid155_prodDivPreNormProd_uid60_fpDivTest_b <= invY_uid54_fpDivTest_merged_bit_select_b(25 downto 17);

    -- sm0_uid208_prodDivPreNormProd_uid60_fpDivTest(MULT,207)@6 + 2
    sm0_uid208_prodDivPreNormProd_uid60_fpDivTest_a0 <= aboveLeftX_uid155_prodDivPreNormProd_uid60_fpDivTest_b;
    sm0_uid208_prodDivPreNormProd_uid60_fpDivTest_b0 <= aboveLeftY_mergedSignalTM_uid158_prodDivPreNormProd_uid60_fpDivTest_q;
    sm0_uid208_prodDivPreNormProd_uid60_fpDivTest_reset <= areset;
    sm0_uid208_prodDivPreNormProd_uid60_fpDivTest_component : lpm_mult
    GENERIC MAP (
        lpm_widtha => 9,
        lpm_widthb => 9,
        lpm_widthp => 18,
        lpm_widths => 1,
        lpm_type => "LPM_MULT",
        lpm_representation => "UNSIGNED",
        lpm_hint => "DEDICATED_MULTIPLIER_CIRCUITRY=YES, MAXIMIZE_SPEED=5",
        lpm_pipeline => 2
    )
    PORT MAP (
        dataa => sm0_uid208_prodDivPreNormProd_uid60_fpDivTest_a0,
        datab => sm0_uid208_prodDivPreNormProd_uid60_fpDivTest_b0,
        clken => VCC_q(0),
        aclr => sm0_uid208_prodDivPreNormProd_uid60_fpDivTest_reset,
        clock => clk,
        result => sm0_uid208_prodDivPreNormProd_uid60_fpDivTest_s1
    );
    sm0_uid208_prodDivPreNormProd_uid60_fpDivTest_q <= sm0_uid208_prodDivPreNormProd_uid60_fpDivTest_s1;

    -- topRangeY_uid150_prodDivPreNormProd_uid60_fpDivTest(BITSELECT,149)@6
    topRangeY_uid150_prodDivPreNormProd_uid60_fpDivTest_b <= lOAdded_uid58_fpDivTest_q(23 downto 6);

    -- topRangeX_uid149_prodDivPreNormProd_uid60_fpDivTest(BITSELECT,148)@6
    topRangeX_uid149_prodDivPreNormProd_uid60_fpDivTest_b <= invY_uid54_fpDivTest_merged_bit_select_b(25 downto 8);

    -- sm0_uid207_prodDivPreNormProd_uid60_fpDivTest(MULT,206)@6 + 2
    sm0_uid207_prodDivPreNormProd_uid60_fpDivTest_a0 <= topRangeX_uid149_prodDivPreNormProd_uid60_fpDivTest_b;
    sm0_uid207_prodDivPreNormProd_uid60_fpDivTest_b0 <= topRangeY_uid150_prodDivPreNormProd_uid60_fpDivTest_b;
    sm0_uid207_prodDivPreNormProd_uid60_fpDivTest_reset <= areset;
    sm0_uid207_prodDivPreNormProd_uid60_fpDivTest_component : lpm_mult
    GENERIC MAP (
        lpm_widtha => 18,
        lpm_widthb => 18,
        lpm_widthp => 36,
        lpm_widths => 1,
        lpm_type => "LPM_MULT",
        lpm_representation => "UNSIGNED",
        lpm_hint => "DEDICATED_MULTIPLIER_CIRCUITRY=YES, MAXIMIZE_SPEED=5",
        lpm_pipeline => 2
    )
    PORT MAP (
        dataa => sm0_uid207_prodDivPreNormProd_uid60_fpDivTest_a0,
        datab => sm0_uid207_prodDivPreNormProd_uid60_fpDivTest_b0,
        clken => VCC_q(0),
        aclr => sm0_uid207_prodDivPreNormProd_uid60_fpDivTest_reset,
        clock => clk,
        result => sm0_uid207_prodDivPreNormProd_uid60_fpDivTest_s1
    );
    sm0_uid207_prodDivPreNormProd_uid60_fpDivTest_q <= sm0_uid207_prodDivPreNormProd_uid60_fpDivTest_s1;

    -- lev1_a0_uid212_prodDivPreNormProd_uid60_fpDivTest(ADD,211)@8
    lev1_a0_uid212_prodDivPreNormProd_uid60_fpDivTest_a <= STD_LOGIC_VECTOR("0" & sm0_uid207_prodDivPreNormProd_uid60_fpDivTest_q);
    lev1_a0_uid212_prodDivPreNormProd_uid60_fpDivTest_b <= STD_LOGIC_VECTOR("0000000000000000000" & sm0_uid208_prodDivPreNormProd_uid60_fpDivTest_q);
    lev1_a0_uid212_prodDivPreNormProd_uid60_fpDivTest_o <= STD_LOGIC_VECTOR(UNSIGNED(lev1_a0_uid212_prodDivPreNormProd_uid60_fpDivTest_a) + UNSIGNED(lev1_a0_uid212_prodDivPreNormProd_uid60_fpDivTest_b));
    lev1_a0_uid212_prodDivPreNormProd_uid60_fpDivTest_q <= lev1_a0_uid212_prodDivPreNormProd_uid60_fpDivTest_o(36 downto 0);

    -- lev2_a0_uid217_prodDivPreNormProd_uid60_fpDivTest(ADD,216)@8
    lev2_a0_uid217_prodDivPreNormProd_uid60_fpDivTest_a <= STD_LOGIC_VECTOR("0" & lev1_a0_uid212_prodDivPreNormProd_uid60_fpDivTest_q);
    lev2_a0_uid217_prodDivPreNormProd_uid60_fpDivTest_b <= STD_LOGIC_VECTOR("0000000000000000000" & lev1_a1_uid216_prodDivPreNormProd_uid60_fpDivTest_q);
    lev2_a0_uid217_prodDivPreNormProd_uid60_fpDivTest_o <= STD_LOGIC_VECTOR(UNSIGNED(lev2_a0_uid217_prodDivPreNormProd_uid60_fpDivTest_a) + UNSIGNED(lev2_a0_uid217_prodDivPreNormProd_uid60_fpDivTest_b));
    lev2_a0_uid217_prodDivPreNormProd_uid60_fpDivTest_q <= lev2_a0_uid217_prodDivPreNormProd_uid60_fpDivTest_o(37 downto 0);

    -- lowRangeA_uid218_prodDivPreNormProd_uid60_fpDivTest_merged_bit_select(BITSELECT,334)@8
    lowRangeA_uid218_prodDivPreNormProd_uid60_fpDivTest_merged_bit_select_b <= lev2_a0_uid217_prodDivPreNormProd_uid60_fpDivTest_q(4 downto 0);
    lowRangeA_uid218_prodDivPreNormProd_uid60_fpDivTest_merged_bit_select_c <= lev2_a0_uid217_prodDivPreNormProd_uid60_fpDivTest_q(37 downto 5);

    -- lev3_a0_uid221_prodDivPreNormProd_uid60_fpDivTest(BITJOIN,220)@8
    lev3_a0_uid221_prodDivPreNormProd_uid60_fpDivTest_q <= lev3_a0high_uid220_prodDivPreNormProd_uid60_fpDivTest_q & lowRangeA_uid218_prodDivPreNormProd_uid60_fpDivTest_merged_bit_select_b;

    -- osig_uid222_prodDivPreNormProd_uid60_fpDivTest(BITSELECT,221)@8
    osig_uid222_prodDivPreNormProd_uid60_fpDivTest_in <= lev3_a0_uid221_prodDivPreNormProd_uid60_fpDivTest_q(35 downto 0);
    osig_uid222_prodDivPreNormProd_uid60_fpDivTest_b <= osig_uid222_prodDivPreNormProd_uid60_fpDivTest_in(35 downto 9);

    -- divValPreNormS_uid65_fpDivTest(BITSELECT,64)@8
    divValPreNormS_uid65_fpDivTest_b <= osig_uid222_prodDivPreNormProd_uid60_fpDivTest_b(26 downto 1);

    -- updatedY_uid16_fpDivTest(BITJOIN,15)@0
    updatedY_uid16_fpDivTest_q <= GND_q & paddingY_uid15_fpDivTest_q;

    -- fracYZero_uid15_fpDivTest(LOGICAL,16)@0 + 1
    fracYZero_uid15_fpDivTest_a <= STD_LOGIC_VECTOR("0" & fracY_uid13_fpDivTest_b);
    fracYZero_uid15_fpDivTest_qi <= "1" WHEN fracYZero_uid15_fpDivTest_a = updatedY_uid16_fpDivTest_q ELSE "0";
    fracYZero_uid15_fpDivTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => fracYZero_uid15_fpDivTest_qi, xout => fracYZero_uid15_fpDivTest_q, clk => clk, aclr => areset );

    -- redist14_fracYZero_uid15_fpDivTest_q_6(DELAY,349)
    redist14_fracYZero_uid15_fpDivTest_q_6 : dspba_delay
    GENERIC MAP ( width => 1, depth => 5, reset_kind => "ASYNC" )
    PORT MAP ( xin => fracYZero_uid15_fpDivTest_q, xout => redist14_fracYZero_uid15_fpDivTest_q_6_q, clk => clk, aclr => areset );

    -- fracYPostZ_uid56_fpDivTest(LOGICAL,55)@6 + 1
    fracYPostZ_uid56_fpDivTest_qi <= redist14_fracYZero_uid15_fpDivTest_q_6_q or invY_uid54_fpDivTest_merged_bit_select_c;
    fracYPostZ_uid56_fpDivTest_delay : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => fracYPostZ_uid56_fpDivTest_qi, xout => fracYPostZ_uid56_fpDivTest_q, clk => clk, aclr => areset );

    -- redist1_fracYPostZ_uid56_fpDivTest_q_2(DELAY,336)
    redist1_fracYPostZ_uid56_fpDivTest_q_2 : dspba_delay
    GENERIC MAP ( width => 1, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => fracYPostZ_uid56_fpDivTest_q, xout => redist1_fracYPostZ_uid56_fpDivTest_q_2_q, clk => clk, aclr => areset );

    -- divValPreNormTrunc_uid66_fpDivTest(MUX,65)@8
    divValPreNormTrunc_uid66_fpDivTest_s <= redist1_fracYPostZ_uid56_fpDivTest_q_2_q;
    divValPreNormTrunc_uid66_fpDivTest_combproc: PROCESS (divValPreNormTrunc_uid66_fpDivTest_s, divValPreNormS_uid65_fpDivTest_b, oFracXSE_mergedSignalTM_uid63_fpDivTest_q)
    BEGIN
        CASE (divValPreNormTrunc_uid66_fpDivTest_s) IS
            WHEN "0" => divValPreNormTrunc_uid66_fpDivTest_q <= divValPreNormS_uid65_fpDivTest_b;
            WHEN "1" => divValPreNormTrunc_uid66_fpDivTest_q <= oFracXSE_mergedSignalTM_uid63_fpDivTest_q;
            WHEN OTHERS => divValPreNormTrunc_uid66_fpDivTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- norm_uid67_fpDivTest(BITSELECT,66)@8
    norm_uid67_fpDivTest_b <= STD_LOGIC_VECTOR(divValPreNormTrunc_uid66_fpDivTest_q(25 downto 25));

    -- rndOp_uid75_fpDivTest(BITJOIN,74)@8
    rndOp_uid75_fpDivTest_q <= norm_uid67_fpDivTest_b & paddingY_uid15_fpDivTest_q & VCC_q;

    -- cstBiasM1_uid6_fpDivTest(CONSTANT,5)
    cstBiasM1_uid6_fpDivTest_q <= "01111110";

    -- expXmY_uid47_fpDivTest(SUB,46)@0 + 1
    expXmY_uid47_fpDivTest_a <= STD_LOGIC_VECTOR("0" & expX_uid9_fpDivTest_b);
    expXmY_uid47_fpDivTest_b <= STD_LOGIC_VECTOR("0" & expY_uid12_fpDivTest_b);
    expXmY_uid47_fpDivTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            expXmY_uid47_fpDivTest_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            expXmY_uid47_fpDivTest_o <= STD_LOGIC_VECTOR(UNSIGNED(expXmY_uid47_fpDivTest_a) - UNSIGNED(expXmY_uid47_fpDivTest_b));
        END IF;
    END PROCESS;
    expXmY_uid47_fpDivTest_q <= expXmY_uid47_fpDivTest_o(8 downto 0);

    -- redist6_expXmY_uid47_fpDivTest_q_8(DELAY,341)
    redist6_expXmY_uid47_fpDivTest_q_8 : dspba_delay
    GENERIC MAP ( width => 9, depth => 7, reset_kind => "ASYNC" )
    PORT MAP ( xin => expXmY_uid47_fpDivTest_q, xout => redist6_expXmY_uid47_fpDivTest_q_8_q, clk => clk, aclr => areset );

    -- expR_uid48_fpDivTest(ADD,47)@8
    expR_uid48_fpDivTest_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((10 downto 9 => redist6_expXmY_uid47_fpDivTest_q_8_q(8)) & redist6_expXmY_uid47_fpDivTest_q_8_q));
    expR_uid48_fpDivTest_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR("0" & "00" & cstBiasM1_uid6_fpDivTest_q));
    expR_uid48_fpDivTest_o <= STD_LOGIC_VECTOR(SIGNED(expR_uid48_fpDivTest_a) + SIGNED(expR_uid48_fpDivTest_b));
    expR_uid48_fpDivTest_q <= expR_uid48_fpDivTest_o(9 downto 0);

    -- divValPreNormHigh_uid68_fpDivTest(BITSELECT,67)@8
    divValPreNormHigh_uid68_fpDivTest_in <= divValPreNormTrunc_uid66_fpDivTest_q(24 downto 0);
    divValPreNormHigh_uid68_fpDivTest_b <= divValPreNormHigh_uid68_fpDivTest_in(24 downto 1);

    -- divValPreNormLow_uid69_fpDivTest(BITSELECT,68)@8
    divValPreNormLow_uid69_fpDivTest_in <= divValPreNormTrunc_uid66_fpDivTest_q(23 downto 0);
    divValPreNormLow_uid69_fpDivTest_b <= divValPreNormLow_uid69_fpDivTest_in(23 downto 0);

    -- normFracRnd_uid70_fpDivTest(MUX,69)@8
    normFracRnd_uid70_fpDivTest_s <= norm_uid67_fpDivTest_b;
    normFracRnd_uid70_fpDivTest_combproc: PROCESS (normFracRnd_uid70_fpDivTest_s, divValPreNormLow_uid69_fpDivTest_b, divValPreNormHigh_uid68_fpDivTest_b)
    BEGIN
        CASE (normFracRnd_uid70_fpDivTest_s) IS
            WHEN "0" => normFracRnd_uid70_fpDivTest_q <= divValPreNormLow_uid69_fpDivTest_b;
            WHEN "1" => normFracRnd_uid70_fpDivTest_q <= divValPreNormHigh_uid68_fpDivTest_b;
            WHEN OTHERS => normFracRnd_uid70_fpDivTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- expFracRnd_uid71_fpDivTest(BITJOIN,70)@8
    expFracRnd_uid71_fpDivTest_q <= expR_uid48_fpDivTest_q & normFracRnd_uid70_fpDivTest_q;

    -- expFracPostRnd_uid76_fpDivTest(ADD,75)@8
    expFracPostRnd_uid76_fpDivTest_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((35 downto 34 => expFracRnd_uid71_fpDivTest_q(33)) & expFracRnd_uid71_fpDivTest_q));
    expFracPostRnd_uid76_fpDivTest_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR("0" & "0000000000" & rndOp_uid75_fpDivTest_q));
    expFracPostRnd_uid76_fpDivTest_o <= STD_LOGIC_VECTOR(SIGNED(expFracPostRnd_uid76_fpDivTest_a) + SIGNED(expFracPostRnd_uid76_fpDivTest_b));
    expFracPostRnd_uid76_fpDivTest_q <= expFracPostRnd_uid76_fpDivTest_o(34 downto 0);

    -- excRPreExc_uid79_fpDivTest(BITSELECT,78)@8
    excRPreExc_uid79_fpDivTest_in <= expFracPostRnd_uid76_fpDivTest_q(31 downto 0);
    excRPreExc_uid79_fpDivTest_b <= excRPreExc_uid79_fpDivTest_in(31 downto 24);

    -- invExpXIsMax_uid43_fpDivTest(LOGICAL,42)@8
    invExpXIsMax_uid43_fpDivTest_q <= not (redist9_expXIsMax_uid38_fpDivTest_q_8_q);

    -- InvExpXIsZero_uid44_fpDivTest(LOGICAL,43)@8
    InvExpXIsZero_uid44_fpDivTest_q <= not (redist10_excZ_y_uid37_fpDivTest_q_8_q);

    -- excR_y_uid45_fpDivTest(LOGICAL,44)@8
    excR_y_uid45_fpDivTest_q <= InvExpXIsZero_uid44_fpDivTest_q and invExpXIsMax_uid43_fpDivTest_q;

    -- excXIYR_uid93_fpDivTest(LOGICAL,92)@8
    excXIYR_uid93_fpDivTest_q <= excI_x_uid27_fpDivTest_q and excR_y_uid45_fpDivTest_q;

    -- excXIYZ_uid92_fpDivTest(LOGICAL,91)@8
    excXIYZ_uid92_fpDivTest_q <= excI_x_uid27_fpDivTest_q and redist10_excZ_y_uid37_fpDivTest_q_8_q;

    -- expRExt_uid80_fpDivTest(BITSELECT,79)@8
    expRExt_uid80_fpDivTest_b <= STD_LOGIC_VECTOR(expFracPostRnd_uid76_fpDivTest_q(34 downto 24));

    -- expOvf_uid84_fpDivTest(COMPARE,83)@8
    expOvf_uid84_fpDivTest_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((12 downto 11 => expRExt_uid80_fpDivTest_b(10)) & expRExt_uid80_fpDivTest_b));
    expOvf_uid84_fpDivTest_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR("0" & "0000" & cstAllOWE_uid18_fpDivTest_q));
    expOvf_uid84_fpDivTest_o <= STD_LOGIC_VECTOR(SIGNED(expOvf_uid84_fpDivTest_a) - SIGNED(expOvf_uid84_fpDivTest_b));
    expOvf_uid84_fpDivTest_n(0) <= not (expOvf_uid84_fpDivTest_o(12));

    -- invExpXIsMax_uid29_fpDivTest(LOGICAL,28)@8
    invExpXIsMax_uid29_fpDivTest_q <= not (redist12_expXIsMax_uid24_fpDivTest_q_8_q);

    -- InvExpXIsZero_uid30_fpDivTest(LOGICAL,29)@8
    InvExpXIsZero_uid30_fpDivTest_q <= not (redist13_excZ_x_uid23_fpDivTest_q_8_q);

    -- excR_x_uid31_fpDivTest(LOGICAL,30)@8
    excR_x_uid31_fpDivTest_q <= InvExpXIsZero_uid30_fpDivTest_q and invExpXIsMax_uid29_fpDivTest_q;

    -- excXRYROvf_uid91_fpDivTest(LOGICAL,90)@8
    excXRYROvf_uid91_fpDivTest_q <= excR_x_uid31_fpDivTest_q and excR_y_uid45_fpDivTest_q and expOvf_uid84_fpDivTest_n;

    -- excXRYZ_uid90_fpDivTest(LOGICAL,89)@8
    excXRYZ_uid90_fpDivTest_q <= excR_x_uid31_fpDivTest_q and redist10_excZ_y_uid37_fpDivTest_q_8_q;

    -- excRInf_uid94_fpDivTest(LOGICAL,93)@8
    excRInf_uid94_fpDivTest_q <= excXRYZ_uid90_fpDivTest_q or excXRYROvf_uid91_fpDivTest_q or excXIYZ_uid92_fpDivTest_q or excXIYR_uid93_fpDivTest_q;

    -- xRegOrZero_uid87_fpDivTest(LOGICAL,86)@8
    xRegOrZero_uid87_fpDivTest_q <= excR_x_uid31_fpDivTest_q or redist13_excZ_x_uid23_fpDivTest_q_8_q;

    -- regOrZeroOverInf_uid88_fpDivTest(LOGICAL,87)@8
    regOrZeroOverInf_uid88_fpDivTest_q <= xRegOrZero_uid87_fpDivTest_q and excI_y_uid41_fpDivTest_q;

    -- expUdf_uid81_fpDivTest(COMPARE,80)@8
    expUdf_uid81_fpDivTest_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR("0" & "00000000000" & GND_q));
    expUdf_uid81_fpDivTest_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((12 downto 11 => expRExt_uid80_fpDivTest_b(10)) & expRExt_uid80_fpDivTest_b));
    expUdf_uid81_fpDivTest_o <= STD_LOGIC_VECTOR(SIGNED(expUdf_uid81_fpDivTest_a) - SIGNED(expUdf_uid81_fpDivTest_b));
    expUdf_uid81_fpDivTest_n(0) <= not (expUdf_uid81_fpDivTest_o(12));

    -- regOverRegWithUf_uid86_fpDivTest(LOGICAL,85)@8
    regOverRegWithUf_uid86_fpDivTest_q <= expUdf_uid81_fpDivTest_n and excR_x_uid31_fpDivTest_q and excR_y_uid45_fpDivTest_q;

    -- zeroOverReg_uid85_fpDivTest(LOGICAL,84)@8
    zeroOverReg_uid85_fpDivTest_q <= redist13_excZ_x_uid23_fpDivTest_q_8_q and excR_y_uid45_fpDivTest_q;

    -- excRZero_uid89_fpDivTest(LOGICAL,88)@8
    excRZero_uid89_fpDivTest_q <= zeroOverReg_uid85_fpDivTest_q or regOverRegWithUf_uid86_fpDivTest_q or regOrZeroOverInf_uid88_fpDivTest_q;

    -- concExc_uid98_fpDivTest(BITJOIN,97)@8
    concExc_uid98_fpDivTest_q <= excRNaN_uid97_fpDivTest_q & excRInf_uid94_fpDivTest_q & excRZero_uid89_fpDivTest_q;

    -- excREnc_uid99_fpDivTest(LOOKUP,98)@8
    excREnc_uid99_fpDivTest_combproc: PROCESS (concExc_uid98_fpDivTest_q)
    BEGIN
        -- Begin reserved scope level
        CASE (concExc_uid98_fpDivTest_q) IS
            WHEN "000" => excREnc_uid99_fpDivTest_q <= "01";
            WHEN "001" => excREnc_uid99_fpDivTest_q <= "00";
            WHEN "010" => excREnc_uid99_fpDivTest_q <= "10";
            WHEN "011" => excREnc_uid99_fpDivTest_q <= "00";
            WHEN "100" => excREnc_uid99_fpDivTest_q <= "11";
            WHEN "101" => excREnc_uid99_fpDivTest_q <= "00";
            WHEN "110" => excREnc_uid99_fpDivTest_q <= "00";
            WHEN "111" => excREnc_uid99_fpDivTest_q <= "00";
            WHEN OTHERS => -- unreachable
                           excREnc_uid99_fpDivTest_q <= (others => '-');
        END CASE;
        -- End reserved scope level
    END PROCESS;

    -- expRPostExc_uid107_fpDivTest(MUX,106)@8
    expRPostExc_uid107_fpDivTest_s <= excREnc_uid99_fpDivTest_q;
    expRPostExc_uid107_fpDivTest_combproc: PROCESS (expRPostExc_uid107_fpDivTest_s, cstAllZWE_uid20_fpDivTest_q, excRPreExc_uid79_fpDivTest_b, cstAllOWE_uid18_fpDivTest_q)
    BEGIN
        CASE (expRPostExc_uid107_fpDivTest_s) IS
            WHEN "00" => expRPostExc_uid107_fpDivTest_q <= cstAllZWE_uid20_fpDivTest_q;
            WHEN "01" => expRPostExc_uid107_fpDivTest_q <= excRPreExc_uid79_fpDivTest_b;
            WHEN "10" => expRPostExc_uid107_fpDivTest_q <= cstAllOWE_uid18_fpDivTest_q;
            WHEN "11" => expRPostExc_uid107_fpDivTest_q <= cstAllOWE_uid18_fpDivTest_q;
            WHEN OTHERS => expRPostExc_uid107_fpDivTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- oneFracRPostExc2_uid100_fpDivTest(CONSTANT,99)
    oneFracRPostExc2_uid100_fpDivTest_q <= "00000000000000000000001";

    -- fracRPreExc_uid78_fpDivTest(BITSELECT,77)@8
    fracRPreExc_uid78_fpDivTest_in <= expFracPostRnd_uid76_fpDivTest_q(23 downto 0);
    fracRPreExc_uid78_fpDivTest_b <= fracRPreExc_uid78_fpDivTest_in(23 downto 1);

    -- fracRPostExc_uid103_fpDivTest(MUX,102)@8
    fracRPostExc_uid103_fpDivTest_s <= excREnc_uid99_fpDivTest_q;
    fracRPostExc_uid103_fpDivTest_combproc: PROCESS (fracRPostExc_uid103_fpDivTest_s, paddingY_uid15_fpDivTest_q, fracRPreExc_uid78_fpDivTest_b, oneFracRPostExc2_uid100_fpDivTest_q)
    BEGIN
        CASE (fracRPostExc_uid103_fpDivTest_s) IS
            WHEN "00" => fracRPostExc_uid103_fpDivTest_q <= paddingY_uid15_fpDivTest_q;
            WHEN "01" => fracRPostExc_uid103_fpDivTest_q <= fracRPreExc_uid78_fpDivTest_b;
            WHEN "10" => fracRPostExc_uid103_fpDivTest_q <= paddingY_uid15_fpDivTest_q;
            WHEN "11" => fracRPostExc_uid103_fpDivTest_q <= oneFracRPostExc2_uid100_fpDivTest_q;
            WHEN OTHERS => fracRPostExc_uid103_fpDivTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- divR_uid110_fpDivTest(BITJOIN,109)@8
    divR_uid110_fpDivTest_q <= sRPostExc_uid109_fpDivTest_q & expRPostExc_uid107_fpDivTest_q & fracRPostExc_uid103_fpDivTest_q;

    -- xOut(GPOUT,4)@8
    q <= divR_uid110_fpDivTest_q;

END normal;
