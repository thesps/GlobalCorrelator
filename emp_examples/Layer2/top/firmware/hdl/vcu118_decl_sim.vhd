-- emp_project_decl for the VCU118 minimal example design
--
-- Defines constants for the whole project
--


library IEEE;
use IEEE.STD_LOGIC_1164.all;

-------------------------------------------------------------------------------
package emp_device_decl is

  constant N_REGION : integer := 28;
  constant cTimeMultiplexingPeriod : integer := 6;
  constant cFramesPerBX : integer := 12;

end emp_device_decl;
-------------------------------------------------------------------------------
