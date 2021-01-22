library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use ieee.math_real.all;
use std.textio.all;

--library utilities;
--use utilities.utilities.all;

package DataType is

  type tData is record
    pt : integer range 0 to (2**16) - 1;
    eta : integer range -(2**9) to (2**9) - 1;
    phi : integer range -(2**9) to (2**9) - 1;
    iSeed : integer range 0 to (2**5) - 1;
    nCand : integer range 0 to (2**5) - 1;
    DataValid  : boolean;
    FrameValid : boolean;
  end record;
 
  attribute size : natural;
  attribute size of tData : type is 66;  

  constant cNull : tData := (0, 0, 0, 0, 0, false, false);

  function ToStdLogicVector(x : tData) return std_logic_vector;
  function ToDataType(x : std_logic_vector) return tData;

  function WriteHeader return string;
  function WriteData(d : tData) return string;

  function ">" (x, y : tData) return boolean;
  function "<=" (x, y : tData) return boolean;

end DataType;

package body DataType is

  function ToStdLogicVector(x : tData) return std_logic_vector is
    variable y : std_logic_vector(tData'size - 1 downto 0) := (others => '0');
  begin
    y(15 downto 0) := std_logic_vector(to_unsigned(x.pt, 16));
    y(25 downto 16) := std_logic_vector(to_signed(x.eta, 10));
    y(35 downto 26) := std_logic_vector(to_signed(x.phi, 10));
    y(40 downto 36) := std_logic_vector(to_unsigned(x.iSeed, 5));
    y(45 downto 41) := std_logic_vector(to_unsigned(x.nCand, 5));
    return y;
  end function;

  function ToDataType(x : std_logic_vector) return tData is
    variable y : tData := cNull;
  begin
    y.pt    := to_integer(unsigned(x(15 downto 0)));
    y.eta   := to_integer(signed(x(25 downto 16)));
    y.phi   := to_integer(signed(x(35 downto 26)));
    y.iSeed := to_integer(unsigned(x(40 downto 36)));
    y.nCand := to_integer(unsigned(x(45 downto 41)));
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
      ret := false;
    elsif x.pt > y.pt then
      ret := true;
    else
      ret := false;
    end if;
    return ret;
  end ">";

  function "<=" (x, y : tData) return boolean is
    variable ret : boolean := false;
  begin
    if x.DataValid and not y.DataValid then
      ret := false;
    elsif y.DataValid and not x.DataValid then
      ret := true;
    elsif x.pt <= y.pt then
      ret := true;
    else
      ret := false;
    end if;
    return ret;
  end "<=";

end DataType;
