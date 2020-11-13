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
 
    pfblock : entity work.packed_pfalgo2hgc
        port map(ap_clk => clk240, 
                 ap_rst => rst240, 
                 ap_start => pf_start_i,
                 ap_ready => open,
                 ap_idle =>  open,
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
                 end if;
             end if;
         end if;
     end process pf2puppi;
   
     puppichsblock : entity work.packed_linpuppi_chs
         port map(ap_clk => clk240, 
                  ap_rst => rst240, 
                  ap_start => puppi_start_i,
                  ap_ready => open,
                  ap_idle =>  open,
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
  
     puppiblock : entity work.packed_linpuppiNoCrop
         port map(ap_clk => clk240, 
                  ap_rst => rst240, 
                  ap_start => puppi_start_i,
                  ap_ready => open,
                  ap_idle =>  open,
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

