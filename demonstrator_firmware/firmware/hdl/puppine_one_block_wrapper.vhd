library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.regionizer_data.all;

entity puppine_one_block is
    port(
            ap_clk   : IN STD_LOGIC;
            ap_start : IN STD_LOGIC;
            ap_done  : OUT STD_LOGIC;
            ap_ready : OUT STD_LOGIC;
            ap_idle  : OUT STD_LOGIC;
            pf_in      : IN word64;
            prep_tk_in : IN w64s(NTKSORTED-1 downto 0);
            puppi_out  : OUT word64
    );
end puppine_one_block;

architecture Behavioral of puppine_one_block is

begin
    
     puppiblock : entity work.packed_linpuppi_one
         port map(ap_clk => ap_clk, 
                  ap_start => ap_start,
                  ap_ready => ap_ready,
                  ap_idle =>  ap_idle,
                  ap_done =>  ap_done,
                  in_V  => pf_in,
                  sel_tracks_0_V  => prep_tk_in(0)(36 downto 0),
                  sel_tracks_1_V  => prep_tk_in(1)(36 downto 0),
                  sel_tracks_2_V  => prep_tk_in(2)(36 downto 0),
                  sel_tracks_3_V  => prep_tk_in(3)(36 downto 0),
                  sel_tracks_4_V  => prep_tk_in(4)(36 downto 0),
                  sel_tracks_5_V  => prep_tk_in(5)(36 downto 0),
                  sel_tracks_6_V  => prep_tk_in(6)(36 downto 0),
                  sel_tracks_7_V  => prep_tk_in(7)(36 downto 0),
                  sel_tracks_8_V  => prep_tk_in(8)(36 downto 0),
                  sel_tracks_9_V  => prep_tk_in(9)(36 downto 0),
                  sel_tracks_10_V  => prep_tk_in(10)(36 downto 0),
                  sel_tracks_11_V  => prep_tk_in(11)(36 downto 0),
                  sel_tracks_12_V  => prep_tk_in(12)(36 downto 0),
                  sel_tracks_13_V  => prep_tk_in(13)(36 downto 0),
                  sel_tracks_14_V  => prep_tk_in(14)(36 downto 0),
                  sel_tracks_15_V  => prep_tk_in(15)(36 downto 0),
                  sel_tracks_16_V  => prep_tk_in(16)(36 downto 0),
                  sel_tracks_17_V  => prep_tk_in(17)(36 downto 0),
                  sel_tracks_18_V  => prep_tk_in(18)(36 downto 0),
                  sel_tracks_19_V  => prep_tk_in(19)(36 downto 0),
                  ap_return => puppi_out
              );
  

end Behavioral;

