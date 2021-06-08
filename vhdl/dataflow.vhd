library ieee;
use ieee.std_logic_1164.all;

entity dataflow is
generic (
		cyclesPerBMAC : integer
		);
port(
		clk             : in std_logic;
		rst             : in std_logic;
		in_layer        : in std_logic_vector(783 downto 0);
		prev_pct_0      : out std_logic_vector(783 downto 0);
		prev_pct_1      : out std_logic_vector(511 downto 0);
		prev_pct_2      : out std_logic_vector(511 downto 0);
		weight_0        : out std_logic_vector(783 downto 0);
		weight_1        : out std_logic_vector(511 downto 0);
		weight_2        : out std_logic_vector(511 downto 0);
		enable          : out std_logic_vector(2 downto 0);
		calced_pct      : in std_logic_vector(2 downto 0)
		);
end dataflow;

architecture dataflowArch of dataflow is
begin

	process(CLK)
	
		variable i : integer range 0 to 512;
		variable cyclesBMAC : integer range 0 to cyclesPerBMAC;

    begin

		if rising_edge(clk) then

			-- check if BMAC is not yet done
			if (cyclesBMAC < cyclesperBMAC - 1) then
				cyclesBMAC := cyclesBMAC + 1;

			else
				--TODO: enable write of calced_pct to register x3?
				cyclesBMAC := 0;
				i := i + 1;
			end if;

			-- all layers active
			if (i < 10) then
				enable(0) <= '1';
				enable(1) <= '1';
				enable(2) <= '1';
				--TODO: select input weights x3

			-- input and hidden layers active
			elsif (i < 512) then
				enable(0) <= '1';
				enable(1) <= '1';
				enable(2) <= '0';
				--TODO: select input weights x2

			else 	
				enable(0) <= '0';
				enable(1) <= '0';
				enable(2) <= '0';
				i := 0;
				--TODO: move calced_pct activations to next stage

			end if;
		end if;    
	end process;

end dataflowArch;
