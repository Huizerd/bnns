----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/07/2021 04:15:48 PM
-- Design Name: 
-- Module Name: sevensevenadder - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity seveneightadder is
    Port (    input_1 : in std_logic_vector(7 downto 0);
              input_2 : in std_logic_vector(7 downto 0);
              input_3 : in std_logic_vector(7 downto 0);
              input_4 : in std_logic_vector(7 downto 0);
              input_5 : in std_logic_vector(7 downto 0);
              input_6 : in std_logic_vector(7 downto 0);
              input_7 : in std_logic_vector(7 downto 0);
              output  : out std_logic_vector(10 downto 0) );
end seveneightadder;

architecture Behavioral of sevensevenadder is

component full_adder is
  Port (a,b,carry_in : in std_logic; 
        sum, carry_out : out std_logic);
end component;

component half_adder is
    Port (a, b : in std_logic; 
          sum, carry : out std_logic);
end component;


signal sums_layer1_0, carries_layer1_0, sums_layer1_1, carries_layer1_1, sums_layer2, carries_layer2, sums_layer3, carries_layer3 : std_logic_vector(7 downto 0);
signal sums_layer4, carries_layer4 : std_logic_vector(5 downto 0);
signal carry_layer5, sum_layer5 : std_logic;
signal ripplecarry :std_logic_vector(7 downto 0);

begin
-- Numbers are ligned in columns, so 1 column is 1 value

--Layer 1 14 FA's
--full adders all get a b and carry from a different number ie different row, 
GEN_LAYER1: for I in 0 to 7 generate
    FA1_0_I: full_adder port map(input_1(I), input_2(I), input_3(I), sums_layer1_0(I),carries_layer1_0(I)); --Row 1 to 3
    FA1_1_I: full_adder port map(input_4(I), input_5(I), input_6(I), sums_layer1_1(I),carries_layer1_1(I)); --Row 4 to 6
end generate;

--Layer 2 7 FA's
FA2_0: full_adder port map(sums_layer1_0(0), sums_layer1_1(0), input_7(0), sums_layer2(0), carries_layer2(0));
GEN_LAYER2: for I in 1 to 7 generate
    FA2_I: full_adder port map(sums_layer1_0(I), sums_layer1_1(I), carries_layer1_0(I-1), sums_layer2(I), carries_layer2(I));
end generate;

--Layer 3 7 FA's
FA3_6: full_adder port map(carries_layer2(7), carries_layer1_0(7), carries_layer1_1(7), sums_layer3(7), carries_layer3(7));
GEN_LAYER3: for I in 0 to 6 generate
    FA3_I: full_adder port map(sums_layer2(I+1), carries_layer2(I), carries_layer1_1(I),  sums_layer3(I), carries_layer3(I));
end generate;

-- layer 4 5 FA's
GEN_LAYER4: for I in 0 to 5 generate
    FA4_I: full_adder port map(sums_layer3(I+1), carries_layer3(I), input_7(I+2), sums_layer4(I), carries_layer4(I));
end generate;

--layer 5 1 FA
FA5: full_adder port map(carries_layer4(5), sums_layer3(7), carries_layer3(6), sum_layer5,  carry_layer5);

--ripple carry

output(0) <= sums_layer2(0);

RA1: half_adder port map(input_7(1), sums_layer3(0), output(1), ripplecarry(0));
RA2: half_adder port map(sums_layer4(0), ripplecarry(0), output(2), ripplecarry(1));
RA3: full_adder port map(sums_layer4(1), carries_layer4(0), ripplecarry(1), output(3), ripplecarry(2));
RA4: full_adder port map(sums_layer4(2), carries_layer4(1), ripplecarry(2), output(4), ripplecarry(3));
RA5: full_adder port map(sums_layer4(3), carries_layer4(2), ripplecarry(3), output(5), ripplecarry(4));
RA6: full_adder port map(sums_layer4(4), carries_layer4(3), ripplecarry(4), output(6), ripplecarry(5));
RA7: full_adder port map(sums_layer4(5), carries_layer4(4), ripplecarry(5), output(7), ripplecarry(6));
RA8: half_adder port map(sum_layer5, ripplecarry(6), output(8), ripplecarry(7));
RA9: full_adder port map(carry_layer5, carries_layer3(7), ripplecarry(7), output(9), output(10));

end Behavioral;
