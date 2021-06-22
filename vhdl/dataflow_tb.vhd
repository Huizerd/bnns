----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/08/2021 02:35:16 PM
-- Design Name: 
-- Module Name: dataflow_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity dataflow_tb is
end dataflow_tb;

architecture Behavioral of dataflow_tb is

component dataflow
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
		calced_pct      : in std_logic_vector(2 downto 0);
		out_layer       : out std_logic_vector(output_layer_size - 1 downto 0)
		);
end component;

signal clk : std_logic;
signal rst : std_logic;
signal in_layer : std_logic_vector(2 downto 0);
signal prev_pct_0 : std_logic_vector(2 downto 0);
signal prev_pct_1 : std_logic_vector(5 downto 0);
signal prev_pct_2 : std_logic_vector(5 downto 0);
signal weight_0 : std_logic_vector(2 downto 0);
signal weight_1 : std_logic_vector(5 downto 0);
signal weight_2 : std_logic_vector(5 downto 0);
signal bias_0 : std_logic;
signal bias_1 : std_logic;
signal bias_2 : std_logic;
signal enable : std_logic_vector(2 downto 0);
signal calced_pct : std_logic_vector(2 downto 0);

constant clock_period : time := 20 ns;

begin

uut: dataflow 
generic map (
    cycles_per_BMAC => 3,
    input_size => 3,
    hidden_layer_size => 6,
    output_layer_size => 4
)
port map (
    clk => clk,
    rst => rst,
    in_layer => in_layer,
    prev_pct_0 => prev_pct_0,
    prev_pct_1 => prev_pct_1,
    prev_pct_2 => prev_pct_2,
    weight_0 => weight_0,
    weight_1 => weight_1,
    weight_2 => weight_2,
    bias_0 => bias_0,
    bias_1 => bias_1,
    bias_2 => bias_2,
    enable => enable,
    calced_pct => calced_pct
);

clk_proc :process
begin
    clk <= '0';
    wait for clock_period/2;
    clk <= '1';
    wait for clock_period/2;
end process;

    rst <= '1', '0' after clock_period;
    
    in_layer <= "000", 
    "001" after 13*6*clock_period+clock_period/2, 
    "010" after 3*6*2*clock_period+clock_period/2,
    "011" after 3*6*3*clock_period+clock_period/2,
    "100" after 3*6*4*clock_period+clock_period/2,
    "101" after 3*6*5*clock_period+clock_period/2;
    
    calced_pct <= "000", 
    "001" after 3*2*clock_period+clock_period/2, 
    "010" after 3*3*clock_period+clock_period/2,
    "011" after 3*4*clock_period+clock_period/2,
    "100" after 3*5*clock_period+clock_period/2,
    "101" after 3*6*clock_period+clock_period/2;

end Behavioral;
