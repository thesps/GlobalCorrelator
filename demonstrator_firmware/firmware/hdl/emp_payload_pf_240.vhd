library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ipbus.all;
use work.emp_data_types.all;
use work.emp_project_decl.all;

use work.emp_device_decl.all;
use work.emp_ttc_decl.all;

use work.regionizer_data.all;

entity emp_payload is
	port(
		clk: in std_logic; -- ipbus signals
		rst: in std_logic;
		ipb_in: in ipb_wbus;
		ipb_out: out ipb_rbus;
		clk_payload: in std_logic_vector(2 downto 0);
		rst_payload: in std_logic_vector(2 downto 0);
		clk_p: in std_logic; -- data clock
		rst_loc: in std_logic_vector(N_REGION - 1 downto 0);
		clken_loc: in std_logic_vector(N_REGION - 1 downto 0);
		ctrs: in ttc_stuff_array;
		bc0: out std_logic;
		d: in ldata(4 * N_REGION - 1 downto 0); -- data in
		q: out ldata(4 * N_REGION - 1 downto 0); -- data out
		gpio: out std_logic_vector(29 downto 0); -- IO to mezzanine connector
		gpio_en: out std_logic_vector(29 downto 0) -- IO to mezzanine connector (three-state enables)
	);
		
end emp_payload;

architecture rtl of emp_payload is
        constant NCLK_WRITE360 : natural := NPFREGIONS * PFII240;
        constant N_IN  : natural := NPFSTREAM;
        constant N_OUT : natural := NPFSTREAM;
        constant N_DELAY_IN  : natural := 5;
        constant N_DELAY_OUT : natural := 5;

        constant RST_CHAIN_DELAY : natural := 6;
        signal rst240, rst240_u : std_logic := '0';
        signal rst240_chain : std_logic_vector(RST_CHAIN_DELAY downto 0):= (others => '0');
        attribute ASYNC_REG : string;
        attribute ASYNC_REG of rst240_u : signal is "TRUE";
        attribute KEEP : string;
        attribute KEEP of rst240_chain : signal is "TRUE";
        attribute SHREG_EXTRACT : string;
        attribute SHREG_EXTRACT of rst240_chain : signal is "FALSE";

        signal pf_in_count : natural range 0 to NCLK_WRITE360-1 := 0;
        signal pf_in, pf_out: w64s(NPFTOT - 1 downto 0);
        signal pf_in_write, pf_start, pf_done, pf_serialized, pf_out_write : std_logic := '0';
        signal pf_in_stream,       pf_out_stream:                   w64s(NPFSTREAM - 1 downto 0);
        signal pf_in_valid_stream, pf_out_valid_stream: std_logic_vector(NPFSTREAM - 1 downto 0);
        signal pf_in240_stream,     pf_out240_stream, pf_towrite240:  w64s(NPFSTREAM - 1 downto 0);
        signal pf_in240_err_stream, pf_out240_err_stream: std_logic_vector(NPFSTREAM - 1 downto 0);
    
        signal links_in, links_out : w64s(N_IN-1 downto 0);
        signal valid_in, invalid_out : std_logic_vector(N_IN-1 downto 0);
begin

    ipb_out <= IPB_RBUS_NULL;

    export_rst240: process(clk_payload(2))
    begin
        if rising_edge(clk_payload(2)) then
            rst240_u <= rst_loc(0);
            rst240_chain(RST_CHAIN_DELAY) <= rst240_u;
            rst240_chain(RST_CHAIN_DELAY-1 downto 0) <= rst240_chain(RST_CHAIN_DELAY downto 1);
            rst240 <= rst240_chain(0);
        end if;
    end process export_rst240;

    buffers_in: for i in 0 to N_IN-1 generate
        buff_in : entity work.word_delay
            generic map(DELAY => N_DELAY_IN, N_BITS => 65)
            port    map(clk => clk_p, enable => '1',
                        d(63 downto 0) => d(i).data,
                        d(64)          => d(i).valid,
                        q(63 downto 0) => links_in(i),
                        q(64)          => valid_in(i));
        end generate buffers_in;

    input_links: process(clk_p)
    begin
        if rising_edge(clk_p) then
            if valid_in(0) = '1' and pf_in_valid_stream(0) = '0' then
                pf_in_count <= 0;
                pf_in_write <= '1';
            end if;
            if pf_in_write = '1' then
                if pf_in_count = NCLK_WRITE360-1 then
                    pf_in_write <= '0';
                    pf_in_count <= 0;
                else
                    pf_in_count <= pf_in_count + 1;
                    pf_in_write  <= '1';
                end if;
            end if;
            pf_in_stream       <= links_in;
            pf_in_valid_stream <= valid_in;
        end if;
    end process input_links;

    gen_pf_in_cdc: for i in 0 to NPFSTREAM-1 generate
        pf_in_cdc: entity work.cdc_bram_fifo
            port map(clk_in => clk_p, clk_out => clk_payload(2), rst_in => rst_loc(0),
                     data_in  => pf_in_stream(i),
                     wr_en    => pf_in_write,
                     data_out => pf_in240_stream(i),
                     rd_en    => '1',
                     rderr    => pf_in240_err_stream(i));
        end generate gen_pf_in_cdc;

    pf_unpack: entity work.serial2parallel
            generic map(NITEMS => NPFTOT, NSTREAM => NPFSTREAM, NREAD => PFII)
            port map(ap_clk   => clk_payload(2),
                     ap_start => pf_in240_err_stream(0), 
                     data_in  => pf_in240_stream,
                     valid_in => (others => '1'),
                     data_out  => pf_in,
                     valid_out => open,
                     ap_done   => pf_start
                     );

    pfblock : entity work.pf_block
        port map(ap_clk   => clk_payload(2), 
                 ap_rst   => '0', --rst240, 
                 ap_start => pf_start,
                 ap_done  => pf_done,
                 pf_in    => pf_in,
                 pf_out   => pf_out
                );

    pf_streamer : entity work.parallel2serial
                generic map(NITEMS => NPFTOT, NSTREAM => NPFSTREAM)
                port map( ap_clk => clk_payload(2),
                          roll   => pf_done,
                          data_in  => pf_out,
                          valid_in => (others => '1'),
                          data_out  => pf_out240_stream,
                          valid_out => open,
                          roll_out  => pf_serialized);

    pf_write : process(clk_payload(2))
    begin
        if rising_edge(clk_payload(2)) then
            if pf_serialized = '1' then
                pf_out_write <= '1';
            end if;
            pf_towrite240 <= pf_out240_stream;
        end if;
    end process pf_write;

    gen_pf_out_cdc: for i in 0 to NPFSTREAM-1 generate
        pf_out_cdc: entity work.cdc_bram_fifo
            port map(clk_in => clk_payload(2), clk_out => clk_p, rst_in => '0', --rst240,
                     data_in  => pf_towrite240(i),
                     data_out => pf_out_stream(i),
                     wr_en    => pf_out_write,
                     rd_en    => '1',
                     rderr    => pf_out240_err_stream(i));
        end generate gen_pf_out_cdc;

    buffers_out: for i in 0 to N_OUT-1 generate
        buff_out : entity work.word_delay
                    generic map(DELAY => N_DELAY_OUT, N_BITS => 65)
                    port    map(clk => clk_p, enable => '1',
                                d(63 downto 0) => pf_out_stream(i),
                                d(64)          => pf_out240_err_stream(i),
                                q(63 downto 0) => links_out(i),
                                q(64)          => invalid_out(i));
                                
        end generate buffers_out;

    emp_output: process(clk_p)
    begin
        if rising_edge(clk_p) then
            for i in 0 to N_OUT-1 loop 
                q(i).data   <= links_out(i);
                q(i).valid  <= not(invalid_out(i));
                q(i).strobe <= '1';
            end loop;
        end if;
    end process emp_output;    

    zerofill:	
    process(clk_p) 
    begin
        if rising_edge(clk_p) then
            for i in 4 * N_REGION - 1 downto N_OUT loop
                q(i).data <= (others => '0');
                q(i).valid <= '0';
                q(i).strobe <= '1';
            end loop;
        end if;
    end process zerofill;
    
    bc0 <= '0';
    
    gpio <= (others => '0');
    gpio_en <= (others => '0');

end rtl;
