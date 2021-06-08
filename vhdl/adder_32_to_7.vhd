Library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity adder_32_to_7 is 
generic ( 	n : integer := 4;	
		n_out : integer := 7 ); 
port(
A : in std_logic_vector((n-1) downto 0);
B : in std_logic_vector((n-1) downto 0);
C : in std_logic_vector((n-1) downto 0);
D : in std_logic_vector((n-1) downto 0);
E : in std_logic_vector((n-1) downto 0);
F : in std_logic_vector((n-1) downto 0);
G : in std_logic_vector((n-1) downto 0);
H : in std_logic_vector((n-1) downto 0);
Add_out : out std_logic_vector((n_out-1) downto 0));
end adder_32_to_7;

architecture structural of adder_32_to_7 is

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

signal Sout_L1a, Cout_L1a, Sout_L1b, Cout_L1b  : std_logic_vector((n-1) downto 0);
signal Sout_L2a, Cout_L2a, Sout_L3a : std_logic_vector((n-1) downto 0);
signal Sout_L4a, Cout_L4a : std_logic_vector((n-1) downto 0);
signal Sout_L2b, Cout_L2b, Cout_L3a	: std_logic_vector((n-2) downto 0);
signal Cout_L3b, Cout_L3c, Cout_L4b  : std_logic;
signal Cout_L5, Cout_L5a, Cout_L5b, Cout_L5c  : std_logic;

begin


-- First 8 FA's for the first level of the wallace adder
level1a:for i in 0 to (n-1) generate
		FA_L1: FA port map (A(i), B(i), C(i), Sout_L1a(i), Cout_L1a(i));
	end generate level1a;

level1b:for i in 0 to (n-1)  generate
		FA_L1: FA port map (D(i), E(i), F(i), Sout_L1b(i), Cout_L1b(i));
	end generate level1b;

-- Second level with 7 FA's

--First 4 FA's
level2a:for i in 0 to (n-1)  generate
		FA_L2: FA port map (G(i), H(i), Sout_L1a(i), Sout_L2a(i), Cout_L2a(i));
	end generate level2a;

-- Second 3 FA's
level2b:for i in 0 to (n-2)  generate
		FA_L2: FA port map (Sout_L1b(i+1), Cout_L1a(i), Cout_L1b(i), Sout_L2b(i), Cout_L2b(i));
	end generate level2b;

--Third level with 4 FA's and 2 HA's and LSB bit of output as result

level3a:for i in 0 to (n-2) generate
		FA_L3: FA port map (Sout_L2a(i+1), Cout_L2a(i), Sout_L2b(i), Sout_L3a(i), Cout_L3a(i));
	end generate level3a;

HA_L3: HA port map (Sout_L2a(0), Sout_L1b(0), Add_out(0), Cout_L3b );

FA_L3: FA port map(Cout_L2a((n-1)), Cout_L1b((n-1)), Cout_L1a((n-1)), Sout_L3a((n-1)), Cout_L3c);


-- Fourth level with 3FA's and 1 HA and 2 LSB bits of output as result

level4a:for i in 0 to 2 generate
		FA_L4: FA port map (Sout_L3a(i+1), Cout_L3a(i), Cout_L2b(i), Sout_L4a(i), Cout_L4a(i));
	end generate level4a;

HA_L4: HA port map (Sout_L3a(0), Cout_L3b, Add_out(1), Cout_L4b);

-- Fifth level with Carry propagate adder, 1 HA and 3 FA's

HA_L5: HA port map (Sout_L4a(0), Cout_L4b, Add_out(2), Cout_L5);

FA_L5a: FA port map (Sout_L4a(1), Cout_L4a(0), Cout_L5, Add_out(3), Cout_L5a);

FA_L5b: FA port map (Sout_L4a(2), Cout_L4a(1), Cout_L5a, Add_out(4), Cout_L5b);

FA_L5c: FA port map (Cout_L3c, Cout_L4a(2), Cout_L5b, Add_out(5), Add_out(6));
	

end structural ; 
