library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Use Interfaces when simulating, xil_defaultlib when synthesizing
-- Results will be the same, but Interfaces supports debug txt file
-- synthesis translate_off
library Interfaces;
use Interfaces.mp7_data_types.ALL;
-- synthesis translate_on
-- synthesis read_comments_as_HDL on
--library xil_defaultlib;
--use xil_defaultlib.emp_data_types.all;
-- synthesis read_comments_as_HDL off

library xil_defaultlib;
use xil_defaultlib.emp_device_decl.all;

library Utilities;
use Utilities.Utilities.all;

library Layer1;
use Layer1.Constants.all;

library PFChargedObj;
use PFChargedObj.DataType;
use PFChargedObj.ArrayTypes;

entity LinkEncode is
generic(
  compressedLinks : boolean := false
);
port(
  clkPF : in std_logic;
  clkLink : in std_logic;
  PFChargedObjIn : in PFChargedObj.ArrayTypes.Vector(0 to N_PFChargedObj_PerRegion - 1) := PFChargedObj.ArrayTypes.NullVector(N_PFChargedObj_PerRegion)
  LinksOut : out ldata(4 * N_REGION - 1 downto 0) := (others => lword_null);
);
end LinkEncode;


architecture behavioral of LinkEncode is
  -- Clock cycle counters
  subtype tCounter is integer range 0 to LinkFanInFactor - 1;
  type tCounterArray is array ( integer range <> ) of tCounter;
  signal CounterArray : tCounterArray(0 to N_LinksPerLayer1Board - 1) := (others => 0); -- every link gets a counter

  subtype tCounterPF is integer range 0 to Layer1PFII - 1;
  type tCounterArrayPF is array(integer range <>) of tCounterPF;
  signal CounterArrayPF : tCounterArrayPF(0 to N_PFChargedObj_PerRegion - 1) := (others => 0);

  signal LinksFanned : ldata(N_LinksPerLayer1Board - 1 downto 0) := (others => lword_null);
  signal PFChargedObjIntPFClk : PFChargedObj.ArrayTypes.Vector(0 to N_PFChargedObj_PerRegion - 1) := PFChargedObj.ArrayTypes.NullVector(N_PFChargedObj_PerRegion);
  signal PFChargedObjIntLinkClk_0 : PFChargedObj.ArrayTypes.Vector(0 to N_PFChargedObj_PerRegion - 1) := PFChargedObj.ArrayTypes.NullVector(N_PFChargedObj_PerRegion);
  signal PFChargedObjIntLinkClk_1 : PFChargedObj.ArrayTypes.Vector(0 to N_PFChargedObj_PerRegion - 1) := PFChargedObj.ArrayTypes.NullVector(N_PFChargedObj_PerRegion);
  signal PFChargedObjPipe : PFChargedObj.ArrayTypes.VectorPipe(0 to LinkFanInFactor - 1)(0 to N_PFChargedObj_PerRegion - 1) := PFChargedObj.ArrayTypes/NullVectorPipe(LinkFanInFactor, N_PFChargedObj_PerRegion);
begin 

  PFLoop:
  for i in 0 to N_PFChargedObj_PerRegion - 1 generate
    -- Maintain the internal PFChargedObjIntPFClk to only change when the data coming in is valid
    -- So if PF IP Core II = 2, PFCHargedObjIntPFClk will change every 2 cycles
    PFInput :
    process(clkPF)
    begin
      if rising_edge(clkPF) then
        -- TODO Does every object need its own counter?
        if PFChargedObjIn(i).DataValid then
          if CountArrayPF(i) = Layer1PFII - 1 then
            CounterArrayPF(i) <= 0;
          else
            CounterArrayPF(i) <= CounterArrayPF(i) + 1;
          end if;
        end if;

        if CounterArrayPF(i) = 0 then
          PFChargedObjIntPFClk(i) <= PFChargedObjIn;
        end if;
      end if;
    end process;
  end generate

  -- Now cross the clock domain
  -- Do this in 2 cycles to avoid metastability
  PFToLinkClk:
  process(clkLink)
  begin
    if rising_edge(clkLink) then
      PFChargedObjIntLinkClk_0 <= PFChargedObjIntPFClk;
      PFChargedObjIntLinkClk_1 <= PFChargedObjIntLinkClk_0;
    end if;
  end process;

  Pipe : entity PFChargedObj.DataPipe
  port map(clkLink, PFChargedObjIntLinkClk_1, PFChargedObjPipe);

  LinksLoop:
  for i in 0 to N_LinksPerLayer1Board - 1 generate
      signal data : PFChargedObj.DataType.tData := PFChargedObj.DataType.cNull;
  begin
      -- Select the data to output this cycle
      data <= PFChargedObjPipe(CounterArray(i))(i * LinkFanInFactor + CounterArray(i));
      Counter:
      process(clkLink)
      begin
        if rising_edge(clkLink) then
            if PFChargedObjIn(i).FrameValid then
              if CounterArray(i) = LinkFanInFactor - 1 then
                CounterArray(i) <= 0;
              else
                CounterArray(i) <= CounterArray(i) + 1;
              end if;
            else
              CounterArray(i) <= 0;
            end if;

            LinksFanned(i) <= PFChargedObj.DataType.ToStdLogicVector(data);
            LinksFanned(i).valid <= to_boolean(data.DataValid);                  
        end if;
      end process;
  end generate;

  LinksOut <= LinksFanned;

DebugInstance : entity PFChargedObj.Debug
--DebugInstance : entity Debug
generic map( FileName => "LinkEncode" )
port map(clk, PFChargedObjInt);

end behavioral;
