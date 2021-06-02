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
component dataflow
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
end component;

component bmac
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
end component;    
    
begin

l_dataflow: dataflow 
port map(

    );
    
l_bmac_0: bmac 
generic map(
    length => 784
    )
port map(

    ); 
    
l_bmac_1: bmac 
generic map(
    length => 512
    )
port map(

    ); 
    
l_bmac_2: bmac 
generic map(
    length => 512
    )
port map(

    ); 
    
end behavioral;