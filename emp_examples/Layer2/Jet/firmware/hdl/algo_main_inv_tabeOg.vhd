-- ==============================================================
-- Vivado(TM) HLS - High-Level Synthesis from C, C++ and SystemC v2019.2 (64-bit)
-- Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
-- ==============================================================
library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;

entity algo_main_inv_tabeOg_rom is 
    generic(
             DWIDTH     : integer := 8; 
             AWIDTH     : integer := 10; 
             MEM_SIZE    : integer := 1024
    ); 
    port (
          addr0      : in std_logic_vector(AWIDTH-1 downto 0); 
          ce0       : in std_logic; 
          q0         : out std_logic_vector(DWIDTH-1 downto 0);
          clk       : in std_logic
    ); 
end entity; 


architecture rtl of algo_main_inv_tabeOg_rom is 

signal addr0_tmp : std_logic_vector(AWIDTH-1 downto 0); 
type mem_array is array (0 to MEM_SIZE-1) of std_logic_vector (DWIDTH-1 downto 0); 
signal mem : mem_array := (
    0 => "10000000", 1 to 8=> "01111111", 9 to 16=> "01111110", 17 to 24=> "01111101", 
    25 to 33=> "01111100", 34 to 41=> "01111011", 42 to 50=> "01111010", 51 to 59=> "01111001", 
    60 to 68=> "01111000", 69 to 77=> "01110111", 78 to 86=> "01110110", 87 to 96=> "01110101", 
    97 to 105=> "01110100", 106 to 115=> "01110011", 116 to 125=> "01110010", 126 to 135=> "01110001", 
    136 to 146=> "01110000", 147 to 156=> "01101111", 157 to 167=> "01101110", 168 to 178=> "01101101", 
    179 to 189=> "01101100", 190 to 200=> "01101011", 201 to 212=> "01101010", 213 to 224=> "01101001", 
    225 to 236=> "01101000", 237 to 248=> "01100111", 249 to 261=> "01100110", 262 to 273=> "01100101", 
    274 to 286=> "01100100", 287 to 299=> "01100011", 300 to 313=> "01100010", 314 to 327=> "01100001", 
    328 to 341=> "01100000", 342 to 355=> "01011111", 356 to 370=> "01011110", 371 to 385=> "01011101", 
    386 to 400=> "01011100", 401 to 416=> "01011011", 417 to 432=> "01011010", 433 to 448=> "01011001", 
    449 to 465=> "01011000", 466 to 482=> "01010111", 483 to 500=> "01010110", 501 to 518=> "01010101", 
    519 to 536=> "01010100", 537 to 555=> "01010011", 556 to 574=> "01010010", 575 to 594=> "01010001", 
    595 to 614=> "01010000", 615 to 635=> "01001111", 636 to 656=> "01001110", 657 to 678=> "01001101", 
    679 to 700=> "01001100", 701 to 723=> "01001011", 724 to 747=> "01001010", 748 to 771=> "01001001", 
    772 to 796=> "01001000", 797 to 822=> "01000111", 823 to 848=> "01000110", 849 to 875=> "01000101", 
    876 to 903=> "01000100", 904 to 932=> "01000011", 933 to 961=> "01000010", 962 to 992=> "01000001", 
    993 to 1023=> "01000000" );


begin 


memory_access_guard_0: process (addr0) 
begin
      addr0_tmp <= addr0;
--synthesis translate_off
      if (CONV_INTEGER(addr0) > mem_size-1) then
           addr0_tmp <= (others => '0');
      else 
           addr0_tmp <= addr0;
      end if;
--synthesis translate_on
end process;

p_rom_access: process (clk)  
begin 
    if (clk'event and clk = '1') then
        if (ce0 = '1') then 
            q0 <= mem(CONV_INTEGER(addr0_tmp)); 
        end if;
    end if;
end process;

end rtl;

Library IEEE;
use IEEE.std_logic_1164.all;

entity algo_main_inv_tabeOg is
    generic (
        DataWidth : INTEGER := 8;
        AddressRange : INTEGER := 1024;
        AddressWidth : INTEGER := 10);
    port (
        reset : IN STD_LOGIC;
        clk : IN STD_LOGIC;
        address0 : IN STD_LOGIC_VECTOR(AddressWidth - 1 DOWNTO 0);
        ce0 : IN STD_LOGIC;
        q0 : OUT STD_LOGIC_VECTOR(DataWidth - 1 DOWNTO 0));
end entity;

architecture arch of algo_main_inv_tabeOg is
    component algo_main_inv_tabeOg_rom is
        port (
            clk : IN STD_LOGIC;
            addr0 : IN STD_LOGIC_VECTOR;
            ce0 : IN STD_LOGIC;
            q0 : OUT STD_LOGIC_VECTOR);
    end component;



begin
    algo_main_inv_tabeOg_rom_U :  component algo_main_inv_tabeOg_rom
    port map (
        clk => clk,
        addr0 => address0,
        ce0 => ce0,
        q0 => q0);

end architecture;


