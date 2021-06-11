----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/07/2021 10:39:13 PM
-- Design Name: 
-- Module Name: threshold - Behavioral
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
use ieee.numeric_std.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity threshold_bit is
  Port (popcount, threshold : in std_logic_vector(10 downto 0 );
        bias : in std_logic;
        cell_value : out std_logic);
end threshold_bit;

architecture Behavioral of threshold_bit is

signal and_outputs : std_logic_vector(10 downto 0);
signal or_outputs : std_logic_vector(9 downto 2);
signal lastbitcheck :std_logic;
signal SEL : std_logic_vector(3 downto 0);
signal a,b,c,d, s1, s2, s3, s4, s5, s6, s7, s8 , a_and_b :std_logic;
begin

GEN_AND: for I in 0 to 10 generate
    and_outputs(I) <= popcount(I) and (not(threshold(I)));
end generate;

or_outputs(9) <= and_outputs(10) or and_outputs(9);

GEN_OR: for I in 2 to 8 generate
    or_outputs(I) <= and_outputs(I) or or_outputs(I+1);
end generate;
 
--Check larger than upto last 2 bits
-- or_outputs(2) resembles that
--reduce threshold by 1, now bias 1 is +2 and bias 0 is -0


--Always one for 

select_process : process (bias, popcount, threshold,or_outputs,lastbitcheck)
begin
    SEL(3) <= popcount(1);
    SEL(2)  <= popcount(0);
    SEL(1)  <= threshold(1); 
    SEL(0)  <= threshold(0);

    case SEL is 
        when "0000" => lastbitcheck <= bias;
        when "0001" => lastbitcheck <= bias;
        when "0101" => lastbitcheck <= bias;
        when "0110" => lastbitcheck <= bias;
        when "1010" => lastbitcheck <= bias;
        when "1011" => lastbitcheck <= bias;
        when "1111" => lastbitcheck <= bias;
        when "0100" => lastbitcheck <= '1';
        when "1001" => lastbitcheck <= '1';
        when "1110" => lastbitcheck <= '1';              
        when others => lastbitcheck <= '0';
    end case;
    
    cell_value <= or_outputs(2) or (lastbitcheck and not or_outputs(2));
end process;


end Behavioral;
