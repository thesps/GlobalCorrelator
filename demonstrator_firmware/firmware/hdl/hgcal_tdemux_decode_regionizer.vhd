library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.regionizer_data.all;

entity hgcal_tdemux_decode_regionizer is
    port(
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        links_in : IN w64s(NCALOSECTORS*TDEMUX_FACTOR*TDEMUX_NCALOFIBERS-1 downto 0);
        valid_in : IN STD_LOGIC_VECTOR(NCALOSECTORS*TDEMUX_FACTOR*TDEMUX_NCALOFIBERS-1 downto 0);
        calo_out : OUT w64s(NCALOSTREAM-1 downto 0);
        newevent_out : OUT STD_LOGIC
    );
end hgcal_tdemux_decode_regionizer;

architecture Behavioral of hgcal_tdemux_decode_regionizer is
    signal calo_tdemux: w64s(NCALOSECTORS*TDEMUX_FACTOR*TDEMUX_NCALOFIBERS-1 downto 0) := (others => (others => '0'));
    signal calo_tdemux_valid   : std_logic_vector(NCALOSECTORS*TDEMUX_FACTOR*TDEMUX_NCALOFIBERS-1 downto 0) := (others => '0');

    signal calo_unpack:  w64s(NCALOSECTORS*NCALOFIBERS-1 downto 0) := (others => (others => '0'));
    signal calo_unpack_valid: std_logic_vector(NCALOSECTORS*NCALOFIBERS-1 downto 0) := (others => '0');
    signal calo_unpack_done:  std_logic_vector(NCALOSECTORS*NCALOFIBERS-1 downto 0) := (others => '0');
    signal calo_in:  w64s(NCALOSECTORS*NCALOFIBERS-1 downto 0) := (others => (others => '0'));
    signal calo_input_was_valid, calo_regionizer_start, calo_newevent : std_logic := '0';

    signal calo_regionized:        w64s(NPFREGIONS-1 downto 0);
    signal calo_regionized_valid:  std_logic_vector(NPFREGIONS-1 downto 0) := (others => '0');
    signal calo_regionized_roll:   std_logic := '0';

begin 

    tdemuxer : entity work.tdemux_link_group
                    generic map(
                        NLINKS => NCALOSECTORS*TDEMUX_NCALOFIBERS,
                        FACTOR => TDEMUX_FACTOR)
                    port map(
                        clk => clk,
                        rst => rst,
                        links_in => links_in,
                        valid_in => valid_in,
                        tdemux_out => calo_tdemux,
                        tdemux_valid => calo_tdemux_valid);

    gen_unpack: for i in 0 to NCALOSECTORS*NCALOFIBERS-1 generate
        unpacker : entity work.unpack_hgcal_3to1
                        port map(    ap_clk => clk,
                                     ap_rst => '0',
                                     ap_start => '1',
                                     ap_done => calo_unpack_done(i),
                                     ap_idle => open,
                                     ap_ready => open,
                                     in1_V     => calo_tdemux(TDEMUX_FACTOR*i+0),
                                     in2_V     => calo_tdemux(TDEMUX_FACTOR*i+1),
                                     in3_V     => calo_tdemux(TDEMUX_FACTOR*i+2),
                                     in1_valid => calo_tdemux_valid(TDEMUX_FACTOR*i+0),
                                     in2_valid => calo_tdemux_valid(TDEMUX_FACTOR*i+1),
                                     in3_valid => calo_tdemux_valid(TDEMUX_FACTOR*i+2),
                                     out1_V     => calo_unpack(i),
                                     out1_valid => calo_unpack_valid(i));
        end generate gen_unpack;

    input_links: process(clk)
    begin
        if rising_edge(clk) then
            -- for these we put some reset logic
            if rst = '1' then
                calo_input_was_valid  <= '0';
                calo_regionizer_start <= '0';
            else
                calo_input_was_valid  <=  calo_unpack_done(0) and calo_unpack_valid(0);
                calo_regionizer_start <= (calo_unpack_done(0) and calo_unpack_valid(0)) or calo_input_was_valid;
            end if;
            -- these run anyway
            calo_newevent <= (calo_unpack_done(0) and calo_unpack_valid(0)) and not(calo_input_was_valid);
            calo_in <= calo_unpack;
        end if;
    end process input_links;

    calo_regionizer : entity work.calo_regionizer 
            port map(ap_clk => clk, ap_rst => rst,
                         ap_start => calo_regionizer_start,
                         newevent => calo_newevent,
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
                         calo_out_0_V => calo_regionized(0),
                         calo_out_1_V => calo_regionized(1),
                         calo_out_2_V => calo_regionized(2),
                         calo_out_3_V => calo_regionized(3),
                         calo_out_4_V => calo_regionized(4),
                         calo_out_5_V => calo_regionized(5),
                         calo_out_6_V => calo_regionized(6),
                         calo_out_7_V => calo_regionized(7),
                         calo_out_8_V => calo_regionized(8),
                         calo_out_valid_0 => calo_regionized_valid(0),
                         calo_out_valid_1 => calo_regionized_valid(1),
                         calo_out_valid_2 => calo_regionized_valid(2),
                         calo_out_valid_3 => calo_regionized_valid(3),
                         calo_out_valid_4 => calo_regionized_valid(4),
                         calo_out_valid_5 => calo_regionized_valid(5),
                         calo_out_valid_6 => calo_regionized_valid(6),
                         calo_out_valid_7 => calo_regionized_valid(7),
                         calo_out_valid_8 => calo_regionized_valid(8),
                         newevent_out => calo_regionized_roll);

    post_regionizer : entity work.delay_sort_mux_stream
                generic map(NREGIONS => NPFREGIONS, 
                            NSORTED  => NCALOSORTED,
                            NSTREAM  => NCALOSTREAM,
                            OUTII    => PFII240,
                            DELAY    => CALODELAY)
                port map(ap_clk => clk,
                         d_in => calo_regionized,
                         valid_in => calo_regionized_valid,
                         roll => calo_regionized_roll,
                         d_out => calo_out,
                         roll_out => newevent_out);

 end Behavioral;

