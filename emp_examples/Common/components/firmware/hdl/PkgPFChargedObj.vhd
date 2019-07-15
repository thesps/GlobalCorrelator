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
    pt  : pt_t;         -- 16 bits
    eta : etaphi_t;     -- 10 bits
    phi : etaphi_t;     -- 10 bits
    id  : particleID_t; -- 3 bits
    z0  : z0_t;         -- 10 bits
    DataValid : boolean;
    FrameValid : boolean;
    ---------------------
    -- Below this not stored if object written to RAM
    --------------------
    deltaR2 : deltaR2_t;
    NeighbourID : integer range -1 to 8;
  end record;
 
  attribute size : natural;
  attribute size of tData : type is 72; -- Actual is 56, round up to BRAM boundary 

  constant cNull : tData := ((others => '0'), (others => '0'), (others => '0'), (others => '0'), (others => '0'), false, false, (others => '0'), 0);

  function ToStdLogicVector(x : tData) return std_logic_vector;
  function ToDataType(x : std_logic_vector) return tData;

  function WriteHeader return string;
  function WriteData(d : tData) return string;

  function SumPt(x, y : tData) return tData;
  function "<" (left, right : tData) return boolean;
  function ">" (left, right : tData) return boolean;

end DataType;

package body DataType is

  function ToStdLogicVector(x : tData) return std_logic_vector is
    variable h : integer := x.pt'high;
    variable l : integer := 0;
    variable y : std_logic_vector(tData'size - 1 downto 0) := (others => '0');
  begin
    y(h downto l) := std_logic_vector(x.pt);
    h := h + x.eta'length;
    l := l + x.pt'length;
    y(h downto l) := std_logic_vector(x.eta);
    h := h + x.phi'length;
    l := l + x.eta'length;
    y(h downto l) := std_logic_vector(x.phi);
    h := h + x.id'length;
    l := l + x.phi'length;
    y(h downto l) := std_logic_vector(x.id);
    h := h + x.z0'length;
    l := l + x.id'length;
    y(h downto l) := std_logic_vector(x.z0);
    y(h+1) := to_std_logic(x.DataValid);
    --h := h + x.z0'length;
    --l := l + x.z0'length;
    return y;
  end function;

  function ToDataType(x : std_logic_vector) return tData is
    variable y : tData := cNull;
    variable h : integer := y.pt'high;
    variable l : integer := 0;
  begin
    y.pt := signed(x(h downto l));
    h := h + y.eta'length;
    l := l + y.pt'length;
    y.eta := signed(x(h downto l));
    h := h + y.phi'length;
    l := l + y.eta'length;
    y.phi := signed(x(h downto l));
    h := h + y.id'length;
    l := l + y.phi'length;
    y.id := unsigned(x(h downto l));
    h := h + y.z0'length;
    l := l + y.id'length;
    y.z0 := signed(x(h downto l));
    y.DataValid := to_boolean(x(h+1));

    --h := h + y.z0'length;
    --l := l + y.z0'length;
    return y;
  end function;

  function WriteHeader return string is
    variable x : line;
  begin
    write(x, string'("pt"), right, 15);
    write(x, string'("eta"), right, 15);
    write(x, string'("phi"), right, 15);
    write(x, string'("id"), right, 15);
    write(x, string'("z0"), right, 15);
    write(x, string'("FrameValid"), right, 15);
    write(x, string'("DataValid"), right, 15);
    write(x, string'("DeltaR2"), right, 15);
    write(x, string'("NeighbourID"), right, 15);
    return x.all;
  end WriteHeader;

  function WriteData(d : tData) return string is 
    variable x : line;
  begin
    write(x, to_integer(d.pt), right, 15);
    write(x, to_integer(d.eta), right, 15);
    write(x, to_integer(d.phi), right, 15);
    write(x, to_integer(d.id), right, 15);
    write(x, to_integer(d.z0), right, 15);
    write(x, d.FrameValid, right, 15);
    write(x, d.DataValid, right, 15);
    write(x, to_integer(d.DeltaR2), right, 15);
    write(x, d.NeighbourID, right, 15);
 
    return x.all;
  end WriteData;

  function SumPt(x, y : tData) return tData is
    variable z : tData := x;
  begin
    z.pt := x.pt + y.pt;
    return z;
  end SumPt;

  function "<" (left, right : tData) return boolean is
    variable ret : boolean := false;
  begin
      if to_integer(left.pt) < to_integer(right.pt) then
          ret := true;
      else
          ret := false;
      end if;
      return ret;
  end "<";
  
  function ">" (left, right : tData) return boolean is
    variable ret : boolean := false;
  begin
      if to_integer(left.pt) > to_integer(right.pt) then
          ret := true;
      else
          ret := false;
      end if;
      return ret;
  end ">";

end DataType;
