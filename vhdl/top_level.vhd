library ieee;
use ieee.std_logic_1164.all;

entity top_level is
port(
    clk         : in std_logic;
    rst         : in std_logic;
    in_layer    : in std_logic_vector(783 downto 0);
    out_layer   : out std_logic_vector(9 downto 0)
    );
end top_level;
    
architecture behavioral of top_level is
component control
port(
    clk         : in std_logic;
    rst         : in std_logic;
    c_signal    : out std_logic
    );
end component;

component mlp_pipeline
port(
    clk         : in std_logic;
    rst         : in std_logic;
    c_signal    : in std_logic;
    in_layer    : in std_logic_vector(783 downto 0);
    out_layer   : out std_logic_vector(9 downto 0)
    );
end component;    
    
signal c_signal : std_logic;
    
begin

l_c: control port map(
    clk => clk,
    rst => rst,
    c_signal => c_signal
    );
    
l_p: mlp_pipeline port map(
    clk => clk,
    rst => rst,
    c_signal => c_signal,
    in_layer => in_layer,
    out_layer => out_layer
    ); 
    
end behavioral;