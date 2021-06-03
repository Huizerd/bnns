Library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity HA is 
port(
A : in std_logic;
B : in std_logic;
S : out std_logic;
Cout : out std_logic);
end HA;

architecture structural of HA is

begin

  S   <= A XOR B;
  Cout <= A AND B;

end structural;
