library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.regionizer_data.all;

entity pf_block is
    port(
            ap_clk   : IN STD_LOGIC;
            ap_rst   : IN STD_LOGIC;
            ap_start : IN STD_LOGIC;
            ap_done  : OUT STD_LOGIC;
            ap_ready : OUT STD_LOGIC;
            ap_idle  : OUT STD_LOGIC;
            pf_in    : IN w64s(NTKSORTED+NCALOSORTED+NMUSORTED-1 downto 0);
            pf_out   : OUT w64s(NPFTOT-1 downto 0)
    );
end pf_block;

architecture Behavioral of pf_block is

begin

        pfblock : entity work.packed_pfalgo2hgc
            port map(ap_clk => ap_clk, 
                     ap_rst => ap_rst, 
                     ap_start => ap_start,
                     ap_ready => ap_ready,
                     ap_idle =>  ap_idle,
                     ap_done =>  ap_done,
                     input_0_V => pf_in(0),
                     input_1_V => pf_in(1),
                     input_2_V => pf_in(2),
                     input_3_V => pf_in(3),
                     input_4_V => pf_in(4),
                     input_5_V => pf_in(5),
                     input_6_V => pf_in(6),
                     input_7_V => pf_in(7),
                     input_8_V => pf_in(8),
                     input_9_V => pf_in(9),
                     input_10_V => pf_in(10),
                     input_11_V => pf_in(11),
                     input_12_V => pf_in(12),
                     input_13_V => pf_in(13),
                     input_14_V => pf_in(14),
                     input_15_V => pf_in(15),
                     input_16_V => pf_in(16),
                     input_17_V => pf_in(17),
                     input_18_V => pf_in(18),
                     input_19_V => pf_in(19),
                     input_20_V => pf_in(20),
                     input_21_V => pf_in(21),
                     input_22_V => pf_in(22),
                     input_23_V => pf_in(23),
                     input_24_V => pf_in(24),
                     input_25_V => pf_in(25),
                     input_26_V => pf_in(26),
                     input_27_V => pf_in(27),
                     input_28_V => pf_in(28),
                     input_29_V => pf_in(29),
                     input_30_V => pf_in(30),
                     input_31_V => pf_in(31),
                     input_32_V => pf_in(32),
                     input_33_V => pf_in(33),
                     input_34_V => pf_in(34),
                     input_35_V => pf_in(35),
                     input_36_V => pf_in(36),
                     input_37_V => pf_in(37),
                     input_38_V => pf_in(38),
                     input_39_V => pf_in(39),
                     input_40_V => pf_in(40),
                     input_41_V => pf_in(41),
                     input_42_V => pf_in(42),
                     input_43_V => pf_in(43),
                     input_44_V => pf_in(44),
                     input_45_V => pf_in(45),
                     input_46_V => pf_in(46),
                     input_47_V => pf_in(47),
                     input_48_V => pf_in(48),
                     input_49_V => pf_in(49),
                     input_50_V => pf_in(50),
                     input_51_V => pf_in(51),
                     input_52_V => pf_in(52),
                     input_53_V => pf_in(53),
                     output_0_V => pf_out(0),
                     output_1_V => pf_out(1),
                     output_2_V => pf_out(2),
                     output_3_V => pf_out(3),
                     output_4_V => pf_out(4),
                     output_5_V => pf_out(5),
                     output_6_V => pf_out(6),
                     output_7_V => pf_out(7),
                     output_8_V => pf_out(8),
                     output_9_V => pf_out(9),
                     output_10_V => pf_out(10),
                     output_11_V => pf_out(11),
                     output_12_V => pf_out(12),
                     output_13_V => pf_out(13),
                     output_14_V => pf_out(14),
                     output_15_V => pf_out(15),
                     output_16_V => pf_out(16),
                     output_17_V => pf_out(17),
                     output_18_V => pf_out(18),
                     output_19_V => pf_out(19),
                     output_20_V => pf_out(20),
                     output_21_V => pf_out(21),
                     output_22_V => pf_out(22),
                     output_23_V => pf_out(23),
                     output_24_V => pf_out(24),
                     output_25_V => pf_out(25),
                     output_26_V => pf_out(26),
                     output_27_V => pf_out(27),
                     output_28_V => pf_out(28),
                     output_29_V => pf_out(29),
                     output_30_V => pf_out(30),
                     output_31_V => pf_out(31),
                     output_32_V => pf_out(32),
                     output_33_V => pf_out(33),
                     output_34_V => pf_out(34),
                     output_35_V => pf_out(35),
                     output_36_V => pf_out(36),
                     output_37_V => pf_out(37),
                     output_38_V => pf_out(38),
                     output_39_V => pf_out(39),
                     output_40_V => pf_out(40),
                     output_41_V => pf_out(41),
                     output_42_V => pf_out(42),
                     output_43_V => pf_out(43),
                     output_44_V => pf_out(44),
                     output_45_V => pf_out(45),
                     output_46_V => pf_out(46),
                     output_47_V => pf_out(47),
                     output_48_V => pf_out(48),
                     output_49_V => pf_out(49),
                     output_50_V => pf_out(50),
                     output_51_V => pf_out(51),
                     output_52_V => pf_out(52),
                     output_53_V => pf_out(53)
                );

end Behavioral;

