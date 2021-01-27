library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library IO;
use IO.DataType.all;
use IO.ArrayTypes.all;

library JetCompute;

use work.PkgConstants.all;

entity JetComputeWrapped is
port(
    clk : in std_logic;
    particles : in Vector(0 to NPARTICLES-1) := NullVector(NPARTICLES);
    seed_eta : in tData := cNull;
    seed_phi : in tData := cNull;
    jet : out tData := cNull
);
end JetComputeWrapped;

architecture rtl of JetComputeWrapped is
    signal jeti : tData := cNull;
begin

    HLSIP : entity JetCompute.jet_compute
    port map(
    ap_clk => clk,
    ap_rst => '0',
    ap_start => '1',
    particles_0 => particles(0).data(59 downto 0),
    particles_1 => particles(1).data(59 downto 0),
    particles_2 => particles(2).data(59 downto 0),
    particles_3 => particles(3).data(59 downto 0),
    particles_4 => particles(4).data(59 downto 0),
    particles_5 => particles(5).data(59 downto 0),
    particles_6 => particles(6).data(59 downto 0),
    particles_7 => particles(7).data(59 downto 0),
    particles_8 => particles(8).data(59 downto 0),
    particles_9 => particles(9).data(59 downto 0),
    particles_10 => particles(10).data(59 downto 0),
    particles_11 => particles(11).data(59 downto 0),
    particles_12 => particles(12).data(59 downto 0),
    particles_13 => particles(13).data(59 downto 0),
    particles_14 => particles(14).data(59 downto 0),
    particles_15 => particles(15).data(59 downto 0),
    particles_16 => particles(16).data(59 downto 0),
    particles_17 => particles(17).data(59 downto 0),
    particles_18 => particles(18).data(59 downto 0),
    particles_19 => particles(19).data(59 downto 0),
    particles_20 => particles(20).data(59 downto 0),
    particles_21 => particles(21).data(59 downto 0),
    particles_22 => particles(22).data(59 downto 0),
    particles_23 => particles(23).data(59 downto 0),
    particles_24 => particles(24).data(59 downto 0),
    particles_25 => particles(25).data(59 downto 0),
    particles_26 => particles(26).data(59 downto 0),
    particles_27 => particles(27).data(59 downto 0),
    particles_28 => particles(28).data(59 downto 0),
    particles_29 => particles(29).data(59 downto 0),
    particles_30 => particles(30).data(59 downto 0),
    particles_31 => particles(31).data(59 downto 0),
    particles_32 => particles(32).data(59 downto 0),
    particles_33 => particles(33).data(59 downto 0),
    particles_34 => particles(34).data(59 downto 0),
    particles_35 => particles(35).data(59 downto 0),
    particles_36 => particles(36).data(59 downto 0),
    particles_37 => particles(37).data(59 downto 0),
    particles_38 => particles(38).data(59 downto 0),
    particles_39 => particles(39).data(59 downto 0),
    particles_40 => particles(40).data(59 downto 0),
    particles_41 => particles(41).data(59 downto 0),
    particles_42 => particles(42).data(59 downto 0),
    particles_43 => particles(43).data(59 downto 0),
    particles_44 => particles(44).data(59 downto 0),
    particles_45 => particles(45).data(59 downto 0),
    particles_46 => particles(46).data(59 downto 0),
    particles_47 => particles(47).data(59 downto 0),
    particles_48 => particles(48).data(59 downto 0),
    particles_49 => particles(49).data(59 downto 0),
    particles_50 => particles(50).data(59 downto 0),
    particles_51 => particles(51).data(59 downto 0),
    particles_52 => particles(52).data(59 downto 0),
    particles_53 => particles(53).data(59 downto 0),
    particles_54 => particles(54).data(59 downto 0),
    particles_55 => particles(55).data(59 downto 0),
    particles_56 => particles(56).data(59 downto 0),
    particles_57 => particles(57).data(59 downto 0),
    particles_58 => particles(58).data(59 downto 0),
    particles_59 => particles(59).data(59 downto 0),
    particles_60 => particles(60).data(59 downto 0),
    particles_61 => particles(61).data(59 downto 0),
    particles_62 => particles(62).data(59 downto 0),
    particles_63 => particles(63).data(59 downto 0),
    particles_64 => particles(64).data(59 downto 0),
    particles_65 => particles(65).data(59 downto 0),
    particles_66 => particles(66).data(59 downto 0),
    particles_67 => particles(67).data(59 downto 0),
    particles_68 => particles(68).data(59 downto 0),
    particles_69 => particles(69).data(59 downto 0),
    particles_70 => particles(70).data(59 downto 0),
    particles_71 => particles(71).data(59 downto 0),
    particles_72 => particles(72).data(59 downto 0),
    particles_73 => particles(73).data(59 downto 0),
    particles_74 => particles(74).data(59 downto 0),
    particles_75 => particles(75).data(59 downto 0),
    particles_76 => particles(76).data(59 downto 0),
    particles_77 => particles(77).data(59 downto 0),
    particles_78 => particles(78).data(59 downto 0),
    particles_79 => particles(79).data(59 downto 0),
    particles_80 => particles(80).data(59 downto 0),
    particles_81 => particles(81).data(59 downto 0),
    particles_82 => particles(82).data(59 downto 0),
    particles_83 => particles(83).data(59 downto 0),
    particles_84 => particles(84).data(59 downto 0),
    particles_85 => particles(85).data(59 downto 0),
    particles_86 => particles(86).data(59 downto 0),
    particles_87 => particles(87).data(59 downto 0),
    particles_88 => particles(88).data(59 downto 0),
    particles_89 => particles(89).data(59 downto 0),
    particles_90 => particles(90).data(59 downto 0),
    particles_91 => particles(91).data(59 downto 0),
    particles_92 => particles(92).data(59 downto 0),
    particles_93 => particles(93).data(59 downto 0),
    particles_94 => particles(94).data(59 downto 0),
    particles_95 => particles(95).data(59 downto 0),
    particles_96 => particles(96).data(59 downto 0),
    particles_97 => particles(97).data(59 downto 0),
    particles_98 => particles(98).data(59 downto 0),
    particles_99 => particles(99).data(59 downto 0),
    particles_100 => particles(100).data(59 downto 0),
    particles_101 => particles(101).data(59 downto 0),
    particles_102 => particles(102).data(59 downto 0),
    particles_103 => particles(103).data(59 downto 0),
    particles_104 => particles(104).data(59 downto 0),
    particles_105 => particles(105).data(59 downto 0),
    particles_106 => particles(106).data(59 downto 0),
    particles_107 => particles(107).data(59 downto 0),
    particles_108 => particles(108).data(59 downto 0),
    particles_109 => particles(109).data(59 downto 0),
    particles_110 => particles(110).data(59 downto 0),
    particles_111 => particles(111).data(59 downto 0),
    particles_112 => particles(112).data(59 downto 0),
    particles_113 => particles(113).data(59 downto 0),
    particles_114 => particles(114).data(59 downto 0),
    particles_115 => particles(115).data(59 downto 0),
    particles_116 => particles(116).data(59 downto 0),
    particles_117 => particles(117).data(59 downto 0),
    particles_118 => particles(118).data(59 downto 0),
    particles_119 => particles(119).data(59 downto 0),
    particles_120 => particles(120).data(59 downto 0),
    particles_121 => particles(121).data(59 downto 0),
    particles_122 => particles(122).data(59 downto 0),
    particles_123 => particles(123).data(59 downto 0),
    particles_124 => particles(124).data(59 downto 0),
    particles_125 => particles(125).data(59 downto 0),
    particles_126 => particles(126).data(59 downto 0),
    particles_127 => particles(127).data(59 downto 0),
    seed_eta_V => seed_eta.data(9 downto 0),
    seed_phi_V => seed_phi.data(9 downto 0),
    jet => jet.data(45 downto 0)
    );

end rtl;

