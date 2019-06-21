library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library Track;
use Track.DataType.all;
use Track.ArrayType.all;

---
--- 6 * (3 -> 5) -> 5 * (6 -> 5)
---
entity TrackRouterN is
port(
    clk : in std_logic;
    TrackPipeIn : in VectorPipe;
    TrackPipeOut : out VectorPipe
);

architecture Behavioral of TrackRouterN is

    signal l0o_grp : Vector(0 to 17) := NulLVector(18);

    signal l1i_grp : Matrix(0 to 5)(0 to 2) := NullMatrix(6, 3);
    signal l1o_grp : Matrix(0 to 5)(0 to 4) := NullMatrix(6, 5);

    signal l2i_grp : Matrix(0 to 4)(0 to 5) := NullMatrix(5, 6);
    signal l2o_grp : Matrix(0 to 4)(0 to 4) := NullMatrix(5, 5);

    signal output : Vector(0 to 17) := NullVector(18);

begin

    for i in 0 to 17 generate
        l0o_grp(i) <= TrackPipeIn(0)(i);
        l0o_grp(i).SortKey <= TrackPipeIn(0)(i).Keys(0);
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
        for j in 0 to 4 generate
            l2i_grp(j)(i) <= l1o_grp(i)(j);
            l2i_grp(j)(i).SortKey <= l1o_grp(i)(j).Keys(1)
        end generate;
    end generate;

    RouteLayer1:
    for i in 0 to 4 generate
        RouteNode : entity Track.DistributionServer
        port map(clk => clk, DataIn => l2i_grp(i), DataOut => l2o_grp(i));
    end generate;

    EndGroup:
    for i in 0 to 4 generate
        for j in 0 to 4 generate
            output(5 * i + j) <= l2o_grp(i)(j);
        end generate;
    end generate;

    OutputPipe : entity Track.DataPipe
    port map(clk, output, TrackPipeOut);

    debug: entity Track.Debug
    generic map("TrackRouterN")
    port map(clk, output);



end Behavioral;
