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

  signal PFChargedObjIn : PFChargedObj.ArrayTypes.Vector(0 to N_Layer1Boards * N_PFChargedObj_PerRegion - 1) := PFChargedObj.ArrayTypes.NullVector(N_Layer1Boards * N_PFChargedObj_PerRegion);
  --signal PFNeutralObjIn : PFNeutralObj.Vector;

  signal PFChargedObjStream : PFChargedObj.ArrayTypes.VectorPipe(0 to 19)(0 to N_PF_REGIONS - 1) := PFChargedObj.ArrayTypes.NullVectorPipe(20, N_PF_REGIONS);

  signal SeedOut : PFChargedObj.DataType.tData := PFChargedObj.DataType.cNull;
  signal PFChargedObjStream2 : PFChargedObj.ArrayTypes.VectorPipe(0 to 19)(0 to N_PF_REGIONS - 1 ) := PFChargedObj.ArrayTypes.NullVectorPipe(20, N_PF_REGIONS);
  signal RegionsNeighbouringSeed : PFChargedObj.ArrayTypes.VectorPipe(0 to 19)(0 to 8) := PFChargedObj.ArrayTypes.NullVectorPipe(20, 9);
  signal SeedOutV : PFChargedObj.ArrayTypes.Vector(0 to 0) := PFChargedObj.ArrayTypes.NullVector(1);
  signal NewSeed : std_logic := '0';

begin

  LinkDecode : entity Layer2.LinkDecode
  port map(
    clk => clk,
    LinksIn => LinksIn,
    PFChargedObjStream => PFChargedObjIn--,
    --PFNeutralObj => PFNeutralObjIn
  );

  RegionStreams : entity Layer2.AllFlatRegionsToStreams
  port map(
    clk => clk,
    PFChargedObjFlat => PFChargedObjIn,
    PFChargedObjStream => PFChargedObjStream--,
  );

  Seeding : entity Layer2.IterativeSeeding
  port map(
    clk => clk,
    PFChargedObjIn => PFChargedObjStream(0),
    CurrentSeed => SeedOut, 
    PFChargedObjOut => PFChargedObjStream2,
    NewSeedOut => NewSeed
  );

  NeighbourReduce : entity Layer2.ReduceRegionsToNeighbours
  port map(
    clk => clk,
    iRegion => X,
    PFChargedObjIn => 
    PFChargedObjOut => RegionsNeighbouringSeed
  );

  ReadOut : entity Layer2.DebugSeedOut
  port map(
    clk => clk,
    NewSeed => NewSeed,
    SeedIn => SeedOut,
    LinkOut => LinksOut(0)
  );

  SeedOutV(0) <= SeedOut;
  DebuggingOutput <= SeedOutV;
end rtl;
