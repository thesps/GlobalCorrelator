-- ==============================================================
-- RTL generated by Vivado(TM) HLS - High-Level Synthesis from C, C++ and SystemC
-- Version: 2018.2
-- Copyright (C) 1986-2018 Xilinx, Inc. All Rights Reserved.
-- 
-- ===========================================================

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity em2calo_sub is
port (
    ap_ready : OUT STD_LOGIC;
    calo_0_hwPt_V_read : IN STD_LOGIC_VECTOR (15 downto 0);
    calo_1_hwPt_V_read : IN STD_LOGIC_VECTOR (15 downto 0);
    calo_2_hwPt_V_read : IN STD_LOGIC_VECTOR (15 downto 0);
    calo_3_hwPt_V_read : IN STD_LOGIC_VECTOR (15 downto 0);
    calo_4_hwPt_V_read : IN STD_LOGIC_VECTOR (15 downto 0);
    calo_5_hwPt_V_read : IN STD_LOGIC_VECTOR (15 downto 0);
    calo_6_hwPt_V_read : IN STD_LOGIC_VECTOR (15 downto 0);
    calo_7_hwPt_V_read : IN STD_LOGIC_VECTOR (15 downto 0);
    calo_8_hwPt_V_read : IN STD_LOGIC_VECTOR (15 downto 0);
    calo_9_hwPt_V_read : IN STD_LOGIC_VECTOR (15 downto 0);
    calo_0_hwEta_V_read : IN STD_LOGIC_VECTOR (9 downto 0);
    calo_1_hwEta_V_read : IN STD_LOGIC_VECTOR (9 downto 0);
    calo_2_hwEta_V_read : IN STD_LOGIC_VECTOR (9 downto 0);
    calo_3_hwEta_V_read : IN STD_LOGIC_VECTOR (9 downto 0);
    calo_4_hwEta_V_read : IN STD_LOGIC_VECTOR (9 downto 0);
    calo_5_hwEta_V_read : IN STD_LOGIC_VECTOR (9 downto 0);
    calo_6_hwEta_V_read : IN STD_LOGIC_VECTOR (9 downto 0);
    calo_7_hwEta_V_read : IN STD_LOGIC_VECTOR (9 downto 0);
    calo_8_hwEta_V_read : IN STD_LOGIC_VECTOR (9 downto 0);
    calo_9_hwEta_V_read : IN STD_LOGIC_VECTOR (9 downto 0);
    calo_0_hwPhi_V_read : IN STD_LOGIC_VECTOR (9 downto 0);
    calo_1_hwPhi_V_read : IN STD_LOGIC_VECTOR (9 downto 0);
    calo_2_hwPhi_V_read : IN STD_LOGIC_VECTOR (9 downto 0);
    calo_3_hwPhi_V_read : IN STD_LOGIC_VECTOR (9 downto 0);
    calo_4_hwPhi_V_read : IN STD_LOGIC_VECTOR (9 downto 0);
    calo_5_hwPhi_V_read : IN STD_LOGIC_VECTOR (9 downto 0);
    calo_6_hwPhi_V_read : IN STD_LOGIC_VECTOR (9 downto 0);
    calo_7_hwPhi_V_read : IN STD_LOGIC_VECTOR (9 downto 0);
    calo_8_hwPhi_V_read : IN STD_LOGIC_VECTOR (9 downto 0);
    calo_9_hwPhi_V_read : IN STD_LOGIC_VECTOR (9 downto 0);
    calo_0_hwEmPt_V_rea : IN STD_LOGIC_VECTOR (15 downto 0);
    calo_1_hwEmPt_V_rea : IN STD_LOGIC_VECTOR (15 downto 0);
    calo_2_hwEmPt_V_rea : IN STD_LOGIC_VECTOR (15 downto 0);
    calo_3_hwEmPt_V_rea : IN STD_LOGIC_VECTOR (15 downto 0);
    calo_4_hwEmPt_V_rea : IN STD_LOGIC_VECTOR (15 downto 0);
    calo_5_hwEmPt_V_rea : IN STD_LOGIC_VECTOR (15 downto 0);
    calo_6_hwEmPt_V_rea : IN STD_LOGIC_VECTOR (15 downto 0);
    calo_7_hwEmPt_V_rea : IN STD_LOGIC_VECTOR (15 downto 0);
    calo_8_hwEmPt_V_rea : IN STD_LOGIC_VECTOR (15 downto 0);
    calo_9_hwEmPt_V_rea : IN STD_LOGIC_VECTOR (15 downto 0);
    calo_0_hwIsEM_read : IN STD_LOGIC;
    calo_1_hwIsEM_read : IN STD_LOGIC;
    calo_2_hwIsEM_read : IN STD_LOGIC;
    calo_3_hwIsEM_read : IN STD_LOGIC;
    calo_4_hwIsEM_read : IN STD_LOGIC;
    calo_5_hwIsEM_read : IN STD_LOGIC;
    calo_6_hwIsEM_read : IN STD_LOGIC;
    calo_7_hwIsEM_read : IN STD_LOGIC;
    calo_8_hwIsEM_read : IN STD_LOGIC;
    calo_9_hwIsEM_read : IN STD_LOGIC;
    sumem_0_V_read : IN STD_LOGIC_VECTOR (15 downto 0);
    sumem_1_V_read : IN STD_LOGIC_VECTOR (15 downto 0);
    sumem_2_V_read : IN STD_LOGIC_VECTOR (15 downto 0);
    sumem_3_V_read : IN STD_LOGIC_VECTOR (15 downto 0);
    sumem_4_V_read : IN STD_LOGIC_VECTOR (15 downto 0);
    sumem_5_V_read : IN STD_LOGIC_VECTOR (15 downto 0);
    sumem_6_V_read : IN STD_LOGIC_VECTOR (15 downto 0);
    sumem_7_V_read : IN STD_LOGIC_VECTOR (15 downto 0);
    sumem_8_V_read : IN STD_LOGIC_VECTOR (15 downto 0);
    sumem_9_V_read : IN STD_LOGIC_VECTOR (15 downto 0);
    ap_return_0 : OUT STD_LOGIC_VECTOR (15 downto 0);
    ap_return_1 : OUT STD_LOGIC_VECTOR (15 downto 0);
    ap_return_2 : OUT STD_LOGIC_VECTOR (15 downto 0);
    ap_return_3 : OUT STD_LOGIC_VECTOR (15 downto 0);
    ap_return_4 : OUT STD_LOGIC_VECTOR (15 downto 0);
    ap_return_5 : OUT STD_LOGIC_VECTOR (15 downto 0);
    ap_return_6 : OUT STD_LOGIC_VECTOR (15 downto 0);
    ap_return_7 : OUT STD_LOGIC_VECTOR (15 downto 0);
    ap_return_8 : OUT STD_LOGIC_VECTOR (15 downto 0);
    ap_return_9 : OUT STD_LOGIC_VECTOR (15 downto 0);
    ap_return_10 : OUT STD_LOGIC_VECTOR (9 downto 0);
    ap_return_11 : OUT STD_LOGIC_VECTOR (9 downto 0);
    ap_return_12 : OUT STD_LOGIC_VECTOR (9 downto 0);
    ap_return_13 : OUT STD_LOGIC_VECTOR (9 downto 0);
    ap_return_14 : OUT STD_LOGIC_VECTOR (9 downto 0);
    ap_return_15 : OUT STD_LOGIC_VECTOR (9 downto 0);
    ap_return_16 : OUT STD_LOGIC_VECTOR (9 downto 0);
    ap_return_17 : OUT STD_LOGIC_VECTOR (9 downto 0);
    ap_return_18 : OUT STD_LOGIC_VECTOR (9 downto 0);
    ap_return_19 : OUT STD_LOGIC_VECTOR (9 downto 0);
    ap_return_20 : OUT STD_LOGIC_VECTOR (9 downto 0);
    ap_return_21 : OUT STD_LOGIC_VECTOR (9 downto 0);
    ap_return_22 : OUT STD_LOGIC_VECTOR (9 downto 0);
    ap_return_23 : OUT STD_LOGIC_VECTOR (9 downto 0);
    ap_return_24 : OUT STD_LOGIC_VECTOR (9 downto 0);
    ap_return_25 : OUT STD_LOGIC_VECTOR (9 downto 0);
    ap_return_26 : OUT STD_LOGIC_VECTOR (9 downto 0);
    ap_return_27 : OUT STD_LOGIC_VECTOR (9 downto 0);
    ap_return_28 : OUT STD_LOGIC_VECTOR (9 downto 0);
    ap_return_29 : OUT STD_LOGIC_VECTOR (9 downto 0) );
end;


architecture behav of em2calo_sub is 
    constant ap_const_logic_1 : STD_LOGIC := '1';
    constant ap_const_boolean_1 : BOOLEAN := true;
    constant ap_const_lv32_4 : STD_LOGIC_VECTOR (31 downto 0) := "00000000000000000000000000000100";
    constant ap_const_lv32_F : STD_LOGIC_VECTOR (31 downto 0) := "00000000000000000000000000001111";
    constant ap_const_lv32_3 : STD_LOGIC_VECTOR (31 downto 0) := "00000000000000000000000000000011";
    constant ap_const_lv1_1 : STD_LOGIC_VECTOR (0 downto 0) := "1";
    constant ap_const_lv10_0 : STD_LOGIC_VECTOR (9 downto 0) := "0000000000";
    constant ap_const_lv16_0 : STD_LOGIC_VECTOR (15 downto 0) := "0000000000000000";
    constant ap_const_logic_0 : STD_LOGIC := '0';

    signal tmp_s_fu_516_p4 : STD_LOGIC_VECTOR (11 downto 0);
    signal tmp_58_fu_530_p4 : STD_LOGIC_VECTOR (12 downto 0);
    signal r_V_fu_526_p1 : STD_LOGIC_VECTOR (15 downto 0);
    signal ptsub_V_fu_504_p2 : STD_LOGIC_VECTOR (15 downto 0);
    signal slt_fu_544_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal r_V_9_fu_540_p1 : STD_LOGIC_VECTOR (15 downto 0);
    signal emsub_V_fu_510_p2 : STD_LOGIC_VECTOR (15 downto 0);
    signal slt34_fu_556_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal rev34_fu_562_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal sel_tmp2_fu_568_p1 : STD_LOGIC_VECTOR (0 downto 0);
    signal sel_tmp2_fu_568_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal rev_fu_550_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal sel_tmp3_fu_574_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal tmp_59_fu_616_p4 : STD_LOGIC_VECTOR (11 downto 0);
    signal tmp_60_fu_630_p4 : STD_LOGIC_VECTOR (12 downto 0);
    signal r_V_1_fu_626_p1 : STD_LOGIC_VECTOR (15 downto 0);
    signal ptsub_V_1_fu_604_p2 : STD_LOGIC_VECTOR (15 downto 0);
    signal slt35_fu_644_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal r_V_9_1_fu_640_p1 : STD_LOGIC_VECTOR (15 downto 0);
    signal emsub_V_s_fu_610_p2 : STD_LOGIC_VECTOR (15 downto 0);
    signal slt36_fu_656_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal rev36_fu_662_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal sel_tmp17_fu_668_p1 : STD_LOGIC_VECTOR (0 downto 0);
    signal sel_tmp17_fu_668_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal rev35_fu_650_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal sel_tmp18_fu_674_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal tmp_61_fu_716_p4 : STD_LOGIC_VECTOR (11 downto 0);
    signal tmp_62_fu_730_p4 : STD_LOGIC_VECTOR (12 downto 0);
    signal r_V_2_fu_726_p1 : STD_LOGIC_VECTOR (15 downto 0);
    signal ptsub_V_2_fu_704_p2 : STD_LOGIC_VECTOR (15 downto 0);
    signal slt37_fu_744_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal r_V_9_2_fu_740_p1 : STD_LOGIC_VECTOR (15 downto 0);
    signal emsub_V_2_fu_710_p2 : STD_LOGIC_VECTOR (15 downto 0);
    signal slt38_fu_756_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal rev38_fu_762_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal sel_tmp32_fu_768_p1 : STD_LOGIC_VECTOR (0 downto 0);
    signal sel_tmp32_fu_768_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal rev37_fu_750_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal sel_tmp33_fu_774_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal tmp_63_fu_816_p4 : STD_LOGIC_VECTOR (11 downto 0);
    signal tmp_64_fu_830_p4 : STD_LOGIC_VECTOR (12 downto 0);
    signal r_V_3_fu_826_p1 : STD_LOGIC_VECTOR (15 downto 0);
    signal ptsub_V_3_fu_804_p2 : STD_LOGIC_VECTOR (15 downto 0);
    signal slt39_fu_844_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal r_V_9_3_fu_840_p1 : STD_LOGIC_VECTOR (15 downto 0);
    signal emsub_V_3_fu_810_p2 : STD_LOGIC_VECTOR (15 downto 0);
    signal slt40_fu_856_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal rev40_fu_862_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal sel_tmp47_fu_868_p1 : STD_LOGIC_VECTOR (0 downto 0);
    signal sel_tmp47_fu_868_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal rev39_fu_850_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal sel_tmp48_fu_874_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal tmp_65_fu_916_p4 : STD_LOGIC_VECTOR (11 downto 0);
    signal tmp_66_fu_930_p4 : STD_LOGIC_VECTOR (12 downto 0);
    signal r_V_4_fu_926_p1 : STD_LOGIC_VECTOR (15 downto 0);
    signal ptsub_V_4_fu_904_p2 : STD_LOGIC_VECTOR (15 downto 0);
    signal slt41_fu_944_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal r_V_9_4_fu_940_p1 : STD_LOGIC_VECTOR (15 downto 0);
    signal emsub_V_4_fu_910_p2 : STD_LOGIC_VECTOR (15 downto 0);
    signal slt42_fu_956_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal rev42_fu_962_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal sel_tmp62_fu_968_p1 : STD_LOGIC_VECTOR (0 downto 0);
    signal sel_tmp62_fu_968_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal rev41_fu_950_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal sel_tmp63_fu_974_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal tmp_67_fu_1016_p4 : STD_LOGIC_VECTOR (11 downto 0);
    signal tmp_68_fu_1030_p4 : STD_LOGIC_VECTOR (12 downto 0);
    signal r_V_5_fu_1026_p1 : STD_LOGIC_VECTOR (15 downto 0);
    signal ptsub_V_5_fu_1004_p2 : STD_LOGIC_VECTOR (15 downto 0);
    signal slt43_fu_1044_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal r_V_9_5_fu_1040_p1 : STD_LOGIC_VECTOR (15 downto 0);
    signal emsub_V_5_fu_1010_p2 : STD_LOGIC_VECTOR (15 downto 0);
    signal slt44_fu_1056_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal rev44_fu_1062_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal sel_tmp77_fu_1068_p1 : STD_LOGIC_VECTOR (0 downto 0);
    signal sel_tmp77_fu_1068_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal rev43_fu_1050_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal sel_tmp78_fu_1074_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal tmp_69_fu_1116_p4 : STD_LOGIC_VECTOR (11 downto 0);
    signal tmp_70_fu_1130_p4 : STD_LOGIC_VECTOR (12 downto 0);
    signal r_V_6_fu_1126_p1 : STD_LOGIC_VECTOR (15 downto 0);
    signal ptsub_V_6_fu_1104_p2 : STD_LOGIC_VECTOR (15 downto 0);
    signal slt45_fu_1144_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal r_V_9_6_fu_1140_p1 : STD_LOGIC_VECTOR (15 downto 0);
    signal emsub_V_6_fu_1110_p2 : STD_LOGIC_VECTOR (15 downto 0);
    signal slt46_fu_1156_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal rev46_fu_1162_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal sel_tmp92_fu_1168_p1 : STD_LOGIC_VECTOR (0 downto 0);
    signal sel_tmp92_fu_1168_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal rev45_fu_1150_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal sel_tmp93_fu_1174_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal tmp_71_fu_1216_p4 : STD_LOGIC_VECTOR (11 downto 0);
    signal tmp_72_fu_1230_p4 : STD_LOGIC_VECTOR (12 downto 0);
    signal r_V_7_fu_1226_p1 : STD_LOGIC_VECTOR (15 downto 0);
    signal ptsub_V_7_fu_1204_p2 : STD_LOGIC_VECTOR (15 downto 0);
    signal slt47_fu_1244_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal r_V_9_7_fu_1240_p1 : STD_LOGIC_VECTOR (15 downto 0);
    signal emsub_V_7_fu_1210_p2 : STD_LOGIC_VECTOR (15 downto 0);
    signal slt48_fu_1256_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal rev48_fu_1262_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal sel_tmp107_fu_1268_p1 : STD_LOGIC_VECTOR (0 downto 0);
    signal sel_tmp107_fu_1268_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal rev47_fu_1250_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal sel_tmp108_fu_1274_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal tmp_73_fu_1316_p4 : STD_LOGIC_VECTOR (11 downto 0);
    signal tmp_74_fu_1330_p4 : STD_LOGIC_VECTOR (12 downto 0);
    signal r_V_8_fu_1326_p1 : STD_LOGIC_VECTOR (15 downto 0);
    signal ptsub_V_8_fu_1304_p2 : STD_LOGIC_VECTOR (15 downto 0);
    signal slt49_fu_1344_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal r_V_9_8_fu_1340_p1 : STD_LOGIC_VECTOR (15 downto 0);
    signal emsub_V_8_fu_1310_p2 : STD_LOGIC_VECTOR (15 downto 0);
    signal slt50_fu_1356_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal rev50_fu_1362_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal sel_tmp122_fu_1368_p1 : STD_LOGIC_VECTOR (0 downto 0);
    signal sel_tmp122_fu_1368_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal rev49_fu_1350_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal sel_tmp123_fu_1374_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal tmp_75_fu_1416_p4 : STD_LOGIC_VECTOR (11 downto 0);
    signal tmp_76_fu_1430_p4 : STD_LOGIC_VECTOR (12 downto 0);
    signal r_V_s_fu_1426_p1 : STD_LOGIC_VECTOR (15 downto 0);
    signal ptsub_V_9_fu_1404_p2 : STD_LOGIC_VECTOR (15 downto 0);
    signal slt51_fu_1444_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal r_V_9_9_fu_1440_p1 : STD_LOGIC_VECTOR (15 downto 0);
    signal emsub_V_9_fu_1410_p2 : STD_LOGIC_VECTOR (15 downto 0);
    signal slt52_fu_1456_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal rev52_fu_1462_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal sel_tmp137_fu_1468_p1 : STD_LOGIC_VECTOR (0 downto 0);
    signal sel_tmp137_fu_1468_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal rev51_fu_1450_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal sel_tmp138_fu_1474_p2 : STD_LOGIC_VECTOR (0 downto 0);
    signal calo_out_0_hwPt_V_w_fu_588_p3 : STD_LOGIC_VECTOR (15 downto 0);
    signal calo_out_1_hwPt_V_w_fu_688_p3 : STD_LOGIC_VECTOR (15 downto 0);
    signal calo_out_2_hwPt_V_w_fu_780_p3 : STD_LOGIC_VECTOR (15 downto 0);
    signal calo_out_3_hwPt_V_w_fu_880_p3 : STD_LOGIC_VECTOR (15 downto 0);
    signal calo_out_4_hwPt_V_w_fu_980_p3 : STD_LOGIC_VECTOR (15 downto 0);
    signal calo_out_5_hwPt_V_w_fu_1080_p3 : STD_LOGIC_VECTOR (15 downto 0);
    signal calo_out_6_hwPt_V_w_fu_1180_p3 : STD_LOGIC_VECTOR (15 downto 0);
    signal calo_out_7_hwPt_V_w_fu_1280_p3 : STD_LOGIC_VECTOR (15 downto 0);
    signal calo_out_8_hwPt_V_w_fu_1380_p3 : STD_LOGIC_VECTOR (15 downto 0);
    signal calo_out_9_hwPt_V_w_fu_1480_p3 : STD_LOGIC_VECTOR (15 downto 0);
    signal calo_out_0_hwEta_V_s_fu_580_p3 : STD_LOGIC_VECTOR (9 downto 0);
    signal calo_out_1_hwEta_V_s_fu_680_p3 : STD_LOGIC_VECTOR (9 downto 0);
    signal calo_out_2_hwEta_V_s_fu_788_p3 : STD_LOGIC_VECTOR (9 downto 0);
    signal calo_out_3_hwEta_V_s_fu_888_p3 : STD_LOGIC_VECTOR (9 downto 0);
    signal calo_out_4_hwEta_V_s_fu_988_p3 : STD_LOGIC_VECTOR (9 downto 0);
    signal calo_out_5_hwEta_V_s_fu_1088_p3 : STD_LOGIC_VECTOR (9 downto 0);
    signal calo_out_6_hwEta_V_s_fu_1188_p3 : STD_LOGIC_VECTOR (9 downto 0);
    signal calo_out_7_hwEta_V_s_fu_1288_p3 : STD_LOGIC_VECTOR (9 downto 0);
    signal calo_out_8_hwEta_V_s_fu_1388_p3 : STD_LOGIC_VECTOR (9 downto 0);
    signal calo_out_9_hwEta_V_s_fu_1488_p3 : STD_LOGIC_VECTOR (9 downto 0);
    signal calo_out_0_hwPhi_V_s_fu_596_p3 : STD_LOGIC_VECTOR (9 downto 0);
    signal calo_out_1_hwPhi_V_s_fu_696_p3 : STD_LOGIC_VECTOR (9 downto 0);
    signal calo_out_2_hwPhi_V_s_fu_796_p3 : STD_LOGIC_VECTOR (9 downto 0);
    signal calo_out_3_hwPhi_V_s_fu_896_p3 : STD_LOGIC_VECTOR (9 downto 0);
    signal calo_out_4_hwPhi_V_s_fu_996_p3 : STD_LOGIC_VECTOR (9 downto 0);
    signal calo_out_5_hwPhi_V_s_fu_1096_p3 : STD_LOGIC_VECTOR (9 downto 0);
    signal calo_out_6_hwPhi_V_s_fu_1196_p3 : STD_LOGIC_VECTOR (9 downto 0);
    signal calo_out_7_hwPhi_V_s_fu_1296_p3 : STD_LOGIC_VECTOR (9 downto 0);
    signal calo_out_8_hwPhi_V_s_fu_1396_p3 : STD_LOGIC_VECTOR (9 downto 0);
    signal calo_out_9_hwPhi_V_s_fu_1496_p3 : STD_LOGIC_VECTOR (9 downto 0);


begin



    ap_ready <= ap_const_logic_1;
    ap_return_0 <= calo_out_0_hwPt_V_w_fu_588_p3;
    ap_return_1 <= calo_out_1_hwPt_V_w_fu_688_p3;
    ap_return_10 <= calo_out_0_hwEta_V_s_fu_580_p3;
    ap_return_11 <= calo_out_1_hwEta_V_s_fu_680_p3;
    ap_return_12 <= calo_out_2_hwEta_V_s_fu_788_p3;
    ap_return_13 <= calo_out_3_hwEta_V_s_fu_888_p3;
    ap_return_14 <= calo_out_4_hwEta_V_s_fu_988_p3;
    ap_return_15 <= calo_out_5_hwEta_V_s_fu_1088_p3;
    ap_return_16 <= calo_out_6_hwEta_V_s_fu_1188_p3;
    ap_return_17 <= calo_out_7_hwEta_V_s_fu_1288_p3;
    ap_return_18 <= calo_out_8_hwEta_V_s_fu_1388_p3;
    ap_return_19 <= calo_out_9_hwEta_V_s_fu_1488_p3;
    ap_return_2 <= calo_out_2_hwPt_V_w_fu_780_p3;
    ap_return_20 <= calo_out_0_hwPhi_V_s_fu_596_p3;
    ap_return_21 <= calo_out_1_hwPhi_V_s_fu_696_p3;
    ap_return_22 <= calo_out_2_hwPhi_V_s_fu_796_p3;
    ap_return_23 <= calo_out_3_hwPhi_V_s_fu_896_p3;
    ap_return_24 <= calo_out_4_hwPhi_V_s_fu_996_p3;
    ap_return_25 <= calo_out_5_hwPhi_V_s_fu_1096_p3;
    ap_return_26 <= calo_out_6_hwPhi_V_s_fu_1196_p3;
    ap_return_27 <= calo_out_7_hwPhi_V_s_fu_1296_p3;
    ap_return_28 <= calo_out_8_hwPhi_V_s_fu_1396_p3;
    ap_return_29 <= calo_out_9_hwPhi_V_s_fu_1496_p3;
    ap_return_3 <= calo_out_3_hwPt_V_w_fu_880_p3;
    ap_return_4 <= calo_out_4_hwPt_V_w_fu_980_p3;
    ap_return_5 <= calo_out_5_hwPt_V_w_fu_1080_p3;
    ap_return_6 <= calo_out_6_hwPt_V_w_fu_1180_p3;
    ap_return_7 <= calo_out_7_hwPt_V_w_fu_1280_p3;
    ap_return_8 <= calo_out_8_hwPt_V_w_fu_1380_p3;
    ap_return_9 <= calo_out_9_hwPt_V_w_fu_1480_p3;
    calo_out_0_hwEta_V_s_fu_580_p3 <= 
        ap_const_lv10_0 when (sel_tmp3_fu_574_p2(0) = '1') else 
        calo_0_hwEta_V_read;
    calo_out_0_hwPhi_V_s_fu_596_p3 <= 
        ap_const_lv10_0 when (sel_tmp3_fu_574_p2(0) = '1') else 
        calo_0_hwPhi_V_read;
    calo_out_0_hwPt_V_w_fu_588_p3 <= 
        ap_const_lv16_0 when (sel_tmp3_fu_574_p2(0) = '1') else 
        ptsub_V_fu_504_p2;
    calo_out_1_hwEta_V_s_fu_680_p3 <= 
        ap_const_lv10_0 when (sel_tmp18_fu_674_p2(0) = '1') else 
        calo_1_hwEta_V_read;
    calo_out_1_hwPhi_V_s_fu_696_p3 <= 
        ap_const_lv10_0 when (sel_tmp18_fu_674_p2(0) = '1') else 
        calo_1_hwPhi_V_read;
    calo_out_1_hwPt_V_w_fu_688_p3 <= 
        ap_const_lv16_0 when (sel_tmp18_fu_674_p2(0) = '1') else 
        ptsub_V_1_fu_604_p2;
    calo_out_2_hwEta_V_s_fu_788_p3 <= 
        ap_const_lv10_0 when (sel_tmp33_fu_774_p2(0) = '1') else 
        calo_2_hwEta_V_read;
    calo_out_2_hwPhi_V_s_fu_796_p3 <= 
        ap_const_lv10_0 when (sel_tmp33_fu_774_p2(0) = '1') else 
        calo_2_hwPhi_V_read;
    calo_out_2_hwPt_V_w_fu_780_p3 <= 
        ap_const_lv16_0 when (sel_tmp33_fu_774_p2(0) = '1') else 
        ptsub_V_2_fu_704_p2;
    calo_out_3_hwEta_V_s_fu_888_p3 <= 
        ap_const_lv10_0 when (sel_tmp48_fu_874_p2(0) = '1') else 
        calo_3_hwEta_V_read;
    calo_out_3_hwPhi_V_s_fu_896_p3 <= 
        ap_const_lv10_0 when (sel_tmp48_fu_874_p2(0) = '1') else 
        calo_3_hwPhi_V_read;
    calo_out_3_hwPt_V_w_fu_880_p3 <= 
        ap_const_lv16_0 when (sel_tmp48_fu_874_p2(0) = '1') else 
        ptsub_V_3_fu_804_p2;
    calo_out_4_hwEta_V_s_fu_988_p3 <= 
        ap_const_lv10_0 when (sel_tmp63_fu_974_p2(0) = '1') else 
        calo_4_hwEta_V_read;
    calo_out_4_hwPhi_V_s_fu_996_p3 <= 
        ap_const_lv10_0 when (sel_tmp63_fu_974_p2(0) = '1') else 
        calo_4_hwPhi_V_read;
    calo_out_4_hwPt_V_w_fu_980_p3 <= 
        ap_const_lv16_0 when (sel_tmp63_fu_974_p2(0) = '1') else 
        ptsub_V_4_fu_904_p2;
    calo_out_5_hwEta_V_s_fu_1088_p3 <= 
        ap_const_lv10_0 when (sel_tmp78_fu_1074_p2(0) = '1') else 
        calo_5_hwEta_V_read;
    calo_out_5_hwPhi_V_s_fu_1096_p3 <= 
        ap_const_lv10_0 when (sel_tmp78_fu_1074_p2(0) = '1') else 
        calo_5_hwPhi_V_read;
    calo_out_5_hwPt_V_w_fu_1080_p3 <= 
        ap_const_lv16_0 when (sel_tmp78_fu_1074_p2(0) = '1') else 
        ptsub_V_5_fu_1004_p2;
    calo_out_6_hwEta_V_s_fu_1188_p3 <= 
        ap_const_lv10_0 when (sel_tmp93_fu_1174_p2(0) = '1') else 
        calo_6_hwEta_V_read;
    calo_out_6_hwPhi_V_s_fu_1196_p3 <= 
        ap_const_lv10_0 when (sel_tmp93_fu_1174_p2(0) = '1') else 
        calo_6_hwPhi_V_read;
    calo_out_6_hwPt_V_w_fu_1180_p3 <= 
        ap_const_lv16_0 when (sel_tmp93_fu_1174_p2(0) = '1') else 
        ptsub_V_6_fu_1104_p2;
    calo_out_7_hwEta_V_s_fu_1288_p3 <= 
        ap_const_lv10_0 when (sel_tmp108_fu_1274_p2(0) = '1') else 
        calo_7_hwEta_V_read;
    calo_out_7_hwPhi_V_s_fu_1296_p3 <= 
        ap_const_lv10_0 when (sel_tmp108_fu_1274_p2(0) = '1') else 
        calo_7_hwPhi_V_read;
    calo_out_7_hwPt_V_w_fu_1280_p3 <= 
        ap_const_lv16_0 when (sel_tmp108_fu_1274_p2(0) = '1') else 
        ptsub_V_7_fu_1204_p2;
    calo_out_8_hwEta_V_s_fu_1388_p3 <= 
        ap_const_lv10_0 when (sel_tmp123_fu_1374_p2(0) = '1') else 
        calo_8_hwEta_V_read;
    calo_out_8_hwPhi_V_s_fu_1396_p3 <= 
        ap_const_lv10_0 when (sel_tmp123_fu_1374_p2(0) = '1') else 
        calo_8_hwPhi_V_read;
    calo_out_8_hwPt_V_w_fu_1380_p3 <= 
        ap_const_lv16_0 when (sel_tmp123_fu_1374_p2(0) = '1') else 
        ptsub_V_8_fu_1304_p2;
    calo_out_9_hwEta_V_s_fu_1488_p3 <= 
        ap_const_lv10_0 when (sel_tmp138_fu_1474_p2(0) = '1') else 
        calo_9_hwEta_V_read;
    calo_out_9_hwPhi_V_s_fu_1496_p3 <= 
        ap_const_lv10_0 when (sel_tmp138_fu_1474_p2(0) = '1') else 
        calo_9_hwPhi_V_read;
    calo_out_9_hwPt_V_w_fu_1480_p3 <= 
        ap_const_lv16_0 when (sel_tmp138_fu_1474_p2(0) = '1') else 
        ptsub_V_9_fu_1404_p2;
    emsub_V_2_fu_710_p2 <= std_logic_vector(unsigned(calo_2_hwEmPt_V_rea) - unsigned(sumem_2_V_read));
    emsub_V_3_fu_810_p2 <= std_logic_vector(unsigned(calo_3_hwEmPt_V_rea) - unsigned(sumem_3_V_read));
    emsub_V_4_fu_910_p2 <= std_logic_vector(unsigned(calo_4_hwEmPt_V_rea) - unsigned(sumem_4_V_read));
    emsub_V_5_fu_1010_p2 <= std_logic_vector(unsigned(calo_5_hwEmPt_V_rea) - unsigned(sumem_5_V_read));
    emsub_V_6_fu_1110_p2 <= std_logic_vector(unsigned(calo_6_hwEmPt_V_rea) - unsigned(sumem_6_V_read));
    emsub_V_7_fu_1210_p2 <= std_logic_vector(unsigned(calo_7_hwEmPt_V_rea) - unsigned(sumem_7_V_read));
    emsub_V_8_fu_1310_p2 <= std_logic_vector(unsigned(calo_8_hwEmPt_V_rea) - unsigned(sumem_8_V_read));
    emsub_V_9_fu_1410_p2 <= std_logic_vector(unsigned(calo_9_hwEmPt_V_rea) - unsigned(sumem_9_V_read));
    emsub_V_fu_510_p2 <= std_logic_vector(unsigned(calo_0_hwEmPt_V_rea) - unsigned(sumem_0_V_read));
    emsub_V_s_fu_610_p2 <= std_logic_vector(unsigned(calo_1_hwEmPt_V_rea) - unsigned(sumem_1_V_read));
    ptsub_V_1_fu_604_p2 <= std_logic_vector(unsigned(calo_1_hwPt_V_read) - unsigned(sumem_1_V_read));
    ptsub_V_2_fu_704_p2 <= std_logic_vector(unsigned(calo_2_hwPt_V_read) - unsigned(sumem_2_V_read));
    ptsub_V_3_fu_804_p2 <= std_logic_vector(unsigned(calo_3_hwPt_V_read) - unsigned(sumem_3_V_read));
    ptsub_V_4_fu_904_p2 <= std_logic_vector(unsigned(calo_4_hwPt_V_read) - unsigned(sumem_4_V_read));
    ptsub_V_5_fu_1004_p2 <= std_logic_vector(unsigned(calo_5_hwPt_V_read) - unsigned(sumem_5_V_read));
    ptsub_V_6_fu_1104_p2 <= std_logic_vector(unsigned(calo_6_hwPt_V_read) - unsigned(sumem_6_V_read));
    ptsub_V_7_fu_1204_p2 <= std_logic_vector(unsigned(calo_7_hwPt_V_read) - unsigned(sumem_7_V_read));
    ptsub_V_8_fu_1304_p2 <= std_logic_vector(unsigned(calo_8_hwPt_V_read) - unsigned(sumem_8_V_read));
    ptsub_V_9_fu_1404_p2 <= std_logic_vector(unsigned(calo_9_hwPt_V_read) - unsigned(sumem_9_V_read));
    ptsub_V_fu_504_p2 <= std_logic_vector(unsigned(calo_0_hwPt_V_read) - unsigned(sumem_0_V_read));
        r_V_1_fu_626_p1 <= std_logic_vector(IEEE.numeric_std.resize(signed(tmp_59_fu_616_p4),16));

        r_V_2_fu_726_p1 <= std_logic_vector(IEEE.numeric_std.resize(signed(tmp_61_fu_716_p4),16));

        r_V_3_fu_826_p1 <= std_logic_vector(IEEE.numeric_std.resize(signed(tmp_63_fu_816_p4),16));

        r_V_4_fu_926_p1 <= std_logic_vector(IEEE.numeric_std.resize(signed(tmp_65_fu_916_p4),16));

        r_V_5_fu_1026_p1 <= std_logic_vector(IEEE.numeric_std.resize(signed(tmp_67_fu_1016_p4),16));

        r_V_6_fu_1126_p1 <= std_logic_vector(IEEE.numeric_std.resize(signed(tmp_69_fu_1116_p4),16));

        r_V_7_fu_1226_p1 <= std_logic_vector(IEEE.numeric_std.resize(signed(tmp_71_fu_1216_p4),16));

        r_V_8_fu_1326_p1 <= std_logic_vector(IEEE.numeric_std.resize(signed(tmp_73_fu_1316_p4),16));

        r_V_9_1_fu_640_p1 <= std_logic_vector(IEEE.numeric_std.resize(signed(tmp_60_fu_630_p4),16));

        r_V_9_2_fu_740_p1 <= std_logic_vector(IEEE.numeric_std.resize(signed(tmp_62_fu_730_p4),16));

        r_V_9_3_fu_840_p1 <= std_logic_vector(IEEE.numeric_std.resize(signed(tmp_64_fu_830_p4),16));

        r_V_9_4_fu_940_p1 <= std_logic_vector(IEEE.numeric_std.resize(signed(tmp_66_fu_930_p4),16));

        r_V_9_5_fu_1040_p1 <= std_logic_vector(IEEE.numeric_std.resize(signed(tmp_68_fu_1030_p4),16));

        r_V_9_6_fu_1140_p1 <= std_logic_vector(IEEE.numeric_std.resize(signed(tmp_70_fu_1130_p4),16));

        r_V_9_7_fu_1240_p1 <= std_logic_vector(IEEE.numeric_std.resize(signed(tmp_72_fu_1230_p4),16));

        r_V_9_8_fu_1340_p1 <= std_logic_vector(IEEE.numeric_std.resize(signed(tmp_74_fu_1330_p4),16));

        r_V_9_9_fu_1440_p1 <= std_logic_vector(IEEE.numeric_std.resize(signed(tmp_76_fu_1430_p4),16));

        r_V_9_fu_540_p1 <= std_logic_vector(IEEE.numeric_std.resize(signed(tmp_58_fu_530_p4),16));

        r_V_fu_526_p1 <= std_logic_vector(IEEE.numeric_std.resize(signed(tmp_s_fu_516_p4),16));

        r_V_s_fu_1426_p1 <= std_logic_vector(IEEE.numeric_std.resize(signed(tmp_75_fu_1416_p4),16));

    rev34_fu_562_p2 <= (slt34_fu_556_p2 xor ap_const_lv1_1);
    rev35_fu_650_p2 <= (slt35_fu_644_p2 xor ap_const_lv1_1);
    rev36_fu_662_p2 <= (slt36_fu_656_p2 xor ap_const_lv1_1);
    rev37_fu_750_p2 <= (slt37_fu_744_p2 xor ap_const_lv1_1);
    rev38_fu_762_p2 <= (slt38_fu_756_p2 xor ap_const_lv1_1);
    rev39_fu_850_p2 <= (slt39_fu_844_p2 xor ap_const_lv1_1);
    rev40_fu_862_p2 <= (slt40_fu_856_p2 xor ap_const_lv1_1);
    rev41_fu_950_p2 <= (slt41_fu_944_p2 xor ap_const_lv1_1);
    rev42_fu_962_p2 <= (slt42_fu_956_p2 xor ap_const_lv1_1);
    rev43_fu_1050_p2 <= (slt43_fu_1044_p2 xor ap_const_lv1_1);
    rev44_fu_1062_p2 <= (slt44_fu_1056_p2 xor ap_const_lv1_1);
    rev45_fu_1150_p2 <= (slt45_fu_1144_p2 xor ap_const_lv1_1);
    rev46_fu_1162_p2 <= (slt46_fu_1156_p2 xor ap_const_lv1_1);
    rev47_fu_1250_p2 <= (slt47_fu_1244_p2 xor ap_const_lv1_1);
    rev48_fu_1262_p2 <= (slt48_fu_1256_p2 xor ap_const_lv1_1);
    rev49_fu_1350_p2 <= (slt49_fu_1344_p2 xor ap_const_lv1_1);
    rev50_fu_1362_p2 <= (slt50_fu_1356_p2 xor ap_const_lv1_1);
    rev51_fu_1450_p2 <= (slt51_fu_1444_p2 xor ap_const_lv1_1);
    rev52_fu_1462_p2 <= (slt52_fu_1456_p2 xor ap_const_lv1_1);
    rev_fu_550_p2 <= (slt_fu_544_p2 xor ap_const_lv1_1);
    sel_tmp107_fu_1268_p1 <= (0=>calo_7_hwIsEM_read, others=>'-');
    sel_tmp107_fu_1268_p2 <= (sel_tmp107_fu_1268_p1 and rev48_fu_1262_p2);
    sel_tmp108_fu_1274_p2 <= (sel_tmp107_fu_1268_p2 or rev47_fu_1250_p2);
    sel_tmp122_fu_1368_p1 <= (0=>calo_8_hwIsEM_read, others=>'-');
    sel_tmp122_fu_1368_p2 <= (sel_tmp122_fu_1368_p1 and rev50_fu_1362_p2);
    sel_tmp123_fu_1374_p2 <= (sel_tmp122_fu_1368_p2 or rev49_fu_1350_p2);
    sel_tmp137_fu_1468_p1 <= (0=>calo_9_hwIsEM_read, others=>'-');
    sel_tmp137_fu_1468_p2 <= (sel_tmp137_fu_1468_p1 and rev52_fu_1462_p2);
    sel_tmp138_fu_1474_p2 <= (sel_tmp137_fu_1468_p2 or rev51_fu_1450_p2);
    sel_tmp17_fu_668_p1 <= (0=>calo_1_hwIsEM_read, others=>'-');
    sel_tmp17_fu_668_p2 <= (sel_tmp17_fu_668_p1 and rev36_fu_662_p2);
    sel_tmp18_fu_674_p2 <= (sel_tmp17_fu_668_p2 or rev35_fu_650_p2);
    sel_tmp2_fu_568_p1 <= (0=>calo_0_hwIsEM_read, others=>'-');
    sel_tmp2_fu_568_p2 <= (sel_tmp2_fu_568_p1 and rev34_fu_562_p2);
    sel_tmp32_fu_768_p1 <= (0=>calo_2_hwIsEM_read, others=>'-');
    sel_tmp32_fu_768_p2 <= (sel_tmp32_fu_768_p1 and rev38_fu_762_p2);
    sel_tmp33_fu_774_p2 <= (sel_tmp32_fu_768_p2 or rev37_fu_750_p2);
    sel_tmp3_fu_574_p2 <= (sel_tmp2_fu_568_p2 or rev_fu_550_p2);
    sel_tmp47_fu_868_p1 <= (0=>calo_3_hwIsEM_read, others=>'-');
    sel_tmp47_fu_868_p2 <= (sel_tmp47_fu_868_p1 and rev40_fu_862_p2);
    sel_tmp48_fu_874_p2 <= (sel_tmp47_fu_868_p2 or rev39_fu_850_p2);
    sel_tmp62_fu_968_p1 <= (0=>calo_4_hwIsEM_read, others=>'-');
    sel_tmp62_fu_968_p2 <= (sel_tmp62_fu_968_p1 and rev42_fu_962_p2);
    sel_tmp63_fu_974_p2 <= (sel_tmp62_fu_968_p2 or rev41_fu_950_p2);
    sel_tmp77_fu_1068_p1 <= (0=>calo_5_hwIsEM_read, others=>'-');
    sel_tmp77_fu_1068_p2 <= (sel_tmp77_fu_1068_p1 and rev44_fu_1062_p2);
    sel_tmp78_fu_1074_p2 <= (sel_tmp77_fu_1068_p2 or rev43_fu_1050_p2);
    sel_tmp92_fu_1168_p1 <= (0=>calo_6_hwIsEM_read, others=>'-');
    sel_tmp92_fu_1168_p2 <= (sel_tmp92_fu_1168_p1 and rev46_fu_1162_p2);
    sel_tmp93_fu_1174_p2 <= (sel_tmp92_fu_1168_p2 or rev45_fu_1150_p2);
    slt34_fu_556_p2 <= "1" when (signed(r_V_9_fu_540_p1) < signed(emsub_V_fu_510_p2)) else "0";
    slt35_fu_644_p2 <= "1" when (signed(r_V_1_fu_626_p1) < signed(ptsub_V_1_fu_604_p2)) else "0";
    slt36_fu_656_p2 <= "1" when (signed(r_V_9_1_fu_640_p1) < signed(emsub_V_s_fu_610_p2)) else "0";
    slt37_fu_744_p2 <= "1" when (signed(r_V_2_fu_726_p1) < signed(ptsub_V_2_fu_704_p2)) else "0";
    slt38_fu_756_p2 <= "1" when (signed(r_V_9_2_fu_740_p1) < signed(emsub_V_2_fu_710_p2)) else "0";
    slt39_fu_844_p2 <= "1" when (signed(r_V_3_fu_826_p1) < signed(ptsub_V_3_fu_804_p2)) else "0";
    slt40_fu_856_p2 <= "1" when (signed(r_V_9_3_fu_840_p1) < signed(emsub_V_3_fu_810_p2)) else "0";
    slt41_fu_944_p2 <= "1" when (signed(r_V_4_fu_926_p1) < signed(ptsub_V_4_fu_904_p2)) else "0";
    slt42_fu_956_p2 <= "1" when (signed(r_V_9_4_fu_940_p1) < signed(emsub_V_4_fu_910_p2)) else "0";
    slt43_fu_1044_p2 <= "1" when (signed(r_V_5_fu_1026_p1) < signed(ptsub_V_5_fu_1004_p2)) else "0";
    slt44_fu_1056_p2 <= "1" when (signed(r_V_9_5_fu_1040_p1) < signed(emsub_V_5_fu_1010_p2)) else "0";
    slt45_fu_1144_p2 <= "1" when (signed(r_V_6_fu_1126_p1) < signed(ptsub_V_6_fu_1104_p2)) else "0";
    slt46_fu_1156_p2 <= "1" when (signed(r_V_9_6_fu_1140_p1) < signed(emsub_V_6_fu_1110_p2)) else "0";
    slt47_fu_1244_p2 <= "1" when (signed(r_V_7_fu_1226_p1) < signed(ptsub_V_7_fu_1204_p2)) else "0";
    slt48_fu_1256_p2 <= "1" when (signed(r_V_9_7_fu_1240_p1) < signed(emsub_V_7_fu_1210_p2)) else "0";
    slt49_fu_1344_p2 <= "1" when (signed(r_V_8_fu_1326_p1) < signed(ptsub_V_8_fu_1304_p2)) else "0";
    slt50_fu_1356_p2 <= "1" when (signed(r_V_9_8_fu_1340_p1) < signed(emsub_V_8_fu_1310_p2)) else "0";
    slt51_fu_1444_p2 <= "1" when (signed(r_V_s_fu_1426_p1) < signed(ptsub_V_9_fu_1404_p2)) else "0";
    slt52_fu_1456_p2 <= "1" when (signed(r_V_9_9_fu_1440_p1) < signed(emsub_V_9_fu_1410_p2)) else "0";
    slt_fu_544_p2 <= "1" when (signed(r_V_fu_526_p1) < signed(ptsub_V_fu_504_p2)) else "0";
    tmp_58_fu_530_p4 <= calo_0_hwEmPt_V_rea(15 downto 3);
    tmp_59_fu_616_p4 <= calo_1_hwPt_V_read(15 downto 4);
    tmp_60_fu_630_p4 <= calo_1_hwEmPt_V_rea(15 downto 3);
    tmp_61_fu_716_p4 <= calo_2_hwPt_V_read(15 downto 4);
    tmp_62_fu_730_p4 <= calo_2_hwEmPt_V_rea(15 downto 3);
    tmp_63_fu_816_p4 <= calo_3_hwPt_V_read(15 downto 4);
    tmp_64_fu_830_p4 <= calo_3_hwEmPt_V_rea(15 downto 3);
    tmp_65_fu_916_p4 <= calo_4_hwPt_V_read(15 downto 4);
    tmp_66_fu_930_p4 <= calo_4_hwEmPt_V_rea(15 downto 3);
    tmp_67_fu_1016_p4 <= calo_5_hwPt_V_read(15 downto 4);
    tmp_68_fu_1030_p4 <= calo_5_hwEmPt_V_rea(15 downto 3);
    tmp_69_fu_1116_p4 <= calo_6_hwPt_V_read(15 downto 4);
    tmp_70_fu_1130_p4 <= calo_6_hwEmPt_V_rea(15 downto 3);
    tmp_71_fu_1216_p4 <= calo_7_hwPt_V_read(15 downto 4);
    tmp_72_fu_1230_p4 <= calo_7_hwEmPt_V_rea(15 downto 3);
    tmp_73_fu_1316_p4 <= calo_8_hwPt_V_read(15 downto 4);
    tmp_74_fu_1330_p4 <= calo_8_hwEmPt_V_rea(15 downto 3);
    tmp_75_fu_1416_p4 <= calo_9_hwPt_V_read(15 downto 4);
    tmp_76_fu_1430_p4 <= calo_9_hwEmPt_V_rea(15 downto 3);
    tmp_s_fu_516_p4 <= calo_0_hwPt_V_read(15 downto 4);
end behav;