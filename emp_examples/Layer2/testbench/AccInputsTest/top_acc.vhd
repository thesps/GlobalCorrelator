library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library Simple;
use Simple.DataType.all;
use Simple.ArrayTypes.all;

library Int;
use Int.DataType;

entity top is
port(
  clk : in std_logic := '0';
  d : in Vector(0 to 15) := NullVector(16);
  q : out Vector(0 to 63) := NullVector(64)
);
end top;

architecture behavioral of top is
  constant nIn  : integer := 16;
  constant nOut : integer := 64;
begin

  Merge : entity Simple.AccumulateInputs
  generic map(nIn, nOut)
  port map(clk, d, q);

end behavioral;
