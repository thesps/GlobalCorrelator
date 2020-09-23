library ieee;
use ieee.std_logic_1164.all;

library HGCRouter;
use HGCRouter.DataType.all;
use HGCRouter.ArrayTypes.all;

use work.Constants.all;

entity testbench is
end testbench;

architecture rtl of testbench is
    signal X : VectorPipe(0 to 0)(0 to N_LINKS_HGC_TOTAL-1) := NullVectorPipe(1, N_LINKS_HGC_TOTAL);
    signal Y : VectorPipe(0 to 0)(0 to N_LINKS_HGC_TOTAL-1) := NullVectorPipe(1, N_LINKS_HGC_TOTAL);
    signal clk : std_logic := '0';
begin
    clk <= not clk after 2.5 ns;

    Input : entity work.SimulationInput
    port map(clk, X(0));

    UUT : entity HGCRouter.IndexInRegionAssignment
    port map(clk, X, Y);

    Output : entity work.SimulationOutput
    port map(clk, Y(0));

end architecture rtl;
