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
  signal PFChargedObjStreamInt : PFChargedObj.ArrayTypes.Vector(0 to N_PF_REGIONS_PerLayer1Board - 1) := PFChargedObj.ArrayTypes.NullVector(N_PF_REGIONS_PerLayer1Board);
begin

FlatPipe : entity PFChargedObj.DataPipe
port map(clk, PFChargedObjFlat, FlatInVectorPipe);

pisos :
for i in 0 to N_PF_REGIONS_PerLayer1Board - 1 generate
  signal framecounter : integer range 0 to N_PF_REGIONS_PerLayer1Board - 1 := 0;
  signal objcounter : integer range 0 to N_PFChargedObj_PerRegion - 1 := 0;
  signal we : boolean := false;
  signal re : boolean := false;
begin

  counter : process(clk)
  begin
    if rising_edge(clk) then

      -- Increment the frame counter while new data is arriving
      if FlatInVectorPipe(0)(0).FrameValid then
        if (not FlatInVectorPipe(1)(0).FrameValid) or (framecounter = N_PF_REGIONS_PerLayer1Board - 1) then
          framecounter <= 1;
        else
          framecounter <= framecounter + 1;
        end if;
      else
        framecounter <= 0;
      end if;

      -- Increment the object counter once all the data has arrived
      -- Keep going until the counter reaches the number of objects
      if objcounter = N_PFChargedObj_PerRegion - 1 then
        objcounter <= 0;
      elsif framecounter = N_PF_REGIONS_PerLayer1Board - 1 or objcounter > 0 then
        objcounter <= objcounter + 1;
      else
        objcounter <= 0;
      end if;

      if i = 0 then
        we <= (not FlatInVectorPipe(1)(0).FrameValid) and FlatInVectorPipe(0)(0).FrameValid;
      else
        --we <= framecounter = i;
        we <= framecounter = i and not re;
      end if;
      re <= (framecounter = N_PF_REGIONS_PerLayer1Board - 1) or (objcounter > 0); 
    end if;
  end process;

  piso : entity PFChargedObj.ParallelToSerial
  port map(clk, we, re, FlatInVectorPipe(1), PFChargedObjStreamInt(i));
end generate;

OutPipe : entity PFChargedObj.DataPipe
port map(clk, PFChargedObjStreamInt, PFChargedObjStream);
--PFChargedObjStream <= PFChargedObjStreamInt;

--DebugInstance : entity PFChargedObj.Debug
--generic map( FileName => "FlatRegionsToStreams" )
--port map(clk, PFChargedObjStreamInt);

DebugInstance : entity PFChargedObj.Debug
generic map( FileName => "FlatRegionsToStreams" )
port map(clk, PFChargedObjStreamInt);

end behavioral;
