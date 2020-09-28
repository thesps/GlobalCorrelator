library ieee;
use ieee.std_logic_1164.all;

library HGCRouter;
use HGCRouter.DataType.all;
use HGCRouter.ArrayTypes.all;

library Utilities;
use Utilities.Debugging.all;

use work.Constants.all;

entity testbench is
end testbench;

architecture rtl of testbench is
    signal XRead : Vector(0 to N_LINKS_HGC_TOTAL-1) := NullVector(N_LINKS_HGC_TOTAL);
    signal X : Vector(0 to 17) := NullVector(18);
    signal Y: Vector(0 to 23) := NullVector(24);
    signal clk : std_logic := '0';
begin
    clk <= not clk after 2.5 ns;

    -- Global sim counter
    SimCounter:
    process(clk)
    begin
        if rising_edge(clk) then
            SimulationClockCounter <= SimulationClockCounter + 1;
        end if;
    end process;

    Input : entity work.SimulationInput
    port map(clk, XRead);

    X(0 to N_LINKS_HGC_TOTAL-1) <= XRead;

    UUT : entity HGCRouter.Router18to24
    port map(clk, X, Y);

    Output : entity work.SimulationOutput
    port map(clk, Y);

end architecture rtl;
