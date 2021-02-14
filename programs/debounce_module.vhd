LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.MATH_REAL.ALL;
use ieee.std_logic_unsigned.all;

entity Deb_Mod is 
	port(
			clk,reset, btn_in: in std_logic;
			btn_out: out std_logic
	);
end Deb_Mod;

architecture behav of Deb_Mod is
	type FSM is (s0, s1, s2, s3);
	signal estado_act, estado_sig: FSM;
	signal clk_div: std_logic;
	signal cunt:std_logic_vector (3 downto 0):="0000";
	---Importacion del componente contador
	component Contador
		port(
			clk,reset: in std_logic;
			contt: out std_logic_vector (3 downto 0)
		);
	end component;
	---Importacion del componente divisor de frecuencia
	component Div_frec
		port(
			clk: in std_logic;
			clk_div: out std_logic
		);
	end component;
	begin
		---Utilizacion del componente contador
		Cont1: Contador port map (clk_div, reset, cunt);
			-- Utilizacion del divisor de frecuencia a medio segundo
		Div1: Div_frec port map (clk, clk_div);
			-- Reset y definicion de comportamiento de estados
			process (clk_div,reset)
			begin
				if reset='1' then
					estado_act<=s0;
				elsif rising_edge(clk_div)then
					estado_act<=estado_sig;
				else 
					estado_act<=estado_act;
				end if;
			end process;
			--Maquina de estados
			process (clk_div,cunt, btn_in)
			begin
				case (estado_act) is 
					when s0=>
							btn_out<='0';
							if btn_in='1' then --Porque el boton es activo en '1'--
								estado_sig<=s1;
							else
								estado_sig<=s0;	
							end if;
					when s1=>
							if ((cunt="1010") and (btn_in='1')) then
								estado_sig<=s2;
							else
								estado_sig<=s0;
							end if;
					when s2=>
							btn_out<='1';
							if btn_in='0' then --Porque el boton no es activo en '0'--
								estado_sig<=s3;
							else
								estado_sig<=s2;
							end if;
					when s3=>
							if ((cunt="1010") and (btn_in='0')) then
								estado_sig<=s0;
							else
								estado_sig<=s2;
							end if;
					when others => 
							estado_sig<=estado_sig;
				end case;				
			end process;
end behav;