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
  constant sumPtLatency : integer := 1;
  constant SeedDelayLatency : integer := 6;
  signal PFChargedObjOutInt : PFChargedObj.ArrayTypes.Vector(0 to N_PF_Regions - 1) := PFChargedObj.ArrayTypes.NullVector(N_PF_Regions);
begin

RegionLoop:
--for i in 0 to N_PF_Regions - 1 generate
for i in 0 to N_PF_REGIONS_PerLayer1Board - 1 generate
  -- A copy of the candidates neighbouring this region
  signal candidatesCopy : PFChargedObj.ArrayTypes.Vector(0 to 8) := PFChargedObj.ArrayTypes.NullVector(9);
  signal candidatesCopyDelayed : PFChargedObj.ArrayTypes.Vector(0 to 8) := PFChargedObj.ArrayTypes.NullVector(9);
  signal accumulators : PFChargedObj.ArrayTypes.Vector(0 to 8) := PFChargedObj.ArrayTypes.NullVector(9);
  signal accumulatorsTreeReduce : PFChargedObj.ArrayTypes.Matrix(0 to 4)(0 to 9) := PFChargedObj.ArrayTypes.NullMatrix(5, 10);
  signal sumPt : PFChargedObj.DataType.tData := PFChargedObj.DataType.cNull;
  signal sumPtTmp : PFChargedObj.DataType.tData := PFChargedObj.DataType.cNull;
  signal sumPtOut : PFChargedObj.DataType.tData := PFChargedObj.DataType.cNull;
  signal seed : PFChargedObj.DataType.tData := PFChargedObj.DataType.cNull;
  signal seedVector : PFChargedObj.ArrayTypes.Vector(0 to 0) := PFChargedObj.ArrayTypes.NullVector(1);
  signal seedVectorPipe : PFChargedObj.ArrayTypes.VectorPipe(0 to 5)(0 to 0) := PFChargedObj.ArrayTypes.NullVectorPipe(6, 1);
  --signal seedDelayed : PFChargedObj.DataType.tData := PFChargedObj.DataType.cNull;

begin
  
  --seedDelayed <= SeedsIn(SeedDelayLatency)(i);
  seedProcess:
  process(clk)
  begin
    if rising_edge(clk) then
      if not SeedsIn(1)(i).DataValid and SeedsIn(0)(i).DataValid then
        seed <= SeedsIn(0)(i);
      end if;
      seed.FrameValid <= SeedsIn(0)(i).FrameValid;
      -- Hold the seed valid for the entire frame
      -- It's only internal
      seed.DataValid <= SeedsIn(0)(i).FrameValid;
    end if;
  end process;

  seedVector(0) <= seed;
  SeedPipe: entity PFChargedObj.DataPipe
  port map(clk, seedVector, seedVectorPipe);


  NeighbourLoop:
  for j in 0 to 8 generate
  begin
    process(clk)
    begin
      if rising_edge(clk) then
        if Neighbours(i, j) /= -1 then
          candidatesCopy(j) <= PFChargedObjIn(0)(Neighbours(i, j));
          candidatesCopyDelayed(j) <= PFChargedObjIn(SumPtLatency)(Neighbours(i, j));
        else
          candidatesCopy(j) <= PFChargedObj.DataType.cNull;
          candidatesCopyDelayed(j) <= PFChargedObj.DataType.cNull;
        end if;
      end if;
    end process;
  end generate;

  AccumulatorsLoop:
  for j in 0 to 8 generate
    signal acc : PFChargedObj.DataType.tData := PFChargedObj.DataType.cNull; 
  begin
    process(clk)
    begin
      if rising_edge(clk) then
        --acc <= PFChargedObj.DataType.SumPt(candidatesCopy(j), accumulators(j));
        -- The candidate stores the ID of its closest seed
        -- Here we are 'seed-centric' so take 8 - j
        if candidatesCopy(j).NeighbourID = 8 - j then
          --accumulators(j) <= acc;
          accumulators(j) <= PFChargedObj.DataType.SumPt(candidatesCopy(j), accumulators(j));
        else
          accumulators(j) <= accumulators(j);
          accumulators(j).DataValid <= candidatesCopy(j).DataValid;
          accumulators(j).FrameValid <= candidatesCopy(j).FrameValid;
        end if;
      end if;
    end process;
  end generate;

  accumulatorsTreeReduce(0)(0 to 8) <= accumulators;
  accumulatorsTreeReduce(0)(9) <= PFChargedObj.DataType.cNull;
  TreeReduce:
  for j in 1 to 3 generate
  begin
    TreeReduceLayer:
    for k in 0 to 2 ** (3 - j) generate
    begin
      ReduceProc:
      process(clk)
      begin
        if rising_edge(clk) then
          accumulatorsTreeReduce(j)(k) <= PFChargedObj.DataType.SumPt(accumulatorsTreeReduce(j-1)(2*k), accumulatorsTreeReduce(j-1)(2*k+1));
        end if;
      end process;
    end generate;
  end generate;

  FinalTreeReduceLayer:
  process(clk)
  begin
    if rising_edge(clk) then
      accumulatorsTreeReduce(4)(0) <= PFChargedObj.DataType.SumPt(accumulatorsTreeReduce(3)(0), accumulatorsTreeReduce(3)(1));
      sumPt <= PFChargedObj.DataType.SumPt(seedVectorPipe(SeedDelayLatency-1)(0), accumulatorsTreeReduce(4)(0));
      sumPtTmp <= sumPt;
    end if;
  end process;
 
  CopyOut:
  process(clk)
  begin
    if rising_edge(clk) then
      if not sumPt.DataValid and sumPtTmp.DataValid then
        sumPtOut <= sumPtTmp;
      else
        sumPtOut <= PFChargedObj.DataType.cNull;
      end if;
    end if;
  end process;

  PFChargedObjOutInt(i) <= sumPtOut;

end generate;

OutPipe : entity PFChargedObj.DataPipe
port map(clk, PFChargedObjOutInt, PFChargedObjOut);

DebugInstance : entity PFChargedObj.Debug
generic map( FileName => "SumCandidatesAroundSeed" )
port map(clk, PFChargedObjOutInt);

end behavioral;
