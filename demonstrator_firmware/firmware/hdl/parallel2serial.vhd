library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.regionizer_data.all;

entity parallel2serial is
    generic(
        NITEMS  : natural; -- number of parallel intputs 
        NSTREAM : natural -- number of output serial streams
    );
    port(
            ap_clk:    in  std_logic; 
            roll:      in  std_logic; -- true when a new parallel data bunch arrives
            data_in:   in  w64s(NITEMS-1 downto 0);
            valid_in:  in  std_logic_vector(NITEMS-1 downto 0);
            data_out:  out w64s(NSTREAM-1 downto 0);
            valid_out: out std_logic_vector(NSTREAM-1 downto 0);
            roll_out:  out std_logic -- true when the first items comes out
    );
		
end parallel2serial;

architecture Behavioral of parallel2serial is
    constant NWRITE : natural := (NITEMS+(NSTREAM-1))/NSTREAM; -- clock cycles to write out, = NITEMS/NSTREAM rounded up
    constant NMEM : natural := NITEMS;
    signal data  : w64s(NMEM-1 downto 0);
    signal valid : std_logic_vector(NMEM-1 downto 0);
begin
    logic: process(ap_clk) 
        begin
            if rising_edge(ap_clk) then
                if roll = '1' then
                    data  <= data_in;
                    valid <= valid_in;
                else
                    -- for each block, shift items down, add nulls at the end
                    -- be careful not to go outside of the vector
                    for i in 0 to NSTREAM-1 loop
                        for j in (i+1)*NWRITE-2 downto i*NWRITE loop
                            if j < NITEMS-1 then
                                data(j)  <=  data(j+1);
                                valid(j) <= valid(j+1);
                            elsif j < NITEMS then
                                data (j) <= (others => '0');
                                valid(j) <= '0';
                            end if;
                        end loop;
                        if (i+1)*NWRITE-1 < NITEMS-1 then
                            data ((i+1)*NWRITE-1) <= (others => '0');
                            valid((i+1)*NWRITE-1) <= '0';
                        end if; 
                    end loop; -- i
               end if; -- roll
               roll_out <= roll;
            end if; -- clk
        end process logic;

    gen_out: for i in 0 to NSTREAM-1 generate
        data_out(i)  <= data(i*NWRITE);
        valid_out(i) <= valid(i*NWRITE);
    end generate gen_out;

end Behavioral;
