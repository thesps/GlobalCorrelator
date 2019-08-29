library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.DataType.all;
use work.ArrayTypes.all;

library Layer2;
use Layer2.Constants.all;

entity DeltaR2 is
port(
  clk : in std_logic;
  a : in tData;
  b : in tData;
  q : out deltaR2_t
);
end DeltaR2;

architecture rtl of DeltaR2 is
  signal dPhi : etaphi_t;
  -- tmp signals for DSP inference
  signal dPhi_tmp0 : etaphi_t; -- DSP A in reg
  signal dPhi_tmp1 : etaphi_t; -- DSP B in reg
  signal qPhi_tmp0 : etaphi2_t; -- DSP internal reg
  signal qPhi_tmp1 : etaphi2_t; -- DSP q reg

  signal dEta : etaphi_t;
  -- tmp signals for DSP inference
  signal dEta_tmp0 : etaphi_t; -- DSP A in reg
  signal dEta_tmp1 : etaphi_t; -- DSP B in reg
  signal qEta_tmp0 : etaphi2_t; -- DSP internal reg
  signal qEta_tmp1 : etaphi2_t; -- DSP q reg

  attribute USE_DSP48 : string;
  attribute USE_DSP48 of qPhi_tmp0 : signal is "YES";
  attribute USE_DSP48 of qEta_tmp0 : signal is "YES";

begin

  process(clk)
  begin
    if rising_edge(clk) then
      -- Delta phi
      dPhi <= a.phi - b.phi;
      -- Delta phi**2
      dPhi_tmp0 <= dPhi;
      dPhi_tmp1 <= dPhi;
      qPhi_tmp0 <= dPhi_tmp0 * dPhi_tmp1;
      qPhi_tmp1 <= qPhi_tmp0;

      -- Delta eta
      dEta <= a.eta - b.eta;
      -- Delta eta**2
      dEta_tmp0 <= dEta;
      dEta_tmp1 <= dEta;
      qEta_tmp0 <= dEta_tmp0 * dEta_tmp1;
      qEta_tmp1 <= qEta_tmp0;

      -- Delta phi**2 + Delta eta**2
      q <= signed('0' & qPhi_tmp1) + signed('0' & qEta_tmp1);
    end if;
  end process;

end rtl;
