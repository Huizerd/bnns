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
		CLK             : in std_logic;
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

    signal layer0_pct       : std_logic_vector(input_size - 1 downto 0);
    signal layer1_pct_buff  : std_logic_vector(hidden_layer_size - 1 downto 0);
    signal layer1_pct       : std_logic_vector(hidden_layer_size - 1 downto 0);
    signal layer2_pct_buff  : std_logic_vector(hidden_layer_size - 1 downto 0);
    signal layer2_pct       : std_logic_vector(hidden_layer_size - 1 downto 0);
    signal layer3_pct_buff  : out_type;
    signal layer3_pct       : out_type;
    
begin

	process(clk)
	
		variable i : integer range 0 to hidden_layer_size+1 := hidden_layer_size+1;
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
                        weight_0 <= I0_weights(i);
                        weight_1 <= I1_weights(i);
                        weight_2 <= I2_weights(i);
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
                        weight_0 <= I0_weights(i);
                        weight_1 <= I1_weights(i);
                        weight_2 <= I2_weights(i);
                        bias_0 <= bias_mem_0(i);
                        bias_1 <= bias_mem_1(i);
                        bias_2 <= bias_mem_2(i);

                        layer1_pct_buff(hidden_layer_size - i) <= calced_pct_0;
                        layer2_pct_buff(hidden_layer_size - i) <= calced_pct_1;
                        layer3_pct_buff(i - 1) <= calced_pct_2;
                        i := i + 1;
                        
                    elsif (i = output_layer_size) then
                        enable(0) <= '1';
                        enable(1) <= '1';
                        enable(2) <= '0';
                        weight_0 <= I0_weights(i);
                        weight_1 <= I1_weights(i);
                        bias_0 <= bias_mem_0(i);
                        bias_1 <= bias_mem_1(i);
                        
                        layer1_pct_buff(hidden_layer_size - i) <= calced_pct_0;
                        layer2_pct_buff(hidden_layer_size - i) <= calced_pct_1;
                        layer3_pct_buff(i - 1) <= calced_pct_2;
                        i := i + 1;
        
                    elsif (i < hidden_layer_size) then
                        enable(0) <= '1';
                        enable(1) <= '1';
                        enable(2) <= '0';
                        weight_0 <= I0_weights(i);
                        weight_1 <= I1_weights(i);
                        bias_0 <= bias_mem_0(i);
                        bias_1 <= bias_mem_1(i);
                        
                        layer1_pct_buff(hidden_layer_size - i) <= calced_pct_0;
                        layer2_pct_buff(hidden_layer_size - i) <= calced_pct_1;
                        --layer3_pct_buff(i) <= calced_pct(2);
                        i := i + 1;

                    elsif (i = hidden_layer_size) then
                        enable(0) <= '0';
                        enable(1) <= '0';
                        enable(2) <= '0';
                        --weight_0 <= weights_mem_0(i);
                        --weight_1 <= weights_mem_1(i);
                        
                        layer1_pct_buff(hidden_layer_size - i) <= calced_pct_0;
                        layer2_pct_buff(hidden_layer_size - i) <= calced_pct_1;
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