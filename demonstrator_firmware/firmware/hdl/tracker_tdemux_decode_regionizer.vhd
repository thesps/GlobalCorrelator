library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.regionizer_data.all;

entity tracker_tdemux_decode_regionizer is
    port(
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        links_in : IN w64s(NTKSECTORS*TDEMUX_FACTOR*TDEMUX_NTKFIBERS-1 downto 0);
        valid_in : IN STD_LOGIC_VECTOR(NTKSECTORS*TDEMUX_FACTOR*TDEMUX_NTKFIBERS-1 downto 0);
        tk_out : OUT w64s(NTKSTREAM-1 downto 0);
        newevent_out : OUT STD_LOGIC
    );
end tracker_tdemux_decode_regionizer;

architecture Behavioral of tracker_tdemux_decode_regionizer is
    signal tk_tdemux: w64s(NTKSECTORS*TDEMUX_FACTOR*TDEMUX_NTKFIBERS-1 downto 0) := (others => (others => '0'));
    signal tk_tdemux_valid   : std_logic_vector(NTKSECTORS*TDEMUX_FACTOR*TDEMUX_NTKFIBERS-1 downto 0) := (others => '0');

    signal tk_unpack:  w64s(NTKSECTORS*NTKFIBERS-1 downto 0) := (others => (others => '0'));
    signal tk_unpack_valid: std_logic_vector(NTKSECTORS*NTKFIBERS-1 downto 0) := (others => '0');
    signal tk_unpack_done:  std_logic_vector(NTKSECTORS-1 downto 0) := (others => '0');
    signal tk_in:  w64s(NTKSECTORS*NTKFIBERS-1 downto 0) := (others => (others => '0'));
    signal tk_input_was_valid, tk_regionizer_start, tk_newevent : std_logic := '0';

    signal tk_regionized:        w64s(NPFREGIONS-1 downto 0);
    signal tk_regionized_valid:  std_logic_vector(NPFREGIONS-1 downto 0) := (others => '0');
    signal tk_regionized_roll:   std_logic := '0';

begin 

    tdemuxer : entity work.tdemux_link_group
                    generic map(
                        NLINKS => NTKSECTORS*TDEMUX_NTKFIBERS,
                        FACTOR => TDEMUX_FACTOR)
                    port map(
                        clk => clk,
                        rst => rst,
                        links_in => links_in,
                        valid_in => valid_in,
                        tdemux_out => tk_tdemux,
                        tdemux_valid => tk_tdemux_valid);

    gen_unpack: for i in 0 to NTKSECTORS-1 generate
        unpacker : entity work.unpack_track_3to2
                        port map(    ap_clk => clk,
                                     ap_rst => '0',
                                     ap_start => '1',
                                     ap_done => tk_unpack_done(i),
                                     ap_idle => open,
                                     ap_ready => open,
                                     in1_V     => tk_tdemux(TDEMUX_FACTOR*i+0),
                                     in2_V     => tk_tdemux(TDEMUX_FACTOR*i+1),
                                     in3_V     => tk_tdemux(TDEMUX_FACTOR*i+2),
                                     in1_valid => tk_tdemux_valid(TDEMUX_FACTOR*i+0),
                                     in2_valid => tk_tdemux_valid(TDEMUX_FACTOR*i+1),
                                     in3_valid => tk_tdemux_valid(TDEMUX_FACTOR*i+2),
                                     out1_V => tk_unpack(NTKFIBERS*i+0),
                                     out2_V => tk_unpack(NTKFIBERS*i+1),
                                     out1_valid => tk_unpack_valid(NTKFIBERS*i+0),
                                     out2_valid => tk_unpack_valid(NTKFIBERS*i+1));
        end generate gen_unpack;

    input_links: process(clk)
    begin
        if rising_edge(clk) then
            -- for these we put some reset logic
            if rst = '1' then
                tk_input_was_valid  <= '0';
                tk_regionizer_start <= '0';
            else
                tk_input_was_valid  <=  tk_unpack_done(0) and tk_unpack_valid(0);
                tk_regionizer_start <= (tk_unpack_done(0) and tk_unpack_valid(0)) or tk_input_was_valid;
            end if;
            -- these run anyway
            tk_newevent <= (tk_unpack_done(0) and tk_unpack_valid(0)) and not(tk_input_was_valid);
            tk_in <= tk_unpack;
        end if;
    end process input_links;

    tk_regionizer : entity work.tk_regionizer 
            port map(ap_clk => clk, ap_rst => rst,
                         ap_start => tk_regionizer_start,
                         newevent => tk_newevent,
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
                         tracks_out_0_V => tk_regionized(0),
                         tracks_out_1_V => tk_regionized(1),
                         tracks_out_2_V => tk_regionized(2),
                         tracks_out_3_V => tk_regionized(3),
                         tracks_out_4_V => tk_regionized(4),
                         tracks_out_5_V => tk_regionized(5),
                         tracks_out_6_V => tk_regionized(6),
                         tracks_out_7_V => tk_regionized(7),
                         tracks_out_8_V => tk_regionized(8),
                         tracks_out_valid_0 => tk_regionized_valid(0),
                         tracks_out_valid_1 => tk_regionized_valid(1),
                         tracks_out_valid_2 => tk_regionized_valid(2),
                         tracks_out_valid_3 => tk_regionized_valid(3),
                         tracks_out_valid_4 => tk_regionized_valid(4),
                         tracks_out_valid_5 => tk_regionized_valid(5),
                         tracks_out_valid_6 => tk_regionized_valid(6),
                         tracks_out_valid_7 => tk_regionized_valid(7),
                         tracks_out_valid_8 => tk_regionized_valid(8),
                         newevent_out => tk_regionized_roll);

    post_regionizer : entity work.delay_sort_mux_stream
                generic map(NREGIONS => NPFREGIONS, 
                            NSORTED  => NTKSORTED,
                            NSTREAM  => NTKSTREAM,
                            OUTII    => PFII240,
                            DELAY    => TKDELAY,
                            SORT_NSTAGES => 2)
                port map(ap_clk => clk,
                         d_in => tk_regionized,
                         valid_in => tk_regionized_valid,
                         roll => tk_regionized_roll,
                         d_out => tk_out,
                         roll_out => newevent_out);

 end Behavioral;

