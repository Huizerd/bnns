----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/07/2021 04:17:27 PM
-- Design Name: 
-- Module Name: full_adder - Behavioral
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

entity full_adder is
  Port (a,b,carry_in : in std_logic; 
        sum, carry_out : out std_logic);
end full_adder;

architecture Behavioral of full_adder is
signal s1, s2, s3, s4 : std_logic;
begin

s1 <= a xor b; 
sum <= s1 xor carry_in; 
s2 <= s1 and carry_in; 
s3 <= a and b; 
carry_out <= s2 or s3;


end Behavioral;
