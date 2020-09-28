-- Router of 18 inputs to 32 outputs
-- First stage is 6 x (3 -> 4)
-- Second stage is 4 * (6 -> 8);

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.DataType.all;
use work.ArrayTypes.all;

entity Router18to24 is
port(
    clk : in std_logic := '0';
    D : in Vector;
    Q : out Vector
);
end Router18to24;

architecture rtl of Router18to24 is

    signal layer0_in : Matrix(0 to 5)(0 to 2) := NullMatrix(6, 3);
    signal layer0_out : Matrix(0 to 5)(0 to 3) := NullMatrix(6, 4);

    signal layer1_in : Matrix(0 to 3)(0 to 5) := NullMatrix(4, 6);
    signal layer1_out : Matrix(0 to 3)(0 to 7) := NullMatrix(4, 8);

    function LocalAddrLayer0(data : tData) return integer is
        variable local : integer := 0;
    begin
        local := to_integer(data.addr(1 downto 0));
        return local;
    end function;

    function LocalAddrLayer1(data : tData) return integer is
        variable local : integer := 0;
    begin
        local := to_integer(data.addr(4 downto 2));
        return local;
    end function;

begin

    -- Group the module inputs into groups for the router Layer 0
    -- Use the lowest 2 bits for the SortKey
    GrpInput:
    for i in 0 to 17 generate
        signal d_keyed : tData := cNull;
    begin
        --d_keyed.data <= D(i).data;
        --d_keyed.addr <= D(i).addr;
        --d_keyed.DataValid <= D(i).DataValid;
        --d_keyed.FrameValid <= D(i).FrameValid;
        --d_keyed.SortKey <= to_integer(D(i).addr(1 downto 0));
        --layer0_in(i / 3)(i mod 3) <= d_keyed;
        layer0_in(i / 3)(i mod 3) <= D(i);
    end generate;

    -- The Layer 0 routing
    RouteLayer0:
    for i in 0 to 5 generate
        Node : entity work.DistributionServer generic map(LocalAddrLayer0) port map(clk, layer0_in(i), layer0_out(i));
    end generate;

    -- Connect the output of Layer 0 to input of Layer 1
    -- Use the highest 3 bits of addr for the SortKey
    ConnectLayersOuter:
    for i in 0 to 5 generate
        ConnectLayersInner:
        for j in 0 to 3 generate
            signal d_keyed : tData := cNull; --layer0_out(i)(j);
        begin
            --d_keyed <= layer0_out(i)(j);
            --d_keyed.data <= layer0_out(i)(j).data;
            --d_keyed.addr <= layer0_out(i)(j).addr;
            --d_keyed.DataValid <= layer0_out(i)(j).DataValid;
            --d_keyed.FrameValid <= layer0_out(i)(j).FrameValid;
            --d_keyed.SortKey <= to_integer(layer0_out(i)(j).addr(4 downto 2));
            --layer1_in(j)(i) <= d_keyed;
            layer1_in(j)(i) <= layer0_out(i)(j);
        end generate;
    end generate;

    -- The Layer 1 routing
    RouteLayer1:
    for i in 0 to 3 generate
        Node : entity work.DistributionServer generic map(LocalAddrLayer1) port map (clk, layer1_in(i), layer1_out(i));
    end generate;

    ConnectOutput:
    for i in 0 to 23 generate
        Q(i) <= layer1_out(i / 8)(i mod 8);
    end generate;

    Debug0 : entity work.Debug generic map("RouterD") port map(clk, D);
    Debug1 : entity work.Debug generic map("RouterQ") port map(clk, Q);
end rtl;
