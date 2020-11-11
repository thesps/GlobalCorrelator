library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.regionizer_data.all;

entity serial2parallel is
    generic(
        NITEMS  : natural; -- number of parallel outputs 
        NSTREAM : natural; -- number of input serial streams
        NREAD   : natural; -- number of clock cycles to read
        NWAIT   : natural := 0  -- number of clock cycles to wait (II of output should be NREAD+NWAIT)
    );
    port(
            ap_clk:    in  std_logic; 
            ap_start:  in  std_logic;
            data_in:   in  w64s(NSTREAM-1 downto 0);
            valid_in:  in  std_logic_vector(NSTREAM-1 downto 0);
            data_out:  out w64s(NITEMS-1 downto 0);
            valid_out: out std_logic_vector(NITEMS-1 downto 0);
            ap_done:   out std_logic;
            rden_out:  out std_logic
    );
		
end serial2parallel;

architecture Behavioral of serial2parallel is
    constant NMEM : natural := NREAD*NSTREAM;
    signal data  : w64s(NMEM-1 downto 0) := (others => (others => '0'));
    signal valid : std_logic_vector(NMEM-1 downto 0):= (others => '0');
    signal count : integer range 0 to NREAD+NWAIT-1 := 0;
    signal may_read : std_logic := '1';
begin
    rden_out <= ap_start and may_read;

    logic: process(ap_clk) 
        begin
            if rising_edge(ap_clk) then
                if ap_start = '0' then
                    valid <= (others => '0');
                    ap_done  <= '0';
                    count <= 0;
                    may_read <= '1';
                    --if NITEMS = NTKSORTED then
                    --    report "S2P active at count " & integer'image(count) & " channel " & integer'image(i) & "  data: "
                    --end if;
                else
                    -- stream in data
                    if count <= NREAD-1 then
                        for i in 0 to NSTREAM-1 loop
                            -- we're filling in the block [ i*NREAD, (i+1)*NREAD-1 ] --
                            -- put the new value at the end, and shift the others up
                            data ((i+1)*NREAD-2 downto i*NREAD) <=  data((i+1)*NREAD-1 downto i*NREAD+1);
                            valid((i+1)*NREAD-2 downto i*NREAD) <= valid((i+1)*NREAD-1 downto i*NREAD+1);
                            data ((i+1)*NREAD-1) <=  data_in(i);
                            valid((i+1)*NREAD-1) <= valid_in(i);
                        end loop;
                    end if;
                    -- counter to signal when done
                    if count = NREAD-1 then
                        ap_done <= '1';
                    else
                        ap_done <= '0';
                    end if;
                    -- increment & cycle counter
                    if count /= NREAD+NWAIT-1 then
                        count <= count + 1;
                        if count < NREAD-1 then
                            may_read <= '1';
                        else
                            may_read <= '0';
                        end if;
                    else
                        count <= 0;
                        may_read <= '1';
                    end if;
               end if; -- ap_start
            end if; -- clk
        end process logic;

    data_out  <= data(NITEMS-1 downto 0);
    valid_out <= valid(NITEMS-1 downto 0);

end Behavioral;
