library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity dataflow is
generic (
		cycles_per_BMAC : integer
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

architecture dataflow_architecture of dataflow is
    
    type weights_memory_0 is array (0 to 511) of std_logic_vector(783 downto 0);
    type weights_memory_1 is array (0 to 511) of std_logic_vector(511 downto 0);
    type weights_memory_2 is array (0 to 9) of std_logic_vector(511 downto 0);
    
    alias bread is read[line, std_logic_vector];
    
    impure function init_weights_mem_0 return weights_memory_0 is
        file text_file : text open read_mode is "TODO.txt";
        variable text_line : line;
        variable weights : weights_memory_0;
    begin
        for i in 0 to 511 loop
            readline(text_file, text_line);
            bread(text_line, weights(i));
        end loop;
        
        return weights;
    end function;
    
    impure function init_weights_mem_1 return weights_memory_1 is
        file text_file : text open read_mode is "TODO.txt";
        variable text_line : line;
        variable weights : weights_memory_1;
    begin
        for i in 0 to 511 loop
            readline(text_file, text_line);
            bread(text_line, weights(i));
        end loop;
        
        return weights;
    end function;
    
    impure function init_weights_mem_2 return weights_memory_2 is
        file text_file : text open read_mode is "TODO.txt";
        variable text_line : line;
        variable weights : weights_memory_2;
    begin
        for i in 0 to 9 loop
            readline(text_file, text_line);
            bread(text_line, weights(i));
        end loop;
        
        return weights;
    end function;
    
    signal weights_mem_0 : weights_memory_0 := init_weights_mem_0;
    signal weights_mem_1 : weights_memory_1 := init_weights_mem_1;
    signal weights_mem_2 : weights_memory_2 := init_weights_mem_2;
    
begin

	process(CLK)
	
		variable i : integer range 0 to 512;
		variable cycles_BMAC : integer range 0 to cycles_per_BMAC;

    begin

		if rising_edge(clk) then

			-- check if BMAC is not yet done
			if (cycles_BMAC < cycles_per_BMAC - 1) then
				cycles_BMAC := cycles_BMAC + 1;

			else
				--TODO: enable write of calced_pct to register x3?
				cycles_BMAC := 0;
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

end dataflow_architecture;
