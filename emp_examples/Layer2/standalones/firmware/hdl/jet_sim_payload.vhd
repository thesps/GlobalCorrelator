-- null_algo
--
-- Do-nothing top level algo for testing
--
-- Dave Newbold, July 2013

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library IO;
use IO.DataType;
use IO.ArrayTypes;

library Jet;

library Utilities;
use Utilities.Debugging;

use work.ipbus.all;
use work.emp_data_types.all;
use work.emp_project_decl.all;

use work.emp_device_decl.all;
use work.emp_ttc_decl.all;

use work.PkgConstants.all;

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
	
    --signal dVIO   : IO.ArrayTypes.Vector(0 to 6 * 16 - 1) := IO.ArrayTypes.NullVector(6 * 16);
    signal dIO      : IO.ArrayTypes.Matrix(0 to 5)(0 to 5)      := IO.ArrayTypes.NullMatrix(6, 6);
    signal qIO      : IO.ArrayTypes.Vector(0 to 127)             := IO.ArrayTypes.NullVector(128);
    signal qIOP     : IO.ArrayTypes.VectorPipe(0 to 4)(0 to 127) := IO.ArrayTypes.NullVectorPipe(5, 128);
    signal jetsIO   : IO.ArrayTypes.Vector(0 to 9)               := IO.ArrayTypes.NullVector(10);
    signal jetsIOP  : IO.ArrayTypes.VectorPipe(0 to 4)(0 to 9)   := IO.ArrayTypes.NullVectorPipe(5, 10);
    signal jetStart : std_logic := '0';
    signal jetsDone : std_logic := '0';
    signal jetsDonePipe : std_logic_vector(0 to 4) := (others => '0');

begin

    LinkMap : entity work.link_map
    generic map(True)
    port map(clk_p, d, dIO);

    Merge : entity IO.DemuxMergeAccumulateInputRegions
    generic map(NFRAMESPEREVENT)
    port map(clk_p, dIO, qIO, jetStart);

    --MergeOutPipe : entity IO.DataPipe
    --port map(clk_p, qIO, qIOP);

    --JetAlgo : entity Jet.JetAlgoWrapped
    --port map(clk_p, qIO, jetStart, jetsIO);

    JetAlgo : entity work.JetAlgo
    port map(clk_p, qIO, jetsIO);

    JetsOutPipe : entity IO.DataPipe
    port map(clk_p, jetsIO, jetsIOP);

    GenOut:
    for i in 0 to 9 generate
        q(80 + i).data   <= jetsIOP(4)(i).data;
        q(80 + i).valid  <= '1' when jetsIOP(4)(i).DataValid else '0';
        q(80 + i).strobe <= '1';
        q(80 + i).start  <= '0';
    end generate;

	ipb_out <= IPB_RBUS_NULL;
	bc0 <= '0';
	
	gpio <= (others => '0');
	gpio_en <= (others => '0');

    SimCounter:
    process(clk_p)
    begin
        if rising_edge(clk_p) then
            Utilities.Debugging.SimulationClockCounter <= Utilities.Debugging.SimulationClockCounter + 1;
        end if;
    end process;

    Debug : entity IO.Debug
    generic map("Jets", "./")
    port map(clk_p, jetsIO);

end rtl;
