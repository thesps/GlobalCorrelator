library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library Track;
use Track.DataType.all;
use Track.ArrayType.all;

entity TrackRouter is
port(
    clk : in std_logic;
    TrackPipeIn : in VectorPipe;
    TrackPipeOut : out VectorPipe
);

architecture Behavioral of TrackRouter is

    signal tracksRoutedPhi : VectorPipe;
    signal tracksRoutedPhiCounted : VectorPipe;
    signal tracksRoutedN : VectorPipe;

begin

    -- Group the tracks by phi
    PhiRouter : entity Track.RouterPhi
    port map(clk, TrackPipeIn, tracksRoutedPhi);

    -- Add the bookkeeping info
    BookKeepers : entity Track.TrackCounter
    port map(clk, tracksRoutedPhi, tracksRoutedPhiCounted);

    -- Group the tracks by bookkeeping info
    NRouter : entity Track.RouterN
    port map(clk, tracksRoutedPhiCounted, tracksRoutedN);

    TrackPipeOut <= tracksRoutedN;

    debug: entity Track.Debug
    generic map("TrackRouter")
    port map(clk, tracksRoutedN(0));

end Behavioral;
