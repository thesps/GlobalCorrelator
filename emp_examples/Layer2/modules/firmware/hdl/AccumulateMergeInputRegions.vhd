library ieee;
use ieee.std_logic_1164.all;

use work.DataType.all;
use work.ArrayTypes.all;

library Int;
use Int.DataType;
use Int.ArrayTypes;

entity MergeAccumulateInputRegions is
generic(
  constant nStreamsIn : integer := 1;
  constant nInPerStream : integer := 16;
  constant nOut : integer := 128
);
port(
  clk : in std_logic := '0';
  RegionStreams : in Matrix(0 to nStreamsIn - 1)(0 to nInPerStream - 1);
  EventParticles : out Vector(0 to nOut - 1)
);
end MergeAccumulateInputRegions;

architecture rtl of MergeAccumulateInputRegions is
  signal RegionsAccumulated : Matrix (0 to nStreamsIn - 1)(0 to nOut - 1) := NullMatrix(nStreamsIn, nOut);
  signal BaseI : Int.ArrayTypes.Vector(0 to nStreamsIn - 1) := Int.ArrayTypes.NullVector(nStreamsIn);
  --signal BaseQ : Int.ArrayTypes.Vector(0 to nStreamsIn - 1) := Int.ArrayTypes.NullVector(nStreamsIn);
  signal BaseQ : Int.DataType.tData := Int.DataType.cNull;

  attribute keep_hierarchy : string;
  attribute keep_hierarchy of Merge : label is "yes";
  attribute keep_hierarchy of GAccumulate : label is "yes";

begin

  GAccumulate :
  for i in 0 to nStreamsIn - 1 generate
    Accumulate : entity work.AccumulateInputs
    generic map(nInPerStream, nOut)
    port map(clk, RegionStreams(i), RegionsAccumulated(i), BaseI(i));
  end generate;

  Merge : entity work.MergeArrays
  generic map(nStreamsIn, nOut, nOut)
  port map(clk, RegionsAccumulated, BaseI, EventParticles, BaseQ);

end rtl;

