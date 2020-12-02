library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.regionizer_data.all;

entity tdemux_link_group is
    generic(
        NLINKS : natural; -- links per time slice
        FACTOR : natural := TDEMUX_FACTOR
    );
    port(
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        links_in : IN w64s(FACTOR*NLINKS-1 downto 0);
        valid_in : IN STD_LOGIC_VECTOR(FACTOR*NLINKS-1 downto 0);
        tdemux_out : OUT w64s(FACTOR*NLINKS-1 downto 0);
        tdemux_valid : OUT STD_LOGIC_VECTOR(FACTOR*NLINKS-1 downto 0)
    );
end tdemux_link_group;

architecture Behavioral of tdemux_link_group is
    signal tmux,  tdemux:  w65s(FACTOR*NLINKS-1 downto 0) := (others => (others => '0'));
    signal tmux_isinit, tmux_init, tdemux_return, tdemux_done: std_logic_vector(NLINKS-1 downto 0) := (others => '0');
 
begin 
    tmux_input_links: process(clk)
    begin
        if rising_edge(clk) then
            for i in 0 to NLINKS-1 loop
                for j in 0 to FACTOR-1 loop
                    tmux(FACTOR*i+j)(63 downto 0) <= links_in(FACTOR*i+j);
                    tmux(FACTOR*i+j)(64)          <= valid_in(FACTOR*i+j);
                end loop;
                if rst = '1' then
                    tmux_isinit(i) <= '0';
                    tmux_init(i)   <= '0';
                elsif valid_in(FACTOR*i) = '1' then
                    tmux_isinit(i) <= '1';
                    tmux_init(i)   <= not tmux_isinit(i);
                else
                    tmux_init(i)   <= '0';
                end if;
            end loop;
        end if;
    end process tmux_input_links;

    gen_tdemux: for i in 0 to NLINKS-1 generate
        tdemuxer : entity work.tdemux
                        port map(    ap_clk => clk,
                                     ap_rst => '0',
                                     ap_start => '1',
                                     ap_done => tdemux_done(i),
                                     ap_idle => open,
                                     ap_ready => open,
                                     newEvent => tmux_init(i),
                                     links_0_V => tmux(FACTOR*i+0),
                                     links_1_V => tmux(FACTOR*i+1),
                                     links_2_V => tmux(FACTOR*i+2),
                                     out_0_V => tdemux(FACTOR*i+0),
                                     out_1_V => tdemux(FACTOR*i+1),
                                     out_2_V => tdemux(FACTOR*i+2),
                                     ap_return(0) => tdemux_return(i));
              gen_demux_out: for j in 0 to FACTOR-1 generate
                    tdemux_out  (FACTOR*i+j) <= tdemux(FACTOR*i+j)(63 downto 0);
                    tdemux_valid(FACTOR*i+j) <= tdemux_done(i) and tdemux_return(i) and tdemux(FACTOR*i+j)(64);
              end generate gen_demux_out;
        end generate gen_tdemux;

end Behavioral;

