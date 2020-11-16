library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.regionizer_data.all;

entity puppich_block is
    port(
            ap_clk   : IN STD_LOGIC;
            ap_rst   : IN STD_LOGIC;
            ap_start : IN STD_LOGIC;
            ap_done  : OUT STD_LOGIC;
            ap_ready : OUT STD_LOGIC;
            ap_idle  : OUT STD_LOGIC;
            puppich_in    : IN w64s(NTKSORTED downto 0);
            puppich_out   : OUT w64s(NTKSORTED-1 downto 0)
    );
end puppich_block;

architecture Behavioral of puppich_block is

begin
    
     puppichsblock : entity work.packed_linpuppi_chs
         port map(ap_clk => ap_clk, 
                  ap_rst => ap_rst, 
                  ap_start => ap_start,
                  ap_ready => ap_ready,
                  ap_idle =>  ap_idle,
                  ap_done =>  ap_done,
                  input_0_V => puppich_in(0),
                  input_1_V => puppich_in(1),
                  input_2_V => puppich_in(2),
                  input_3_V => puppich_in(3),
                  input_4_V => puppich_in(4),
                  input_5_V => puppich_in(5),
                  input_6_V => puppich_in(6),
                  input_7_V => puppich_in(7),
                  input_8_V => puppich_in(8),
                  input_9_V => puppich_in(9),
                  input_10_V => puppich_in(10),
                  input_11_V => puppich_in(11),
                  input_12_V => puppich_in(12),
                  input_13_V => puppich_in(13),
                  input_14_V => puppich_in(14),
                  input_15_V => puppich_in(15),
                  input_16_V => puppich_in(16),
                  input_17_V => puppich_in(17),
                  input_18_V => puppich_in(18),
                  input_19_V => puppich_in(19),
                  input_20_V => puppich_in(20),
                  --input_21_V => puppich_in(21),
                  --input_22_V => puppich_in(22),
                  --input_23_V => puppich_in(23),
                  --input_24_V => puppich_in(24),
                  --input_25_V => puppich_in(25),
                  --input_26_V => puppich_in(26),
                  --input_27_V => puppich_in(27),
                  --input_28_V => puppich_in(28),
                  --input_29_V => puppich_in(29),
                  --input_30_V => puppich_in(30),
                  output_0_V => puppich_out(0),
                  output_1_V => puppich_out(1),
                  output_2_V => puppich_out(2),
                  output_3_V => puppich_out(3),
                  output_4_V => puppich_out(4),
                  output_5_V => puppich_out(5),
                  output_6_V => puppich_out(6),
                  output_7_V => puppich_out(7),
                  output_8_V => puppich_out(8),
                  output_9_V => puppich_out(9),
                  output_10_V => puppich_out(10),
                  output_11_V => puppich_out(11),
                  output_12_V => puppich_out(12),
                  output_13_V => puppich_out(13),
                  output_14_V => puppich_out(14),
                  output_15_V => puppich_out(15),
                  output_16_V => puppich_out(16),
                  output_17_V => puppich_out(17),
                  output_18_V => puppich_out(18),
                  output_19_V => puppich_out(19) --,
                  --output_20_V => puppich_out(20),
                  --output_21_V => puppich_out(21),
                  --output_22_V => puppich_out(22),
                  --output_23_V => puppich_out(23),
                  --output_24_V => puppich_out(24),
                  --output_25_V => puppich_out(25),
                  --output_26_V => puppich_out(26),
                  --output_27_V => puppich_out(27),
                  --output_28_V => puppich_out(28),
                  --output_29_V => puppich_out(29)
             );

end Behavioral;

