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

library Layer2;
use Layer2.Constants.all;
use Layer2.PkgIterativeSeeding.all;

library PFChargedObj;
use PFChargedObj.DataType;
use PFChargedObj.ArrayTypes;

entity DebugSeedOut is
port(
  clk : in std_logic;
  NewSeed : in std_logic;
  SeedIn : in PFChargedObj.DataType.tData := PFChargedObj.DataType.cNull;
  LinkOut : out lword := lword_null
);
end DebugSeedOut;


architecture behavioral of DebugSeedOut is
  signal SeedCounter : integer range 0 to N_Seeds - 1 := 0;
  signal SeedCounter1 : integer range 0 to N_Seeds - 1 := 0;
  signal ROCounter : integer range 0 to N_Seeds := 0;
  --signal SeedsInVector : PFChargedObj.ArrayTypes.Vector(0 to 0) := PFChargedObj.ArrayTypes.NullVector(1);
  --signal SeedsInPipe : PFChargedObj.ArrayTypes.VectorPipe(0 to 1)(0 to 0) := PFChargedObj.ArrayTypes.NullVectorPipe(2, 1);
  signal SeedsInt : PFChargedObj.ArrayTypes.Vector(0 to N_Seeds - 1) := PFChargedObj.ArrayTypes.NullVector(N_Seeds);
begin 
 
  -- Pipeline the incoming seeds to detect new seeds arriving
  --SeedsInVector(0) <= SeedIn;
  --SeedsInPipe : entity PFChargedObj.DataPipe
  --port map(clk, SeedsInVector, SeedsInPipe);

  NewSeeds:
  process(clk)
  begin
    if rising_edge(clk) then
      --if SeedInPipe(0) /= SeedInPipe(1) then
      if NewSeed = '1' then
        if SeedCounter = N_Seeds - 1 then
          SeedCounter <= 0;
        else
          SeedCounter <= SeedCounter + 1;
        end if;
        SeedsInt(SeedCounter) <= SeedIn;
      end if;
      SeedCounter1 <= SeedCounter; -- Pipeline the counter
    end if;
  end process;

  ReadOut:
  process(clk)
  begin
    if rising_edge(clk) then
      if SeedCounter = N_Seeds - 1 then
        -- Start of readout
        if SeedCounter1 /= N_Seeds - 1 then
          ROCounter <= 0;
          LinkOut.data <= DataType.ToStdLogicVector(SeedsInt(ROCounter))(63 downto 0);
          LinkOut.valid <= '1';
        elsif ROCounter < N_Seeds - 1 then
          ROCounter <= ROCounter + 1;
          LinkOut.data <= DataType.ToStdLogicVector(SeedsInt(ROCounter))(63 downto 0);
          LinkOut.valid <= '1';
         elsif ROCounter = N_Seeds - 1 then
           ROCounter <= N_Seeds; -- To stop it counting up any more
           LinkOut.data <= DataType.ToStdLogicVector(SeedsInt(ROCounter))(63 downto 0);
           LinkOut.valid <= '1';
         else
           LinkOut <= lword_null;
        end if;
      else
        LinkOut <= lword_null;
      end if;
    end if;
  end process;

  LinkOut.strobe <= '1';

end behavioral;
