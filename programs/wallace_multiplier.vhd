library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity Multiplicador is
  Port (a 	: in std_logic_vector(3 downto 0);
           b 	: in std_logic_vector(3 downto 0);
           p 	: out std_logic_vector(7 downto 0)
			  );
end Multiplicador;
architecture Comportamiento_Mult of Multiplicador is

	signal s : std_logic_vector (7 downto 0);
	signal c : std_logic_vector (9 downto 0);
	signal q : std_logic_vector (4 downto 0);
	signal m : std_logic_vector (15 downto 0);

	component fullAdder is
		Port ( a : in std_logic;
				b : in std_logic;
				cin : in std_logic;
				s : out std_logic;
				cout : out std_logic);
	end component;

	component halfadd is
		Port ( a : in std_logic;
				b : in std_logic;
				s : out std_logic;
				cout : out std_logic);
	end component; 

	begin

		m (0)<= a(0) and b(0);
		m (1)<= a(1) and b(0);
		m (2)<= a(2) and b(0);
		m (3)<= a(3) and b(0);
		m (4)<= a(0) and b(1);
		m (5)<= a(1) and b(1);
		m (6)<= a(2) and b(1);
		m (7)<= a(3) and b(1);
		m (8)<= a(0) and b(2);
		m (9)<= a(1) and b(2);
		m (10)<= a(2) and b(2);
		m (11)<= a(3) and b(2);
		m (12)<= a(0) and b(3);
		m (13)<= a(1) and b(3);
		m (14)<= a(2) and b(3);
		m (15)<= a(3) and b(3);

		p(0)<= m(0);

		ha0: halfadd port map (m(1), m(4), p(1), c(0));
		fa0: fullAdder port map (m(2), m(5), m(8), s(0), c(1));
		fa1: fullAdder port map (m(6), m(9), m(12), s(1), c(2));
		fa2: fullAdder port map (m(7), m(10), m(13), s(2), c(3));
		ha1: halfadd port map (m(11), m(14), s(3), c(4));
		ha2: halfadd port map (c(0), s(0), p(2), c(5));
		ha3: halfadd port map (c(1), s(1), s(4), c(6));
		fa3: fullAdder port map (c(2), s(2), m(3), s(5), c(7));
		ha4: halfadd port map (c(3), s(3), s(6), c(8));
		ha5: halfadd port map (c(4), m(15), s(7), c(9));
		ha6: halfadd port map (c(5), s(4), p(3), q(0));
		fa4: fullAdder port map (c(6), s(5), q(0), p(4), q(1));
		fa5: fullAdder port map (c(7), s(6), q(1), p(5), q(2));
		fa6: fullAdder port map (c(8), s(7), q(2), p(6), q(3));
		ha7: halfadd port map (c(9), q(3), p(7), q(4));

end Comportamiento_Mult;