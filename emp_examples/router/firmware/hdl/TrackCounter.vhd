library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library Track;
use Track.DataType.all;
use Track.ArrayTypes.all;

entity TrackCounter is
port(
    clk : in std_logic;
    TrackPipeIn : in VectorPipe;
    TrackPipeOut : out VectorPipe
);
end TrackCounter;

architecture Behavioral of TrackCounter is

    -- Define array of 8-bit counters
    -- 8 bits can count to 255. 18BX @ 480 MHz is 216 clks
    type CounterArray is array(integer range <>) of integer 0 to 5;
    signal Counters0 : CounterArray(TrackPipeIn'left downto TrackPipeIn'right) := (others => (others => 0)); -- the fast counter
    signal Counters1 : CounterArray(TrackPipeIn'left downto TrackPipeIn'right) := (others => (others => 0)); -- the slow counter
    signal tracks : Vector(TrackPipeIn'left downto TrackPipeIn'right) := NullVector(TrackPipeIn'length);

    signal RstValue : CounterARrat(TrackPipeIn'left downto TrackPipeIn'right) := (0, 1, 2, 3, 4);

begin

    for i in TrackPipeIn'left downto TrackPipeIn'right generate
        process(clk)
        begin
            if rising_edge(clk) then
                if not TrackPipeIn(i).FrameValid then
                    Counters0(i) <= 0;
                    Counters1(i) <= 0;
                elsif TrackPipeIn(i).DataValid then
                    if Counters0(i) = 4 then
                        Counters0(i) <= 0;
                        if Counters1(i) <= 4 then
                            Counters1(i) <= 0;
                        else
                            Counters1(i) += 1;
                        end if;
                    else
                        Counters0(i) <= Counters0(i) + 1;
                    end if;
                end if;
            end if;
        end process;
    end generate;

    -- Delay the tracks by 1-cycle (the counter latency) and attach the counter
    -- As their new destination
    for i in TrackPipeIn'left downto TrackPipeIn'right generate
        tracks(i) <= TrackPipeIn(1)(i);
        tracks(i).Keys(0) <= Counters1(i); -- slow counter for first layer
        tracks(i).Keys(1) <= Counters0(i); -- fast counter for second layer
    end generate;

    -- Map the Output
    Output : entity Track.DataPipe
    port map(clk, tracks, TrackPipeOut);

    -- Write the output tracks to file
    Debug : entity Track.Debug
    generic map("TrackCounter")
    port map(clk, tracks);

end Behavioral;
