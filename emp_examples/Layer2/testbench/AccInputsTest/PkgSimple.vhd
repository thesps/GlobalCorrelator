library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

library utilities;
use utilities.utilities.all;

package DataType is

  type tData is record
    pt  : unsigned(63 downto 0);         -- 16 bits
    DataValid : boolean;
    FrameValid : boolean;
  end record;
 
  attribute size : natural;
  attribute size of tData : type is 66; -- Actual is 56, round up to BRAM boundary 

  constant cNull : tData := ((others => '0'), false, false);

  function ToStdLogicVector(x : tData) return std_logic_vector;
  function ToDataType(x : std_logic_vector) return tData;

  function WriteHeader return string;
  function WriteData(d : tData) return string;

end DataType;

package body DataType is

  function ToStdLogicVector(x : tData) return std_logic_vector is
    variable h : integer := x.pt'high;
    variable l : integer := 0;
    variable y : std_logic_vector(tData'size - 1 downto 0) := (others => '0');
  begin
    y(h downto l) := std_logic_vector(x.pt);
    return y;
  end function;

  function ToDataType(x : std_logic_vector) return tData is
    variable y : tData := cNull;
    variable h : integer := y.pt'high;
    variable l : integer := 0;
  begin
    y.pt := unsigned(x(h downto l));
    return y;
  end function;

  function WriteHeader return string is
    variable x : line;
  begin
    write(x, string'("pt"), right, 15);
    write(x, string'("FrameValid"), right, 15);
    write(x, string'("DataValid"), right, 15);
    return x.all;
  end WriteHeader;

  function WriteData(d : tData) return string is 
    variable x : line;
  begin
    write(x, to_integer(d.pt), right, 15);
    write(x, d.FrameValid, right, 15);
    write(x, d.DataValid, right, 15);
    return x.all;
  end WriteData;

end DataType;
