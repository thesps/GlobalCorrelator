library ieee;
use ieee.std_logic_1164.all;

library xil_defaultlib;
use xil_defaultlib.Constants.all;

use work.DataType.all;
use work.ArrayTypes.all;
use work.PkgFindIndexInRow.all;

library Int;
use Int.DataType;
use Int.ArrayTypes;

entity FindIndexInRow is
-- Supply N_LINKS & N_REGIONS as generics rather than from Constants so that the module can be tiled to meet timing for 
-- large N_LINKS
generic(
    N_LINKS : integer := N_LINKS_HGC_TOTAL;
    N_REGIONS : integer := N_REGIONS_PF
);
port(
    clk             : in std_logic := '0';
    DataIn          : in Vector;
    DataOut         : out Vector;
    IndexOut        : out Int.ArrayTypes.Vector;
    RegionIncrement : out Int.ArrayTypes.Vector
);
end FindIndexInRow;

architecture rtl of FindIndexInRow is
    signal newEvent : boolean := false;
    -- For pipelining the DataIn to DataOut
    --constant moduleLatency : integer := 3;
    signal DataInPipe : VectorPipe(0 to moduleLatency)(0 to N_LINKS-1) := NullVectorPipe(moduleLatency+1, N_LINKS);

    -- Expand the region flag on each link to a "one hot" (could become "n hot") matrix
    -- row is PF region; column is input link
    signal linkInRegion : Int.ArrayTypes.Matrix(0 to N_REGIONS-1)(0 to N_LINKS-1) := Int.ArrayTypes.NullMatrix(N_REGIONS, N_LINKS);
    -- Flattened version just for debug output
    signal linkInRegionFlat : Int.ArrayTypes.Vector(0 to (N_REGIONS * N_LINKS) - 1) := Int.ArrayTypes.NullVector(N_REGIONS * N_LINKS);

    -- To track the destination index within this row (clock) of input data
    signal indexInRow : Int.ArrayTypes.Vector(0 to N_LINKS-1) := Int.ArrayTypes.NullVector(N_LINKS);

    -- To track the number of new objects in this region
    signal regIncInt : Int.ArrayTypes.Vector(0 to N_REGIONS-1) := Int.ArrayTypes.NullVector(N_REGIONS); 
    signal regIncIntPipe : Int.ArrayTypes.VectorPipe(0 to moduleLatency)(0 to N_REGIONS-1) := Int.ArrayTypes.NullVectorPipe(moduleLatency+1, N_REGIONS); 

begin

    -- Expand the region flag on each link to a "one hot" (could become "n hot") vector
    GenRegionOneHotOuter:
    for i in 0 to N_REGIONS-1 generate
    begin
        GenRegionOneHotInner:
        for j in 0 to N_LINKS-1 generate
        begin
            Proc:
            process(clk)
            begin
                if rising_edge(clk) then
                    if DataIn(j).DataValid and DataIn(j).iRegion = i then
                        linkInRegion(i)(j) <= (1, true, true);
                    else
                        linkInRegion(i)(j) <= (0, true, true);
                    end if;
                end if;
            end process;
        end generate;
    end generate;

    -- First attempt, try to find the region index for each input in one clock
    -- Probably won't meet timing for large N_LINKS
    GenIndexInRow:
    for i in 0 to N_LINKS-1 generate
    begin
        Proc:
        process(clk)
            variable idx : Int.DataType.tData := (0, true, true);
            variable region : Int.ArrayTypes.Vector(0 TO N_LINKS-1) := Int.ArrayTypes.NullVector(N_LINKS);
        begin
            if rising_edge(clk) then
                idx := (0, DataInPipe(1)(i).DataValid, DataInPipe(1)(i).FrameValid);
                region := linkInRegion(DataInPipe(1)(i).iRegion);
                FindIndexInRow:
                for j in 0 to i-1 loop
                    idx.x := idx.x + region(j).x;
                end loop;
                indexInRow(i) <= idx;
            end if;
        end process;
    end generate;

    -- Sum the total links in the same region in this input row
    GenRegionIncrement:
    for i in 0 to N_REGIONS - 1 generate
    begin
        Proc:
        process(clk)
            variable regInc : Int.DataType.tData := (0, true, true);
        begin
            if rising_edge(clk) then
                regInc := (0, true, true);
                for j in 0 to N_LINKS - 1 loop
                    regInc.x := regInc.x + linkInRegion(i)(j).x;
                end loop;
            end if;
            regIncInt(i) <= regInc;
        end process;
    end generate;

    -- Pipeline DataIn to DataOut
    Pipe0 : entity work.DataPipe
    port map(clk, DataIn, DataInPipe);
    Pipe1 : entity Int.DataPipe
    port map(clk, regIncInt, regIncIntPipe);

    IndexOut <= indexInRow;
    RegionIncrement <= regIncIntPipe(2);
    DataOut <= DataInPipe(moduleLatency);

    -- Flatten the matrix to write to file
    GenMatFlatOuter:
    for i in 0 to N_REGIONS - 1 generate
    begin
        GenMatFlatInner:
        for j in 0 to N_LINKS - 1 generate 
        begin
            linkInRegionFlat(i * N_LINKS + j) <= linkInRegion(i)(j);
        end generate;
    end generate;

    -- Debug signals
    Debug0 : entity Int.Debug generic map("linkInRegion") port map(clk, linkInRegionFlat);
    Debug1 : entity Int.Debug generic map("indexInRow") port map(clk, indexInRow);
    Debug2 : entity Int.Debug generic map("regIncInt") port map(clk, regIncInt);
    Debug3 : entity work.Debug generic map("DataOut") port map(clk, DataOut);
end rtl;
