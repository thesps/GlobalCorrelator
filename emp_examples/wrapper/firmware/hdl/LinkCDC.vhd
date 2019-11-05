library ieee;
use ieee.std_logic_1164.all;

use work.emp_data_types.all;

entity LinkCDC is
port(
  clk_in : in std_logic := '0';
  clk_out : in std_logic := '0';
  d_in : in ldata;
  d_out : out ldata
);
end LinkCDC;

architecture rtl of LinkCDC is
  signal r0 : ldata(d_in'length-1 downto 0);
  signal r1 : ldata(d_in'length-1 downto 0);
  signal r2 : ldata(d_in'length-1 downto 0);
  signal r3 : ldata(d_in'length-1 downto 0);

  attribute ASYNC_REG : string;
  attribute ASYNC_REG of r1 : signal is "TRUE";
  attribute ASYNC_REG of r2 : signal is "TRUE";
  attribute ASYNC_REG of r3 : signal is "TRUE";

begin

  -- Register the input in the input domain clock
  InRegProc:
  process(clk_in)
  begin
    if rising_edge(clk_in) then
      r0 <= d_in;
    end if;
  end process;

  CDC:
  process(clk_out)
  begin
    if rising_edge(clk_out) then
      r1 <= r0;
      r2 <= r1;
      r3 <= r2;
    end if;
  end process;

  d_out <= r3;

end rtl;
