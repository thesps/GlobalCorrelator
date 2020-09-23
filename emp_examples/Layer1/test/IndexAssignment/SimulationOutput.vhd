library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

library HGCRouter;
use HGCRouter.DataType.all;
use HGCRouter.ArrayTypes.all;

library Int;
use Int.DataType;
use Int.ArrayTypes;

library Bool;
use Bool.DataType;
use Bool.ArrayTypes;

library Utilities;
use Utilities.Utilities.all;

use work.Constants.all;

entity SimulationOutput is
  generic(
    FileName : string := "./SimulationOutput.txt";
    FilePath : string := "./"
  );
  port(
    clk : in std_logic;
    X   : in Vector(0 to N_LINKS_HGC_TOTAL-1) := NullVector(N_LINKS_HGC_TOTAL)
  );
end SimulationOutput;
-- -------------------------------------------------------------------------
-- -------------------------------------------------------------------------
architecture rtl of SimulationOutput is

begin
-- pragma synthesis_off
  process(clk)
    file f     : text open read_mode is FilePath & FileName;
    variable s : line;
  begin
  if rising_edge(clk) then
      for i in  X'range loop
        write(s, to_integer(unsigned(X(i).data)), right, 10);
        write(s, string'(","), right, 1);
        write(s, to_integer(X(i).addr), right, 10);
        write(s, string'(","), right, 1);
        write(s, X(i).DataValid, right, 10);
        write(s, string'(","), right, 1);
        write(s, X(i).FrameValid, right, 10);
        write(s, string'(","), right, 1);
        write(s, X(i).iRegion, right, 10);
        write(s, string'(";"), right, 1);
      end loop;
      writeline(f, s);
  end if;
  end process;
-- pragma synthesis_on    
end architecture rtl;
