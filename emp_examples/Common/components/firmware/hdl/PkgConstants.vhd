library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package constants is
  subtype pt_t is signed(15 downto 0);
  subtype etaphi_t is signed(9 downto 0);
  subtype particleID_t is unsigned(2 downto 0);
  subtype z0_t is signed(9 downto 0);

  -- eta phi squared
  subtype etaphi2_t is signed(19 downto 0);
  subtype DeltaR2_t is signed(20 downto 0);

  constant N_PF_REGIONS : integer := 72;
  -- With TMUX=6 there will be 18 regions per board, but keep 36 pending implementation of II=2 input decode
  constant N_PF_REGIONS_PerLayer1Board : integer := 36;
  constant N_PFChargedObj_PerRegion : integer := 25;
end package;
