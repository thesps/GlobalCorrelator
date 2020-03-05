library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.DataType.all;
use work.ArrayTypes.all;

library Int;
use Int.DataType;
use Int.ArrayTypes;

entity Merge32and64to64 is
port(
    clk : in std_logic := '0';
    a : in Vector(0 to 63) := NullVector(64);
    b : in Vector(0 to 31) := NullVector(32);
    q : out Vector(0 to 63) := NullVector(64)
);
end Merge32and64to64;

architecture rtl of Merge32and64to64 is

    constant RouterLatency : integer := 5; -- a guess for now
    signal aPipe : VectorPipe(0 to RouterLatency - 1)(0 to 63) := NulLVectorPipe(RouterLatency, 64);
    signal aPiped : Vector(0 to 63) := NullVector(64);

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
    signal bRouted  : Vector(0 to 63) := NullVector(64);
    signal Y : Vector(0 to 63) := NullVector(64);

    -- N is the current base address to route to
    -- M is the max
    --signal N : Int.DataType.tData := Int.DataType.cNull;
    --signal M : Int.DataType.tData := Int.DataType.cNull;
    signal N : integer range 0 to 63 := 0;

begin

    aPipeEnt:
    entity work.DataPipe
    port map(clk, a, aPipe);
    aPiped <= aPipe(routerLatency-1);
    
    NMProc:
    process(clk)
    begin
        --if rising_edge(clk) then
        -- Find the first invalid input in a to route the b array
        -- to that position
        for i in 0 to 63 loop
            if not a(i).DataValid then
                N <= i;
                exit;
            end if;
        end loop;
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
            constant ij : integer := 4 * i + j;
            constant ai : integer := ij / 4;
            constant bi : integer := ij mod 4;
            constant ab : integer := 4 * bi + ai;
            constant aj : integer := ab / 8;
            constant bj : integer := ab mod 8;
        begin
            --AddrInProc:
            --process(clk)
            --begin
            k0 <= (N + 8 * i + j) mod 64;
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
    bRoute:
    for i in 0 to 63 generate
        bRouteProc:
        process(clk)
        begin
            if rising_edge(clk) then
                if XA2(i / 16)(i mod 8).x = i and X2(i / 16)(i mod 8).DataValid then
                    bRouted(i) <= X2(i / 16)(i mod 8); 
                --elsif not X2(i / 16)(i mod 8).DataValid then
                else
                    bRouted(i) <= cNull;
                end if;
            end if;
        end process;
    end generate;

    FinalRoute:
    for i in 0 to 63 generate
        FinalRouteProcA:
        process(clk)
        begin
            if rising_edge(clk) then
                if aPiped(i).DataValid then
                    Y(i) <= aPiped(i);
                elsif bRouted(i).DataValid then
                    Y(i) <=  bRouted(i);
                else
                    Y(i) <= cNull;
                end if;
            end if;
        end process;
    end generate;

    q <= Y;

end rtl;

