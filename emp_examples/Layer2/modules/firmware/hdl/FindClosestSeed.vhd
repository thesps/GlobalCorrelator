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

library SeedReduce;
use SeedReduce.DataType;
use SeedReduce.ArrayTypes;

entity FindClosestSeed is
port(
  clk : in std_logic;
  SeedsIn : in PFChargedObj.ArrayTypes.VectorPipe;
  PFChargedObjIn : in PFChargedObj.ArrayTypes.VectorPipe;
  SeedsOut : out PFChargedObj.ArrayTypes.VectorPipe;
  PFChargedObjOut : out PFChargedObj.ArrayTypes.VectorPipe
);
end FindClosestSeed;

architecture behavioral of FindClosestSeed is
  -- Verify this latency
  constant ModuleLatency : integer := 9;
  constant DeltaRLatency : integer := 5;
  type deltaR2Array is array(0 to 8) of deltaR2_t;
  signal PFChargedObjOutInt : PFChargedObj.ArrayTypes.Vector(0 to N_PF_Regions - 1) := PFChargedObj.ArrayTypes.NullVector(N_PF_Regions);
  signal SeedsOutInt : PFChargedObj.ArrayTypes.Vector(0 to N_PF_Regions - 1) := PFChargedObj.ArrayTypes.NullVector(N_PF_Regions);
begin

-- Simplest, most naive seeding: take the highest pT object from each region
-- The objects arrive pT ordered so just take the first to arrvie
RegionLoop:
--for i in 0 to N_PF_Regions - 1 generate
for i in 0 to N_PF_REGIONS_PerLayer1Board - 1 generate
  -- A copy of the seeds neighbouring this region
  signal seedsCopy : PFChargedObj.ArrayTypes.Vector(0 to 8) := PFChargedObj.ArrayTypes.NullVector(9);
  -- The deltaR2s between the current region and every neighbouring seed
  signal deltaR2s : deltaR2Array := (others => (others => '0')); 
  -- The pair reducing closest seed
  -- 5 layers of comparison, 10 objects per layer (should get trimmed)
  -- Because we want to reduce 9 objects, pad to 10 for simplicity
  signal seedsTreeReduce : SeedReduce.ArrayTypes.Matrix(0 to 4)(0 to 9) := SeedReduce.ArrayTypes.NullMatrix(5, 10);
begin
  
  -- Calculate delta R for every seed in neighbouring regions to this candidate
  SeedLoop:
  for j in 0 to 8 generate
    signal seed : PFChargedObj.DataType.tData := PFChargedObj.DataType.cNull;
    --signal seedDelayed : PFChargedObj.DataType.tData := PFChargedObj.DataType.cNull;
  begin
    process(clk)
    begin
      if rising_edge(clk) then
      if Neighbours(i, j) /= -1 then
        if not SeedsIn(1)(Neighbours(i, j)).DataValid and SeedsIn(0)(Neighbours(i, j)).DataValid then
          seed <= SeedsIn(0)(Neighbours(i, j));
          --seedDelayed <= SeedsIn(DeltaRLatency)(Neighbours(i, j));
        end if;
      else
        seed <= PFChargedObj.DataType.cNull;
        --seedDelayed <= PFChargedObj.DataType.cNull;
      end if;
      end if;
    end process;
    dr2Calc : entity PFChargedObj.deltaR2
    port map(clk, seed, PFChargedObjIn(1)(i), deltaR2s(j));  

    -- Start the pair reduce to find the closest
    -- The null-object padding should never be propagated by the 'closest' function
    seedsTreeReduce(0)(j).deltaR2 <= deltaR2s(j);
    seedsTreeReduce(0)(j).NeighbourID <= j;
    seedsTreeReduce(0)(j).FrameValid <= seed.FrameValid;
    seedsTreeReduce(0)(j).DataValid <= seed.DataValid and PFChargedObjIn(DeltaRLatency)(i).DataValid;
  end generate;

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
            seedsTreeReduce(j)(k) <= SeedReduce.DataType.Closer(seedsTreeReduce(j-1)(2*k), seedsTreeReduce(j-1)(2*k+1));
        end if;
      end process;
    end generate; 
  end generate;

  FinalTreeReduceLayer:
  process(clk)
  begin
    if rising_edge(clk) then
      seedsTreeReduce(4)(0) <= SeedReduce.DataType.Closer(seedsTreeReduce(3)(0), seedsTreeReduce(3)(1));
    end if;
  end process;

  PFChargedObjOutInt(i).pt <= PFChargedObjIn(ModuleLatency)(i).pt;
  PFChargedObjOutInt(i).eta <= PFChargedObjIn(ModuleLatency)(i).eta;
  PFChargedObjOutInt(i).phi <= PFChargedObjIn(ModuleLatency)(i).phi;
  PFChargedObjOutInt(i).id <= PFChargedObjIn(ModuleLatency)(i).id;
  PFChargedObjOutInt(i).z0 <= PFChargedObjIn(ModuleLatency)(i).z0;
  PFChargedObjOutInt(i).DataValid <= PFChargedObjIn(ModuleLatency)(i).DataValid;
  PFChargedObjOutInt(i).FrameValid <= PFChargedObjIn(ModuleLatency)(i).FrameValid;
  PFChargedObjOutInt(i).NeighbourID <= seedsTreeReduce(4)(0).NeighbourID;
  PFChargedObjOutInt(i).DeltaR2 <= seedsTreeReduce(4)(0).DeltaR2;

end generate;

SeedsOutInt <= SeedsIn(ModuleLatency);

OutPipe : entity PFChargedObj.DataPipe
port map(clk, PFChargedObjOutInt, PFChargedObjOut);

OutPipeSeeds : entity PFChargedObj.DataPipe
port map(clk, SeedsOutInt, SeedsOut);

DebugInstance : entity PFChargedObj.Debug
generic map( FileName => "FindClosest" )
port map(clk, PFChargedObjOutInt);

end behavioral;
