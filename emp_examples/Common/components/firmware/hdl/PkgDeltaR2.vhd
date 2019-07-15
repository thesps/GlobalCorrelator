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
    ---------------------
    -- Below this not stored if object written to RAM
    --------------------
    deltaR2 : deltaR2_t;
  end record;
 
  attribute size : natural;
  attribute size of tData : type is 36; -- Rounded up 

  constant cNull : tData := (false, false, (others => '0'));

  constant ZeroPointFourSquared : tData := (false, false, "000000000100000000000"); 

  --function ToStdLogicVector(x : tData) return std_logic_vector;
  --function ToDataType(x : std_logic_vector) return tData;

  function WriteHeader return string;
  function WriteData(d : tData) return string;

  --function SumPt(x, y : tData) return tData;
  function "<" (x, y : tData) return boolean;
  function ">" (x, y : tData) return boolean;

end DataType;

package body DataType is

  function ToStdLogicVector(x : tData) return std_logic_vector is
    variable y : std_logic_vector(tData'size - 1 downto 0) := (others => '0');
  begin
    y(0) := to_std_logic(x.DataValid);
    return y;
  end function;

  function ToDataType(x : std_logic_vector) return tData is
    variable y : tData := cNull;
  begin
    y.DataValid := to_boolean(x(0));
    return y;
  end function;

  function WriteHeader return string is
    variable x : line;
  begin
    write(x, string'("FrameValid"), right, 15);
    write(x, string'("DataValid"), right, 15);
    write(x, string'("DeltaR2"), right, 15);
    return x.all;
  end WriteHeader;

  function WriteData(d : tData) return string is 
    variable x : line;
  begin
    write(x, d.FrameValid, right, 15);
    write(x, d.DataValid, right, 15);
    write(x, to_integer(d.DeltaR2), right, 15);
    return x.all;
  end WriteData;


  function "<" (x, y : tData) return boolean is
    variable ret : boolean := false;
  begin
      if to_integer(x.deltaR2) < to_integer(y.deltaR2) then
          ret := true;
      else
          ret := false;
      end if;
      return ret;
  end "<";
  
  function ">" (x, y : tData) return boolean is
    variable ret : boolean := false;
  begin
      if to_integer(x.deltaR2) > to_integer(y.deltaR2) then
          ret := true;
      else
          ret := false;
      end if;
      return ret;
  end ">";

end DataType;
