library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.DataType.all;
use work.ArrayTypes.all;

entity RegionBuffers is
port(
    clk : in std_logic := '0';
    newEvent : in boolean;
    D : in Vector(0 to 23) := NullVector(24);
    Q : out Vector(0 to 23) := NullVector(24)
);
end RegionBuffers;

architecture rtl of RegionBuffers is
begin

    GenBuffers:
    for i in D'range generate
    begin
        BufferInstance : entity work.RegionBuffer
        port map(clk, newEvent, D(i), Q(i));
    end generate;

    Debug : entity work.Debug generic map("BufferQ") port map(clk, Q);

end rtl;
