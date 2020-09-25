library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package DataType is

  type tData is record
    x : boolean;
    DataValid : boolean;
    FrameValid : boolean;
  end record;

  constant cNull : tData := (false, false, false);

end DataType;

package body DataType is

end DataType;
