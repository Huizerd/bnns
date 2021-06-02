library ieee;
use ieee.std_logic_1164.all;

entity dataflow is
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
    enabel          : out std_logic_vector(2 downto 0);
    calced_pct      : in std_logic_vector(2 downto 0)
    );
end dataflow;