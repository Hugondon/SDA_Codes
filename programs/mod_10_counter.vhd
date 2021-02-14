library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity contador_mod_10 is
port (
	clkbot, reset, load: in std_logic;
	data: in std_logic_vector (3 downto 0);
	counter: out std_logic_vector (3 downto 0)
	);
end contador_mod_10;
architecture Contador of contador_mod_10 is
 signal contsig: std_logic_vector (3 downto 0):="0000";
 begin 
	process (load, reset, clkbot)
	begin
		if (reset='1') or (contsig="1001") then
			contsig<=(others=>'0');
		elsif load='1' then
			contsig<=data;
		elsif clkbot='1' then
			contsig<=contsig+1;
		end if;
	end process;
	counter<=contsig;
end Contador;