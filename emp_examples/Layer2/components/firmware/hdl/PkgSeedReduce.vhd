library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

library utilities;
use utilities.utilities.all;

library Layer2;
use Layer2.Constants.all;

package DataType is

  type tData is record
    DataValid : boolean;
    FrameValid : boolean;
    deltaR2 : deltaR2_t;
    neighbourID : integer range -1 to 8;
  end record;

  constant cNull : tData := (false, false, (others => '0'), -1);

  function Closer(x, y : tData) return tData;

end DataType;

package body DataType is

  function Closer(x, y : tData) return tData is
    variable z : tData := cNull;
  begin
    if x.DataValid and y.DataValid then
      if x.deltaR2 <= y.deltaR2 then
        z := x;
      else
        z := y;
      end if;
    elsif x.DataValid and not y.DataValid then
      z := x;
    elsif not x.DataValid and y.DataValid then
      z := y;
    end if;
    return z;
  end function;

end DataType;
