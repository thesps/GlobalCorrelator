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

entity FlatRegionsToStreams is
port(
  clk : in std_logic;
  PFChargedObjFlat : in PFChargedObj.ArrayTypes.Vector;
  --PFNeutralObjFlat : in PFNeutralObj.Vector;
  --PFChargedObjStream : out PFChargedObj.ArrayTypes.Vector
  PFChargedObjStream : out PFChargedObj.ArrayTypes.VectorPipe
  --PFNeutralObjStream : out PFNeutralObj.Vector;
);
end FlatRegionsToStreams;

architecture behavioral of FlatRegionsToStreams is
  -- This stream sees every input offset by 1 cycle
  signal FlatInVector : PFChargedObj.ArrayTypes.Vector(0 to N_PFChargedObj_PerRegion - 1) := PFChargedObj.ArrayTypes.NullVector(N_PFChargedObj_PerRegion);
  signal FlatInVectorPipe : PFChargedObj.ArrayTypes.VectorPipe(0 to 1)(0 to N_PFChargedObj_PerRegion - 1) := PFChargedObj.ArrayTypes.NullVectorPipe(2, N_PFChargedObj_PerRegion);
  signal PFChargedObjStreamInt : PFChargedObj.ArrayTypes.Vector(0 to N_PF_Regions - 1) := PFChargedObj.ArrayTypes.NullVector(N_PF_Regions);
begin

GenPipe : for i in 0 to N_PFChargedObj_PerRegion - 1 generate
  signal Vec : PFChargedObj.ArrayTypes.Vector(0 to 0) := PFChargedObj.ArrayTypes.NullVector(1);
  signal StreamInPipe : PFChargedObj.ArrayTypes.VectorPipe(0 to i)(0 to 0) := PFChargedObj.ArrayTypes.NullVectorPipe(i + 1, 1);
begin
  -- Pipeline the incoming data
  -- The pipeline depth grows as we go along the list of inputs
  Vec(0) <= PFChargedObjFlat(i);
  Pipe : entity PFChargedObj.DataPipe
  port map(clk, Vec, StreamInPipe);

  -- Connect the input pipe to the _end_ of the delayed pipe
  FlatInVector(i) <= StreamInPipe(i)(0);
end generate;

-- Delay that flattened delayed pipe by one so we can detect the new event
FlatPipe : entity PFChargedObj.DataPipe
port map(clk, FlatInVector, FlatInVectorPipe);

GenMux : for i in 0 to N_PF_Regions - 1 generate
  signal counter : integer range 0 to N_PFChargedObj_PerRegion - 1 := 0;
begin
  MuxPrc : process(clk)
  begin
    -- Increment the counter
    if rising_edge(clk) then
      -- Reset the counter if the data is newly valid
      if not FlatInVectorPipe(1)(0).DataValid and FlatInVectorPipe(0)(0).FrameValid then
        if i = 0 then
          counter <= 0;
        else
          counter <= N_PFChargedObj_PerRegion - 1;
        end if;
      elsif counter = N_PFChargedObj_PerRegion - 1 then
        counter <= 0;
      else
        counter <= counter + 1;
      end if;
      -- Multiplex the input to the output
      PFChargedObjStreamInt(i) <= FlatInVectorPipe(1)(counter);
    end if;
  end process;
end generate;

OutPipe : entity PFChargedObj.DataPipe
port map(clk, PFChargedObjStreamInt, PFChargedObjStream);
--PFChargedObjStream <= PFChargedObjStreamInt;

DebugInstance : entity PFChargedObj.Debug
generic map( FileName => "FlatRegionsToStreams" )
port map(clk, PFChargedObjStreamInt);

end behavioral;
