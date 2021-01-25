library ieee;
use ieee.std_logic_1164.all;

library Jet;
use Jet.DataType.all;
use Jet.ArrayTypes.all;

-- D 'trickles down' the internal Q, slotting into the list
entity AccumulatingSort is
port(
    clk : in std_logic;
    D : in tData;
    Q : out Vector
);
end AccumulatingSort;

architecture rtl of AccumulatingSort is
    -- the moving list
    signal M : Vector(0 to Q'length) := NullVector(Q'length+1);
    -- the static list
    signal S : Vector(0 to Q'length-1) := NullVector(Q'length);
    -- a signal to determine when to read out
    signal flush : boolean := false;
    type bool_arr is array(natural range <>) of boolean;
    signal comp : bool_arr(0 to Q'length) := (others => false);
begin
    -- Connect the new data to the start of the moving list
    M(0) <= D;

    CtrlProc:
    process(clk) is
    begin
    if rising_edge(clk) then
        -- When the final element in 'S' is valid we have process NJETS jets
        -- so flush and read out
        flush <= S(S'length-1).DataValid;
        if flush then
            Q <= S;
        else
            Q <= NullVector(Q'length);
        end if;
    end if;
    end process;

    GComp:
    for i in 0 to Q'length-1 generate
        process(clk) is
        begin
            if falling_edge(clk) then
                comp(i) <= M(i) > S(i);
            end if;
        end process;
    end generate;

    GMove:
    for i in 0 to Q'length-1 generate
        process(clk) is
        begin
            if rising_edge(clk) then
                if flush then
                    S(i) <= cNull;
                else
                    if comp(i) then
                        S(i) <= M(i);
                        M(i+1) <= S(i);
                    else
                        S(i) <= S(i);
                        M(i+1) <= M(i);
                    end if;
                end if;
            end if;
        end process;
    end generate;

end rtl;
