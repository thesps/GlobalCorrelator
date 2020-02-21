library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package DataType is

  type tData is record
    x : integer range 0 to 128;
    DataValid : boolean;
    FrameValid : boolean;
  end record;

  constant cNull : tData := (0, false, false);

  function "+" (a, b : tData) return tData;

end DataType;

package body DataType is

  function "+" (a, b : tData) return tData is
    variable z : tData := cNull;
  begin
    z.x := a.x + b.x;
    z.DataValid := a.DataValid or b.DataValid;
    z.FrameValid := a.FrameValid or b.FrameValid;
    return z;
  end function;

end DataType;
