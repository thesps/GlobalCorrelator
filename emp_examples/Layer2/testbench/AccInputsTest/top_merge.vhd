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
  q : out Vector(0 to 127) := NullVector(128)
);
end top;

architecture behavioral of top is
  constant nIn  : integer := 16;
  constant nOut : integer := 128;

  attribute keep_hierarchy : string;
  attribute keep_hierarchy of Merge : label is "yes";
begin

  Merge : entity Simple.MergeAccumulateInputRegions
  generic map(6, nIn, nOut)
  port map(clk, d, q);

end behavioral;
