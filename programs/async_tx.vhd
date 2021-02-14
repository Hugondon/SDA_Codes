library ieee;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_1164.all;
USE IEEE.MATH_REAL.ALL;
use ieee.std_logic_arith.all;
USE IEEE.NUMERIC_STD.ALL;


Entity Trans_Asinc is
port(
	clk, enable, reset: in std_logic; -- enable activo en 1, reset activo en 0
	data_in: in std_logic_vector (7 downto 0);
	data_out: out std_logic
);
end Trans_Asinc;

Architecture behaviour of Trans_Asinc is
	----------------------------------------------------------------------------Decalracion de señales tipo estados
	type FSM is (s0, s1, s2, s3);
	signal estado: FSM;
	----------------------------------------------------------------------------Decalaracion de señales para maquina de estado
	signal data_in_1: std_logic_vector (7 downto 0);
	signal data_out_1: std_logic;
	----------------------------------------------------------------------------Declaracion de señal para divisor de frecuencia
	signal clk_div: std_logic;
	----------------------------------------------------------------------------
	begin
		data_in_1 <= not (data_in);
	---------------------------------------------------------------------------- Proceso de maquina de estado
		process(clk_div, enable, reset)
		variable cont_1: integer := 0;
		begin
			if (reset = '1') then
				cont_1 := 0;
				estado <= s0;
			else 
				if (rising_edge(clk_div)) then
					case estado is
						when s0 =>
							data_out_1 <= '1';
							if (enable = '1') then
								estado <= s1;
							else
								estado <= s0;
							end if;

						when s1 =>
							data_out_1 <= '0'; 
							estado <= s2;

						when s2 =>
							data_out_1 <= data_in_1 (cont_1);
							cont_1 := cont_1 + 1;
							if (cont_1 = 7) then
								estado <= s3;
								cont_1 := 0;
							else
								estado <= s2;
							end if;

						when s3 =>
							data_out_1 <= '1';
							estado <= s0;

						when others =>
							data_out_1<=data_out_1;
							estado<=estado;
						end case;
				else
					estado <= estado;
					data_out_1 <= data_out_1;
				end if;
			end if;
		end process;

		data_out <= data_out_1;
	-------------------------------------------------------------------------------- Proceso de divisor de frecuencia a 9600 bauds
		process(clk, reset)
		variable cont: integer := 0;
		begin
			if (reset = '1') then
				cont := 0;
				clk_div <= '0';
			else
				if rising_edge(clk) then
					cont := cont + 1;
					if cont = 2605 then
						cont := 0;
						clk_div <= not(clk_div);
					else
						clk_div <= clk_div;
					end if;
				else
					cont := cont;
				end if;
			end if;
		end process;
end behaviour;