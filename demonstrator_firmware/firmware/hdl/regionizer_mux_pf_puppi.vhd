library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.regionizer_data.all;

entity regionizer_mux_pf_puppi is
    port(
            clk : IN STD_LOGIC;
            rst : IN STD_LOGIC;
            --ap_start : IN STD_LOGIC;
            --ap_done : OUT STD_LOGIC;
            --ap_idle : OUT STD_LOGIC;
            --ap_ready : OUT STD_LOGIC;
            links_in : IN w64s(NTKSECTORS*NTKFIBERS + NCALOSECTORS*NCALOFIBERS + NMUFIBERS downto 0);
            valid_in : IN STD_LOGIC_VECTOR(NTKSECTORS*NTKFIBERS + NCALOSECTORS*NCALOFIBERS + NMUFIBERS downto 0);
            regionizer_out   : OUT w64s(NTKSORTED + NCALOSORTED + NMUSORTED - 1 downto 0);
            regionizer_start : OUT STD_LOGIC;
            regionizer_done  : OUT STD_LOGIC;
            regionizer_valid : OUT STD_LOGIC;
            pf_out   : OUT w64s(NTKSORTED + NCALOSORTED + NMUSORTED - 1 downto 0);
            pf_start : OUT STD_LOGIC;
            pf_done  : OUT STD_LOGIC;
            pf_valid : OUT STD_LOGIC;
            pf_ready : OUT STD_LOGIC;
            pf_idle  : OUT STD_LOGIC;
            puppi_out   : OUT w64s(NTKSORTED+NCALOSORTED - 1 downto 0);
            puppi_done  : OUT STD_LOGIC;
            puppi_valid : OUT STD_LOGIC;
            d_puppich_in  : OUT w64s(NTKSORTED downto 0);
            puppich_out   : OUT w64s(NTKSORTED - 1 downto 0);
            puppich_start : OUT STD_LOGIC;
            puppich_done  : OUT STD_LOGIC;
            puppich_valid : OUT STD_LOGIC;
            puppich_ready : OUT STD_LOGIC;
            puppich_idle  : OUT STD_LOGIC;
            d_puppine_in  : OUT w64s(NTKSORTED+NCALOSORTED downto 0);
            puppine_out   : OUT w64s(NCALOSORTED - 1 downto 0);
            puppine_start : OUT STD_LOGIC;
            puppine_done  : OUT STD_LOGIC;
            puppine_valid : OUT STD_LOGIC;
            puppine_ready : OUT STD_LOGIC;
            puppine_idle  : OUT STD_LOGIC
    );

--  Port ( );
end regionizer_mux_pf_puppi;

architecture Behavioral of regionizer_mux_pf_puppi is
    constant PV_LINK  : natural := NTKSECTORS*NTKFIBERS + NCALOSECTORS*NCALOFIBERS + NMUFIBERS;
    constant NREGIONIZER_OUT : natural := NTKSORTED + NCALOSORTED + NMUSORTED;
    constant NPFTOT :          natural := NTKSORTED + NCALOSORTED + NMUSORTED;

    constant LATENCY_PF : natural := 46;
    constant LATENCY_PUPPINE : natural := 53;
    constant LATENCY_PUPPICH : natural :=  6;
    constant LATENCY_REGIONIZER : natural := 54+11;
    constant LATENCY_PV         : natural := 0; -- not realistic but who cares
    constant DELAY_PV           : natural := LATENCY_REGIONIZER + LATENCY_PF - LATENCY_PV;

    signal input_was_valid, newevent, newevent_out : std_logic := '0';

    signal tk_in:  w64s(NTKSECTORS*NTKFIBERS-1 downto 0) := (others => (others => '0'));
    signal tk_out: w64s(NTKSORTED-1 downto 0) := (others => (others => '0'));
    signal calo_in:  w64s(NCALOSECTORS*NCALOFIBERS-1 downto 0) := (others => (others => '0'));
    signal calo_out: w64s(NCALOSORTED-1 downto 0) := (others => (others => '0'));
    signal mu_in:  w64s(NMUFIBERS-1 downto 0) := (others => (others => '0'));
    signal mu_out: w64s(NMUSORTED-1 downto 0) := (others => (others => '0'));
    signal vtx_in: word64 := (others => '0');

    signal tk_delay_out: w64s(NTKSORTED-1 downto 0) := (others => (others => '0'));

    signal regionizer_start_i, regionizer_done_i : std_logic := '0';

    signal pf_in    : w64s(NPFTOT-1 downto 0) := (others => (others => '0'));
    signal pf_out_i : w64s(NPFTOT-1 downto 0) := (others => (others => '0'));
    signal pf_start_i, pf_warmup, pf_done_i, pf_idle_i, pf_ready_i : std_logic := '0';

    signal puppi_start_i : std_logic := '0';

    signal puppich_in    : w64s(NTKSORTED downto 0) := (others => (others => '0'));
    signal puppich_out_i : w64s(NTKSORTED-1 downto 0) := (others => (others => '0'));
    signal puppich_done_i, puppich_idle_i, puppich_ready_i : std_logic := '0';

    signal puppine_in    : w64s(NTKSORTED+NCALOSORTED downto 0) := (others => (others => '0'));
    signal puppine_out_i : w64s(NCALOSORTED-1 downto 0) := (others => (others => '0'));
    signal puppine_done_i, puppine_idle_i, puppine_ready_i : std_logic := '0';
   
    signal puppi_out_i : w64s(NTKSORTED+NCALOSORTED-1 downto 0) := (others => (others => '0'));
    signal puppi_done_i, puppi_valid_i : std_logic := '0';

    signal pv_input_was_valid : std_logic := '0';
    signal vtx_delay_in, vtx_delay_out : word64 := (others => '0'); 
begin
    
    input_links: process(clk)
    begin
        if rising_edge(clk) then
            -- for these we put some reset logic
            if rst = '1' then
                input_was_valid    <= '0';
                regionizer_start_i <= '0';
            else
                input_was_valid    <= valid_in(0);
                regionizer_start_i <= valid_in(0) or input_was_valid;
            end if;
            -- these run anyway
            newevent <= valid_in(0) and not(input_was_valid);
            for i in 0 to NTKSECTORS*NTKFIBERS-1 loop
                tk_in(i) <= links_in(i);
            end loop;
            for i in 0 to NCALOSECTORS*NCALOFIBERS-1 loop
                calo_in(i) <= links_in(i+NTKSECTORS*NTKFIBERS);
            end loop;
            for i in 0 to NMUFIBERS-1 loop
                mu_in(i) <= links_in(i+NTKSECTORS*NTKFIBERS+NCALOSECTORS*NCALOFIBERS);
            end loop;
        end if;
    end process input_links;
    regionizer_start <= regionizer_start_i;

    input_link_pv: process(clk)
    begin
        if rising_edge(clk) then
            -- for these we put some reset logic
            if rst = '1' then
                pv_input_was_valid <= '0';
                vtx_delay_in <= (others => '0');
            else
                pv_input_was_valid <= valid_in(PV_LINK);
                if valid_in(PV_LINK) = '1' and pv_input_was_valid = '0' then
                    vtx_delay_in <= links_in(PV_LINK);
                end if;
            end if;
        end if;
    end process input_link_pv;

    regionizer : entity work.full_regionizer_mux
        generic map(MU_ETA_CENTER => 460)
        port map(ap_clk => clk, 
                 ap_rst => rst, 
                 ap_start => '1',
                 --ap_ready => ready,
                 --ap_idle =>  idle,
                 --ap_done => done,
                 tracks_start => regionizer_start_i,
                 tracks_newevent => newevent,
                 tracks_in_0_0_V => tk_in( 0),
                 tracks_in_0_1_V => tk_in( 1),
                 tracks_in_1_0_V => tk_in( 2),
                 tracks_in_1_1_V => tk_in( 3), 
                 tracks_in_2_0_V => tk_in( 4),
                 tracks_in_2_1_V => tk_in( 5),
                 tracks_in_3_0_V => tk_in( 6),
                 tracks_in_3_1_V => tk_in( 7),
                 tracks_in_4_0_V => tk_in( 8),
                 tracks_in_4_1_V => tk_in( 9), 
                 tracks_in_5_0_V => tk_in(10),
                 tracks_in_5_1_V => tk_in(11),
                 tracks_in_6_0_V => tk_in(12),
                 tracks_in_6_1_V => tk_in(13),
                 tracks_in_7_0_V => tk_in(14),
                 tracks_in_7_1_V => tk_in(15), 
                 tracks_in_8_0_V => tk_in(16),
                 tracks_in_8_1_V => tk_in(17),
                 calo_start => regionizer_start_i,
                 calo_newevent => newevent,
                 calo_in_0_0_V => calo_in( 0),
                 calo_in_0_1_V => calo_in( 1),
                 calo_in_0_2_V => calo_in( 2),
                 calo_in_0_3_V => calo_in( 3), 
                 calo_in_1_0_V => calo_in( 4),
                 calo_in_1_1_V => calo_in( 5),
                 calo_in_1_2_V => calo_in( 6),
                 calo_in_1_3_V => calo_in( 7),
                 calo_in_2_0_V => calo_in( 8),
                 calo_in_2_1_V => calo_in( 9), 
                 calo_in_2_2_V => calo_in(10),
                 calo_in_2_3_V => calo_in(11),
                 mu_start => regionizer_start_i,
                 mu_newevent => newevent,
                 mu_in_0_V => mu_in(0),
                 mu_in_1_V => mu_in(1),
                 tracks_out => tk_out,
                 calo_out   => calo_out,
                 mu_out     => mu_out,
                 newevent_out => newevent_out
             );
  

    regio2pf: process(clk)
    begin
        if rising_edge(clk) then
            pf_in(NCALOSORTED-1 downto 0) <= calo_out;
            pf_in(NCALOSORTED+NTKSORTED-1 downto NCALOSORTED) <= tk_out;
            pf_in(NCALOSORTED+NTKSORTED+NMUSORTED-1 downto NCALOSORTED+NTKSORTED) <= mu_out;
            if rst = '1' then
                pf_start_i <= '0';
                pf_warmup <= '0';
            elsif newevent_out = '1' then
                -- we skip the first 'newevent' since it's dummy
                pf_warmup <= '1'; 
                pf_start_i <= pf_warmup;
            end if;
            regionizer_done_i <= newevent_out and pf_warmup; 
        end if;
    end process regio2pf;
    -- expected output order is tracks, calo, muons, so we re-arrange pf-in
    regionizer_out(NTKSORTED-1 downto 0) <= pf_in(NCALOSORTED+NTKSORTED-1 downto NCALOSORTED);
    regionizer_out(NTKSORTED+NCALOSORTED-1 downto NTKSORTED) <= pf_in(NCALOSORTED-1 downto 0);
    regionizer_out(NTKSORTED+NCALOSORTED+NMUSORTED-1 downto NCALOSORTED+NTKSORTED) <= pf_in(NCALOSORTED+NTKSORTED+NMUSORTED-1 downto NCALOSORTED+NTKSORTED);
    regionizer_valid <= pf_start_i;
    regionizer_done  <= regionizer_done_i;

    pfblock : entity work.pf_block
        port map(ap_clk => clk, 
                 ap_rst => rst, 
                 ap_start => pf_start_i,
                 ap_ready => pf_ready_i,
                 ap_idle =>  pf_idle_i,
                 ap_done =>  pf_done_i,
                 pf_in    => pf_in,
                 pf_out   => pf_out_i
                );
        pf_start <= pf_start_i;
        pf_idle <= pf_idle_i;
        pf_ready <= pf_ready_i;

    pf2out: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                pf_out   <= (others => (others => '0'));
                pf_valid <= '0';
            else
                if pf_done_i = '1' then
                    pf_valid <= '1';
                    pf_out   <= pf_out_i;
                end if;
            end if;
            pf_done <= pf_done_i;
        end if;
    end process pf2out;

    vtx_delay : entity work.bram_delay
        generic map(DELAY => DELAY_PV)
        port map(clk => clk, 
                 rst => rst, 
                 d   => vtx_delay_in,
                 q   => vtx_delay_out);

    gen_tk_delay: for i in 0 to NTKSORTED-1 generate
         tk_delay: entity work.bram_delay
                generic map(DELAY => LATENCY_PF + 1)
                port map(clk => clk, 
                         rst => rst, 
                         d   => tk_out(i),
                         q   => tk_delay_out(i));
     end generate gen_tk_delay;


    pf2puppi: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                puppi_start_i <= '0';
                puppich_in <= (others => (others => '0'));
                puppine_in <= (others => (others => '0'));
            else
                if pf_done_i = '1' then
                    puppi_start_i <= '1';
                    puppich_in(NTKSORTED downto 1) <= pf_out_i(NTKSORTED-1 downto 0);
                    puppich_in(0)                  <= vtx_delay_out;  
                    puppine_in(NTKSORTED-1 downto 0) <= tk_delay_out; 
                    puppine_in(NTKSORTED)            <= vtx_delay_out; 
                    puppine_in(NTKSORTED+NCALOSORTED downto NTKSORTED+1) <= pf_out_i(NTKSORTED+NCALOSORTED-1 downto NTKSORTED);
                end if;
            end if;
        end if;
    end process pf2puppi;

    puppichsblock : entity work.puppich_block
        port map(ap_clk => clk, 
                 ap_rst => rst, 
                 ap_start => puppi_start_i,
                 ap_ready => puppich_ready_i,
                 ap_idle =>  puppich_idle_i,
                 ap_done =>  puppich_done_i,
                 puppich_in => puppich_in,
                 puppich_out => puppich_out_i
            );
        puppich_start <= puppi_start_i;
        puppich_idle <= puppich_idle_i;
        puppich_ready <= puppich_ready_i;
        d_puppich_in <= puppich_in;

    puppiblock : entity work.puppine_block
        port map(ap_clk => clk, 
                 ap_rst => rst, 
                 ap_start => puppi_start_i,
                 ap_ready => puppine_ready_i,
                 ap_idle =>  puppine_idle_i,
                 ap_done =>  puppine_done_i,
                 puppine_in => puppine_in,
                 puppine_out => puppine_out_i
            );
        puppine_start <= puppi_start_i;
        puppine_idle <= puppine_idle_i;
        puppine_ready <= puppine_ready_i;
        d_puppine_in <= puppine_in;

    puppich2out: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                puppich_out   <= (others => (others => '0'));
                puppich_valid <= '0';
            else
                if puppich_done_i = '1' then
                    puppich_valid <= '1';
                    puppich_out   <= puppich_out_i;
                end if;
            end if;
            puppich_done <= puppich_done_i;
        end if;
    end process puppich2out;

    puppine2out: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                puppine_out   <= (others => (others => '0'));
                puppine_valid <= '0';
            else
                if puppine_done_i = '1' then
                    puppine_valid <= '1';
                    puppine_out   <= puppine_out_i;
                end if;
            end if;
            puppine_done <= puppine_done_i;
        end if;
    end process puppine2out;


    gen_puppich_delay: for i in 0 to NTKSORTED-1 generate
        puppich_delay: entity work.bram_delay
            generic map(DELAY => LATENCY_PUPPINE - LATENCY_PUPPICH)
            port map(clk => clk, 
                     rst => rst, 
                     d   => puppich_out_i(i),
                     q   => puppi_out_i(i));
    end generate gen_puppich_delay;

    puppi_out_i(NTKSORTED+NCALOSORTED-1 downto NTKSORTED) <= puppine_out_i;

    puppi2out: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                puppi_out   <= (others => (others => '0'));
                puppi_valid <= '0';
            else
                if puppine_done_i = '1' then
                    puppi_valid <= '1';
                    puppi_out <= puppi_out_i;
                end if;
            end if;
            puppi_done <= puppine_done_i;
        end if;
    end process puppi2out;

end Behavioral;
