library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.DataType.all;
use work.ArrayTypes.all;

library Int;
use Int.DataType;
use Int.ArrayTypes;

entity AccumulateInputs is
port(
  clk : in std_logic := '0';
  d : in Vector(0 to 64 - 1) := NullVector(64);
  q : out Vector(0 to 128 - 1) := NullVector(128)
);
end AccumulateInputs;

architecture rtl of AccumulateInputs is

    -- Layer input arrays
    -- First index is group, second is within-group
    signal X0 : Matrix(0 to 7)(0 to 7) := NullMatrix(8,8);
    signal X1 : Matrix(0 to 7)(0 to 7) := NullMatrix(8,8);
    signal X2 : Matrix(0 to 7)(0 to 7) := NullMatrix(8,8);

    -- Layer output arrays
    signal Y0 : Matrix(0 to 7)(0 to 7) := NullMatrix(8,8);
    signal Y1 : Matrix(0 to 7)(0 to 7) := NullMatrix(8,8);
    signal Y2 : Matrix(0 to 7)(0 to 7) := NullMatrix(8,8);

    -- Global Address arrays
    signal XA0 : Int.ArrayTypes.Matrix(0 to 7)(0 to 7) := Int.ArrayTypes.NullMatrix(8,8);
    signal XA1 : Int.ArrayTypes.Matrix(0 to 7)(0 to 7) := Int.ArrayTypes.NullMatrix(8,8);
    signal XA2 : Int.ArrayTypes.Matrix(0 to 7)(0 to 7) := Int.ArrayTypes.NullMatrix(8,8);

    signal YA0 : Int.ArrayTypes.Matrix(0 to 7)(0 to 7) := Int.ArrayTypes.NullMatrix(8,8);
    signal YA1 : Int.ArrayTypes.Matrix(0 to 7)(0 to 7) := Int.ArrayTypes.NullMatrix(8,8);
    signal YA2 : Int.ArrayTypes.Matrix(0 to 7)(0 to 7) := Int.ArrayTypes.NullMatrix(8,8);

    -- Local Address arrays
    signal XLA0 : Int.ArrayTypes.Matrix(0 to 7)(0 to 7) := Int.ArrayTypes.NullMatrix(8,8);
    signal XLA1 : Int.ArrayTypes.Matrix(0 to 7)(0 to 7) := Int.ArrayTypes.NullMatrix(8,8);
    signal XLA2 : Int.ArrayTypes.Matrix(0 to 7)(0 to 7) := Int.ArrayTypes.NullMatrix(8,8);

    -- Final route arrays
    signal Y64: Vector(0 to 63) := NulLVector(64);
    signal Y128 : Vector(0 to 127) := NullVector(128);

    -- Delay the input by 1 clock
    signal A : Vector(0 to 63) := NulLVector(64);
    -- N is the current base address to route to
    -- M is the max
    -- Use a vector with duplicated logic for each element to ease signal fanout
    signal N : Int.ArrayTypes.Vector(0 to 7) := Int.ArrayTypes.NullVector(8);
    signal M : Int.ArrayTypes.Vector(0 to 7) := Int.ArrayTypes.NullVector(8);
    --signal N : integer range 0 to 127 := 0;
    --signal M : integer range 0 to 127 := 0;
    

begin

    A <= d when rising_edge(clk);

    NMGen:
    for i in 0 to 7 generate
        NMProc:
        process(clk)
        begin
            if rising_edge(clk) then
                -- Find the first invalid input to increment the base address
                for j in 0 to 63 loop
                    if not d(j).DataValid then
                        M(i).x <= j;
                        exit;
                    end if;
                end loop;
            end if;
            if rising_edge(clk) then
                -- Try in the same cycle
                -- Increment the base address
                -- Reset on new event
                if not A(8*i).FrameValid then
                    N(i).x <= 0;
                -- M should lag N by one cycle
                else
                    if N(i).x + M(i).x >= 127 then
                        N(i).x <= 127;
                    else
                        N(i).x <= N(i).x + M(i).x;
                    end if;
                end if;
            end if;
        end process;
    end generate;
    
    -- Compute an address for every input
    -- Also clock the input into the next array to keep sync with addr
    OLoop:
    for i in 0 to 7 generate
        ILoop:
        for j in 0 to 7 generate
            signal k0  : integer := 0;
            signal k1  : integer := 0;
            signal k2  : integer := 0;
            signal ki0 : Int.DataType.tData := (0, True, True);
            signal ki1 : Int.DataType.tData := (0, True, True);
            signal ki2 : Int.DataType.tData := (0, True, True);
        begin
            k0 <= (N(i).x + 8 * i + j) mod 128;
            ki0.x <= k0;
            -- Slice the lowest 3 bits. Aka x % 8
            k1 <= to_integer(to_unsigned(k0, 7)(2 downto 0));
            ki1.x <= k1;
            X0(i)(j) <= A(8*i + j);
            XA0(i)(j) <= ki0; 
            XLA0(i)(j) <= ki1;
            -- Slice the next 3 bits. Aka x // 8
            k2 <= to_integer(to_unsigned(YA0(j)(i).x, 7)(5 downto 3));
            ki2.x <= k2;

            RouteProc:
            process(clk)
            begin
                if rising_edge(clk) then
                    XLA1(i)(j) <= ki2; 
                    -- Inter layer connections
                    X1(i)(j) <= Y0(j)(i);
                    XA1(i)(j) <= YA0(j)(i);
                    X2(i)(j) <= Y1(j)(i);
                    XA2(i)(j) <= YA1(j)(i);
                end if;
            end process;

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

    -- Fan out the 64 to 128
    FinalRoute:
    for i in 0 to 127 generate
        FinalRouteProc:
        process(clk)
        begin
            if rising_edge(clk) then
                if X2((i mod 64) / 8)(i mod 8).FrameValid then
                    if XA2((i mod 64) / 8)(i mod 8).x = i and X2((i mod 64) / 8)(i mod 8).DataValid then
                        Y128(i) <= X2((i mod 64) / 8)(i mod 8);
                    else
                        --Y128(i) <= cNull;
                        Y128(i).FrameValid <= True;
                    end if;
                elsif not X2((i mod 64) / 8)(i mod 8).FrameValid then
                    -- new event reset
                    Y128(i) <= cNull;
                end if;
            end if;
        end process;
    end generate;    

    q <= Y128;

end rtl;

