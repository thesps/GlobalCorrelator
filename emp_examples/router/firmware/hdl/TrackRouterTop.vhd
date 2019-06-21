-- Top Level with only router

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Use the Interfaces.mp7_data_types for simulation
-- Use emp_data_types for synthesis
-- synthesis translate_off
LIBRARY Interfaces;
USE Interfaces.mp7_data_types.ALL;
-- synthesis translate_on
-- synthesis read_comments_as_HDL on
--library xil_defaultlib;
--use xil_defaultlib.emp_data_types.all;
-- synthesis read_comments_as_HDL off
use work.emp_device_decl.all;
use work.mp7_ttc_decl.all;

use work.correlator_constants.all;

library Track;
use Track.DataType;
use Track.ArrayTypes;

entity RouterTop is
port(
    clk : in std_logic;
    LinksIn : in ldata(71 downto 0) := (others => lword_null);
    LinksOut : out ldata(71 downto 0) := (others => lword_null);
    -- To prevent the logic being synthesised away for standalone testing
    DebuggingOutput : out Track.ArrayTypes.Vector(0 to 24) := Vertex.ArrayTypes.NullVector(25)
    );
end RouterTop;

architecture rtl of RouterTop is

    subtype tTracksInPipe is Track.ArrayTypes.VectorPipe(0 to 9)(0 to 17);
    signal tracksIn : tTracksInPipe := Track.ArrayTypes.NullVectorPipe(10, 18);

    subtype tTracksRoutedPipe is Track.ArrayTypes.VectorPipe(0 to 9)(0 to 24);
    signal tracksRouted : tTracksRoutedPipe := Track.ArrayTypes.NullVectorPipe(10, 25);

begin

   InputDecode : entity work.linkToTrack
   port map(clk, d(17 downto 0), tracksIn);
   
   RouteTracks : entity Track.TrackRouter
   port map(clk, tracksIn, tracksRouted);

   DebuggingOutput <= tracksRouted(0);
end rtl;
