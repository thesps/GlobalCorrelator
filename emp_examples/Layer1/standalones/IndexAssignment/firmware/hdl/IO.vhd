library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library HGCRouter;
use HGCRouter.DataType.all;
use HGCRouter.ArrayTypes.all;

library Utilities;
use Utilities.Utilities.all;

use work.emp_data_types.all;
use work.emp_device_decl.all;
use work.emp_project_decl.all;

use work.Constants.all;

entity IO is
port(
    clk : in std_logic;
    link_in  : in ldata(4 * N_REGION - 1 downto 0);
    data_out : out VectorPipe(0 to 0)(0 to N_LINKS_HGC_TOTAL - 1) := NullVectorPipe(1, N_LINKS_HGC_TOTAL);
    data_in  : in VectorPipe(0 to 0)(0 to N_LINKS_HGC_TOTAL - 1) := NullVectorPipe(1, N_LINKS_HGC_TOTAL);
    link_out : out ldata(4 * N_REGION - 1 downto 0)
);
end IO;

architecture rtl of IO is

    -- 16 chosen to keep links in same SLR
    -- https://gitlab.cern.ch/p2-xware/firmware/emp-fwk/-/blob/master/boards/vcu118/regions.md
    constant offs : integer := 16;
begin

    GenIn:
    for i in 0 to N_LINKS_HGC_TOTAL - 1 generate
    begin
        data_out(0)(i).frameValid <= to_boolean(link_in(i + offs).valid);
        data_out(0)(i).dataValid  <= to_boolean(link_in(i + offs).data(63));
        data_out(0)(i).data       <= link_in(i + offs).data;
        data_out(0)(i).iRegion    <= to_integer(unsigned(link_in(i + offs).data(5 downto 0)));
    end generate;

    GenOut:
    for i in 0 to N_LINKS_HGC_TOTAL - 1 generate
    begin
        link_out(i + offs).valid             <= to_std_logic(data_in(0)(i).FrameValid);
        link_out(i + offs).data(5 downto 0)  <= std_logic_vector(data_in(0)(i).addr);
        link_out(i + offs).data(63 downto 6) <= data_in(0)(i).data(63 downto 6);
        link_out(i + offs).strobe            <= '1';
    end generate;

end rtl;
