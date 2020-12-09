library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library IO;
use IO.DataType.all;
use IO.ArrayTypes.all;

entity JetAlgoWrapped is
port(
    clk   : in std_logic;
    d     : in Vector(0 to 127) := NullVector(128);
    start : in std_logic := '0';
    q     : out Vector(0 to 9) := NullVector(10)
);
end;

architecture rtl of jetAlgoWrapped is
    signal qi : Vector(0 to 9) := NullVector(10);
begin

    algo : entity work.algo_main
    port map(
    ap_clk => clk,
    ap_rst => '0',
    ap_start => start,
    particles_0 => d(0).data(35 downto 0),
    particles_1 => d(1).data(35 downto 0),
    particles_2 => d(2).data(35 downto 0),
    particles_3 => d(3).data(35 downto 0),
    particles_4 => d(4).data(35 downto 0),
    particles_5 => d(5).data(35 downto 0),
    particles_6 => d(6).data(35 downto 0),
    particles_7 => d(7).data(35 downto 0),
    particles_8 => d(8).data(35 downto 0),
    particles_9 => d(9).data(35 downto 0),
    particles_10 => d(10).data(35 downto 0),
    particles_11 => d(11).data(35 downto 0),
    particles_12 => d(12).data(35 downto 0),
    particles_13 => d(13).data(35 downto 0),
    particles_14 => d(14).data(35 downto 0),
    particles_15 => d(15).data(35 downto 0),
    particles_16 => d(16).data(35 downto 0),
    particles_17 => d(17).data(35 downto 0),
    particles_18 => d(18).data(35 downto 0),
    particles_19 => d(19).data(35 downto 0),
    particles_20 => d(20).data(35 downto 0),
    particles_21 => d(21).data(35 downto 0),
    particles_22 => d(22).data(35 downto 0),
    particles_23 => d(23).data(35 downto 0),
    particles_24 => d(24).data(35 downto 0),
    particles_25 => d(25).data(35 downto 0),
    particles_26 => d(26).data(35 downto 0),
    particles_27 => d(27).data(35 downto 0),
    particles_28 => d(28).data(35 downto 0),
    particles_29 => d(29).data(35 downto 0),
    particles_30 => d(30).data(35 downto 0),
    particles_31 => d(31).data(35 downto 0),
    particles_32 => d(32).data(35 downto 0),
    particles_33 => d(33).data(35 downto 0),
    particles_34 => d(34).data(35 downto 0),
    particles_35 => d(35).data(35 downto 0),
    particles_36 => d(36).data(35 downto 0),
    particles_37 => d(37).data(35 downto 0),
    particles_38 => d(38).data(35 downto 0),
    particles_39 => d(39).data(35 downto 0),
    particles_40 => d(40).data(35 downto 0),
    particles_41 => d(41).data(35 downto 0),
    particles_42 => d(42).data(35 downto 0),
    particles_43 => d(43).data(35 downto 0),
    particles_44 => d(44).data(35 downto 0),
    particles_45 => d(45).data(35 downto 0),
    particles_46 => d(46).data(35 downto 0),
    particles_47 => d(47).data(35 downto 0),
    particles_48 => d(48).data(35 downto 0),
    particles_49 => d(49).data(35 downto 0),
    particles_50 => d(50).data(35 downto 0),
    particles_51 => d(51).data(35 downto 0),
    particles_52 => d(52).data(35 downto 0),
    particles_53 => d(53).data(35 downto 0),
    particles_54 => d(54).data(35 downto 0),
    particles_55 => d(55).data(35 downto 0),
    particles_56 => d(56).data(35 downto 0),
    particles_57 => d(57).data(35 downto 0),
    particles_58 => d(58).data(35 downto 0),
    particles_59 => d(59).data(35 downto 0),
    particles_60 => d(60).data(35 downto 0),
    particles_61 => d(61).data(35 downto 0),
    particles_62 => d(62).data(35 downto 0),
    particles_63 => d(63).data(35 downto 0),
    particles_64 => d(64).data(35 downto 0),
    particles_65 => d(65).data(35 downto 0),
    particles_66 => d(66).data(35 downto 0),
    particles_67 => d(67).data(35 downto 0),
    particles_68 => d(68).data(35 downto 0),
    particles_69 => d(69).data(35 downto 0),
    particles_70 => d(70).data(35 downto 0),
    particles_71 => d(71).data(35 downto 0),
    particles_72 => d(72).data(35 downto 0),
    particles_73 => d(73).data(35 downto 0),
    particles_74 => d(74).data(35 downto 0),
    particles_75 => d(75).data(35 downto 0),
    particles_76 => d(76).data(35 downto 0),
    particles_77 => d(77).data(35 downto 0),
    particles_78 => d(78).data(35 downto 0),
    particles_79 => d(79).data(35 downto 0),
    particles_80 => d(80).data(35 downto 0),
    particles_81 => d(81).data(35 downto 0),
    particles_82 => d(82).data(35 downto 0),
    particles_83 => d(83).data(35 downto 0),
    particles_84 => d(84).data(35 downto 0),
    particles_85 => d(85).data(35 downto 0),
    particles_86 => d(86).data(35 downto 0),
    particles_87 => d(87).data(35 downto 0),
    particles_88 => d(88).data(35 downto 0),
    particles_89 => d(89).data(35 downto 0),
    particles_90 => d(90).data(35 downto 0),
    particles_91 => d(91).data(35 downto 0),
    particles_92 => d(92).data(35 downto 0),
    particles_93 => d(93).data(35 downto 0),
    particles_94 => d(94).data(35 downto 0),
    particles_95 => d(95).data(35 downto 0),
    particles_96 => d(96).data(35 downto 0),
    particles_97 => d(97).data(35 downto 0),
    particles_98 => d(98).data(35 downto 0),
    particles_99 => d(99).data(35 downto 0),
    particles_100 => d(100).data(35 downto 0),
    particles_101 => d(101).data(35 downto 0),
    particles_102 => d(102).data(35 downto 0),
    particles_103 => d(103).data(35 downto 0),
    particles_104 => d(104).data(35 downto 0),
    particles_105 => d(105).data(35 downto 0),
    particles_106 => d(106).data(35 downto 0),
    particles_107 => d(107).data(35 downto 0),
    particles_108 => d(108).data(35 downto 0),
    particles_109 => d(109).data(35 downto 0),
    particles_110 => d(110).data(35 downto 0),
    particles_111 => d(111).data(35 downto 0),
    particles_112 => d(112).data(35 downto 0),
    particles_113 => d(113).data(35 downto 0),
    particles_114 => d(114).data(35 downto 0),
    particles_115 => d(115).data(35 downto 0),
    particles_116 => d(116).data(35 downto 0),
    particles_117 => d(117).data(35 downto 0),
    particles_118 => d(118).data(35 downto 0),
    particles_119 => d(119).data(35 downto 0),
    particles_120 => d(120).data(35 downto 0),
    particles_121 => d(121).data(35 downto 0),
    particles_122 => d(122).data(35 downto 0),
    particles_123 => d(123).data(35 downto 0),
    particles_124 => d(124).data(35 downto 0),
    particles_125 => d(125).data(35 downto 0),
    particles_126 => d(126).data(35 downto 0),
    particles_127 => d(127).data(35 downto 0),
    jet_0 => qi(0).data(45 downto 0),
    jet_1 => qi(1).data(45 downto 0),
    jet_2 => qi(2).data(45 downto 0),
    jet_3 => qi(3).data(45 downto 0),
    jet_4 => qi(4).data(45 downto 0),
    jet_5 => qi(5).data(45 downto 0),
    jet_6 => qi(6).data(45 downto 0),
    jet_7 => qi(7).data(45 downto 0),
    jet_8 => qi(8).data(45 downto 0),
    jet_9 => qi(9).data(45 downto 0));

    GenValid:
    for i in 0 to 9 generate
    begin
        q(i).DataValid <= qi(i).data /= (63 downto 0 => '0');
        q(i).FrameValid <= qi(i).data /= (63 downto 0 => '0');
        q(i).data <= qi(i).data;
    end generate;

end rtl;
