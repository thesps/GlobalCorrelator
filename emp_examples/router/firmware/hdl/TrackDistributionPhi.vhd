library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library Track;
use Track.DataType.all;
use Track.ArrayType.all;

entity TrackRouterPhi is
port(
    clk : in std_logic;
    TrackPipeIn : in VectorPipe;
    TrackPipeOut : out VectorPipe
);

architecture Behavioral of TrackRouterPhi is

    signal l0o_grp : Vector(0 to 17) := NulLVector(18);

    signal l1i_grp : Matrix(0 to 5)(0 to 2) := NullMatrix(6, 3);
    signal l1o_grp : Matrix(0 to 5)(0 to 2) := NullMatrix(6, 3);

    signal l2i_grp : Matrix(0 to 5)(0 to 2) := NullMatrix(6, 3);
    signal l2o_grp : Matrix(0 to 5)(0 to 2) := NullMatrix(6, 3);

    signal output : Vector(0 to 17) := NullVector(18);

begin

    -- Fanout the 9 incoming tracks to 18
    -- input 0 can go to output 0 and 9, input 1 can go to output 1 and 10, etc
    Fanout:
    for i in 0 to 8 generate
        process(clk)
            variable track0 : tData := cNull;
            variable track1 : tData := cNull;
        begin
            if rising_edge(clk) then
                -- TODO allow duplication
                if TrackPipeIn(0)(i).SortKey = 0 then
                   track0 := TrackPipeIn(0)(i);
                   track0.SortKey := TrackPipeIn(0)(i).Keys(1);
                end if;
                if TrackPipeIn(0)(i).SortKey = 1 then
                   track1 := TrackPipeIn(0)(i);
                   track1.SortKey := TrackPipeIn(0)(i).Keys(1);
                end if;
                l0o_grp(i) <= track0;
                l0o_grp(i + 9) <= track1;
            end if;
        end process;
    end generate;

    GroupInput:
    for i in 0 to 17 generate
        l1i_grp(i / 3)(i % 3) <= l0o_grp(i);        
    end generate;

    RouteLayer0:
    for i in 0 to 5 generate
        RouteNode : entity Track.DistributionServer
        port map(clk => clk, DataIn => l1i_grp(i), DataOut =>  l1o_grp(i));
    end generate;

    -- Regroup the signals ready for the next layer
    ReGroup:
    for i in 0 to 5 generate
        for j in 0 to 2 generate
            l2i_grp(3 * (i / 3) + j)(i % 3) <= l1o_grp(i)(j);
            l2i_grp(3 * (i / 3) + j)(i % 3).SortKey <= l1o_grp(i)(j).Keys(2)
        end generate;
    end generate;

    RouteLayer1:
    for i in 0 to 5 generate
        RouteNode : entity Track.DistributionServer
        port map(clk => clk, DataIn => l2i_grp(i), DataOut => l2o_grp(i));
    end generate;

    EndGroup:
    for i in 0 to 5 generate
        for j in 0 to 2 generate
            output(3 * i + j) <= l2o_grp(i)(j);
        end generate;
    end generate;

    OutputPipe : entity Track.DataPipe
    port map(clk, output, TrackPipeOut);

    debug: entity Track.Debug
    generic map("TrackRouterPhi")
    port map(clk, output);



end Behavioral;
