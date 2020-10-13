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

library Bool;
use Bool.DataType;
use Bool.ArrayTypes;

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
	
    signal XPipe : VectorPipe(0 to 0)(0 to 17) := NullVectorPipe(1, 18);
    signal XIdxPipe : VectorPipe(0 to 0)(0 to 17) := NullVectorPipe(1, 18);
    signal XIdx : Vector(0 to 17) := NullVector(18);
    signal XRouted : Vector(0 to 23) := NullVector(24);
    signal XAcc : Vector(0 to 23) := NullVector(24);
    signal XAccPipe : VectorPipe(0 to 0)(0 to 23) := NullVectorPipe(1, 24);
    signal newEvent : Bool.ArrayTypes.Vector(0 to 31) := Bool.ArrayTypes.NullVector(32);

begin

    NewEventProc:
    process(clk)
    begin
        if rising_edge(clk) then
            newEvent(0).x <= XIdx(0).FrameValid and not XIdxPipe(0)(0).FrameValid;
            newEvent(1 to 31) <= newEvent(0 to 30);
            XIdx <= XIdxPipe(0);
        end if;
    end process;

    IO : entity work.IO
    port map(clk_p, d, XPipe, XAccPipe, q);

    IndexAssignment : entity HGCRouter.IndexInRegionAssignment
    port map(clk_p, XPipe, XIdxPipe);

    Router : entity HGCRouter.Router18to24
    port map(clk_p, XIdx, XRouted);

    EventBuffer : entity HGCRouter.RegionBuffers
    port map(clk_p, newEvent(31).x, XRouted, XAcc);

    OutPipe : entity HGCRouter.DataPipe
    port map(clk_p, XAcc, XAccPipe);

	ipb_out <= IPB_RBUS_NULL;
	bc0 <= '0';
	
	gpio <= (others => '0');
	gpio_en <= (others => '0');

end rtl;
