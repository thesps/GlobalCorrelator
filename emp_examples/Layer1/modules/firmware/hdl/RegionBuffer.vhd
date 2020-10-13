library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.DataType.all;

-- The module to buffer the PF Objects after the router
-- Each D(i) is written into the i'th buffer, at the address according to its D(i).iRegion (random access)
-- At the end of the accumulation period, regions are streamed out serially from each D(i)
-- Buffers are paged to write to one for one event while reading from the other event
entity RegionBuffer is
port(
    clk : in std_logic := '0';
    mode_switch : in boolean := false;
    D : in tData := cNull;
    Q : out tData := cNull
);
end RegionBuffer;

architecture rtl of RegionBuffer is

    signal page        : boolean := false;
    signal rpage       : natural range 0 to 1 := 1;
    signal wpage       : natural range 0 to 1 := 0;
    signal WriteAddrEv : natural range 0 to 255 := 0;
    signal WriteAddr   : natural range 0 to 511 := 0;
    signal WriteEnable : boolean := false;
    signal ReadAddrEv  : natural range 0 to 255 := 0;
    signal ReadAddr    : natural range 0 to 511 := 0;
    signal DIn         : tData := cNull;

begin

    WriteAddrEv <= D.iRegion;

    process(clk)
    begin
        if rising_edge(clk) then
            DIn <= D;
            -- Use the 'page' as MSB of the BRAM
            WriteAddr <= 256 * wpage + WriteAddrEv;
            WriteEnable <= D.DataValid;
            if ReadAddrEv = 255 or mode_switch then
                ReadAddrEv <= 0;
            else
                ReadAddrEv <= ReadAddrEv + 1;
            end if;
            ReadAddr <= 256 * rpage + ReadAddrEv;

            if mode_switch then
                page <= not page;
            end if;

        end if;
    end process;

    -- read and write from opposite pages
    wpage <= 0 when page else 1;
    rpage <= 1 when page else 0;

    RAM : entity work.DataRam
    port map(clk, DIn, WriteAddr, WriteEnable, ReadAddr, Q); 

end rtl;
