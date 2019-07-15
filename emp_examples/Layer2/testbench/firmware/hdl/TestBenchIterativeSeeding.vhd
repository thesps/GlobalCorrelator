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


-- .library VertexFinder
-- .include TopLevelInterfaces/mp7_data_types.vhd
-- .include ReuseableElements/PkgDebug.vhd
-- .include components/PkgConstants.vhd

-- .include testbench/DummyData.vhd
-- .include TestingAndDebugging/MP7CaptureFileReader.vhd

-- .include top/VertexFinderProcessor.vhd

-- -------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY Interfaces;
USE Interfaces.mp7_data_types.ALL;

LIBRARY Layer2;
USE Layer2.constants.ALL;
use Layer2.PkgIterativeSeeding.all;

library PFChargedObj;
use PFChargedObj.DataType.all;
use PFChargedObj.ArrayTypes.all;

LIBRARY Utilities;
USE Utilities.debugging.ALL;

library xil_defaultlib;
use xil_defaultlib.emp_device_decl.all;
-- -------------------------------------------------------------------------


-- -------------------------------------------------------------------------
ENTITY top IS
END top;
-- -------------------------------------------------------------------------


-- -------------------------------------------------------------------------
ARCHITECTURE rtl OF top IS

-- CLOCK SIGNALS
  SIGNAL clk                : STD_LOGIC            := '1';
  signal counter : integer range 0 to 65535 := 0;
  signal PFChargedObjBuffer : PFChargedObj.ArrayTypes.Matrix(0 to N_Parts_Per_Region_Group - 1)(0 to N_Region_Groups - 1) := PFChargedObj.ArrayTypes.NullMatrix(N_Parts_Per_Region_Group, N_Region_Groups);
  signal PFChargedObjIn : PFChargedObj.ArrayTypes.Vector(0 to N_Region_Groups - 1) := PFChargedObj.ArrayTypes.NullVector(N_Region_Groups);
  --signal Seeds : PFChargedObj.ArrayTypes.VectorPipe(0 to N_Seeds - 1) := PFChargedObj.ArrayTypes.NullVector(N_Seeds);


BEGIN

    clk <= NOT clk AFTER 1.39 ns;
    TBCounter:
    process(clk)
    begin
      if rising_edge(clk) then
        counter <= counter + 1;
      end if;
    end process;
    PFChargedObjBuffer(0)(0) <= (pt => to_signed(100, 16),
                                 eta => to_signed(0, 10),
                                 phi => to_signed(0, 10),
                                 id => to_unsigned(0, 3),
                                 z0 => to_signed(0, 10),
                                 DataValid => true,
                                 FrameValid => true,
                                 deltaR2 => (others => '0'),
                                 NeighbourID => 0);
    PFChargedObjBuffer(1)(0) <= (pt => to_signed(90, 16),
                                 eta => to_signed(2, 10),
                                 phi => to_signed(0, 10),
                                 id => to_unsigned(0, 3),
                                 z0 => to_signed(0, 10),
                                 DataValid => true,
                                 FrameValid => true,
                                 deltaR2 => (others => '0'),
                                 NeighbourID => 0);
    PFChargedObjBuffer(2)(0) <= (pt => to_signed(80, 16),
                                 eta => to_signed(511, 10),
                                 phi => to_signed(0, 10),
                                 id => to_unsigned(0, 3),
                                 z0 => to_signed(0, 10),
                                 DataValid => true,
                                 FrameValid => true,
                                 deltaR2 => (others => '0'),
                                 NeighbourID => 0);
    PFChargedObjBuffer(0)(1) <= (pt => to_signed(85, 16),
                                 eta => to_signed(511, 10),
                                 phi => to_signed(0, 10),
                                 id => to_unsigned(0, 3),
                                 z0 => to_signed(0, 10),
                                 DataValid => true,
                                 FrameValid => true,
                                 deltaR2 => (others => '0'),
                                 NeighbourID => 0);

    stim:
    process(clk)
    begin
        if rising_edge(clk) then
            if counter < 3 then
                PFChargedObjIn <= PFChargedObjBuffer(counter);
            else
                PFChargedObjIn <= PFChargedObj.ArrayTypes.NullVector(N_Region_Groups); 
            end if;
        end if;
    end process;


-- -------------------------------------------------------------------------
-- THE ALGORITHMS UNDER TEST
  Top : ENTITY work.IterativeSeeding
  PORT MAP(
    clk      => clk ,
    rst => '0',
    PFChargedObjIn => PFChargedObjIn
    --Seeds => Seeds
  );
-- -------------------------------------------------------------------------

END ARCHITECTURE rtl;
