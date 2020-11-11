library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

entity cdc_bram_fifo is
	port(
		clk_in:   in  std_logic; 
                clk_out:  in  std_logic;
                rst_in:   in  std_logic;
                data_in:  in  std_logic_vector(63 downto 0);
                data_out: out std_logic_vector(63 downto 0);
                --data_in:  in  std_logic_vector(71 downto 0);
                --data_out: out std_logic_vector(71 downto 0);
                wr_en:    in  std_logic; -- write enable (on clk_in)
                rd_en:    in  std_logic; -- read enable (on clk_out)
                full:     out std_logic; -- write full (on clk_in)
                empty:    out std_logic; -- read empty (on clk_out)
                wrerr:    out std_logic; -- write error (on clk_in)
                rderr:    out std_logic  -- read error (on clk_out)
 	);
		
end cdc_bram_fifo;

architecture rtl of cdc_bram_fifo is

begin

    impl: FIFO36E2
            generic map(
                WRITE_WIDTH => 72,
                READ_WIDTH => 72,
                REGISTER_MODE => "REGISTERED",
                CLOCK_DOMAINS => "INDEPENDENT"
            )
            port map(
                PROGEMPTY => open,
                PROGFULL => open,
                DIN   => data_in(63 downto 0),
                DINP  => (others => '0'), --data_in(71 downto 64),
                DOUT  => data_out(63 downto 0),
                DOUTP => open, --data_out(71 downto 64),
                EMPTY => empty,
                FULL  => full,
                RDCLK => clk_out,
                RDCOUNT => open,
                RDEN => rd_en,
                RDERR => rderr,
                RDRSTBUSY => open,
                RST => rst_in,
                WRCLK => clk_in,
                WREN => wr_en,
                WRERR => wrerr,
                WRRSTBUSY => open,
                -- unused inputs for cascading
                REGCE => '1',
                RSTREG => '0',
                SLEEP => '0',
                CASDIN => (others=>'0'),
                CASDINP => (others=>'0'),
                CASPRVEMPTY => '0',
                CASNXTRDEN => '0', 
                CASOREGIMUX => '0',
                CASOREGIMUXEN => '1',
                CASDOMUX => '0',
                CASDOMUXEN => '1',
                INJECTSBITERR => '0',
                INJECTDBITERR => '0'
            );

end rtl;
