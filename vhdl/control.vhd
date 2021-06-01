library ieee;
use ieee.std_logic_1164.all;

entity control is
port(
    clk         : in std_logic;
    rst         : in std_logic;
    c_signal    : out std_logic
    );
end control;