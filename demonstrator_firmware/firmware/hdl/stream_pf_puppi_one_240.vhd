library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.regionizer_data.all;

entity stream_pf_puppi_240 is
    generic(
        LATENCY_PF : natural
    );
    port(
            clk240 : IN STD_LOGIC;
            rst240 : IN STD_LOGIC;
            -- input at 240 MHz
            valid_in : IN STD_LOGIC; -- goes up when data arrives (and should stay up...)
            tk_in    : IN w64s(NTKSTREAM-1 downto 0);
            calo_in  : IN w64s(NCALOSTREAM-1 downto 0);
            mu_in    : IN w64s(NMUSTREAM-1 downto 0);
            -- streaming pf output
            pf_out   : OUT w64s(NPFSTREAM-1 downto 0);
            pf_valid : OUT STD_LOGIC; 
            pf_done  : OUT STD_LOGIC; -- goes up 1 clock at the beginning of a region
            -- vertexing input
            vtx_read : OUT STD_LOGIC; -- goes to 1 to request reading of VTX from CDC fifo
            vtx_in   : IN word64; 
            -- streaming puppi output
            puppich_out   : OUT w64s(NTKSTREAM-1 downto 0);
            puppich_valid : OUT STD_LOGIC;
            puppich_done  : OUT STD_LOGIC;
            puppine_out   : OUT w64s(NCALOSTREAM-1 downto 0);
            puppine_valid : OUT STD_LOGIC;
            puppine_done  : OUT STD_LOGIC
    );
end stream_pf_puppi_240;

architecture Behavioral of stream_pf_puppi_240 is
    constant NPUPPI   : natural := NTKSORTED+NCALOSORTED;
    constant LATENCY_CHS_ONE: natural := 1;
    constant LATENCY_PREP_ONE: natural := 4;
    constant LATENCY_PUPPI_ONE: natural := 14;

    signal alltk_240:   w64s(NTKSORTED-1 downto 0)   := (others => (others => '0'));
    signal allcalo_240: w64s(NCALOSORTED-1 downto 0) := (others => (others => '0'));
    signal allmu_240:   w64s(NMUSORTED-1 downto 0)   := (others => (others => '0'));
    signal tk_empty240  : std_logic_vector(NTKSTREAM-1 downto 0) := (others => '0');
    signal alltk_240_done, allcalo_240_done, allmu_240_done, empty240not : std_logic := '0'; 

    signal pf_in   : w64s(NPFTOT-1 downto 0) := (others => (others => '0'));
    signal pf_out_i, pf_out_p : w64s(NPFTOT-1 downto 0) := (others => (others => '0'));
    signal pf_start_i, pf_done_i, pf_done_p, pf_valid_p : std_logic := '0';

    signal vtx_read_i, puppi_start, puppi_prepare_start : std_logic := '0';
    signal pfch_stream : w64s(NTKSTREAM-1 downto 0) := (others => (others => '0'));
    signal pfne_stream : w64s(NCALOSTREAM-1 downto 0) := (others => (others => '0'));

    signal vtx_delayed, vtx_for_chs, vtx_for_prepare : word64 := (others => '0');
    signal tk_delay_out: w64s(NTKSTREAM-1 downto 0)   := (others => (others => '0'));

    signal puppich_out_i  : w64s(NTKSTREAM-1 downto 0) := (others => (others => '0'));
    signal puppich_done_i : std_logic_vector(NTKSTREAM-1 downto 0) := (others => '0');

    signal prepare_done_i : std_logic_vector(NTKSTREAM-1 downto 0) := (others => '0');
    signal prep_obj       : w64s(NTKSTREAM-1 downto 0) := (others => (others => '0'));
    signal all_prep_obj   : w64s(NTKSORTED-1 downto 0) := (others => (others => '0'));
    signal puppine_tk_in  : w64s(NTKSORTED-1 downto 0) := (others => (others => '0'));
    signal all_prep_obj_done : std_logic := '0';
    
    signal puppine_out_i : w64s(NCALOSTREAM-1 downto 0) := (others => (others => '0'));
    signal puppine_done_i: std_logic_vector(NCALOSTREAM-1 downto 0) := (others => '0');

begin
    
     s2p_tk: entity work.serial2parallel
                    generic map(NITEMS => NTKSORTED, NSTREAM => NTKSTREAM, NREAD => PFII240)
                    port map(ap_clk   => clk240,
                             ap_start => valid_in,
                             data_in  => tk_in,
                             valid_in => (others => '1'),
                             data_out  => alltk_240,
                             valid_out => open,
                             ap_done   => alltk_240_done);
     s2p_calo: entity work.serial2parallel
                    generic map(NITEMS => NCALOSORTED, NSTREAM => NCALOSTREAM, NREAD => PFII240)
                    port map(ap_clk   => clk240,
                             ap_start => valid_in,
                             data_in  => calo_in,
                             valid_in => (others => '1'),
                             data_out  => allcalo_240,
                             valid_out => open,
                             ap_done   => allcalo_240_done);
     s2p_mu: entity work.serial2parallel
                    generic map(NITEMS => NMUSORTED, NSTREAM => NMUSTREAM, NREAD => PFII240)
                    port map(ap_clk   => clk240,
                             ap_start => valid_in,
                             data_in  => mu_in,
                             valid_in => (others => '1'),
                             data_out  => allmu_240,
                             valid_out => open,
                             ap_done   => allmu_240_done);

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
 
    pfblock : entity work.pf_block
        port map(ap_clk => clk240, 
                 ap_rst => rst240, 
                 ap_start => pf_start_i,
                 ap_ready => open,
                 ap_idle =>  open,
                 ap_done =>  pf_done_i,
                 pf_in    => pf_in,
                 pf_out   => pf_out_i
                );


     pf2out: process(clk240)
     begin
         if rising_edge(clk240) then
             if rst240 = '1' then
                 pf_out_p   <= (others => (others => '0'));
                 pf_valid_p <= '0';
             else
                 if pf_done_i = '1' then
                     pf_valid_p <= '1';
                     pf_out_p   <= pf_out_i;
                 end if;
             end if;
             pf_done_p <= pf_done_i;
             pf_valid  <= pf_valid_p; -- delay by 1 bit for the s2p
             puppi_start <= pf_valid_p;
         end if;
     end process pf2out;

     pf2serial : entity work.parallel2serial
            generic map(NITEMS  => NPFTOT, NSTREAM => NPFSTREAM)
            port map( ap_clk => clk240,
                      roll   => pf_done_p,
                      data_in  => pf_out_p,
                      valid_in => (others => '1'),
                      data_out  => pf_out,
                      valid_out => open,
                      roll_out  => pf_done);

     pfch2serial : entity work.parallel2serial
            generic map(NITEMS  => NTKSORTED, NSTREAM => NTKSTREAM)
            port map( ap_clk => clk240,
                      roll   => pf_done_p,
                      data_in  => pf_out_p(NTKSORTED-1 downto 0),
                      valid_in => (others => '1'),
                      data_out  => pfch_stream,
                      valid_out => open,
                      roll_out  => open);

     gen_puppich_ones: for i in 0 to NTKSTREAM-1 generate
         puppich : entity work.packed_linpuppi_chs_one
             port map(ap_clk    => clk240, 
                      ap_start  => puppi_start,
                      ap_ready  => open,
                      ap_idle   => open,
                      ap_done   => puppich_done_i(i),
                      pfch_V    => pfch_stream(i),
                      pvZ0_V    => vtx_for_chs,
                      ap_return => puppich_out_i(i));
     end generate gen_puppich_ones;

     pfne2serial : entity work.parallel2serial
            generic map(NITEMS  => NCALOSORTED, NSTREAM => NCALOSTREAM)
            port map( ap_clk => clk240,
                      roll   => pf_done_p,
                      data_in  => pf_out_p(NCALOSORTED+NTKSORTED-1 downto NTKSORTED),
                      valid_in => (others => '1'),
                      data_out  => pfne_stream,
                      valid_out => open,
                      roll_out  => open);

     vtx_read_delay : entity work.bit_delay
        generic map(DELAY => LATENCY_PF - LATENCY_PREP_ONE - PFII240 - 1)
        port map(clk => clk240, enable => '1', 
                 d => pf_start_i,
                 q => vtx_read_i);
     vtx_read <= vtx_read_i;

     vtx_delay_prep : entity work.word_delay
        generic map(DELAY => 1)
        port map(clk => clk240, enable => '1', 
                 d => vtx_in,
                 q => vtx_for_prepare);

     vtx_delay_chs : entity work.word_delay
        generic map(DELAY => LATENCY_PREP_ONE+PFII240+2)
        port map(clk => clk240, enable => '1', 
                 d => vtx_in,
                 q => vtx_for_chs);

     gen_tk_delay: for i in 0 to NTKSTREAM-1 generate
         tk_delay: entity work.bram_delay
                generic map(DELAY => LATENCY_PF - LATENCY_PREP_ONE+2)
                port map(clk => clk240, 
                         rst => rst240, 
                         d   => tk_in(i),
                         q   => tk_delay_out(i));
     end generate gen_tk_delay;

     puppi_prep_start_delay : entity work.bit_delay
        generic map(DELAY => 2)
        port map(clk => clk240, enable => '1', 
                 d => vtx_read_i,
                 q => puppi_prepare_start);

     gen_puppi_preps: for i in 0 to NTKSTREAM-1 generate
         puppi_prep : entity work.packed_linpuppi_prepare_track
             port map(ap_clk    => clk240, 
                      ap_start  => puppi_prepare_start,
                      ap_ready  => open,
                      ap_idle   => open,
                      ap_done   => prepare_done_i(i),
                      track_V   => tk_delay_out(i),
                      pvZ0_V    => vtx_for_prepare,
                      ap_return => prep_obj(i)(36 downto 0));
     end generate gen_puppi_preps;

     s2p_preps: entity work.serial2parallel
                    generic map(NITEMS => NTKSORTED, NSTREAM => NTKSTREAM, NREAD => PFII240)
                    port map(ap_clk   => clk240,
                             ap_start => prepare_done_i(0),
                             data_in  => prep_obj,
                             valid_in => (others => '1'),
                             data_out  => all_prep_obj,
                             valid_out => open,
                             ap_done   => all_prep_obj_done);
     
     puppi_one_in: process(clk240)
     begin
         if rising_edge(clk240) then
             if all_prep_obj_done = '1' then
                 puppine_tk_in <= all_prep_obj;
             end if;
        end if;
     end process puppi_one_in;

     gen_puppi_ones: for i in 0 to NCALOSTREAM-1 generate
         puppi_one: entity work.puppine_one_block
                        port map( ap_clk   => clk240,
                                  ap_start  => puppi_start,
                                  ap_ready  => open,
                                  ap_idle   => open,
                                  ap_done   => puppine_done_i(i),
                                  pf_in     => pfne_stream(i),
                                  prep_tk_in => puppine_tk_in,
                                  puppi_out  => puppine_out_i(i));
     end generate gen_puppi_ones;

     puppich2out: process(clk240)
     begin
         if rising_edge(clk240) then
             if rst240 = '1' then
                 puppich_out <= (others => (others => '0'));
             else
                 if puppich_done_i(0) = '1' then
                     puppich_out <= puppich_out_i;
                 end if;
             end if;
             puppich_valid <= puppich_done_i(0);
             puppich_done  <= puppich_done_i(0); -- FIXME: can it be 1 for just the first obj per region?
         end if;
     end process puppich2out;
  
     puppine2out: process(clk240)
     begin
         if rising_edge(clk240) then
             if rst240 = '1' then
                 puppine_out <= (others => (others => '0'));
             else
                 if puppine_done_i(0) = '1' then
                     puppine_out <= puppine_out_i;
                 end if;
             end if;
             puppine_valid <= puppine_done_i(0);
             puppine_done  <= puppine_done_i(0); -- FIXME: can it be 1 for just the first obj per region?
         end if;
     end process puppine2out;

end Behavioral;

