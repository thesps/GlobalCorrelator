library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.regionizer_data.all;

entity regionizer_mux_pf is
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
            pf_idle  : OUT STD_LOGIC
    );
end regionizer_mux_pf;

architecture Behavioral of regionizer_mux_pf is
    constant NPATTERNS_IN  : natural := NTKSECTORS*NTKFIBERS + NCALOSECTORS*NCALOFIBERS + NMUFIBERS + 1;
    constant NREGIONIZER_OUT : natural := NTKSORTED + NCALOSORTED + NMUSORTED;
    constant NPFTOT :          natural := NTKSORTED + NCALOSORTED + NMUSORTED;

    signal input_was_valid, newevent, newevent_out : std_logic := '0';

    signal tk_in:  w64s(NTKSECTORS*NTKFIBERS-1 downto 0) := (others => (others => '0'));
    signal tk_out: w64s(NTKSORTED-1 downto 0) := (others => (others => '0'));
    signal calo_in:  w64s(NCALOSECTORS*NCALOFIBERS-1 downto 0) := (others => (others => '0'));
    signal calo_out: w64s(NCALOSORTED-1 downto 0) := (others => (others => '0'));
    signal mu_in:  w64s(NMUFIBERS-1 downto 0) := (others => (others => '0'));
    signal mu_out: w64s(NMUSORTED-1 downto 0) := (others => (others => '0'));
    signal vtx_in: word64 := (others => '0');

    signal regionizer_start_i, regionizer_done_i : std_logic := '0';

    signal pf_in    : w64s(NPFTOT-1 downto 0) := (others => (others => '0'));
    signal pf_out_i : w64s(NPFTOT-1 downto 0) := (others => (others => '0'));
    signal pf_start_i, pf_warmup, pf_done_i, pf_idle_i, pf_ready_i : std_logic := '0';

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

    pfblock : entity work.packed_pfalgo2hgc
        port map(ap_clk => clk, 
                 ap_rst => rst, 
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
        pf_start <= pf_start_i;
        pf_done <= pf_done_i;
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
        end if;
    end process pf2out;

    
end Behavioral;
