library ieee;
use ieee.std_logic_1164.all;

entity mlp_pipeline is
port(
    clk         : in std_logic;
    rst         : in std_logic;
    c_signal    : in std_logic;
    in_layer    : in std_logic_vector(783 downto 0);
    out_layer   : out std_logic_vector(9 downto 0)
    );
end mlp_pipeline;