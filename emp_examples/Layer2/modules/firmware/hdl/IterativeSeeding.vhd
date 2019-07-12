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

library TDeltaR2;
use TDeltaR2.DataType;
use TDeltaR2.ArrayTypes;

entity IterativeSeeding is
port(
  clk : in std_logic;
  PFChargedObjStream : in PFChargedObj.ArrayTypes.VectorPipe; -- Region Streams
  Seeds : out PFChargedObj.ArrayTypes.VectorPipe;
  --PFChargedObjOut : out PFChargedObj.ArrayTypes.VectorPipe
);
end IterativeSeeding;

architecture behavioral of Seeding is
  signal GlobalSeeds : PFChargedObj.ArrayTypes.Vector(0 to N_SEEDS - 1) := PFChargedObj.ArrayTypes.NullVector(N_SEEDS);
  signal GlobalSeedsUpdate := PFChargedObj.ArrayTypes.Vector(0 to N_SEEDS - 1) := PFChargedObj.ArrayTypes.NullVector(N_SEEDS);
  signal SortedSeedsByRegion : PFChargedObj.ArrayTypes.Vector(0 to N_SEEDS - 1) := PFChargedObj.ArrayTypes.NullVector(N_SEEDS);

  signal DeltaR2_SortedSeedsByRegion : TDeltaR2.ArrayTypes.Matrix(0 TO N_SEEDS - 1)(0 TO N_SEEDS - 1) := TDeltaR2.ArrayTypes.NullMatrix(N_SEEDS, N_SEEDS);
  signal SortedSeedsByRegionCleaned : PFChargedObj.ArrayTypes.Vector(0 to N_SEEDS - 1) := PFChargedObj.ArrayTypes.NullVector(N_SEEDS);
  signal SortedSeedsByRegionCleaned_Pipe : PFChargedObj.ArrayTypes.VectorPipe(0 to 1)(0 to N_SEEDS - 1) := PFChargedObj.ArrayTypes.NullVectorPipe(2, N_SEEDS);

  signal SeedingStep : integer range 0 to N_SEEDING_ITERATIONS := 0;
begin

-- Sort the best nth candidate from each region keeping N_SEEDS
SortTopCandsInRegions : entity PFChargedObj.BitonicSort
generic map(PFChargedObjStream'length, N_SEEDS, true, "SortTopCandsInRegions")
port map(clk, PFChargedObjStream(0), SortedSeedsByRegion);

-- Eliminate lower pt seeds within 0.4 of higher pt seeds
-- First calculate the pairwise distances
DR2_i:
for i in 1 to N_SEEDS - 1 generate
  begin
  DR2_j:
  for j in 0 to i generate
    signal dr2 : deltaR2_t := (others => '0');
    begin
    DR2_Calc : entity PFChargedObj.DeltaR2(clk, SortedSeedsByRegion(i), SortedSeedsByRegion(j), dr2);
    DeltaR2_SortedSeedsByRegion(i)(j).deltaR2 <= dr2;
    DeltaR2_SortedSeedsByRegion(j)(i).deltaR2 <= dr2;
  end generate;
end generate;

-- Now eliminate the lower pt seed with a nearby higher pt seed
ElimNearby_i
for i in 0 to N_SEEDS - 1 generate
  ElimNearby:
  process(clk)
  variable eliminate : boolean := false;
  begin
    if rising_edge(clk) then
      for j in 0 to N_SEEDS - 1 loop
        if DeltaR2_SortedSeedsByRegion(i)(j) < TDeltaR2.DataType.ZeroPointFour and SortedSeedsByRegion(i) < SortedSeedsByRegion(j) then
          eliminate := true;
        end if;
      end loop;

      if eliminate then
        SortedSeedsByRegionCleaned(i) <= PFChargedObj.DataType.cNull;
      else
        SortedSeedsByRegionCleaned(i) <= SortedSeedsByRegion(i);
      end if;
    end if;
  end process;
end generate;

Pipe : entity PFChargedObj.DataPipe
port map(clk, SortedSeedsByRegionCleaned, SortedSeedsByRegionCleaned_Pipe);

-- Iteration counter
-- Sits at 0 when idle, goes to 1 when first valid data arrives
process(clk) 
begin
  if rising_edge(clk) then
    if not SortedSeedsByRegionCleaned_Pipe(0)(0).FrameValid or SeedingStep = N_SEEDING_ITERATIONS - 1 then
      SeedingStep <= 0;
    elsif SortedSeedsByRegionCleaned_Pipe(0)(0).FrameValid and not SortedSeedsByRegionCleaned_Pipe(1)(0) then
      SeedingStep <= 1;
    else
      SeedingStep <= SeedingStep + 1;
    end if;
  end if;
end process;

-- Eliminate lower pt seeds within 0.4 of higher pt seeds
-- First calculate the pairwise distances
DR2_i:
for i in 1 to N_SEEDS - 1 generate
  begin
  DR2_j:
  for j in 0 to i generate
    signal dr2 : deltaR2_t := (others => '0');
    begin
    DR2_Calc : entity PFChargedObj.DeltaR2(clk, SortedSeedsByRegionCleaned(i), GlobalSeeds(j), dr2);
    DeltaR2_GlobalSeedsUpdate(i)(j).deltaR2 <= dr2;
    DeltaR2_GlobalSeedsUpdate(j)(i).deltaR2 <= dr2;
  end generate;
end generate;

-- Now eliminate the lower pt seed with a nearby higher pt seed
UpdateElimNearby_i
for i in 0 to N_SEEDS - 1 generate
  UpdateElimNearby_j:
  process(clk)
  variable eliminate : boolean := false;
  begin
    if rising_edge(clk) then
      for j in 0 to N_SEEDS - 1 loop
        if DeltaR2_GlobalSeedsUpdate(i)(j) < TDeltaR2.DataType.ZeroPointFour and SortedSeedsByRegionCleaned(i) < GlobalSeeds(j) then
          eliminate := true;
        end if;
      end loop;

      if eliminate then
        GlobalSeedsUpdate(i) <= PFChargedObj.DataType.cNull;
      else
        GlobalSeedsUpdate(i) <= SortedSeedsByRegionCleaned(i);
      end if;
    end if;
  end process;
end generate;




OutPipe : entity PFChargedObj.DataPipe
port map(clk, SeedsInt, Seeds);

OutPipe1 : entity PFChargedObj.DataPipe
port map(clk, PFCandsInt, PFChargedObjOut);

DebugInstance : entity PFChargedObj.Debug
generic map( FileName => "Seeding" )
port map(clk, SeedsInt);

end behavioral;
