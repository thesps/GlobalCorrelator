library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.regionizer_data.all;

entity regionizer_mux_stream_cdc_pf_puppi is
    port(
            clk    : IN STD_LOGIC;
            clk240 : IN STD_LOGIC;
            rst    : IN STD_LOGIC;
            rst240 : IN STD_LOGIC;
            --ap_start : IN STD_LOGIC;
            --ap_done : OUT STD_LOGIC;
            --ap_idle : OUT STD_LOGIC;
            --ap_ready : OUT STD_LOGIC;
            links_in : IN w64s(NTKSECTORS*NTKFIBERS + NCALOSECTORS*NCALOFIBERS + NMUFIBERS downto 0);
            valid_in : IN STD_LOGIC_VECTOR(NTKSECTORS*NTKFIBERS + NCALOSECTORS*NCALOFIBERS + NMUFIBERS downto 0);
            regionizer_out   : OUT w64s(NTKSORTED + NCALOSORTED + NMUSORTED - 1 downto 0);
            regionizer_warm  : OUT STD_LOGIC;
            regionizer_good  : OUT STD_LOGIC;

            tk_out_240   : OUT w64s(NTKSTREAM-1 downto 0);
            tk_all_240   : OUT w64s(NTKSORTED-1 downto 0);
            tk_done_240  : OUT STD_LOGIC;
            tk_empty_240 : OUT STD_LOGIC;

            pf_in_240    : OUT w64s(NTKSORTED + NCALOSORTED + NMUSORTED - 1 downto 0);
            pf_out_240   : OUT w64s(NTKSORTED + NCALOSORTED + NMUSORTED - 1 downto 0);
            pf_start_240 : OUT STD_LOGIC;
            pf_done_240  : OUT STD_LOGIC;
            pf_ready_240 : OUT STD_LOGIC;
            pf_idle_240  : OUT STD_LOGIC;
            pf_out_360   : OUT w64s(NTKSORTED + NCALOSORTED + NMUSORTED - 1 downto 0);
            pf_start_360 : OUT STD_LOGIC;
            pf_read_360  : OUT STD_LOGIC;
            pf_done_360  : OUT STD_LOGIC;
            pf_empty_360 : OUT STD_LOGIC;
           --puppi_out   : OUT w64s(NTKSORTED+NCALOSORTED - 1 downto 0);
           --puppi_done  : OUT STD_LOGIC;
           --puppi_valid : OUT STD_LOGIC;
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
            puppine_idle  : OUT STD_LOGIC;
            puppi_out_360   : OUT w64s(NTKSORTED+NCALOSORTED-1 downto 0);
            puppi_start_360 : OUT STD_LOGIC;
            puppi_read_360  : OUT STD_LOGIC;
            puppi_done_360  : OUT STD_LOGIC
    );

--  Port ( );
end regionizer_mux_stream_cdc_pf_puppi;

architecture Behavioral of regionizer_mux_stream_cdc_pf_puppi is
    constant PV_LINK  : natural := NTKSECTORS*NTKFIBERS + NCALOSECTORS*NCALOFIBERS + NMUFIBERS;
    constant NREGIONIZER_OUT : natural := NTKSORTED + NCALOSORTED + NMUSORTED;

    constant NCLK_WRITE360 : natural := NPFREGIONS * PFII240;
    constant NCLK_WAIT360  : natural := NPFREGIONS * (PFII-PFII240);
    constant LATENCY_PF      : natural := 35; -- at 240 MHz
    constant LATENCY_PUPPINE : natural := 36; -- at 240 MHz
    constant LATENCY_PUPPICH : natural :=  3; -- at 240 MHz
    constant LATENCY_REGIONIZER : natural := 54+10;

    signal input_was_valid, newevent, newevent_out : std_logic := '0';

    signal tk_in:  w64s(NTKSECTORS*NTKFIBERS-1 downto 0) := (others => (others => '0'));
    signal calo_in:  w64s(NCALOSECTORS*NCALOFIBERS-1 downto 0) := (others => (others => '0'));
    signal mu_in:  w64s(NMUFIBERS-1 downto 0) := (others => (others => '0'));

    signal tk_out,   tk_in240,   tk_out240:   w64s(NTKSTREAM-1 downto 0) := (others => (others => '0'));
    signal calo_out, calo_in240, calo_out240: w64s(NCALOSTREAM-1 downto 0) := (others => (others => '0'));
    signal mu_out,   mu_in240,   mu_out240:   w64s(NMUSTREAM-1 downto 0) := (others => (others => '0'));
   
    signal regionizer_start, regionizer_out_warmup, regionizer_out_write: std_logic := '0';
    signal regionizer_count : natural range 0 to NCLK_WRITE360-1 := 0;

    signal alltk_240:   w64s(NTKSORTED-1 downto 0)   := (others => (others => '0'));
    signal allcalo_240: w64s(NCALOSORTED-1 downto 0) := (others => (others => '0'));
    signal allmu_240:   w64s(NMUSORTED-1 downto 0)   := (others => (others => '0'));
    signal tk_empty240  : std_logic_vector(NTKSTREAM-1 downto 0) := (others => '0');
    signal alltk_240_done, allcalo_240_done, allmu_240_done, empty240not : std_logic := '0'; 

    signal pf_in    : w64s(NPFTOT-1 downto 0) := (others => (others => '0'));
    signal pf_out_i : w64s(NPFTOT-1 downto 0) := (others => (others => '0'));
    signal pf_start_i, pf_done_i, pf_idle_i, pf_ready_i : std_logic := '0';

    signal pf_stream, pf_stream360 : w64s(NPFSTREAM-1 downto 0) := (others => (others => '0'));
    signal pf_read360 : std_logic := '0';
    signal pf_write240, pf_read360_start : std_logic_vector(63 downto 0) := (others => '0');
    signal tk_delay_out: w64s(NTKSORTED-1 downto 0) := (others => (others => '0'));
    
    signal puppi_start_i : std_logic := '0';
    
    signal puppich_in    : w64s(NTKSORTED downto 0) := (others => (others => '0'));
    signal puppich_out_i : w64s(NTKSORTED-1 downto 0) := (others => (others => '0'));
    signal puppich_done_i, puppich_idle_i, puppich_ready_i : std_logic := '0';
    
    signal puppine_in    : w64s(NTKSORTED+NCALOSORTED downto 0) := (others => (others => '0'));
    signal puppine_out_i : w64s(NCALOSORTED-1 downto 0) := (others => (others => '0'));
    signal puppine_done_i, puppine_idle_i, puppine_ready_i : std_logic := '0';

    signal puppich_stream, puppich_stream360 : w64s(NTKSTREAM-1 downto 0)  := (others => (others => '0'));
    signal puppine_stream, puppine_stream360 : w64s(NCALOSTREAM-1 downto 0)  := (others => (others => '0'));
    signal puppi_read360 : std_logic := '0';
    signal puppich_write240, puppine_write240, puppi_read360_start : std_logic_vector(63 downto 0) := (others => '0');

--
--signal puppi_out_i : w64s(NTKSORTED+NCALOSORTED-1 downto 0) := (others => (others => '0'));
--signal puppi_done_i, puppi_valid_i : std_logic := '0';
--
    signal pv_input_was_valid : std_logic := '0';
    signal vtx_write360 : std_logic := '0'; 
    signal vtx_read240  : std_logic_vector(63 downto 0) := (others => '0'); 
    signal vtx360, vtx240 : word64 := (others => '0'); 
    signal vtx_count360 : natural range 0 to NCLK_WRITE360-1 := 0;
begin
    
    input_links: process(clk)
    begin
        if rising_edge(clk) then
            -- for these we put some reset logic
            if rst = '1' then
                input_was_valid  <= '0';
                regionizer_start <= '0';
            else
                input_was_valid  <= valid_in(0);
                regionizer_start <= valid_in(0) or input_was_valid;
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

    input_link_pv: process(clk)
    begin
        if rising_edge(clk) then
            -- for these we put some reset logic
            if rst = '1' then
                pv_input_was_valid <= '0';
                vtx_write360 <= '0';
            else
                pv_input_was_valid <= valid_in(PV_LINK);
                if valid_in(PV_LINK) = '1' and pv_input_was_valid = '0' then
                    vtx360 <= links_in(PV_LINK);
                    vtx_count360 <= 0;
                    vtx_write360 <= '1';
                else
                    if vtx_count360 = NCLK_WRITE360-1 then
                        vtx_write360 <= '0';
                    else
                        vtx_count360 <= vtx_count360 + 1;
                    end if;
                end if;
            end if;
        end if;
    end process input_link_pv;

    regionizer : entity work.full_regionizer_mux_stream
        generic map(MU_ETA_CENTER => 460)
        port map(ap_clk => clk, 
                 ap_rst => rst, 
                 ap_start => '1',
                 --ap_ready => ready,
                 --ap_idle =>  idle,
                 --ap_done => done,
                 tracks_start => regionizer_start,
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
                 calo_start => regionizer_start,
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
                 mu_start => regionizer_start,
                 mu_newevent => newevent,
                 mu_in_0_V => mu_in(0),
                 mu_in_1_V => mu_in(1),
                 tracks_out => tk_out,
                 calo_out   => calo_out,
                 mu_out     => mu_out,
                 newevent_out => newevent_out
             );
    -- expected output order is tracks, calo, muons, so we re-arrange pf-in
    regionizer_out(NTKSTREAM-1 downto 0) <= tk_in240;
    regionizer_out(NTKSTREAM+NCALOSTREAM-1 downto NTKSTREAM) <= calo_in240;
    regionizer_out(NTKSTREAM+NCALOSTREAM+NMUSTREAM-1 downto NCALOSTREAM+NTKSTREAM) <= mu_in240;
    regionizer_good <= regionizer_out_write;
    regionizer_warm <= regionizer_out_warmup;

    regio2cdc: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                regionizer_out_warmup <= '0';
                regionizer_out_write  <= '0';
            else
                if newevent_out = '1' then
                    -- if warmed up, start streaming out. otherwise, just warm up
                    if regionizer_out_warmup = '1' then
                        regionizer_count      <= 0;
                        regionizer_out_write  <= '1';
                    else
                        regionizer_out_warmup <= '1'; 
                        regionizer_out_write  <= '0';
                    end if;
                else
                    -- write out for NCLK_WRITE360 clocks, then stop
                    if regionizer_out_write = '1' then
                        if regionizer_count = NCLK_WRITE360-1 then
                            regionizer_out_write <= '0';
                            regionizer_count <= 0;
                        else
                            regionizer_count <= regionizer_count + 1;
                            regionizer_out_write  <= '1';
                        end if;
                    end if;
                end if;
            end if;
            tk_in240   <= tk_out;
            calo_in240 <= calo_out;
            mu_in240   <= mu_out;
        end if;
    end process regio2cdc;

    gen_cdc_tk: for i in 0 to NTKSTREAM-1 generate
        tk_cdc: entity work.cdc_bram_fifo
            port map(clk_in => clk, clk_out => clk240, rst_in => rst,
                     data_in  => tk_in240(i),
                     data_out => tk_out240(i),
                     wr_en    => regionizer_out_write,
                     rd_en    => '1',
                     rderr    => tk_empty240(i));
    end generate gen_cdc_tk;
    gen_cdc_calo: for i in 0 to NCALOSTREAM-1 generate
        calo_cdc: entity work.cdc_bram_fifo
            port map(clk_in => clk, clk_out => clk240, rst_in => rst,
                     data_in  => calo_in240(i),
                     data_out => calo_out240(i),
                     wr_en    => regionizer_out_write,
                     rd_en    => '1',
                     rderr    => open);
    end generate gen_cdc_calo;
    gen_cdc_mu: for i in 0 to NMUSTREAM-1 generate
        mu_cdc: entity work.cdc_bram_fifo
            port map(clk_in => clk, clk_out => clk240, rst_in => rst,
                     data_in  => mu_in240(i),
                     data_out => mu_out240(i),
                     wr_en    => regionizer_out_write,
                     rd_en    => '1',
                     rderr    => open);
     end generate gen_cdc_mu;
    
     empty240not <= not(tk_empty240(0));
     s2p_tk: entity work.serial2parallel
                    generic map(NITEMS => NTKSORTED, NSTREAM => NTKSTREAM, NREAD => PFII240)
                    port map(ap_clk   => clk240,
                             ap_start => empty240not,
                             data_in  => tk_out240,
                             valid_in => (others => '1'),
                             data_out  => alltk_240,
                             valid_out => open,
                             ap_done   => alltk_240_done);
     s2p_calo: entity work.serial2parallel
                    generic map(NITEMS => NCALOSORTED, NSTREAM => NCALOSTREAM, NREAD => PFII240)
                    port map(ap_clk   => clk240,
                             ap_start => empty240not,
                             data_in  => calo_out240,
                             valid_in => (others => '1'),
                             data_out  => allcalo_240,
                             valid_out => open,
                             ap_done   => allcalo_240_done);
     s2p_mu: entity work.serial2parallel
                    generic map(NITEMS => NMUSORTED, NSTREAM => NMUSTREAM, NREAD => PFII240)
                    port map(ap_clk   => clk240,
                             ap_start => empty240not,
                             data_in  => mu_out240,
                             valid_in => (others => '1'),
                             data_out  => allmu_240,
                             valid_out => open,
                             ap_done   => allmu_240_done);

    tk_out_240 <= tk_out240;
    tk_all_240 <= alltk_240;
    tk_done_240 <= alltk_240_done;
    tk_empty_240 <= empty240not; --tk_empty240(0);

    all2pf : process(clk240)
        begin
            if rising_edge(clk240) then
                if alltk_240_done = '1' then
                    pf_in(NCALOSORTED-1 downto 0) <= allcalo_240;
                    pf_in(NCALOSORTED+NTKSORTED-1 downto NCALOSORTED) <= alltk_240;
                    pf_in(NCALOSORTED+NTKSORTED+NMUSORTED-1 downto NCALOSORTED+NTKSORTED) <= allmu_240;
                    pf_start_i <= '1'; -- should also go to zero if empty240 delayed
                end if;
            end if;
        end process all2pf;
 
    pfblock : entity work.packed_pfalgo2hgc
        port map(ap_clk => clk240, 
                 ap_rst => rst240, 
                 ap_start => pf_start_i,
                 ap_ready => pf_ready_i,
                 ap_idle =>  pf_idle_i,
                 ap_done =>  pf_done_i,
                 input_0_V => pf_in(0),
                 input_1_V => pf_in(1),
                 input_2_V => pf_in(2),
                 input_3_V => pf_in(3),
                 input_4_V => pf_in(4),
                 input_5_V => pf_in(5),
                 input_6_V => pf_in(6),
                 input_7_V => pf_in(7),
                 input_8_V => pf_in(8),
                 input_9_V => pf_in(9),
                 input_10_V => pf_in(10),
                 input_11_V => pf_in(11),
                 input_12_V => pf_in(12),
                 input_13_V => pf_in(13),
                 input_14_V => pf_in(14),
                 input_15_V => pf_in(15),
                 input_16_V => pf_in(16),
                 input_17_V => pf_in(17),
                 input_18_V => pf_in(18),
                 input_19_V => pf_in(19),
                 input_20_V => pf_in(20),
                 input_21_V => pf_in(21),
                 input_22_V => pf_in(22),
                 input_23_V => pf_in(23),
                 input_24_V => pf_in(24),
                 input_25_V => pf_in(25),
                 input_26_V => pf_in(26),
                 input_27_V => pf_in(27),
                 input_28_V => pf_in(28),
                 input_29_V => pf_in(29),
                 input_30_V => pf_in(30),
                 input_31_V => pf_in(31),
                 input_32_V => pf_in(32),
                 input_33_V => pf_in(33),
                 input_34_V => pf_in(34),
                 input_35_V => pf_in(35),
                 input_36_V => pf_in(36),
                 input_37_V => pf_in(37),
                 input_38_V => pf_in(38),
                 input_39_V => pf_in(39),
                 input_40_V => pf_in(40),
                 input_41_V => pf_in(41),
                 input_42_V => pf_in(42),
                 input_43_V => pf_in(43),
                 input_44_V => pf_in(44),
                 input_45_V => pf_in(45),
                 input_46_V => pf_in(46),
                 input_47_V => pf_in(47),
                 input_48_V => pf_in(48),
                 input_49_V => pf_in(49),
                 input_50_V => pf_in(50),
                 input_51_V => pf_in(51),
                 input_52_V => pf_in(52),
                 input_53_V => pf_in(53),
                 output_0_V => pf_out_i(0),
                 output_1_V => pf_out_i(1),
                 output_2_V => pf_out_i(2),
                 output_3_V => pf_out_i(3),
                 output_4_V => pf_out_i(4),
                 output_5_V => pf_out_i(5),
                 output_6_V => pf_out_i(6),
                 output_7_V => pf_out_i(7),
                 output_8_V => pf_out_i(8),
                 output_9_V => pf_out_i(9),
                 output_10_V => pf_out_i(10),
                 output_11_V => pf_out_i(11),
                 output_12_V => pf_out_i(12),
                 output_13_V => pf_out_i(13),
                 output_14_V => pf_out_i(14),
                 output_15_V => pf_out_i(15),
                 output_16_V => pf_out_i(16),
                 output_17_V => pf_out_i(17),
                 output_18_V => pf_out_i(18),
                 output_19_V => pf_out_i(19),
                 output_20_V => pf_out_i(20),
                 output_21_V => pf_out_i(21),
                 output_22_V => pf_out_i(22),
                 output_23_V => pf_out_i(23),
                 output_24_V => pf_out_i(24),
                 output_25_V => pf_out_i(25),
                 output_26_V => pf_out_i(26),
                 output_27_V => pf_out_i(27),
                 output_28_V => pf_out_i(28),
                 output_29_V => pf_out_i(29),
                 output_30_V => pf_out_i(30),
                 output_31_V => pf_out_i(31),
                 output_32_V => pf_out_i(32),
                 output_33_V => pf_out_i(33),
                 output_34_V => pf_out_i(34),
                 output_35_V => pf_out_i(35),
                 output_36_V => pf_out_i(36),
                 output_37_V => pf_out_i(37),
                 output_38_V => pf_out_i(38),
                 output_39_V => pf_out_i(39),
                 output_40_V => pf_out_i(40),
                 output_41_V => pf_out_i(41),
                 output_42_V => pf_out_i(42),
                 output_43_V => pf_out_i(43),
                 output_44_V => pf_out_i(44),
                 output_45_V => pf_out_i(45),
                 output_46_V => pf_out_i(46),
                 output_47_V => pf_out_i(47),
                 output_48_V => pf_out_i(48),
                 output_49_V => pf_out_i(49),
                 output_50_V => pf_out_i(50),
                 output_51_V => pf_out_i(51),
                 output_52_V => pf_out_i(52),
                 output_53_V => pf_out_i(53)
            );
        pf_out_240(NPFTOT-1 downto 0) <= pf_out_i;
        pf_in_240 <= pf_in;
        pf_start_240 <= pf_start_i;
        pf_idle_240 <= pf_idle_i;
        pf_ready_240 <= pf_ready_i;
        pf_done_240 <= pf_done_i;

     pf_write240_delay_start: entity work.bram_delay -- FIXME wasteful BRAM36 for a single bit
     generic map(DELAY => LATENCY_PF + 2) 
           port map(clk => clk240, rst => rst240, 
                    d(0) => pf_start_i,
                    d(63 downto 1) => (others => '0'), 
                    q => pf_write240);    

     pf2cdc : entity work.parallel2serial
                generic map(NITEMS  => NPFTOT, NSTREAM => NPFSTREAM)
                port map( ap_clk => clk240,
                          roll   => pf_done_i,
                          data_in  => pf_out_i,
                          valid_in => (others => '1'),
                          data_out  => pf_stream,
                          valid_out => open,
                          roll_out  => open);

    gen_pf_cdc: for i in NPFSTREAM-1 downto 0 generate
        pf_cdc: entity work.cdc_bram_fifo
                    port map(clk_in => clk240, clk_out => clk, rst_in => rst240,
                     data_in  => pf_stream(i),
                     data_out => pf_stream360(i),
                     wr_en    => pf_write240(0),
                     rd_en    => pf_read360,
                     empty    => pf_empty_360);
     end generate gen_pf_cdc;

     pf_read360_delay_start: entity work.bram_delay -- FIXME wasteful BRAM36 for a single bit
                                                    -- in 240 MHz domain, spend PF latency + 1 
                                                    --                     + 2*6 for the two CDC 
                                                    --                     + 4 for serial to parallel
                                                    -- in 360 MHz domain, wait for regionizer +
     generic map(DELAY => LATENCY_REGIONIZER + ((LATENCY_PF + 4 + 12 + 3)*3)/2 + 5) -- FIXME overconservative, to be tuned
           port map(clk => clk, rst => rst, 
                    d(0) => regionizer_out_warmup,
                    d(63 downto 1) => (others => '0'), 
                    q => pf_read360_start);

     pf_unpack: entity work.serial2parallel
                    generic map(NITEMS => NPFTOT, NSTREAM => NPFSTREAM, NREAD => PFII240, NWAIT => 2)
                    port map(ap_clk   => clk,
                             ap_start => pf_read360_start(0),
                             data_in  => pf_stream360,
                             valid_in => (others => '1'),
                             data_out  => pf_out_360,
                             valid_out => open,
                             ap_done   => pf_done_360,
                             rden_out  => pf_read360
                             );
        pf_start_360 <= pf_read360_start(0);
        pf_read_360 <= pf_read360;

    vtx_read_delay : entity work.bram_delay
        generic map(DELAY => LATENCY_PF)
        port map(clk => clk240, 
                 rst => rst240, 
                 d(0)           => pf_start_i,
                 d(63 downto 1) => (others => '0'),
                 q   => vtx_read240);

    vtx_delay_cdc: entity work.cdc_bram_fifo
            port map(clk_in => clk, clk_out => clk240, rst_in => rst,
                     data_in  => vtx360,
                     data_out => vtx240,
                     wr_en    => vtx_write360,
                     rd_en    => vtx_read240(0));
 
    gen_tk_delay: for i in 0 to NTKSORTED-1 generate
         tk_delay: entity work.bram_delay
                generic map(DELAY => LATENCY_PF + 1)
                port map(clk => clk240, 
                         rst => rst240, 
                         d   => alltk_240(i),
                         q   => tk_delay_out(i));
     end generate gen_tk_delay;
 

     pf2puppi: process(clk240)
     begin
         if rising_edge(clk240) then
             if rst240 = '1' then
                 puppi_start_i <= '0';
                 puppich_in <= (others => (others => '0'));
                 puppine_in <= (others => (others => '0'));
             else
                 if pf_done_i = '1' then
                     puppi_start_i <= '1';
                     puppich_in(NTKSORTED downto 1) <= pf_out_i(NTKSORTED-1 downto 0);
                     puppich_in(0)                  <= vtx240;  
                     puppine_in(NTKSORTED-1 downto 0) <= tk_delay_out; 
                     puppine_in(NTKSORTED)            <= vtx240; 
                     puppine_in(NTKSORTED+NCALOSORTED downto NTKSORTED+1) <= pf_out_i(NTKSORTED+NCALOSORTED-1 downto NTKSORTED);
                 end if;
             end if;
         end if;
     end process pf2puppi;
   
     puppichsblock : entity work.packed_linpuppi_chs
         port map(ap_clk => clk240, 
                  ap_rst => rst240, 
                  ap_start => puppi_start_i,
                  ap_ready => puppich_ready_i,
                  ap_idle =>  puppich_idle_i,
                  ap_done =>  puppich_done_i,
                  input_0_V => puppich_in(0),
                  input_1_V => puppich_in(1),
                  input_2_V => puppich_in(2),
                  input_3_V => puppich_in(3),
                  input_4_V => puppich_in(4),
                  input_5_V => puppich_in(5),
                  input_6_V => puppich_in(6),
                  input_7_V => puppich_in(7),
                  input_8_V => puppich_in(8),
                  input_9_V => puppich_in(9),
                  input_10_V => puppich_in(10),
                  input_11_V => puppich_in(11),
                  input_12_V => puppich_in(12),
                  input_13_V => puppich_in(13),
                  input_14_V => puppich_in(14),
                  input_15_V => puppich_in(15),
                  input_16_V => puppich_in(16),
                  input_17_V => puppich_in(17),
                  input_18_V => puppich_in(18),
                  input_19_V => puppich_in(19),
                  input_20_V => puppich_in(20),
                  input_21_V => puppich_in(21),
                  input_22_V => puppich_in(22),
                  input_23_V => puppich_in(23),
                  input_24_V => puppich_in(24),
                  input_25_V => puppich_in(25),
                  input_26_V => puppich_in(26),
                  input_27_V => puppich_in(27),
                  input_28_V => puppich_in(28),
                  input_29_V => puppich_in(29),
                  input_30_V => puppich_in(30),
                  output_0_V => puppich_out_i(0),
                  output_1_V => puppich_out_i(1),
                  output_2_V => puppich_out_i(2),
                  output_3_V => puppich_out_i(3),
                  output_4_V => puppich_out_i(4),
                  output_5_V => puppich_out_i(5),
                  output_6_V => puppich_out_i(6),
                  output_7_V => puppich_out_i(7),
                  output_8_V => puppich_out_i(8),
                  output_9_V => puppich_out_i(9),
                  output_10_V => puppich_out_i(10),
                  output_11_V => puppich_out_i(11),
                  output_12_V => puppich_out_i(12),
                  output_13_V => puppich_out_i(13),
                  output_14_V => puppich_out_i(14),
                  output_15_V => puppich_out_i(15),
                  output_16_V => puppich_out_i(16),
                  output_17_V => puppich_out_i(17),
                  output_18_V => puppich_out_i(18),
                  output_19_V => puppich_out_i(19),
                  output_20_V => puppich_out_i(20),
                  output_21_V => puppich_out_i(21),
                  output_22_V => puppich_out_i(22),
                  output_23_V => puppich_out_i(23),
                  output_24_V => puppich_out_i(24),
                  output_25_V => puppich_out_i(25),
                  output_26_V => puppich_out_i(26),
                  output_27_V => puppich_out_i(27),
                  output_28_V => puppich_out_i(28),
                  output_29_V => puppich_out_i(29)
             );
         puppich_start <= puppi_start_i;
         puppich_idle <= puppich_idle_i;
         puppich_ready <= puppich_ready_i;
         d_puppich_in <= puppich_in;
   
     puppiblock : entity work.packed_linpuppiNoCrop
         port map(ap_clk => clk240, 
                  ap_rst => rst240, 
                  ap_start => puppi_start_i,
                  ap_ready => puppine_ready_i,
                  ap_idle =>  puppine_idle_i,
                  ap_done =>  puppine_done_i,
                  input_0_V => puppine_in(0),
                  input_1_V => puppine_in(1),
                  input_2_V => puppine_in(2),
                  input_3_V => puppine_in(3),
                  input_4_V => puppine_in(4),
                  input_5_V => puppine_in(5),
                  input_6_V => puppine_in(6),
                  input_7_V => puppine_in(7),
                  input_8_V => puppine_in(8),
                  input_9_V => puppine_in(9),
                  input_10_V => puppine_in(10),
                  input_11_V => puppine_in(11),
                  input_12_V => puppine_in(12),
                  input_13_V => puppine_in(13),
                  input_14_V => puppine_in(14),
                  input_15_V => puppine_in(15),
                  input_16_V => puppine_in(16),
                  input_17_V => puppine_in(17),
                  input_18_V => puppine_in(18),
                  input_19_V => puppine_in(19),
                  input_20_V => puppine_in(20),
                  input_21_V => puppine_in(21),
                  input_22_V => puppine_in(22),
                  input_23_V => puppine_in(23),
                  input_24_V => puppine_in(24),
                  input_25_V => puppine_in(25),
                  input_26_V => puppine_in(26),
                  input_27_V => puppine_in(27),
                  input_28_V => puppine_in(28),
                  input_29_V => puppine_in(29),
                  input_30_V => puppine_in(30),
                  input_31_V => puppine_in(31),
                  input_32_V => puppine_in(32),
                  input_33_V => puppine_in(33),
                  input_34_V => puppine_in(34),
                  input_35_V => puppine_in(35),
                  input_36_V => puppine_in(36),
                  input_37_V => puppine_in(37),
                  input_38_V => puppine_in(38),
                  input_39_V => puppine_in(39),
                  input_40_V => puppine_in(40),
                  input_41_V => puppine_in(41),
                  input_42_V => puppine_in(42),
                  input_43_V => puppine_in(43),
                  input_44_V => puppine_in(44),
                  input_45_V => puppine_in(45),
                  input_46_V => puppine_in(46),
                  input_47_V => puppine_in(47),
                  input_48_V => puppine_in(48),
                  input_49_V => puppine_in(49),
                  input_50_V => puppine_in(50),
                  output_0_V => puppine_out_i(0),
                  output_1_V => puppine_out_i(1),
                  output_2_V => puppine_out_i(2),
                  output_3_V => puppine_out_i(3),
                  output_4_V => puppine_out_i(4),
                  output_5_V => puppine_out_i(5),
                  output_6_V => puppine_out_i(6),
                  output_7_V => puppine_out_i(7),
                  output_8_V => puppine_out_i(8),
                  output_9_V => puppine_out_i(9),
                  output_10_V => puppine_out_i(10),
                  output_11_V => puppine_out_i(11),
                  output_12_V => puppine_out_i(12),
                  output_13_V => puppine_out_i(13),
                  output_14_V => puppine_out_i(14),
                  output_15_V => puppine_out_i(15),
                  output_16_V => puppine_out_i(16),
                  output_17_V => puppine_out_i(17),
                  output_18_V => puppine_out_i(18),
                  output_19_V => puppine_out_i(19)
             );
         puppine_start <= puppi_start_i;
         puppine_idle <= puppine_idle_i;
         puppine_ready <= puppine_ready_i;
         d_puppine_in <= puppine_in;
   
     puppich2out: process(clk240)
     begin
         if rising_edge(clk240) then
             if rst240 = '1' then
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
  
     puppine2out: process(clk240)
     begin
         if rising_edge(clk240) then
             if rst240 = '1' then
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

     puppich_write240_delay_start: entity work.bram_delay 
     generic map(DELAY => LATENCY_PUPPICH + 2) 
           port map(clk => clk240, rst => rst240, 
                    d(0) => puppi_start_i,
                    d(63 downto 1) => (others => '0'), 
                    q => puppich_write240);    

     puppich2cdc : entity work.parallel2serial
                generic map(NITEMS  => NTKSORTED, NSTREAM => NTKSTREAM)
                port map( ap_clk => clk240,
                          roll   => puppich_done_i,
                          data_in  => puppich_out_i,
                          valid_in => (others => '1'),
                          data_out  => puppich_stream,
                          valid_out => open,
                          roll_out  => open);

    gen_puppich_cdc: for i in NTKSTREAM-1 downto 0 generate
        puppich_cdc: entity work.cdc_bram_fifo
                    port map(clk_in => clk240, clk_out => clk, rst_in => rst240,
                     data_in  => puppich_stream(i),
                     data_out => puppich_stream360(i),
                     wr_en    => puppich_write240(0),
                     rd_en    => puppi_read360,
                     empty    => open);
     end generate gen_puppich_cdc;

     puppine_write240_delay_start: entity work.bram_delay 
     generic map(DELAY => LATENCY_PUPPINE + 2) 
           port map(clk => clk240, rst => rst240, 
                    d(0) => puppi_start_i,
                    d(63 downto 1) => (others => '0'), 
                    q => puppine_write240);    

     puppine2cdc : entity work.parallel2serial
                generic map(NITEMS  => NCALOSORTED, NSTREAM => NCALOSTREAM)
                port map( ap_clk => clk240,
                          roll   => puppine_done_i,
                          data_in  => puppine_out_i,
                          valid_in => (others => '1'),
                          data_out  => puppine_stream,
                          valid_out => open,
                          roll_out  => open);

    gen_puppine_cdc: for i in NCALOSTREAM-1 downto 0 generate
        puppine_cdc: entity work.cdc_bram_fifo
                    port map(clk_in => clk240, clk_out => clk, rst_in => rst240,
                     data_in  => puppine_stream(i),
                     data_out => puppine_stream360(i),
                     wr_en    => puppine_write240(0),
                     rd_en    => puppi_read360,
                     empty    => open);
     end generate gen_puppine_cdc;

     puppi_read360_delay_start: entity work.bram_delay -- FIXME wasteful BRAM36 for a single bit
     generic map(DELAY => LATENCY_REGIONIZER + ((LATENCY_PF + LATENCY_PUPPINE + 4 + 12 + 3)*3)/2 + 5) -- FIXME overconservative, to be tuned
           port map(clk => clk, rst => rst, 
                    d(0) => regionizer_out_warmup,
                    d(63 downto 1) => (others => '0'), 
                    q => puppi_read360_start);

     puppich_unpack: entity work.serial2parallel
                    generic map(NITEMS => NTKSORTED, NSTREAM => NTKSTREAM, NREAD => PFII240, NWAIT => 2)
                    port map(ap_clk   => clk,
                             ap_start => puppi_read360_start(0),
                             data_in  => puppich_stream360,
                             valid_in => (others => '1'),
                             data_out  => puppi_out_360(NTKSORTED-1 downto 0),
                             valid_out => open,
                             ap_done   => puppi_done_360,
                             rden_out  => puppi_read360
                             );
     puppine_unpack: entity work.serial2parallel
                    generic map(NITEMS => NCALOSORTED, NSTREAM => NCALOSTREAM, NREAD => PFII240, NWAIT => 2)
                    port map(ap_clk   => clk,
                             ap_start => puppi_read360_start(0),
                             data_in  => puppine_stream360,
                             valid_in => (others => '1'),
                             data_out  => puppi_out_360(NCALOSORTED+NTKSORTED-1 downto NTKSORTED),
                             valid_out => open,
                             ap_done   => open,
                             rden_out  => open
                             );
     puppi_start_360 <= puppi_read360_start(0);
     puppi_read_360  <= puppi_read360;
 
  
--   gen_puppich_delay: for i in 0 to NTKSORTED-1 generate
--       puppich_delay: entity work.bram_delay
--           generic map(DELAY => LATENCY_PUPPINE - LATENCY_PUPPICH)
--           port map(clk => clk, 
--                    rst => rst, 
--                    d   => puppich_out_i(i),
--                    q   => puppi_out_i(i));
--   end generate gen_puppich_delay;
--
--   puppi_out_i(NTKSORTED+NCALOSORTED-1 downto NTKSORTED) <= puppine_out_i;
--
--   puppi2out: process(clk)
--   begin
--       if rising_edge(clk) then
--           if rst = '1' then
--               puppi_out   <= (others => (others => '0'));
--               puppi_valid <= '0';
--           else
--               if puppine_done_i = '1' then
--                   puppi_valid <= '1';
--                   puppi_out <= puppi_out_i;
--               end if;
--           end if;
--           puppi_done <= puppine_done_i;
--       end if;
--   end process puppi2out;

end Behavioral;
