library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity LCD is
	port (clk: in std_logic;
			lcd_data: out std_logic_vector (7 downto 0);
			lcd_rs, lcd_rw, lcd_en, lcd_on, lcd_blon: out std_logic
	);
end LCD;
architecture behav of LCD is
	type tipo_estados is (s0, s1, s2, s3, s4, s5, s6, s7, s8);
	signal estado: tipo_estados;
	signal clkdiv: std_logic;
	begin
		lcd_on<='1';
		lcd_blon<='1';
		
		--proceso para divisor de frecuencias
		
		process(clk)
			--variable va antes del begin, despues del process
				variable cont: integer:=0;
				begin
				if rising_edge (clk) then
					cont:= cont+1;
					if cont=50000 then --para 2ms, la formula dice que son 100k, pero eso es lo que tarda en hacer un solo cambio, y como se desea falnco de subida y de bajada en 100k, se asigna la mitad entre cada cambio y como cada instruccion toma dos estados, se reduce otra vez a la mitad, para poder programar 2ms
						cont:=0;
						clkdiv <= not(clkdiv);
					else
						clkdiv <= clkdiv;
					end if;
				else
					cont:= cont;
				end if;
		end process;
		
		--proceso para maquina de estados
		
		process(clkdiv)
			begin
			if rising_edge(clkdiv) then
				case estado is
					when s0=>
						lcd_en <= '1';
						lcd_rs <= '0';
						lcd_rw <= '0';
						lcd_data <= "00111000";
						estado<= s1;
					when s1=>
						lcd_en <= '0';
						lcd_rs <= '0';
						lcd_rw <= '0';
						lcd_data <= "00111000";
						estado<= s2;
					when s2=>
						lcd_en <= '1';
						lcd_rs <= '0';
						lcd_rw <= '0';
						lcd_data <= "00001111";
					estado<= s3;
					when s3=>
						lcd_en <= '0';
						lcd_rs <= '0';
						lcd_rw <= '0';
						lcd_data <= "00001111";
					estado<= s4;
					when s4=>
						lcd_en <= '1';
						lcd_rs <= '0';
						lcd_rw <= '0';
						lcd_data <= "00000001";
					estado<= s5;
					when s5=>
						lcd_en <= '0';
						lcd_rs <= '0';
						lcd_rw <= '0';
						lcd_data <= "00000001";
					estado<= s6;
					when s6=>
						lcd_en <= '1';
						lcd_rs <= '1';
						lcd_rw <= '0';
						lcd_data <= "01001000";
					estado<= s7;
					when s7=>
						lcd_en <= '0';
						lcd_rs <= '1';
						lcd_rw <= '0';
						lcd_data <= "01001000";
					estado<= s8;
					when s8=>
						estado<= estado;
				end case;
			else
				estado<=estado;
			end if;
		end process;
end behav;