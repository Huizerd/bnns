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

entity bmac_512 is
  Port (weights, previous : in std_logic_vector(511 downto 0);
        threshold : in std_logic_vector(10 downto 0);
        bias : in std_logic;
        node_value : out std_logic);
end bmac_512;

architecture Behavioral of bmac_512 is

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
    Cout : std_logic_vector (4 downto 0));
end component;

component threshold_bit is
  Port (popcount, threshold : in std_logic_vector(10 downto 0 );
        bias : in std_logic;
        cell_value : out std_logic);
end component;

type c_array is array (0 to 31) of std_logic_vector(4 downto 0);
type a1_array is array(0 to 3) of std_logic_vector(7 downto 0);
signal xor_outputs : std_logic_vector(511 downto 0);
signal counter_outputs : c_array;
signal adder1_outputs : a1_array;
signal popcount : std_logic_vector(11 downto 0);
begin

--XOR all input weights and previous bitwise
GENXOR: for I in 0 to 511 generate
    xor_outputs(I) <= weights(I) xor previous(I);
    end generate;
    
--  32 16 5 counters
GENCOUNTER: for I in 0 to 32 generate
    COUNTER_I: counter port map(xor_outputs(I*16-1 downto I*16), counter_outputs(I));
    end generate;
    
-- 32 counter outputs van 5 bits worden verdeeld over 4 8(5bit) naar 8 bit adders
GENADDER1: for I in 0 to 3 generate
    ADDER8_5: adder_32_to_7 port map(counter_outputs(I),counter_outputs(I+1),counter_outputs(I+2),
                                    counter_outputs(I+3),counter_outputs(I+4),counter_outputs(I+5),
                                    counter_outputs(I+6),counter_outputs(I+7), adder1_outputs(I));
    end generate;
    
-- last adder results in popcount which has no correction for bias or any other effects just the amount of bits. 
FINAL_ADDER: seveneightadder port map(adder1_outputs(0),adder1_outputs(1),adder1_outputs(2),adder1_outputs(3), "00000000", "00000000", "00000000", popcount );   

--final output to binary output.
FINAL_RESULT: threshold_bit port map(popcount, threshold, bias, node_value);

end Behavioral;
