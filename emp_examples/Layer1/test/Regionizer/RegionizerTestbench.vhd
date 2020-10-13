library ieee;
use ieee.std_logic_1164.all;

library HGCRouter;
use HGCRouter.DataType.all;
use HGCRouter.ArrayTypes.all;

library Bool;
use Bool.DataType;
use Bool.ArrayTypes;

library Utilities;
use Utilities.Debugging.all;

use work.Constants.all;

entity testbench is
end testbench;

architecture rtl of testbench is
    signal XRead : Vector(0 to N_LINKS_HGC_TOTAL-1) := NullVector(N_LINKS_HGC_TOTAL);
    signal X    : Vector(0 to 17) := NullVector(18);
    signal XDel : Vector(0 to 17) := NullVector(18);
    signal Y    : Vector(0 to 23) := NullVector(24);
    signal YReg : Vector(0 to 23) := NullVector(24);
    signal clk  : std_logic := '0';
    signal newEvent : Bool.ArrayTypes.Vector(0 to 31) := Bool.ArrayTypes.NullVector(32);
begin
    clk <= not clk after 5 ns;

    -- Global sim counter
    SimCounter:
    process(clk)
    begin
        if rising_edge(clk) then
            SimulationClockCounter <= SimulationClockCounter + 1;
            XDel <= X;
            -- 'new event' (for the accumulator) when the FrameValid goes _low_
            newEvent(0).x <= XDel(0).FrameValid and not X(0).FrameValid;
            -- Quick pipe
            newEvent(1 to 31) <= newEvent(0 to 30);
        end if;
    end process;

    Input : entity work.SimulationInput
    port map(clk, XRead);

    X(0 to N_LINKS_HGC_TOTAL-1) <= XRead;

    Router : entity HGCRouter.Router18to24
    port map(clk, X, Y);

    BufferInstance : entity HGCRouter.RegionBuffers
    port map(clk, newEvent(31).x, Y, YReg);

    Output : entity work.SimulationOutput
    port map(clk, YReg);

end architecture rtl;
