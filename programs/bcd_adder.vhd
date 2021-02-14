library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity SBCD is
  Port ( a 	: in std_logic_vector(3 downto 0);
           b 	: in std_logic_vector(3 downto 0);
	         cin	: in std_logic;
           sbcd 	: out std_logic_vector(3 downto 0);
	         coutbcd	: out std_logic;
           coutbcdinutil : out std_logic);
end SBCD;
architecture Comportamiento_SBCD of SBCD is

	signal sbin : std_logic_vector (3 downto 0);
	signal sand : std_logic_vector (2 downto 0);
	signal coutbin : std_logic;
	signal c : std_logic_vector (5 downto 0):=(others=>'0');

	component fullAdder is
		Port ( a : in std_logic;
				b : in std_logic;
				cin : in std_logic;
				s : out std_logic;
				cout : out std_logic);
	end component;
	begin

		sbin0: fullAdder port map (a(0), b(0), cin, sbin(0), c(0));
		sbin1: fullAdder port map (a(1), b(1), c(0), sbin(1), c(1));
		sbin2: fullAdder port map (a(2), b(2), c(1), sbin(2), c(2));
		sbin3: fullAdder port map (a(3), b(3), c(2), sbin(3), coutbin);
		sand(0)<=sbin(3) and sbin(2);
		sand(1)<=sbin(3) and sbin(1);
		coutbcd<=sand(0) or sand (1) or coutbin;
		sbcd0: fullAdder port map (sbin(0), '0', '0', sbcd(0), c(3));
		sbcd1: fullAdder port map (sbin(1), coutbin, c(3), sbcd(1), c(4));
		sbcd2: fullAdder port map (sbin(2), coutbin, c(4), sbcd(2), c(5));
		sbcd3: fullAdder port map (sbin(3), '0', c(5), sbcd(3), coutbcdinutil);

end Comportamiento_SBCD;