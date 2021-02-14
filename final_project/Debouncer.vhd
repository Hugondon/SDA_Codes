LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Debouncer is
	PORT(
		CLOCK_50, KEY0, SW0 : IN STD_LOGIC;
		LEDG0 : OUT STD_LOGIC
		);
END Debouncer;
ARCHITECTURE beh of Debouncer  is
	type FSM is (IDLE, COUNTER, BTN_ON);
	signal current_state : FSM;	
begin
	process(CLOCK_50, current_state, KEY0, SW0)
	variable count: integer := 0;
	variable count_limit: integer := 1000000; --1,000,000 de flancos de subida para 50 Hz (contar 20ms)
		begin
			if(SW0 = '0') then --NRst
				current_state <= IDLE;
			else
				if(rising_edge(CLOCK_50)) then
					case current_state is
					when IDLE =>
						count := 0; --Iniciamos/reiniciamos contador 
						if(KEY0 = '1') then --Botón no presionado
							LEDG0 <= '0';
							current_state <= IDLE;
						else --Botón presionado, pasamos a siguiente estado
							LEDG0 <= '0';
							current_state <= COUNTER;
						end if;
					when COUNTER =>
							count := count + 1;
						if count <= count_limit then --Permanecemos en mismo estado
							LEDG0 <= '0';
							current_state <= current_state;
						elsif count > count_limit then --Pasados 20ms
							if (KEY0 = '1') then --Ya no está presionada, entonces fue rebote
								LEDG0 <= '0';
								current_state <= IDLE;
							elsif (KEY0 = '0') then --Sigue presionada, ya se armó
								LEDG0 <= '1';
								current_state <= BTN_ON;
							end if;
						end if;					
					when BTN_ON =>
						if(KEY0 = '1') then --Soltamos botón, salida se apaga y vuelve a empezar todo
							LEDG0 <= '0';
							current_state <= IDLE;
						elsif (KEY0 = '0') then  --Botón sigue presionado, no nos movemos, carnal
							LEDG0 <= '1';
							current_state <= BTN_ON;
					end if;
					when others => 
							current_state <= IDLE;
					end case;
				else
				 current_state <= current_state;
				end if;
			end if;
		end process;
end beh;
