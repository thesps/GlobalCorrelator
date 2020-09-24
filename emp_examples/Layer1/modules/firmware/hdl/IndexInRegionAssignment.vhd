library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library xil_defaultlib;
use xil_defaultlib.Constants.all;

use work.DataType.all;
use work.ArrayTypes.all;

library Int;
use Int.DataType;
use Int.ArrayTypes;

entity IndexInRegionAssignment is
port(
    clk     : in std_logic := '0';
    DataIn  : in VectorPipe(0 to 0)(0 to N_LINKS_HGC_TOTAL - 1) := NullVectorPipe(1, N_LINKS_HGC_TOTAL);
    DataOut : out VectorPipe(0 to 0)(0 to N_LINKS_HGC_TOTAL - 1) := NullVectorPipe(1, N_LINKS_HGC_TOTAL)
);
end IndexInRegionAssignment;

architecture rtl of IndexInRegionAssignment is

    signal DataIdxFound : Vector(0 to N_LINKS_HGC_TOTAL - 1) := NullVector(N_LINKS_HGC_TOTAL);
    signal DataIdxFoundPipe : VectorPipe(0 to 1)(0 to N_LINKS_HGC_TOTAL - 1) := NullVectorPipe(2, N_LINKS_HGC_TOTAL);
    signal indexInRow : Int.ArrayTypes.Vector(0 to N_LINKS_HGC_TOTAL - 1)  := Int.ArrayTypes.NullVector(N_LINKS_HGC_TOTAL);
    signal regionIncrement : Int.ArrayTypes.Vector(0 to N_REGIONS_PF - 1) := Int.ArrayTypes.NullVector(N_REGIONS_PF);

    -- To track the base index of each region cumulatively over the event
    signal regionBase : Int.ArrayTypes.Vector(0 to N_REGIONS_PF-1) := Int.ArrayTypes.NullVector(N_REGIONS_PF);

    signal address : Int.ArrayTypes.Vector(0 to N_LINKS_HGC_TOTAL - 1) := Int.ArrayTypes.NullVector(N_LINKS_HGC_TOTAL);

    signal DataOutV : Vector(0 to N_LINKS_HGC_TOTAL - 1) := NullVector(N_LINKS_HGC_TOTAL);

begin

    -- First attempt, try to find the index in row of each input for all links in one cycle
    -- Probably won't meet timing
    FindIndex : entity work.FindIndexInRow
    generic map(
        N_LINKS => N_LINKS_HGC_TOTAL,
        N_REGIONS => N_REGIONS_PF
               )
    port map(
        clk => clk,
        DataIn => DataIn(0),
        DataOut => DataIdxFound,
        IndexOut => indexInRow,
        RegionIncrement => regionIncrement
    );

    -- Add the event accumulated address offset to the row-local address
    GenAddr:
    for i in 0 to N_LINKS_HGC_TOTAL - 1 generate
    begin
        Proc:
        process(clk)
        begin
            if rising_edge(clk) then
                address(i).x <= regionBase(DataIdxFound(i).iRegion).x + indexInRow(i).x;
            end if;

        end process;
    end generate;

    -- Update the event accumulated offset
    GenUpdateBase:
    for i in 0 to N_REGIONS_PF - 1 generate
    begin
        Proc:
        process(clk)
        begin
            if rising_edge(clk) then
                -- Inter event reset
                if not DataIdxFound(0).FrameValid then
                    regionBase(i) <= (0, false, false);
                else
                    regionBase(i) <= (regionBase(i).x + regionIncrement(i).x, true, false);
                end if;
            end if;
        end process;
    end generate;

    -- Output
    GenOut:
    for i in 0 to N_LINKS_HGC_TOTAL - 1 generate
    begin
        DataOutV(i).data <= DataIdxFoundPipe(1)(i).data;
        DataOutV(i).DataValid <= DataIdxFoundPipe(1)(i).DataValid;
        DataOutV(i).FrameValid <= DataIdxFoundPipe(1)(i).FrameValid;
        DataOutV(i).iRegion <= DataIdxFoundPipe(1)(i).iRegion;
        DataOutV(i).addr <= to_unsigned(address(i).x, DataOutV(i).addr'length);
        DataOutV(i).iInRegion <= address(i).x; 
    end generate;

    -- Pipes
    Pipe0 : entity work.DataPipe port map(clk, DataIdxFound, DataIdxFoundPipe);
    Pipe1 : entity work.DataPipe port map(clk, DataOutV, DataOut);

    -- Debugging
    Debug0 : entity Int.Debug generic map("regionBase") port map(clk, regionBase);
    Debug1 : entity Int.Debug generic map("address") port map(clk, address);
    Debug2 : entity work.Debug generic map("DataOut") port map(clk, DataOutV);
end rtl;
