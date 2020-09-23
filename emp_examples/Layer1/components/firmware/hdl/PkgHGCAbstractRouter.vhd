library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

library Utilities;
use Utilities.Utilities.all;

package DataType is

  type tData is record
    data       : std_logic_vector(63 downto 0); -- 64 bits data
    addr       : unsigned(5 downto 0);  -- 6 bits address (up to 64 destinations) 
    DataValid  : boolean;                       -- 
    FrameValid : boolean;                       -- 
    ------------------------------------------------------------------------------------
    -- Below here not stored in BRAM
    ------------------------------------------------------------------------------------
    iRegion : integer;
    iInRegion : integer;
  end record;
 
  attribute size : natural;
  attribute size of tData : type is 72;  

  constant cNull : tData := ((others => '0'), (others => '0'), false, false, 0, 0);

  function ToStdLogicVector(x : tData) return std_logic_vector;
  function ToDataType(x : std_logic_vector) return tData;

  function WriteHeader return string;
  function WriteData(d : tData) return string;

  function ">" (x, y : tData) return boolean;

end DataType;

package body DataType is

  function ToStdLogicVector(x : tData) return std_logic_vector is
    variable h : integer := x.data'high;
    variable l : integer := 0;
    variable y : std_logic_vector(tData'size - 1 downto 0) := (others => '0');
  begin
    y(h downto l) := std_logic_vector(x.data);
    h := h + x.data'length;
    l := l + x.data'length;
    y(h downto l) := std_logic_vector(x.addr);
    y(y'high-2) := to_std_logic(x.DataValid);
    y(y'high-1) := to_std_logic(x.FrameValid);
    return y;
  end function;

  function ToDataType(x : std_logic_vector) return tData is
    variable y : tData := cNull;
    variable h : integer := y.data'high;
    variable l : integer := 0;
  begin
    y.data := std_logic_vector(x(h downto l));
    h := h + y.data'length;
    l := l + y.data'length;
    y.addr := unsigned(x(h downto l));
    y.DataValid := to_boolean(x(x'high-2));
    y.FrameValid := to_boolean(x(x'low-1));
    return y;
  end function;

  function WriteHeader return string is
    variable x : line;
  begin
    write(x, string'("data"), right, 15);
    write(x, string'("addr"), right, 15);
    write(x, string'("FrameValid"), right, 15);
    write(x, string'("DataValid"), right, 15);
    return x.all;
  end WriteHeader;

  function WriteData(d : tData) return string is 
    variable x : line;
  begin
    write(x, to_integer(unsigned(d.data)), right, 15);
    write(x, to_integer(unsigned(d.addr)), right, 15);
    write(x, d.FrameValid, right, 15);
    write(x, d.DataValid, right, 15);
    return x.all;
  end WriteData;

  function ">" (x, y : tData) return boolean is
    variable ret : boolean := false;
  begin
    if x.DataValid and not y.DataValid then
      ret := true;
    elsif y.DataValid and not x.DataValid then
      ret := true;
    elsif to_integer(unsigned(x.data)) > to_integer(unsigned(y.data)) then
      ret := true;
    else
      ret := false;
    end if;
    return ret;
  end ">";

end DataType;
