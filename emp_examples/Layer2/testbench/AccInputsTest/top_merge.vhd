library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library Simple;
use Simple.DataType.all;
use Simple.ArrayTypes.all;

entity top is
port(
  clk : in std_logic := '0';
  d : in Matrix(0 to 5)(0 to 15) := NullMatrix(6, 16);
  q : out Vector(0 to 63) := NullVector(64)
);
end top;

architecture behavioral of top is
  constant nIn  : integer := 16;
  constant nOut : integer := 128;

  signal d_merged : Vector(0 to 63) := NullVector(64);

  attribute keep_hierarchy : string;
  attribute keep_hierarchy of Merge : label is "yes";

begin

  Merge : entity Simple.MergeArrays
  port map(clk, d, d_merged);

  Acc : entity Simple.AccumulateInputs
  port map(clk, d_merged, q);

end behavioral;
