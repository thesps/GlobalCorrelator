library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Use Interfaces when simulating, xil_defaultlib when synthesizing
-- Results will be the same, but Interfaces supports debug txt file
-- synthesis translate_off
library Interfaces;
use Interfaces.mp7_data_types.ALL;
-- synthesis translate_on
-- synthesis read_comments_as_HDL on
--library xil_defaultlib;
--use xil_defaultlib.emp_data_types.all;
-- synthesis read_comments_as_HDL off

library Layer2;
use Layer2.Constants.all;

library PFChargedObj;
use PFChargedObj.DataType;
use PFChargedObj.ArrayTypes;

library xil_defaultlib;
use xil_defaultlib.emp_device_decl.all;

entity PFLayer2ProcessorTop is
port(
  clk : in std_logic;
  LinksIn         : in ldata(4 * N_REGION - 1 downto 0)                := ( others => LWORD_NULL );
  LinksOut        : out ldata(4 * N_REGION - 1 downto 0)               := ( others => LWORD_NULL );
  -- Prevent all the logic being synthesized away when running standalone
  DebuggingOutput : out PFChargedObj.ArrayTypes.Vector( N_PF_REGIONS - 1 downto 0 ) := PFChargedObj.ArrayTypes.NullVector( N_PF_REGIONS )
);
end PFLayer2ProcessorTop;

architecture rtl of PFLayer2ProcessorTop is

  signal PFChargedObjIn : PFChargedObj.ArrayTypes.Vector(0 to N_PFChargedObj_PerRegion - 1) := PFChargedObj.ArrayTypes.NullVector(N_PFChargedObj_PerRegion);
  --signal PFNeutralObjIn : PFNeutralObj.Vector;

  signal PFChargedObjStream : PFChargedObj.ArrayTypes.VectorPipe(0 to 19)(0 to N_PF_REGIONS_PerLayer1Board - 1) := PFChargedObj.ArrayTypes.NullVectorPipe(20, N_PF_REGIONS_PerLayer1Board);
  signal PFChargedObjSeedSynced : PFChargedObj.ArrayTypes.VectorPipe(0 to 19)(0 to N_PF_REGIONS - 1) := PFChargedObj.ArrayTypes.NullVectorPipe(20, N_PF_REGIONS);
  --signal PFNeutralObjStream : PFNeutralObj.Vector(9 downto 0)(N_PF_REGIONS_PerLayer1Board - 1 downto 0);

  signal Seeds : PFChargedObj.ArrayTypes.VectorPipe(0 to 19)(0 to N_PF_REGIONS - 1) := PFChargedObj.ArrayTypes.NullVectorPipe(20, N_PF_REGIONS);
  signal SeedsDelayed : PFChargedObj.ArrayTypes.VectorPipe(0 to 19)(0 to N_PF_REGIONS - 1) := PFChargedObj.ArrayTypes.NullVectorPipe(20, N_PF_REGIONS);
  signal PFChargedObjAssociated : PFChargedObj.ArrayTypes.VectorPipe(0 to 19)(0 to N_PF_REGIONS - 1) := PFChargedObj.ArrayTypes.NullVectorPipe(20, N_PF_REGIONS);
  signal SeedsSumPt : PFChargedObj.ArrayTypes.VectorPipe(0 to 19)(0 to N_PF_REGIONS - 1) := PFChargedObj.ArrayTypes.NullVectorPipe(20, N_PF_REGIONS);

begin

  LinkDecode : entity Layer2.LinkDecode
  port map(
    clk => clk,
    LinksIn => LinksIn,
    PFChargedObjStream => PFChargedObjIn--,
    --PFNeutralObj => PFNeutralObjIn
  );

  RegionStreams : entity Layer2.FlatRegionsToStreams
  port map(
    clk => clk,
    PFChargedObjFlat => PFChargedObjIn,
    --PFNeutralObjFlat => PFNeutralObjIn,
    PFChargedObjStream => PFChargedObjStream--,
    --PFNeautralObjStream => PFNeutralObjStream
  );

  MakeSeeds : entity Layer2.Seeding
  port map(
    clk => clk,
    PFChargedObjStream => PFChargedObjStream,
    Seeds => Seeds,
    PFChargedObjOut => PFChargedObjSeedSynced
  );

  CandidateToSeedAssoc : entity Layer2.FindClosestSeed
  port map(
    clk => clk,
    SeedsIn => Seeds,
    PFChargedObjIn => PFChargedObjSeedSynced,
    SeedsOut => SeedsDelayed,
    PFChargedObjOut => PFChargedObjAssociated
  );
 
  SumPt : entity Layer2.SumCandidatesAroundSeed
  port map(
    clk => clk,
    SeedsIn => SeedsDelayed,
    PFChargedObjIn => PFChargedObjAssociated,
    PFChargedObjOut => SeedsSumPt
  );

  TopN : entity Layer2.HighestPtCandidatesInCone
  port map(
    clk => clk,
    SeedsIn => SeedsDelayed,
    PFChargedObjIn => PFChargedObjAssociated,
    
  );

  DebuggingOutput <= SeedsSumPt(0);
end rtl;
