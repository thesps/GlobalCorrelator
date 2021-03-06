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

  ----------------------------------------------
  -- Architecture and object number definitions
  ----------------------------------------------
  constant N_PF_REGIONS : integer := 72;
  -- With TMUX=6 there will be 18 regions per board, but keep 36 pending implementation of II=2 input decode
  constant N_PF_REGIONS_PerLayer1Board : integer := 18;
  constant N_PFChargedObj_PerRegion : integer := 25;
  constant N_Layer1Boards : integer := 4;
  constant N_LinksPerLayer1Board : integer := 8;
  constant LinkFanOutFactor : integer := 3; -- If Layer 1 is running @ 240 MHz, II=2, then this is 2 using 16 Gb/s links, or 3 using 25 Gb/s links

  constant TAU_nHighestPt : integer := 10;
end package;
