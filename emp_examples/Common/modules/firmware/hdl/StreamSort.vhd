-- #########################################################################
-- #########################################################################
-- ###                                                                   ###
-- ###   Use of this code, whether in its current form or modified,      ###
-- ###   implies that you consent to the terms and conditions, namely:   ###
-- ###    - You acknowledge my contribution                              ###
-- ###    - This copyright notification remains intact                   ###
-- ###                                                                   ###
-- ###   Many thanks,                                                    ###
-- ###     Dr. Andrew W. Rose, Imperial College London, 2018             ###
-- ###                                                                   ###
-- #########################################################################
-- #########################################################################

-- -------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

USE work.ArrayTypes.ALL;
USE work.DataType.ALL;
-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
ENTITY StreamSort IS
  GENERIC(
    size : integer := 16
         );
  PORT(
    clk      : in std_logic := '0'; -- The algorithm clock
    rst       : in boolean := false;
    DataIn   : in tData := cNull;
    DataOut  : out Vector(0 to size - 1) := NullVector(size)
  );
END StreamSort;
-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
ARCHITECTURE rtl OF StreamSort IS
    signal DataInternal : Vector(0 to size) := NullVector(size+1);
    signal Accumulator : Vector(0 to size - 1) := NullVector(size);
BEGIN

  DataInternal(0) <= DataIn;

  GenPipe:
  for i in 0 to size - 1 generate
  begin
    process(clk)
    begin
      if rising_edge(clk) then
        if rst then
            Accumulator(i) <= cNull;
            DataInternal(i+1) <= cNull;
        elsif DataInternal(i) > Accumulator(i) then
          Accumulator(i) <= DataInternal(i);
          DataInternal(i+1) <= cNull;
        else
          Accumulator(i) <= Accumulator(i);
          DataInternal(i+1) <= DataInternal(i);
        end if;
      end if;
    end process; 
  end generate;

  DataOut <= Accumulator;

END ARCHITECTURE rtl;
