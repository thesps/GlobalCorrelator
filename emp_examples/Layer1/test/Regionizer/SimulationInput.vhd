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

use work.Constants.all;

entity SimulationInput is
  generic(
    FileName : string := "./SimulationInput.txt";
    FilePath : string := "./"
  );
  port(
    clk    : in std_logic;
    Q : out Vector
  );
end SimulationInput;
-- -------------------------------------------------------------------------
-- -------------------------------------------------------------------------
architecture rtl of SimulationInput is

  type tIntArray is array(integer range <>) of integer;

begin
-- pragma synthesis_off
  process(clk)
    file f     : text open read_mode is FilePath & FileName;
    variable s : line;
    --variable x : Vector(Q'left to Q'right) := Vector(Q'length);
    variable dataRead : Int.ArrayTypes.Vector(Q'left to Q'right) := Int.ArrayTypes.NullVector(Q'length);
    variable addrRead : Int.ArrayTypes.Vector(Q'left to Q'right) := Int.ArrayTypes.NullVector(Q'length);
    variable dataValidRead : Bool.ArrayTypes.Vector(Q'left to Q'right) := Bool.ArrayTypes.NullVector(Q'length);
    variable frameValidRead : Bool.ArrayTypes.Vector(Q'left to Q'right) := Bool.ArrayTypes.NullVector(Q'length);
    variable iRegionRead : Int.ArrayTypes.Vector(Q'left to Q'right) := Int.ArrayTypes.NullVector(Q'length);
    variable delim : character;
  begin
  if rising_edge(clk) then
    if(not endfile(f)) then
      readline(f, s); 
      for i in  Q'range loop
        read(s, dataRead(i).x);
        read(s, delim);
        read(s, addrRead(i).x);
        read(s, delim);
        read(s, dataValidRead(i).x);
        read(s, delim);
        read(s, frameValidRead(i).x);
        read(s, delim);
        read(s, iRegionRead(i).x);
        -- don't read the delimiter
        Q(i).data <= std_logic_vector(to_unsigned(dataRead(i).x, Q(i).data'length));
        Q(i).addr <= to_unsigned(addrRead(i).x, Q(i).addr'length);
        Q(i).DataValid <= dataValidRead(i).x;
        Q(i).FrameValid <= frameValidRead(i).x;
        Q(i).iRegion <= iRegionRead(i).x;
        if i /= Q'right then
          read(s, delim);
        end if;
      end loop;
    else
      for i in Q'range loop
        Q(i) <= cNull;
      end loop;
    end if;
  end if;
  end process;
-- pragma synthesis_on    
end architecture rtl;
