library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ipbus.all;
use work.emp_data_types.all;
use work.emp_project_decl.all;

use work.emp_device_decl.all;
use work.emp_ttc_decl.all;

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

-- A simple payload which treats two input links as receiving signed 16 bit integers,
-- then sums them, and outputs the result on a link

architecture rtl of emp_payload is
    -- Declare two signed 16 bit integers, and one 17 bit integer for the sum
    signal a : integer range -32768 to 32767 := 0;
    signal b : integer range -32768 to 32767 := 0;
    signal c : integer range -65536 to 65535 := 0;
    -- Declare a signal to propagate the input data valid flag
    signal v : std_logic := '0';
-- A signal for the HLS output
    signal c_hls : std_logic_vector(16 downto 0) := (others => '0');
begin

    my_process:
    process(clk_p)
    begin
        if rising_edge(clk_p) then
            c <= a + b;
            if d(0).valid = '1' and d(1).valid = '1' then
                v <= '1';
            else
                v <= '0';
            end if;
        end if;
    end process;

    -- d(0).data(15 downto 0) = slice the lowest 16 bits of link 0
    -- signed(...) = cast to signed type (still just a vector of bits)
    -- to_integer(...) = convert to integer type
    a <= to_integer(signed(d(0).data(15 downto 0)));
    b <= to_integer(signed(d(1).data(15 downto 0)));

    -- to_signed(c, c'length) = convert integer to signed, specifying number of bits
    -- std_logic_vector(...) = convert to raw bits
    q(0).data(16 downto 0) <= std_logic_vector(to_signed(c, 17));
    q(0).valid <= v;
    q(0).strobe <= '1';

    -- Now connect the HLS version
    add_hls : entity work.add_hls
    port map(
        -- The control ports
        ap_clk => clk_p,
        ap_rst => '0',
        -- For an HLS IP with II>1, may need to be more careful
        ap_start => '1',
        -- The data ports
        a_V => d(0).data(15 downto 0),
        b_V => d(1).data(15 downto 0),
        ap_return => q(1).data(16 downto 0)
    );

    q(1).valid <= v;
    q(1).strobe <= '1';

    -- tie the other outputs to constant zeros
    q(4 * N_REGION - 1 downto 2) <= (others => lword_null);

	ipb_out <= IPB_RBUS_NULL;

	bc0 <= '0';
	
	gpio <= (others => '0');
	gpio_en <= (others => '0');

end rtl;
