library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.DataType.all;
use work.ArrayTypes.all;

library Int;
use Int.DataType;
use Int.ArrayTypes;

entity Merge32to64 is
port(
    clk : in std_logic := '0';
    a : in Vector(0 to 32 - 1) := NullVector(32);
    b : in Vector(0 to 32 - 1) := NullVector(32);
    q : out Vector(0 to 64 - 1) := NullVector(64)
);
end Merge32to64;

architecture rtl of Merge32to64 is

    constant RouterLatency : integer := 4; -- a guess for now
    signal aPipe : VectorPipe(0 to RouterLatency - 1)(0 to 32 - 1) := NulLVectorPipe(RouterLatency, 32);

    -- Layer input arrays
    -- First index is group, second is within-group
    signal X0 : Matrix(0 to 3)(0 to 7) := NullMatrix(4,8);
    signal X1 : Matrix(0 to 3)(0 to 7) := NullMatrix(4,8);
    signal X2 : Matrix(0 to 3)(0 to 7) := NullMatrix(4,8);

    -- Layer output arrays
    signal Y0 : Matrix(0 to 3)(0 to 7) := NullMatrix(4,8);
    signal Y1 : Matrix(0 to 3)(0 to 7) := NullMatrix(4,8);
    signal Y2 : Matrix(0 to 3)(0 to 7) := NullMatrix(4,8);

    -- Global Address arrays
    signal XA0 : Int.ArrayTypes.Matrix(0 to 3)(0 to 7) := Int.ArrayTypes.NullMatrix(4,8);
    signal XA1 : Int.ArrayTypes.Matrix(0 to 3)(0 to 7) := Int.ArrayTypes.NullMatrix(4,8);
    signal XA2 : Int.ArrayTypes.Matrix(0 to 3)(0 to 7) := Int.ArrayTypes.NullMatrix(4,8);

    signal YA0 : Int.ArrayTypes.Matrix(0 to 3)(0 to 7) := Int.ArrayTypes.NullMatrix(4,8);
    signal YA1 : Int.ArrayTypes.Matrix(0 to 3)(0 to 7) := Int.ArrayTypes.NullMatrix(4,8);
    signal YA2 : Int.ArrayTypes.Matrix(0 to 3)(0 to 7) := Int.ArrayTypes.NullMatrix(4,8);

    -- Local Address arrays
    signal XLA0 : Int.ArrayTypes.Matrix(0 to 3)(0 to 7) := Int.ArrayTypes.NullMatrix(4,8);
    signal XLA1 : Int.ArrayTypes.Matrix(0 to 3)(0 to 7) := Int.ArrayTypes.NullMatrix(4,8);
    signal XLA2 : Int.ArrayTypes.Matrix(0 to 3)(0 to 7) := Int.ArrayTypes.NullMatrix(4,8);

    -- Final route arrays
    signal bFlat   : Vector(0 to 31) := NullVector(32);
    signal bAFlat  : Int.ArrayTypes.Vector(0 to 31) := Int.ArrayTypes.NullVector(32);
    signal bRouted : Vector(0 to 63) := NullVector(64);
    signal Y       : Vector(0 to 63) := NullVector(64);

    -- Final route mapping
    constant YMap : Int.ArrayTypes.Vector(0 to 31) := (
                                                     (0,true,true),
                                                     (5,true,true),
                                                     (2,true,true),
                                                     (7,true,true),
                                                     (8,true,true),
                                                     (13,true,true),
                                                     (10,true,true),
                                                     (15,true,true),
                                                     (16,true,true),
                                                     (21,true,true),
                                                     (18,true,true),
                                                     (23,true,true),
                                                     (24,true,true),
                                                     (29,true,true),
                                                     (26,true,true),
                                                     (31,true,true),
                                                     (4,true,true),
                                                     (1,true,true),
                                                     (6,true,true),
                                                     (3,true,true),
                                                     (12,true,true),
                                                     (9,true,true),
                                                     (14,true,true),
                                                     (11,true,true),
                                                     (20,true,true),
                                                     (17,true,true),
                                                     (22,true,true),
                                                     (19,true,true),
                                                     (28,true,true),
                                                     (25,true,true),
                                                     (30,true,true),
                                                     (27,true,true));

    -- N is the current base address to route to
    -- M is the max
    --signal N : Int.DataType.tData := Int.DataType.cNull;
    --signal M : Int.DataType.tData := Int.DataType.cNull;
    signal N : integer range 0 to 63 := 0;

begin

    aPipeEnt:
    entity work.DataPipe
    port map(clk, a, aPipe);
    
    NMProc:
    process(clk)
    begin
        --if rising_edge(clk) then
        -- Find the first invalid input in a to route the b array
        -- to that position
        for i in 0 to 31 loop
            if not a(i).DataValid then
                N <= i;
                exit;
            end if;
        end loop;
        -- edge condition (all of a was valid)
        if a(31).DataValid then
            N <= 32;
        end if;
    end process;
    
    -- Compute an address for every input
    -- Also clock the input into the next array to keep sync with addr
    OLoop:
    for i in 0 to 3 generate
        ILoop:
        for j in 0 to 7 generate
            signal k0  : integer := 0;
            signal k1  : integer := 0;
            signal k2  : integer := 0;
            signal ad4 : integer := 0; -- address divided by 4
            signal am2 : integer := 0; -- address modulo 2
            signal fourAm2 : integer := 0; -- 4 * address modulo 2
            signal k2pre : integer := 0; -- before taking modulus
            signal ki0 : Int.DataType.tData := (0, True, True);
            signal ki1 : Int.DataType.tData := (0, True, True);
            signal ki2 : Int.DataType.tData := (0, True, True);
            -- index calculation for second router layer
    	    constant aj : integer := j mod 4;
	        constant bj : integer := i + 4 * (j / 4);
        begin
            --AddrInProc:
            --process(clk)
            --begin
            k0 <= N + 8 * i + j;
            -- Slice the lowest 3 bits. Aka x % 8
            k1 <= to_integer(to_unsigned(k0, 6)(2 downto 0));
            ad4 <= to_integer(to_unsigned(XA1(i)(j).x, 6)(5 downto 2));
            am2 <= to_integer(to_unsigned(XA1(i)(j).x, 6)(0 downto 0)); 
            fourAm2 <= 4 * am2;
            k2pre <= ad4 + fourAm2;
            k2 <= to_integer(to_unsigned(k2pre, 6)(2 downto 0)); -- modulo 8
            ki0.x <= k0;
            ki1.x <= k1;
            ki2.x <= k2;
            X0(i)(j) <= b(8*i + j);
            XA0(i)(j) <= ki0; 
            XLA0(i)(j) <= ki1;
            XLA1(i)(j) <= ki2; 
            --end process;

            -- Inter layer connections
            -- Update for 4 x 8 router grouping
            X1(i)(j) <= Y0(aj)(bj);
            XA1(i)(j) <= YA0(aj)(bj);
            X2(i)(j) <= Y1(aj)(bj);
            XA2(i)(j) <= YA1(aj)(bj);
        end generate;

        -- First route layer
        Route0:
        entity work.UniqueRouter
        port map(
            clk             => clk,
            DataIn          => X0(i),
            DataInGlobAddr  => XA0(i),
            Addr            => XLA0(i),
            DataOut         => Y0(i),
            DataOutGlobAddr => YA0(i)
        );

        -- Second route layer
        Route1:
        entity work.UniqueRouter
        port map(
            clk             => clk,
            DataIn          => X1(i),
            DataInGlobAddr  => XA1(i),
            Addr            => XLA1(i),
            DataOut         => Y1(i),
            DataOutGlobAddr => YA1(i)
        );
    end generate;

    -- Fan out the 32 to 64
    bFlatGen:
    for i in 0 to 31 generate
    begin
    	bFlat(i) <= X2(i / 8)(i mod 8);
	    bAFlat(i) <= XA2(i / 8)(i mod 8);
    end generate;

    bRoute:
    for i in 0 to 63 generate
        bRouteProc:
        process(clk)
        begin
            if rising_edge(clk) then
                if bAFlat(YMap(i mod 32).x).x = i and bFlat(YMap(i mod 32).x).DataValid then
                    bRouted(i) <= bFlat(YMap(i mod 32).x);
                else
                    bRouted(i) <= cNull;
                    if bFlat(YMap(i mod 32).x).FrameValid then
                        bRouted(i).FrameValid <= True;
                    end if;
                end if;
            end if;
        end process;
    end generate;

    FinalRoute:
    for i in 0 to 63 generate
        FRLowerHalf:
        if i <= 31 generate
            FinalRouteProcA:
            process(clk)
            begin
                if rising_edge(clk) then
                    if aPipe(RouterLatency-1)(i).DataValid then
                        Y(i) <= aPipe(RouterLatency-1)(i);
                    elsif bRouted(i).DataValid then
                        Y(i) <=  bRouted(i);
                    else
                        Y(i) <= cNull;
                        if aPipe(RouterLatency-1)(i).FrameValid then
                            Y(i).FrameValid <= True;
                        end if;
                    end if;
                end if;
            end process;
        end generate;
        FRUpperHalf:
        if i > 31 generate
            FinalRouteProcB:
            process(clk)
            begin
                if rising_edge(clk) then
                    if bRouted(i).DataValid then
                        Y(i) <= bRouted(i);
                    else
                        Y(i) <= cNull;
                        if bRouted(i).FrameValid then
                            Y(i).FrameValid <= True;
                        end if;
                    end if;
                end if;
            end process;
        end generate;
    end generate;

    q <= Y;

end rtl;

