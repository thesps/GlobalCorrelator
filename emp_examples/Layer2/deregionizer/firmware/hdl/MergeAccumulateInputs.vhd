library ieee;
use ieee.std_logic_1164.all;

use work.DataType.all;
use work.ArrayTypes.all;

library Int;
use Int.DataType;
use Int.ArrayTypes;

entity MergeAccumulateInputRegions is
port(
    clk : in std_logic := '0';
    RegionStreams : in Matrix(0 to 5)(0 to 15) := NullMatrix(6, 16);
    EventParticles : out Vector(0 to 127) := NullVector(128);
    HLSstart : out std_logic := '0';
    -- Just for sending debug data out for standalone deregionizer testing
    -- Leave unconnected for deregionizer + algorithm designs
    DebugLayer1 : out Vector(0 to 31) := NullVector(32);
    DebugLayer2 : out Vector(0 to 63) := NullVector(64);
    DebugMerged : out Vector(0 to 63) := NullVector(64)
);
end MergeAccumulateInputRegions;

architecture rtl of MergeAccumulateInputRegions is

    signal RegionsMerged      : Vector(0 to 63) := NullVector(64);
    signal RegionsMergedPiped : VectorPipe(0 to 4)(0 to 63) := NullVectorPipe(5, 64);
    signal EventParticlesInt  : Vector(0 to 127) := NulLVector(128);
    signal EventParticlesPipe : VectorPipe(0 to 3)(0 to 127) := NullVectorPipe(4, 128);

    attribute keep_hierarchy : string;
    attribute keep_hierarchy of Merge : label is "yes";
    attribute keep_hierarchy of Accumulate : label is "yes";

begin

    Merge : entity work.MergeArrays
    port map(clk, RegionStreams, RegionsMerged, DebugLayer1, DebugLayer2);

    MPipe : entity work.DataPipe
    port map(clk, RegionsMerged, RegionsMergedPiped);

    Accumulate : entity work.AccumulateInputs
    port map(clk, RegionsMergedPiped(4), EventParticlesInt);

    QPipe : entity work.DataPipe
    port map(clk, EventParticlesInt, EventParticlesPipe);

    --EventParticles <= EventParticlesPipe(3);

    StartSigProc:
    process(clk)
    begin
        if rising_edge(clk) then
            if not EventParticlesPipe(0)(0).FrameValid and EventParticlesPipe(1)(0).FrameValid then
                HLSstart <= '1';
            else
                HLSstart <= '0';
            end if;
        end if;
    end process;

    GenOutput:
    for i in 0 to 127 generate
    begin
        Proc:
        process(clk)
        begin
            if rising_edge(clk) then
                EventParticles(i).data <= EventParticlesPipe(2)(i).data;
                EventParticles(i).DataValid <= EventParticlesPipe(2)(i).DataValid and (not EventParticlesPipe(1)(i).FrameValid and EventParticlesPipe(2)(i).FrameValid);
                EventParticles(i).FrameValid <= EventParticlesPipe(2)(i).FrameValid;
            end if;
        end process;
    end generate;

    Debug : entity work.Debug
    generic map("Regionizer-EventParticles", "./")
    port map(clk, EventParticles);

    DebugMerged <= RegionsMerged;

end rtl;

