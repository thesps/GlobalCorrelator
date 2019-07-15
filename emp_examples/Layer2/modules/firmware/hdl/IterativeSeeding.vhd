library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library Utilities;
use Utilities.Utilities.all;

library Layer2;
use Layer2.Constants.all;
use Layer2.PkgIterativeSeeding.all;

library PFChargedObj;
use PFChargedObj.DataType;
use PFChargedObj.ArrayTypes;

library TDeltaR2;
use TDeltaR2.DataType;
use TDeltaR2.ArrayTypes;

entity IterativeSeeding is
port(
  clk : in std_logic;
  rst : in std_logic;
  PFChargedObjIn : in PFCHargedObj.ArrayTypes.Vector(0 to N_Region_Groups - 1) := PFChargedObj.ArrayTypes.NullVector(N_Region_Groups);
  -- PFChargedObjBuffer : in PFChargedObj.ArrayTypes.Matrix(0 to N_Region_Groups - 1)(0 to N_Parts_Per_Region_Group - 1); -- Region-streams in groups
  Seeds : out PFChargedObj.ArrayTypes.VectorPipe(0 to 7)(0 to N_Seeds - 1) := PFChargedObj.ArrayTypes.NullVectorPipe(8, N_Seeds)
  --PFChargedObjOut : out PFChargedObj.ArrayTypes.VectorPipe
);
end IterativeSeeding;

architecture behavioral of IterativeSeeding is

  -- TODO check this value: nothing will work correctly if it is wrong
  constant inConeLatency : integer := 6;
  constant pairReduceLatency : integer := 1;
  constant read_limit : integer := N_Parts_Per_Region_Group;

  signal PFChargedObjInPipe : PFChargedObj.ArrayTypes.VectorPipe(0 to 1)(0 to N_Region_Groups - 1) := PFChargedObj.ArrayTypes.NullVectorPipe(2, N_Region_Groups);
  signal ObjInt : PFChargedObj.ArrayTypes.Matrix(0 to N_Region_Groups - 1)(0 to N_Parts_Per_Region_Group - 1) := PFCHargedObj.ArrayTypes.NullMatrix(N_Region_Groups, N_Parts_Per_Region_Group);
  signal ObjRead : PFChargedObj.ArrayTypes.Vector(0 to N_Region_Groups - 1) := PFChargedObj.ArrayTypes.NullVector(N_Region_Groups); -- One per region group
  signal ObjReadPipe : PFChargedObj.ArrayTypes.VectorPipe(0 to inConeLatency - 1)(0 to N_Region_Groups - 1) := PFChargedObj.ArrayTypes.NullVectorPipe(inConeLatency, N_Region_Groups);
  signal ObjWrite : PFChargedObj.ArrayTypes.Vector(0 to N_Region_Groups - 1) := PFChargedObj.ArrayTypes.NullVector(N_Region_Groups); -- One per region group
  signal GlobalSeeds : PFChargedObj.ArrayTypes.Vector(0 to N_SEEDS - 1) := PFChargedObj.ArrayTypes.NullVector(N_SEEDS);
  signal CurrentGlobalSeed : PFChargedObj.DataType.tData := PFChargedObj.DataType.cNull;
  signal iSeed : integer range 0 to N_SEEDS := 0;

  subtype tAddr is integer range 0 to N_Parts_Per_Region_Group - 1;
  type tAddrArr is array(natural range <>) of tAddr;
  signal rAddrs : tAddrArr(0 to N_Region_Groups - 1) := (others => 0);
  signal wAddrs : tAddrArr(0 to N_Region_Groups - 1) := (others => 0);
  signal wAddrExt : tAddr := 0;

  type tBoolArr is array(natural range <>) of boolean;
  type tBoolArrPipe is array(natural range <>) of tBoolArr;
  signal inCone : tBoolArr(0 to N_Region_Groups - 1) := (others => false);
  signal inConePipe : tBoolArrPipe(0 to inConeLatency - 1)(0 to N_Region_Groups - 1) := (others => (others => false));
  signal writeEn : tBoolArr(0 to N_Region_Groups - 1) := (others => false);
  signal newSeed : boolean := false;

  -- Signals for the pair reduce to find maximum pT cand
  signal PairReduce0 : PFChargedObj.ArrayTypes.Vector(0 to 4 - 1) := PFChargedObj.ArrayTypes.NullVector(4);
  signal PairReduce1 : PFChargedObj.ArrayTypes.Vector(0 to 2 - 1) := PFChargedObj.ArrayTypes.NullVector(2);
  signal PairReduce2 : PFChargedObj.ArrayTypes.Vector(0 to 1 - 1) := PFChargedObj.ArrayTypes.NullVector(1);
  signal PairReduce2_r : PFChargedObj.ArrayTypes.Vector(0 to 1 - 1) := PFChargedObj.ArrayTypes.NullVector(1);

begin

InPipe : entity PFChargedObj.DataPipe
port map(clk, PFChargedObjIn, PFChargedObjInPipe);

WriteExt:
process(clk)
begin
  if rising_edge(clk) then
    if PFChargedObjInPipe(0)(0).DataValid and not PFChargedObjInPipe(1)(0).DataValid then
      wAddrExt <= 0;
    elsif PFChargedObjInPipe(0)(0).DataValid then
      wAddrExt <= wAddrExt + 1;
    else
      wAddrExt <= 0;
    end if;
  end if;
end process;

-- TODO only works for 4 region groups
-- Find the maximum Pt object from the front of the grouped-regions
PRIn:
for i in 0 to 3 generate
begin
  PairReduce0(i) <= ObjRead(i);
end generate;

-- Try just clocking every other time
PR0 : entity PFChargedObj.PairReduceNoClk
port map(PairReduce0, PairReduce1);

PR1 : entity PFChargedObj.PairReduceNoClk
port map(PairReduce1, PairReduce2);

PR1_r:
process(clk)
begin
  if rising_edge(clk) then
    PairReduce2_r <= PairReduce2;
  end if;
end process;

UpdateGlobalSeed:
process(clk)
begin
  if rising_edge(clk) then
    if newSeed then -- when?
      GlobalSeeds(iSeed) <= PairReduce2_r(0);
      CurrentGlobalSeed <= PairReduce2_r(0);
    end if;
  end if;
end process;

GenRead:
for i in 0 to N_Region_Groups - 1 generate
begin
  ReadProc:
  process(clk)
  begin
    if rising_edge(clk) then
      if rst then
        rAddrs(i) <= 0;
      elsif rAddrs(i) = read_limit - 1 then
        rAddrs(i) <= 0;
      else
        rAddrs(i) <= rAddrs(i) + 1;
      end if;
    end if;
    ObjRead(i) <= ObjInt(i)(rAddrs(i));
  end process;
end generate;

NewSeedProc:
process(clk)
begin
  if rising_edge(clk) then
    if rAddrs(0) = read_limit - 1 then
      newSeed <= true;
    elsif ObjInt(0)(0).DataValid then
      newSeed <= true;
    elsif newSeed = true then
      newSeed <= false;
    end if;
  end if;
end process;

-- Delta R2 comparison and write-back loop
GenDR2:
for i in 0 to N_Region_Groups - 1 generate
  signal deltaR2_sig : deltaR2_T := (others => '0');
  signal deltaR2_sig2 : TDeltaR2.DataType.tData := TDeltaR2.DataType.cNull;
begin
  -- Make the DR2 comparisons
  dr2 : entity PFChargedObj.DeltaR2
  port map(clk, CurrentGlobalSeed, ObjRead(i), deltaR2_sig);
  deltaR2_sig2.deltaR2 <= deltaR2_sig;
  -- Compare the dr2 with the cone size
  dr2Comp:
  process(clk)
  begin
    if rising_edge(clk) then
      inCone(i) <= to_integer(deltaR2_sig2.deltaR2) < to_integer(TDeltaR2.DataType.zeroPointFourSquared.deltaR2);
    end if;  
  end process;
  inConePipe(0)(i) <= inCone(i);
  writeEn(i) <= inConePipe(inConeLatency - 1)(i);

  WriteAddr:
  process(clk)
  begin
    if rising_edge(clk) then
      --ObjRead(i) <= ObjInt(i)(rAddrs(i));
      if writeEn(i) then
        --ObjInt(i)(wAddrs(i)) <= ObjWrite(i);
       if wAddrs(i) = read_limit - 1 then
        wAddrs(i) <= 0;
       else
        wAddrs(i) <= wAddrs(i) + 1;
       end if;
      else
        wAddrs(i) <= wAddrs(i);
      end if;
    end if;
  end process;
end generate;

WriteGen:
for i in 0 to N_Region_Groups - 1 generate
begin
  WriteProc:
  process(clk)
  begin
    if rising_edge(clk) then
      if PFChargedObjInPipe(1)(0).DataValid then
        ObjInt(i)(wAddrExt) <= PFChargedObjInPipe(1)(0);
      else
        if writeEn(i) then
          ObjInt(i)(wAddrs(i)) <= ObjWrite(i);
        end if;
      end if;
    end if;
  end process;
end generate;

PipeInCone:
process(clk)
begin
  if rising_edge(clk) then
    inConePipe(1 to inConeLatency - 1) <= inConePipe(0 to inConeLatency - 2);
  end if;
end process;

PipeObjRead : entity PFChargedObj.DataPipe
port map(clk, ObjRead, ObjReadPipe);
ObjWrite <= ObjReadPipe(inConeLatency - 1);

OutPipe : entity PFChargedObj.DataPipe
port map(clk, GlobalSeeds, Seeds);

DebugInstance : entity PFChargedObj.Debug
generic map( FileName => "Seeding" )
port map(clk, GlobalSeeds);

end behavioral;
