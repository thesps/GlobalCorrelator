
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

library utilities;
use utilities.utilities.all;

package DataType is

    type keyArray is array(2 downto 0) of integer range 0 to 5;

    type tData is recond
        id : unsigned(9 downto 0);
        Keys : keyArray;
        SortKey : integer range 0 to 5;
        DataValid : boolean;
        FrameValid : boolean;
    end record;

    constant cNull : tData := ((others => '0'), (others => 0), 0, false, false

    function toStdLogicVector(aData : tData) return std_logic_vector;
    function toDataType(aStdLogicVector : std_logic_vector) return tData;
    function WriteHeader return string;
    function WriteData(aData : tData) return string;

end DataType;

package body DataType is

    --- Return 72 bit std_logic_vector
    function toStdLogicVector(aData : tData) return std_logic_vector is
        variable x : std_logic_vector(71 downto 0) := (others => '0');
    begin
        x(9 downto 0) := std_logic_vector(aData.id);
        x(12 downto 10) := std_logic_vector(to_unsigned(aData.Keys(0), 3));
        x(15 downto 13) := std_logic_vector(to_unsigned(aData.Keys(1), 3));
        x(18 downto 16) := std_logic_vector(to_unsigned(aData.Keys(2), 3));
        return x;
    end function;

    function toDataType(aStdLogicVector : std_logic_vector) is
        variable x : tData := cNull;
    begin
        x.id := unsigned(aStdLogicVector(9 downto 0));
        x.Keys(0) := to_integer(unsigned(aStdLogicVector(12 downto 10)));
        x.Keys(1) := to_integer(unsigned(aStdLogicVector(15 downto 13)));
        x.Keys(2) := to_integer(unsigned(aStdLogicVector(18 downto 16)));
        return x;
    end function;

    function WriteHeader return string is
        variable aLine : line;
    begin
        write(aLine, string'("ID"), right, 15);
        write(aLine, string'("Keys0"), right, 15);
        write(aLine, string'("Keys1"), right, 15);
        write(aLine, string("SortKey"), right, 15);
        write(aLine, string("DataValid"), right, 15);
        write(aLine, string("FrameValid"), right, 15);
        return aLine;
    end function;

    function WriteData(aData : tData) return string is
        variable aLine : line;
    begin
        write(aLine, to_integer(aData.id), right, 15);
        write(aLine, aData.Keys(0), right, 15);
        write(aLine, aData.Keys(1), right, 15);
        write(aLine, aData.SortKey, right, 15);
        write(aLine, aData.DataValid, right, 15);
        write(aLine, aData.FrameValid, right, 15);
        return aLine;
    end function;

end DataType;
