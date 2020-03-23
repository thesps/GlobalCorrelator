library ieee;
use ieee.std_logic_1164.all;

use work.DataType.all;
use work.ArrayTypes.all;

library Int;
use Int.DataType;
use Int.ArrayTypes;

entity MergeAccumulateInputRegions is
port(
    clk : in std_logic := '0';
    RegionStreams : in Matrix(0 to 5)(0 to 15) := NullMatrix(6, 16);
    EventParticles : out Vector(0 to 127) := NullVector(128)
);
end MergeAccumulateInputRegions;

architecture rtl of MergeAccumulateInputRegions is

    signal RegionsMerged      : Vector(0 to 63) := NullVector(64);
    signal RegionsMergedPiped : VectorPipe(0 to 4)(0 to 63) := NullVectorPipe(5, 64);

    attribute keep_hierarchy : string;
    attribute keep_hierarchy of Merge : label is "yes";
    attribute keep_hierarchy of Accumulate : label is "yes";

begin

    Merge : entity work.MergeArrays
    port map(clk, RegionStreams, RegionsMerged);

    Pipe : entity work.DataPipe
    port map(clk, RegionsMerged, RegionsMergedPiped);

    Accumulate : entity work.AccumulateInputs
    port map(clk, RegionsMergedPiped(4), EventParticles);

end rtl;

