library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.regionizer_data.all;

entity cdc_and_deserializer is
    generic(
        NSTREAM : natural;
        NITEMS : natural
    );
    port(
        clk    : IN STD_LOGIC;
        clk240 : IN STD_LOGIC;
        rst    : IN STD_LOGIC;
        rst240 : IN STD_LOGIC;
        data240  : IN w64s(NSTREAM-1 downto 0);
        write240 : IN STD_LOGIC;
        start    : IN STD_LOGIC;
        data     : OUT w64s(NITEMS-1 downto 0);
        valid    : OUT STD_LOGIC;
        done     : OUT STD_LOGIC;
        read     : OUT STD_LOGIC;
        empty    : OUT STD_LOGIC_VECTOR(NSTREAM-1 downto 0)
    );
end cdc_and_deserializer;

architecture Behavioral of cdc_and_deserializer is
    
    signal stream360 : w64s(NSTREAM-1 downto 0) := (others => (others => '0'));
    signal out360    : w64s(NITEMS-1  downto 0) := (others => (others => '0'));

    signal read360, done360, decode360_warmup, decode360_start : std_logic := '0';
    signal read360_count : natural range 0 to PFII-1;
 
begin 
    gen_cdc: for i in NSTREAM-1 downto 0 generate
        cdc: entity work.cdc_bram_fifo
                    port map(clk_in => clk240, clk_out => clk, rst_in => rst240,
                     data_in  => data240(i),
                     data_out => stream360(i),
                     wr_en    => write240,
                     rd_en    => read360,
                     empty    => empty(i));
     end generate gen_cdc;

     reader: process(clk)
     begin
         if rising_edge(clk) then
             if rst = '1' then
                 decode360_warmup <= '0';
                 read360 <= '0';
             elsif start = '1' then
                 if decode360_warmup = '0' then
                     decode360_warmup <= '1';
                     read360 <= '1';
                     read360_count <= 0;
                 else
                     if read360_count = PFII240-1 then
                         read360_count <= read360_count + 1;
                         read360    <= '0';
                     elsif read360_count = PFII-1 then
                         read360_count <= 0;
                         read360    <= '1';
                     else 
                         read360_count <= read360_count + 1;
                     end if;
                 end if;
             end if;
             decode360_start <= decode360_warmup;
         end if;
    end process reader;

    unpack: entity work.serial2parallel
            generic map(NITEMS => NITEMS, NSTREAM => NSTREAM, NREAD => PFII240, NWAIT => PFII-PFII240)
            port map(ap_clk   => clk,
                     ap_start => decode360_start, 
                     data_in  => stream360,
                     valid_in => (others => '1'),
                     data_out  => out360,
                     valid_out => open,
                     ap_done   => done360);

    pf2out: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                data  <= (others => (others => '0'));
                valid <= '0';
            elsif done360 = '1' then
                data  <= out360;
                valid <= '1';
            end if;
            done <= done360;
        end if;
    end process pf2out;

    read  <= read360;

end Behavioral;

         
        

