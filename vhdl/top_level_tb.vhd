library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.types_package.all;

entity top_level_tb is
end top_level_tb;

architecture behavioral of top_level_tb is

component top_level is
port(
    clk         : in std_logic;
    rst         : in std_logic;
    in_layer    : in std_logic_vector(783 downto 0);
    out_layer   : out out_type
    );
end component;

impure function input_image return std_logic_vector is
        file text_file : text open read_mode is "../export/base_version_7/in_image.txt";
        variable text_line : line;
        variable input : std_logic_vector(783 downto 0);
        variable good : boolean;
    begin
        readline(text_file, text_line);
        read(text_line, input, good);
        return input;
end function;

signal in_image : std_logic_vector(783 downto 0) := input_image;
signal in_layer : std_logic_vector(783 downto 0);
signal out_layer : out_type;
signal clk, rst : std_logic;

begin

lbl1: top_level
port map ( 
    	clk	  => clk,
    	rst	  => rst,
    	in_layer  => in_layer,
    	out_layer => out_layer

);


clk <= 	'1' after 25 ns when clk /='1' else
        	'0' after 25 ns;

rst <= 	'1' after 0 ns,
	'0' after 50 ns;

in_layer <= in_image;
out_layer <= out_layer;

end behavioral;
