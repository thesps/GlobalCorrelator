library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package PkgConstants is
    constant NPARTICLES : integer := 128;
    constant NJETS : integer := 10;
    constant JETLOOPLATENCY : integer := 15;
    constant JETCOMPUTELATENCY : integer := 12;
    constant EVENTSINFLIGHT : integer := 3;
end PkgConstants;
