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
  constant pairReduceLatency : integer := 2;
  constant read_limit : integer := N_Parts_Per_Region_Group;
  constant wAddrsNewSeedDelay : integer := 4; -- Determined from sim

  signal PFChargedObjInPipe : PFChargedObj.ArrayTypes.VectorPipe(0 to 19)(0 to N_Region_Groups - 1) := PFChargedObj.ArrayTypes.NullVectorPipe(20, N_Region_Groups);
  signal ObjInt : PFChargedObj.ArrayTypes.Matrix(0 to N_Region_Groups - 1)(0 to N_Parts_Per_Region_Group - 1) := PFCHargedObj.ArrayTypes.NullMatrix(N_Region_Groups, N_Parts_Per_Region_Group);
  signal ObjRead : PFChargedObj.ArrayTypes.Vector(0 to N_Region_Groups - 1) := PFChargedObj.ArrayTypes.NullVector(N_Region_Groups); -- One per region group
  signal ObjReadPipe : PFChargedObj.ArrayTypes.VectorPipe(0 to 19)(0 to N_Region_Groups - 1) := PFChargedObj.ArrayTypes.NullVectorPipe(20, N_Region_Groups);
  signal ObjWrite : PFChargedObj.ArrayTypes.Vector(0 to N_Region_Groups - 1) := PFChargedObj.ArrayTypes.NullVector(N_Region_Groups); -- One per region group
  signal wData : PFChargedObj.ArrayTypes.Vector(0 to N_Region_Groups - 1) := PFChargedObj.ArrayTypes.NullVector(N_Region_Groups); -- One per region group
  signal GlobalSeeds : PFChargedObj.ArrayTypes.Vector(0 to N_SEEDS - 1) := PFChargedObj.ArrayTypes.NullVector(N_SEEDS);
  signal CurrentGlobalSeed : PFChargedObj.DataType.tData := PFChargedObj.DataType.cNull;
  signal iSeed : integer range 0 to N_SEEDS := 0;

  type tDeltaR2Arr is array(natural range <>) of deltaR2_T;
  signal deltaR2_arr : tDeltaR2Arr(0 to N_Region_Groups - 1) := (others => (others => '0'));

  subtype tAddr is integer range 0 to N_Parts_Per_Region_Group - 1;
  type tAddrArr is array(natural range <>) of tAddr;
  signal rAddrs : tAddrArr(0 to N_Region_Groups - 1) := (others => 0);
  signal wAddrsInt : tAddrArr(0 to N_Region_Groups - 1) := (others => 0);
  signal wAddrExt : tAddr := 0;
  signal wAddrs : tAddrArr(0 to N_Region_Groups - 1) := (others => 0);
  signal wAddrsDel : tAddrArr(0 to N_Region_Groups - 1) := (others => 0); -- Delayed by one
  signal regMaxAddr : tAddrArr(0 to N_Region_Groups - 1) := (others => 0); -- Keep track of the number of particles written back

  type tBoolArr is array(natural range <>) of boolean;
  type tBoolArrPipe is array(natural range <>) of tBoolArr;
  signal inCone : tBoolArr(0 to N_Region_Groups - 1) := (others => false);
  signal inConePipe : tBoolArrPipe(0 to inConeLatency)(0 to N_Region_Groups - 1) := (others => (others => false));
  signal wEn : tBoolArr(0 to N_Region_Groups - 1) := (others => false);
  signal wEnInt : tBoolArr(0 to N_Region_Groups - 1) := (others => false);
  signal newSeed : boolean := false;
  signal newSeedPipe : tBoolArr(0 to 19) := (others => false);

  -- Signals for the pair reduce to find maximum pT cand
  signal PairReduce0 : PFChargedObj.ArrayTypes.Vector(0 to 4 - 1) := PFChargedObj.ArrayTypes.NullVector(4);
  signal PairReduce1 : PFChargedObj.ArrayTypes.Vector(0 to 2 - 1) := PFChargedObj.ArrayTypes.NullVector(2);
  signal PairReduce2 : PFChargedObj.ArrayTypes.Vector(0 to 1 - 1) := PFChargedObj.ArrayTypes.NullVector(1);
  signal PairReduce2_r : PFChargedObj.ArrayTypes.Vector(0 to 1 - 1) := PFChargedObj.ArrayTypes.NullVector(1);

begin

-- Pipeline some things
InPipe : entity PFChargedObj.DataPipe
port map(clk, PFChargedObjIn, PFChargedObjInPipe);
newSeedPipe(0) <= newSeed;
newSeedPipeProc:
process(clk)
begin
    if rising_edge(clk) then
        newSeedPipe(1 to newSeedPipe'length - 1) <= newSeedPipe(0 to newSeedPipe'length - 2);
    end if;
end process;

WriteExt:
process(clk)
begin
  if rising_edge(clk) then
    if PFChargedObjInPipe(0)(0).FrameValid and not PFChargedObjInPipe(1)(0).FrameValid then
      wAddrExt <= 1; -- '1' Because we already wrote to 0 last time
    elsif PFChargedObjInPipe(0)(0).FrameValid then
      if wAddrExt = read_limit - 1 then
        wAddrExt <= 0;
      else
        wAddrExt <= wAddrExt + 1;
      end if;
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
PR0 : entity PFChargedObj.PairReduce
port map(clk, PairReduce0, PairReduce1);

PR1 : entity PFChargedObj.PairReduce
port map(clk, PairReduce1, PairReduce2);

--PR1_r:
--process(clk)
--begin
--  if rising_edge(clk) then
--    PairReduce2_r <= PairReduce2;
--  end if;
--end process;
PairReduce2_r <= PairReduce2;

UpdateGlobalSeed:
process(clk)
begin
  if rising_edge(clk) then
    -- Takes pairReduceLatency to get the GS, 2 cycles for w/r
    if newSeedPipe(pairReduceLatency + 1) then -- when?
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
      -- Read needs to lag the write by 1 cycle
      if PFChargedObjInPipe(N_Parts_Per_Region_Group - inConeLatency)(i).FrameValid and not PFChargedObjInPipe(N_Parts_Per_Region_Group - inConeLatency + 1)(i).FrameValid then
        rAddrs(i) <= 0;
      -- Need to iterate from 0 when the new Global Seed arrives
      --elsif newSeedPipe(pairReduceLatency + 2) then
      --  rAddrs(i) <= 0;
      elsif rAddrs(i) = read_limit - 1 then
        rAddrs(i) <= 0;
      else
        rAddrs(i) <= rAddrs(i) + 1;
      end if;
      if rAddrs(i) < regMaxAddr(i) then -- Mask objects not overwritten
        ObjRead(i) <= ObjInt(i)(rAddrs(i));
      else
        ObjRead(i) <= PFChargedObj.DataType.cNull;
      end if;  
    end if;
  end process;
end generate;

NewSeedProc:
process(clk)
begin
  if rising_edge(clk) then
    if rAddrs(0) = read_limit - 1 then
      newSeed <= true;
    elsif PFChargedObjInPipe(N_Parts_Per_Region_Group - inConeLatency)(0).FrameValid and not PFChargedObjInPipe(N_Parts_Per_Region_Group - inConeLatency + 1)(0).FrameValid then
      newSeed <= true;
    elsif newSeed = true then
      newSeed <= false;
    end if;
  end if;
end process;

-- Delta R2 comparison and write-back loop
GenDR2:
for i in 0 to N_Region_Groups - 1 generate
  --signal deltaR2_sig : deltaR2_T := (others => '0');
  signal deltaR2_sig2 : TDeltaR2.DataType.tData := TDeltaR2.DataType.cNull;
begin
  -- Make the DR2 comparisons
  dr2 : entity PFChargedObj.DeltaR2
  port map(clk, CurrentGlobalSeed, ObjReadPipe(pairReduceLatency + 1)(i), deltaR2_arr(i));
  deltaR2_sig2.deltaR2 <= deltaR2_arr(i); -- just a convenience thing
  -- Compare the dr2 with the cone size
  dr2Comp:
  process(clk)
  begin
    if rising_edge(clk) then
      inCone(i) <= to_integer(deltaR2_sig2.deltaR2) < to_integer(TDeltaR2.DataType.zeroPointFourSquared.deltaR2);
    end if;  
  end process;
  inConePipe(0)(i) <= inCone(i);
  --wEnInt(i) <= not inConePipe(inConeLatency)(i);
  wEnInt(i) <= not inCone(i);

  WriteAddr:
  process(clk)
  begin
    if rising_edge(clk) then
      --ObjRead(i) <= ObjInt(i)(rAddrs(i));
      if wEnInt(i) then
        --ObjInt(i)(wAddrs(i)) <= ObjWrite(i);
       if wAddrsInt(i) = read_limit - 1 then
        wAddrsInt(i) <= 0;
       -- Start writing once the comparisons are valid
       else
        wAddrsInt(i) <= wAddrsInt(i) + 1;
       end if;
      else
        if newSeedPipe(wAddrsNewSeedDelay) then
            wAddrsInt(i) <= 0;
        else
            wAddrsInt(i) <= wAddrsInt(i);
        end if;
      end if;
    end if;
  end process;
end generate;

WriteAddrSel:
for i in 0 to N_Region_Groups - 1 generate
begin
  WriteAddrSelProc:
  process(clk)
  begin
    if rising_edge(clk) then
      if PFChargedObjInPipe(0)(i).FrameValid then
        wAddrs(i) <= wAddrExt;
        wData(i) <= PFChargedObjInPipe(0)(i);
        wEn(i) <= true;
      else
        wAddrs(i) <= wAddrsInt(i);
        wData(i) <= ObjWrite(i);
        wEn(i) <= wEnInt(i);
        --if writeEn(i) then
        --  ObjInt(i)(wAddrs(i)) <= ObjWrite(i);
        --end if;
      end if;
    end if;
  end process;
end generate;

-- Keep track of the maximum adress written into per region
MaxAddr:
for i in 0 to N_Region_Groups - 1 generate
begin
  process(clk)
  begin
    if rising_edge(clk) then
      wAddrsDel(i) <= wAddrs(i);
      if wAddrs(i) > wAddrsDel(i) then
        regMaxAddr(i) <= wAddrs(i);
      elsif wAddrs(i) < wAddrsDel(i) then
        regMaxAddr(i) <= regMaxAddr(i);
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
            if wEn(i) then
                ObjInt(i)(wAddrs(i)) <= wData(i);
            end if;
        end if;
    end process;
end generate;

PipeInCone:
process(clk)
begin
  if rising_edge(clk) then
    inConePipe(1 to inConePipe'length - 1) <= inConePipe(0 to inConePipe'length - 2);
  end if;
end process;

PipeObjRead : entity PFChargedObj.DataPipe
port map(clk, ObjRead, ObjReadPipe);
ObjWrite <= ObjReadPipe(inConeLatency + 3);

OutPipe : entity PFChargedObj.DataPipe
port map(clk, GlobalSeeds, Seeds);

DebugInstance : entity PFChargedObj.Debug
generic map( FileName => "Seeding" )
port map(clk, GlobalSeeds);

end behavioral;
