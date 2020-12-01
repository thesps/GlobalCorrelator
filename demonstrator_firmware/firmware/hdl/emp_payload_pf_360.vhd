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
        constant NPFSTREAM360    : natural := (NPFTOT+PFII-1)/PFII;
        constant FIRST_LINK : natural := 4*9;
        constant N_IN  : natural := NPFSTREAM360;
        constant N_OUT : natural := NPFSTREAM360;
        constant N_DELAY_IN  : natural := 6;
        constant N_DELAY_OUT : natural := 6;

        signal pf_in, pf_out_buff, pf_out: w64s(NPFTOT - 1 downto 0);
        signal pf_decode_warmup, pf_decode_start, pf_start, pf_valid, pf_done, pf_done_buff : std_logic := '0';
        signal pf_in_stream,       pf_out_stream:                   w64s(NPFSTREAM360 - 1 downto 0);
        signal pf_in_valid_stream, pf_out_valid_stream: std_logic_vector(NPFSTREAM360 - 1 downto 0);
    
        signal links_in, links_out : w64s(N_IN-1 downto 0);
        signal valid_in, valid_out : std_logic_vector(N_IN-1 downto 0);
begin

    ipb_out <= IPB_RBUS_NULL;

    buffers_in: for i in 0 to N_IN-1 generate
        buff_in : entity work.word_delay
            generic map(DELAY => N_DELAY_IN, N_BITS => 65)
            port    map(clk => clk_p, enable => '1',
                        d(63 downto 0) => d(FIRST_LINK+i).data,
                        d(64)          => d(FIRST_LINK+i).valid,
                        q(63 downto 0) => links_in(i),
                        q(64)          => valid_in(i));
        end generate buffers_in;

    input_links: process(clk_p)
    begin
        if rising_edge(clk_p) then
            if valid_in(0) = '1' and pf_in_valid_stream(0) = '0' then
                pf_decode_warmup <= '1';
            end if;
            pf_decode_start <= pf_decode_warmup;
            for i in 0 to NPFSTREAM360-1 loop
                pf_in_stream(i) <= links_in(i);
                pf_in_valid_stream(i) <= valid_in(i);
            end loop;
        end if;
    end process input_links;


    pf_unpack: entity work.serial2parallel
            generic map(NITEMS => NPFTOT, NSTREAM => NPFSTREAM360, NREAD => PFII, NWAIT => 0)
            port map(ap_clk   => clk_p,
                     ap_start => pf_decode_start, 
                     data_in  => pf_in_stream,
                     valid_in => (others => '1'),
                     data_out  => pf_in,
                     valid_out => open,
                     ap_done   => pf_start
                     );

    pfblock : entity work.pf_block
        port map(ap_clk   => clk_p, 
                 ap_rst   => '0', --rst_loc(0), 
                 ap_start => pf_start,
                 ap_done  => pf_done,
                 pf_in    => pf_in,
                 pf_out   => pf_out
                );

    gen_prestream_buff: for i in 0 to N_OUT-1 generate
        prestream_buff : entity work.word_delay
                    generic map(DELAY => 2)
                    port    map(clk => clk_p, enable => '1',
                                d => pf_out(i), q => pf_out_buff(i));
        end generate gen_prestream_buff;
    prestream_done_delay: entity work.word_delay
                    generic map(DELAY => 2, N_BITS => 1) 
                    port    map(clk => clk_p, enable => '1',
                                d(0) => pf_done, q(0) => pf_done_buff);
    
    pf_streamer : entity work.parallel2serial
                generic map(NITEMS => NPFTOT, NSTREAM => NPFSTREAM360)
                port map( ap_clk => clk_p,
                          roll   => pf_done_buff,
                          data_in  => pf_out_buff,
                          valid_in => (others => '1'),
                          data_out  => pf_out_stream,
                          valid_out => pf_out_valid_stream,
                          roll_out  => open);

    buffers_out: for i in 0 to N_OUT-1 generate
        buff_out : entity work.word_delay
                    generic map(DELAY => N_DELAY_OUT, N_BITS => 65)
                    port    map(clk => clk_p, enable => '1',
                                d(63 downto 0) => pf_out_stream(i),
                                d(64)          => pf_out_valid_stream(i),
                                q(63 downto 0) => links_out(i),
                                q(64)          => valid_out(i));
                                
        end generate buffers_out;

    emp_output: process(clk_p)
    begin
        if rising_edge(clk_p) then
            for i in 0 to N_OUT-1 loop 
                q(FIRST_LINK+i).data   <= links_out(i);
                q(FIRST_LINK+i).valid  <= valid_out(i);
                q(FIRST_LINK+i).strobe <= '1';
            end loop;
        end if;
    end process emp_output;    

    zerofill:	
    process(clk_p) 
    begin
        if rising_edge(clk_p) then
            for i in FIRST_LINK - 1 downto 0 loop
                q(i).data <= (others => '0');
                q(i).valid <= '0';
                q(i).strobe <= '1';
            end loop;
            for i in 4 * N_REGION - 1 downto N_OUT+FIRST_LINK loop
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
