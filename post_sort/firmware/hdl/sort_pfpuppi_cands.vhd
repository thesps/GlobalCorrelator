-- Sort the PFCandidate objects output by the PF or Puppi blocks using a bitonic sort.
-- First implementation makes no special optimizations, simply sorts all candidates

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_textio.ALL;

library PF;
use PF.DataType;
use PF.ArrayTypes;

use work.regionizer_data.all;

entity sort_pfpuppi_cands is
port(
    clk : in std_logic;
    d : in w64s;
    q : out w64s
);
end entity;

architecture rtl of sort_pfpuppi_cands is
    signal pf_d : PF.ArrayTypes.Vector(0 to d'length-1) := PF.ArrayTypes.NullVector(d'length);
    signal pf_q : PF.ArrayTypes.Vector(0 to d'length-1) := PF.ArrayTypes.NullVector(d'length);
begin

    GenCast:
    for i in d'range generate
        pf_d(i) <= PF.DataType.FromW64(d(i));
        q(i) <= PF.DataType.ToStdLogicVector(pf_q(i));
    end generate;

    Sort: entity PF.BitonicSort
    generic map(InSize => d'length, OutSize => d'length, d => false, id => "pfsort")
    port map(clk, pf_d, pf_q);

end architecture;


