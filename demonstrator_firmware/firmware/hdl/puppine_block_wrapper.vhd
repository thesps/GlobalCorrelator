library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.regionizer_data.all;

entity puppine_block is
    port(
            ap_clk   : IN STD_LOGIC;
            ap_rst   : IN STD_LOGIC;
            ap_start : IN STD_LOGIC;
            ap_done  : OUT STD_LOGIC;
            ap_ready : OUT STD_LOGIC;
            ap_idle  : OUT STD_LOGIC;
            puppine_in    : IN w64s(NTKSORTED+NCALOSORTED downto 0);
            puppine_out   : OUT w64s(NCALOSORTED-1 downto 0)
    );
end puppine_block;

architecture Behavioral of puppine_block is

begin
    
     puppiblock : entity work.packed_linpuppiNoCrop
         port map(ap_clk => ap_clk, 
                  ap_rst => ap_rst, 
                  ap_start => ap_start,
                  ap_ready => ap_ready,
                  ap_idle =>  ap_idle,
                  ap_done =>  ap_done,
                  input_0_V => puppine_in(0),
                  input_1_V => puppine_in(1),
                  input_2_V => puppine_in(2),
                  input_3_V => puppine_in(3),
                  input_4_V => puppine_in(4),
                  input_5_V => puppine_in(5),
                  input_6_V => puppine_in(6),
                  input_7_V => puppine_in(7),
                  input_8_V => puppine_in(8),
                  input_9_V => puppine_in(9),
                  input_10_V => puppine_in(10),
                  input_11_V => puppine_in(11),
                  input_12_V => puppine_in(12),
                  input_13_V => puppine_in(13),
                  input_14_V => puppine_in(14),
                  input_15_V => puppine_in(15),
                  input_16_V => puppine_in(16),
                  input_17_V => puppine_in(17),
                  input_18_V => puppine_in(18),
                  input_19_V => puppine_in(19),
                  input_20_V => puppine_in(20),
                  input_21_V => puppine_in(21),
                  input_22_V => puppine_in(22),
                  input_23_V => puppine_in(23),
                  input_24_V => puppine_in(24),
                  input_25_V => puppine_in(25),
                  input_26_V => puppine_in(26),
                  input_27_V => puppine_in(27),
                  input_28_V => puppine_in(28),
                  input_29_V => puppine_in(29),
                  input_30_V => puppine_in(30),
                  input_31_V => puppine_in(31),
                  input_32_V => puppine_in(32),
                  input_33_V => puppine_in(33),
                  input_34_V => puppine_in(34),
                  input_35_V => puppine_in(35),
                  input_36_V => puppine_in(36),
                  input_37_V => puppine_in(37),
                  input_38_V => puppine_in(38),
                  input_39_V => puppine_in(39),
                  input_40_V => puppine_in(40),
                  input_41_V => puppine_in(41),
                  input_42_V => puppine_in(42),
                  input_43_V => puppine_in(43),
                  input_44_V => puppine_in(44),
                  input_45_V => puppine_in(45),
                  input_46_V => puppine_in(46),
                  input_47_V => puppine_in(47),
                  input_48_V => puppine_in(48),
                  input_49_V => puppine_in(49),
                  input_50_V => puppine_in(50),
                  output_0_V => puppine_out(0),
                  output_1_V => puppine_out(1),
                  output_2_V => puppine_out(2),
                  output_3_V => puppine_out(3),
                  output_4_V => puppine_out(4),
                  output_5_V => puppine_out(5),
                  output_6_V => puppine_out(6),
                  output_7_V => puppine_out(7),
                  output_8_V => puppine_out(8),
                  output_9_V => puppine_out(9),
                  output_10_V => puppine_out(10),
                  output_11_V => puppine_out(11),
                  output_12_V => puppine_out(12),
                  output_13_V => puppine_out(13),
                  output_14_V => puppine_out(14),
                  output_15_V => puppine_out(15),
                  output_16_V => puppine_out(16),
                  output_17_V => puppine_out(17),
                  output_18_V => puppine_out(18),
                  output_19_V => puppine_out(19)
              );
  

end Behavioral;

