library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

--library utilities;
--use utilities.utilities.all;

package DataType is

  type tData is record
    pt : integer range -65536 to 65535;
    eta : integer range -512 to 511;
    phi : integer range -512 to 511;
    --data       : std_logic_vector(63 downto 0);  
    DataValid  : boolean;
    FrameValid : boolean;
  end record;
 
  attribute size : natural;
  attribute size of tData : type is 66;  

  constant cNull : tData := (0, 0, 0, false, false);

  function ToStdLogicVector(x : tData) return std_logic_vector;
  function ToDataType(x : std_logic_vector) return tData;

  function WriteHeader return string;
  function WriteData(d : tData) return string;

  function ">" (x, y : tData) return boolean;

end DataType;

package body DataType is

  function ToStdLogicVector(x : tData) return std_logic_vector is
    variable y : std_logic_vector(tData'size - 1 downto 0) := (others => '0');
  begin
    y(15 downto 0) := std_logic_vector(to_signed(x.pt, 16));
    y(25 downto 16) := std_logic_vector(to_signed(x.eta, 10));
    y(35 downto 26) := std_logic_vector(to_signed(x.phi, 10));
    y(36) := '1' when x.DataValid else '0';
    y(37) := '1' when x.FrameValid else '0';
    return y;
  end function;

  function ToDataType(x : std_logic_vector) return tData is
    variable y : tData := cNull;
  begin
    y.pt := to_integer(signed(x(15 downto 0)));
    y.eta := to_integer(signed(x(25 downto 16)));
    y.phi := to_integer(signed(x(35 downto 26)));
    y.DataValid := true when x(36) = '1' else false;
    y.FrameValid := true when x(37) = '1' else false;
    return y;
  end function;

  function WriteHeader return string is
    variable x : line;
  begin
    write(x, string'("pt"), right, 15);
    write(x, string'("eta"), right, 15);
    write(x, string'("phi"), right, 15);
    write(x, string'("FrameValid"), right, 15);
    write(x, string'("DataValid"), right, 15);
    return x.all;
  end WriteHeader;

  function WriteData(d : tData) return string is 
    variable x : line;
  begin
    write(x, d.pt, right, 15);
    write(x, d.eta, right, 15);
    write(x, d.phi, right, 15);
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
    elsif x.pt > y.pt then
      ret := true;
    else
      ret := false;
    end if;
    return ret;
  end ">";

end DataType;
