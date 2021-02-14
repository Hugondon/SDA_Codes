library IEEE;
use ieee.std_logic_1164.all;

Entity full_adder is
Port(
	x,y,z: in std_logic;
	cout,sum: out std_logic
);
End full_adder;
Architecture estructural of full_adder is
	component half_adder
	port(
		A,B: in std_logic;
		SUM,CARRY: out std_logic
	);
	end component;
	signal s0,c0,c1: std_logic;
	Begin
	U0: half_adder port map(x,y,s0,c0);
	U1: half_adder port map (s0,z,SUM,c1);
	cout <= c0 or c1;
end estructural;