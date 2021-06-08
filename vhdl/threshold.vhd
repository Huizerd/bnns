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

entity threshold is
  Port (popcount, threshold : in std_logic_vector(9 downto 0 );
        bias : in std_logic;
        cell_value : out std_logic);
end threshold;

architecture Behavioral of threshold is

signal and_outputs : std_logic_vector(9 downto 0);
signal or_outputs : std_logic_vector(8 downto 1);
begin

GEN_AND: for I in 0 to 9 generate
    and_outputs(I) <= popcount(I) and (not(threshold(I)));
end generate;

or_outputs(8) <= and_outputs(9) or and_outputs(8);

GEN_OR: for I in 1 to 7 generate
    or_outputs(I) <= and_outputs(I) or or_outputs(I+1);
end generate;
 
cell_value <=  or_outputs(1) or (and_outputs(0) and bias);

end Behavioral;
