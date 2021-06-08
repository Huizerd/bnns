library ieee;
use ieee.std_logic_1164.all;

entity bmac is
generic (
    -- If we don't say e.g. := 512 here we could use it for any layer?
    n     : integer
    n_out : integer
);
port (
    prev_act : in std_logic_vector((n-1) downto 0);
    weights  : in std_logic_vector((n*n_out-1) downto 0);
    out_act  : out std_logic_vector((n_out-1) downto 0)
);
end bmac;

architecture behavioural of bmac is

component counter is
port (
    A    : in std_logic_vector (15 downto 0);
    Cout : out std_logic_vector (4 downto 0)
);
end component;

component adder_32_to_7 is
generic (
    n     : integer := 4;	
    n_out : integer := 7
); 
port (
    A       : in std_logic_vector((n-1) downto 0);
    B       : in std_logic_vector((n-1) downto 0);
    C       : in std_logic_vector((n-1) downto 0);
    D       : in std_logic_vector((n-1) downto 0);
    E       : in std_logic_vector((n-1) downto 0);
    F       : in std_logic_vector((n-1) downto 0);
    G       : in std_logic_vector((n-1) downto 0);
    H       : in std_logic_vector((n-1) downto 0);
    Add_out : out std_logic_vector((n_out-1) downto 0)
);
end component;

component seveneightadder is
port (
    input_1 : in std_logic_vector(7 downto 0);
    input_2 : in std_logic_vector(7 downto 0);
    input_3 : in std_logic_vector(7 downto 0);
    input_4 : in std_logic_vector(7 downto 0);
    input_5 : in std_logic_vector(7 downto 0);
    input_6 : in std_logic_vector(7 downto 0);
    input_7 : in std_logic_vector(7 downto 0);
    output  : out std_logic_vector(10 downto 0)
);
end component;

begin

---
---

end behavioural;
