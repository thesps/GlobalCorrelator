library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library Simple;
use Simple.DataType.all;
use Simple.ArrayTypes.all;

entity testbench is
end testbench;

architecture behavioral of testbench is
  constant nIn  : integer := 16;
  constant nOut : integer := 64;
  signal d : Vector(0 to nIn - 1) := NullVector(nIn);
  signal q : Vector(0 to nOut - 1) := NullVector(nOut);

  constant startFrame : integer := 2;
  constant nFrames : integer := 5;
  signal testCounter : integer := 0;
  signal clk : std_logic := '0';

begin

  clk <= not clk after 2 ns;

  process(clk)
  begin
    if rising_edge(clk) then
      testCounter <= testCounter + 1;
    end if;
  end process;

  GenInputs:
  process(clk)
  begin
    if rising_edge(clk) then
      if testCounter > startFrame and testCounter < (nFrames + startFrame) then
        for i in 0 to 0 loop --testCounter - startFrame loop
          d(i).pt <= to_unsigned(testCounter - startFrame, 64);
          d(i).FrameValid <= True;
          d(i).DataValid <= True;
        end loop;
        for i in 1 to nIn - 1 loop --testCounter - startFrame + 1 to nIn - 1 loop
          d(i).pt <= (others => '0');
          d(i).FrameValid <= True;
          d(i).DataValid <= False;
        end loop;        
      else
        for i in 0 to nIn - 1 loop
          d(i) <= cNull;
        end loop;
      end if;
    end if;
  end process;
  --GenInputs:
  --for i in 0 to nIn - 1 generate
  --process(clk)
  --begin
  --  if rising_edge(clk) then
  --    if testCounter > startFrame and testCounter < nFrames + startFrame then
  --      for j in 0 to testCounter - startFrame loop
  --        d(i).pt <= to_unsigned(to_integer(d(i).pt) + 1, 16);
  --        d(i).FrameValid <= True;
  --        d(i).DataValid <= True;
  --      end loop;
  --    else
  --      d(i).FrameValid <= False;
  --      d(i).DataValid <= False;
  --    end if;
  -- end if;
  --end process;
  --end generate;

  uut : entity Simple.AccumulateInputs
  generic map(nIn, nOut)
  port map(clk, d, q);

end behavioral;
