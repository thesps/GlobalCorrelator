library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library Simple;
use Simple.DataType.all;
use Simple.ArrayTypes.all;

library Int;
use Int.DataType;
use Int.ArrayTypes;

entity testbench is
end testbench;

architecture behavioral of testbench is
  constant nIn  : integer := 16;
  constant nOut : integer := 64;
  signal d : Vector(0 to nIn - 1) := NullVector(nIn);
  signal dM : Matrix(0 to 5)(0 to nIn - 1) := NullMatrix(6, nIn);
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
        for i in 0 to testCounter - startFrame loop
          d(i).pt <= to_unsigned(testCounter - startFrame, 64);
          d(i).FrameValid <= True;
          d(i).DataValid <= True;
        end loop;
        for i in testCounter - startFrame + 1 to nIn - 1 loop
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
  
  GD:
  for i in 0 to 5 generate 
    dM(i) <= d;
  end generate;


  uut : entity Simple.MergeArrays
  port map(clk, dM, q);

end behavioral;
