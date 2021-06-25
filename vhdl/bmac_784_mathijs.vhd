----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/08/2021 02:27:26 PM
-- Design Name: 
-- Module Name: bmac_784 - Behavioral
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

entity bmac_784 is
  Port (weights, previous : in std_logic_vector(783 downto 0);
        threshold : in std_logic_vector(10 downto 0);
        bias : in std_logic;
        node_value : out std_logic);
end bmac_784;

architecture Behavioral of bmac_784 is

component seveneightadder is
    Port (    input_1 : in std_logic_vector(7 downto 0);
              input_2 : in std_logic_vector(7 downto 0);
              input_3 : in std_logic_vector(7 downto 0);
              input_4 : in std_logic_vector(7 downto 0);
              input_5 : in std_logic_vector(7 downto 0);
              input_6 : in std_logic_vector(7 downto 0);
              input_7 : in std_logic_vector(7 downto 0);
              output  : out std_logic_vector(10 downto 0));
end component;

component adder_32_to_7 is 
generic ( 	n : integer := 5;	
		n_out : integer := 8 ); 
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
end component;

component counter is
port (
    A    : in std_logic_vector (15 downto 0);
    -- I think we discussed a 16 to 4-bit counter, but aren't 5 bits necessary to represent 16?
    Cout : out std_logic_vector (4 downto 0));
end component;

component threshold_bit is
  Port (popcount, threshold : in std_logic_vector(10 downto 0 );
        bias : in std_logic;
        cell_value : out std_logic);
end component;

type c_array is array (0 to 48) of std_logic_vector(4 downto 0);
type a1_array is array(0 to 5) of std_logic_vector(7 downto 0);
signal plus1_outputs, min1_outputs : std_logic_vector(783 downto 0);
signal counter_outputs_pos,counter_outputs_neg : c_array;
signal adder1_outputs_pos, adder1_outputs_neg : a1_array;
signal popcount_pos, popcount_neg : std_logic_vector(10 downto 0);
signal temp1, temp2 : std_logic_vector(7 downto 0);
begin

--XOR all input weights and previous bitwise
GENXNOR: for I in 0 to 783 generate
--    xnor_outputs(I) <= weights(I) xnor previous(I);
    plus1_outputs(I) <= previous(I) and weights(I);
    min1_outputs(I) <= previous(I) and not weights(I);
    end generate;
    
--  32 16 5 counters
--Postive counter
GENCOUNTER_POS: for I in 0 to 48 generate
    COUNTER_I: counter port map(plus1_outputs((I+1)*16-1 downto I*16), counter_outputs_pos(I));
    end generate;
--Postive counter
GENCOUNTER_NEG: for I in 0 to 48 generate
    COUNTER_I: counter port map(min1_outputs((I+1)*16-1 downto I*16), counter_outputs_neg(I));
    end generate;
    
        
-- 32 counter outputs van 5 bits worden verdeeld over 4 8(5bit) naar 8 bit adders
GENADDER1_POS: for I in 0 to 5 generate
    ADDER8_5: adder_32_to_7 port map(counter_outputs_pos(I),counter_outputs_pos(I+1),counter_outputs_pos(I+2),
                                    counter_outputs_pos(I+3),counter_outputs_pos(I+4),counter_outputs_pos(I+5),
                                    counter_outputs_pos(I+6),counter_outputs_pos(I+7), adder1_outputs_pos(I));
    end generate;
    
GENADDER1_neg: for I in 0 to 5 generate
    ADDER8_5: adder_32_to_7 port map(counter_outputs_neg(I),counter_outputs_neg(I+1),counter_outputs_neg(I+2),
                                    counter_outputs_neg(I+3),counter_outputs_neg(I+4),counter_outputs_neg(I+5),
                                    counter_outputs_neg(I+6),counter_outputs_neg(I+7), adder1_outputs_neg(I));
    end generate;
    
temp1 <= "000" & counter_outputs_pos(48);
temp2 <= "000" & counter_outputs_neg(48);

-- last adder results in popcount which has no correction for bias or any other effects just the amount of bits. 
FINAL_ADDER_POS: seveneightadder port map(adder1_outputs_pos(0),adder1_outputs_pos(1),adder1_outputs_pos(2),adder1_outputs_pos(3),
                                        adder1_outputs_pos(4), adder1_outputs_pos(5), temp1, popcount_pos );   
        
                                 
FINAL_ADDER_NEG: seveneightadder port map(adder1_outputs_neg(0),adder1_outputs_neg(1),adder1_outputs_neg(2),adder1_outputs_neg(3),
                                        adder1_outputs_neg(4), adder1_outputs_neg(5),temp2 , popcount_neg );   
                                    

--final output to binary output. Threshold moet 254 zijn
FINAL_RESULT: threshold_bit port map(popcount_pos, popcount_neg, bias, node_value);

end Behavioral;
