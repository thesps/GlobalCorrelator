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
  signal RegionsMerged : Vector(0 to nStreamsIn * nInPerStream - 1) := NullVector(nStreamsIn * nInPerStream);
  signal NullI : Int.ArrayTypes.Vector(0 to nStreamsIn - 1) := Int.ArrayTypes.NullVector(nStreamsIn);
  signal BaseI : Int.ArrayTypes.Vector(0 to nStreamsIn - 1) := Int.ArrayTypes.NullVector(nStreamsIn);
  --signal BaseQ : Int.ArrayTypes.Vector(0 to nStreamsIn - 1) := Int.ArrayTypes.NullVector(nStreamsIn);
  signal BaseQ : Int.DataType.tData := Int.DataType.cNull;

  attribute keep_hierarchy : string;
  attribute keep_hierarchy of Merge : label is "yes";
  attribute keep_hierarchy of Accumulate : label is "yes";

begin

  GenBases:
  for i in 0 to nStreamsIn - 1 generate
    Base:
    process(clk)
      begin
      for j in 0 to nInPerStream - 1 loop
        if RegionStreams(i)(j).DataValid then
          BaseI(i).x <= j;
        end if;
      end loop;
    end process;
  end generate;

  Merge : entity work.MergeArrays
  generic map(nStreamsIn, nInPerStream, nStreamsIn * nInPerStream)
  port map(clk, RegionStreams, BaseI, RegionsMerged);

  Accumulate : entity work.AccumulateInputs
  generic map(nStreamsIn * nInPerStream, nOut)
  port map(clk, RegionsMerged, EventParticles, BaseQ);


end rtl;

