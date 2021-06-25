----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/08/2021 02:58:00 PM
-- Design Name: 
-- Module Name: threshold_value - Behavioral
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


library IEEE;----------------------------------------------------------------------------------
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

entity finalvalueconverter is
  Port (popcount : in std_logic_vector(10 downto 0 );
        bias : in std_logic;
        cell_value : out std_logic_vector(10 downto 0));
end finalvalueconverter;

architecture Behavioral of finalvalueconverter is
component FA is
  Port (A : in std_logic;
    B : in std_logic;
    Cin : in std_logic;
    S : out std_logic;
    Cout : out std_logic);
end component;

signal carries, carries1  : std_logic_vector(11 downto 0);
signal offset :  std_logic_vector(10 downto 0);
signal biasadd,cell_value2,cell_value1 : std_logic_vector(10 downto 0);
begin

--Ripple carry all the way, bias as carry(0)
carries(0) <= '0';
carries1(0) <= '0';

process (bias)
begin
    case bias is 
        when '1' => biasadd <= "00000000001" ;          
        when others => biasadd <= "11111111111" ;
    end case;
end process;
-- -256 x2 dan bias

offset <= "11100000000";
GEN: for I in 0 to 10 generate
    FA_I: FA port map(popcount(I), offset(I) , carries1(I), cell_value1(I), carries1(I+1));
end generate;


cell_value2(10 downto 1) <= cell_value1(9 downto 0);
cell_value2(0) <= '0';

GEN2: for I in 0 to 10 generate
    FA_I: FA port map(cell_value2(I), biasadd(I), carries(I), cell_value(I), carries(I+1));
end generate;

--cell_value(11) <= carries(11);


end Behavioral;

