library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package PkgConstants is
    constant NPARTICLES : integer := 128;
    constant NJETS : integer := 10;
    constant JETLOOPLATENCY : integer := 16;
    constant JETCOMPUTELATENCY : integer := 19;
    constant EVENTSINFLIGHT : integer := 8;
    constant NFRAMESPEREVENT : integer := 54; -- Layer 1 at TMUX=6, Layer2 at 360 MHz
end PkgConstants;
