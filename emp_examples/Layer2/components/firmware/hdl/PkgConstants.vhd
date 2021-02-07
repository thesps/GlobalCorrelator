library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package PkgConstants is
    constant NPARTICLES : integer := 128;
    constant NJETS : integer := 10;
    constant JETLOOPLATENCY : integer := 16;
    constant JETCOMPUTELATENCY : integer := 16;
    constant EVENTSINFLIGHT : integer := 8;
end PkgConstants;
