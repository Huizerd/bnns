Library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity FA is 
port(
A : in std_logic;
B : in std_logic;
Cin : in std_logic;
S : out std_logic;
Cout : out std_logic);
end FA;

architecture structural of FA is

begin

 S <= (A XOR B) XOR Cin ;
 Cout <= (A AND B) OR (Cin AND A) OR (Cin AND B) ;

end structural;