library IEEE;
use ieee.std_logic_1164.all;

Entity mi74LS138 is
	Port( A,B,C : in std_logic;
			Selector: in std_logic_vector (2 downto 0);
			Y : out std_logic_vector (7 downto 0)
	);
	End mi74LS138;
	architecture tarea74ls138con of mi74LS138 is
	signal enables : std_logic_vector(2 downto 0);
	begin
	enables (0)<= C;
	enables (1)<= B;
	enables (2)<= A;
	Y<="11111110" when (Selector = "001") and (enables="000") else
	"11111101" when (Selector = "001") and (enables="001") else
	"11111011" when (Selector = "001") and (enables="010") else
	"11110111" when (Selector = "001") and (enables="011") else
	"11101111" when (Selector = "001") and (enables="100") else
	"11011111" when (Selector = "001") and (enables="101") else
	"10111111" when (Selector = "001") and (enables="110") else
	"01111111" when (Selector = "001") and (enables="111") else
	"11111111";		
end tarea74ls138con;