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
    constant NPATTERNS_IN  : natural := NTKSECTORS*NTKFIBERS + NCALOSECTORS*NCALOFIBERS + NMUFIBERS + 1;
    constant NREGIONIZER_OUT : natural := NTKSORTED + NCALOSORTED + NMUSORTED;
    constant NPFTOT :          natural := NTKSORTED + NCALOSORTED + NMUSORTED;
    constant NPUPPICH :          natural := NTKSORTED;
    constant NPUPPINE :          natural := NCALOSORTED;
    constant NPUPPI   :          natural := NTKSORTED+NCALOSORTED;

    signal clk : std_logic := '0';
    signal rst : std_logic := '0';

    signal links_in:  w64s(NPATTERNS_IN-1 downto 0) := (others => (others => '0'));
    signal valid_in: std_logic_vector(NPATTERNS_IN-1 downto 0) := (others => '0');

    signal regionizer_out   : w64s(NTKSORTED + NCALOSORTED + NMUSORTED - 1 downto 0);
    signal regionizer_start, regionizer_done, regionizer_valid : STD_LOGIC := '0';

    signal pf_out   : w64s(NPFTOT - 1 downto 0);
    signal pf_start, pf_done, pf_valid, pf_ready, pf_idle : STD_LOGIC := '0';

    signal puppi_out   : w64s(NPUPPI - 1 downto 0);
    signal puppi_start, puppi_done, puppi_valid, puppi_ready, puppi_idle : STD_LOGIC := '0';

    signal puppich_in    : w64s(NTKSORTED               downto 0);
    signal puppine_in    : w64s(NTKSORTED + NCALOSORTED downto 0);
    signal puppich_out   : w64s(NPUPPICH - 1 downto 0);
    signal puppine_out   : w64s(NPUPPINE - 1 downto 0);
    signal puppich_start, puppich_done, puppich_valid, puppich_ready, puppich_idle : STD_LOGIC := '0';
    signal puppine_start, puppine_done, puppine_valid, puppine_ready, puppine_idle : STD_LOGIC := '0';

    file Fi : text open read_mode  is "input-emp.txt";
    file Fo_reg : text open write_mode is "output-emp-regionized-vhdl_tb.txt";
    file Fo_pf  : text open write_mode is "output-emp-pf-vhdl_tb.txt";
    file Fo_puppi  : text open write_mode is "output-emp-puppi-vhdl_tb.txt";
    file Fo_puppich  : text open write_mode is "output-emp-puppich-vhdl_tb.txt";
    file Fo_puppine  : text open write_mode is "output-emp-puppine-vhdl_tb.txt";

begin
    clk  <= not clk after 1.25 ns;
    
    uut : entity work.regionizer_mux_pf_puppi
        port map(clk => clk, 
                 rst => rst, 
                 links_in => links_in,
                 valid_in => valid_in,
                 regionizer_out => regionizer_out,
                 regionizer_start => regionizer_start,
                 regionizer_valid => regionizer_valid,
                 regionizer_done => regionizer_done,
                 pf_out => pf_out,
                 pf_start => pf_start,
                 pf_valid => pf_valid,
                 pf_done => pf_done,
                 pf_ready => pf_ready,
                 pf_idle => pf_idle,
                 puppi_out => puppi_out,
                 puppi_valid => puppi_valid,
                 puppi_done => puppi_done,
                 d_puppine_in => puppine_in,
                 d_puppich_in => puppich_in,
                 puppich_out => puppich_out,
                 puppich_start => puppich_start,
                 puppich_valid => puppich_valid,
                 puppich_done => puppich_done,
                 puppich_ready => puppich_ready,
                 puppich_idle => puppich_idle,
                 puppine_out => puppine_out,
                 puppine_start => puppine_start,
                 puppine_valid => puppine_valid,
                 puppine_done => puppine_done,
                 puppine_ready => puppine_ready,
                 puppine_idle => puppine_idle
             );
  

    runit : process 
        variable remainingEvents : integer := 5;
        variable v_patterns_in  : w64s(NPATTERNS_IN  - 1 downto 0);
        variable v_patterns_in_valid : std_logic;
        variable v_regions_out : w64s(NREGIONIZER_OUT downto 0) := (others => (others => '0'));
        variable v_regions_out_valid : std_logic := '1';
        variable v_pf_out : w64s(NPFTOT downto 0) := (others => (others => '0'));
        variable v_pf_out_valid : std_logic := '1';
        variable v_puppich_out : w64s(NTKSORTED+1+NPUPPICH downto 0) := (others => (others => '0'));
        variable v_puppich_out_valid : std_logic := '1';
        --variable v_puppine_out : w64s(NTKSORTED+NCALOSORTED+1+NPUPPINE downto 0) := (others => (others => '0'));
        variable v_puppine_out : w64s(NPUPPINE downto 0) := (others => (others => '0'));
        variable v_puppine_out_valid : std_logic := '1';
        variable v_puppi_out : w64s(NTKSORTED+NCALOSORTED downto 0) := (others => (others => '0'));
        variable v_puppi_out_valid : std_logic := '1';
        variable frame : integer := 0;
    begin
        rst <= '1';
        wait for 5 ns;
        rst <= '0';
        wait until rising_edge(clk);
        while remainingEvents > 0 loop
            if not endfile(Fi) then
                read_pattern_frame(FI, v_patterns_in, v_patterns_in_valid);
            else
                v_patterns_in := (others => (others => '0'));
                v_patterns_in_valid := '0';
                remainingEvents := remainingEvents - 1;
            end if;
            links_in <= v_patterns_in;
            valid_in <= (others => v_patterns_in_valid);
            -- ready to dispatch ---
            wait until rising_edge(clk);
            -- write out the regionizer output --
            v_regions_out(NREGIONIZER_OUT-1 downto 0) := regionizer_out;
            v_regions_out(NREGIONIZER_OUT) := (60 => regionizer_start, 
                                                4 => regionizer_done, 
                                                0 => regionizer_valid, 
                                                others => '0');
            write_pattern_frame(Fo_reg, frame, v_regions_out, v_regions_out_valid);
            -- write out the pf output --
            v_pf_out(NPFTOT-1 downto 0) := pf_out;
            v_pf_out(NPFTOT) := (60=>pf_start, 56=>pf_ready, 52=>pf_idle,
                                 4 => pf_done, 0 => pf_valid,
                                 others => '0');
            write_pattern_frame(Fo_pf, frame, v_pf_out, v_pf_out_valid);
            -- write out the puppi output --
            v_puppich_out(NTKSORTED downto 0) := puppich_in;
            v_puppich_out(NTKSORTED+1+NPUPPICH-1 downto NTKSORTED+1) := puppich_out;
            v_puppich_out(NTKSORTED+1+NPUPPICH) := (60=>puppich_start, 56=>puppich_ready, 52=>puppich_idle,
                                 4 => puppich_done, 0 => puppich_valid,
                                 others => '0');
            write_pattern_frame(Fo_puppich, frame, v_puppich_out, v_puppich_out_valid);
            --v_puppine_out(NTKSORTED+NCALOSORTED downto 0) := puppine_in;
            --v_puppine_out(NTKSORTED+NCALOSORTED+1+NPUPPINE-1 downto NTKSORTED+NCALOSORTED+1) := puppine_out;
            v_puppine_out(NPUPPINE-1 downto 0) := puppine_out;
            v_puppine_out(NPUPPINE) := (60=>puppine_start, 56=>puppine_ready, 52=>puppine_idle,
                                 4 => puppine_done, 0 => puppine_valid,
                                 others => '0');
            write_pattern_frame(Fo_puppine, frame, v_puppine_out, v_puppine_out_valid);
            v_puppi_out(NTKSORTED+NCALOSORTED-1 downto 0) := puppi_out;
            v_puppi_out(NTKSORTED+NCALOSORTED) := ( 4 => puppi_done, 0 => puppi_valid, others => '0');
            write_pattern_frame(Fo_puppi, frame, v_puppi_out, v_puppi_out_valid);
            frame := frame + 1;
        end loop;
        wait for 50 ns;
        finish(0);
    end process;

    
end Behavioral;
