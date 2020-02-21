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

entity PairReduceNoClk is
port(
  PFChargedObjIn : in PFChargedObj.ArrayTypes.Vector;
  PFChargedObjOut : out PFChargedObj.ArrayTypes.Vector
);
end PairReduceNoClk;

architecture behavioral of PairReduceNoClk is
begin

ReduceLoop:
for i in 0 to PFChargedObjIn'length / 2 - 1 generate
  signal A : PFChargedObj.DataType.tData := PFChargedObj.DataType.cNull;
  signal B : PFChargedObj.DataType.tData := PFChargedObj.DataType.cNull;
begin
  A <= PFChargedObjIn(2*i);
  B <= PFChargedObjIn(2* i + 1);
  process(PFChargedObjIn)
  begin
    -- TODO ">" should be defined for PFChargedObj, but trouble resolving
    if to_integer(A.pt) > to_integer(B.pt) then
      PFChargedObjOut(i) <= A;
    else
      PFChargedObjOut(i) <= B;
    end if;
  end process;
end generate;

end behavioral;
