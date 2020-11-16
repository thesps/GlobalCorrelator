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

    signal alltk_240:   w64s(NTKSORTED-1 downto 0)   := (others => (others => '0'));
    signal allcalo_240: w64s(NCALOSORTED-1 downto 0) := (others => (others => '0'));
    signal allmu_240:   w64s(NMUSORTED-1 downto 0)   := (others => (others => '0'));
    signal tk_empty240  : std_logic_vector(NTKSTREAM-1 downto 0) := (others => '0');
    signal alltk_240_done, allcalo_240_done, allmu_240_done, empty240not : std_logic := '0'; 

    signal pf_in   : w64s(NPFTOT-1 downto 0) := (others => (others => '0'));
    signal pf_out_i, pf_out_p : w64s(NPFTOT-1 downto 0) := (others => (others => '0'));
    signal pf_start_i, pf_done_i, pf_done_p, pf_valid_p : std_logic := '0';

    signal puppi_start_i : std_logic := '0';
    signal tk_delay_out: w64s(NTKSORTED-1 downto 0)   := (others => (others => '0'));

    signal puppich_in    : w64s(NTKSORTED downto 0) := (others => (others => '0'));
    signal puppich_out_i : w64s(NTKSORTED-1 downto 0) := (others => (others => '0'));
    signal puppich_out_p : w64s(NTKSORTED-1 downto 0) := (others => (others => '0'));
    signal puppich_done_i, puppich_done_p, puppich_valid_p : std_logic := '0';
    
    signal puppine_in    : w64s(NTKSORTED+NCALOSORTED downto 0) := (others => (others => '0'));
    signal puppine_out_i : w64s(NCALOSORTED-1 downto 0) := (others => (others => '0'));
    signal puppine_out_p : w64s(NCALOSORTED-1 downto 0) := (others => (others => '0'));
    signal puppine_done_i, puppine_done_p, puppine_valid_p : std_logic := '0';

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


     vtx_read_delay : entity work.bit_delay
        generic map(DELAY => LATENCY_PF-1)
        port map(clk => clk240, enable => '1', 
                 d => pf_start_i,
                 q => vtx_read);

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
                     puppich_in(0)                  <= vtx_in;  
                     puppich_in(NTKSORTED downto 1) <= pf_out_i(NTKSORTED-1 downto 0);
                     puppine_in(NTKSORTED-1 downto 0) <= tk_delay_out; 
                     puppine_in(NTKSORTED)            <= vtx_in; 
                     puppine_in(NTKSORTED+NCALOSORTED downto NTKSORTED+1) <= pf_out_i(NTKSORTED+NCALOSORTED-1 downto NTKSORTED);
                 else
                     puppi_start_i <= '0';
                 end if;
             end if;
         end if;
     end process pf2puppi;
   
    puppichsblock : entity work.puppich_block
        port map(ap_clk => clk240, 
                 ap_rst => rst240, 
                 ap_start => puppi_start_i,
                 ap_ready => open,
                 ap_idle =>  open,
                 ap_done =>  puppich_done_i,
                 puppich_in => puppich_in,
                 puppich_out => puppich_out_i
            );
  
    puppiblock : entity work.puppine_block
        port map(ap_clk => clk240, 
                 ap_rst => rst240, 
                 ap_start => puppi_start_i,
                 ap_ready => open,
                 ap_idle =>  open,
                 ap_done =>  puppine_done_i,
                 puppine_in => puppine_in,
                 puppine_out => puppine_out_i
            );
 
     puppich2out: process(clk240)
     begin
         if rising_edge(clk240) then
             if rst240 = '1' then
                 puppich_out_p   <= (others => (others => '0'));
                 puppich_valid_p <= '0';
             else
                 if puppich_done_i = '1' then
                     puppich_valid_p <= '1';
                     puppich_out_p   <= puppich_out_i;
                 end if;
             end if;
             puppich_done_p <= puppich_done_i;
             puppich_valid  <= puppich_valid_p; -- delay by 1 clk for p2s
         end if;
     end process puppich2out;
  
     puppine2out: process(clk240)
     begin
         if rising_edge(clk240) then
             if rst240 = '1' then
                 puppine_out_p   <= (others => (others => '0'));
                 puppine_valid_p <= '0';
             else
                 if puppine_done_i = '1' then
                     puppine_valid_p <= '1';
                     puppine_out_p   <= puppine_out_i;
                 end if;
             end if;
             puppine_done_p <= puppine_done_i;
             puppine_valid <= puppine_valid_p;
         end if;
     end process puppine2out;

     puppich_stream : entity work.parallel2serial
                generic map(NITEMS  => NTKSORTED, NSTREAM => NTKSTREAM)
                port map( ap_clk => clk240,
                          roll   => puppich_done_p,
                          data_in  => puppich_out_p,
                          valid_in => (others => '1'),
                          data_out  => puppich_out,
                          valid_out => open,
                          roll_out  => puppich_done);

     puppine_stream : entity work.parallel2serial
                generic map(NITEMS  => NCALOSORTED, NSTREAM => NCALOSTREAM)
                port map( ap_clk => clk240,
                          roll   => puppine_done_p,
                          data_in  => puppine_out_p,
                          valid_in => (others => '1'),
                          data_out  => puppine_out,
                          valid_out => open,
                          roll_out  => puppine_done);

end Behavioral;

