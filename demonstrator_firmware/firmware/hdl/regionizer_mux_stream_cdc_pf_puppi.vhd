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
            -- 360 MHz clock regionizer 
            regionizer_out   : OUT w64s(NTKSTREAM+NCALOSTREAM+NMUSTREAM-1 downto 0);
            regionizer_done  : OUT STD_LOGIC; -- '1' for 1 clock at start of event
            regionizer_valid : OUT STD_LOGIC; -- '1' for valid output, '0' for null
            -- 360 MHz clock PF output
            pf_out   : OUT w64s(NPFTOT-1 downto 0);
            pf_start : OUT STD_LOGIC;
            pf_read  : OUT STD_LOGIC;
            pf_done  : OUT STD_LOGIC;
            pf_valid : OUT STD_LOGIC;
            pf_empty : OUT STD_LOGIC_VECTOR(NPFSTREAM-1 downto 0);
            -- 360 MHz clock Puppi output
            puppi_out   : OUT w64s(NPUPPI-1 downto 0);
            puppi_start : OUT STD_LOGIC;
            puppi_read  : OUT STD_LOGIC;
            puppi_done  : OUT STD_LOGIC;
            puppi_valid : OUT STD_LOGIC;
            puppi_empty : OUT STD_LOGIC_VECTOR(NTKSTREAM+NCALOSTREAM-1 downto 0)
    );

end regionizer_mux_stream_cdc_pf_puppi;

architecture Behavioral of regionizer_mux_stream_cdc_pf_puppi is
    constant PV_LINK  : natural := NTKSECTORS*NTKFIBERS + NCALOSECTORS*NCALOFIBERS + NMUFIBERS;
    constant NREGIONIZER_OUT : natural := NTKSORTED + NCALOSORTED + NMUSORTED;
    constant NPUPPI   : natural := NTKSORTED+NCALOSORTED;

    constant NCLK_WRITE360 : natural := NPFREGIONS * PFII240;
    constant NCLK_WAIT360  : natural := NPFREGIONS * (PFII-PFII240);
    constant LATENCY_PF      : natural := 32; -- at 240 MHz
    constant LATENCY_PUPPINE : natural := 32; -- at 240 MHz
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

    signal tk_empty240  : std_logic_vector(NTKSTREAM-1 downto 0) := (others => '0');
    signal empty240not : std_logic := '0'; 

    signal pf_out360   : w64s(NPFTOT-1 downto 0) := (others => (others => '0'));
    signal pf_write240, pf_done240: std_logic := '0';
    signal pf_stream, pf_stream360 : w64s(NPFSTREAM-1 downto 0) := (others => (others => '0'));
    signal pf_read360_start, pf_read360, pf_done360, pf_decode360_warmup, pf_decode360_start : std_logic := '0';
    signal pf_empty360 : std_logic_vector(NPFSTREAM-1 downto 0) := (others => '0');
    signal pf_read360_count : natural range 0 to PFII-1;
    
    signal puppi_start_i : std_logic := '0';
    
    signal puppich_valid, puppich_done : std_logic := '0';
    signal puppine_valid, puppine_done : std_logic := '0';

    signal puppich_stream, puppich_stream360 : w64s(NTKSTREAM-1 downto 0)  := (others => (others => '0'));
    signal puppine_stream, puppine_stream360 : w64s(NCALOSTREAM-1 downto 0)  := (others => (others => '0'));
    signal puppi_read360_start, puppi_read360, puppi_done360, puppi_decode360_warmup, puppi_decode360_start : std_logic := '0';
    signal puppi_read360_count : natural range 0 to PFII-1;

    signal puppi_out360 : w64s(NTKSORTED+NCALOSORTED-1 downto 0) := (others => (others => '0'));

    constant PV_INITIAL_DELAY : natural := 10; -- extra delay because FIFOs don't become writable immediately after rst goes down. 
                                               -- not sure how much, but 6 is too little and 10 is ok
    signal pv_input_was_valid : std_logic := '0';
    signal vtx_write360 : std_logic_vector(PV_INITIAL_DELAY downto 0) := (others => '0'); 
    signal vtx_read240  : std_logic; 
    signal vtx360 : w64s(PV_INITIAL_DELAY downto 0) := (others => (others => '0')); 
    signal vtx240 : word64 := (others => '0'); 
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
                vtx_write360(0) <= '0';
            else
                pv_input_was_valid <= valid_in(PV_LINK);
                if valid_in(PV_LINK) = '1' and pv_input_was_valid = '0' then
                    vtx360(0) <= links_in(PV_LINK);
                    vtx_count360 <= 0;
                    vtx_write360(0) <= '1';
                else
                    if vtx_count360 = NCLK_WRITE360-1 then
                        vtx_write360(0) <= '0';
                    else
                        vtx_count360 <= vtx_count360 + 1;
                    end if;
                end if;
            end if;
            vtx_write360(PV_INITIAL_DELAY downto 1) <= vtx_write360(PV_INITIAL_DELAY-1downto 0);
            vtx360(PV_INITIAL_DELAY downto 1) <= vtx360(PV_INITIAL_DELAY-1downto 0);
        end if;
    end process input_link_pv;

    regionizer : entity work.full_regionizer_mux_stream
        generic map(MU_ETA_CENTER => 460)
        port map(ap_clk => clk, 
                 ap_rst => rst, 
                 ap_start => '1',
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

    regio2cdc: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                regionizer_out_warmup <= '0';
                regionizer_out_write  <= '0';
                regionizer_done <= '0';
            else
                if newevent_out = '1' then
                    -- if warmed up, start streaming out. otherwise, just warm up
                    if regionizer_out_warmup = '1' then
                        regionizer_count      <= 0;
                        regionizer_out_write  <= '1';
                        regionizer_done <= '1';
                    else
                        regionizer_out_warmup <= '1'; 
                        regionizer_out_write  <= '0';
                        regionizer_done <= '0';
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
                    regionizer_done <= '0';
                end if;
            end if;
            tk_in240   <= tk_out;
            calo_in240 <= calo_out;
            mu_in240   <= mu_out;
        end if;
    end process regio2cdc;

    -- expected output order is tracks, calo, muons, so we re-arrange pf-in
    regionizer_out(NTKSTREAM-1 downto 0) <= tk_in240;
    regionizer_out(NTKSTREAM+NCALOSTREAM-1 downto NTKSTREAM) <= calo_in240;
    regionizer_out(NTKSTREAM+NCALOSTREAM+NMUSTREAM-1 downto NCALOSTREAM+NTKSTREAM) <= mu_in240;
    regionizer_valid <= regionizer_out_write;

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
  
     empty240not <= not(tk_empty240(0)); -- FIXME: better sync here

     pf_puppi_240: entity work.stream_pf_puppi_240
            generic map(LATENCY_PF => LATENCY_PF)
            port map(clk240 => clk240,
                     rst240 => rst240,
                     valid_in => empty240not,
                     tk_in    => tk_out240,
                     calo_in  => calo_out240,
                     mu_in    => mu_out240,
                     pf_out   => pf_stream,
                     pf_valid => pf_write240,
                     pf_done  => pf_done240,
                     vtx_in   => vtx240,
                     vtx_read => vtx_read240,
                     puppich_out => puppich_stream,
                     puppich_valid => puppich_valid,
                     puppich_done  => puppich_done,
                     puppine_out => puppine_stream,
                     puppine_valid => puppine_valid,
                     puppine_done  => puppine_done);


     pf_read360_delay_start: entity work.bit_delay  -- in 240 MHz domain, spend PF latency + 1 
                                                    --                     + 2*6 for the two CDC 
                                                    --                     + 4 for serial to parallel
                                                    -- in 360 MHz domain, wait for regionizer +
           generic map(DELAY => LATENCY_REGIONIZER + ((LATENCY_PF + 4 + 12 + 3)*3)/2 + 10, SHREG => "yes") 
           port map(clk => clk, enable => '1', 
                    d => regionizer_out_warmup,
                    q => pf_read360_start);

     pf_unpacker: entity work.cdc_and_deserializer
            generic map(NITEMS => NPFTOT, 
                        NSTREAM => NPFSTREAM)
            port map(   clk => clk, 
                        rst => rst,
                        clk240 => clk240, 
                        rst240 => rst240,
                        data240 => pf_stream,
                        write240 => pf_write240,
                        start => pf_read360_start,
                        data  => pf_out,
                        valid => pf_valid,
                        done  => pf_done,
                        read  => pf_read,
                        empty => pf_empty);
    pf_start <= pf_read360_start;

    vtx_delay_cdc: entity work.cdc_bram_fifo
            port map(clk_in => clk, clk_out => clk240, rst_in => rst,
                     data_in  => vtx360(PV_INITIAL_DELAY),
                     data_out => vtx240,
                     wr_en    => vtx_write360(PV_INITIAL_DELAY),
                     rd_en    => vtx_read240);
 

     puppi_read360_delay_start: entity work.bit_delay
           generic map(DELAY => LATENCY_REGIONIZER + ((LATENCY_PF + LATENCY_PUPPINE + 4 + 12 + 3)*3)/2 + 10, SHREG => "yes")
           port map(clk => clk, enable => '1', 
                    d => regionizer_out_warmup,
                    q => puppi_read360_start);

     puppich_unpacker: entity work.cdc_and_deserializer
            generic map(NITEMS => NTKSORTED, 
                        NSTREAM => NTKSTREAM)
            port map(   clk => clk, 
                        rst => rst,
                        clk240 => clk240, 
                        rst240 => rst240,
                        data240 => puppich_stream,
                        write240 => puppich_valid,
                        start => puppi_read360_start,
                        data  => puppi_out(NTKSORTED-1 downto 0),
                        valid => puppi_valid,
                        done  => puppi_done,
                        read  => puppi_read,
                        empty => puppi_empty(NTKSTREAM-1 downto 0));
     puppine_unpacker: entity work.cdc_and_deserializer
            generic map(NITEMS => NCALOSORTED, 
                        NSTREAM => NCALOSTREAM)
            port map(   clk => clk, 
                        rst => rst,
                        clk240 => clk240, 
                        rst240 => rst240,
                        data240 => puppine_stream,
                        write240 => puppine_valid,
                        start => puppi_read360_start,
                        data  => puppi_out(NCALOSORTED+NTKSORTED-1 downto NTKSORTED),
                        valid => open,
                        done  => open,
                        read  => open,
                        empty => puppi_empty(NCALOSTREAM+NTKSTREAM-1 downto NTKSTREAM));
     puppi_start <= puppi_read360_start;

end Behavioral;
