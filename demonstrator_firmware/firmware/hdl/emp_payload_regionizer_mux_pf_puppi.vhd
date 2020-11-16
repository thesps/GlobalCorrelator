library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ipbus.all;
use work.emp_data_types.all;
use work.emp_project_decl.all;

use work.emp_device_decl.all;
use work.emp_ttc_decl.all;

use work.regionizer_data.all;

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
        constant NREGTOT : natural := NTKSORTED + NCALOSORTED + NMUSORTED;
        constant NREGSTREAM360    : natural := (NREGTOT+PFII-1)/PFII;
        constant NPFSTREAM360    : natural := (NPFTOT+PFII-1)/PFII;
        constant NPUPPISTREAM360 : natural := (NPUPPI+PFII-1)/PFII;
        constant N_IN  : natural := NTKSECTORS*NTKFIBERS + NCALOSECTORS*NCALOFIBERS + NMUFIBERS + 1;
        constant N_OUT_REG   : natural := NREGSTREAM360 ;
        constant N_OUT_PF    : natural := NPFSTREAM360 + 1;
        constant N_OUT_PUPPI : natural := NPUPPISTREAM360 + 1;
        constant LINK0_PF    : natural := N_OUT_REG;
        constant LINK0_PUPPI : natural := N_OUT_REG + N_OUT_PF;
        constant N_OUT : natural := N_OUT_REG + N_OUT_PF + N_OUT_PUPPI;
        
        signal links_in:  w64s(N_IN-1 downto 0) := (others => (others => '0'));
        signal valid_in: std_logic_vector(N_IN-1 downto 0) := (others => '0');

        signal regionizer_out: w64s(NREGTOT-1 downto 0);
        signal regionizer_done, regionizer_valid : STD_LOGIC := '0';
        signal regionizer_out_stream: w64s(NREGSTREAM360-1 downto 0);
        signal regionizer_valid_stream: STD_LOGIC_VECTOR(NREGSTREAM360-1 downto 0);

        signal pf_out: w64s(NPFTOT - 1 downto 0);
        signal pf_start, pf_ready, pf_idle, pf_valid, pf_done : STD_LOGIC;
        signal pf_out_stream: w64s(NPFSTREAM360 - 1 downto 0);
        signal pf_valid_stream: STD_LOGIC_VECTOR(NPFSTREAM360 - 1 downto 0);

        signal puppi_out  : w64s(NPUPPI - 1 downto 0);
        signal puppi_done, puppi_valid : STD_LOGIC;
        signal puppi_out_stream: w64s(NPUPPISTREAM360 - 1 downto 0);
        signal puppi_valid_stream: STD_LOGIC_VECTOR(NPUPPISTREAM360 - 1 downto 0);

        signal regionizer_valid_dummy : STD_LOGIC_VECTOR(NREGTOT-1 downto 0) := (others => '1');
        signal pf_valid_dummy : STD_LOGIC_VECTOR(NPFTOT-1 downto 0) := (others => '1');
        signal puppi_valid_dummy : STD_LOGIC_VECTOR(NPUPPI-1 downto 0) := (others => '1');
begin

    ipb_out <= IPB_RBUS_NULL;

    algo_payload : entity work.regionizer_mux_pf_puppi
        port map(clk => clk_p,  rst => '0', --rst_loc(0),
                 links_in => links_in,
                 valid_in => valid_in,
                 regionizer_out => regionizer_out,
                 regionizer_done => regionizer_done,
                 regionizer_valid => regionizer_valid,

                 pf_out => pf_out,
                 pf_start => pf_start,
                 pf_done => pf_done,
                 pf_valid => pf_valid,
                 pf_ready => pf_ready,
                 pf_idle => pf_idle,

                 puppi_out => puppi_out,
                 puppi_done => puppi_done,
                 puppi_valid => puppi_valid
             );

    connect_inputs: for i in 0 to N_IN-1 generate
        links_in(i) <= d(i).data;
        valid_in(i) <= d(i).valid;
    end generate;

    -- regionizer output 
    reg_streamer : entity work.parallel2serial
                generic map(NITEMS => NPFTOT, NSTREAM => NPFSTREAM360)
                port map( ap_clk => clk_p,
                          roll   => regionizer_done,
                          data_in  => regionizer_out,
                          valid_in => regionizer_valid_dummy,
                          data_out  => regionizer_out_stream,
                          valid_out => regionizer_valid_stream,
                          roll_out  => open);
    connect_reg_outputs: for i in 0 to N_OUT_REG-1 generate 
        q(i).data   <= regionizer_out_stream(i);
        q(i).valid  <= regionizer_valid_stream(i);
        q(i).strobe <= '1';
    end generate;

    -- pf & puppi have to be serialized
    pf_streamer : entity work.parallel2serial
                generic map(NITEMS => NPFTOT, NSTREAM => NPFSTREAM360)
                port map( ap_clk => clk_p,
                          roll   => pf_done,
                          data_in  => pf_out,
                          valid_in => pf_valid_dummy,
                          data_out  => pf_out_stream,
                          valid_out => pf_valid_stream,
                          roll_out  => open);
    connect_pf_outputs: for i in 0 to NPFSTREAM360-1 generate 
        q(LINK0_PF+i).data   <= pf_out_stream(i);
        q(LINK0_PF+i).valid  <= pf_valid_stream(i);
        q(LINK0_PF+i).strobe <= '1';
    end generate;
    q(LINK0_PF+NPFSTREAM360).data <= (60=>pf_start, 56=>pf_ready, 52=>pf_idle, 4=>pf_done, 0=>pf_valid, others => '0');
    q(LINK0_PF+NPFSTREAM360).valid  <= '1';
    q(LINK0_PF+NPFSTREAM360).strobe <= '1';

    puppi_streamer : entity work.parallel2serial
                generic map(NITEMS => NPUPPI, NSTREAM => NPUPPISTREAM360)
                port map( ap_clk => clk_p,
                          roll   => puppi_done,
                          data_in  => puppi_out,
                          valid_in => puppi_valid_dummy,
                          data_out  => puppi_out_stream,
                          valid_out => puppi_valid_stream,
                          roll_out  => open);
    connect_puppi_outputs: for i in 0 to NPUPPISTREAM360-1 generate 
        q(LINK0_PUPPI+i).data   <= puppi_out_stream(i);
        q(LINK0_PUPPI+i).valid  <= puppi_valid_stream(i);
        q(LINK0_PUPPI+i).strobe <= '1';
    end generate;
    q(LINK0_PUPPI+NPUPPISTREAM360).data <= (4=>puppi_done, 0=>puppi_valid, others => '0');
    q(LINK0_PUPPI+NPUPPISTREAM360).valid  <= '1';
    q(LINK0_PUPPI+NPUPPISTREAM360).strobe <= '1';
    
    zerofill:	
        process(clk_p) 
        begin
            if rising_edge(clk_p) then
                for i in 4 * N_REGION - 1 downto N_OUT loop
                    q(i).data <= (others => '0');
                    q(i).valid <= '0';
                    q(i).strobe <= '1';
                end loop;
            end if;
        end process zerofill;

    
    bc0 <= '0';
    
    gpio <= (others => '0');
    gpio_en <= (others => '0');

end rtl;
