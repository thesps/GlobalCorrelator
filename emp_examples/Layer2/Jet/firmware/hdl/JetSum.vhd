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

-- Input the seed and its 9 neighbouring regions of objects
entity JetSum is
port(
  clk : in std_logic;
  Seed : in PFChargedObj.ArrayTypes.VectorPipe;
  JetConstituents : in PFChargedObj.ArrayTypes.VectorPipe;
  Jets : out PFChargedObj.ArrayTypes.VectorPipe
);
end JetSum;

architecture behavioral of JetSum is
  -- One output stream per region
  signal PFChargedObjOutInt : PFChargedObj.ArrayTypes.Vector(0 to 8) := PFChargedObj.ArrayTypes.NullVector(N_PF_Regions);
  signal CurrentConstituentsSumPt : PFChargedObj.ArrayTypes.Vector(0 to 0) := PFChargedObj.ArrayTypes.NullVector(1);
  signal CurrentJet : PFChargedObj.DataType.tData := PFChargedObj.DataType.cNull;
  signal JetsInt : PFChargedObj.ArrayTypes.Vector(0 to N_Jets - 1) := PFChargedObj.ArrayTypes.NullVector(N_Jets);
  signal iJet : integer range 0 to N_Jets - 1 := 0;
  signal newEvent : boolean := False;
  signal newJet : boolean := False;
begin

SumConstituents : entity PFChargedObj.PairReduceSum
port map(clk, JetConstituents(0), CurrentConstituentsSumPt);

Accumulate : process(clk)
begin
  if rising_edge(clk) then
    if newEvent then
      iJet <= 0;
      CurrentJet <= Seed(0)(0);
      for i in 0 to N_Jets - 1 loop
        JetsInt(i) <= PFChargedObj.DataType.cNull;
      end loop;
    else
      if newJet then
        CurrentJet <= Seed(0)(0);
        iJet <= iJet + 1;
      else
        CurrentJet.pt <= CurrentJet.pt + CurrentConstituentsSumPt.pt;
      end if;
      JetsInt(iJet) <= CurrentJet;
    end if;
  end if;
end process;

OutPipe : entity PFChargedObj.DataPipe
port map(clk, JetsInt, Jets);

DebugInstance : entity PFChargedObj.Debug
generic map( FileName => "JetSum" )
port map(clk, JetsInt);

end behavioral;
