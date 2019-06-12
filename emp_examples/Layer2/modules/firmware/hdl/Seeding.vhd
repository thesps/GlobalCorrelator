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

entity Seeding is
port(
  clk : in std_logic;
  PFChargedObjStream : in PFChargedObj.ArrayTypes.VectorPipe;
  Seeds : out PFChargedObj.ArrayTypes.VectorPipe;
  PFChargedObjOut : out PFChargedObj.ArrayTypes.VectorPipe
);
end Seeding;

architecture behavioral of Seeding is
  constant PFCandsDelay : integer := 1;
  signal SeedsInt : PFChargedObj.ArrayTypes.Vector(0 to N_PF_Regions - 1) := PFChargedObj.ArrayTypes.NullVector(N_PF_Regions);
  signal PFCandsInt : PFChargedObj.ArrayTypes.Vector(0 to N_PF_Regions - 1) := PFChargedObj.ArrayTypes.NullVector(N_PF_Regions);
begin

-- Simplest, most naive seeding: take the highest pT object from each region
-- The objects arrive pT ordered so just take the first to arrvie
SeedGen:
--for i in 0 to N_PF_Regions - 1 generate
for i in 0 to N_PF_Regions_PerLayer1Board - 1 generate
begin
  process(clk)
  begin
  if rising_edge(clk) then
    if not PFChargedObjStream(1)(i).FrameValid and PFChargedObjStream(0)(i).FrameValid then
      SeedsInt(i) <= PFChargedObjStream(0)(i);
      -- Remove the seed from the candidate stream
      PFCandsInt(i) <= PFChargedObj.DataType.cNull;
      PFCandsInt(i).FrameValid <= PFChargedObjStream(0)(i).FrameValid;
    else
      SeedsInt(i) <= PFChargedObj.DataType.cNull;
      SeedsInt(i).FrameValid <= PFChargedObjStream(0)(i).FrameValid;
      PFCandsInt(i) <= PFChargedObjStream(0)(i);
    end if;
  end if;
  end process;
  --PFCandsInt(i) <= PFChargedObjStream(PFCandsDelay)(i);
end generate;


OutPipe : entity PFChargedObj.DataPipe
port map(clk, SeedsInt, Seeds);

OutPipe1 : entity PFChargedObj.DataPipe
port map(clk, PFCandsInt, PFChargedObjOut);

DebugInstance : entity PFChargedObj.Debug
generic map( FileName => "Seeding" )
port map(clk, SeedsInt);

end behavioral;
