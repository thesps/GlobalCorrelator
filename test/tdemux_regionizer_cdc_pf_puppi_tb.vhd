library std;
use std.textio.all;
use std.env.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

use work.regionizer_data.all;
use work.pattern_textio.all;


entity testbench is
--  Port ( );
end testbench;

architecture Behavioral of testbench is
    constant NPATTERNS_TK_IN   : natural := NTKSECTORS*TDEMUX_FACTOR*TDEMUX_NTKFIBERS;
    constant NPATTERNS_CALO_IN : natural := NCALOSECTORS*TDEMUX_FACTOR*TDEMUX_NCALOFIBERS;
    constant NPATTERNS_MU_IN   : natural := TDEMUX_FACTOR*TDEMUX_NMUFIBERS;
    constant NPATTERNS_IN    : natural := NPATTERNS_TK_IN + NPATTERNS_CALO_IN + NPATTERNS_MU_IN + 1;
    constant IPATTERN_TK_START : natural := 0;
    constant IPATTERN_TK_END   : natural := NPATTERNS_TK_IN-1;
    constant IPATTERN_CALO_START : natural := NPATTERNS_TK_IN;
    constant IPATTERN_CALO_END   : natural := NPATTERNS_TK_IN+NPATTERNS_CALO_IN-1;
    constant IPATTERN_MU_START : natural := NPATTERNS_TK_IN+NPATTERNS_CALO_IN;
    constant IPATTERN_MU_END   : natural := NPATTERNS_TK_IN+NPATTERNS_CALO_IN+NPATTERNS_MU_IN-1;
    constant IPATTERN_PV       : natural := NPATTERNS_TK_IN+NPATTERNS_CALO_IN+NPATTERNS_MU_IN;
    constant NREGIONIZER_OUT : natural := NTKSTREAM + NCALOSTREAM + NMUSTREAM;
    constant NPFTOT   : natural := NTKSORTED + NCALOSORTED + NMUSORTED;
    constant NPUPPICH : natural := NTKSORTED;
    constant NPUPPINE : natural := NCALOSORTED;
    constant NPUPPI   : natural := NTKSORTED+NCALOSORTED;

    -- I want a 240 MHz clk and a 360 MHz clocks, aligned
    -- => I need to start with a 720 MHz clock, and then divide by 2 and 3
    signal clk720, clk, clk240 : std_logic := '0';
    signal count240 : natural range 0 to 2 := 0;

    signal rst, rst240, rst240_u : std_logic := '0';
    attribute ASYNC_REG : string;
    attribute ASYNC_REG of rst240_u : signal is "TRUE";

    signal links_in:  w64s(NPATTERNS_IN-1 downto 0) := (others => (others => '0'));
    signal valid_in: std_logic_vector(NPATTERNS_IN-1 downto 0) := (others => '0');

    signal regionizer_out: w64s(NTKSTREAM+NCALOSTREAM+NMUSTREAM-1 downto 0);
    signal regionizer_done, regionizer_valid : STD_LOGIC := '0';

    -- PF: 360 MHz stuff
    signal pf_out: w64s(NPFTOT - 1 downto 0);
    signal pf_start, pf_read, pf_valid, pf_done : STD_LOGIC;
    signal pf_empty : STD_LOGIC_VECTOR(NPFSTREAM-1 downto 0);

    -- Puppi: 360 MHz stuff
    signal puppi_out  : w64s(NPUPPI - 1 downto 0);
    signal puppi_start, puppi_read, puppi_done, puppi_valid : STD_LOGIC;
    signal puppi_empty : STD_LOGIC_VECTOR(NTKSTREAM+NCALOSTREAM-1 downto 0);

    file Fi : text open read_mode  is "input-emp.txt";
    file Fo_reg   : text open write_mode is "output-emp-regionized-vhdl_tb.txt";
    file Fo_pf    : text open write_mode is "output-emp-pf-vhdl_tb.txt";
    file Fo_puppi : text open write_mode is "output-emp-puppi-vhdl_tb.txt";

begin
    clk720 <= not clk720 after 0.69444 ns;

    make_clocks: process(clk720)
    begin
        -- clock division by 2 is easy
        if rising_edge(clk720) then
            clk <= not clk;
        end if;
        -- clock division by 3 is slightly harder
        if rising_edge(clk720) or falling_edge(clk720) then
            if count240 < 2 then
                count240 <= count240 + 1;
            else
                clk240 <= not clk240;
                count240 <= 0;
            end if;
        end if;
    end process make_clocks;

    export_rst_clk240: process(clk240)
    begin
        if rising_edge(clk240) then
            rst240_u <= rst;
            rst240 <= rst240_u;
        end if;
    end process export_rst_clk240;
    

    uut : entity work.tdemux_regionizer_cdc_pf_puppi
        port map(clk => clk, clk240 => clk240, 
                 rst => rst, rst240 => rst240, 

                 tk_links_in => links_in(IPATTERN_TK_END downto IPATTERN_TK_START),
                 tk_valid_in => valid_in(IPATTERN_TK_END downto IPATTERN_TK_START),
                 calo_links_in => links_in(IPATTERN_CALO_END downto IPATTERN_CALO_START),
                 calo_valid_in => valid_in(IPATTERN_CALO_END downto IPATTERN_CALO_START),
                 mu_links_in => links_in(IPATTERN_MU_END downto IPATTERN_MU_START),
                 mu_valid_in => valid_in(IPATTERN_MU_END downto IPATTERN_MU_START),
                 vtx_link_in => links_in(IPATTERN_PV),
                 vtx_valid_in => valid_in(IPATTERN_PV),

                 regionizer_out => regionizer_out,
                 regionizer_done => regionizer_done,
                 regionizer_valid => regionizer_valid,

                 pf_out => pf_out,
                 pf_start => pf_start,
                 pf_read => pf_read,
                 pf_done => pf_done,
                 pf_valid => pf_valid,
                 pf_empty => pf_empty,

                 puppi_out => puppi_out,
                 puppi_start => puppi_start,
                 puppi_read => puppi_read,
                 puppi_done => puppi_done,
                 puppi_valid => puppi_valid,
                 puppi_empty => puppi_empty

             );
  

    runit : process 
        variable remainingEvents : integer := 5;
        variable v_patterns_in  : w64s(NPATTERNS_IN  - 1 downto 0);
        variable v_patterns_in_valid : std_logic_vector(NPATTERNS_IN  - 1 downto 0);
        variable v_demuxed_out : w64s(NTKSECTORS*TDEMUX_FACTOR*TDEMUX_NTKFIBERS+NCALOSECTORS*TDEMUX_FACTOR*TDEMUX_NCALOFIBERS+TDEMUX_FACTOR*TDEMUX_NMUFIBERS-1 downto 0);
        variable v_demuxed_vld : std_logic_vector(NTKSECTORS*TDEMUX_FACTOR*TDEMUX_NTKFIBERS+NCALOSECTORS*TDEMUX_FACTOR*TDEMUX_NCALOFIBERS+TDEMUX_FACTOR*TDEMUX_NMUFIBERS-1 downto 0);
        variable v_regions_out : w64s(NREGIONIZER_OUT downto 0) := (others => (others => '0'));
        variable v_regions_out_valid : std_logic := '1';
        variable v_pf_out : w64s(NPFTOT downto 0) := (others => (others => '0'));
        variable v_pf_out_valid : std_logic := '1';
        variable v_puppi_out : w64s(NPUPPI downto 0) := (others => (others => '0'));
        variable v_puppi_out_valid : std_logic := '1';
        variable frame : integer := 0;
    begin
        rst <= '1';
        wait for 25 ns;
        rst <= '0';
        wait until rising_edge(clk);
        while remainingEvents > 0 loop
            if not endfile(Fi) then
                read_pattern_frame(FI, v_patterns_in, v_patterns_in_valid);
            else
                v_patterns_in := (others => (others => '0'));
                v_patterns_in_valid := (others => '0');
                remainingEvents := remainingEvents - 1;
            end if;
            links_in <= v_patterns_in;
            valid_in <= v_patterns_in_valid;
            -- ready to dispatch ---
            wait until rising_edge(clk);
            -- write out the regionizer output --
            v_regions_out(NREGIONIZER_OUT-1 downto 0) := regionizer_out;
            v_regions_out(NREGIONIZER_OUT) := (4 => regionizer_done, 0 => regionizer_valid, others => '0');
            write_pattern_frame(Fo_reg, frame, v_regions_out, v_regions_out_valid);
            -- write out the pf output --
            v_pf_out(NPFTOT-1 downto 0) := pf_out;
            v_pf_out(NPFTOT) := (60=>pf_start, 56=>pf_read, 
                                  4=>pf_done, 0=>pf_valid, others => '0');
            v_pf_out(NPFTOT)(NPFSTREAM+15 downto 16) := pf_empty;
            write_pattern_frame(Fo_pf, frame, v_pf_out, v_pf_out_valid);
            -- write out the puppi output --
            v_puppi_out(NPUPPI-1 downto 0) := puppi_out;
            v_puppi_out(NPUPPI) := (60=>puppi_start, 56=>puppi_read, 
                                     4=>puppi_done, 0=>puppi_valid, others => '0');
            v_puppi_out(NPUPPI)(NTKSTREAM+NCALOSTREAM+15 downto 16) := puppi_empty;
            write_pattern_frame(Fo_puppi, frame, v_puppi_out, v_puppi_out_valid);
            ----
            frame := frame + 1;
        end loop;
        wait for 50 ns;
        finish(0);
    end process;

end Behavioral;
