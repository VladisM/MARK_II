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

-- VHDL created from fp_addsub
-- VHDL created on Thu Feb 15 14:11:38 2018


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

entity fp_addsub is
    port (
        a : in std_logic_vector(31 downto 0);  -- float32_m23
        b : in std_logic_vector(31 downto 0);  -- float32_m23
        q : out std_logic_vector(31 downto 0);  -- float32_m23
        s : out std_logic_vector(31 downto 0);  -- float32_m23
        clk : in std_logic;
        areset : in std_logic
    );
end fp_addsub;

architecture normal of fp_addsub is

    attribute altera_attribute : string;
    attribute altera_attribute of normal : architecture is "-name AUTO_SHIFT_REGISTER_RECOGNITION OFF; -name PHYSICAL_SYNTHESIS_REGISTER_DUPLICATION ON; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 10037; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 15400; -name MESSAGE_DISABLE 14130; -name MESSAGE_DISABLE 10036; -name MESSAGE_DISABLE 12020; -name MESSAGE_DISABLE 12030; -name MESSAGE_DISABLE 12010; -name MESSAGE_DISABLE 12110; -name MESSAGE_DISABLE 14320; -name MESSAGE_DISABLE 13410; -name MESSAGE_DISABLE 113007";
    
    signal GND_q : STD_LOGIC_VECTOR (0 downto 0);
    signal VCC_q : STD_LOGIC_VECTOR (0 downto 0);
    signal expFracX_uid6_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (30 downto 0);
    signal expFracY_uid7_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (30 downto 0);
    signal xGTEy_uid8_fpFusedAddSubTest_a : STD_LOGIC_VECTOR (32 downto 0);
    signal xGTEy_uid8_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (32 downto 0);
    signal xGTEy_uid8_fpFusedAddSubTest_o : STD_LOGIC_VECTOR (32 downto 0);
    signal xGTEy_uid8_fpFusedAddSubTest_n : STD_LOGIC_VECTOR (0 downto 0);
    signal siga_uid9_fpFusedAddSubTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal siga_uid9_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (31 downto 0);
    signal sigb_uid10_fpFusedAddSubTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal sigb_uid10_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (31 downto 0);
    signal cstAllOWE_uid11_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (7 downto 0);
    signal cstZeroWF_uid12_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (22 downto 0);
    signal cstAllZWE_uid13_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (7 downto 0);
    signal exp_siga_uid14_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (30 downto 0);
    signal exp_siga_uid14_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (7 downto 0);
    signal frac_siga_uid15_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (22 downto 0);
    signal frac_siga_uid15_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (22 downto 0);
    signal excZ_siga_uid9_uid16_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal expXIsMax_uid17_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal fracXIsZero_uid18_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal fracXIsNotZero_uid19_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excI_siga_uid20_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excN_siga_uid21_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal invExpXIsMax_uid22_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal InvExpXIsZero_uid23_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excR_siga_uid24_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal exp_sigb_uid28_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (30 downto 0);
    signal exp_sigb_uid28_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (7 downto 0);
    signal frac_sigb_uid29_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (22 downto 0);
    signal frac_sigb_uid29_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (22 downto 0);
    signal excZ_sigb_uid10_uid30_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal expXIsMax_uid31_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal fracXIsZero_uid32_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal fracXIsNotZero_uid33_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excI_sigb_uid34_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excN_sigb_uid35_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal invExpXIsMax_uid36_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal InvExpXIsZero_uid37_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excR_sigb_uid38_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal sigA_uid43_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal sigB_uid44_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal effSub_uid45_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal expAmExpB_uid48_fpFusedAddSubTest_a : STD_LOGIC_VECTOR (8 downto 0);
    signal expAmExpB_uid48_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (8 downto 0);
    signal expAmExpB_uid48_fpFusedAddSubTest_o : STD_LOGIC_VECTOR (8 downto 0);
    signal expAmExpB_uid48_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (8 downto 0);
    signal cWFP1_uid49_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (4 downto 0);
    signal shiftedOut_uid51_fpFusedAddSubTest_a : STD_LOGIC_VECTOR (10 downto 0);
    signal shiftedOut_uid51_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (10 downto 0);
    signal shiftedOut_uid51_fpFusedAddSubTest_o : STD_LOGIC_VECTOR (10 downto 0);
    signal shiftedOut_uid51_fpFusedAddSubTest_c : STD_LOGIC_VECTOR (0 downto 0);
    signal shiftOutConst_uid52_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (4 downto 0);
    signal expAmExpBShiftRange_uid53_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (4 downto 0);
    signal expAmExpBShiftRange_uid53_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (4 downto 0);
    signal shiftValue_uid54_fpFusedAddSubTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal shiftValue_uid54_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (4 downto 0);
    signal oFracB_uid56_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (23 downto 0);
    signal oFracA_uid57_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (23 downto 0);
    signal oFracBR_uid58_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (24 downto 0);
    signal fracAOp_uid61_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (24 downto 0);
    signal fracBOp_uid62_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (26 downto 0);
    signal fracResSub_uid63_fpFusedAddSubTest_a : STD_LOGIC_VECTOR (27 downto 0);
    signal fracResSub_uid63_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (27 downto 0);
    signal fracResSub_uid63_fpFusedAddSubTest_o : STD_LOGIC_VECTOR (27 downto 0);
    signal fracResSub_uid63_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (27 downto 0);
    signal fracResAdd_uid64_fpFusedAddSubTest_a : STD_LOGIC_VECTOR (27 downto 0);
    signal fracResAdd_uid64_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (27 downto 0);
    signal fracResAdd_uid64_fpFusedAddSubTest_o : STD_LOGIC_VECTOR (27 downto 0);
    signal fracResAdd_uid64_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (27 downto 0);
    signal fracResSubNoSignExt_uid65_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (25 downto 0);
    signal fracResSubNoSignExt_uid65_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (25 downto 0);
    signal fracResAddNoSignExt_uid66_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (25 downto 0);
    signal fracResAddNoSignExt_uid66_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (25 downto 0);
    signal cAmA_uid71_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (4 downto 0);
    signal aMinusA_uid72_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal expInc_uid73_fpFusedAddSubTest_a : STD_LOGIC_VECTOR (8 downto 0);
    signal expInc_uid73_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (8 downto 0);
    signal expInc_uid73_fpFusedAddSubTest_o : STD_LOGIC_VECTOR (8 downto 0);
    signal expInc_uid73_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (8 downto 0);
    signal expPostNormSub_uid74_fpFusedAddSubTest_a : STD_LOGIC_VECTOR (9 downto 0);
    signal expPostNormSub_uid74_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (9 downto 0);
    signal expPostNormSub_uid74_fpFusedAddSubTest_o : STD_LOGIC_VECTOR (9 downto 0);
    signal expPostNormSub_uid74_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (9 downto 0);
    signal expPostNormAdd_uid75_fpFusedAddSubTest_a : STD_LOGIC_VECTOR (9 downto 0);
    signal expPostNormAdd_uid75_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (9 downto 0);
    signal expPostNormAdd_uid75_fpFusedAddSubTest_o : STD_LOGIC_VECTOR (9 downto 0);
    signal expPostNormAdd_uid75_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (9 downto 0);
    signal fracPostNormSubRndRange_uid76_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (24 downto 0);
    signal fracPostNormSubRndRange_uid76_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (23 downto 0);
    signal expFracRSub_uid77_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (33 downto 0);
    signal fracPostNormAddRndRange_uid78_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (24 downto 0);
    signal fracPostNormAddRndRange_uid78_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (23 downto 0);
    signal expFracRAdd_uid79_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (33 downto 0);
    signal wEP2AllOwE_uid80_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (9 downto 0);
    signal rndExp_uid81_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (9 downto 0);
    signal rOvf_uid82_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal signedExp_uid83_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (9 downto 0);
    signal rUdf_uid84_fpFusedAddSubTest_a : STD_LOGIC_VECTOR (11 downto 0);
    signal rUdf_uid84_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (11 downto 0);
    signal rUdf_uid84_fpFusedAddSubTest_o : STD_LOGIC_VECTOR (11 downto 0);
    signal rUdf_uid84_fpFusedAddSubTest_n : STD_LOGIC_VECTOR (0 downto 0);
    signal fracRPreExcSub_uid85_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (23 downto 0);
    signal fracRPreExcSub_uid85_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (22 downto 0);
    signal expRPreExcSub_uid86_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (31 downto 0);
    signal expRPreExcSub_uid86_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (7 downto 0);
    signal fracRPreExcAdd_uid88_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (23 downto 0);
    signal fracRPreExcAdd_uid88_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (22 downto 0);
    signal expRPreExcAdd_uid89_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (31 downto 0);
    signal expRPreExcAdd_uid89_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (7 downto 0);
    signal regInputs_uid91_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excRZeroVInC_uid92_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (5 downto 0);
    signal excRZeroAdd_uid93_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excRZeroSub_uid94_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal regInAndOvf_uid95_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal oneIsInf_uid96_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal oneIsInfOrZero_uid97_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal addIsAlsoInf_uid98_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excRInfVInC_uid99_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (5 downto 0);
    signal excRInfAdd_uid100_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excRInfAddFull_uid101_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excRInfSub_uid102_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excRInfSubFull_uid103_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal infMinf_uid104_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excRNaNA_uid105_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal invEffSub_uid106_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal infPinfForSub_uid107_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal excRNaNS_uid108_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal concExcSub_uid109_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (2 downto 0);
    signal concExcAdd_uid110_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (2 downto 0);
    signal excREncSub_uid111_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (1 downto 0);
    signal excREncAdd_uid112_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (1 downto 0);
    signal fracRPreExcAddition_uid113_fpFusedAddSubTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal fracRPreExcAddition_uid113_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (22 downto 0);
    signal expRPreExcAddition_uid114_fpFusedAddSubTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal expRPreExcAddition_uid114_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (7 downto 0);
    signal fracRPreExcSubtraction_uid115_fpFusedAddSubTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal fracRPreExcSubtraction_uid115_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (22 downto 0);
    signal expRPreExcSubtraction_uid116_fpFusedAddSubTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal expRPreExcSubtraction_uid116_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (7 downto 0);
    signal oneFracRPostExc2_uid117_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (22 downto 0);
    signal fracRPostExcAdd_uid120_fpFusedAddSubTest_s : STD_LOGIC_VECTOR (1 downto 0);
    signal fracRPostExcAdd_uid120_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (22 downto 0);
    signal expRPostExcAdd_uid124_fpFusedAddSubTest_s : STD_LOGIC_VECTOR (1 downto 0);
    signal expRPostExcAdd_uid124_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (7 downto 0);
    signal invXGTEy_uid125_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal invSigA_uid126_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal signInputsZeroSwap_uid127_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal invSignInputsZeroSwap_uid128_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal invSigB_uid129_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal signInputsZeroNoSwap_uid130_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal invSignInputsZeroNoSwap_uid131_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal aMa_uid132_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal invAMA_uid133_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal invExcRNaNA_uid134_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal signRPostExc_uid135_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal RSum_uid136_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (31 downto 0);
    signal fracRPostExcSub_uid140_fpFusedAddSubTest_s : STD_LOGIC_VECTOR (1 downto 0);
    signal fracRPostExcSub_uid140_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (22 downto 0);
    signal expRPostExcSub_uid144_fpFusedAddSubTest_s : STD_LOGIC_VECTOR (1 downto 0);
    signal expRPostExcSub_uid144_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (7 downto 0);
    signal positiveExc_uid145_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal invPositiveExc_uid146_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal signInputsZeroForSub_uid147_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal invSignInputsZeroForSub_uid148_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal sigY_uid149_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal invSigY_uid150_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal yGTxYPos_uid152_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal sigX_uid153_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal xGTyXNeg_uid154_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal signRPostExcSub0_uid155_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal invExcRNaNS_uid156_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal signRPostExcSub_uid157_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal RDiff_uid158_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (31 downto 0);
    signal zs_uid161_lzCountValSub_uid67_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (15 downto 0);
    signal rVStage_uid162_lzCountValSub_uid67_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (15 downto 0);
    signal vCount_uid163_lzCountValSub_uid67_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal mO_uid164_lzCountValSub_uid67_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (5 downto 0);
    signal vStage_uid165_lzCountValSub_uid67_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (9 downto 0);
    signal vStage_uid165_lzCountValSub_uid67_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (9 downto 0);
    signal cStage_uid166_lzCountValSub_uid67_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (15 downto 0);
    signal vStagei_uid168_lzCountValSub_uid67_fpFusedAddSubTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid168_lzCountValSub_uid67_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (15 downto 0);
    signal vCount_uid171_lzCountValSub_uid67_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid174_lzCountValSub_uid67_fpFusedAddSubTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid174_lzCountValSub_uid67_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (7 downto 0);
    signal zs_uid175_lzCountValSub_uid67_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (3 downto 0);
    signal vCount_uid177_lzCountValSub_uid67_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid180_lzCountValSub_uid67_fpFusedAddSubTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid180_lzCountValSub_uid67_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (3 downto 0);
    signal zs_uid181_lzCountValSub_uid67_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (1 downto 0);
    signal vCount_uid183_lzCountValSub_uid67_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid186_lzCountValSub_uid67_fpFusedAddSubTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid186_lzCountValSub_uid67_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (1 downto 0);
    signal rVStage_uid188_lzCountValSub_uid67_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal vCount_uid189_lzCountValSub_uid67_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal r_uid190_lzCountValSub_uid67_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (4 downto 0);
    signal rVStage_uid193_lzCountValAdd_uid69_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (15 downto 0);
    signal vCount_uid194_lzCountValAdd_uid69_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal vStage_uid196_lzCountValAdd_uid69_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (9 downto 0);
    signal vStage_uid196_lzCountValAdd_uid69_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (9 downto 0);
    signal cStage_uid197_lzCountValAdd_uid69_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (15 downto 0);
    signal vStagei_uid199_lzCountValAdd_uid69_fpFusedAddSubTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid199_lzCountValAdd_uid69_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (15 downto 0);
    signal vCount_uid202_lzCountValAdd_uid69_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid205_lzCountValAdd_uid69_fpFusedAddSubTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid205_lzCountValAdd_uid69_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (7 downto 0);
    signal vCount_uid208_lzCountValAdd_uid69_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid211_lzCountValAdd_uid69_fpFusedAddSubTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid211_lzCountValAdd_uid69_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (3 downto 0);
    signal vCount_uid214_lzCountValAdd_uid69_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid217_lzCountValAdd_uid69_fpFusedAddSubTest_s : STD_LOGIC_VECTOR (0 downto 0);
    signal vStagei_uid217_lzCountValAdd_uid69_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (1 downto 0);
    signal rVStage_uid219_lzCountValAdd_uid69_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal vCount_uid220_lzCountValAdd_uid69_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (0 downto 0);
    signal r_uid221_lzCountValAdd_uid69_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (4 downto 0);
    signal rightShiftStage0Idx1Rng4_uid225_alignmentShifter_uid59_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (20 downto 0);
    signal rightShiftStage0Idx1_uid227_alignmentShifter_uid59_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (24 downto 0);
    signal rightShiftStage0Idx2Rng8_uid228_alignmentShifter_uid59_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (16 downto 0);
    signal rightShiftStage0Idx2_uid230_alignmentShifter_uid59_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (24 downto 0);
    signal rightShiftStage0Idx3Rng12_uid231_alignmentShifter_uid59_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (12 downto 0);
    signal rightShiftStage0Idx3Pad12_uid232_alignmentShifter_uid59_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (11 downto 0);
    signal rightShiftStage0Idx3_uid233_alignmentShifter_uid59_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (24 downto 0);
    signal rightShiftStage0Idx4Rng16_uid234_alignmentShifter_uid59_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (8 downto 0);
    signal rightShiftStage0Idx4_uid236_alignmentShifter_uid59_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (24 downto 0);
    signal rightShiftStage0Idx5Rng20_uid237_alignmentShifter_uid59_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (4 downto 0);
    signal rightShiftStage0Idx5Pad20_uid238_alignmentShifter_uid59_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (19 downto 0);
    signal rightShiftStage0Idx5_uid239_alignmentShifter_uid59_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (24 downto 0);
    signal rightShiftStage0Idx6Rng24_uid240_alignmentShifter_uid59_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (0 downto 0);
    signal rightShiftStage0Idx6Pad24_uid241_alignmentShifter_uid59_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (23 downto 0);
    signal rightShiftStage0Idx6_uid242_alignmentShifter_uid59_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (24 downto 0);
    signal rightShiftStage0Idx7_uid243_alignmentShifter_uid59_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (24 downto 0);
    signal rightShiftStage1Idx1Rng1_uid246_alignmentShifter_uid59_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (23 downto 0);
    signal rightShiftStage1Idx1_uid248_alignmentShifter_uid59_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (24 downto 0);
    signal rightShiftStage1Idx2Rng2_uid249_alignmentShifter_uid59_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (22 downto 0);
    signal rightShiftStage1Idx2_uid251_alignmentShifter_uid59_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (24 downto 0);
    signal rightShiftStage1Idx3Rng3_uid252_alignmentShifter_uid59_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (21 downto 0);
    signal rightShiftStage1Idx3Pad3_uid253_alignmentShifter_uid59_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (2 downto 0);
    signal rightShiftStage1Idx3_uid254_alignmentShifter_uid59_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (24 downto 0);
    signal rightShiftStage1_uid256_alignmentShifter_uid59_fpFusedAddSubTest_s : STD_LOGIC_VECTOR (1 downto 0);
    signal rightShiftStage1_uid256_alignmentShifter_uid59_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (24 downto 0);
    signal leftShiftStage0Idx1Rng4_uid261_fracPostNormSub_uid68_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (21 downto 0);
    signal leftShiftStage0Idx1Rng4_uid261_fracPostNormSub_uid68_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (21 downto 0);
    signal leftShiftStage0Idx1_uid262_fracPostNormSub_uid68_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (25 downto 0);
    signal leftShiftStage0Idx2Rng8_uid264_fracPostNormSub_uid68_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (17 downto 0);
    signal leftShiftStage0Idx2Rng8_uid264_fracPostNormSub_uid68_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (17 downto 0);
    signal leftShiftStage0Idx2_uid265_fracPostNormSub_uid68_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (25 downto 0);
    signal leftShiftStage0Idx3Rng12_uid267_fracPostNormSub_uid68_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (13 downto 0);
    signal leftShiftStage0Idx3Rng12_uid267_fracPostNormSub_uid68_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (13 downto 0);
    signal leftShiftStage0Idx3_uid268_fracPostNormSub_uid68_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (25 downto 0);
    signal leftShiftStage0Idx4_uid271_fracPostNormSub_uid68_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (25 downto 0);
    signal leftShiftStage0Idx5Rng20_uid273_fracPostNormSub_uid68_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (5 downto 0);
    signal leftShiftStage0Idx5Rng20_uid273_fracPostNormSub_uid68_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (5 downto 0);
    signal leftShiftStage0Idx5_uid274_fracPostNormSub_uid68_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (25 downto 0);
    signal leftShiftStage0Idx6Rng24_uid276_fracPostNormSub_uid68_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (1 downto 0);
    signal leftShiftStage0Idx6Rng24_uid276_fracPostNormSub_uid68_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (1 downto 0);
    signal leftShiftStage0Idx6_uid277_fracPostNormSub_uid68_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (25 downto 0);
    signal leftShiftStage0Idx7_uid278_fracPostNormSub_uid68_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (25 downto 0);
    signal leftShiftStage1Idx1Rng1_uid282_fracPostNormSub_uid68_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (24 downto 0);
    signal leftShiftStage1Idx1Rng1_uid282_fracPostNormSub_uid68_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (24 downto 0);
    signal leftShiftStage1Idx1_uid283_fracPostNormSub_uid68_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (25 downto 0);
    signal leftShiftStage1Idx2Rng2_uid285_fracPostNormSub_uid68_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (23 downto 0);
    signal leftShiftStage1Idx2Rng2_uid285_fracPostNormSub_uid68_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (23 downto 0);
    signal leftShiftStage1Idx2_uid286_fracPostNormSub_uid68_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (25 downto 0);
    signal leftShiftStage1Idx3Rng3_uid288_fracPostNormSub_uid68_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (22 downto 0);
    signal leftShiftStage1Idx3Rng3_uid288_fracPostNormSub_uid68_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (22 downto 0);
    signal leftShiftStage1Idx3_uid289_fracPostNormSub_uid68_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (25 downto 0);
    signal leftShiftStage1_uid291_fracPostNormSub_uid68_fpFusedAddSubTest_s : STD_LOGIC_VECTOR (1 downto 0);
    signal leftShiftStage1_uid291_fracPostNormSub_uid68_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (25 downto 0);
    signal leftShiftStage0Idx1Rng4_uid296_fracPostNormAdd_uid70_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (21 downto 0);
    signal leftShiftStage0Idx1Rng4_uid296_fracPostNormAdd_uid70_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (21 downto 0);
    signal leftShiftStage0Idx1_uid297_fracPostNormAdd_uid70_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (25 downto 0);
    signal leftShiftStage0Idx2Rng8_uid299_fracPostNormAdd_uid70_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (17 downto 0);
    signal leftShiftStage0Idx2Rng8_uid299_fracPostNormAdd_uid70_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (17 downto 0);
    signal leftShiftStage0Idx2_uid300_fracPostNormAdd_uid70_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (25 downto 0);
    signal leftShiftStage0Idx3Rng12_uid302_fracPostNormAdd_uid70_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (13 downto 0);
    signal leftShiftStage0Idx3Rng12_uid302_fracPostNormAdd_uid70_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (13 downto 0);
    signal leftShiftStage0Idx3_uid303_fracPostNormAdd_uid70_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (25 downto 0);
    signal leftShiftStage0Idx4_uid306_fracPostNormAdd_uid70_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (25 downto 0);
    signal leftShiftStage0Idx5Rng20_uid308_fracPostNormAdd_uid70_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (5 downto 0);
    signal leftShiftStage0Idx5Rng20_uid308_fracPostNormAdd_uid70_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (5 downto 0);
    signal leftShiftStage0Idx5_uid309_fracPostNormAdd_uid70_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (25 downto 0);
    signal leftShiftStage0Idx6Rng24_uid311_fracPostNormAdd_uid70_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (1 downto 0);
    signal leftShiftStage0Idx6Rng24_uid311_fracPostNormAdd_uid70_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (1 downto 0);
    signal leftShiftStage0Idx6_uid312_fracPostNormAdd_uid70_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (25 downto 0);
    signal leftShiftStage1Idx1Rng1_uid317_fracPostNormAdd_uid70_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (24 downto 0);
    signal leftShiftStage1Idx1Rng1_uid317_fracPostNormAdd_uid70_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (24 downto 0);
    signal leftShiftStage1Idx1_uid318_fracPostNormAdd_uid70_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (25 downto 0);
    signal leftShiftStage1Idx2Rng2_uid320_fracPostNormAdd_uid70_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (23 downto 0);
    signal leftShiftStage1Idx2Rng2_uid320_fracPostNormAdd_uid70_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (23 downto 0);
    signal leftShiftStage1Idx2_uid321_fracPostNormAdd_uid70_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (25 downto 0);
    signal leftShiftStage1Idx3Rng3_uid323_fracPostNormAdd_uid70_fpFusedAddSubTest_in : STD_LOGIC_VECTOR (22 downto 0);
    signal leftShiftStage1Idx3Rng3_uid323_fracPostNormAdd_uid70_fpFusedAddSubTest_b : STD_LOGIC_VECTOR (22 downto 0);
    signal leftShiftStage1Idx3_uid324_fracPostNormAdd_uid70_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (25 downto 0);
    signal leftShiftStage1_uid326_fracPostNormAdd_uid70_fpFusedAddSubTest_s : STD_LOGIC_VECTOR (1 downto 0);
    signal leftShiftStage1_uid326_fracPostNormAdd_uid70_fpFusedAddSubTest_q : STD_LOGIC_VECTOR (25 downto 0);
    signal rightShiftStage0_uid245_alignmentShifter_uid59_fpFusedAddSubTest_msplit_0_s : STD_LOGIC_VECTOR (1 downto 0);
    signal rightShiftStage0_uid245_alignmentShifter_uid59_fpFusedAddSubTest_msplit_0_q : STD_LOGIC_VECTOR (24 downto 0);
    signal rightShiftStage0_uid245_alignmentShifter_uid59_fpFusedAddSubTest_msplit_1_s : STD_LOGIC_VECTOR (1 downto 0);
    signal rightShiftStage0_uid245_alignmentShifter_uid59_fpFusedAddSubTest_msplit_1_q : STD_LOGIC_VECTOR (24 downto 0);
    signal rightShiftStage0_uid245_alignmentShifter_uid59_fpFusedAddSubTest_mfinal_s : STD_LOGIC_VECTOR (0 downto 0);
    signal rightShiftStage0_uid245_alignmentShifter_uid59_fpFusedAddSubTest_mfinal_q : STD_LOGIC_VECTOR (24 downto 0);
    signal leftShiftStage0_uid280_fracPostNormSub_uid68_fpFusedAddSubTest_msplit_0_s : STD_LOGIC_VECTOR (1 downto 0);
    signal leftShiftStage0_uid280_fracPostNormSub_uid68_fpFusedAddSubTest_msplit_0_q : STD_LOGIC_VECTOR (25 downto 0);
    signal leftShiftStage0_uid280_fracPostNormSub_uid68_fpFusedAddSubTest_msplit_1_s : STD_LOGIC_VECTOR (1 downto 0);
    signal leftShiftStage0_uid280_fracPostNormSub_uid68_fpFusedAddSubTest_msplit_1_q : STD_LOGIC_VECTOR (25 downto 0);
    signal leftShiftStage0_uid280_fracPostNormSub_uid68_fpFusedAddSubTest_mfinal_s : STD_LOGIC_VECTOR (0 downto 0);
    signal leftShiftStage0_uid280_fracPostNormSub_uid68_fpFusedAddSubTest_mfinal_q : STD_LOGIC_VECTOR (25 downto 0);
    signal leftShiftStage0_uid315_fracPostNormAdd_uid70_fpFusedAddSubTest_msplit_0_s : STD_LOGIC_VECTOR (1 downto 0);
    signal leftShiftStage0_uid315_fracPostNormAdd_uid70_fpFusedAddSubTest_msplit_0_q : STD_LOGIC_VECTOR (25 downto 0);
    signal leftShiftStage0_uid315_fracPostNormAdd_uid70_fpFusedAddSubTest_msplit_1_s : STD_LOGIC_VECTOR (1 downto 0);
    signal leftShiftStage0_uid315_fracPostNormAdd_uid70_fpFusedAddSubTest_msplit_1_q : STD_LOGIC_VECTOR (25 downto 0);
    signal leftShiftStage0_uid315_fracPostNormAdd_uid70_fpFusedAddSubTest_mfinal_s : STD_LOGIC_VECTOR (0 downto 0);
    signal leftShiftStage0_uid315_fracPostNormAdd_uid70_fpFusedAddSubTest_mfinal_q : STD_LOGIC_VECTOR (25 downto 0);
    signal rightShiftStageSel4Dto2_uid244_alignmentShifter_uid59_fpFusedAddSubTest_merged_bit_select_b : STD_LOGIC_VECTOR (2 downto 0);
    signal rightShiftStageSel4Dto2_uid244_alignmentShifter_uid59_fpFusedAddSubTest_merged_bit_select_c : STD_LOGIC_VECTOR (1 downto 0);
    signal rVStage_uid170_lzCountValSub_uid67_fpFusedAddSubTest_merged_bit_select_b : STD_LOGIC_VECTOR (7 downto 0);
    signal rVStage_uid170_lzCountValSub_uid67_fpFusedAddSubTest_merged_bit_select_c : STD_LOGIC_VECTOR (7 downto 0);
    signal rVStage_uid176_lzCountValSub_uid67_fpFusedAddSubTest_merged_bit_select_b : STD_LOGIC_VECTOR (3 downto 0);
    signal rVStage_uid176_lzCountValSub_uid67_fpFusedAddSubTest_merged_bit_select_c : STD_LOGIC_VECTOR (3 downto 0);
    signal rVStage_uid182_lzCountValSub_uid67_fpFusedAddSubTest_merged_bit_select_b : STD_LOGIC_VECTOR (1 downto 0);
    signal rVStage_uid182_lzCountValSub_uid67_fpFusedAddSubTest_merged_bit_select_c : STD_LOGIC_VECTOR (1 downto 0);
    signal leftShiftStageSel4Dto2_uid279_fracPostNormSub_uid68_fpFusedAddSubTest_merged_bit_select_b : STD_LOGIC_VECTOR (2 downto 0);
    signal leftShiftStageSel4Dto2_uid279_fracPostNormSub_uid68_fpFusedAddSubTest_merged_bit_select_c : STD_LOGIC_VECTOR (1 downto 0);
    signal rVStage_uid201_lzCountValAdd_uid69_fpFusedAddSubTest_merged_bit_select_b : STD_LOGIC_VECTOR (7 downto 0);
    signal rVStage_uid201_lzCountValAdd_uid69_fpFusedAddSubTest_merged_bit_select_c : STD_LOGIC_VECTOR (7 downto 0);
    signal rVStage_uid207_lzCountValAdd_uid69_fpFusedAddSubTest_merged_bit_select_b : STD_LOGIC_VECTOR (3 downto 0);
    signal rVStage_uid207_lzCountValAdd_uid69_fpFusedAddSubTest_merged_bit_select_c : STD_LOGIC_VECTOR (3 downto 0);
    signal rVStage_uid213_lzCountValAdd_uid69_fpFusedAddSubTest_merged_bit_select_b : STD_LOGIC_VECTOR (1 downto 0);
    signal rVStage_uid213_lzCountValAdd_uid69_fpFusedAddSubTest_merged_bit_select_c : STD_LOGIC_VECTOR (1 downto 0);
    signal leftShiftStageSel4Dto2_uid314_fracPostNormAdd_uid70_fpFusedAddSubTest_merged_bit_select_b : STD_LOGIC_VECTOR (2 downto 0);
    signal leftShiftStageSel4Dto2_uid314_fracPostNormAdd_uid70_fpFusedAddSubTest_merged_bit_select_c : STD_LOGIC_VECTOR (1 downto 0);
    signal rightShiftStage0_uid245_alignmentShifter_uid59_fpFusedAddSubTest_selLSBs_merged_bit_select_b : STD_LOGIC_VECTOR (1 downto 0);
    signal rightShiftStage0_uid245_alignmentShifter_uid59_fpFusedAddSubTest_selLSBs_merged_bit_select_c : STD_LOGIC_VECTOR (0 downto 0);
    signal leftShiftStage0_uid280_fracPostNormSub_uid68_fpFusedAddSubTest_selLSBs_merged_bit_select_b : STD_LOGIC_VECTOR (1 downto 0);
    signal leftShiftStage0_uid280_fracPostNormSub_uid68_fpFusedAddSubTest_selLSBs_merged_bit_select_c : STD_LOGIC_VECTOR (0 downto 0);
    signal leftShiftStage0_uid315_fracPostNormAdd_uid70_fpFusedAddSubTest_selLSBs_merged_bit_select_b : STD_LOGIC_VECTOR (1 downto 0);
    signal leftShiftStage0_uid315_fracPostNormAdd_uid70_fpFusedAddSubTest_selLSBs_merged_bit_select_c : STD_LOGIC_VECTOR (0 downto 0);
    signal redist0_xIn_a_1_q : STD_LOGIC_VECTOR (31 downto 0);
    signal redist1_xIn_b_1_q : STD_LOGIC_VECTOR (31 downto 0);

begin


    -- redist1_xIn_b_1(DELAY,355)
    redist1_xIn_b_1 : dspba_delay
    GENERIC MAP ( width => 32, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => b, xout => redist1_xIn_b_1_q, clk => clk, aclr => areset );

    -- redist0_xIn_a_1(DELAY,354)
    redist0_xIn_a_1 : dspba_delay
    GENERIC MAP ( width => 32, depth => 1, reset_kind => "ASYNC" )
    PORT MAP ( xin => a, xout => redist0_xIn_a_1_q, clk => clk, aclr => areset );

    -- GND(CONSTANT,0)
    GND_q <= "0";

    -- expFracY_uid7_fpFusedAddSubTest(BITSELECT,6)@0
    expFracY_uid7_fpFusedAddSubTest_b <= b(30 downto 0);

    -- expFracX_uid6_fpFusedAddSubTest(BITSELECT,5)@0
    expFracX_uid6_fpFusedAddSubTest_b <= a(30 downto 0);

    -- xGTEy_uid8_fpFusedAddSubTest(COMPARE,7)@0 + 1
    xGTEy_uid8_fpFusedAddSubTest_a <= STD_LOGIC_VECTOR("00" & expFracX_uid6_fpFusedAddSubTest_b);
    xGTEy_uid8_fpFusedAddSubTest_b <= STD_LOGIC_VECTOR("00" & expFracY_uid7_fpFusedAddSubTest_b);
    xGTEy_uid8_fpFusedAddSubTest_clkproc: PROCESS (clk, areset)
    BEGIN
        IF (areset = '1') THEN
            xGTEy_uid8_fpFusedAddSubTest_o <= (others => '0');
        ELSIF (clk'EVENT AND clk = '1') THEN
            xGTEy_uid8_fpFusedAddSubTest_o <= STD_LOGIC_VECTOR(UNSIGNED(xGTEy_uid8_fpFusedAddSubTest_a) - UNSIGNED(xGTEy_uid8_fpFusedAddSubTest_b));
        END IF;
    END PROCESS;
    xGTEy_uid8_fpFusedAddSubTest_n(0) <= not (xGTEy_uid8_fpFusedAddSubTest_o(32));

    -- sigb_uid10_fpFusedAddSubTest(MUX,9)@1
    sigb_uid10_fpFusedAddSubTest_s <= xGTEy_uid8_fpFusedAddSubTest_n;
    sigb_uid10_fpFusedAddSubTest_combproc: PROCESS (sigb_uid10_fpFusedAddSubTest_s, redist0_xIn_a_1_q, redist1_xIn_b_1_q)
    BEGIN
        CASE (sigb_uid10_fpFusedAddSubTest_s) IS
            WHEN "0" => sigb_uid10_fpFusedAddSubTest_q <= redist0_xIn_a_1_q;
            WHEN "1" => sigb_uid10_fpFusedAddSubTest_q <= redist1_xIn_b_1_q;
            WHEN OTHERS => sigb_uid10_fpFusedAddSubTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- sigB_uid44_fpFusedAddSubTest(BITSELECT,43)@1
    sigB_uid44_fpFusedAddSubTest_b <= STD_LOGIC_VECTOR(sigb_uid10_fpFusedAddSubTest_q(31 downto 31));

    -- siga_uid9_fpFusedAddSubTest(MUX,8)@1
    siga_uid9_fpFusedAddSubTest_s <= xGTEy_uid8_fpFusedAddSubTest_n;
    siga_uid9_fpFusedAddSubTest_combproc: PROCESS (siga_uid9_fpFusedAddSubTest_s, redist1_xIn_b_1_q, redist0_xIn_a_1_q)
    BEGIN
        CASE (siga_uid9_fpFusedAddSubTest_s) IS
            WHEN "0" => siga_uid9_fpFusedAddSubTest_q <= redist1_xIn_b_1_q;
            WHEN "1" => siga_uid9_fpFusedAddSubTest_q <= redist0_xIn_a_1_q;
            WHEN OTHERS => siga_uid9_fpFusedAddSubTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- sigA_uid43_fpFusedAddSubTest(BITSELECT,42)@1
    sigA_uid43_fpFusedAddSubTest_b <= STD_LOGIC_VECTOR(siga_uid9_fpFusedAddSubTest_q(31 downto 31));

    -- cAmA_uid71_fpFusedAddSubTest(CONSTANT,70)
    cAmA_uid71_fpFusedAddSubTest_q <= "11010";

    -- zs_uid161_lzCountValSub_uid67_fpFusedAddSubTest(CONSTANT,160)
    zs_uid161_lzCountValSub_uid67_fpFusedAddSubTest_q <= "0000000000000000";

    -- rightShiftStage1Idx3Pad3_uid253_alignmentShifter_uid59_fpFusedAddSubTest(CONSTANT,252)
    rightShiftStage1Idx3Pad3_uid253_alignmentShifter_uid59_fpFusedAddSubTest_q <= "000";

    -- rightShiftStage1Idx3Rng3_uid252_alignmentShifter_uid59_fpFusedAddSubTest(BITSELECT,251)@1
    rightShiftStage1Idx3Rng3_uid252_alignmentShifter_uid59_fpFusedAddSubTest_b <= rightShiftStage0_uid245_alignmentShifter_uid59_fpFusedAddSubTest_mfinal_q(24 downto 3);

    -- rightShiftStage1Idx3_uid254_alignmentShifter_uid59_fpFusedAddSubTest(BITJOIN,253)@1
    rightShiftStage1Idx3_uid254_alignmentShifter_uid59_fpFusedAddSubTest_q <= rightShiftStage1Idx3Pad3_uid253_alignmentShifter_uid59_fpFusedAddSubTest_q & rightShiftStage1Idx3Rng3_uid252_alignmentShifter_uid59_fpFusedAddSubTest_b;

    -- zs_uid181_lzCountValSub_uid67_fpFusedAddSubTest(CONSTANT,180)
    zs_uid181_lzCountValSub_uid67_fpFusedAddSubTest_q <= "00";

    -- rightShiftStage1Idx2Rng2_uid249_alignmentShifter_uid59_fpFusedAddSubTest(BITSELECT,248)@1
    rightShiftStage1Idx2Rng2_uid249_alignmentShifter_uid59_fpFusedAddSubTest_b <= rightShiftStage0_uid245_alignmentShifter_uid59_fpFusedAddSubTest_mfinal_q(24 downto 2);

    -- rightShiftStage1Idx2_uid251_alignmentShifter_uid59_fpFusedAddSubTest(BITJOIN,250)@1
    rightShiftStage1Idx2_uid251_alignmentShifter_uid59_fpFusedAddSubTest_q <= zs_uid181_lzCountValSub_uid67_fpFusedAddSubTest_q & rightShiftStage1Idx2Rng2_uid249_alignmentShifter_uid59_fpFusedAddSubTest_b;

    -- rightShiftStage1Idx1Rng1_uid246_alignmentShifter_uid59_fpFusedAddSubTest(BITSELECT,245)@1
    rightShiftStage1Idx1Rng1_uid246_alignmentShifter_uid59_fpFusedAddSubTest_b <= rightShiftStage0_uid245_alignmentShifter_uid59_fpFusedAddSubTest_mfinal_q(24 downto 1);

    -- rightShiftStage1Idx1_uid248_alignmentShifter_uid59_fpFusedAddSubTest(BITJOIN,247)@1
    rightShiftStage1Idx1_uid248_alignmentShifter_uid59_fpFusedAddSubTest_q <= GND_q & rightShiftStage1Idx1Rng1_uid246_alignmentShifter_uid59_fpFusedAddSubTest_b;

    -- rightShiftStage0Idx7_uid243_alignmentShifter_uid59_fpFusedAddSubTest(CONSTANT,242)
    rightShiftStage0Idx7_uid243_alignmentShifter_uid59_fpFusedAddSubTest_q <= "0000000000000000000000000";

    -- rightShiftStage0Idx6Pad24_uid241_alignmentShifter_uid59_fpFusedAddSubTest(CONSTANT,240)
    rightShiftStage0Idx6Pad24_uid241_alignmentShifter_uid59_fpFusedAddSubTest_q <= "000000000000000000000000";

    -- cstAllZWE_uid13_fpFusedAddSubTest(CONSTANT,12)
    cstAllZWE_uid13_fpFusedAddSubTest_q <= "00000000";

    -- exp_sigb_uid28_fpFusedAddSubTest(BITSELECT,27)@1
    exp_sigb_uid28_fpFusedAddSubTest_in <= sigb_uid10_fpFusedAddSubTest_q(30 downto 0);
    exp_sigb_uid28_fpFusedAddSubTest_b <= exp_sigb_uid28_fpFusedAddSubTest_in(30 downto 23);

    -- excZ_sigb_uid10_uid30_fpFusedAddSubTest(LOGICAL,29)@1
    excZ_sigb_uid10_uid30_fpFusedAddSubTest_q <= "1" WHEN exp_sigb_uid28_fpFusedAddSubTest_b = cstAllZWE_uid13_fpFusedAddSubTest_q ELSE "0";

    -- InvExpXIsZero_uid37_fpFusedAddSubTest(LOGICAL,36)@1
    InvExpXIsZero_uid37_fpFusedAddSubTest_q <= not (excZ_sigb_uid10_uid30_fpFusedAddSubTest_q);

    -- frac_sigb_uid29_fpFusedAddSubTest(BITSELECT,28)@1
    frac_sigb_uid29_fpFusedAddSubTest_in <= sigb_uid10_fpFusedAddSubTest_q(22 downto 0);
    frac_sigb_uid29_fpFusedAddSubTest_b <= frac_sigb_uid29_fpFusedAddSubTest_in(22 downto 0);

    -- oFracB_uid56_fpFusedAddSubTest(BITJOIN,55)@1
    oFracB_uid56_fpFusedAddSubTest_q <= InvExpXIsZero_uid37_fpFusedAddSubTest_q & frac_sigb_uid29_fpFusedAddSubTest_b;

    -- oFracBR_uid58_fpFusedAddSubTest(BITJOIN,57)@1
    oFracBR_uid58_fpFusedAddSubTest_q <= oFracB_uid56_fpFusedAddSubTest_q & GND_q;

    -- rightShiftStage0Idx6Rng24_uid240_alignmentShifter_uid59_fpFusedAddSubTest(BITSELECT,239)@1
    rightShiftStage0Idx6Rng24_uid240_alignmentShifter_uid59_fpFusedAddSubTest_b <= oFracBR_uid58_fpFusedAddSubTest_q(24 downto 24);

    -- rightShiftStage0Idx6_uid242_alignmentShifter_uid59_fpFusedAddSubTest(BITJOIN,241)@1
    rightShiftStage0Idx6_uid242_alignmentShifter_uid59_fpFusedAddSubTest_q <= rightShiftStage0Idx6Pad24_uid241_alignmentShifter_uid59_fpFusedAddSubTest_q & rightShiftStage0Idx6Rng24_uid240_alignmentShifter_uid59_fpFusedAddSubTest_b;

    -- rightShiftStage0Idx5Pad20_uid238_alignmentShifter_uid59_fpFusedAddSubTest(CONSTANT,237)
    rightShiftStage0Idx5Pad20_uid238_alignmentShifter_uid59_fpFusedAddSubTest_q <= "00000000000000000000";

    -- rightShiftStage0Idx5Rng20_uid237_alignmentShifter_uid59_fpFusedAddSubTest(BITSELECT,236)@1
    rightShiftStage0Idx5Rng20_uid237_alignmentShifter_uid59_fpFusedAddSubTest_b <= oFracBR_uid58_fpFusedAddSubTest_q(24 downto 20);

    -- rightShiftStage0Idx5_uid239_alignmentShifter_uid59_fpFusedAddSubTest(BITJOIN,238)@1
    rightShiftStage0Idx5_uid239_alignmentShifter_uid59_fpFusedAddSubTest_q <= rightShiftStage0Idx5Pad20_uid238_alignmentShifter_uid59_fpFusedAddSubTest_q & rightShiftStage0Idx5Rng20_uid237_alignmentShifter_uid59_fpFusedAddSubTest_b;

    -- rightShiftStage0Idx4Rng16_uid234_alignmentShifter_uid59_fpFusedAddSubTest(BITSELECT,233)@1
    rightShiftStage0Idx4Rng16_uid234_alignmentShifter_uid59_fpFusedAddSubTest_b <= oFracBR_uid58_fpFusedAddSubTest_q(24 downto 16);

    -- rightShiftStage0Idx4_uid236_alignmentShifter_uid59_fpFusedAddSubTest(BITJOIN,235)@1
    rightShiftStage0Idx4_uid236_alignmentShifter_uid59_fpFusedAddSubTest_q <= zs_uid161_lzCountValSub_uid67_fpFusedAddSubTest_q & rightShiftStage0Idx4Rng16_uid234_alignmentShifter_uid59_fpFusedAddSubTest_b;

    -- rightShiftStage0_uid245_alignmentShifter_uid59_fpFusedAddSubTest_msplit_1(MUX,330)@1
    rightShiftStage0_uid245_alignmentShifter_uid59_fpFusedAddSubTest_msplit_1_s <= rightShiftStage0_uid245_alignmentShifter_uid59_fpFusedAddSubTest_selLSBs_merged_bit_select_b;
    rightShiftStage0_uid245_alignmentShifter_uid59_fpFusedAddSubTest_msplit_1_combproc: PROCESS (rightShiftStage0_uid245_alignmentShifter_uid59_fpFusedAddSubTest_msplit_1_s, rightShiftStage0Idx4_uid236_alignmentShifter_uid59_fpFusedAddSubTest_q, rightShiftStage0Idx5_uid239_alignmentShifter_uid59_fpFusedAddSubTest_q, rightShiftStage0Idx6_uid242_alignmentShifter_uid59_fpFusedAddSubTest_q, rightShiftStage0Idx7_uid243_alignmentShifter_uid59_fpFusedAddSubTest_q)
    BEGIN
        CASE (rightShiftStage0_uid245_alignmentShifter_uid59_fpFusedAddSubTest_msplit_1_s) IS
            WHEN "00" => rightShiftStage0_uid245_alignmentShifter_uid59_fpFusedAddSubTest_msplit_1_q <= rightShiftStage0Idx4_uid236_alignmentShifter_uid59_fpFusedAddSubTest_q;
            WHEN "01" => rightShiftStage0_uid245_alignmentShifter_uid59_fpFusedAddSubTest_msplit_1_q <= rightShiftStage0Idx5_uid239_alignmentShifter_uid59_fpFusedAddSubTest_q;
            WHEN "10" => rightShiftStage0_uid245_alignmentShifter_uid59_fpFusedAddSubTest_msplit_1_q <= rightShiftStage0Idx6_uid242_alignmentShifter_uid59_fpFusedAddSubTest_q;
            WHEN "11" => rightShiftStage0_uid245_alignmentShifter_uid59_fpFusedAddSubTest_msplit_1_q <= rightShiftStage0Idx7_uid243_alignmentShifter_uid59_fpFusedAddSubTest_q;
            WHEN OTHERS => rightShiftStage0_uid245_alignmentShifter_uid59_fpFusedAddSubTest_msplit_1_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- rightShiftStage0Idx3Pad12_uid232_alignmentShifter_uid59_fpFusedAddSubTest(CONSTANT,231)
    rightShiftStage0Idx3Pad12_uid232_alignmentShifter_uid59_fpFusedAddSubTest_q <= "000000000000";

    -- rightShiftStage0Idx3Rng12_uid231_alignmentShifter_uid59_fpFusedAddSubTest(BITSELECT,230)@1
    rightShiftStage0Idx3Rng12_uid231_alignmentShifter_uid59_fpFusedAddSubTest_b <= oFracBR_uid58_fpFusedAddSubTest_q(24 downto 12);

    -- rightShiftStage0Idx3_uid233_alignmentShifter_uid59_fpFusedAddSubTest(BITJOIN,232)@1
    rightShiftStage0Idx3_uid233_alignmentShifter_uid59_fpFusedAddSubTest_q <= rightShiftStage0Idx3Pad12_uid232_alignmentShifter_uid59_fpFusedAddSubTest_q & rightShiftStage0Idx3Rng12_uid231_alignmentShifter_uid59_fpFusedAddSubTest_b;

    -- rightShiftStage0Idx2Rng8_uid228_alignmentShifter_uid59_fpFusedAddSubTest(BITSELECT,227)@1
    rightShiftStage0Idx2Rng8_uid228_alignmentShifter_uid59_fpFusedAddSubTest_b <= oFracBR_uid58_fpFusedAddSubTest_q(24 downto 8);

    -- rightShiftStage0Idx2_uid230_alignmentShifter_uid59_fpFusedAddSubTest(BITJOIN,229)@1
    rightShiftStage0Idx2_uid230_alignmentShifter_uid59_fpFusedAddSubTest_q <= cstAllZWE_uid13_fpFusedAddSubTest_q & rightShiftStage0Idx2Rng8_uid228_alignmentShifter_uid59_fpFusedAddSubTest_b;

    -- zs_uid175_lzCountValSub_uid67_fpFusedAddSubTest(CONSTANT,174)
    zs_uid175_lzCountValSub_uid67_fpFusedAddSubTest_q <= "0000";

    -- rightShiftStage0Idx1Rng4_uid225_alignmentShifter_uid59_fpFusedAddSubTest(BITSELECT,224)@1
    rightShiftStage0Idx1Rng4_uid225_alignmentShifter_uid59_fpFusedAddSubTest_b <= oFracBR_uid58_fpFusedAddSubTest_q(24 downto 4);

    -- rightShiftStage0Idx1_uid227_alignmentShifter_uid59_fpFusedAddSubTest(BITJOIN,226)@1
    rightShiftStage0Idx1_uid227_alignmentShifter_uid59_fpFusedAddSubTest_q <= zs_uid175_lzCountValSub_uid67_fpFusedAddSubTest_q & rightShiftStage0Idx1Rng4_uid225_alignmentShifter_uid59_fpFusedAddSubTest_b;

    -- rightShiftStage0_uid245_alignmentShifter_uid59_fpFusedAddSubTest_msplit_0(MUX,329)@1
    rightShiftStage0_uid245_alignmentShifter_uid59_fpFusedAddSubTest_msplit_0_s <= rightShiftStage0_uid245_alignmentShifter_uid59_fpFusedAddSubTest_selLSBs_merged_bit_select_b;
    rightShiftStage0_uid245_alignmentShifter_uid59_fpFusedAddSubTest_msplit_0_combproc: PROCESS (rightShiftStage0_uid245_alignmentShifter_uid59_fpFusedAddSubTest_msplit_0_s, oFracBR_uid58_fpFusedAddSubTest_q, rightShiftStage0Idx1_uid227_alignmentShifter_uid59_fpFusedAddSubTest_q, rightShiftStage0Idx2_uid230_alignmentShifter_uid59_fpFusedAddSubTest_q, rightShiftStage0Idx3_uid233_alignmentShifter_uid59_fpFusedAddSubTest_q)
    BEGIN
        CASE (rightShiftStage0_uid245_alignmentShifter_uid59_fpFusedAddSubTest_msplit_0_s) IS
            WHEN "00" => rightShiftStage0_uid245_alignmentShifter_uid59_fpFusedAddSubTest_msplit_0_q <= oFracBR_uid58_fpFusedAddSubTest_q;
            WHEN "01" => rightShiftStage0_uid245_alignmentShifter_uid59_fpFusedAddSubTest_msplit_0_q <= rightShiftStage0Idx1_uid227_alignmentShifter_uid59_fpFusedAddSubTest_q;
            WHEN "10" => rightShiftStage0_uid245_alignmentShifter_uid59_fpFusedAddSubTest_msplit_0_q <= rightShiftStage0Idx2_uid230_alignmentShifter_uid59_fpFusedAddSubTest_q;
            WHEN "11" => rightShiftStage0_uid245_alignmentShifter_uid59_fpFusedAddSubTest_msplit_0_q <= rightShiftStage0Idx3_uid233_alignmentShifter_uid59_fpFusedAddSubTest_q;
            WHEN OTHERS => rightShiftStage0_uid245_alignmentShifter_uid59_fpFusedAddSubTest_msplit_0_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- rightShiftStage0_uid245_alignmentShifter_uid59_fpFusedAddSubTest_selLSBs_merged_bit_select(BITSELECT,351)@1
    rightShiftStage0_uid245_alignmentShifter_uid59_fpFusedAddSubTest_selLSBs_merged_bit_select_b <= rightShiftStageSel4Dto2_uid244_alignmentShifter_uid59_fpFusedAddSubTest_merged_bit_select_b(1 downto 0);
    rightShiftStage0_uid245_alignmentShifter_uid59_fpFusedAddSubTest_selLSBs_merged_bit_select_c <= rightShiftStageSel4Dto2_uid244_alignmentShifter_uid59_fpFusedAddSubTest_merged_bit_select_b(2 downto 2);

    -- rightShiftStage0_uid245_alignmentShifter_uid59_fpFusedAddSubTest_mfinal(MUX,331)@1
    rightShiftStage0_uid245_alignmentShifter_uid59_fpFusedAddSubTest_mfinal_s <= rightShiftStage0_uid245_alignmentShifter_uid59_fpFusedAddSubTest_selLSBs_merged_bit_select_c;
    rightShiftStage0_uid245_alignmentShifter_uid59_fpFusedAddSubTest_mfinal_combproc: PROCESS (rightShiftStage0_uid245_alignmentShifter_uid59_fpFusedAddSubTest_mfinal_s, rightShiftStage0_uid245_alignmentShifter_uid59_fpFusedAddSubTest_msplit_0_q, rightShiftStage0_uid245_alignmentShifter_uid59_fpFusedAddSubTest_msplit_1_q)
    BEGIN
        CASE (rightShiftStage0_uid245_alignmentShifter_uid59_fpFusedAddSubTest_mfinal_s) IS
            WHEN "0" => rightShiftStage0_uid245_alignmentShifter_uid59_fpFusedAddSubTest_mfinal_q <= rightShiftStage0_uid245_alignmentShifter_uid59_fpFusedAddSubTest_msplit_0_q;
            WHEN "1" => rightShiftStage0_uid245_alignmentShifter_uid59_fpFusedAddSubTest_mfinal_q <= rightShiftStage0_uid245_alignmentShifter_uid59_fpFusedAddSubTest_msplit_1_q;
            WHEN OTHERS => rightShiftStage0_uid245_alignmentShifter_uid59_fpFusedAddSubTest_mfinal_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- shiftOutConst_uid52_fpFusedAddSubTest(CONSTANT,51)
    shiftOutConst_uid52_fpFusedAddSubTest_q <= "11001";

    -- exp_siga_uid14_fpFusedAddSubTest(BITSELECT,13)@1
    exp_siga_uid14_fpFusedAddSubTest_in <= siga_uid9_fpFusedAddSubTest_q(30 downto 0);
    exp_siga_uid14_fpFusedAddSubTest_b <= exp_siga_uid14_fpFusedAddSubTest_in(30 downto 23);

    -- expAmExpB_uid48_fpFusedAddSubTest(SUB,47)@1
    expAmExpB_uid48_fpFusedAddSubTest_a <= STD_LOGIC_VECTOR("0" & exp_siga_uid14_fpFusedAddSubTest_b);
    expAmExpB_uid48_fpFusedAddSubTest_b <= STD_LOGIC_VECTOR("0" & exp_sigb_uid28_fpFusedAddSubTest_b);
    expAmExpB_uid48_fpFusedAddSubTest_o <= STD_LOGIC_VECTOR(UNSIGNED(expAmExpB_uid48_fpFusedAddSubTest_a) - UNSIGNED(expAmExpB_uid48_fpFusedAddSubTest_b));
    expAmExpB_uid48_fpFusedAddSubTest_q <= expAmExpB_uid48_fpFusedAddSubTest_o(8 downto 0);

    -- expAmExpBShiftRange_uid53_fpFusedAddSubTest(BITSELECT,52)@1
    expAmExpBShiftRange_uid53_fpFusedAddSubTest_in <= expAmExpB_uid48_fpFusedAddSubTest_q(4 downto 0);
    expAmExpBShiftRange_uid53_fpFusedAddSubTest_b <= expAmExpBShiftRange_uid53_fpFusedAddSubTest_in(4 downto 0);

    -- cWFP1_uid49_fpFusedAddSubTest(CONSTANT,48)
    cWFP1_uid49_fpFusedAddSubTest_q <= "11000";

    -- shiftedOut_uid51_fpFusedAddSubTest(COMPARE,50)@1
    shiftedOut_uid51_fpFusedAddSubTest_a <= STD_LOGIC_VECTOR("000000" & cWFP1_uid49_fpFusedAddSubTest_q);
    shiftedOut_uid51_fpFusedAddSubTest_b <= STD_LOGIC_VECTOR("00" & expAmExpB_uid48_fpFusedAddSubTest_q);
    shiftedOut_uid51_fpFusedAddSubTest_o <= STD_LOGIC_VECTOR(UNSIGNED(shiftedOut_uid51_fpFusedAddSubTest_a) - UNSIGNED(shiftedOut_uid51_fpFusedAddSubTest_b));
    shiftedOut_uid51_fpFusedAddSubTest_c(0) <= shiftedOut_uid51_fpFusedAddSubTest_o(10);

    -- shiftValue_uid54_fpFusedAddSubTest(MUX,53)@1
    shiftValue_uid54_fpFusedAddSubTest_s <= shiftedOut_uid51_fpFusedAddSubTest_c;
    shiftValue_uid54_fpFusedAddSubTest_combproc: PROCESS (shiftValue_uid54_fpFusedAddSubTest_s, expAmExpBShiftRange_uid53_fpFusedAddSubTest_b, shiftOutConst_uid52_fpFusedAddSubTest_q)
    BEGIN
        CASE (shiftValue_uid54_fpFusedAddSubTest_s) IS
            WHEN "0" => shiftValue_uid54_fpFusedAddSubTest_q <= expAmExpBShiftRange_uid53_fpFusedAddSubTest_b;
            WHEN "1" => shiftValue_uid54_fpFusedAddSubTest_q <= shiftOutConst_uid52_fpFusedAddSubTest_q;
            WHEN OTHERS => shiftValue_uid54_fpFusedAddSubTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- rightShiftStageSel4Dto2_uid244_alignmentShifter_uid59_fpFusedAddSubTest_merged_bit_select(BITSELECT,342)@1
    rightShiftStageSel4Dto2_uid244_alignmentShifter_uid59_fpFusedAddSubTest_merged_bit_select_b <= shiftValue_uid54_fpFusedAddSubTest_q(4 downto 2);
    rightShiftStageSel4Dto2_uid244_alignmentShifter_uid59_fpFusedAddSubTest_merged_bit_select_c <= shiftValue_uid54_fpFusedAddSubTest_q(1 downto 0);

    -- rightShiftStage1_uid256_alignmentShifter_uid59_fpFusedAddSubTest(MUX,255)@1
    rightShiftStage1_uid256_alignmentShifter_uid59_fpFusedAddSubTest_s <= rightShiftStageSel4Dto2_uid244_alignmentShifter_uid59_fpFusedAddSubTest_merged_bit_select_c;
    rightShiftStage1_uid256_alignmentShifter_uid59_fpFusedAddSubTest_combproc: PROCESS (rightShiftStage1_uid256_alignmentShifter_uid59_fpFusedAddSubTest_s, rightShiftStage0_uid245_alignmentShifter_uid59_fpFusedAddSubTest_mfinal_q, rightShiftStage1Idx1_uid248_alignmentShifter_uid59_fpFusedAddSubTest_q, rightShiftStage1Idx2_uid251_alignmentShifter_uid59_fpFusedAddSubTest_q, rightShiftStage1Idx3_uid254_alignmentShifter_uid59_fpFusedAddSubTest_q)
    BEGIN
        CASE (rightShiftStage1_uid256_alignmentShifter_uid59_fpFusedAddSubTest_s) IS
            WHEN "00" => rightShiftStage1_uid256_alignmentShifter_uid59_fpFusedAddSubTest_q <= rightShiftStage0_uid245_alignmentShifter_uid59_fpFusedAddSubTest_mfinal_q;
            WHEN "01" => rightShiftStage1_uid256_alignmentShifter_uid59_fpFusedAddSubTest_q <= rightShiftStage1Idx1_uid248_alignmentShifter_uid59_fpFusedAddSubTest_q;
            WHEN "10" => rightShiftStage1_uid256_alignmentShifter_uid59_fpFusedAddSubTest_q <= rightShiftStage1Idx2_uid251_alignmentShifter_uid59_fpFusedAddSubTest_q;
            WHEN "11" => rightShiftStage1_uid256_alignmentShifter_uid59_fpFusedAddSubTest_q <= rightShiftStage1Idx3_uid254_alignmentShifter_uid59_fpFusedAddSubTest_q;
            WHEN OTHERS => rightShiftStage1_uid256_alignmentShifter_uid59_fpFusedAddSubTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- fracBOp_uid62_fpFusedAddSubTest(BITJOIN,61)@1
    fracBOp_uid62_fpFusedAddSubTest_q <= GND_q & GND_q & rightShiftStage1_uid256_alignmentShifter_uid59_fpFusedAddSubTest_q;

    -- frac_siga_uid15_fpFusedAddSubTest(BITSELECT,14)@1
    frac_siga_uid15_fpFusedAddSubTest_in <= siga_uid9_fpFusedAddSubTest_q(22 downto 0);
    frac_siga_uid15_fpFusedAddSubTest_b <= frac_siga_uid15_fpFusedAddSubTest_in(22 downto 0);

    -- oFracA_uid57_fpFusedAddSubTest(BITJOIN,56)@1
    oFracA_uid57_fpFusedAddSubTest_q <= VCC_q & frac_siga_uid15_fpFusedAddSubTest_b;

    -- fracAOp_uid61_fpFusedAddSubTest(BITJOIN,60)@1
    fracAOp_uid61_fpFusedAddSubTest_q <= oFracA_uid57_fpFusedAddSubTest_q & GND_q;

    -- fracResSub_uid63_fpFusedAddSubTest(SUB,62)@1
    fracResSub_uid63_fpFusedAddSubTest_a <= STD_LOGIC_VECTOR("000" & fracAOp_uid61_fpFusedAddSubTest_q);
    fracResSub_uid63_fpFusedAddSubTest_b <= STD_LOGIC_VECTOR("0" & fracBOp_uid62_fpFusedAddSubTest_q);
    fracResSub_uid63_fpFusedAddSubTest_o <= STD_LOGIC_VECTOR(UNSIGNED(fracResSub_uid63_fpFusedAddSubTest_a) - UNSIGNED(fracResSub_uid63_fpFusedAddSubTest_b));
    fracResSub_uid63_fpFusedAddSubTest_q <= fracResSub_uid63_fpFusedAddSubTest_o(27 downto 0);

    -- fracResSubNoSignExt_uid65_fpFusedAddSubTest(BITSELECT,64)@1
    fracResSubNoSignExt_uid65_fpFusedAddSubTest_in <= fracResSub_uid63_fpFusedAddSubTest_q(25 downto 0);
    fracResSubNoSignExt_uid65_fpFusedAddSubTest_b <= fracResSubNoSignExt_uid65_fpFusedAddSubTest_in(25 downto 0);

    -- rVStage_uid162_lzCountValSub_uid67_fpFusedAddSubTest(BITSELECT,161)@1
    rVStage_uid162_lzCountValSub_uid67_fpFusedAddSubTest_b <= fracResSubNoSignExt_uid65_fpFusedAddSubTest_b(25 downto 10);

    -- vCount_uid163_lzCountValSub_uid67_fpFusedAddSubTest(LOGICAL,162)@1
    vCount_uid163_lzCountValSub_uid67_fpFusedAddSubTest_q <= "1" WHEN rVStage_uid162_lzCountValSub_uid67_fpFusedAddSubTest_b = zs_uid161_lzCountValSub_uid67_fpFusedAddSubTest_q ELSE "0";

    -- vStage_uid165_lzCountValSub_uid67_fpFusedAddSubTest(BITSELECT,164)@1
    vStage_uid165_lzCountValSub_uid67_fpFusedAddSubTest_in <= fracResSubNoSignExt_uid65_fpFusedAddSubTest_b(9 downto 0);
    vStage_uid165_lzCountValSub_uid67_fpFusedAddSubTest_b <= vStage_uid165_lzCountValSub_uid67_fpFusedAddSubTest_in(9 downto 0);

    -- mO_uid164_lzCountValSub_uid67_fpFusedAddSubTest(CONSTANT,163)
    mO_uid164_lzCountValSub_uid67_fpFusedAddSubTest_q <= "111111";

    -- cStage_uid166_lzCountValSub_uid67_fpFusedAddSubTest(BITJOIN,165)@1
    cStage_uid166_lzCountValSub_uid67_fpFusedAddSubTest_q <= vStage_uid165_lzCountValSub_uid67_fpFusedAddSubTest_b & mO_uid164_lzCountValSub_uid67_fpFusedAddSubTest_q;

    -- vStagei_uid168_lzCountValSub_uid67_fpFusedAddSubTest(MUX,167)@1
    vStagei_uid168_lzCountValSub_uid67_fpFusedAddSubTest_s <= vCount_uid163_lzCountValSub_uid67_fpFusedAddSubTest_q;
    vStagei_uid168_lzCountValSub_uid67_fpFusedAddSubTest_combproc: PROCESS (vStagei_uid168_lzCountValSub_uid67_fpFusedAddSubTest_s, rVStage_uid162_lzCountValSub_uid67_fpFusedAddSubTest_b, cStage_uid166_lzCountValSub_uid67_fpFusedAddSubTest_q)
    BEGIN
        CASE (vStagei_uid168_lzCountValSub_uid67_fpFusedAddSubTest_s) IS
            WHEN "0" => vStagei_uid168_lzCountValSub_uid67_fpFusedAddSubTest_q <= rVStage_uid162_lzCountValSub_uid67_fpFusedAddSubTest_b;
            WHEN "1" => vStagei_uid168_lzCountValSub_uid67_fpFusedAddSubTest_q <= cStage_uid166_lzCountValSub_uid67_fpFusedAddSubTest_q;
            WHEN OTHERS => vStagei_uid168_lzCountValSub_uid67_fpFusedAddSubTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- rVStage_uid170_lzCountValSub_uid67_fpFusedAddSubTest_merged_bit_select(BITSELECT,343)@1
    rVStage_uid170_lzCountValSub_uid67_fpFusedAddSubTest_merged_bit_select_b <= vStagei_uid168_lzCountValSub_uid67_fpFusedAddSubTest_q(15 downto 8);
    rVStage_uid170_lzCountValSub_uid67_fpFusedAddSubTest_merged_bit_select_c <= vStagei_uid168_lzCountValSub_uid67_fpFusedAddSubTest_q(7 downto 0);

    -- vCount_uid171_lzCountValSub_uid67_fpFusedAddSubTest(LOGICAL,170)@1
    vCount_uid171_lzCountValSub_uid67_fpFusedAddSubTest_q <= "1" WHEN rVStage_uid170_lzCountValSub_uid67_fpFusedAddSubTest_merged_bit_select_b = cstAllZWE_uid13_fpFusedAddSubTest_q ELSE "0";

    -- vStagei_uid174_lzCountValSub_uid67_fpFusedAddSubTest(MUX,173)@1
    vStagei_uid174_lzCountValSub_uid67_fpFusedAddSubTest_s <= vCount_uid171_lzCountValSub_uid67_fpFusedAddSubTest_q;
    vStagei_uid174_lzCountValSub_uid67_fpFusedAddSubTest_combproc: PROCESS (vStagei_uid174_lzCountValSub_uid67_fpFusedAddSubTest_s, rVStage_uid170_lzCountValSub_uid67_fpFusedAddSubTest_merged_bit_select_b, rVStage_uid170_lzCountValSub_uid67_fpFusedAddSubTest_merged_bit_select_c)
    BEGIN
        CASE (vStagei_uid174_lzCountValSub_uid67_fpFusedAddSubTest_s) IS
            WHEN "0" => vStagei_uid174_lzCountValSub_uid67_fpFusedAddSubTest_q <= rVStage_uid170_lzCountValSub_uid67_fpFusedAddSubTest_merged_bit_select_b;
            WHEN "1" => vStagei_uid174_lzCountValSub_uid67_fpFusedAddSubTest_q <= rVStage_uid170_lzCountValSub_uid67_fpFusedAddSubTest_merged_bit_select_c;
            WHEN OTHERS => vStagei_uid174_lzCountValSub_uid67_fpFusedAddSubTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- rVStage_uid176_lzCountValSub_uid67_fpFusedAddSubTest_merged_bit_select(BITSELECT,344)@1
    rVStage_uid176_lzCountValSub_uid67_fpFusedAddSubTest_merged_bit_select_b <= vStagei_uid174_lzCountValSub_uid67_fpFusedAddSubTest_q(7 downto 4);
    rVStage_uid176_lzCountValSub_uid67_fpFusedAddSubTest_merged_bit_select_c <= vStagei_uid174_lzCountValSub_uid67_fpFusedAddSubTest_q(3 downto 0);

    -- vCount_uid177_lzCountValSub_uid67_fpFusedAddSubTest(LOGICAL,176)@1
    vCount_uid177_lzCountValSub_uid67_fpFusedAddSubTest_q <= "1" WHEN rVStage_uid176_lzCountValSub_uid67_fpFusedAddSubTest_merged_bit_select_b = zs_uid175_lzCountValSub_uid67_fpFusedAddSubTest_q ELSE "0";

    -- vStagei_uid180_lzCountValSub_uid67_fpFusedAddSubTest(MUX,179)@1
    vStagei_uid180_lzCountValSub_uid67_fpFusedAddSubTest_s <= vCount_uid177_lzCountValSub_uid67_fpFusedAddSubTest_q;
    vStagei_uid180_lzCountValSub_uid67_fpFusedAddSubTest_combproc: PROCESS (vStagei_uid180_lzCountValSub_uid67_fpFusedAddSubTest_s, rVStage_uid176_lzCountValSub_uid67_fpFusedAddSubTest_merged_bit_select_b, rVStage_uid176_lzCountValSub_uid67_fpFusedAddSubTest_merged_bit_select_c)
    BEGIN
        CASE (vStagei_uid180_lzCountValSub_uid67_fpFusedAddSubTest_s) IS
            WHEN "0" => vStagei_uid180_lzCountValSub_uid67_fpFusedAddSubTest_q <= rVStage_uid176_lzCountValSub_uid67_fpFusedAddSubTest_merged_bit_select_b;
            WHEN "1" => vStagei_uid180_lzCountValSub_uid67_fpFusedAddSubTest_q <= rVStage_uid176_lzCountValSub_uid67_fpFusedAddSubTest_merged_bit_select_c;
            WHEN OTHERS => vStagei_uid180_lzCountValSub_uid67_fpFusedAddSubTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- rVStage_uid182_lzCountValSub_uid67_fpFusedAddSubTest_merged_bit_select(BITSELECT,345)@1
    rVStage_uid182_lzCountValSub_uid67_fpFusedAddSubTest_merged_bit_select_b <= vStagei_uid180_lzCountValSub_uid67_fpFusedAddSubTest_q(3 downto 2);
    rVStage_uid182_lzCountValSub_uid67_fpFusedAddSubTest_merged_bit_select_c <= vStagei_uid180_lzCountValSub_uid67_fpFusedAddSubTest_q(1 downto 0);

    -- vCount_uid183_lzCountValSub_uid67_fpFusedAddSubTest(LOGICAL,182)@1
    vCount_uid183_lzCountValSub_uid67_fpFusedAddSubTest_q <= "1" WHEN rVStage_uid182_lzCountValSub_uid67_fpFusedAddSubTest_merged_bit_select_b = zs_uid181_lzCountValSub_uid67_fpFusedAddSubTest_q ELSE "0";

    -- vStagei_uid186_lzCountValSub_uid67_fpFusedAddSubTest(MUX,185)@1
    vStagei_uid186_lzCountValSub_uid67_fpFusedAddSubTest_s <= vCount_uid183_lzCountValSub_uid67_fpFusedAddSubTest_q;
    vStagei_uid186_lzCountValSub_uid67_fpFusedAddSubTest_combproc: PROCESS (vStagei_uid186_lzCountValSub_uid67_fpFusedAddSubTest_s, rVStage_uid182_lzCountValSub_uid67_fpFusedAddSubTest_merged_bit_select_b, rVStage_uid182_lzCountValSub_uid67_fpFusedAddSubTest_merged_bit_select_c)
    BEGIN
        CASE (vStagei_uid186_lzCountValSub_uid67_fpFusedAddSubTest_s) IS
            WHEN "0" => vStagei_uid186_lzCountValSub_uid67_fpFusedAddSubTest_q <= rVStage_uid182_lzCountValSub_uid67_fpFusedAddSubTest_merged_bit_select_b;
            WHEN "1" => vStagei_uid186_lzCountValSub_uid67_fpFusedAddSubTest_q <= rVStage_uid182_lzCountValSub_uid67_fpFusedAddSubTest_merged_bit_select_c;
            WHEN OTHERS => vStagei_uid186_lzCountValSub_uid67_fpFusedAddSubTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- rVStage_uid188_lzCountValSub_uid67_fpFusedAddSubTest(BITSELECT,187)@1
    rVStage_uid188_lzCountValSub_uid67_fpFusedAddSubTest_b <= vStagei_uid186_lzCountValSub_uid67_fpFusedAddSubTest_q(1 downto 1);

    -- vCount_uid189_lzCountValSub_uid67_fpFusedAddSubTest(LOGICAL,188)@1
    vCount_uid189_lzCountValSub_uid67_fpFusedAddSubTest_q <= "1" WHEN rVStage_uid188_lzCountValSub_uid67_fpFusedAddSubTest_b = GND_q ELSE "0";

    -- r_uid190_lzCountValSub_uid67_fpFusedAddSubTest(BITJOIN,189)@1
    r_uid190_lzCountValSub_uid67_fpFusedAddSubTest_q <= vCount_uid163_lzCountValSub_uid67_fpFusedAddSubTest_q & vCount_uid171_lzCountValSub_uid67_fpFusedAddSubTest_q & vCount_uid177_lzCountValSub_uid67_fpFusedAddSubTest_q & vCount_uid183_lzCountValSub_uid67_fpFusedAddSubTest_q & vCount_uid189_lzCountValSub_uid67_fpFusedAddSubTest_q;

    -- aMinusA_uid72_fpFusedAddSubTest(LOGICAL,71)@1
    aMinusA_uid72_fpFusedAddSubTest_q <= "1" WHEN r_uid190_lzCountValSub_uid67_fpFusedAddSubTest_q = cAmA_uid71_fpFusedAddSubTest_q ELSE "0";

    -- cstAllOWE_uid11_fpFusedAddSubTest(CONSTANT,10)
    cstAllOWE_uid11_fpFusedAddSubTest_q <= "11111111";

    -- expXIsMax_uid17_fpFusedAddSubTest(LOGICAL,16)@1
    expXIsMax_uid17_fpFusedAddSubTest_q <= "1" WHEN exp_siga_uid14_fpFusedAddSubTest_b = cstAllOWE_uid11_fpFusedAddSubTest_q ELSE "0";

    -- invExpXIsMax_uid22_fpFusedAddSubTest(LOGICAL,21)@1
    invExpXIsMax_uid22_fpFusedAddSubTest_q <= not (expXIsMax_uid17_fpFusedAddSubTest_q);

    -- excZ_siga_uid9_uid16_fpFusedAddSubTest(LOGICAL,15)@1
    excZ_siga_uid9_uid16_fpFusedAddSubTest_q <= "1" WHEN exp_siga_uid14_fpFusedAddSubTest_b = cstAllZWE_uid13_fpFusedAddSubTest_q ELSE "0";

    -- InvExpXIsZero_uid23_fpFusedAddSubTest(LOGICAL,22)@1
    InvExpXIsZero_uid23_fpFusedAddSubTest_q <= not (excZ_siga_uid9_uid16_fpFusedAddSubTest_q);

    -- excR_siga_uid24_fpFusedAddSubTest(LOGICAL,23)@1
    excR_siga_uid24_fpFusedAddSubTest_q <= InvExpXIsZero_uid23_fpFusedAddSubTest_q and invExpXIsMax_uid22_fpFusedAddSubTest_q;

    -- positiveExc_uid145_fpFusedAddSubTest(LOGICAL,144)@1
    positiveExc_uid145_fpFusedAddSubTest_q <= excR_siga_uid24_fpFusedAddSubTest_q and aMinusA_uid72_fpFusedAddSubTest_q and sigA_uid43_fpFusedAddSubTest_b and sigB_uid44_fpFusedAddSubTest_b;

    -- invPositiveExc_uid146_fpFusedAddSubTest(LOGICAL,145)@1
    invPositiveExc_uid146_fpFusedAddSubTest_q <= not (positiveExc_uid145_fpFusedAddSubTest_q);

    -- signInputsZeroForSub_uid147_fpFusedAddSubTest(LOGICAL,146)@1
    signInputsZeroForSub_uid147_fpFusedAddSubTest_q <= excZ_siga_uid9_uid16_fpFusedAddSubTest_q and excZ_sigb_uid10_uid30_fpFusedAddSubTest_q and sigA_uid43_fpFusedAddSubTest_b and sigB_uid44_fpFusedAddSubTest_b;

    -- invSignInputsZeroForSub_uid148_fpFusedAddSubTest(LOGICAL,147)@1
    invSignInputsZeroForSub_uid148_fpFusedAddSubTest_q <= not (signInputsZeroForSub_uid147_fpFusedAddSubTest_q);

    -- sigY_uid149_fpFusedAddSubTest(BITSELECT,148)@1
    sigY_uid149_fpFusedAddSubTest_b <= STD_LOGIC_VECTOR(redist1_xIn_b_1_q(31 downto 31));

    -- invSigY_uid150_fpFusedAddSubTest(LOGICAL,149)@1
    invSigY_uid150_fpFusedAddSubTest_q <= not (sigY_uid149_fpFusedAddSubTest_b);

    -- invXGTEy_uid125_fpFusedAddSubTest(LOGICAL,124)@1
    invXGTEy_uid125_fpFusedAddSubTest_q <= not (xGTEy_uid8_fpFusedAddSubTest_n);

    -- yGTxYPos_uid152_fpFusedAddSubTest(LOGICAL,151)@1
    yGTxYPos_uid152_fpFusedAddSubTest_q <= invXGTEy_uid125_fpFusedAddSubTest_q and invSigY_uid150_fpFusedAddSubTest_q;

    -- sigX_uid153_fpFusedAddSubTest(BITSELECT,152)@1
    sigX_uid153_fpFusedAddSubTest_b <= STD_LOGIC_VECTOR(redist0_xIn_a_1_q(31 downto 31));

    -- xGTyXNeg_uid154_fpFusedAddSubTest(LOGICAL,153)@1
    xGTyXNeg_uid154_fpFusedAddSubTest_q <= xGTEy_uid8_fpFusedAddSubTest_n and sigX_uid153_fpFusedAddSubTest_b;

    -- signRPostExcSub0_uid155_fpFusedAddSubTest(LOGICAL,154)@1
    signRPostExcSub0_uid155_fpFusedAddSubTest_q <= xGTyXNeg_uid154_fpFusedAddSubTest_q or yGTxYPos_uid152_fpFusedAddSubTest_q;

    -- cstZeroWF_uid12_fpFusedAddSubTest(CONSTANT,11)
    cstZeroWF_uid12_fpFusedAddSubTest_q <= "00000000000000000000000";

    -- fracXIsZero_uid32_fpFusedAddSubTest(LOGICAL,31)@1
    fracXIsZero_uid32_fpFusedAddSubTest_q <= "1" WHEN cstZeroWF_uid12_fpFusedAddSubTest_q = frac_sigb_uid29_fpFusedAddSubTest_b ELSE "0";

    -- fracXIsNotZero_uid33_fpFusedAddSubTest(LOGICAL,32)@1
    fracXIsNotZero_uid33_fpFusedAddSubTest_q <= not (fracXIsZero_uid32_fpFusedAddSubTest_q);

    -- expXIsMax_uid31_fpFusedAddSubTest(LOGICAL,30)@1
    expXIsMax_uid31_fpFusedAddSubTest_q <= "1" WHEN exp_sigb_uid28_fpFusedAddSubTest_b = cstAllOWE_uid11_fpFusedAddSubTest_q ELSE "0";

    -- excN_sigb_uid35_fpFusedAddSubTest(LOGICAL,34)@1
    excN_sigb_uid35_fpFusedAddSubTest_q <= expXIsMax_uid31_fpFusedAddSubTest_q and fracXIsNotZero_uid33_fpFusedAddSubTest_q;

    -- fracXIsZero_uid18_fpFusedAddSubTest(LOGICAL,17)@1
    fracXIsZero_uid18_fpFusedAddSubTest_q <= "1" WHEN cstZeroWF_uid12_fpFusedAddSubTest_q = frac_siga_uid15_fpFusedAddSubTest_b ELSE "0";

    -- fracXIsNotZero_uid19_fpFusedAddSubTest(LOGICAL,18)@1
    fracXIsNotZero_uid19_fpFusedAddSubTest_q <= not (fracXIsZero_uid18_fpFusedAddSubTest_q);

    -- excN_siga_uid21_fpFusedAddSubTest(LOGICAL,20)@1
    excN_siga_uid21_fpFusedAddSubTest_q <= expXIsMax_uid17_fpFusedAddSubTest_q and fracXIsNotZero_uid19_fpFusedAddSubTest_q;

    -- effSub_uid45_fpFusedAddSubTest(LOGICAL,44)@1
    effSub_uid45_fpFusedAddSubTest_q <= sigA_uid43_fpFusedAddSubTest_b xor sigB_uid44_fpFusedAddSubTest_b;

    -- invEffSub_uid106_fpFusedAddSubTest(LOGICAL,105)@1
    invEffSub_uid106_fpFusedAddSubTest_q <= not (effSub_uid45_fpFusedAddSubTest_q);

    -- excI_sigb_uid34_fpFusedAddSubTest(LOGICAL,33)@1
    excI_sigb_uid34_fpFusedAddSubTest_q <= expXIsMax_uid31_fpFusedAddSubTest_q and fracXIsZero_uid32_fpFusedAddSubTest_q;

    -- excI_siga_uid20_fpFusedAddSubTest(LOGICAL,19)@1
    excI_siga_uid20_fpFusedAddSubTest_q <= expXIsMax_uid17_fpFusedAddSubTest_q and fracXIsZero_uid18_fpFusedAddSubTest_q;

    -- infPinfForSub_uid107_fpFusedAddSubTest(LOGICAL,106)@1
    infPinfForSub_uid107_fpFusedAddSubTest_q <= excI_siga_uid20_fpFusedAddSubTest_q and excI_sigb_uid34_fpFusedAddSubTest_q and invEffSub_uid106_fpFusedAddSubTest_q;

    -- excRNaNS_uid108_fpFusedAddSubTest(LOGICAL,107)@1
    excRNaNS_uid108_fpFusedAddSubTest_q <= infPinfForSub_uid107_fpFusedAddSubTest_q or excN_siga_uid21_fpFusedAddSubTest_q or excN_sigb_uid35_fpFusedAddSubTest_q;

    -- invExcRNaNS_uid156_fpFusedAddSubTest(LOGICAL,155)@1
    invExcRNaNS_uid156_fpFusedAddSubTest_q <= not (excRNaNS_uid108_fpFusedAddSubTest_q);

    -- VCC(CONSTANT,1)
    VCC_q <= "1";

    -- signRPostExcSub_uid157_fpFusedAddSubTest(LOGICAL,156)@1
    signRPostExcSub_uid157_fpFusedAddSubTest_q <= invExcRNaNS_uid156_fpFusedAddSubTest_q and signRPostExcSub0_uid155_fpFusedAddSubTest_q and invSignInputsZeroForSub_uid148_fpFusedAddSubTest_q and invPositiveExc_uid146_fpFusedAddSubTest_q;

    -- fracResAdd_uid64_fpFusedAddSubTest(ADD,63)@1
    fracResAdd_uid64_fpFusedAddSubTest_a <= STD_LOGIC_VECTOR("000" & fracAOp_uid61_fpFusedAddSubTest_q);
    fracResAdd_uid64_fpFusedAddSubTest_b <= STD_LOGIC_VECTOR("0" & fracBOp_uid62_fpFusedAddSubTest_q);
    fracResAdd_uid64_fpFusedAddSubTest_o <= STD_LOGIC_VECTOR(UNSIGNED(fracResAdd_uid64_fpFusedAddSubTest_a) + UNSIGNED(fracResAdd_uid64_fpFusedAddSubTest_b));
    fracResAdd_uid64_fpFusedAddSubTest_q <= fracResAdd_uid64_fpFusedAddSubTest_o(27 downto 0);

    -- fracResAddNoSignExt_uid66_fpFusedAddSubTest(BITSELECT,65)@1
    fracResAddNoSignExt_uid66_fpFusedAddSubTest_in <= fracResAdd_uid64_fpFusedAddSubTest_q(25 downto 0);
    fracResAddNoSignExt_uid66_fpFusedAddSubTest_b <= fracResAddNoSignExt_uid66_fpFusedAddSubTest_in(25 downto 0);

    -- rVStage_uid193_lzCountValAdd_uid69_fpFusedAddSubTest(BITSELECT,192)@1
    rVStage_uid193_lzCountValAdd_uid69_fpFusedAddSubTest_b <= fracResAddNoSignExt_uid66_fpFusedAddSubTest_b(25 downto 10);

    -- vCount_uid194_lzCountValAdd_uid69_fpFusedAddSubTest(LOGICAL,193)@1
    vCount_uid194_lzCountValAdd_uid69_fpFusedAddSubTest_q <= "1" WHEN rVStage_uid193_lzCountValAdd_uid69_fpFusedAddSubTest_b = zs_uid161_lzCountValSub_uid67_fpFusedAddSubTest_q ELSE "0";

    -- vStage_uid196_lzCountValAdd_uid69_fpFusedAddSubTest(BITSELECT,195)@1
    vStage_uid196_lzCountValAdd_uid69_fpFusedAddSubTest_in <= fracResAddNoSignExt_uid66_fpFusedAddSubTest_b(9 downto 0);
    vStage_uid196_lzCountValAdd_uid69_fpFusedAddSubTest_b <= vStage_uid196_lzCountValAdd_uid69_fpFusedAddSubTest_in(9 downto 0);

    -- cStage_uid197_lzCountValAdd_uid69_fpFusedAddSubTest(BITJOIN,196)@1
    cStage_uid197_lzCountValAdd_uid69_fpFusedAddSubTest_q <= vStage_uid196_lzCountValAdd_uid69_fpFusedAddSubTest_b & mO_uid164_lzCountValSub_uid67_fpFusedAddSubTest_q;

    -- vStagei_uid199_lzCountValAdd_uid69_fpFusedAddSubTest(MUX,198)@1
    vStagei_uid199_lzCountValAdd_uid69_fpFusedAddSubTest_s <= vCount_uid194_lzCountValAdd_uid69_fpFusedAddSubTest_q;
    vStagei_uid199_lzCountValAdd_uid69_fpFusedAddSubTest_combproc: PROCESS (vStagei_uid199_lzCountValAdd_uid69_fpFusedAddSubTest_s, rVStage_uid193_lzCountValAdd_uid69_fpFusedAddSubTest_b, cStage_uid197_lzCountValAdd_uid69_fpFusedAddSubTest_q)
    BEGIN
        CASE (vStagei_uid199_lzCountValAdd_uid69_fpFusedAddSubTest_s) IS
            WHEN "0" => vStagei_uid199_lzCountValAdd_uid69_fpFusedAddSubTest_q <= rVStage_uid193_lzCountValAdd_uid69_fpFusedAddSubTest_b;
            WHEN "1" => vStagei_uid199_lzCountValAdd_uid69_fpFusedAddSubTest_q <= cStage_uid197_lzCountValAdd_uid69_fpFusedAddSubTest_q;
            WHEN OTHERS => vStagei_uid199_lzCountValAdd_uid69_fpFusedAddSubTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- rVStage_uid201_lzCountValAdd_uid69_fpFusedAddSubTest_merged_bit_select(BITSELECT,347)@1
    rVStage_uid201_lzCountValAdd_uid69_fpFusedAddSubTest_merged_bit_select_b <= vStagei_uid199_lzCountValAdd_uid69_fpFusedAddSubTest_q(15 downto 8);
    rVStage_uid201_lzCountValAdd_uid69_fpFusedAddSubTest_merged_bit_select_c <= vStagei_uid199_lzCountValAdd_uid69_fpFusedAddSubTest_q(7 downto 0);

    -- vCount_uid202_lzCountValAdd_uid69_fpFusedAddSubTest(LOGICAL,201)@1
    vCount_uid202_lzCountValAdd_uid69_fpFusedAddSubTest_q <= "1" WHEN rVStage_uid201_lzCountValAdd_uid69_fpFusedAddSubTest_merged_bit_select_b = cstAllZWE_uid13_fpFusedAddSubTest_q ELSE "0";

    -- vStagei_uid205_lzCountValAdd_uid69_fpFusedAddSubTest(MUX,204)@1
    vStagei_uid205_lzCountValAdd_uid69_fpFusedAddSubTest_s <= vCount_uid202_lzCountValAdd_uid69_fpFusedAddSubTest_q;
    vStagei_uid205_lzCountValAdd_uid69_fpFusedAddSubTest_combproc: PROCESS (vStagei_uid205_lzCountValAdd_uid69_fpFusedAddSubTest_s, rVStage_uid201_lzCountValAdd_uid69_fpFusedAddSubTest_merged_bit_select_b, rVStage_uid201_lzCountValAdd_uid69_fpFusedAddSubTest_merged_bit_select_c)
    BEGIN
        CASE (vStagei_uid205_lzCountValAdd_uid69_fpFusedAddSubTest_s) IS
            WHEN "0" => vStagei_uid205_lzCountValAdd_uid69_fpFusedAddSubTest_q <= rVStage_uid201_lzCountValAdd_uid69_fpFusedAddSubTest_merged_bit_select_b;
            WHEN "1" => vStagei_uid205_lzCountValAdd_uid69_fpFusedAddSubTest_q <= rVStage_uid201_lzCountValAdd_uid69_fpFusedAddSubTest_merged_bit_select_c;
            WHEN OTHERS => vStagei_uid205_lzCountValAdd_uid69_fpFusedAddSubTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- rVStage_uid207_lzCountValAdd_uid69_fpFusedAddSubTest_merged_bit_select(BITSELECT,348)@1
    rVStage_uid207_lzCountValAdd_uid69_fpFusedAddSubTest_merged_bit_select_b <= vStagei_uid205_lzCountValAdd_uid69_fpFusedAddSubTest_q(7 downto 4);
    rVStage_uid207_lzCountValAdd_uid69_fpFusedAddSubTest_merged_bit_select_c <= vStagei_uid205_lzCountValAdd_uid69_fpFusedAddSubTest_q(3 downto 0);

    -- vCount_uid208_lzCountValAdd_uid69_fpFusedAddSubTest(LOGICAL,207)@1
    vCount_uid208_lzCountValAdd_uid69_fpFusedAddSubTest_q <= "1" WHEN rVStage_uid207_lzCountValAdd_uid69_fpFusedAddSubTest_merged_bit_select_b = zs_uid175_lzCountValSub_uid67_fpFusedAddSubTest_q ELSE "0";

    -- vStagei_uid211_lzCountValAdd_uid69_fpFusedAddSubTest(MUX,210)@1
    vStagei_uid211_lzCountValAdd_uid69_fpFusedAddSubTest_s <= vCount_uid208_lzCountValAdd_uid69_fpFusedAddSubTest_q;
    vStagei_uid211_lzCountValAdd_uid69_fpFusedAddSubTest_combproc: PROCESS (vStagei_uid211_lzCountValAdd_uid69_fpFusedAddSubTest_s, rVStage_uid207_lzCountValAdd_uid69_fpFusedAddSubTest_merged_bit_select_b, rVStage_uid207_lzCountValAdd_uid69_fpFusedAddSubTest_merged_bit_select_c)
    BEGIN
        CASE (vStagei_uid211_lzCountValAdd_uid69_fpFusedAddSubTest_s) IS
            WHEN "0" => vStagei_uid211_lzCountValAdd_uid69_fpFusedAddSubTest_q <= rVStage_uid207_lzCountValAdd_uid69_fpFusedAddSubTest_merged_bit_select_b;
            WHEN "1" => vStagei_uid211_lzCountValAdd_uid69_fpFusedAddSubTest_q <= rVStage_uid207_lzCountValAdd_uid69_fpFusedAddSubTest_merged_bit_select_c;
            WHEN OTHERS => vStagei_uid211_lzCountValAdd_uid69_fpFusedAddSubTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- rVStage_uid213_lzCountValAdd_uid69_fpFusedAddSubTest_merged_bit_select(BITSELECT,349)@1
    rVStage_uid213_lzCountValAdd_uid69_fpFusedAddSubTest_merged_bit_select_b <= vStagei_uid211_lzCountValAdd_uid69_fpFusedAddSubTest_q(3 downto 2);
    rVStage_uid213_lzCountValAdd_uid69_fpFusedAddSubTest_merged_bit_select_c <= vStagei_uid211_lzCountValAdd_uid69_fpFusedAddSubTest_q(1 downto 0);

    -- vCount_uid214_lzCountValAdd_uid69_fpFusedAddSubTest(LOGICAL,213)@1
    vCount_uid214_lzCountValAdd_uid69_fpFusedAddSubTest_q <= "1" WHEN rVStage_uid213_lzCountValAdd_uid69_fpFusedAddSubTest_merged_bit_select_b = zs_uid181_lzCountValSub_uid67_fpFusedAddSubTest_q ELSE "0";

    -- vStagei_uid217_lzCountValAdd_uid69_fpFusedAddSubTest(MUX,216)@1
    vStagei_uid217_lzCountValAdd_uid69_fpFusedAddSubTest_s <= vCount_uid214_lzCountValAdd_uid69_fpFusedAddSubTest_q;
    vStagei_uid217_lzCountValAdd_uid69_fpFusedAddSubTest_combproc: PROCESS (vStagei_uid217_lzCountValAdd_uid69_fpFusedAddSubTest_s, rVStage_uid213_lzCountValAdd_uid69_fpFusedAddSubTest_merged_bit_select_b, rVStage_uid213_lzCountValAdd_uid69_fpFusedAddSubTest_merged_bit_select_c)
    BEGIN
        CASE (vStagei_uid217_lzCountValAdd_uid69_fpFusedAddSubTest_s) IS
            WHEN "0" => vStagei_uid217_lzCountValAdd_uid69_fpFusedAddSubTest_q <= rVStage_uid213_lzCountValAdd_uid69_fpFusedAddSubTest_merged_bit_select_b;
            WHEN "1" => vStagei_uid217_lzCountValAdd_uid69_fpFusedAddSubTest_q <= rVStage_uid213_lzCountValAdd_uid69_fpFusedAddSubTest_merged_bit_select_c;
            WHEN OTHERS => vStagei_uid217_lzCountValAdd_uid69_fpFusedAddSubTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- rVStage_uid219_lzCountValAdd_uid69_fpFusedAddSubTest(BITSELECT,218)@1
    rVStage_uid219_lzCountValAdd_uid69_fpFusedAddSubTest_b <= vStagei_uid217_lzCountValAdd_uid69_fpFusedAddSubTest_q(1 downto 1);

    -- vCount_uid220_lzCountValAdd_uid69_fpFusedAddSubTest(LOGICAL,219)@1
    vCount_uid220_lzCountValAdd_uid69_fpFusedAddSubTest_q <= "1" WHEN rVStage_uid219_lzCountValAdd_uid69_fpFusedAddSubTest_b = GND_q ELSE "0";

    -- r_uid221_lzCountValAdd_uid69_fpFusedAddSubTest(BITJOIN,220)@1
    r_uid221_lzCountValAdd_uid69_fpFusedAddSubTest_q <= vCount_uid194_lzCountValAdd_uid69_fpFusedAddSubTest_q & vCount_uid202_lzCountValAdd_uid69_fpFusedAddSubTest_q & vCount_uid208_lzCountValAdd_uid69_fpFusedAddSubTest_q & vCount_uid214_lzCountValAdd_uid69_fpFusedAddSubTest_q & vCount_uid220_lzCountValAdd_uid69_fpFusedAddSubTest_q;

    -- expInc_uid73_fpFusedAddSubTest(ADD,72)@1
    expInc_uid73_fpFusedAddSubTest_a <= STD_LOGIC_VECTOR("0" & exp_siga_uid14_fpFusedAddSubTest_b);
    expInc_uid73_fpFusedAddSubTest_b <= STD_LOGIC_VECTOR("00000000" & VCC_q);
    expInc_uid73_fpFusedAddSubTest_o <= STD_LOGIC_VECTOR(UNSIGNED(expInc_uid73_fpFusedAddSubTest_a) + UNSIGNED(expInc_uid73_fpFusedAddSubTest_b));
    expInc_uid73_fpFusedAddSubTest_q <= expInc_uid73_fpFusedAddSubTest_o(8 downto 0);

    -- expPostNormAdd_uid75_fpFusedAddSubTest(SUB,74)@1
    expPostNormAdd_uid75_fpFusedAddSubTest_a <= STD_LOGIC_VECTOR("0" & expInc_uid73_fpFusedAddSubTest_q);
    expPostNormAdd_uid75_fpFusedAddSubTest_b <= STD_LOGIC_VECTOR("00000" & r_uid221_lzCountValAdd_uid69_fpFusedAddSubTest_q);
    expPostNormAdd_uid75_fpFusedAddSubTest_o <= STD_LOGIC_VECTOR(UNSIGNED(expPostNormAdd_uid75_fpFusedAddSubTest_a) - UNSIGNED(expPostNormAdd_uid75_fpFusedAddSubTest_b));
    expPostNormAdd_uid75_fpFusedAddSubTest_q <= expPostNormAdd_uid75_fpFusedAddSubTest_o(9 downto 0);

    -- leftShiftStage1Idx3Rng3_uid323_fracPostNormAdd_uid70_fpFusedAddSubTest(BITSELECT,322)@1
    leftShiftStage1Idx3Rng3_uid323_fracPostNormAdd_uid70_fpFusedAddSubTest_in <= leftShiftStage0_uid315_fracPostNormAdd_uid70_fpFusedAddSubTest_mfinal_q(22 downto 0);
    leftShiftStage1Idx3Rng3_uid323_fracPostNormAdd_uid70_fpFusedAddSubTest_b <= leftShiftStage1Idx3Rng3_uid323_fracPostNormAdd_uid70_fpFusedAddSubTest_in(22 downto 0);

    -- leftShiftStage1Idx3_uid324_fracPostNormAdd_uid70_fpFusedAddSubTest(BITJOIN,323)@1
    leftShiftStage1Idx3_uid324_fracPostNormAdd_uid70_fpFusedAddSubTest_q <= leftShiftStage1Idx3Rng3_uid323_fracPostNormAdd_uid70_fpFusedAddSubTest_b & rightShiftStage1Idx3Pad3_uid253_alignmentShifter_uid59_fpFusedAddSubTest_q;

    -- leftShiftStage1Idx2Rng2_uid320_fracPostNormAdd_uid70_fpFusedAddSubTest(BITSELECT,319)@1
    leftShiftStage1Idx2Rng2_uid320_fracPostNormAdd_uid70_fpFusedAddSubTest_in <= leftShiftStage0_uid315_fracPostNormAdd_uid70_fpFusedAddSubTest_mfinal_q(23 downto 0);
    leftShiftStage1Idx2Rng2_uid320_fracPostNormAdd_uid70_fpFusedAddSubTest_b <= leftShiftStage1Idx2Rng2_uid320_fracPostNormAdd_uid70_fpFusedAddSubTest_in(23 downto 0);

    -- leftShiftStage1Idx2_uid321_fracPostNormAdd_uid70_fpFusedAddSubTest(BITJOIN,320)@1
    leftShiftStage1Idx2_uid321_fracPostNormAdd_uid70_fpFusedAddSubTest_q <= leftShiftStage1Idx2Rng2_uid320_fracPostNormAdd_uid70_fpFusedAddSubTest_b & zs_uid181_lzCountValSub_uid67_fpFusedAddSubTest_q;

    -- leftShiftStage1Idx1Rng1_uid317_fracPostNormAdd_uid70_fpFusedAddSubTest(BITSELECT,316)@1
    leftShiftStage1Idx1Rng1_uid317_fracPostNormAdd_uid70_fpFusedAddSubTest_in <= leftShiftStage0_uid315_fracPostNormAdd_uid70_fpFusedAddSubTest_mfinal_q(24 downto 0);
    leftShiftStage1Idx1Rng1_uid317_fracPostNormAdd_uid70_fpFusedAddSubTest_b <= leftShiftStage1Idx1Rng1_uid317_fracPostNormAdd_uid70_fpFusedAddSubTest_in(24 downto 0);

    -- leftShiftStage1Idx1_uid318_fracPostNormAdd_uid70_fpFusedAddSubTest(BITJOIN,317)@1
    leftShiftStage1Idx1_uid318_fracPostNormAdd_uid70_fpFusedAddSubTest_q <= leftShiftStage1Idx1Rng1_uid317_fracPostNormAdd_uid70_fpFusedAddSubTest_b & GND_q;

    -- leftShiftStage0Idx7_uid278_fracPostNormSub_uid68_fpFusedAddSubTest(CONSTANT,277)
    leftShiftStage0Idx7_uid278_fracPostNormSub_uid68_fpFusedAddSubTest_q <= "00000000000000000000000000";

    -- leftShiftStage0Idx6Rng24_uid311_fracPostNormAdd_uid70_fpFusedAddSubTest(BITSELECT,310)@1
    leftShiftStage0Idx6Rng24_uid311_fracPostNormAdd_uid70_fpFusedAddSubTest_in <= fracResAddNoSignExt_uid66_fpFusedAddSubTest_b(1 downto 0);
    leftShiftStage0Idx6Rng24_uid311_fracPostNormAdd_uid70_fpFusedAddSubTest_b <= leftShiftStage0Idx6Rng24_uid311_fracPostNormAdd_uid70_fpFusedAddSubTest_in(1 downto 0);

    -- leftShiftStage0Idx6_uid312_fracPostNormAdd_uid70_fpFusedAddSubTest(BITJOIN,311)@1
    leftShiftStage0Idx6_uid312_fracPostNormAdd_uid70_fpFusedAddSubTest_q <= leftShiftStage0Idx6Rng24_uid311_fracPostNormAdd_uid70_fpFusedAddSubTest_b & rightShiftStage0Idx6Pad24_uid241_alignmentShifter_uid59_fpFusedAddSubTest_q;

    -- leftShiftStage0Idx5Rng20_uid308_fracPostNormAdd_uid70_fpFusedAddSubTest(BITSELECT,307)@1
    leftShiftStage0Idx5Rng20_uid308_fracPostNormAdd_uid70_fpFusedAddSubTest_in <= fracResAddNoSignExt_uid66_fpFusedAddSubTest_b(5 downto 0);
    leftShiftStage0Idx5Rng20_uid308_fracPostNormAdd_uid70_fpFusedAddSubTest_b <= leftShiftStage0Idx5Rng20_uid308_fracPostNormAdd_uid70_fpFusedAddSubTest_in(5 downto 0);

    -- leftShiftStage0Idx5_uid309_fracPostNormAdd_uid70_fpFusedAddSubTest(BITJOIN,308)@1
    leftShiftStage0Idx5_uid309_fracPostNormAdd_uid70_fpFusedAddSubTest_q <= leftShiftStage0Idx5Rng20_uid308_fracPostNormAdd_uid70_fpFusedAddSubTest_b & rightShiftStage0Idx5Pad20_uid238_alignmentShifter_uid59_fpFusedAddSubTest_q;

    -- leftShiftStage0Idx4_uid306_fracPostNormAdd_uid70_fpFusedAddSubTest(BITJOIN,305)@1
    leftShiftStage0Idx4_uid306_fracPostNormAdd_uid70_fpFusedAddSubTest_q <= vStage_uid196_lzCountValAdd_uid69_fpFusedAddSubTest_b & zs_uid161_lzCountValSub_uid67_fpFusedAddSubTest_q;

    -- leftShiftStage0_uid315_fracPostNormAdd_uid70_fpFusedAddSubTest_msplit_1(MUX,340)@1
    leftShiftStage0_uid315_fracPostNormAdd_uid70_fpFusedAddSubTest_msplit_1_s <= leftShiftStage0_uid315_fracPostNormAdd_uid70_fpFusedAddSubTest_selLSBs_merged_bit_select_b;
    leftShiftStage0_uid315_fracPostNormAdd_uid70_fpFusedAddSubTest_msplit_1_combproc: PROCESS (leftShiftStage0_uid315_fracPostNormAdd_uid70_fpFusedAddSubTest_msplit_1_s, leftShiftStage0Idx4_uid306_fracPostNormAdd_uid70_fpFusedAddSubTest_q, leftShiftStage0Idx5_uid309_fracPostNormAdd_uid70_fpFusedAddSubTest_q, leftShiftStage0Idx6_uid312_fracPostNormAdd_uid70_fpFusedAddSubTest_q, leftShiftStage0Idx7_uid278_fracPostNormSub_uid68_fpFusedAddSubTest_q)
    BEGIN
        CASE (leftShiftStage0_uid315_fracPostNormAdd_uid70_fpFusedAddSubTest_msplit_1_s) IS
            WHEN "00" => leftShiftStage0_uid315_fracPostNormAdd_uid70_fpFusedAddSubTest_msplit_1_q <= leftShiftStage0Idx4_uid306_fracPostNormAdd_uid70_fpFusedAddSubTest_q;
            WHEN "01" => leftShiftStage0_uid315_fracPostNormAdd_uid70_fpFusedAddSubTest_msplit_1_q <= leftShiftStage0Idx5_uid309_fracPostNormAdd_uid70_fpFusedAddSubTest_q;
            WHEN "10" => leftShiftStage0_uid315_fracPostNormAdd_uid70_fpFusedAddSubTest_msplit_1_q <= leftShiftStage0Idx6_uid312_fracPostNormAdd_uid70_fpFusedAddSubTest_q;
            WHEN "11" => leftShiftStage0_uid315_fracPostNormAdd_uid70_fpFusedAddSubTest_msplit_1_q <= leftShiftStage0Idx7_uid278_fracPostNormSub_uid68_fpFusedAddSubTest_q;
            WHEN OTHERS => leftShiftStage0_uid315_fracPostNormAdd_uid70_fpFusedAddSubTest_msplit_1_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- leftShiftStage0Idx3Rng12_uid302_fracPostNormAdd_uid70_fpFusedAddSubTest(BITSELECT,301)@1
    leftShiftStage0Idx3Rng12_uid302_fracPostNormAdd_uid70_fpFusedAddSubTest_in <= fracResAddNoSignExt_uid66_fpFusedAddSubTest_b(13 downto 0);
    leftShiftStage0Idx3Rng12_uid302_fracPostNormAdd_uid70_fpFusedAddSubTest_b <= leftShiftStage0Idx3Rng12_uid302_fracPostNormAdd_uid70_fpFusedAddSubTest_in(13 downto 0);

    -- leftShiftStage0Idx3_uid303_fracPostNormAdd_uid70_fpFusedAddSubTest(BITJOIN,302)@1
    leftShiftStage0Idx3_uid303_fracPostNormAdd_uid70_fpFusedAddSubTest_q <= leftShiftStage0Idx3Rng12_uid302_fracPostNormAdd_uid70_fpFusedAddSubTest_b & rightShiftStage0Idx3Pad12_uid232_alignmentShifter_uid59_fpFusedAddSubTest_q;

    -- leftShiftStage0Idx2Rng8_uid299_fracPostNormAdd_uid70_fpFusedAddSubTest(BITSELECT,298)@1
    leftShiftStage0Idx2Rng8_uid299_fracPostNormAdd_uid70_fpFusedAddSubTest_in <= fracResAddNoSignExt_uid66_fpFusedAddSubTest_b(17 downto 0);
    leftShiftStage0Idx2Rng8_uid299_fracPostNormAdd_uid70_fpFusedAddSubTest_b <= leftShiftStage0Idx2Rng8_uid299_fracPostNormAdd_uid70_fpFusedAddSubTest_in(17 downto 0);

    -- leftShiftStage0Idx2_uid300_fracPostNormAdd_uid70_fpFusedAddSubTest(BITJOIN,299)@1
    leftShiftStage0Idx2_uid300_fracPostNormAdd_uid70_fpFusedAddSubTest_q <= leftShiftStage0Idx2Rng8_uid299_fracPostNormAdd_uid70_fpFusedAddSubTest_b & cstAllZWE_uid13_fpFusedAddSubTest_q;

    -- leftShiftStage0Idx1Rng4_uid296_fracPostNormAdd_uid70_fpFusedAddSubTest(BITSELECT,295)@1
    leftShiftStage0Idx1Rng4_uid296_fracPostNormAdd_uid70_fpFusedAddSubTest_in <= fracResAddNoSignExt_uid66_fpFusedAddSubTest_b(21 downto 0);
    leftShiftStage0Idx1Rng4_uid296_fracPostNormAdd_uid70_fpFusedAddSubTest_b <= leftShiftStage0Idx1Rng4_uid296_fracPostNormAdd_uid70_fpFusedAddSubTest_in(21 downto 0);

    -- leftShiftStage0Idx1_uid297_fracPostNormAdd_uid70_fpFusedAddSubTest(BITJOIN,296)@1
    leftShiftStage0Idx1_uid297_fracPostNormAdd_uid70_fpFusedAddSubTest_q <= leftShiftStage0Idx1Rng4_uid296_fracPostNormAdd_uid70_fpFusedAddSubTest_b & zs_uid175_lzCountValSub_uid67_fpFusedAddSubTest_q;

    -- leftShiftStage0_uid315_fracPostNormAdd_uid70_fpFusedAddSubTest_msplit_0(MUX,339)@1
    leftShiftStage0_uid315_fracPostNormAdd_uid70_fpFusedAddSubTest_msplit_0_s <= leftShiftStage0_uid315_fracPostNormAdd_uid70_fpFusedAddSubTest_selLSBs_merged_bit_select_b;
    leftShiftStage0_uid315_fracPostNormAdd_uid70_fpFusedAddSubTest_msplit_0_combproc: PROCESS (leftShiftStage0_uid315_fracPostNormAdd_uid70_fpFusedAddSubTest_msplit_0_s, fracResAddNoSignExt_uid66_fpFusedAddSubTest_b, leftShiftStage0Idx1_uid297_fracPostNormAdd_uid70_fpFusedAddSubTest_q, leftShiftStage0Idx2_uid300_fracPostNormAdd_uid70_fpFusedAddSubTest_q, leftShiftStage0Idx3_uid303_fracPostNormAdd_uid70_fpFusedAddSubTest_q)
    BEGIN
        CASE (leftShiftStage0_uid315_fracPostNormAdd_uid70_fpFusedAddSubTest_msplit_0_s) IS
            WHEN "00" => leftShiftStage0_uid315_fracPostNormAdd_uid70_fpFusedAddSubTest_msplit_0_q <= fracResAddNoSignExt_uid66_fpFusedAddSubTest_b;
            WHEN "01" => leftShiftStage0_uid315_fracPostNormAdd_uid70_fpFusedAddSubTest_msplit_0_q <= leftShiftStage0Idx1_uid297_fracPostNormAdd_uid70_fpFusedAddSubTest_q;
            WHEN "10" => leftShiftStage0_uid315_fracPostNormAdd_uid70_fpFusedAddSubTest_msplit_0_q <= leftShiftStage0Idx2_uid300_fracPostNormAdd_uid70_fpFusedAddSubTest_q;
            WHEN "11" => leftShiftStage0_uid315_fracPostNormAdd_uid70_fpFusedAddSubTest_msplit_0_q <= leftShiftStage0Idx3_uid303_fracPostNormAdd_uid70_fpFusedAddSubTest_q;
            WHEN OTHERS => leftShiftStage0_uid315_fracPostNormAdd_uid70_fpFusedAddSubTest_msplit_0_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- leftShiftStage0_uid315_fracPostNormAdd_uid70_fpFusedAddSubTest_selLSBs_merged_bit_select(BITSELECT,353)@1
    leftShiftStage0_uid315_fracPostNormAdd_uid70_fpFusedAddSubTest_selLSBs_merged_bit_select_b <= leftShiftStageSel4Dto2_uid314_fracPostNormAdd_uid70_fpFusedAddSubTest_merged_bit_select_b(1 downto 0);
    leftShiftStage0_uid315_fracPostNormAdd_uid70_fpFusedAddSubTest_selLSBs_merged_bit_select_c <= leftShiftStageSel4Dto2_uid314_fracPostNormAdd_uid70_fpFusedAddSubTest_merged_bit_select_b(2 downto 2);

    -- leftShiftStage0_uid315_fracPostNormAdd_uid70_fpFusedAddSubTest_mfinal(MUX,341)@1
    leftShiftStage0_uid315_fracPostNormAdd_uid70_fpFusedAddSubTest_mfinal_s <= leftShiftStage0_uid315_fracPostNormAdd_uid70_fpFusedAddSubTest_selLSBs_merged_bit_select_c;
    leftShiftStage0_uid315_fracPostNormAdd_uid70_fpFusedAddSubTest_mfinal_combproc: PROCESS (leftShiftStage0_uid315_fracPostNormAdd_uid70_fpFusedAddSubTest_mfinal_s, leftShiftStage0_uid315_fracPostNormAdd_uid70_fpFusedAddSubTest_msplit_0_q, leftShiftStage0_uid315_fracPostNormAdd_uid70_fpFusedAddSubTest_msplit_1_q)
    BEGIN
        CASE (leftShiftStage0_uid315_fracPostNormAdd_uid70_fpFusedAddSubTest_mfinal_s) IS
            WHEN "0" => leftShiftStage0_uid315_fracPostNormAdd_uid70_fpFusedAddSubTest_mfinal_q <= leftShiftStage0_uid315_fracPostNormAdd_uid70_fpFusedAddSubTest_msplit_0_q;
            WHEN "1" => leftShiftStage0_uid315_fracPostNormAdd_uid70_fpFusedAddSubTest_mfinal_q <= leftShiftStage0_uid315_fracPostNormAdd_uid70_fpFusedAddSubTest_msplit_1_q;
            WHEN OTHERS => leftShiftStage0_uid315_fracPostNormAdd_uid70_fpFusedAddSubTest_mfinal_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- leftShiftStageSel4Dto2_uid314_fracPostNormAdd_uid70_fpFusedAddSubTest_merged_bit_select(BITSELECT,350)@1
    leftShiftStageSel4Dto2_uid314_fracPostNormAdd_uid70_fpFusedAddSubTest_merged_bit_select_b <= r_uid221_lzCountValAdd_uid69_fpFusedAddSubTest_q(4 downto 2);
    leftShiftStageSel4Dto2_uid314_fracPostNormAdd_uid70_fpFusedAddSubTest_merged_bit_select_c <= r_uid221_lzCountValAdd_uid69_fpFusedAddSubTest_q(1 downto 0);

    -- leftShiftStage1_uid326_fracPostNormAdd_uid70_fpFusedAddSubTest(MUX,325)@1
    leftShiftStage1_uid326_fracPostNormAdd_uid70_fpFusedAddSubTest_s <= leftShiftStageSel4Dto2_uid314_fracPostNormAdd_uid70_fpFusedAddSubTest_merged_bit_select_c;
    leftShiftStage1_uid326_fracPostNormAdd_uid70_fpFusedAddSubTest_combproc: PROCESS (leftShiftStage1_uid326_fracPostNormAdd_uid70_fpFusedAddSubTest_s, leftShiftStage0_uid315_fracPostNormAdd_uid70_fpFusedAddSubTest_mfinal_q, leftShiftStage1Idx1_uid318_fracPostNormAdd_uid70_fpFusedAddSubTest_q, leftShiftStage1Idx2_uid321_fracPostNormAdd_uid70_fpFusedAddSubTest_q, leftShiftStage1Idx3_uid324_fracPostNormAdd_uid70_fpFusedAddSubTest_q)
    BEGIN
        CASE (leftShiftStage1_uid326_fracPostNormAdd_uid70_fpFusedAddSubTest_s) IS
            WHEN "00" => leftShiftStage1_uid326_fracPostNormAdd_uid70_fpFusedAddSubTest_q <= leftShiftStage0_uid315_fracPostNormAdd_uid70_fpFusedAddSubTest_mfinal_q;
            WHEN "01" => leftShiftStage1_uid326_fracPostNormAdd_uid70_fpFusedAddSubTest_q <= leftShiftStage1Idx1_uid318_fracPostNormAdd_uid70_fpFusedAddSubTest_q;
            WHEN "10" => leftShiftStage1_uid326_fracPostNormAdd_uid70_fpFusedAddSubTest_q <= leftShiftStage1Idx2_uid321_fracPostNormAdd_uid70_fpFusedAddSubTest_q;
            WHEN "11" => leftShiftStage1_uid326_fracPostNormAdd_uid70_fpFusedAddSubTest_q <= leftShiftStage1Idx3_uid324_fracPostNormAdd_uid70_fpFusedAddSubTest_q;
            WHEN OTHERS => leftShiftStage1_uid326_fracPostNormAdd_uid70_fpFusedAddSubTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- fracPostNormAddRndRange_uid78_fpFusedAddSubTest(BITSELECT,77)@1
    fracPostNormAddRndRange_uid78_fpFusedAddSubTest_in <= leftShiftStage1_uid326_fracPostNormAdd_uid70_fpFusedAddSubTest_q(24 downto 0);
    fracPostNormAddRndRange_uid78_fpFusedAddSubTest_b <= fracPostNormAddRndRange_uid78_fpFusedAddSubTest_in(24 downto 1);

    -- expFracRAdd_uid79_fpFusedAddSubTest(BITJOIN,78)@1
    expFracRAdd_uid79_fpFusedAddSubTest_q <= expPostNormAdd_uid75_fpFusedAddSubTest_q & fracPostNormAddRndRange_uid78_fpFusedAddSubTest_b;

    -- expRPreExcAdd_uid89_fpFusedAddSubTest(BITSELECT,88)@1
    expRPreExcAdd_uid89_fpFusedAddSubTest_in <= expFracRAdd_uid79_fpFusedAddSubTest_q(31 downto 0);
    expRPreExcAdd_uid89_fpFusedAddSubTest_b <= expRPreExcAdd_uid89_fpFusedAddSubTest_in(31 downto 24);

    -- expPostNormSub_uid74_fpFusedAddSubTest(SUB,73)@1
    expPostNormSub_uid74_fpFusedAddSubTest_a <= STD_LOGIC_VECTOR("0" & expInc_uid73_fpFusedAddSubTest_q);
    expPostNormSub_uid74_fpFusedAddSubTest_b <= STD_LOGIC_VECTOR("00000" & r_uid190_lzCountValSub_uid67_fpFusedAddSubTest_q);
    expPostNormSub_uid74_fpFusedAddSubTest_o <= STD_LOGIC_VECTOR(UNSIGNED(expPostNormSub_uid74_fpFusedAddSubTest_a) - UNSIGNED(expPostNormSub_uid74_fpFusedAddSubTest_b));
    expPostNormSub_uid74_fpFusedAddSubTest_q <= expPostNormSub_uid74_fpFusedAddSubTest_o(9 downto 0);

    -- leftShiftStage1Idx3Rng3_uid288_fracPostNormSub_uid68_fpFusedAddSubTest(BITSELECT,287)@1
    leftShiftStage1Idx3Rng3_uid288_fracPostNormSub_uid68_fpFusedAddSubTest_in <= leftShiftStage0_uid280_fracPostNormSub_uid68_fpFusedAddSubTest_mfinal_q(22 downto 0);
    leftShiftStage1Idx3Rng3_uid288_fracPostNormSub_uid68_fpFusedAddSubTest_b <= leftShiftStage1Idx3Rng3_uid288_fracPostNormSub_uid68_fpFusedAddSubTest_in(22 downto 0);

    -- leftShiftStage1Idx3_uid289_fracPostNormSub_uid68_fpFusedAddSubTest(BITJOIN,288)@1
    leftShiftStage1Idx3_uid289_fracPostNormSub_uid68_fpFusedAddSubTest_q <= leftShiftStage1Idx3Rng3_uid288_fracPostNormSub_uid68_fpFusedAddSubTest_b & rightShiftStage1Idx3Pad3_uid253_alignmentShifter_uid59_fpFusedAddSubTest_q;

    -- leftShiftStage1Idx2Rng2_uid285_fracPostNormSub_uid68_fpFusedAddSubTest(BITSELECT,284)@1
    leftShiftStage1Idx2Rng2_uid285_fracPostNormSub_uid68_fpFusedAddSubTest_in <= leftShiftStage0_uid280_fracPostNormSub_uid68_fpFusedAddSubTest_mfinal_q(23 downto 0);
    leftShiftStage1Idx2Rng2_uid285_fracPostNormSub_uid68_fpFusedAddSubTest_b <= leftShiftStage1Idx2Rng2_uid285_fracPostNormSub_uid68_fpFusedAddSubTest_in(23 downto 0);

    -- leftShiftStage1Idx2_uid286_fracPostNormSub_uid68_fpFusedAddSubTest(BITJOIN,285)@1
    leftShiftStage1Idx2_uid286_fracPostNormSub_uid68_fpFusedAddSubTest_q <= leftShiftStage1Idx2Rng2_uid285_fracPostNormSub_uid68_fpFusedAddSubTest_b & zs_uid181_lzCountValSub_uid67_fpFusedAddSubTest_q;

    -- leftShiftStage1Idx1Rng1_uid282_fracPostNormSub_uid68_fpFusedAddSubTest(BITSELECT,281)@1
    leftShiftStage1Idx1Rng1_uid282_fracPostNormSub_uid68_fpFusedAddSubTest_in <= leftShiftStage0_uid280_fracPostNormSub_uid68_fpFusedAddSubTest_mfinal_q(24 downto 0);
    leftShiftStage1Idx1Rng1_uid282_fracPostNormSub_uid68_fpFusedAddSubTest_b <= leftShiftStage1Idx1Rng1_uid282_fracPostNormSub_uid68_fpFusedAddSubTest_in(24 downto 0);

    -- leftShiftStage1Idx1_uid283_fracPostNormSub_uid68_fpFusedAddSubTest(BITJOIN,282)@1
    leftShiftStage1Idx1_uid283_fracPostNormSub_uid68_fpFusedAddSubTest_q <= leftShiftStage1Idx1Rng1_uid282_fracPostNormSub_uid68_fpFusedAddSubTest_b & GND_q;

    -- leftShiftStage0Idx6Rng24_uid276_fracPostNormSub_uid68_fpFusedAddSubTest(BITSELECT,275)@1
    leftShiftStage0Idx6Rng24_uid276_fracPostNormSub_uid68_fpFusedAddSubTest_in <= fracResSubNoSignExt_uid65_fpFusedAddSubTest_b(1 downto 0);
    leftShiftStage0Idx6Rng24_uid276_fracPostNormSub_uid68_fpFusedAddSubTest_b <= leftShiftStage0Idx6Rng24_uid276_fracPostNormSub_uid68_fpFusedAddSubTest_in(1 downto 0);

    -- leftShiftStage0Idx6_uid277_fracPostNormSub_uid68_fpFusedAddSubTest(BITJOIN,276)@1
    leftShiftStage0Idx6_uid277_fracPostNormSub_uid68_fpFusedAddSubTest_q <= leftShiftStage0Idx6Rng24_uid276_fracPostNormSub_uid68_fpFusedAddSubTest_b & rightShiftStage0Idx6Pad24_uid241_alignmentShifter_uid59_fpFusedAddSubTest_q;

    -- leftShiftStage0Idx5Rng20_uid273_fracPostNormSub_uid68_fpFusedAddSubTest(BITSELECT,272)@1
    leftShiftStage0Idx5Rng20_uid273_fracPostNormSub_uid68_fpFusedAddSubTest_in <= fracResSubNoSignExt_uid65_fpFusedAddSubTest_b(5 downto 0);
    leftShiftStage0Idx5Rng20_uid273_fracPostNormSub_uid68_fpFusedAddSubTest_b <= leftShiftStage0Idx5Rng20_uid273_fracPostNormSub_uid68_fpFusedAddSubTest_in(5 downto 0);

    -- leftShiftStage0Idx5_uid274_fracPostNormSub_uid68_fpFusedAddSubTest(BITJOIN,273)@1
    leftShiftStage0Idx5_uid274_fracPostNormSub_uid68_fpFusedAddSubTest_q <= leftShiftStage0Idx5Rng20_uid273_fracPostNormSub_uid68_fpFusedAddSubTest_b & rightShiftStage0Idx5Pad20_uid238_alignmentShifter_uid59_fpFusedAddSubTest_q;

    -- leftShiftStage0Idx4_uid271_fracPostNormSub_uid68_fpFusedAddSubTest(BITJOIN,270)@1
    leftShiftStage0Idx4_uid271_fracPostNormSub_uid68_fpFusedAddSubTest_q <= vStage_uid165_lzCountValSub_uid67_fpFusedAddSubTest_b & zs_uid161_lzCountValSub_uid67_fpFusedAddSubTest_q;

    -- leftShiftStage0_uid280_fracPostNormSub_uid68_fpFusedAddSubTest_msplit_1(MUX,335)@1
    leftShiftStage0_uid280_fracPostNormSub_uid68_fpFusedAddSubTest_msplit_1_s <= leftShiftStage0_uid280_fracPostNormSub_uid68_fpFusedAddSubTest_selLSBs_merged_bit_select_b;
    leftShiftStage0_uid280_fracPostNormSub_uid68_fpFusedAddSubTest_msplit_1_combproc: PROCESS (leftShiftStage0_uid280_fracPostNormSub_uid68_fpFusedAddSubTest_msplit_1_s, leftShiftStage0Idx4_uid271_fracPostNormSub_uid68_fpFusedAddSubTest_q, leftShiftStage0Idx5_uid274_fracPostNormSub_uid68_fpFusedAddSubTest_q, leftShiftStage0Idx6_uid277_fracPostNormSub_uid68_fpFusedAddSubTest_q, leftShiftStage0Idx7_uid278_fracPostNormSub_uid68_fpFusedAddSubTest_q)
    BEGIN
        CASE (leftShiftStage0_uid280_fracPostNormSub_uid68_fpFusedAddSubTest_msplit_1_s) IS
            WHEN "00" => leftShiftStage0_uid280_fracPostNormSub_uid68_fpFusedAddSubTest_msplit_1_q <= leftShiftStage0Idx4_uid271_fracPostNormSub_uid68_fpFusedAddSubTest_q;
            WHEN "01" => leftShiftStage0_uid280_fracPostNormSub_uid68_fpFusedAddSubTest_msplit_1_q <= leftShiftStage0Idx5_uid274_fracPostNormSub_uid68_fpFusedAddSubTest_q;
            WHEN "10" => leftShiftStage0_uid280_fracPostNormSub_uid68_fpFusedAddSubTest_msplit_1_q <= leftShiftStage0Idx6_uid277_fracPostNormSub_uid68_fpFusedAddSubTest_q;
            WHEN "11" => leftShiftStage0_uid280_fracPostNormSub_uid68_fpFusedAddSubTest_msplit_1_q <= leftShiftStage0Idx7_uid278_fracPostNormSub_uid68_fpFusedAddSubTest_q;
            WHEN OTHERS => leftShiftStage0_uid280_fracPostNormSub_uid68_fpFusedAddSubTest_msplit_1_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- leftShiftStage0Idx3Rng12_uid267_fracPostNormSub_uid68_fpFusedAddSubTest(BITSELECT,266)@1
    leftShiftStage0Idx3Rng12_uid267_fracPostNormSub_uid68_fpFusedAddSubTest_in <= fracResSubNoSignExt_uid65_fpFusedAddSubTest_b(13 downto 0);
    leftShiftStage0Idx3Rng12_uid267_fracPostNormSub_uid68_fpFusedAddSubTest_b <= leftShiftStage0Idx3Rng12_uid267_fracPostNormSub_uid68_fpFusedAddSubTest_in(13 downto 0);

    -- leftShiftStage0Idx3_uid268_fracPostNormSub_uid68_fpFusedAddSubTest(BITJOIN,267)@1
    leftShiftStage0Idx3_uid268_fracPostNormSub_uid68_fpFusedAddSubTest_q <= leftShiftStage0Idx3Rng12_uid267_fracPostNormSub_uid68_fpFusedAddSubTest_b & rightShiftStage0Idx3Pad12_uid232_alignmentShifter_uid59_fpFusedAddSubTest_q;

    -- leftShiftStage0Idx2Rng8_uid264_fracPostNormSub_uid68_fpFusedAddSubTest(BITSELECT,263)@1
    leftShiftStage0Idx2Rng8_uid264_fracPostNormSub_uid68_fpFusedAddSubTest_in <= fracResSubNoSignExt_uid65_fpFusedAddSubTest_b(17 downto 0);
    leftShiftStage0Idx2Rng8_uid264_fracPostNormSub_uid68_fpFusedAddSubTest_b <= leftShiftStage0Idx2Rng8_uid264_fracPostNormSub_uid68_fpFusedAddSubTest_in(17 downto 0);

    -- leftShiftStage0Idx2_uid265_fracPostNormSub_uid68_fpFusedAddSubTest(BITJOIN,264)@1
    leftShiftStage0Idx2_uid265_fracPostNormSub_uid68_fpFusedAddSubTest_q <= leftShiftStage0Idx2Rng8_uid264_fracPostNormSub_uid68_fpFusedAddSubTest_b & cstAllZWE_uid13_fpFusedAddSubTest_q;

    -- leftShiftStage0Idx1Rng4_uid261_fracPostNormSub_uid68_fpFusedAddSubTest(BITSELECT,260)@1
    leftShiftStage0Idx1Rng4_uid261_fracPostNormSub_uid68_fpFusedAddSubTest_in <= fracResSubNoSignExt_uid65_fpFusedAddSubTest_b(21 downto 0);
    leftShiftStage0Idx1Rng4_uid261_fracPostNormSub_uid68_fpFusedAddSubTest_b <= leftShiftStage0Idx1Rng4_uid261_fracPostNormSub_uid68_fpFusedAddSubTest_in(21 downto 0);

    -- leftShiftStage0Idx1_uid262_fracPostNormSub_uid68_fpFusedAddSubTest(BITJOIN,261)@1
    leftShiftStage0Idx1_uid262_fracPostNormSub_uid68_fpFusedAddSubTest_q <= leftShiftStage0Idx1Rng4_uid261_fracPostNormSub_uid68_fpFusedAddSubTest_b & zs_uid175_lzCountValSub_uid67_fpFusedAddSubTest_q;

    -- leftShiftStage0_uid280_fracPostNormSub_uid68_fpFusedAddSubTest_msplit_0(MUX,334)@1
    leftShiftStage0_uid280_fracPostNormSub_uid68_fpFusedAddSubTest_msplit_0_s <= leftShiftStage0_uid280_fracPostNormSub_uid68_fpFusedAddSubTest_selLSBs_merged_bit_select_b;
    leftShiftStage0_uid280_fracPostNormSub_uid68_fpFusedAddSubTest_msplit_0_combproc: PROCESS (leftShiftStage0_uid280_fracPostNormSub_uid68_fpFusedAddSubTest_msplit_0_s, fracResSubNoSignExt_uid65_fpFusedAddSubTest_b, leftShiftStage0Idx1_uid262_fracPostNormSub_uid68_fpFusedAddSubTest_q, leftShiftStage0Idx2_uid265_fracPostNormSub_uid68_fpFusedAddSubTest_q, leftShiftStage0Idx3_uid268_fracPostNormSub_uid68_fpFusedAddSubTest_q)
    BEGIN
        CASE (leftShiftStage0_uid280_fracPostNormSub_uid68_fpFusedAddSubTest_msplit_0_s) IS
            WHEN "00" => leftShiftStage0_uid280_fracPostNormSub_uid68_fpFusedAddSubTest_msplit_0_q <= fracResSubNoSignExt_uid65_fpFusedAddSubTest_b;
            WHEN "01" => leftShiftStage0_uid280_fracPostNormSub_uid68_fpFusedAddSubTest_msplit_0_q <= leftShiftStage0Idx1_uid262_fracPostNormSub_uid68_fpFusedAddSubTest_q;
            WHEN "10" => leftShiftStage0_uid280_fracPostNormSub_uid68_fpFusedAddSubTest_msplit_0_q <= leftShiftStage0Idx2_uid265_fracPostNormSub_uid68_fpFusedAddSubTest_q;
            WHEN "11" => leftShiftStage0_uid280_fracPostNormSub_uid68_fpFusedAddSubTest_msplit_0_q <= leftShiftStage0Idx3_uid268_fracPostNormSub_uid68_fpFusedAddSubTest_q;
            WHEN OTHERS => leftShiftStage0_uid280_fracPostNormSub_uid68_fpFusedAddSubTest_msplit_0_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- leftShiftStage0_uid280_fracPostNormSub_uid68_fpFusedAddSubTest_selLSBs_merged_bit_select(BITSELECT,352)@1
    leftShiftStage0_uid280_fracPostNormSub_uid68_fpFusedAddSubTest_selLSBs_merged_bit_select_b <= leftShiftStageSel4Dto2_uid279_fracPostNormSub_uid68_fpFusedAddSubTest_merged_bit_select_b(1 downto 0);
    leftShiftStage0_uid280_fracPostNormSub_uid68_fpFusedAddSubTest_selLSBs_merged_bit_select_c <= leftShiftStageSel4Dto2_uid279_fracPostNormSub_uid68_fpFusedAddSubTest_merged_bit_select_b(2 downto 2);

    -- leftShiftStage0_uid280_fracPostNormSub_uid68_fpFusedAddSubTest_mfinal(MUX,336)@1
    leftShiftStage0_uid280_fracPostNormSub_uid68_fpFusedAddSubTest_mfinal_s <= leftShiftStage0_uid280_fracPostNormSub_uid68_fpFusedAddSubTest_selLSBs_merged_bit_select_c;
    leftShiftStage0_uid280_fracPostNormSub_uid68_fpFusedAddSubTest_mfinal_combproc: PROCESS (leftShiftStage0_uid280_fracPostNormSub_uid68_fpFusedAddSubTest_mfinal_s, leftShiftStage0_uid280_fracPostNormSub_uid68_fpFusedAddSubTest_msplit_0_q, leftShiftStage0_uid280_fracPostNormSub_uid68_fpFusedAddSubTest_msplit_1_q)
    BEGIN
        CASE (leftShiftStage0_uid280_fracPostNormSub_uid68_fpFusedAddSubTest_mfinal_s) IS
            WHEN "0" => leftShiftStage0_uid280_fracPostNormSub_uid68_fpFusedAddSubTest_mfinal_q <= leftShiftStage0_uid280_fracPostNormSub_uid68_fpFusedAddSubTest_msplit_0_q;
            WHEN "1" => leftShiftStage0_uid280_fracPostNormSub_uid68_fpFusedAddSubTest_mfinal_q <= leftShiftStage0_uid280_fracPostNormSub_uid68_fpFusedAddSubTest_msplit_1_q;
            WHEN OTHERS => leftShiftStage0_uid280_fracPostNormSub_uid68_fpFusedAddSubTest_mfinal_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- leftShiftStageSel4Dto2_uid279_fracPostNormSub_uid68_fpFusedAddSubTest_merged_bit_select(BITSELECT,346)@1
    leftShiftStageSel4Dto2_uid279_fracPostNormSub_uid68_fpFusedAddSubTest_merged_bit_select_b <= r_uid190_lzCountValSub_uid67_fpFusedAddSubTest_q(4 downto 2);
    leftShiftStageSel4Dto2_uid279_fracPostNormSub_uid68_fpFusedAddSubTest_merged_bit_select_c <= r_uid190_lzCountValSub_uid67_fpFusedAddSubTest_q(1 downto 0);

    -- leftShiftStage1_uid291_fracPostNormSub_uid68_fpFusedAddSubTest(MUX,290)@1
    leftShiftStage1_uid291_fracPostNormSub_uid68_fpFusedAddSubTest_s <= leftShiftStageSel4Dto2_uid279_fracPostNormSub_uid68_fpFusedAddSubTest_merged_bit_select_c;
    leftShiftStage1_uid291_fracPostNormSub_uid68_fpFusedAddSubTest_combproc: PROCESS (leftShiftStage1_uid291_fracPostNormSub_uid68_fpFusedAddSubTest_s, leftShiftStage0_uid280_fracPostNormSub_uid68_fpFusedAddSubTest_mfinal_q, leftShiftStage1Idx1_uid283_fracPostNormSub_uid68_fpFusedAddSubTest_q, leftShiftStage1Idx2_uid286_fracPostNormSub_uid68_fpFusedAddSubTest_q, leftShiftStage1Idx3_uid289_fracPostNormSub_uid68_fpFusedAddSubTest_q)
    BEGIN
        CASE (leftShiftStage1_uid291_fracPostNormSub_uid68_fpFusedAddSubTest_s) IS
            WHEN "00" => leftShiftStage1_uid291_fracPostNormSub_uid68_fpFusedAddSubTest_q <= leftShiftStage0_uid280_fracPostNormSub_uid68_fpFusedAddSubTest_mfinal_q;
            WHEN "01" => leftShiftStage1_uid291_fracPostNormSub_uid68_fpFusedAddSubTest_q <= leftShiftStage1Idx1_uid283_fracPostNormSub_uid68_fpFusedAddSubTest_q;
            WHEN "10" => leftShiftStage1_uid291_fracPostNormSub_uid68_fpFusedAddSubTest_q <= leftShiftStage1Idx2_uid286_fracPostNormSub_uid68_fpFusedAddSubTest_q;
            WHEN "11" => leftShiftStage1_uid291_fracPostNormSub_uid68_fpFusedAddSubTest_q <= leftShiftStage1Idx3_uid289_fracPostNormSub_uid68_fpFusedAddSubTest_q;
            WHEN OTHERS => leftShiftStage1_uid291_fracPostNormSub_uid68_fpFusedAddSubTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- fracPostNormSubRndRange_uid76_fpFusedAddSubTest(BITSELECT,75)@1
    fracPostNormSubRndRange_uid76_fpFusedAddSubTest_in <= leftShiftStage1_uid291_fracPostNormSub_uid68_fpFusedAddSubTest_q(24 downto 0);
    fracPostNormSubRndRange_uid76_fpFusedAddSubTest_b <= fracPostNormSubRndRange_uid76_fpFusedAddSubTest_in(24 downto 1);

    -- expFracRSub_uid77_fpFusedAddSubTest(BITJOIN,76)@1
    expFracRSub_uid77_fpFusedAddSubTest_q <= expPostNormSub_uid74_fpFusedAddSubTest_q & fracPostNormSubRndRange_uid76_fpFusedAddSubTest_b;

    -- expRPreExcSub_uid86_fpFusedAddSubTest(BITSELECT,85)@1
    expRPreExcSub_uid86_fpFusedAddSubTest_in <= expFracRSub_uid77_fpFusedAddSubTest_q(31 downto 0);
    expRPreExcSub_uid86_fpFusedAddSubTest_b <= expRPreExcSub_uid86_fpFusedAddSubTest_in(31 downto 24);

    -- expRPreExcSubtraction_uid116_fpFusedAddSubTest(MUX,115)@1
    expRPreExcSubtraction_uid116_fpFusedAddSubTest_s <= effSub_uid45_fpFusedAddSubTest_q;
    expRPreExcSubtraction_uid116_fpFusedAddSubTest_combproc: PROCESS (expRPreExcSubtraction_uid116_fpFusedAddSubTest_s, expRPreExcSub_uid86_fpFusedAddSubTest_b, expRPreExcAdd_uid89_fpFusedAddSubTest_b)
    BEGIN
        CASE (expRPreExcSubtraction_uid116_fpFusedAddSubTest_s) IS
            WHEN "0" => expRPreExcSubtraction_uid116_fpFusedAddSubTest_q <= expRPreExcSub_uid86_fpFusedAddSubTest_b;
            WHEN "1" => expRPreExcSubtraction_uid116_fpFusedAddSubTest_q <= expRPreExcAdd_uid89_fpFusedAddSubTest_b;
            WHEN OTHERS => expRPreExcSubtraction_uid116_fpFusedAddSubTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- wEP2AllOwE_uid80_fpFusedAddSubTest(CONSTANT,79)
    wEP2AllOwE_uid80_fpFusedAddSubTest_q <= "0011111111";

    -- rndExp_uid81_fpFusedAddSubTest(BITSELECT,80)@1
    rndExp_uid81_fpFusedAddSubTest_b <= expFracRAdd_uid79_fpFusedAddSubTest_q(33 downto 24);

    -- rOvf_uid82_fpFusedAddSubTest(LOGICAL,81)@1
    rOvf_uid82_fpFusedAddSubTest_q <= "1" WHEN rndExp_uid81_fpFusedAddSubTest_b = wEP2AllOwE_uid80_fpFusedAddSubTest_q ELSE "0";

    -- invExpXIsMax_uid36_fpFusedAddSubTest(LOGICAL,35)@1
    invExpXIsMax_uid36_fpFusedAddSubTest_q <= not (expXIsMax_uid31_fpFusedAddSubTest_q);

    -- excR_sigb_uid38_fpFusedAddSubTest(LOGICAL,37)@1
    excR_sigb_uid38_fpFusedAddSubTest_q <= InvExpXIsZero_uid37_fpFusedAddSubTest_q and invExpXIsMax_uid36_fpFusedAddSubTest_q;

    -- regInputs_uid91_fpFusedAddSubTest(LOGICAL,90)@1
    regInputs_uid91_fpFusedAddSubTest_q <= excR_siga_uid24_fpFusedAddSubTest_q and excR_sigb_uid38_fpFusedAddSubTest_q;

    -- regInAndOvf_uid95_fpFusedAddSubTest(LOGICAL,94)@1
    regInAndOvf_uid95_fpFusedAddSubTest_q <= regInputs_uid91_fpFusedAddSubTest_q and rOvf_uid82_fpFusedAddSubTest_q;

    -- excRInfVInC_uid99_fpFusedAddSubTest(BITJOIN,98)@1
    excRInfVInC_uid99_fpFusedAddSubTest_q <= regInAndOvf_uid95_fpFusedAddSubTest_q & excZ_sigb_uid10_uid30_fpFusedAddSubTest_q & excZ_siga_uid9_uid16_fpFusedAddSubTest_q & excI_sigb_uid34_fpFusedAddSubTest_q & excI_siga_uid20_fpFusedAddSubTest_q & effSub_uid45_fpFusedAddSubTest_q;

    -- excRInfSub_uid102_fpFusedAddSubTest(LOOKUP,101)@1
    excRInfSub_uid102_fpFusedAddSubTest_combproc: PROCESS (excRInfVInC_uid99_fpFusedAddSubTest_q)
    BEGIN
        -- Begin reserved scope level
        CASE (excRInfVInC_uid99_fpFusedAddSubTest_q) IS
            WHEN "000000" => excRInfSub_uid102_fpFusedAddSubTest_q <= "0";
            WHEN "000001" => excRInfSub_uid102_fpFusedAddSubTest_q <= "0";
            WHEN "000010" => excRInfSub_uid102_fpFusedAddSubTest_q <= "0";
            WHEN "000011" => excRInfSub_uid102_fpFusedAddSubTest_q <= "0";
            WHEN "000100" => excRInfSub_uid102_fpFusedAddSubTest_q <= "0";
            WHEN "000101" => excRInfSub_uid102_fpFusedAddSubTest_q <= "0";
            WHEN "000110" => excRInfSub_uid102_fpFusedAddSubTest_q <= "0";
            WHEN "000111" => excRInfSub_uid102_fpFusedAddSubTest_q <= "1";
            WHEN "001000" => excRInfSub_uid102_fpFusedAddSubTest_q <= "0";
            WHEN "001001" => excRInfSub_uid102_fpFusedAddSubTest_q <= "0";
            WHEN "001010" => excRInfSub_uid102_fpFusedAddSubTest_q <= "0";
            WHEN "001011" => excRInfSub_uid102_fpFusedAddSubTest_q <= "0";
            WHEN "001100" => excRInfSub_uid102_fpFusedAddSubTest_q <= "1";
            WHEN "001101" => excRInfSub_uid102_fpFusedAddSubTest_q <= "1";
            WHEN "001110" => excRInfSub_uid102_fpFusedAddSubTest_q <= "0";
            WHEN "001111" => excRInfSub_uid102_fpFusedAddSubTest_q <= "0";
            WHEN "010000" => excRInfSub_uid102_fpFusedAddSubTest_q <= "0";
            WHEN "010001" => excRInfSub_uid102_fpFusedAddSubTest_q <= "0";
            WHEN "010010" => excRInfSub_uid102_fpFusedAddSubTest_q <= "1";
            WHEN "010011" => excRInfSub_uid102_fpFusedAddSubTest_q <= "1";
            WHEN "010100" => excRInfSub_uid102_fpFusedAddSubTest_q <= "0";
            WHEN "010101" => excRInfSub_uid102_fpFusedAddSubTest_q <= "0";
            WHEN "010110" => excRInfSub_uid102_fpFusedAddSubTest_q <= "0";
            WHEN "010111" => excRInfSub_uid102_fpFusedAddSubTest_q <= "0";
            WHEN "011000" => excRInfSub_uid102_fpFusedAddSubTest_q <= "0";
            WHEN "011001" => excRInfSub_uid102_fpFusedAddSubTest_q <= "0";
            WHEN "011010" => excRInfSub_uid102_fpFusedAddSubTest_q <= "0";
            WHEN "011011" => excRInfSub_uid102_fpFusedAddSubTest_q <= "0";
            WHEN "011100" => excRInfSub_uid102_fpFusedAddSubTest_q <= "0";
            WHEN "011101" => excRInfSub_uid102_fpFusedAddSubTest_q <= "0";
            WHEN "011110" => excRInfSub_uid102_fpFusedAddSubTest_q <= "0";
            WHEN "011111" => excRInfSub_uid102_fpFusedAddSubTest_q <= "0";
            WHEN "100000" => excRInfSub_uid102_fpFusedAddSubTest_q <= "0";
            WHEN "100001" => excRInfSub_uid102_fpFusedAddSubTest_q <= "1";
            WHEN "100010" => excRInfSub_uid102_fpFusedAddSubTest_q <= "0";
            WHEN "100011" => excRInfSub_uid102_fpFusedAddSubTest_q <= "0";
            WHEN "100100" => excRInfSub_uid102_fpFusedAddSubTest_q <= "0";
            WHEN "100101" => excRInfSub_uid102_fpFusedAddSubTest_q <= "0";
            WHEN "100110" => excRInfSub_uid102_fpFusedAddSubTest_q <= "0";
            WHEN "100111" => excRInfSub_uid102_fpFusedAddSubTest_q <= "0";
            WHEN "101000" => excRInfSub_uid102_fpFusedAddSubTest_q <= "0";
            WHEN "101001" => excRInfSub_uid102_fpFusedAddSubTest_q <= "0";
            WHEN "101010" => excRInfSub_uid102_fpFusedAddSubTest_q <= "0";
            WHEN "101011" => excRInfSub_uid102_fpFusedAddSubTest_q <= "0";
            WHEN "101100" => excRInfSub_uid102_fpFusedAddSubTest_q <= "0";
            WHEN "101101" => excRInfSub_uid102_fpFusedAddSubTest_q <= "0";
            WHEN "101110" => excRInfSub_uid102_fpFusedAddSubTest_q <= "0";
            WHEN "101111" => excRInfSub_uid102_fpFusedAddSubTest_q <= "0";
            WHEN "110000" => excRInfSub_uid102_fpFusedAddSubTest_q <= "0";
            WHEN "110001" => excRInfSub_uid102_fpFusedAddSubTest_q <= "0";
            WHEN "110010" => excRInfSub_uid102_fpFusedAddSubTest_q <= "0";
            WHEN "110011" => excRInfSub_uid102_fpFusedAddSubTest_q <= "0";
            WHEN "110100" => excRInfSub_uid102_fpFusedAddSubTest_q <= "0";
            WHEN "110101" => excRInfSub_uid102_fpFusedAddSubTest_q <= "0";
            WHEN "110110" => excRInfSub_uid102_fpFusedAddSubTest_q <= "0";
            WHEN "110111" => excRInfSub_uid102_fpFusedAddSubTest_q <= "0";
            WHEN "111000" => excRInfSub_uid102_fpFusedAddSubTest_q <= "0";
            WHEN "111001" => excRInfSub_uid102_fpFusedAddSubTest_q <= "0";
            WHEN "111010" => excRInfSub_uid102_fpFusedAddSubTest_q <= "0";
            WHEN "111011" => excRInfSub_uid102_fpFusedAddSubTest_q <= "0";
            WHEN "111100" => excRInfSub_uid102_fpFusedAddSubTest_q <= "0";
            WHEN "111101" => excRInfSub_uid102_fpFusedAddSubTest_q <= "0";
            WHEN "111110" => excRInfSub_uid102_fpFusedAddSubTest_q <= "0";
            WHEN "111111" => excRInfSub_uid102_fpFusedAddSubTest_q <= "0";
            WHEN OTHERS => -- unreachable
                           excRInfSub_uid102_fpFusedAddSubTest_q <= (others => '-');
        END CASE;
        -- End reserved scope level
    END PROCESS;

    -- oneIsInfOrZero_uid97_fpFusedAddSubTest(LOGICAL,96)@1
    oneIsInfOrZero_uid97_fpFusedAddSubTest_q <= excR_siga_uid24_fpFusedAddSubTest_q or excR_sigb_uid38_fpFusedAddSubTest_q or excZ_siga_uid9_uid16_fpFusedAddSubTest_q or excZ_sigb_uid10_uid30_fpFusedAddSubTest_q;

    -- oneIsInf_uid96_fpFusedAddSubTest(LOGICAL,95)@1
    oneIsInf_uid96_fpFusedAddSubTest_q <= excI_siga_uid20_fpFusedAddSubTest_q or excI_sigb_uid34_fpFusedAddSubTest_q;

    -- addIsAlsoInf_uid98_fpFusedAddSubTest(LOGICAL,97)@1
    addIsAlsoInf_uid98_fpFusedAddSubTest_q <= oneIsInf_uid96_fpFusedAddSubTest_q and oneIsInfOrZero_uid97_fpFusedAddSubTest_q;

    -- excRInfSubFull_uid103_fpFusedAddSubTest(LOGICAL,102)@1
    excRInfSubFull_uid103_fpFusedAddSubTest_q <= addIsAlsoInf_uid98_fpFusedAddSubTest_q or excRInfSub_uid102_fpFusedAddSubTest_q;

    -- signedExp_uid83_fpFusedAddSubTest(BITSELECT,82)@1
    signedExp_uid83_fpFusedAddSubTest_b <= STD_LOGIC_VECTOR(expFracRSub_uid77_fpFusedAddSubTest_q(33 downto 24));

    -- rUdf_uid84_fpFusedAddSubTest(COMPARE,83)@1
    rUdf_uid84_fpFusedAddSubTest_a <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR("0" & "0000000000" & GND_q));
    rUdf_uid84_fpFusedAddSubTest_b <= STD_LOGIC_VECTOR(STD_LOGIC_VECTOR((11 downto 10 => signedExp_uid83_fpFusedAddSubTest_b(9)) & signedExp_uid83_fpFusedAddSubTest_b));
    rUdf_uid84_fpFusedAddSubTest_o <= STD_LOGIC_VECTOR(SIGNED(rUdf_uid84_fpFusedAddSubTest_a) - SIGNED(rUdf_uid84_fpFusedAddSubTest_b));
    rUdf_uid84_fpFusedAddSubTest_n(0) <= not (rUdf_uid84_fpFusedAddSubTest_o(11));

    -- excRZeroVInC_uid92_fpFusedAddSubTest(BITJOIN,91)@1
    excRZeroVInC_uid92_fpFusedAddSubTest_q <= effSub_uid45_fpFusedAddSubTest_q & aMinusA_uid72_fpFusedAddSubTest_q & rUdf_uid84_fpFusedAddSubTest_n & regInputs_uid91_fpFusedAddSubTest_q & excZ_sigb_uid10_uid30_fpFusedAddSubTest_q & excZ_siga_uid9_uid16_fpFusedAddSubTest_q;

    -- excRZeroSub_uid94_fpFusedAddSubTest(LOOKUP,93)@1
    excRZeroSub_uid94_fpFusedAddSubTest_combproc: PROCESS (excRZeroVInC_uid92_fpFusedAddSubTest_q)
    BEGIN
        -- Begin reserved scope level
        CASE (excRZeroVInC_uid92_fpFusedAddSubTest_q) IS
            WHEN "000000" => excRZeroSub_uid94_fpFusedAddSubTest_q <= "0";
            WHEN "000001" => excRZeroSub_uid94_fpFusedAddSubTest_q <= "0";
            WHEN "000010" => excRZeroSub_uid94_fpFusedAddSubTest_q <= "0";
            WHEN "000011" => excRZeroSub_uid94_fpFusedAddSubTest_q <= "1";
            WHEN "000100" => excRZeroSub_uid94_fpFusedAddSubTest_q <= "0";
            WHEN "000101" => excRZeroSub_uid94_fpFusedAddSubTest_q <= "0";
            WHEN "000110" => excRZeroSub_uid94_fpFusedAddSubTest_q <= "0";
            WHEN "000111" => excRZeroSub_uid94_fpFusedAddSubTest_q <= "0";
            WHEN "001000" => excRZeroSub_uid94_fpFusedAddSubTest_q <= "0";
            WHEN "001001" => excRZeroSub_uid94_fpFusedAddSubTest_q <= "0";
            WHEN "001010" => excRZeroSub_uid94_fpFusedAddSubTest_q <= "0";
            WHEN "001011" => excRZeroSub_uid94_fpFusedAddSubTest_q <= "0";
            WHEN "001100" => excRZeroSub_uid94_fpFusedAddSubTest_q <= "1";
            WHEN "001101" => excRZeroSub_uid94_fpFusedAddSubTest_q <= "0";
            WHEN "001110" => excRZeroSub_uid94_fpFusedAddSubTest_q <= "0";
            WHEN "001111" => excRZeroSub_uid94_fpFusedAddSubTest_q <= "0";
            WHEN "010000" => excRZeroSub_uid94_fpFusedAddSubTest_q <= "0";
            WHEN "010001" => excRZeroSub_uid94_fpFusedAddSubTest_q <= "0";
            WHEN "010010" => excRZeroSub_uid94_fpFusedAddSubTest_q <= "0";
            WHEN "010011" => excRZeroSub_uid94_fpFusedAddSubTest_q <= "0";
            WHEN "010100" => excRZeroSub_uid94_fpFusedAddSubTest_q <= "1";
            WHEN "010101" => excRZeroSub_uid94_fpFusedAddSubTest_q <= "0";
            WHEN "010110" => excRZeroSub_uid94_fpFusedAddSubTest_q <= "0";
            WHEN "010111" => excRZeroSub_uid94_fpFusedAddSubTest_q <= "0";
            WHEN "011000" => excRZeroSub_uid94_fpFusedAddSubTest_q <= "0";
            WHEN "011001" => excRZeroSub_uid94_fpFusedAddSubTest_q <= "0";
            WHEN "011010" => excRZeroSub_uid94_fpFusedAddSubTest_q <= "0";
            WHEN "011011" => excRZeroSub_uid94_fpFusedAddSubTest_q <= "0";
            WHEN "011100" => excRZeroSub_uid94_fpFusedAddSubTest_q <= "1";
            WHEN "011101" => excRZeroSub_uid94_fpFusedAddSubTest_q <= "0";
            WHEN "011110" => excRZeroSub_uid94_fpFusedAddSubTest_q <= "0";
            WHEN "011111" => excRZeroSub_uid94_fpFusedAddSubTest_q <= "0";
            WHEN "100000" => excRZeroSub_uid94_fpFusedAddSubTest_q <= "0";
            WHEN "100001" => excRZeroSub_uid94_fpFusedAddSubTest_q <= "0";
            WHEN "100010" => excRZeroSub_uid94_fpFusedAddSubTest_q <= "0";
            WHEN "100011" => excRZeroSub_uid94_fpFusedAddSubTest_q <= "0";
            WHEN "100100" => excRZeroSub_uid94_fpFusedAddSubTest_q <= "0";
            WHEN "100101" => excRZeroSub_uid94_fpFusedAddSubTest_q <= "0";
            WHEN "100110" => excRZeroSub_uid94_fpFusedAddSubTest_q <= "0";
            WHEN "100111" => excRZeroSub_uid94_fpFusedAddSubTest_q <= "0";
            WHEN "101000" => excRZeroSub_uid94_fpFusedAddSubTest_q <= "0";
            WHEN "101001" => excRZeroSub_uid94_fpFusedAddSubTest_q <= "0";
            WHEN "101010" => excRZeroSub_uid94_fpFusedAddSubTest_q <= "0";
            WHEN "101011" => excRZeroSub_uid94_fpFusedAddSubTest_q <= "0";
            WHEN "101100" => excRZeroSub_uid94_fpFusedAddSubTest_q <= "0";
            WHEN "101101" => excRZeroSub_uid94_fpFusedAddSubTest_q <= "0";
            WHEN "101110" => excRZeroSub_uid94_fpFusedAddSubTest_q <= "0";
            WHEN "101111" => excRZeroSub_uid94_fpFusedAddSubTest_q <= "0";
            WHEN "110000" => excRZeroSub_uid94_fpFusedAddSubTest_q <= "0";
            WHEN "110001" => excRZeroSub_uid94_fpFusedAddSubTest_q <= "0";
            WHEN "110010" => excRZeroSub_uid94_fpFusedAddSubTest_q <= "0";
            WHEN "110011" => excRZeroSub_uid94_fpFusedAddSubTest_q <= "0";
            WHEN "110100" => excRZeroSub_uid94_fpFusedAddSubTest_q <= "0";
            WHEN "110101" => excRZeroSub_uid94_fpFusedAddSubTest_q <= "0";
            WHEN "110110" => excRZeroSub_uid94_fpFusedAddSubTest_q <= "0";
            WHEN "110111" => excRZeroSub_uid94_fpFusedAddSubTest_q <= "0";
            WHEN "111000" => excRZeroSub_uid94_fpFusedAddSubTest_q <= "0";
            WHEN "111001" => excRZeroSub_uid94_fpFusedAddSubTest_q <= "0";
            WHEN "111010" => excRZeroSub_uid94_fpFusedAddSubTest_q <= "0";
            WHEN "111011" => excRZeroSub_uid94_fpFusedAddSubTest_q <= "0";
            WHEN "111100" => excRZeroSub_uid94_fpFusedAddSubTest_q <= "0";
            WHEN "111101" => excRZeroSub_uid94_fpFusedAddSubTest_q <= "0";
            WHEN "111110" => excRZeroSub_uid94_fpFusedAddSubTest_q <= "0";
            WHEN "111111" => excRZeroSub_uid94_fpFusedAddSubTest_q <= "0";
            WHEN OTHERS => -- unreachable
                           excRZeroSub_uid94_fpFusedAddSubTest_q <= (others => '-');
        END CASE;
        -- End reserved scope level
    END PROCESS;

    -- concExcSub_uid109_fpFusedAddSubTest(BITJOIN,108)@1
    concExcSub_uid109_fpFusedAddSubTest_q <= excRNaNS_uid108_fpFusedAddSubTest_q & excRInfSubFull_uid103_fpFusedAddSubTest_q & excRZeroSub_uid94_fpFusedAddSubTest_q;

    -- excREncSub_uid111_fpFusedAddSubTest(LOOKUP,110)@1
    excREncSub_uid111_fpFusedAddSubTest_combproc: PROCESS (concExcSub_uid109_fpFusedAddSubTest_q)
    BEGIN
        -- Begin reserved scope level
        CASE (concExcSub_uid109_fpFusedAddSubTest_q) IS
            WHEN "000" => excREncSub_uid111_fpFusedAddSubTest_q <= "01";
            WHEN "001" => excREncSub_uid111_fpFusedAddSubTest_q <= "00";
            WHEN "010" => excREncSub_uid111_fpFusedAddSubTest_q <= "10";
            WHEN "011" => excREncSub_uid111_fpFusedAddSubTest_q <= "00";
            WHEN "100" => excREncSub_uid111_fpFusedAddSubTest_q <= "11";
            WHEN "101" => excREncSub_uid111_fpFusedAddSubTest_q <= "00";
            WHEN "110" => excREncSub_uid111_fpFusedAddSubTest_q <= "00";
            WHEN "111" => excREncSub_uid111_fpFusedAddSubTest_q <= "00";
            WHEN OTHERS => -- unreachable
                           excREncSub_uid111_fpFusedAddSubTest_q <= (others => '-');
        END CASE;
        -- End reserved scope level
    END PROCESS;

    -- expRPostExcSub_uid144_fpFusedAddSubTest(MUX,143)@1
    expRPostExcSub_uid144_fpFusedAddSubTest_s <= excREncSub_uid111_fpFusedAddSubTest_q;
    expRPostExcSub_uid144_fpFusedAddSubTest_combproc: PROCESS (expRPostExcSub_uid144_fpFusedAddSubTest_s, cstAllZWE_uid13_fpFusedAddSubTest_q, expRPreExcSubtraction_uid116_fpFusedAddSubTest_q, cstAllOWE_uid11_fpFusedAddSubTest_q)
    BEGIN
        CASE (expRPostExcSub_uid144_fpFusedAddSubTest_s) IS
            WHEN "00" => expRPostExcSub_uid144_fpFusedAddSubTest_q <= cstAllZWE_uid13_fpFusedAddSubTest_q;
            WHEN "01" => expRPostExcSub_uid144_fpFusedAddSubTest_q <= expRPreExcSubtraction_uid116_fpFusedAddSubTest_q;
            WHEN "10" => expRPostExcSub_uid144_fpFusedAddSubTest_q <= cstAllOWE_uid11_fpFusedAddSubTest_q;
            WHEN "11" => expRPostExcSub_uid144_fpFusedAddSubTest_q <= cstAllOWE_uid11_fpFusedAddSubTest_q;
            WHEN OTHERS => expRPostExcSub_uid144_fpFusedAddSubTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- oneFracRPostExc2_uid117_fpFusedAddSubTest(CONSTANT,116)
    oneFracRPostExc2_uid117_fpFusedAddSubTest_q <= "00000000000000000000001";

    -- fracRPreExcAdd_uid88_fpFusedAddSubTest(BITSELECT,87)@1
    fracRPreExcAdd_uid88_fpFusedAddSubTest_in <= expFracRAdd_uid79_fpFusedAddSubTest_q(23 downto 0);
    fracRPreExcAdd_uid88_fpFusedAddSubTest_b <= fracRPreExcAdd_uid88_fpFusedAddSubTest_in(23 downto 1);

    -- fracRPreExcSub_uid85_fpFusedAddSubTest(BITSELECT,84)@1
    fracRPreExcSub_uid85_fpFusedAddSubTest_in <= expFracRSub_uid77_fpFusedAddSubTest_q(23 downto 0);
    fracRPreExcSub_uid85_fpFusedAddSubTest_b <= fracRPreExcSub_uid85_fpFusedAddSubTest_in(23 downto 1);

    -- fracRPreExcSubtraction_uid115_fpFusedAddSubTest(MUX,114)@1
    fracRPreExcSubtraction_uid115_fpFusedAddSubTest_s <= effSub_uid45_fpFusedAddSubTest_q;
    fracRPreExcSubtraction_uid115_fpFusedAddSubTest_combproc: PROCESS (fracRPreExcSubtraction_uid115_fpFusedAddSubTest_s, fracRPreExcSub_uid85_fpFusedAddSubTest_b, fracRPreExcAdd_uid88_fpFusedAddSubTest_b)
    BEGIN
        CASE (fracRPreExcSubtraction_uid115_fpFusedAddSubTest_s) IS
            WHEN "0" => fracRPreExcSubtraction_uid115_fpFusedAddSubTest_q <= fracRPreExcSub_uid85_fpFusedAddSubTest_b;
            WHEN "1" => fracRPreExcSubtraction_uid115_fpFusedAddSubTest_q <= fracRPreExcAdd_uid88_fpFusedAddSubTest_b;
            WHEN OTHERS => fracRPreExcSubtraction_uid115_fpFusedAddSubTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- fracRPostExcSub_uid140_fpFusedAddSubTest(MUX,139)@1
    fracRPostExcSub_uid140_fpFusedAddSubTest_s <= excREncSub_uid111_fpFusedAddSubTest_q;
    fracRPostExcSub_uid140_fpFusedAddSubTest_combproc: PROCESS (fracRPostExcSub_uid140_fpFusedAddSubTest_s, cstZeroWF_uid12_fpFusedAddSubTest_q, fracRPreExcSubtraction_uid115_fpFusedAddSubTest_q, oneFracRPostExc2_uid117_fpFusedAddSubTest_q)
    BEGIN
        CASE (fracRPostExcSub_uid140_fpFusedAddSubTest_s) IS
            WHEN "00" => fracRPostExcSub_uid140_fpFusedAddSubTest_q <= cstZeroWF_uid12_fpFusedAddSubTest_q;
            WHEN "01" => fracRPostExcSub_uid140_fpFusedAddSubTest_q <= fracRPreExcSubtraction_uid115_fpFusedAddSubTest_q;
            WHEN "10" => fracRPostExcSub_uid140_fpFusedAddSubTest_q <= cstZeroWF_uid12_fpFusedAddSubTest_q;
            WHEN "11" => fracRPostExcSub_uid140_fpFusedAddSubTest_q <= oneFracRPostExc2_uid117_fpFusedAddSubTest_q;
            WHEN OTHERS => fracRPostExcSub_uid140_fpFusedAddSubTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- RDiff_uid158_fpFusedAddSubTest(BITJOIN,157)@1
    RDiff_uid158_fpFusedAddSubTest_q <= signRPostExcSub_uid157_fpFusedAddSubTest_q & expRPostExcSub_uid144_fpFusedAddSubTest_q & fracRPostExcSub_uid140_fpFusedAddSubTest_q;

    -- invSigA_uid126_fpFusedAddSubTest(LOGICAL,125)@1
    invSigA_uid126_fpFusedAddSubTest_q <= not (sigA_uid43_fpFusedAddSubTest_b);

    -- signInputsZeroSwap_uid127_fpFusedAddSubTest(LOGICAL,126)@1
    signInputsZeroSwap_uid127_fpFusedAddSubTest_q <= excZ_siga_uid9_uid16_fpFusedAddSubTest_q and excZ_sigb_uid10_uid30_fpFusedAddSubTest_q and invSigA_uid126_fpFusedAddSubTest_q and sigB_uid44_fpFusedAddSubTest_b and invXGTEy_uid125_fpFusedAddSubTest_q;

    -- invSignInputsZeroSwap_uid128_fpFusedAddSubTest(LOGICAL,127)@1
    invSignInputsZeroSwap_uid128_fpFusedAddSubTest_q <= not (signInputsZeroSwap_uid127_fpFusedAddSubTest_q);

    -- invSigB_uid129_fpFusedAddSubTest(LOGICAL,128)@1
    invSigB_uid129_fpFusedAddSubTest_q <= not (sigB_uid44_fpFusedAddSubTest_b);

    -- signInputsZeroNoSwap_uid130_fpFusedAddSubTest(LOGICAL,129)@1
    signInputsZeroNoSwap_uid130_fpFusedAddSubTest_q <= excZ_siga_uid9_uid16_fpFusedAddSubTest_q and excZ_sigb_uid10_uid30_fpFusedAddSubTest_q and sigA_uid43_fpFusedAddSubTest_b and invSigB_uid129_fpFusedAddSubTest_q and xGTEy_uid8_fpFusedAddSubTest_n;

    -- invSignInputsZeroNoSwap_uid131_fpFusedAddSubTest(LOGICAL,130)@1
    invSignInputsZeroNoSwap_uid131_fpFusedAddSubTest_q <= not (signInputsZeroNoSwap_uid130_fpFusedAddSubTest_q);

    -- aMa_uid132_fpFusedAddSubTest(LOGICAL,131)@1
    aMa_uid132_fpFusedAddSubTest_q <= aMinusA_uid72_fpFusedAddSubTest_q and effSub_uid45_fpFusedAddSubTest_q;

    -- invAMA_uid133_fpFusedAddSubTest(LOGICAL,132)@1
    invAMA_uid133_fpFusedAddSubTest_q <= not (aMa_uid132_fpFusedAddSubTest_q);

    -- infMinf_uid104_fpFusedAddSubTest(LOGICAL,103)@1
    infMinf_uid104_fpFusedAddSubTest_q <= excI_siga_uid20_fpFusedAddSubTest_q and excI_sigb_uid34_fpFusedAddSubTest_q and effSub_uid45_fpFusedAddSubTest_q;

    -- excRNaNA_uid105_fpFusedAddSubTest(LOGICAL,104)@1
    excRNaNA_uid105_fpFusedAddSubTest_q <= infMinf_uid104_fpFusedAddSubTest_q or excN_siga_uid21_fpFusedAddSubTest_q or excN_sigb_uid35_fpFusedAddSubTest_q;

    -- invExcRNaNA_uid134_fpFusedAddSubTest(LOGICAL,133)@1
    invExcRNaNA_uid134_fpFusedAddSubTest_q <= not (excRNaNA_uid105_fpFusedAddSubTest_q);

    -- signRPostExc_uid135_fpFusedAddSubTest(LOGICAL,134)@1
    signRPostExc_uid135_fpFusedAddSubTest_q <= invExcRNaNA_uid134_fpFusedAddSubTest_q and sigA_uid43_fpFusedAddSubTest_b and invAMA_uid133_fpFusedAddSubTest_q and invSignInputsZeroNoSwap_uid131_fpFusedAddSubTest_q and invSignInputsZeroSwap_uid128_fpFusedAddSubTest_q;

    -- expRPreExcAddition_uid114_fpFusedAddSubTest(MUX,113)@1
    expRPreExcAddition_uid114_fpFusedAddSubTest_s <= effSub_uid45_fpFusedAddSubTest_q;
    expRPreExcAddition_uid114_fpFusedAddSubTest_combproc: PROCESS (expRPreExcAddition_uid114_fpFusedAddSubTest_s, expRPreExcAdd_uid89_fpFusedAddSubTest_b, expRPreExcSub_uid86_fpFusedAddSubTest_b)
    BEGIN
        CASE (expRPreExcAddition_uid114_fpFusedAddSubTest_s) IS
            WHEN "0" => expRPreExcAddition_uid114_fpFusedAddSubTest_q <= expRPreExcAdd_uid89_fpFusedAddSubTest_b;
            WHEN "1" => expRPreExcAddition_uid114_fpFusedAddSubTest_q <= expRPreExcSub_uid86_fpFusedAddSubTest_b;
            WHEN OTHERS => expRPreExcAddition_uid114_fpFusedAddSubTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- excRInfAdd_uid100_fpFusedAddSubTest(LOOKUP,99)@1
    excRInfAdd_uid100_fpFusedAddSubTest_combproc: PROCESS (excRInfVInC_uid99_fpFusedAddSubTest_q)
    BEGIN
        -- Begin reserved scope level
        CASE (excRInfVInC_uid99_fpFusedAddSubTest_q) IS
            WHEN "000000" => excRInfAdd_uid100_fpFusedAddSubTest_q <= "0";
            WHEN "000001" => excRInfAdd_uid100_fpFusedAddSubTest_q <= "0";
            WHEN "000010" => excRInfAdd_uid100_fpFusedAddSubTest_q <= "0";
            WHEN "000011" => excRInfAdd_uid100_fpFusedAddSubTest_q <= "0";
            WHEN "000100" => excRInfAdd_uid100_fpFusedAddSubTest_q <= "0";
            WHEN "000101" => excRInfAdd_uid100_fpFusedAddSubTest_q <= "0";
            WHEN "000110" => excRInfAdd_uid100_fpFusedAddSubTest_q <= "1";
            WHEN "000111" => excRInfAdd_uid100_fpFusedAddSubTest_q <= "0";
            WHEN "001000" => excRInfAdd_uid100_fpFusedAddSubTest_q <= "0";
            WHEN "001001" => excRInfAdd_uid100_fpFusedAddSubTest_q <= "0";
            WHEN "001010" => excRInfAdd_uid100_fpFusedAddSubTest_q <= "0";
            WHEN "001011" => excRInfAdd_uid100_fpFusedAddSubTest_q <= "0";
            WHEN "001100" => excRInfAdd_uid100_fpFusedAddSubTest_q <= "1";
            WHEN "001101" => excRInfAdd_uid100_fpFusedAddSubTest_q <= "1";
            WHEN "001110" => excRInfAdd_uid100_fpFusedAddSubTest_q <= "0";
            WHEN "001111" => excRInfAdd_uid100_fpFusedAddSubTest_q <= "0";
            WHEN "010000" => excRInfAdd_uid100_fpFusedAddSubTest_q <= "0";
            WHEN "010001" => excRInfAdd_uid100_fpFusedAddSubTest_q <= "0";
            WHEN "010010" => excRInfAdd_uid100_fpFusedAddSubTest_q <= "1";
            WHEN "010011" => excRInfAdd_uid100_fpFusedAddSubTest_q <= "1";
            WHEN "010100" => excRInfAdd_uid100_fpFusedAddSubTest_q <= "0";
            WHEN "010101" => excRInfAdd_uid100_fpFusedAddSubTest_q <= "0";
            WHEN "010110" => excRInfAdd_uid100_fpFusedAddSubTest_q <= "0";
            WHEN "010111" => excRInfAdd_uid100_fpFusedAddSubTest_q <= "0";
            WHEN "011000" => excRInfAdd_uid100_fpFusedAddSubTest_q <= "0";
            WHEN "011001" => excRInfAdd_uid100_fpFusedAddSubTest_q <= "0";
            WHEN "011010" => excRInfAdd_uid100_fpFusedAddSubTest_q <= "0";
            WHEN "011011" => excRInfAdd_uid100_fpFusedAddSubTest_q <= "0";
            WHEN "011100" => excRInfAdd_uid100_fpFusedAddSubTest_q <= "0";
            WHEN "011101" => excRInfAdd_uid100_fpFusedAddSubTest_q <= "0";
            WHEN "011110" => excRInfAdd_uid100_fpFusedAddSubTest_q <= "0";
            WHEN "011111" => excRInfAdd_uid100_fpFusedAddSubTest_q <= "0";
            WHEN "100000" => excRInfAdd_uid100_fpFusedAddSubTest_q <= "1";
            WHEN "100001" => excRInfAdd_uid100_fpFusedAddSubTest_q <= "0";
            WHEN "100010" => excRInfAdd_uid100_fpFusedAddSubTest_q <= "0";
            WHEN "100011" => excRInfAdd_uid100_fpFusedAddSubTest_q <= "0";
            WHEN "100100" => excRInfAdd_uid100_fpFusedAddSubTest_q <= "0";
            WHEN "100101" => excRInfAdd_uid100_fpFusedAddSubTest_q <= "0";
            WHEN "100110" => excRInfAdd_uid100_fpFusedAddSubTest_q <= "0";
            WHEN "100111" => excRInfAdd_uid100_fpFusedAddSubTest_q <= "0";
            WHEN "101000" => excRInfAdd_uid100_fpFusedAddSubTest_q <= "0";
            WHEN "101001" => excRInfAdd_uid100_fpFusedAddSubTest_q <= "0";
            WHEN "101010" => excRInfAdd_uid100_fpFusedAddSubTest_q <= "0";
            WHEN "101011" => excRInfAdd_uid100_fpFusedAddSubTest_q <= "0";
            WHEN "101100" => excRInfAdd_uid100_fpFusedAddSubTest_q <= "0";
            WHEN "101101" => excRInfAdd_uid100_fpFusedAddSubTest_q <= "0";
            WHEN "101110" => excRInfAdd_uid100_fpFusedAddSubTest_q <= "0";
            WHEN "101111" => excRInfAdd_uid100_fpFusedAddSubTest_q <= "0";
            WHEN "110000" => excRInfAdd_uid100_fpFusedAddSubTest_q <= "0";
            WHEN "110001" => excRInfAdd_uid100_fpFusedAddSubTest_q <= "0";
            WHEN "110010" => excRInfAdd_uid100_fpFusedAddSubTest_q <= "0";
            WHEN "110011" => excRInfAdd_uid100_fpFusedAddSubTest_q <= "0";
            WHEN "110100" => excRInfAdd_uid100_fpFusedAddSubTest_q <= "0";
            WHEN "110101" => excRInfAdd_uid100_fpFusedAddSubTest_q <= "0";
            WHEN "110110" => excRInfAdd_uid100_fpFusedAddSubTest_q <= "0";
            WHEN "110111" => excRInfAdd_uid100_fpFusedAddSubTest_q <= "0";
            WHEN "111000" => excRInfAdd_uid100_fpFusedAddSubTest_q <= "0";
            WHEN "111001" => excRInfAdd_uid100_fpFusedAddSubTest_q <= "0";
            WHEN "111010" => excRInfAdd_uid100_fpFusedAddSubTest_q <= "0";
            WHEN "111011" => excRInfAdd_uid100_fpFusedAddSubTest_q <= "0";
            WHEN "111100" => excRInfAdd_uid100_fpFusedAddSubTest_q <= "0";
            WHEN "111101" => excRInfAdd_uid100_fpFusedAddSubTest_q <= "0";
            WHEN "111110" => excRInfAdd_uid100_fpFusedAddSubTest_q <= "0";
            WHEN "111111" => excRInfAdd_uid100_fpFusedAddSubTest_q <= "0";
            WHEN OTHERS => -- unreachable
                           excRInfAdd_uid100_fpFusedAddSubTest_q <= (others => '-');
        END CASE;
        -- End reserved scope level
    END PROCESS;

    -- excRInfAddFull_uid101_fpFusedAddSubTest(LOGICAL,100)@1
    excRInfAddFull_uid101_fpFusedAddSubTest_q <= addIsAlsoInf_uid98_fpFusedAddSubTest_q or excRInfAdd_uid100_fpFusedAddSubTest_q;

    -- excRZeroAdd_uid93_fpFusedAddSubTest(LOOKUP,92)@1
    excRZeroAdd_uid93_fpFusedAddSubTest_combproc: PROCESS (excRZeroVInC_uid92_fpFusedAddSubTest_q)
    BEGIN
        -- Begin reserved scope level
        CASE (excRZeroVInC_uid92_fpFusedAddSubTest_q) IS
            WHEN "000000" => excRZeroAdd_uid93_fpFusedAddSubTest_q <= "0";
            WHEN "000001" => excRZeroAdd_uid93_fpFusedAddSubTest_q <= "0";
            WHEN "000010" => excRZeroAdd_uid93_fpFusedAddSubTest_q <= "0";
            WHEN "000011" => excRZeroAdd_uid93_fpFusedAddSubTest_q <= "1";
            WHEN "000100" => excRZeroAdd_uid93_fpFusedAddSubTest_q <= "0";
            WHEN "000101" => excRZeroAdd_uid93_fpFusedAddSubTest_q <= "0";
            WHEN "000110" => excRZeroAdd_uid93_fpFusedAddSubTest_q <= "0";
            WHEN "000111" => excRZeroAdd_uid93_fpFusedAddSubTest_q <= "0";
            WHEN "001000" => excRZeroAdd_uid93_fpFusedAddSubTest_q <= "0";
            WHEN "001001" => excRZeroAdd_uid93_fpFusedAddSubTest_q <= "0";
            WHEN "001010" => excRZeroAdd_uid93_fpFusedAddSubTest_q <= "0";
            WHEN "001011" => excRZeroAdd_uid93_fpFusedAddSubTest_q <= "0";
            WHEN "001100" => excRZeroAdd_uid93_fpFusedAddSubTest_q <= "0";
            WHEN "001101" => excRZeroAdd_uid93_fpFusedAddSubTest_q <= "0";
            WHEN "001110" => excRZeroAdd_uid93_fpFusedAddSubTest_q <= "0";
            WHEN "001111" => excRZeroAdd_uid93_fpFusedAddSubTest_q <= "0";
            WHEN "010000" => excRZeroAdd_uid93_fpFusedAddSubTest_q <= "0";
            WHEN "010001" => excRZeroAdd_uid93_fpFusedAddSubTest_q <= "0";
            WHEN "010010" => excRZeroAdd_uid93_fpFusedAddSubTest_q <= "0";
            WHEN "010011" => excRZeroAdd_uid93_fpFusedAddSubTest_q <= "0";
            WHEN "010100" => excRZeroAdd_uid93_fpFusedAddSubTest_q <= "0";
            WHEN "010101" => excRZeroAdd_uid93_fpFusedAddSubTest_q <= "0";
            WHEN "010110" => excRZeroAdd_uid93_fpFusedAddSubTest_q <= "0";
            WHEN "010111" => excRZeroAdd_uid93_fpFusedAddSubTest_q <= "0";
            WHEN "011000" => excRZeroAdd_uid93_fpFusedAddSubTest_q <= "0";
            WHEN "011001" => excRZeroAdd_uid93_fpFusedAddSubTest_q <= "0";
            WHEN "011010" => excRZeroAdd_uid93_fpFusedAddSubTest_q <= "0";
            WHEN "011011" => excRZeroAdd_uid93_fpFusedAddSubTest_q <= "0";
            WHEN "011100" => excRZeroAdd_uid93_fpFusedAddSubTest_q <= "0";
            WHEN "011101" => excRZeroAdd_uid93_fpFusedAddSubTest_q <= "0";
            WHEN "011110" => excRZeroAdd_uid93_fpFusedAddSubTest_q <= "0";
            WHEN "011111" => excRZeroAdd_uid93_fpFusedAddSubTest_q <= "0";
            WHEN "100000" => excRZeroAdd_uid93_fpFusedAddSubTest_q <= "0";
            WHEN "100001" => excRZeroAdd_uid93_fpFusedAddSubTest_q <= "0";
            WHEN "100010" => excRZeroAdd_uid93_fpFusedAddSubTest_q <= "0";
            WHEN "100011" => excRZeroAdd_uid93_fpFusedAddSubTest_q <= "0";
            WHEN "100100" => excRZeroAdd_uid93_fpFusedAddSubTest_q <= "0";
            WHEN "100101" => excRZeroAdd_uid93_fpFusedAddSubTest_q <= "0";
            WHEN "100110" => excRZeroAdd_uid93_fpFusedAddSubTest_q <= "0";
            WHEN "100111" => excRZeroAdd_uid93_fpFusedAddSubTest_q <= "0";
            WHEN "101000" => excRZeroAdd_uid93_fpFusedAddSubTest_q <= "0";
            WHEN "101001" => excRZeroAdd_uid93_fpFusedAddSubTest_q <= "0";
            WHEN "101010" => excRZeroAdd_uid93_fpFusedAddSubTest_q <= "0";
            WHEN "101011" => excRZeroAdd_uid93_fpFusedAddSubTest_q <= "0";
            WHEN "101100" => excRZeroAdd_uid93_fpFusedAddSubTest_q <= "1";
            WHEN "101101" => excRZeroAdd_uid93_fpFusedAddSubTest_q <= "0";
            WHEN "101110" => excRZeroAdd_uid93_fpFusedAddSubTest_q <= "0";
            WHEN "101111" => excRZeroAdd_uid93_fpFusedAddSubTest_q <= "0";
            WHEN "110000" => excRZeroAdd_uid93_fpFusedAddSubTest_q <= "0";
            WHEN "110001" => excRZeroAdd_uid93_fpFusedAddSubTest_q <= "0";
            WHEN "110010" => excRZeroAdd_uid93_fpFusedAddSubTest_q <= "0";
            WHEN "110011" => excRZeroAdd_uid93_fpFusedAddSubTest_q <= "0";
            WHEN "110100" => excRZeroAdd_uid93_fpFusedAddSubTest_q <= "1";
            WHEN "110101" => excRZeroAdd_uid93_fpFusedAddSubTest_q <= "0";
            WHEN "110110" => excRZeroAdd_uid93_fpFusedAddSubTest_q <= "0";
            WHEN "110111" => excRZeroAdd_uid93_fpFusedAddSubTest_q <= "0";
            WHEN "111000" => excRZeroAdd_uid93_fpFusedAddSubTest_q <= "0";
            WHEN "111001" => excRZeroAdd_uid93_fpFusedAddSubTest_q <= "0";
            WHEN "111010" => excRZeroAdd_uid93_fpFusedAddSubTest_q <= "0";
            WHEN "111011" => excRZeroAdd_uid93_fpFusedAddSubTest_q <= "0";
            WHEN "111100" => excRZeroAdd_uid93_fpFusedAddSubTest_q <= "1";
            WHEN "111101" => excRZeroAdd_uid93_fpFusedAddSubTest_q <= "0";
            WHEN "111110" => excRZeroAdd_uid93_fpFusedAddSubTest_q <= "0";
            WHEN "111111" => excRZeroAdd_uid93_fpFusedAddSubTest_q <= "0";
            WHEN OTHERS => -- unreachable
                           excRZeroAdd_uid93_fpFusedAddSubTest_q <= (others => '-');
        END CASE;
        -- End reserved scope level
    END PROCESS;

    -- concExcAdd_uid110_fpFusedAddSubTest(BITJOIN,109)@1
    concExcAdd_uid110_fpFusedAddSubTest_q <= excRNaNA_uid105_fpFusedAddSubTest_q & excRInfAddFull_uid101_fpFusedAddSubTest_q & excRZeroAdd_uid93_fpFusedAddSubTest_q;

    -- excREncAdd_uid112_fpFusedAddSubTest(LOOKUP,111)@1
    excREncAdd_uid112_fpFusedAddSubTest_combproc: PROCESS (concExcAdd_uid110_fpFusedAddSubTest_q)
    BEGIN
        -- Begin reserved scope level
        CASE (concExcAdd_uid110_fpFusedAddSubTest_q) IS
            WHEN "000" => excREncAdd_uid112_fpFusedAddSubTest_q <= "01";
            WHEN "001" => excREncAdd_uid112_fpFusedAddSubTest_q <= "00";
            WHEN "010" => excREncAdd_uid112_fpFusedAddSubTest_q <= "10";
            WHEN "011" => excREncAdd_uid112_fpFusedAddSubTest_q <= "00";
            WHEN "100" => excREncAdd_uid112_fpFusedAddSubTest_q <= "11";
            WHEN "101" => excREncAdd_uid112_fpFusedAddSubTest_q <= "00";
            WHEN "110" => excREncAdd_uid112_fpFusedAddSubTest_q <= "00";
            WHEN "111" => excREncAdd_uid112_fpFusedAddSubTest_q <= "00";
            WHEN OTHERS => -- unreachable
                           excREncAdd_uid112_fpFusedAddSubTest_q <= (others => '-');
        END CASE;
        -- End reserved scope level
    END PROCESS;

    -- expRPostExcAdd_uid124_fpFusedAddSubTest(MUX,123)@1
    expRPostExcAdd_uid124_fpFusedAddSubTest_s <= excREncAdd_uid112_fpFusedAddSubTest_q;
    expRPostExcAdd_uid124_fpFusedAddSubTest_combproc: PROCESS (expRPostExcAdd_uid124_fpFusedAddSubTest_s, cstAllZWE_uid13_fpFusedAddSubTest_q, expRPreExcAddition_uid114_fpFusedAddSubTest_q, cstAllOWE_uid11_fpFusedAddSubTest_q)
    BEGIN
        CASE (expRPostExcAdd_uid124_fpFusedAddSubTest_s) IS
            WHEN "00" => expRPostExcAdd_uid124_fpFusedAddSubTest_q <= cstAllZWE_uid13_fpFusedAddSubTest_q;
            WHEN "01" => expRPostExcAdd_uid124_fpFusedAddSubTest_q <= expRPreExcAddition_uid114_fpFusedAddSubTest_q;
            WHEN "10" => expRPostExcAdd_uid124_fpFusedAddSubTest_q <= cstAllOWE_uid11_fpFusedAddSubTest_q;
            WHEN "11" => expRPostExcAdd_uid124_fpFusedAddSubTest_q <= cstAllOWE_uid11_fpFusedAddSubTest_q;
            WHEN OTHERS => expRPostExcAdd_uid124_fpFusedAddSubTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- fracRPreExcAddition_uid113_fpFusedAddSubTest(MUX,112)@1
    fracRPreExcAddition_uid113_fpFusedAddSubTest_s <= effSub_uid45_fpFusedAddSubTest_q;
    fracRPreExcAddition_uid113_fpFusedAddSubTest_combproc: PROCESS (fracRPreExcAddition_uid113_fpFusedAddSubTest_s, fracRPreExcAdd_uid88_fpFusedAddSubTest_b, fracRPreExcSub_uid85_fpFusedAddSubTest_b)
    BEGIN
        CASE (fracRPreExcAddition_uid113_fpFusedAddSubTest_s) IS
            WHEN "0" => fracRPreExcAddition_uid113_fpFusedAddSubTest_q <= fracRPreExcAdd_uid88_fpFusedAddSubTest_b;
            WHEN "1" => fracRPreExcAddition_uid113_fpFusedAddSubTest_q <= fracRPreExcSub_uid85_fpFusedAddSubTest_b;
            WHEN OTHERS => fracRPreExcAddition_uid113_fpFusedAddSubTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- fracRPostExcAdd_uid120_fpFusedAddSubTest(MUX,119)@1
    fracRPostExcAdd_uid120_fpFusedAddSubTest_s <= excREncAdd_uid112_fpFusedAddSubTest_q;
    fracRPostExcAdd_uid120_fpFusedAddSubTest_combproc: PROCESS (fracRPostExcAdd_uid120_fpFusedAddSubTest_s, cstZeroWF_uid12_fpFusedAddSubTest_q, fracRPreExcAddition_uid113_fpFusedAddSubTest_q, oneFracRPostExc2_uid117_fpFusedAddSubTest_q)
    BEGIN
        CASE (fracRPostExcAdd_uid120_fpFusedAddSubTest_s) IS
            WHEN "00" => fracRPostExcAdd_uid120_fpFusedAddSubTest_q <= cstZeroWF_uid12_fpFusedAddSubTest_q;
            WHEN "01" => fracRPostExcAdd_uid120_fpFusedAddSubTest_q <= fracRPreExcAddition_uid113_fpFusedAddSubTest_q;
            WHEN "10" => fracRPostExcAdd_uid120_fpFusedAddSubTest_q <= cstZeroWF_uid12_fpFusedAddSubTest_q;
            WHEN "11" => fracRPostExcAdd_uid120_fpFusedAddSubTest_q <= oneFracRPostExc2_uid117_fpFusedAddSubTest_q;
            WHEN OTHERS => fracRPostExcAdd_uid120_fpFusedAddSubTest_q <= (others => '0');
        END CASE;
    END PROCESS;

    -- RSum_uid136_fpFusedAddSubTest(BITJOIN,135)@1
    RSum_uid136_fpFusedAddSubTest_q <= signRPostExc_uid135_fpFusedAddSubTest_q & expRPostExcAdd_uid124_fpFusedAddSubTest_q & fracRPostExcAdd_uid120_fpFusedAddSubTest_q;

    -- xOut(GPOUT,4)@1
    q <= RSum_uid136_fpFusedAddSubTest_q;
    s <= RDiff_uid158_fpFusedAddSubTest_q;

END normal;
