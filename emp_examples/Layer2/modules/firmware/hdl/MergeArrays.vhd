library ieee;
use ieee.std_logic_1164.all;

use work.DataType.all;
use work.ArrayTypes.all;

library Int;
use Int.DataType;
use Int.ArrayTypes;

entity MergeArrays is
generic(
  constant nMerge : integer := 2;
  constant nIn : integer := 128;
  constant nOut : integer := 128
);
port(
  clk : in std_logic := '0';
  D : in Matrix(0 to nMerge - 1)(0 to nIn - 1) := NullMatrix(nMerge, nIn);
  BaseIn : in Int.ArrayTypes.Vector(0 to nMerge - 1) := Int.ArrayTypes.NullVector(nMerge);
  Q : out Vector(0 to nOut - 1) := NullVector(nOut);
  BaseOut : out Int.DataType.tData := Int.DataType.cNull
);
end MergeArrays;

architecture behavioral of MergeArrays is
  constant nNext : integer := (nMerge + 1) / 2;
  signal qInt : Vector(0 to nOut - 1) := NullVector(nOut);

  component MergeArrays is
  generic(
    constant nMerge : integer := 2;
    constant nIn : integer := 128;
    constant nOut : integer := 128
  );
  port(
    clk : in std_logic := '0';
    D : in Matrix(0 to nMerge - 1)(0 to nIn - 1) := NullMatrix(nMerge, nIn);
    BaseIn : in Int.ArrayTypes.Vector(0 to nMerge - 1) := Int.ArrayTypes.NullVector(nMerge);
    Q : out Vector(0 to nOut - 1) := NullVector(nOut);
    BaseOut : out Int.DataType.tData := Int.DataType.cNull
  );
  end component MergeArrays;

begin

G1 : if nMerge = 1 generate
  Q <= D(0);
  BaseOut <= BaseIn(0);
end generate;

G2 : if nMerge = 2 generate
  Merge:
  for i in 0 to nOut - 1 generate
  begin
    process(clk)
    begin
      if rising_edge(clk) then
        if i < BaseIn(0).x then
          Q(i) <= D(0)(i);
        else
          Q(i) <= D(1)(i - BaseIn(0).x);
        end if;
      end if;
    end process;
  end generate;

  process(clk)
  begin
    if rising_edge(clk) then
      BaseOut.x <= BaseIn(0).x + BaseIn(1).x;    
      BaseOut.DataValid <= BaseIn(0).DataValid or BaseIn(1).DataValid;
      BaseOut.FrameValid <= BaseIn(0).FrameValid or BaseIn(1).FrameValid;
    end if;
  end process;
end generate;

GN : if nMerge > 2 generate
  signal qInt : Matrix(0 to nNext - 1)(0 to nOut - 1) := NullMatrix(nNext, nOut);
  signal BaseInt : Int.ArrayTypes.Vector(0 to nNext - 1) := Int.ArrayTypes.NullVector(nNext);
  begin
  -- Loop over pairs
  GNext:
  for i in 0 to nNext - 1 generate
    signal DPair : Matrix(0 to 1)(0 to nOut - 1) := NullMatrix(2, nOut);
    signal BasePair : Int.ArrayTypes.Vector(0 to 1) := Int.ArrayTypes.NullVector(2);
  begin
    DPair(0)(0 to nIn - 1) <= D(2*i); -- Assumes nIn < nOut
    BasePair(0) <= BaseIn(2*i);
    GEven:
    if 2*i+1 <= BaseIn'high generate
        DPair(1)(0 to nIn - 1) <= D(2*i+1); -- Assumms nIn < nOut
        BasePair(1) <= BaseIn(2*i+1);
    end generate;
    -- Otherwise the number of input is null and no merge happens

    -- Merge this pair    
    MergeNext : MergeArrays
    generic map(2, nOut, nOut)
    port map(clk, DPair, BasePair, qInt(i), BaseInt(i));
    
  end generate;

  -- Merge the merged pairs
  MergeRest : MergeArrays
  generic map(nNext, nOut, nOut)
  port map(clk, qInt, BaseInt, Q, BaseOut);

end generate;

end behavioral;
