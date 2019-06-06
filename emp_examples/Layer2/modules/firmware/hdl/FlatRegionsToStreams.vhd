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
  signal objcounter : integer range 0 to N_PFChargedObj_PerRegion - 1 := 0;
  signal framecounter : integer range 0 to N_PF_Regions - 1 := 0;
begin
  MuxPrc : process(clk)
  begin
    -- Increment the framecounter
    if rising_edge(clk) then
      if FlatInVectorPipe(0)(0).FrameValid then
        if (not FlatInVectorPipe(1)(0).FrameValid) or (framecounter = N_PF_Regions - 1) then
          framecounter <= 0;
        else
          framecounter <= framecounter + 1;
        end if;
      else
        framecounter <= 0;
      end if;

      -- Increment the object counter
      if i = 0 then
        -- For i = 0, count when the incoming data is valid
        if FlatInVectorPipe(0)(0).FrameValid then
          -- Reset when the incoming data is newly valid
          if not FlatInVectorPipe(1)(0).FrameValid then
            objcounter <= 0;
          else
            -- Reset when the end is reached
            if objcounter = N_PFChargedObj_PerRegion - 1 then
              objcounter <= 0;
            else
              objcounter <= objcounter + 1;
            end if;
          end if;
        else
          objcounter <= 0;
        end if;
      else
        -- for i > 0, start counting when the framecounter has ticked up to 'i'
        -- i.e. this region is ready to start
        if framecounter = i then
          objcounter <= 1;
        elsif objcounter > 0 then
          if objcounter = N_PFChargedObj_PerRegion - 1 then
            objcounter <= 0;
          else 
            objcounter <= objcounter + 1;
          end if;
        else
          objcounter <= 0;
        end if;
      end if; 

      -- Multiplex the input to the output
      if i = 0 then
        if FlatInVectorPipe(0)(0).FrameValid then
          PFChargedObjStreamInt(i) <= FlatInVectorPipe(1)(objcounter);
        else
          PFChargedObjStreamInt(i) <= PFChargedObj.DataType.cNull;
        end if;
      else
        if (framecounter = i) or objcounter > 0 then
          PFChargedObjStreamInt(i) <= FlatInVectorPipe(1)(objcounter);
        else
          PFChargedObjStreamInt(i) <= PFChargedObj.DataType.cNull;
        end if;
      end if;
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
