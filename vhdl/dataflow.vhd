library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity dataflow is
generic (
		cycles_per_BMAC : integer := 3
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
		calced_pct      : in std_logic_vector(2 downto 0);
		out_layer       : out std_logic_vector(9 downto 0)
		);
end dataflow;

architecture dataflow_architecture of dataflow is
    
    type weights_memory_0 is array (0 to 511) of std_logic_vector(783 downto 0);
    type weights_memory_1 is array (0 to 511) of std_logic_vector(511 downto 0);
    type weights_memory_2 is array (0 to 9) of std_logic_vector(511 downto 0);
    
    --alias bread is read[line, std_ulogic_vector];
    
    impure function init_weights_mem_0 return weights_memory_0 is
        file text_file : text open read_mode is "TODO.txt";
        variable text_line : line;
        variable weights : weights_memory_0;
        variable good : boolean;
    begin
        for i in 0 to 511 loop
            readline(text_file, text_line);
            read(text_line, weights(i), good);
        end loop;
        
        return weights;
    end function;
    
    impure function init_weights_mem_1 return weights_memory_1 is
        file text_file : text open read_mode is "TODO.txt";
        variable text_line : line;
        variable weights : weights_memory_1;
        variable good : boolean;
    begin
        for i in 0 to 511 loop
            readline(text_file, text_line);
            read(text_line, weights(i), good);
        end loop;
        
        return weights;
    end function;
    
    impure function init_weights_mem_2 return weights_memory_2 is
        file text_file : text open read_mode is "TODO.txt";
        variable text_line : line;
        variable weights : weights_memory_2;
        variable good : boolean;
    begin
        for i in 0 to 9 loop
            readline(text_file, text_line);
            read(text_line, weights(i), good);
        end loop;
        
        return weights;
    end function;
    
    
    signal weights_mem_0 : weights_memory_0 := init_weights_mem_0;
    signal weights_mem_1 : weights_memory_1;
    signal weights_mem_2 : weights_memory_2;
    
    signal layer0_pct       : std_logic_vector(783 downto 0);
    signal layer1_pct_buff  : std_logic_vector(511 downto 0);
    signal layer1_pct       : std_logic_vector(511 downto 0);
    signal layer2_pct_buff  : std_logic_vector(511 downto 0);
    signal layer2_pct       : std_logic_vector(511 downto 0);
    signal layer3_pct_buff  : std_logic_vector(9 downto 0);
    signal layer3_pct       : std_logic_vector(9 downto 0);
    
begin

	process(CLK)
	
		variable i : integer range 0 to 512 := 512;
		variable cycles_BMAC : integer range 0 to cycles_per_BMAC := 0;

    begin

        prev_pct_0 <= layer0_pct;
		prev_pct_1 <= layer1_pct;
		prev_pct_2 <= layer2_pct;
		out_layer <= layer3_pct;

		if rising_edge(clk) then
		
		      

			-- check if BMAC is not yet done
			if (cycles_BMAC < cycles_per_BMAC - 1) then
				cycles_BMAC := cycles_BMAC + 1;

			else
				--TODO: enable write of calced_pct to register x3?
				cycles_BMAC := 0;
				i := i + 1;
				layer1_pct_buff(i) <= calced_pct(0);
				layer2_pct_buff(i) <= calced_pct(1);
				layer3_pct_buff(i) <= calced_pct(2);
				
			end if;
			    
        
			-- all layers active
			if (i < 10) then
				enable(0) <= '1';
				enable(1) <= '1';
				enable(2) <= '1';
				--TODO: select input weights x3
				weight_0 <= weights_mem_0(i);
				weight_1 <= weights_mem_1(i);
				weight_2 <= weights_mem_2(i);

			-- input and hidden layers active
			elsif (i < 512) then
				enable(0) <= '1';
				enable(1) <= '1';
				enable(2) <= '0';
				--TODO: select input weights x2
				weight_0 <= weights_mem_0(i);
				weight_1 <= weights_mem_1(i);

			else 	
				enable(0) <= '0';
				enable(1) <= '0';
				enable(2) <= '0';
				i := 0;
				--TODO: move calced_pct activations to next stage
				layer0_pct <= in_layer;
				layer1_pct <= layer1_pct_buff;
				layer2_pct <= layer2_pct_buff;
				layer3_pct <= layer3_pct_buff;
				
			end if;
		end if;    
	end process;

end dataflow_architecture;
