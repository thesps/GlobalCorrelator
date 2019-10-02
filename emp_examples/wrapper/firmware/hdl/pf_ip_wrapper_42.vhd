library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use work.pf_data_types.all;
use work.pf_constants.all;

entity pf_ip_wrapper is
      port (
        clk: in std_logic;
        rst: in std_logic;
        start: in std_logic;
        input: in pf_data(N_PF_IP_CORE_IN_CHANS - 1 downto 0);
        done: out std_logic;
        idle: out std_logic;
        ready: out std_logic;
        output : out pf_data(N_PF_IP_CORE_OUT_CHANS - 1 downto 0)
        );
      
end pf_ip_wrapper;

architecture rtl of pf_ip_wrapper is
  
begin

  pf_algo : entity work.mp7wrapped_pfalgo3_full_0
    port map (
      ap_clk => clk,
      ap_rst => rst,
      ap_start => start, -- ??
      ap_done => done, -- ??
      ap_idle => idle, -- ??
      ap_ready => ready, -- ??
      input_0_V => input(0),
      input_1_V => input(1),
      input_2_V => input(2),
      input_3_V => input(3),
      input_4_V => input(4),
      input_5_V => input(5),
      input_6_V => input(6),
      input_7_V => input(7),
      input_8_V => input(8),
      input_9_V => input(9),
      input_10_V => input(10),
      input_11_V => input(11),
      input_12_V => input(12),
      input_13_V => input(13),
      input_14_V => input(14),
      input_15_V => input(15),
      input_16_V => input(16),
      input_17_V => input(17),
      input_18_V => input(18),
      input_19_V => input(19),
      input_20_V => input(20),
      input_21_V => input(21),
      input_22_V => input(22),
      input_23_V => input(23),
      input_24_V => input(24),
      input_25_V => input(25),
      input_26_V => input(26),
      input_27_V => input(27),
      input_28_V => input(28),
      input_29_V => input(29),
      input_30_V => input(30),
      input_31_V => input(31),
      input_32_V => input(32),
      input_33_V => input(33),
      input_34_V => input(34),
      input_35_V => input(35),
      --input_36_V => input(36),
      --input_37_V => input(37),
      --input_38_V => input(38),
      --input_39_V => input(39),
      --input_40_V => input(40),
      input_41_V => input(41),
      output_0_V => output(0),
      output_1_V => output(1),
      output_2_V => output(2),
      output_3_V => output(3),
      output_4_V => output(4),
      output_5_V => output(5),
      output_6_V => output(6),
      output_7_V => output(7),
      output_8_V => output(8),
      output_9_V => output(9),
      output_10_V => output(10),
      output_11_V => output(11),
      output_12_V => output(12),
      output_13_V => output(13),
      output_14_V => output(14),
      output_15_V => output(15),
      output_16_V => output(16),
      output_17_V => output(17),
      output_18_V => output(18),
      output_19_V => output(19),
      output_20_V => output(20),
      output_21_V => output(21),
      output_22_V => output(22),
      output_23_V => output(23),
      output_24_V => output(24),
      output_25_V => output(25),
      output_26_V => output(26),
      output_27_V => output(27),
      output_28_V => output(28),
      output_29_V => output(29),
      output_30_V => output(30),
      output_31_V => output(31),
      output_32_V => output(32),
      output_33_V => output(33),
      output_34_V => output(34),
      output_35_V => output(35),
      output_36_V => output(36),
      output_37_V => output(37),
      output_38_V => output(38),
      output_39_V => output(39),
      output_40_V => output(40),
      output_41_V => output(41)
      );

end rtl;
              
