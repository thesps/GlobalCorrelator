library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library Utilities;
use Utilities.Utilities.all;

library Layer2;
use Layer2.Constants.all;

library PFChargedObj;
use PFChargedObj.DataType;
use PFChargedObj.ArrayTypes;

entity AllFlatRegionsToStreams is
port(
  clk : in std_logic;
  PFChargedObjFlat : in PFChargedObj.ArrayTypes.Vector(0 to N_Layer1Boards * N_PFChargedObj_PerRegion - 1) := PFChargedObj.ArrayTypes.NullVector(N_Layer1Boards * N_PFChargedObj_PerRegion);
  PFChargedObjStream : out PFChargedObj.ArrayTypes.VectorPipe --(0 to 9)(0 to N_Layer1Boards * N_PF_Regions_PerLayer1Board - 1) := PFChargedObj.ArrayTypes.NullVectorPipe(10, N_Layer1Boards * N_PF_Regions_PerLayer1Board)
);
end AllFlatRegionsToStreams;

architecture behavioral of AllFlatRegionsToStreams is
  -- This stream sees every input offset by 1 cycle
  signal PFChargedObjStreamInt : PFChargedObj.ArrayTypes.Vector(0 to N_Layer1Boards * N_PF_REGIONS_PerLayer1Board - 1) := PFChargedObj.ArrayTypes.NullVector(N_PF_REGIONS_PerLayer1Board * N_Layer1Boards);
begin

-- Each FlatRegionsToStreams takes 1 board of inputs, so make N_Layer1Boards instances...
-- ... and connect the relevant links
BoardLoop:
for i in 0 to N_Layer1Boards - 1 generate
  signal ObjsFromBoardFlat : PFChargedObj.ArrayTypes.Vector(0 to N_PFChargedObj_PerRegion - 1) := PFChargedObj.ArrayTypes.NullVector(N_PFChargedObj_PerRegion);
  signal ObjsFromBoardStream : PFChargedObj.ArrayTypes.VectorPipe(0 to 0)(0 to N_PF_Regions_PerLayer1Board - 1) := PFChargedObj.ArrayTypes.NullVectorPipe(1, N_PF_Regions_PerLayer1Board);
begin

  -- Prepare the flat inputs and streamed outputs for board i
  ObjsFromBoardFlat <= PFChargedObjFlat(i * N_PFChargedObj_PerRegion to (i+1) * N_PFChargedObj_PerRegion - 1);
  PFChargedObjStreamInt(i * N_PF_Regions_PerLayer1Board to (i+1) * N_PF_Regions_PerLayer1Board - 1) <= ObjsFromBoardStream(0);

  -- Instantiate the flat-to-stream converter
  FlatToStream : entity work.FlatRegionsToStreams
  port map(clk, ObjsFromBoardFlat, ObjsFromBoardStream);
end generate;

OutPipe : entity PFChargedObj.DataPipe
port map(clk, PFChargedObjStreamInt, PFChargedObjStream);

DebugInstance : entity PFChargedObj.Debug
generic map( FileName => "AllFlatRegionsToStreams" )
port map(clk, PFChargedObjStreamInt);

end behavioral;
