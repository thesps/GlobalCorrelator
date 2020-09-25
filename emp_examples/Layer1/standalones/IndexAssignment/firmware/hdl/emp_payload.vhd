library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use work.ipbus.all;
use work.emp_data_types.all;
use work.emp_project_decl.all;

use work.emp_device_decl.all;
use work.emp_ttc_decl.all;

use work.Constants.all;

library HGCRouter;
use HGCRouter.DataType.all;
use HGCRouter.ArrayTypes.all;

entity emp_payload is
	port(
		clk: in std_logic; -- ipbus signals
		rst: in std_logic;
		ipb_in: in ipb_wbus;
		ipb_out: out ipb_rbus;
		clk_payload: in std_logic_vector(2 downto 0);
		rst_payload: in std_logic_vector(2 downto 0);
		clk_p: in std_logic; -- data clock
		rst_loc: in std_logic_vector(N_REGION - 1 downto 0);
		clken_loc: in std_logic_vector(N_REGION - 1 downto 0);
		ctrs: in ttc_stuff_array;
		bc0: out std_logic;
		d: in ldata(4 * N_REGION - 1 downto 0); -- data in
		q: out ldata(4 * N_REGION - 1 downto 0); -- data out
		gpio: out std_logic_vector(29 downto 0); -- IO to mezzanine connector
		gpio_en: out std_logic_vector(29 downto 0) -- IO to mezzanine connector (three-state enables)
	);
		
end emp_payload;

architecture rtl of emp_payload is
	
    signal X : VectorPipe(0 to 0)(0 to N_LINKS_HGC_TOTAL - 1) := NullVectorPipe(1, N_LINKS_HGC_TOTAL);
    signal Y : VectorPipe(0 to 0)(0 to N_LINKS_HGC_TOTAL - 1) := NullVectorPipe(1, N_LINKS_HGC_TOTAL);

begin

    IO : entity work.IO
    port map(clk_p, d, X, Y, q);

    IndexAssignment : entity HGCRouter.IndexInRegionAssignment
    port map(clk_p, X, Y);

	ipb_out <= IPB_RBUS_NULL;
	bc0 <= '0';
	
	gpio <= (others => '0');
	gpio_en <= (others => '0');

end rtl;
