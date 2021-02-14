library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity SR8B is
  Port ( a 	: in std_logic_vector(7 downto 0);
           b 	: in std_logic_vector(7 downto 0);
	       bs	: in std_logic;
           s 	: out std_logic_vector(7 downto 0);
	   cout	: out std_logic);
end SR4B;
architecture Comportamiento_SR8B of SR8B is

signal bxor : std_logic_vector (7 downto 0);
signal c : std_logic_vector (6 downto 0):=(others=>'0');

component fullAdder is
    Port ( a : in std_logic;
           b : in std_logic;
           cin : in std_logic;
           s : out std_logic;
           cout : out std_logic);
end component;
begin
bxor (0)<= b(0) xor bs;
bxor (1)<= b(1) xor bs;
bxor (2)<= b(2) xor bs;
bxor (3)<= b(3) xor bs;
bxor (4)<= b(4) xor bs;
bxor (5)<= b(5) xor bs;
bxor (6)<= b(6) xor bs;
bxor (7)<= b(7) xor bs;
sr0: fullAdder port map (a(0), bxor(0), bs, s(0), c(0));
sr1: fullAdder port map (a(1), bxor(1), c(0), s(1), c(1));
sr2: fullAdder port map (a(2), bxor(2), c(1), s(2), c(2));
sr3: fullAdder port map (a(3), bxor(3), c(2), s(3), c(3));
sr4: fullAdder port map (a(4), bxor(4), c(3), s(4), c(4));
sr5: fullAdder port map (a(5), bxor(5), c(4), s(5), c(5));
sr6: fullAdder port map (a(6), bxor(6), c(5), s(6), c(6));
sr7: fullAdder port map (a(7), bxor(7), c(6), s(7), cout);

end Comportamiento_SR8B;