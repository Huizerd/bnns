Library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity bias_adder is 
generic ( 	n : integer := 11); 
port(
popcount : in std_logic_vector((n-1) downto 0);
bias : in std_logic;
output : out std_logic_vector((n-2) downto 0));
end bias_adder;

architecture structural of bias_adder is

component FA is 
port(
A : in std_logic;
B : in std_logic;
Cin : in std_logic;
S : out std_logic;
Cout : out std_logic);
end component;

component HA is 
port(
A : in std_logic;
B : in std_logic;
S : out std_logic;
Cout : out std_logic);
end component;

signal add, carry, sum: std_logic_vector(9 downto 0);


begin

-- Subtract or add 1
process (bias)
begin


    case bias is 
        when '1' => add <= "0000000001" ;          
        when others => add <= "1111111111" ;
    end case;
end process;


-- ripple carry adder

RA1: HA port map(popcount(0), add(0), sum(0), carry(0));


RCA: for i in 1 to (n-2) generate
		FA_RCA: FA port map (popcount(i), add(i), carry(i-1), sum(i), carry(i));
	end generate RCA;

-- case of zero popcount and bias is subtract 1
process (sum)
begin
    case (sum(9) and sum(8)) is 
        when '1' => output <= "0000000000" ;          
        when others => output <= sum ;
    end case;
end process;


end structural ; 
