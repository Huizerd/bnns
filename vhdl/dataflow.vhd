library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use work.types_package.all;

entity dataflow is
generic (
		cycles_per_BMAC : integer := 3;
		input_size : integer := 784;
		hidden_layer_size : integer := 512;
		output_layer_size : integer := 10
		);
port(
		clk             : in std_logic;
		rst             : in std_logic;
		in_layer        : in std_logic_vector(input_size - 1 downto 0);
		prev_pct_0      : out std_logic_vector(input_size - 1 downto 0);
		prev_pct_1      : out std_logic_vector(hidden_layer_size - 1 downto 0);
		prev_pct_2      : out std_logic_vector(hidden_layer_size - 1 downto 0);
		weight_0        : out std_logic_vector(input_size - 1 downto 0);
		weight_1        : out std_logic_vector(hidden_layer_size - 1 downto 0);
		weight_2        : out std_logic_vector(hidden_layer_size - 1 downto 0);
		bias_0          : out std_logic;
		bias_1          : out std_logic;
		bias_2          : out std_logic;
		enable          : out std_logic_vector(2 downto 0);
		calced_pct_0    : in std_logic;
		calced_pct_1    : in std_logic;
		calced_pct_2    : in std_logic_vector(9 downto 0);
		out_layer       : out out_type
		);
end dataflow;

architecture dataflow_architecture of dataflow is
    
    type weights_memory_0 is array (0 to hidden_layer_size - 1) of std_logic_vector(input_size - 1 downto 0);
    type weights_memory_1 is array (0 to hidden_layer_size - 1) of std_logic_vector(hidden_layer_size - 1 downto 0);
    type weights_memory_2 is array (0 to output_layer_size - 1) of std_logic_vector(hidden_layer_size - 1 downto 0);
    
    impure function init_weights_mem_0 return weights_memory_0 is
        file text_file : text open read_mode is "../export/base_version_7/l0_weights.txt";
        variable text_line : line;
        variable weights : weights_memory_0;
        variable good : boolean;
    begin
        for i in 0 to hidden_layer_size - 1 loop
            readline(text_file, text_line);
            read(text_line, weights(i), good);
        end loop;
        
        return weights;
    end function;
    
    impure function init_weights_mem_1 return weights_memory_1 is
        file text_file : text open read_mode is "../export/base_version_7/l1_weights.txt";
        variable text_line : line;
        variable weights : weights_memory_1;
        variable good : boolean;
    begin
        for i in 0 to hidden_layer_size - 1 loop
            readline(text_file, text_line);
            read(text_line, weights(i), good);
        end loop;
        
        return weights;
    end function;
    
    impure function init_weights_mem_2 return weights_memory_2 is
        file text_file : text open read_mode is "../export/base_version_7/l2_weights.txt";
        variable text_line : line;
        variable weights : weights_memory_2;
        variable good : boolean;
    begin
        for i in 0 to output_layer_size - 1 loop
            readline(text_file, text_line);
            read(text_line, weights(i), good);
        end loop;
        
        return weights;
    end function;
    
    impure function init_bias_mem_0 return std_logic_vector is
        file text_file : text open read_mode is "../export/base_version_7/l0_biases.txt";
        variable text_line : line;
        variable biases : std_logic_vector(hidden_layer_size - 1 downto 0);
        variable good : boolean;
    begin
        readline(text_file, text_line);
        read(text_line, biases, good);
        return biases;
    end function;
    
    impure function init_bias_mem_1 return std_logic_vector is
        file text_file : text open read_mode is "../export/base_version_7/l1_biases.txt";
        variable text_line : line;
        variable biases : std_logic_vector(hidden_layer_size - 1 downto 0);
        variable good : boolean;
    begin
        readline(text_file, text_line);
        read(text_line, biases, good);
        return biases;
    end function;
    
    impure function init_bias_mem_2 return std_logic_vector is
        file text_file : text open read_mode is "../export/base_version_7/l2_biases.txt";
        variable text_line : line;
        variable biases : std_logic_vector(output_layer_size - 1 downto 0);
        variable good : boolean;
    begin
        readline(text_file, text_line);
        read(text_line, biases, good);
        return biases;
    end function;
    
    
    signal weights_mem_0 : weights_memory_0 := init_weights_mem_0;
    signal weights_mem_1 : weights_memory_1 := init_weights_mem_1;
    signal weights_mem_2 : weights_memory_2 := init_weights_mem_2;
    
    signal bias_mem_0 : std_logic_vector(hidden_layer_size - 1 downto 0) := init_bias_mem_0;
    signal bias_mem_1 : std_logic_vector(hidden_layer_size - 1 downto 0) := init_bias_mem_1;
    signal bias_mem_2 : std_logic_vector(output_layer_size - 1 downto 0) := init_bias_mem_2;
    
    signal layer0_pct       : std_logic_vector(input_size - 1 downto 0);
    signal layer1_pct_buff  : std_logic_vector(hidden_layer_size - 1 downto 0);
    signal layer1_pct       : std_logic_vector(hidden_layer_size - 1 downto 0);
    signal layer2_pct_buff  : std_logic_vector(hidden_layer_size - 1 downto 0);
    signal layer2_pct       : std_logic_vector(hidden_layer_size - 1 downto 0);
    signal layer3_pct_buff  : out_type;
    signal layer3_pct       : out_type;
    
begin

	process(clk)
	
		variable i : integer range 0 to hidden_layer_size := hidden_layer_size+1;
		variable cycles_BMAC : integer range 0 to cycles_per_BMAC := 0;

    begin

        prev_pct_0 <= layer0_pct;
		prev_pct_1 <= layer1_pct;
		prev_pct_2 <= layer2_pct;
		out_layer <= layer3_pct;

		if rising_edge(clk) then
		
		    if rst = '1' then
                enable(0) <= '0';
                enable(1) <= '0';
                enable(2) <= '0';
                layer0_pct <= in_layer;
		        i := 0;
		        cycles_BMAC := 0;
		    
		    
		    else

                -- check if BMAC is not yet done
                if (cycles_BMAC < cycles_per_BMAC - 1) then
                    cycles_BMAC := cycles_BMAC + 1;
    
                else
                    cycles_BMAC := 0;

                    if (i = 0) then
                        enable(0) <= '1';
                        enable(1) <= '0';
                        enable(2) <= '1';
                        weight_0 <= weights_mem_0(i);
                        weight_1 <= weights_mem_1(i);
                        weight_2 <= weights_mem_2(i);
                        bias_0 <= bias_mem_0(i);
                        bias_1 <= bias_mem_1(i);
                        bias_2 <= bias_mem_2(i);

                        --layer1_pct_buff(i) <= calced_pct(0);
                        --layer2_pct_buff(i) <= calced_pct(1);
                        --layer3_pct_buff(i) <= calced_pct(2);
                        i := i + 1;
                    
                    elsif (i < output_layer_size) then
                        enable(0) <= '1';
                        enable(1) <= '1';
                        enable(2) <= '1';
                        weight_0 <= weights_mem_0(i);
                        weight_1 <= weights_mem_1(i);
                        weight_2 <= weights_mem_2(i);
                        bias_0 <= bias_mem_0(i);
                        bias_1 <= bias_mem_1(i);
                        bias_2 <= bias_mem_2(i);

                        layer1_pct_buff(i-1) <= calced_pct_0;
                        layer2_pct_buff(i-1) <= calced_pct_1;
                        layer3_pct_buff(i-1) <= calced_pct_2;
                        i := i + 1;
                        
                    elsif (i = output_layer_size) then
                        enable(0) <= '1';
                        enable(1) <= '1';
                        enable(2) <= '0';
                        weight_0 <= weights_mem_0(i);
                        weight_1 <= weights_mem_1(i);
                        bias_0 <= bias_mem_0(i);
                        bias_1 <= bias_mem_1(i);
                        
                        layer1_pct_buff(i-1) <= calced_pct_0;
                        layer2_pct_buff(i-1) <= calced_pct_1;
                        layer3_pct_buff(i-1) <= calced_pct_2;
                        i := i + 1;
        
                    elsif (i < hidden_layer_size) then
                        enable(0) <= '1';
                        enable(1) <= '1';
                        enable(2) <= '0';
                        weight_0 <= weights_mem_0(i);
                        weight_1 <= weights_mem_1(i);
                        bias_0 <= bias_mem_0(i);
                        bias_1 <= bias_mem_1(i);
                        
                        layer1_pct_buff(i-1) <= calced_pct_0;
                        layer2_pct_buff(i-1) <= calced_pct_1;
                        --layer3_pct_buff(i) <= calced_pct(2);
                        i := i + 1;

                    elsif (i = hidden_layer_size) then
                        enable(0) <= '0';
                        enable(1) <= '0';
                        enable(2) <= '0';
                        --weight_0 <= weights_mem_0(i);
                        --weight_1 <= weights_mem_1(i);
                        
                        layer1_pct_buff(i-1) <= calced_pct_0;
                        layer2_pct_buff(i-1) <= calced_pct_1;
                        --layer3_pct_buff(i) <= calced_pct(2);
                        i := i + 1;
        
                    else 	
                        enable(0) <= '0';
                        enable(1) <= '0';
                        enable(2) <= '0';
                        
                        layer0_pct <= in_layer;
                        layer1_pct <= layer1_pct_buff;
                        layer2_pct <= layer2_pct_buff;
                        layer3_pct <= layer3_pct_buff;
                        i := 0;
                        
                    end if;     
                end if;
            end if;    
         end if;
	end process;

end dataflow_architecture;
