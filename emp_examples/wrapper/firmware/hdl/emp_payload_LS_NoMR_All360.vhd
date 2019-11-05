-- null_algo
--
-- Do-nothing top level algo for testing
--
-- Dave Newbold, July 2013

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use work.ipbus.all;
use work.emp_data_types.all;
use work.emp_project_decl.all;

use work.emp_device_decl.all;
use work.emp_ttc_decl.all;

use work.pf_data_types.all;
use work.pf_constants.all;
use work.pf_ip_constants.all;

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

  signal links_synced : ldata(4 * N_REGION - 1 downto 0);
  signal rst_loc_reg : std_logic_vector(N_REGION - 1 downto 0);       
  constant N_FRAMES_USED : natural := 1;
  signal start_pf : std_logic;
  signal d_pf : pf_data(N_PF_IP_CORE_IN_CHANS - 1 downto 0);
  signal q_pf : pf_data(N_PF_IP_CORE_OUT_CHANS - 1 downto 0);
  type valid_array is array (natural range <>) of std_logic_vector(N_PF_IP_CORE_IN_CHANS - 1 downto 0);
  signal valid_pipe : valid_array(0 to PF_ALGO_LATENCY-1) := (others => (others => '0'));

begin

   ipb_out <= IPB_RBUS_NULL;

   algo : entity work.PF_top
   generic map( 
      algoAt240 => False,
      linkSync => True,
      magicReset => False
   )
   port map(
      clk360 => clk_p,
      clk240 => clk_payload(0),
      d => d,
      q => q
   );

    bc0 <= '0';
    gpio <= (others => '0');
    gpio_en <= (others => '0');

end rtl;
