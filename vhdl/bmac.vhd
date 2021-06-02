library ieee;
use ieee.std_logic_1164.all;

entity bmac is
generic(
    length : integer
    );
port(
    clk         : in std_logic;
    rst         : in std_logic;
    enable      : in std_logic;
    prev_pct    : in std_logic_vector(length-1 downto 0);
    weight      : in std_logic_vector(length-1 downto 0);
    calced_pct  : out std_logic
    );
end bmac;