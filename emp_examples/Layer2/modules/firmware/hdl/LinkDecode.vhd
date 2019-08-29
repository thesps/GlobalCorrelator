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

library PFChargedObj;
use PFChargedObj.DataType;
use PFChargedObj.ArrayTypes;

entity LinkDecode is
port(
  clk : in std_logic;
  LinksIn : in ldata(4 * N_REGION - 1 downto 0) := (others => lword_null);
  PFChargedObjStream : out PFChargedObj.ArrayTypes.Vector(0 to N_Layer1Boards * N_PFChargedObj_PerRegion - 1) := PFChargedObj.ArrayTypes.NullVector(N_Layer1Boards * N_PFChargedObj_PerRegion)
);
end LinkDecode;


architecture behavioral of LinkDecode is
  signal PFChargedObjInt : PFChargedObj.ArrayTypes.Vector(0 to N_Layer1Boards * N_PFChargedObj_PerRegion - 1) := PFChargedObj.ArrayTypes.NullVector(N_Layer1Boards * N_PFChargedObj_PerRegion);
begin 
 
  DecodeChargedObjs : for i in 0 to N_Layer1Boards * N_PFChargedObj_PerRegion - 1 generate
    --signal tmp : PFChargedObj.DataType.tData := PFChargedObj.DataType.NullData;
    signal tmp : DataType.tData := DataType.cNull;
  begin
    --tmp <= PFChargedObj.DataType.ToDataType(LinksIn(i));
    tmp <= DataType.ToDataType(LinksIn(i).data);
    PFChargedObjInt(i).pt <= tmp.pt;
    PFChargedObjInt(i).eta <= tmp.eta;
    PFChargedObjInt(i).phi <= tmp.phi;
    PFChargedObjInt(i).id <= tmp.id;
    PFChargedObjInt(i).z0 <= tmp.z0;
    PFChargedObjInt(i).DataValid <= tmp.DataValid;
    PFChargedObjInt(i).FrameValid <= to_boolean(LinksIn(i).valid);
  end generate;

PFChargedObjStream <= PFChargedObjInt;

DebugInstance : entity PFChargedObj.Debug
--DebugInstance : entity Debug
generic map( FileName => "LinkDecode" )
port map(clk, PFChargedObjInt);

end behavioral;
