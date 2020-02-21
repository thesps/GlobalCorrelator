library ieee;
use ieee.std_logic_1164.all;

use work.DataType.all;
use work.ArrayTypes.all;

library Int;
use Int.DataType;

entity AccumulateInputs is
generic(
  constant nIn : integer := 16;
  constant nOut : integer := 128
);
port(
  clk : in std_logic := '0';
  d : in Vector(0 to nIn - 1) := NullVector(nIn);
  q : out Vector(0 to nOut - 1) := NullVector(nOut);
  iMax : out Int.DataType.tData := Int.DataType.cNull
);
end AccumulateInputs;

architecture behavioral of AccumulateInputs is
  signal qInt : Vector(0 to nOut - 1) := NullVector(nOut);
  signal dPipe : VectorPipe(0 to 1)(0 to nIn - 1) := NullVectorPipe(2, nIn);
  -- Check this doesnt mess up last region
  --signal base : integer range 0 to nOut - nIn - 1:= 0;
  signal base : integer range 0 to 511 := 0;
begin

  dPipe(0) <= d;
  IncrementBasePointer:
  process(clk)
    variable baseInc : integer := 0;
  begin
    baseInc := 0;
    if rising_edge(clk) then
      dPipe(1) <= dPipe(0);
      for i in 0 to nIn-1 loop
        if not d(i).DataValid then
          exit;
        end if;
        baseInc := baseInc + 1;
      end loop;
      base <= base + baseInc;
    end if;
  end process;
  
  GCopy:
  for i in 0 to nOut - 1 generate
    signal b : integer := 0;
  begin
    b <= i - base;
    process(clk)
    begin
      if rising_edge(clk) then
        if b >= 0 and b < nIn then
          qInt(i) <= d(b);
        end if;
      end if;
    end process;
  end generate;

  -- At end of TM Period, copy internal reg to output
  OutProc:
  process(clk)
  begin
    if rising_edge(clk) then
      if not dPipe(0)(0).FrameValid and dPipe(1)(0).FrameValid then
        q <= qInt;
        iMax.x <= base;
        iMax.DataValid <= True;
        iMax.FrameValid <= True;
      end if;
    end if;
  end process;

-- synthesis translate_off
DebugInstance0 : entity work.Debug
generic map(FileName => "AccumulateInputs_d")
port map(clk, d);

DebugInstance1 : entity work.Debug
generic map(FileName => "AccumulateInputs_q")
port map(clk, q);
-- synthesis translate_on
end behavioral;
