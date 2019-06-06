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
ENTITY ParallelToSerial IS
  PORT(
    clk      : IN STD_LOGIC := '0'; -- The algorithm clock
    WriteEnable       : in boolean := false;
    ReadEnable        : in boolean := false;
    DataIn   : IN Vector;
    DataOut  : OUT tData := cNull
  );
END ParallelToSerial;
-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
ARCHITECTURE rtl OF ParallelToSerial IS
    signal DataInternal : Vector(DataIn'Range) := NullVector(DataIn'Length);
BEGIN

  process(clk)
  begin
    if rising_edge(clk) then
      if WriteEnable then
        DataInternal <= DataIn;
      end if;
      if ReadEnable then
        DataOut <= DataInternal(0);
        DataInternal(0 to DataInternal'High - 1) <= DataInternal(1 to DataInternal'High);
      else
        DataOut <= cNull;
      end if;
    end if;
  end process; 

END ARCHITECTURE rtl;
