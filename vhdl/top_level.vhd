library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.types_package.all;

entity top_level is
port(
    CLK         : in std_logic;
    rst         : in std_logic;
    in_layer    : in std_logic_vector(783 downto 0);
    out_layer   : out out_type
    );
end top_level;
    
architecture behavioral of top_level is
component dataflow
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
end component;

component bmac_784
port(
    weights, previous : in std_logic_vector(783 downto 0);
    bias : in std_logic;
    node_value : out std_logic 
    );
end component;    

component bmac_512
port(
    weights, previous : in std_logic_vector(511 downto 0);
    threshold : in std_logic_vector(10 downto 0);
    bias : in std_logic;
    node_value : out std_logic 
    );
end component;  

component bmac_10
port(
    weights, previous : in std_logic_vector(511 downto 0);
    bias : in std_logic;
    node_value : out std_logic_vector(9 downto 0) 
    );
end component;  

signal threshold_bmac_512 : std_logic_vector(10 downto 0);
signal threshold_bmac_10 : std_logic_vector(10 downto 0);

signal prev_pct_0 : std_logic_vector(783 downto 0);
signal prev_pct_1 : std_logic_vector(511 downto 0);
signal prev_pct_2 : std_logic_vector(511 downto 0);
signal weight_0   : std_logic_vector(783 downto 0);
signal weight_1   : std_logic_vector(511 downto 0);
signal weight_2   : std_logic_vector(511 downto 0);
signal bias_0     : std_logic;
signal bias_1     : std_logic;
signal bias_2     : std_logic;
signal enable     : std_logic_vector(2 downto 0);
signal calced_pct_0 : std_logic;
signal calced_pct_1 : std_logic;
signal calced_pct_2 : std_logic_vector(9 downto 0);
    
begin

threshold_bmac_512 <= std_logic_vector(to_unsigned(255, threshold_bmac_512'length));

l_dataflow: dataflow 
generic map (
    cycles_per_BMAC => 1,
    input_size => 784,
    hidden_layer_size => 512,
    output_layer_size => 10
)
port map(
    clk,
    rst,
    in_layer,
    prev_pct_0,
    prev_pct_1,
    prev_pct_2,
    weight_0,
    weight_1,
    weight_2,
    bias_0,
    bias_1,
    bias_2,
    enable,
    calced_pct_0,
    calced_pct_1,
    calced_pct_2,
    out_layer
    );
    
l_bmac_0: bmac_784
port map(
    weight_0,
    prev_pct_0,
    bias_0,
    calced_pct_0
    ); 
    
l_bmac_1: bmac_512
port map(
    weight_1,
    prev_pct_1,
    threshold_bmac_512,
    bias_1,
    calced_pct_1
    ); 
    
l_bmac_2: bmac_10
port map(
    weight_2,
    prev_pct_2,
    bias_2,
    calced_pct_2
    ); 
    
end behavioral;