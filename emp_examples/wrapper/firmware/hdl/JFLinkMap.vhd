library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use work.emp_data_types.all;
use work.emp_project_decl.all;

use work.emp_device_decl.all;

-- Map some of the PF outputs to links for the Jet Finder demo
entity JFLinkMap is
	port(
		clk: in std_logic; -- clk
		d: in ldata(4 * N_REGION - 1 downto 0); -- data in
		q: out ldata(4 * N_REGION - 1 downto 0) := (others => lword_null) -- data out
	);
		
end JFLinkMap;

architecture rtl of JFLinkMap is

    signal qInt : ldata(4 * N_REGION - 1 downto 0) := (others => lword_null);

begin


    Charged:
    for i in 0 to 9 generate
        qInt(i+40) <= d(i);
    end generate;

    Photon:
    for i in 0 to 6 generate
        qInt(i+57) <= d(i+14); -- Track offset
    end generate;

    Neutral:
    for i in 0 to 4 generate
        qInt(i+52) <= d(i+14+10); -- track + photon offset
    end generate;

    Muon:
    for i in 0 to 1 generate
        qInt(i+50) <= d(i+14+10+10); -- track + photon + neutral offset
    end generate;

    RX_Unscramble:
    for i in 40 to 63 generate
        constant j : integer := 64 - (i-40) - 2 * ((i+1) MOD 2);
    begin
        q(i) <= qInt(j);
    end generate;
    
end rtl;
