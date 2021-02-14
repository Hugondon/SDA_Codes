library IEEE;
use ieee.std_logic_1164.all;

Entity deco7segmentos is
	port(
		i1,i2,i3,i4: in std_logic;
		o1,o2,o3,o4,o5,o6,o7: out std_logic
);
End deco7segmentos;

Architecture behaviour of deco7segmentos is
		signal s : std_logic_vector (6 downto 0);
		signal e : std_logic_vector (3 downto 0);
		begin
		e(0) <= i1;
		e(1) <= i2;
		e(2) <= i3;
		e(3) <= i4;
		
		with E select                   	
      s <= 	"0000001" when "0000",
						"0011111" when "0001",
						"0010010" when "0010",
						"0000110" when "0011",
						"1001100" when "0100",
						"0100100" when "0101",
						"0100000" when "0110",
						"0001111" when "0111",
						"0000000" when "1000",
						"0000100" when "1001",
						"1111111" when others;				
		
		o1 <= s(0);
		o2 <= s(1);
		o3 <= s(2);
		o4 <= s(3);
		o5 <= s(4);
		o6 <= s(5);
		o7 <= s(6);
End behaviour;