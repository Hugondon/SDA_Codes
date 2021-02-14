library IEEE;
use ieee.std_logic_1164.all;

Entity mi74LS151 is 
	port( Selector: in std_logic_vector (2 downto 0);
			Input: in std_logic_vector (7 downto 0);
			Enable : in std_logic;
			Y,Z: out std_logic
	);
	end mi74LS151;
Architecture struct of mi74LS151 is 
signal X: std_logic;
begin 
	X<= Input(0) when (Enable ='0') and (Selector= "000") else 
		 Input(1) when (Enable ='0') and (Selector= "001") else 
		 Input(2) when (Enable ='0') and (Selector= "010") else 
		 Input(3) when (Enable ='0') and (Selector= "011") else 
		 Input(4) when (Enable ='0') and (Selector= "100") else 
		 Input(5) when (Enable ='0') and (Selector= "101") else 
		 Input(6) when (Enable ='0') and (Selector= "110") else 
		 Input(7) when (Enable ='0') and (Selector= "111") else 
		 '0';
	Y<=X;
	Z<= not X;
	end struct;