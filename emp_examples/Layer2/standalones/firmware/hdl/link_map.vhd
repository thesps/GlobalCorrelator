library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library IO;
use IO.DataType;
use IO.ArrayTypes;

use work.emp_data_types.all;
use work.emp_project_decl.all;

use work.emp_device_decl.all;

-- Map links to regions such that each group originates from the same SLR
-- Using the map of https://gitlab.cern.ch/p2-xware/firmware/emp-fwk/blob/task/board-datapath-region-diagrams/boards/vcu118/regions.md
entity link_map is
	port(
		clk: in std_logic; -- ipbus signals
		d: in ldata(4 * N_REGION - 1 downto 0); -- data in
        q: out IO.ArrayTypes.Matrix(0 to 5)(0 to 15) := IO.ArrayTypes.NullMatrix(6, 16)
	);
end link_map;

architecture rtl of link_map is
	
    signal dVIO : IO.ArrayTypes.Vector(0 to 4 * N_REGION - 1) := IO.ArrayTypes.NullVector(4 * N_REGION);
    signal dPIO : IO.ArrayTypes.VectorPipe(0 to 4)(0 to 4 * N_REGION - 1) := IO.ArrayTypes.NullVectorPipe(5, 4 * N_REGION);
    signal qInt : IO.ArrayTypes.Matrix(0 to 5)(0 to 15) := IO.ArrayTypes.NullMatrix(6, 16);

begin

    InputCast:
    for i in 0 to 4 * N_REGION - 1 generate
        dVIO(i).data       <= d(i).data;
        dVIO(i).DataValid  <= true when d(i).data(63) = '1' else false; -- Use the top bit
        dVIO(i).FrameValid <= true when d(i).valid = '1' else false;
    end generate;

    Pipe : entity IO.DataPipe
    port map(clk, dVIO, dPIO);

    -- Regions 0 - 3 (4 regions) are in SLR0
    -- Other regions are in groups of 5 per-side-of-SLR
    -- Final group is a group of 4 in SLR0
    --Q0:
    --for i in 0 to 15 generate
    --    qInt(0)(i) <= dPIO(4)(i);
    --end generate;

    --Q1to5:
    --for i in 0 to 4 generate
    --    QJ:
    --    for j in 0 to 15 generate
    --        qInt(i+1)(j) <= dPIO(4)(20 * i + j + 16);
    --    end generate;
    --end generate;

    Gi:
    for i in 0 to 5 generate
        Gj:
        for j in 0 to 15 generate
        begin
            qInt(i)(j) <= dPIO(4)(16*i + j);
        end generate;
    end generate;


    -- Map to the Merge inputs such that the first layer of merging uses
    -- inputs in the same SLR
    q(0) <= qInt(0);
    q(1) <= qInt(5);
    q(2) <= qInt(1);
    q(3) <= qInt(4);
    q(4) <= qInt(2);
    q(5) <= qInt(3);

    Debug : entity IO.Debug
    generic map("Regionizer-Inputs", "./")
    port map(clk, dVIO);
end rtl;
