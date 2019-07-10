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

entity SumCandidatesAroundSeed is
port(
  clk : in std_logic;
  SeedsIn : in PFChargedObj.ArrayTypes.VectorPipe;
  PFChargedObjIn : in PFChargedObj.ArrayTypes.VectorPipe;
  PFChargedObjOut : out PFChargedObj.ArrayTypes.VectorPipe
);
end SumCandidatesAroundSeed;

architecture behavioral of SumCandidatesAroundSeed is
  signal PFChargedObjOutInt : PFChargedObj.ArrayTypes.Vector(0 to N_PF_Regions - 1) := PFChargedObj.ArrayTypes.NullVector(N_PF_Regions);
  constant SeedPipeLength : integer : 6;
begin

RegionLoop:
for i in 0 to N_PF_REGIONS - 1 generate

    signal candidatesCopy : PFChargedObj.ArrayTypes.Vector(0 to 8) := PFChargedObj.ArrayTypes.NullVector(9);
    --signal candidatesCopyDelayed : PFChargedObj.ArrayTypes.Vector(0 to 8) := PFChargedObj.ArrayTypes.NullVector(9);
    signal PtSortedCandidatesNeighbours : PFChargedObj.ArrayTypes.Matrix(0 to 8)(0 to TAU_nHighestPt - 1) := PFChargedObj.ArrayTypes.NullMatrix(9, TAU_nHighestPt);
    signal rstSort : std_logic := '0';

    signal seed : PFChargedObj.DataType.tData := PFChargedObj.DataType.cNull;
    signal seedVector : PFChargedObj.ArrayTypes.Vector(0 to 0) := PFChargedObj.ArrayTypes.NullVector(1);
    signal seedVectorPipe : PFChargedObj.ArrayTypes.VectorPipe(0 to SeedPipeLength - 1)(0 to 0) := PFChargedObj.ArrayTypes.NullVectorPipe(SeedPipeLength, 1);
begin

  seedProcess:
  process(clk)
  begin
    if rising_edge(clk) then
      if not SeedsIn(1)(i).DataValid and SeedsIn(0)(i).DataValid then
        seed <= SeedsIn(0)(i);
        rstSort <= '1';
      else
        rstSort <= '0';
      end if;
      seed.FrameValid <= SeedsIn(0)(i).FrameValid;
      -- Hold the seed valid for the entire frame
      -- It's only internal
      seed.DataValid <= SeedsIn(0)(i).FrameValid;
    end if;
  end process;

  NeighbourLoop:
  for j in 0 to 8 generate
  begin
    process(clk)
    begin
      if rising_edge(clk) then
        if Neighbours(i, j) /= -1 then
          candidatesCopy(j) <= PFChargedObjIn(0)(Neighbours(i, j));
          --candidatesCopyDelayed(j) <= PFChargedObjIn(SumPtLatency)(Neighbours(i, j));
        else
          candidatesCopy(j) <= PFChargedObj.DataType.cNull;
          --candidatesCopyDelayed(j) <= PFChargedObj.DataType.cNull;
        end if;
      end if;
    end process;

    -- For each neighbour, pick out the TAU_nHighestPt particles
    SortNeighbours : entity PFChargedObj.StreamSort 
    generic map( size <= TAU_nHighestPt );
    port map(clk, rstSort, candidatesCopyDelayed(j), PtSortedCandidatesNeighbours(j));

  end generate;
end generate;

OutPipe : entity PFChargedObj.DataPipe
port map(clk, PFChargedObjOutInt, PFChargedObjOut);

DebugInstance : entity PFChargedObj.Debug
generic map( FileName => "HighestPtCandidatesInCone" )
port map(clk, PFChargedObjOutInt);

end behavioral;
