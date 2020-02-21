library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library Utilities;
use Utilities.Utilities.all;

library Layer2;
use Layer2.Constants.all;
use Layer2.Regions.all;

library PFChargedObj;
use PFChargedObj.DataType;
use PFChargedObj.ArrayTypes;

-- Take N_Regions input streams (one stream per region)
-- Take input 'iRegion'
-- Output only 9 region streams which neighbour iRegion
entity ReduceRegionsToNeighbours is
port(
  clk : in std_logic;
  iRegion : in integer range 0 to N_Regions - 1;
  PFChargedObjIn : in PFChargedObj.ArrayTypes.VectorPipe;
  PFChargedObjOut : out PFChargedObj.ArrayTypes.VectorPipe
);
end ReduceRegionsToNeighbours;

architecture behavioral of ReduceRegionsToNeighbours is
  -- One output stream per region
  signal PFChargedObjOutInt : PFChargedObj.ArrayTypes.Vector(0 to 8) := PFChargedObj.ArrayTypes.NullVector(N_PF_Regions);
begin

-- A big dumb mux
NeighboursLoop:
for i in 0 to 9 - 1 generate
begin
  process(clk)
  begin
    if rising_edge(clk) then
      PFChargedObjOutInt(i) <= PFChargedObjIn(Neighbours(iRegion, i));
    end if;
  end if;
end generate;

OutPipe : entity PFChargedObj.DataPipe
port map(clk, PFChargedObjOutInt, PFChargedObjOut);

DebugInstance : entity PFChargedObj.Debug
generic map( FileName => "ReduceRegionsToNeighbours" )
port map(clk, PFChargedObjOutInt);

end behavioral;
