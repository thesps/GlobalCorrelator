library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.regionizer_data.all;

entity muon_tdemux_decode_regionizer is
    generic(
            MU_ETA_CENTER : integer 
    );
    port(
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        links_in : IN w64s(TDEMUX_FACTOR*TDEMUX_NMUFIBERS-1 downto 0);
        valid_in : IN STD_LOGIC_VECTOR(TDEMUX_FACTOR*TDEMUX_NMUFIBERS-1 downto 0);
        mu_out : OUT w64s(NMUSTREAM-1 downto 0);
        newevent_out : OUT STD_LOGIC
    );
end muon_tdemux_decode_regionizer;

architecture Behavioral of muon_tdemux_decode_regionizer is
    signal mu_tdemux:   w64s(TDEMUX_FACTOR*TDEMUX_NMUFIBERS-1 downto 0) := (others => (others => '0'));
    signal mu_tdemux_valid   : std_logic_vector(TDEMUX_FACTOR*TDEMUX_NMUFIBERS-1 downto 0) := (others => '0');

    signal mu_unpack:  w64s(NMUFIBERS-1 downto 0) := (others => (others => '0'));
    signal mu_unpack_valid: std_logic_vector(NMUFIBERS-1 downto 0) := (others => '0');
    signal mu_unpack_done:  std_logic_vector(TDEMUX_NMUFIBERS-1 downto 0) := (others => '0');
    signal mu_in:  w64s(NMUFIBERS-1 downto 0) := (others => (others => '0'));
    signal mu_input_was_valid, mu_regionizer_start, mu_newevent : std_logic := '0';

    signal mu_regionized:        w64s(NPFREGIONS-1 downto 0);
    signal mu_regionized_valid:  std_logic_vector(NPFREGIONS-1 downto 0) := (others => '0');
    signal mu_regionized_roll:   std_logic := '0';

begin 

   tdemuxer : entity work.tdemux_link_group
                    generic map(
                        NLINKS => TDEMUX_NMUFIBERS,
                        FACTOR => TDEMUX_FACTOR)
                    port map(
                        clk => clk,
                        rst => rst,
                        links_in => links_in,
                        valid_in => valid_in,
                        tdemux_out => mu_tdemux,
                        tdemux_valid => mu_tdemux_valid);

    gen_unpack: for i in 0 to TDEMUX_NMUFIBERS-1 generate
        unpacker : entity work.unpack_mu_3to12
                        port map(    ap_clk => clk,
                                     ap_rst => '0',
                                     ap_start => '1',
                                     ap_done => mu_unpack_done(i),
                                     ap_idle => open,
                                     ap_ready => open,
                                     in1_V     => mu_tdemux(TDEMUX_FACTOR*i+0),
                                     in2_V     => mu_tdemux(TDEMUX_FACTOR*i+1),
                                     in3_V     => mu_tdemux(TDEMUX_FACTOR*i+2),
                                     in1_valid => mu_tdemux_valid(TDEMUX_FACTOR*i+0),
                                     in2_valid => mu_tdemux_valid(TDEMUX_FACTOR*i+1),
                                     in3_valid => mu_tdemux_valid(TDEMUX_FACTOR*i+2),
                                     out1_V => mu_unpack(NMUFIBERS*i+0),
                                     out2_V => mu_unpack(NMUFIBERS*i+1),
                                     out1_valid => mu_unpack_valid(NMUFIBERS*i+0),
                                     out2_valid => mu_unpack_valid(NMUFIBERS*i+1));
        end generate gen_unpack;

    input_links: process(clk)
    begin
        if rising_edge(clk) then
            -- for these we put some reset logic
            if rst = '1' then
                mu_input_was_valid  <= '0';
                mu_regionizer_start <= '0';
            else
                mu_input_was_valid  <=  mu_unpack_done(0) and mu_unpack_valid(0);
                mu_regionizer_start <= (mu_unpack_done(0) and mu_unpack_valid(0)) or mu_input_was_valid;
            end if;
            -- these run anyway
            mu_newevent <= (mu_unpack_done(0) and mu_unpack_valid(0)) and not(mu_input_was_valid);
            mu_in <= mu_unpack;
        end if;
    end process input_links;

    mu_regionizer : entity work.mu_regionizer 
                generic map(ETA_CENTER => MU_ETA_CENTER)
                port map(ap_clk => clk, ap_rst => rst,
                             ap_start => mu_regionizer_start,
                             newevent => mu_newevent,
                             mu_in_0_V => mu_in(0),
                             mu_in_1_V => mu_in(1),
                             mu_out_0_V => mu_regionized(0),
                             mu_out_1_V => mu_regionized(1),
                             mu_out_2_V => mu_regionized(2),
                             mu_out_3_V => mu_regionized(3),
                             mu_out_4_V => mu_regionized(4),
                             mu_out_5_V => mu_regionized(5),
                             mu_out_6_V => mu_regionized(6),
                             mu_out_7_V => mu_regionized(7),
                             mu_out_8_V => mu_regionized(8),
                             mu_out_valid_0 => mu_regionized_valid(0),
                             mu_out_valid_1 => mu_regionized_valid(1),
                             mu_out_valid_2 => mu_regionized_valid(2),
                             mu_out_valid_3 => mu_regionized_valid(3),
                             mu_out_valid_4 => mu_regionized_valid(4),
                             mu_out_valid_5 => mu_regionized_valid(5),
                             mu_out_valid_6 => mu_regionized_valid(6),
                             mu_out_valid_7 => mu_regionized_valid(7),
                             mu_out_valid_8 => mu_regionized_valid(8),
                             newevent_out => mu_regionized_roll);

    post_regionizer : entity work.delay_sort_mux_stream
                generic map(NREGIONS => NPFREGIONS, 
                            NSORTED  => NMUSORTED,
                            NSTREAM  => NMUSTREAM,
                            OUTII    => PFII240,
                            DELAY    => MUDELAY)
                port map(ap_clk => clk,
                         d_in => mu_regionized,
                         valid_in => mu_regionized_valid,
                         roll => mu_regionized_roll,
                         d_out => mu_out,
                         roll_out => newevent_out);

 end Behavioral;

