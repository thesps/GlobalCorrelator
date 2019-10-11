library ieee;
use ieee.STD_LOGIC_1164.all;
use ieee.STD_LOGIC_MISC.all;
use ieee.NUMERIC_STD.all;

-- synthesis translate_off
library Interfaces;
use Interfaces.mp7_data_types.all;
-- synthesis translate_on
-- synthesis read_comments_as_HDL on
--library xil_defaultlib;
--use xil_defaultlib.emp_data_types.all;
-- synthesis read_comments_as_HDL off

library Link;
use Link.DataType;
use Link.ArrayTypes;

library xil_defaultlib;
use xil_defaultlib.emp_device_decl.all;
-- -------------------------------------------------------------------------


-- -------------------------------------------------------------------------
entity PatternFileLinkSync IS
  generic(
    realLinkMin : integer := 0;
    realLinkMax : integer := 1;
    bufferLinkMin : integer := 2;
    bufferLinkMax : integer := N_REGION * 4 - 1
  );
  port(
    clk          : in STD_LOGIC            := '0'; -- The algorithm clock
    linksIn      : in ldata( N_REGION * 4 - 1 downto 0 ) := ( others => lword_null );
    linksOut     : out ldata( N_REGION * 4 - 1 downto 0 ) := ( others => lword_null )
  );
end PatternFileLinkSync;
-- -------------------------------------------------------------------------


-- -------------------------------------------------------------------------
architecture behavioral OF PatternFileLinkSync IS

  signal realLinksDelayed : ldata(realLinkMax downto realLinkMin) := (others => lword_null);
  signal linksInT : Link.ArrayTypes.Vector(N_REGION * 4 - 1 downto 0) := Link.ArrayTypes.NullVector(N_REGION * 4);
  signal linksOutT : Link.ArrayTypes.Vector(N_REGION * 4 - 1 downto 0) := Link.ArrayTypes.NullVector(N_REGION * 4);

begin

cast:
for i in 0 to bufferLinkMax generate
  linksInT(i) <= Link.DataType.from_lword(linksIn(i));
end generate;

pipeLinks :
for i in realLinkMin to realLinkMax generate
begin
  pipe:
  process(clk)
  begin
    if rising_edge(clk) then
      realLinksDelayed(i) <= linksIn(i);
    end if;
  end process;
end generate;

bufferLinks : 
for i in bufferLinkMin to bufferLinkMax generate
  signal rAddr : natural range 0 to 1023 := 0;
  signal wAddr : natural range 0 to 1023 := 0;
  constant iRealLink : integer := (i - bufferLinkMin) / ((bufferLinkMax - bufferLinkMin + 1) / (realLinkMax - realLinkMin + 1)) + realLinkMin;
 
begin

  address_update : process(clk)
    -- The index of the real link used to control readout of this buffer link
    -- Constructed such that each real link controls the same number of buffers
    --variable iRealLink : integer := (i - bufferLinkMin) / ((bufferLinkMax - bufferLinkMin + 1) / (realLinkMax - realLinkMin + 1)) + realLinkMin;
  begin
    if rising_edge(clk) then
      -- Increment the write pointer while the data is valid
      if linksIn(i).valid = '1' then
        wAddr <= wAddr + 1;
      else
        wAddr <= 0;
      end if;
      -- Increment the read pointer while the real link is valid
      if linksIn(iRealLink).valid = '1' then
        rAddr <= rAddr + 1;
      else
        rAddr <= 0;
      end if;
     
    end if;
  end process;

  Ram : entity Link.DataRam
  generic map( 
    count => 1024 )
  port map(
    clk => clk,
    DataIn => linksInT(i),
    DataOut => linksOutT(i),
    ReadAddr => raddr,
    WriteAddr => waddr,
    WriteEnable => linksIn(i).valid = '1'
  );
 
  -- One cycle read, the valid comes from the pipelined link
  linksOut(i).data <= Link.DataType.to_lword(linksOutT(i)).data;
  linksOut(i).start <= Link.DataType.to_lword(linksOutT(i)).start;
  linksOut(i).strobe <= Link.DataType.to_lword(linksOutT(i)).strobe;
  linksOut(i).valid <= realLinksDelayed(iRealLink).valid;
end generate;

realLinkO:
for i in realLinkMin to realLinkMax generate
begin
  linksOut(i) <= realLinksDelayed(i);
end generate; 

unusedLinks:
for i in 0 to 4 * N_REGION - 1 generate
  signal inReal : boolean := i >= realLinkMin and i <= realLinkMax;
  signal inBuff : boolean := i >= bufferLinkMin and i <= bufferLinkMax;
begin
  onlyUnusedLinks:
  if not inReal and not inBuff generate
    linksOut(i) <= lword_null;
  end generate;
end generate;

end behavioral;
