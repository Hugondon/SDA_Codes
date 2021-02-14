LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;


Entity Pong_PelotaAuto is
	Port(
		CLOCK_50 : IN STD_LOGIC; --Reloj de entrada
		KEY : IN STD_LOGIC_VECTOR(3 DOWNTO 0); --Línea horizontal KEY3, KEY2 - Línea vertical KEY1, KEY0
		SW : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
		LEDG : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		VGA_R,VGA_G,VGA_B : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N : OUT STD_LOGIC
	);
end Pong_PelotaAuto;

architecture beh of Pong_PelotaAuto is

signal BI_Abajo, BI_Arriba, BD_Abajo, BD_Arriba : STD_LOGIC; --Botones para movimiento de líneas
signal clk_div, clk_div2, HS_signal, VS_signal, HDisp, VDisp: STD_LOGIC;
signal RED, GR, BL: std_logic_vector(7 downto 0);
signal CoordenadaxCPelota, CoordenadayCPelota, ContadorBI, ContadorBD : integer;
signal LimDerBall, LimIzqBall, LimSupBall, LimInfBall : integer;
signal LimIzqBarrI, LimDerBarrI, LimSupBarrI, LimInfBarrI : integer;
signal LimIzqBarrD, LimDerBarrD, LimSupBarrD, LimInfBarrD : integer;
signal marcadorp1, marcadorp2 : integer;

type FSM is (Movimiento, ReboteArriba, ReboteAbajo, ReboteIzquierda, ReboteDerecha, ScoreP1, ScoreP2);
signal estado_pelota : FSM;

COMPONENT Debouncer is
	PORT(
		CLOCK_50, KEY0, SW0 : IN STD_LOGIC;
		LEDG0 : OUT STD_LOGIC
		);
END Component;
COMPONENT DIV_Pong is
	PORT(
	CLOCK_50: IN STD_LOGIC;
	clk_out: OUT STD_LOGIC
	);	
END COMPONENT;
begin

	VGA_BLANK_N <= '1';
	VGA_SYNC_N 	<= '0';
	
 --Se necesita divisor de 25MHz --
	process(clk_div) 
		begin
			if rising_edge(CLOCK_50) then
				clk_div <= not(clk_div);
			else
				clk_div <= clk_div;
			end if;
	end process;
 --Se necesita divisor de 25MHz --
 
 
 	U0 : Debouncer port map(clk_div, KEY(0), '1', BD_Arriba); 
	U1 : Debouncer port map(clk_div, KEY(1), '1', BD_Abajo);
	U2 : Debouncer port map(clk_div, KEY(2), '1', BI_Arriba); 
	U3 : Debouncer port map(clk_div, KEY(3), '1', BI_Abajo);	
	U4 : DIV_Pong	port map(CLOCK_50, clk_div2);
 
 
	process(clk_div, HDisp, VDisp)
	
		variable contHS : integer := 0; --contador de pixeles
		variable contVS : integer := 0; --contador de líneas
		
		begin
		
		LimDerBall <= CoordenadaxCPelota + 6;
		LimIzqBall  <= CoordenadaxCPelota - 6;
		LimSupBall  <= CoordenadayCPelota + 6;
		LimInfBall  <= CoordenadayCPelota - 6;
		
		LimIzqBarrI <=  157;
		LimDerBarrI <=  171;
		LimSupBarrI <=  contadorBI +  40;
		LimInfBarrI <=  contadorBI -  40;
		
		LimIzqBarrD <=  755;
		LimDerBarrD <=  769;
		LimSupBarrD <=  contadorBD +  40;
		LimInfBarrD <=  contadorBD -  40;
		
			if rising_edge(clk_div) then
			--Análisis horizontal --
				if (contHS <= 95) then -- TPW 0-95
					HS_signal <= '0'; --No es necesario el HSync
					HDisp <= '0';	--No es zona para poner color
					contHS := contHS + 1; --Sigue contando					
				elsif (contHS <= 143) then --Back porch 96-143
					HS_signal <= '1'; --HSync
					HDisp <= '0'; --No es zona para poner color
					contHS := contHS + 1; --Sigue contando					
				elsif (contHS <= 783) then --Horizontal display time 144-783
					HS_signal <= '1'; --HSync
					HDisp <= '1'; -- Ya es zona para poner color
					contHS := contHS + 1; --Sigue contando					
				elsif (contHS <= 799) then --Front porch 784-799
					HS_signal <= '1'; --HSync
					HDisp <= '0'; --No es zona para poner color
					contHS := contHS + 1;
				else--Ya terminó la línea, contHS contó 800 veces ya
					contHS := 0;
					contVS := contVS + 1;					
				end if;
				--Análisis vertical--
				if (contVS <= 1) then -- TPW 0-1
					VS_signal <= '0';
					VDisp <= '0'; --No es zona para poner color				
				elsif (contVS <= 30) then -- Back Porch 2-30
					VS_signal <= '1';
					VDisp <= '0'; --No es zona para poner color
				elsif (contVS <= 510) then -- Vertical Display time 31-510
					VS_signal <= '1';
					VDisp <= '1'; -- Ya es zona para poner color					
				elsif (contVS <= 520) then -- Front Porch 511-520
					VS_signal <= '1';
					VDisp <= '0';	--No es zona para poner color					
				else --Se terminó pantalla, contVS contó 521 veces ya
					contVs := 0;
				end if;
				else
				contHs := contHs;
			end if;
			
			
			
	--Se puede pintar de 32 a 509 en contVS y 152 a 774 en ContHS
	
			if (HDisp = '1' AND VDisp = '1') then
				

				--Para pelota--
				if( (contHS > LimIzqBall AND contHS < LimDerBall) AND (contVS > LimInfBall AND contVS < LimSupBall)) then
					RED<=	"11111111"; 
					GR	<=	"11111111"; 
					BL	<=	"11111111";		
				else
					RED<=	"00000000"; 
					GR	<=	"00000000"; 
					BL	<=	"00000000";
				end if;
				--Para pelota--
				
				--Para Barra BI_Abajo--
				if( (contHS > LimIzqBarrI AND contHS < LimDerBarrI) AND (contVS > LimInfBarrI AND contVS < LimSupBarrI)) then
					
					RED<=	"11111111"; 
					GR	<=	"11111111"; 
					BL	<=	"11111111";
				end if;
				--Para Barra BI_Abajo--
				
				--Para Barra BI_Arriba--
				if( (contHS > LimIzqBarrD AND contHS < LimDerBarrD) AND (contVS > LimInfBarrD AND contVS < LimSupBarrD)) then
					
					RED<=	"11111111"; 
					GR	<=	"11111111"; 
					BL	<=	"11111111";
				end if;
				--Para Barra BI_Arriba--
				
				--BORDES DE ANOTACIÓN--
				if contHS = 157 then
					RED<=	"11111111"; 
					GR	<=	"11111111"; 
					BL	<=	"11111111";
				end if;
				if contHS = 769 then
					RED<=	"11111111"; 
					GR	<=	"11111111"; 
					BL	<=	"11111111";
				end if;
				--BORDES DE ANOTACIÓN--
				
				--Línea de en medio--
				if( contHS = 464 AND contVS mod 20 < 10 ) then
					RED<=	"11111111"; 
					GR	<=	"11111111"; 
					BL	<=	"11111111";
				end if;
				--Linea de en medio--

				--Marcador--
				
				case (marcadorp1) is
	when 0 =>
		if ((contHS > 301 AND contHS < 361) AND (contVS > 70 AND contVS < 82)) then 
			RED	<=	"11111111"; 
			GR	<=	"11111111"; 
			BL	<=	"11111111";
		elsif ((contHS > 301 AND contHS < 321) AND (contVS > 82 AND contVS < 94)) then
			RED	<=	"11111111"; 
			GR	<=	"11111111"; 
			BL	<=	"11111111";
		elsif ((contHS > 341 AND contHS < 361) AND (contVS > 82 AND contVS < 94)) then
			RED	<=	"11111111"; 
			GR	<=	"11111111"; 
			BL	<=	"11111111";
		elsif ((contHS > 301 AND contHS < 321) AND (contVS > 94 AND contVS < 106)) then
			RED	<=	"11111111"; 
			GR	<=	"11111111"; 
			BL	<=	"11111111";
		elsif ((contHS > 341 AND contHS < 361) AND (contVS > 94 AND contVS < 106)) then
			RED	<=	"11111111"; 
			GR	<=	"11111111"; 
			BL	<=	"11111111";
		elsif ((contHS > 301 AND contHS < 321) AND (contVS > 106 AND contVS < 118)) then
			RED	<=	"11111111"; 
			GR	<=	"11111111"; 
			BL	<=	"11111111";
		elsif ((contHS > 341 AND contHS < 361) AND (contVS > 106 AND contVS < 118)) then
			RED	<=	"11111111"; 
			GR	<=	"11111111"; 
			BL	<=	"11111111";
		elsif ((contHS > 301 AND contHS < 361) AND (contVS > 118 AND contVS < 130)) then 
			RED	<=	"11111111"; 
			GR	<=	"11111111"; 
			BL	<=	"11111111";
		end if;
	when 1 => 
		if ((contHS > 321 AND contHS < 341) AND (contVS > 70 AND contVS < 130)) then 
			RED	<=	"11111111"; 
			GR	<=	"11111111"; 
			BL	<=	"11111111";
		end if;
	when 2 =>
		if ((contHS > 301 AND contHS < 361) AND (contVS > 70 AND contVS < 82)) then 
			RED	<=	"11111111"; 
			GR	<=	"11111111"; 
			BL	<=	"11111111";
		elsif ((contHS > 341 AND contHS < 361) AND (contVS > 82 AND contVS < 94)) then
			RED	<=	"11111111"; 
			GR	<=	"11111111"; 
			BL	<=	"11111111";
		elsif ((contHS > 301 AND contHS < 361) AND (contVS > 94 AND contVS < 106)) then
			RED	<=	"11111111"; 
			GR	<=	"11111111"; 
			BL	<=	"11111111";
		elsif ((contHS > 301 AND contHS < 321) AND (contVS > 106 AND contVS < 118)) then
			RED	<=	"11111111"; 
			GR	<=	"11111111"; 
			BL	<=	"11111111";
		elsif ((contHS > 301 AND contHS < 361) AND (contVS > 118 AND contVS < 130)) then 
			RED	<=	"11111111"; 
			GR	<=	"11111111"; 
			BL	<=	"11111111";
		end if;
	when 3 =>
			if ((contHS > 301 AND contHS < 361) AND (contVS > 70 AND contVS < 82)) then 
			RED	<=	"11111111"; 
			GR	<=	"11111111"; 
			BL	<=	"11111111";
			elsif ((contHS > 341 AND contHS < 361) AND (contVS > 82 AND contVS < 94)) then
			RED	<=	"11111111"; 
			GR	<=	"11111111"; 
			BL	<=	"11111111";
			elsif ((contHS > 321 AND contHS < 361) AND (contVS > 94 AND contVS < 106)) then
			RED	<=	"11111111"; 
			GR	<=	"11111111"; 
			BL	<=	"11111111";
			elsif ((contHS > 341 AND contHS < 361) AND (contVS > 106 AND contVS < 118)) then
			RED	<=	"11111111"; 
			GR	<=	"11111111"; 
			BL	<=	"11111111";
			elsif ((contHS > 301 AND contHS < 361) AND (contVS > 118 AND contVS < 130)) then 
			RED	<=	"11111111"; 
			GR	<=	"11111111"; 
			BL	<=	"11111111";
	end if;
	when 4 =>
		if ((contHS > 301 AND contHS < 321) AND (contVS > 70 AND contVS < 82)) then 
			RED	<=	"11111111"; 
			GR	<=	"11111111"; 
			BL	<=	"11111111";
		elsif ((contHS > 341 AND contHS < 361) AND (contVS > 70 AND contVS < 82)) then 
			RED	<=	"11111111"; 
			GR	<=	"11111111"; 
			BL	<=	"11111111";
		elsif ((contHS > 301 AND contHS < 321) AND (contVS > 82 AND contVS < 94)) then 
			RED	<=	"11111111"; 
			GR	<=	"11111111"; 
			BL	<=	"11111111";
		elsif ((contHS > 341 AND contHS < 361) AND (contVS > 82 AND contVS < 94)) then 
			RED	<=	"11111111"; 
			GR	<=	"11111111"; 
			BL	<=	"11111111";
		elsif ((contHS > 301 AND contHS < 361) AND (contVS > 94 AND contVS < 106)) then 
			RED	<=	"11111111"; 
			GR	<=	"11111111"; 
			BL	<=	"11111111";
		elsif ((contHS > 341 AND contHS < 361) AND (contVS > 106 AND contVS < 118)) then
			RED	<=	"11111111"; 
			GR	<=	"11111111"; 
			BL	<=	"11111111";
		elsif ((contHS > 341 AND contHS < 361) AND (contVS > 106 AND contVS < 130)) then
			RED	<=	"11111111"; 
			GR	<=	"11111111"; 
			BL	<=	"11111111";
		end if;
	when 5 =>
		if ((contHS > 301 AND contHS < 361) AND (contVS > 70 AND contVS < 82)) then 
			RED	<=	"11111111"; 
			GR	<=	"11111111"; 
			BL	<=	"11111111";
		elsif ((contHS > 301 AND contHS < 321) AND (contVS > 82 AND contVS < 94)) then
			RED	<=	"11111111"; 
			GR	<=	"11111111"; 
			BL	<=	"11111111";
		elsif ((contHS > 301 AND contHS < 361) AND (contVS > 94 AND contVS < 106)) then
			RED	<=	"11111111"; 
			GR	<=	"11111111"; 
			BL	<=	"11111111";
		elsif ((contHS > 341 AND contHS < 361) AND (contVS > 106 AND contVS < 118)) then
			RED	<=	"11111111"; 
			GR	<=	"11111111"; 
			BL	<=	"11111111";
		elsif ((contHS > 301 AND contHS < 361) AND (contVS > 118 AND contVS < 130)) then 
			RED	<=	"11111111"; 
			GR	<=	"11111111"; 
			BL	<=	"11111111";
		end if;
	when others =>
		null;
				end case;
				case (marcadorp2) is
	when 0 =>
		if ((contHS > 567 AND contHS < 627) AND (contVS > 70 AND contVS < 82)) then 
			RED	<=	"11111111"; 
			GR	<=	"11111111"; 
			BL	<=	"11111111";
		elsif ((contHS > 567 AND contHS < 587) AND (contVS > 82 AND contVS < 94)) then
			RED	<=	"11111111"; 
			GR	<=	"11111111"; 
			BL	<=	"11111111";
		elsif ((contHS > 607 AND contHS < 627) AND (contVS > 82 AND contVS < 94)) then
			RED	<=	"11111111"; 
			GR	<=	"11111111"; 
			BL	<=	"11111111";
		elsif ((contHS > 567 AND contHS < 587) AND (contVS > 94 AND contVS < 106)) then
			RED	<=	"11111111"; 
			GR	<=	"11111111"; 
			BL	<=	"11111111";
		elsif ((contHS > 607 AND contHS < 627) AND (contVS > 94 AND contVS < 106)) then
			RED	<=	"11111111"; 
			GR	<=	"11111111"; 
			BL	<=	"11111111";
		elsif ((contHS > 567 AND contHS < 587) AND (contVS > 106 AND contVS < 118)) then
			RED	<=	"11111111"; 
			GR	<=	"11111111"; 
			BL	<=	"11111111";
		elsif ((contHS > 607 AND contHS < 627) AND (contVS > 106 AND contVS < 118)) then
			RED	<=	"11111111"; 
			GR	<=	"11111111"; 
			BL	<=	"11111111";
		elsif ((contHS > 567 AND contHS < 627) AND (contVS > 118 AND contVS < 130)) then 
			RED	<=	"11111111"; 
			GR	<=	"11111111"; 
			BL	<=	"11111111";
	
		end if;
	when 1 => 
		if ((contHS > 587 AND contHS < 607) AND (contVS > 70 AND contVS < 130)) then 
			RED	<=	"11111111"; 
			GR	<=	"11111111"; 
			BL	<=	"11111111";
		
		end if;
	when 2 =>
		if ((contHS > 567 AND contHS < 627) AND (contVS > 70 AND contVS < 82)) then 
			RED	<=	"11111111"; 
			GR	<=	"11111111"; 
			BL	<=	"11111111";
		elsif ((contHS > 607 AND contHS < 627) AND (contVS > 82 AND contVS < 94)) then
			RED	<=	"11111111"; 
			GR	<=	"11111111"; 
			BL	<=	"11111111";
		elsif ((contHS > 567 AND contHS < 627) AND (contVS > 94 AND contVS < 106)) then
			RED	<=	"11111111"; 
			GR	<=	"11111111"; 
			BL	<=	"11111111";
		elsif ((contHS > 567 AND contHS < 587) AND (contVS > 106 AND contVS < 118)) then
			RED	<=	"11111111"; 
			GR	<=	"11111111"; 
			BL	<=	"11111111";
		elsif ((contHS > 567 AND contHS < 627) AND (contVS > 118 AND contVS < 130)) then 
			RED	<=	"11111111"; 
			GR	<=	"11111111"; 
			BL	<=	"11111111";
		end if;
	when 3 =>
			if ((contHS > 567 AND contHS < 627) AND (contVS > 70 AND contVS < 82)) then 
			RED	<=	"11111111"; 
			GR	<=	"11111111"; 
			BL	<=	"11111111";
			elsif ((contHS > 607 AND contHS < 627) AND (contVS > 82 AND contVS < 94)) then
			RED	<=	"11111111"; 
			GR	<=	"11111111"; 
			BL	<=	"11111111";
			elsif ((contHS > 587 AND contHS < 627) AND (contVS > 94 AND contVS < 106)) then
			RED	<=	"11111111"; 
			GR	<=	"11111111"; 
			BL	<=	"11111111";
			elsif ((contHS > 607 AND contHS < 627) AND (contVS > 106 AND contVS < 118)) then
			RED	<=	"11111111"; 
			GR	<=	"11111111"; 
			BL	<=	"11111111";
			elsif ((contHS > 567 AND contHS < 627) AND (contVS > 118 AND contVS < 130)) then 
			RED	<=	"11111111"; 
			GR	<=	"11111111"; 
			BL	<=	"11111111";	
	end if;
	when 4 =>
		if ((contHS > 567 AND contHS < 587) AND (contVS > 70 AND contVS < 82)) then 
			RED	<=	"11111111"; 
			GR	<=	"11111111"; 
			BL	<=	"11111111";
		elsif ((contHS > 607 AND contHS < 627) AND (contVS > 70 AND contVS < 82)) then 
			RED	<=	"11111111"; 
			GR	<=	"11111111"; 
			BL	<=	"11111111";
		elsif ((contHS > 567 AND contHS < 587) AND (contVS >82 AND contVS < 94)) then 
			RED	<=	"11111111"; 
			GR	<=	"11111111"; 
			BL	<=	"11111111";
		elsif ((contHS > 607 AND contHS < 627) AND (contVS >82 AND contVS < 94)) then 
			RED	<=	"11111111"; 
			GR	<=	"11111111"; 
			BL	<=	"11111111";
		elsif ((contHS > 567 AND contHS < 627) AND (contVS > 94 AND contVS < 106)) then 
			RED	<=	"11111111"; 
			GR	<=	"11111111"; 
			BL	<=	"11111111";
		elsif ((contHS > 607 AND contHS < 627) AND (contVS > 106 AND contVS < 118)) then
			RED	<=	"11111111"; 
			GR	<=	"11111111"; 
			BL	<=	"11111111";
		elsif ((contHS > 607 AND contHS < 627) AND (contVS > 106 AND contVS < 130)) then
			RED	<=	"11111111"; 
			GR	<=	"11111111"; 
			BL	<=	"11111111";

		end if;
	when 5 =>
		if ((contHS > 567 AND contHS < 627) AND (contVS > 70 AND contVS < 82)) then 
			RED	<=	"11111111"; 
			GR	<=	"11111111"; 
			BL	<=	"11111111";
		elsif ((contHS > 567 AND contHS < 587) AND (contVS > 82 AND contVS < 94)) then
			RED	<=	"11111111"; 
			GR	<=	"11111111"; 
			BL	<=	"11111111";
		elsif ((contHS > 567 AND contHS < 627) AND (contVS > 94 AND contVS < 106)) then
			RED	<=	"11111111"; 
			GR	<=	"11111111"; 
			BL	<=	"11111111";
		elsif ((contHS > 607 AND contHS < 627) AND (contVS > 106 AND contVS < 118)) then
			RED	<=	"11111111"; 
			GR	<=	"11111111"; 
			BL	<=	"11111111";
		elsif ((contHS > 567 AND contHS < 627) AND (contVS > 118 AND contVS < 130)) then 
			RED	<=	"11111111"; 
			GR	<=	"11111111"; 
			BL	<=	"11111111";
		end if;

			when others =>
			null;
	end case;
				
				-- Marcador--
				
				if(marcadorp1 = 5) then
				if ((contHS > 301 AND contHS < 361) AND (contVS > 300 AND contVS < 312)) then 
			RED	<=	"11111111"; 
			GR	<=	"00000000"; 
			BL	<=	"00000000";
elsif ((contHS > 301 AND contHS < 313) AND (contVS > 312 AND contVS < 324)) then 
			RED	<=	"11111111"; 
			GR	<=	"00000000"; 
			BL	<=	"00000000";
elsif ((contHS > 349 AND contHS < 361) AND (contVS > 312 AND contVS < 324)) then 
			RED	<=	"11111111"; 
			GR	<=	"00000000"; 
			BL	<=	"00000000";
elsif ((contHS > 301 AND contHS < 361) AND (contVS > 324 AND contVS < 336)) then 
			RED	<=	"11111111"; 
			GR	<=	"00000000"; 
			BL	<=	"00000000";
elsif ((contHS > 301 AND contHS < 313) AND (contVS > 336 AND contVS < 348)) then 
			RED	<=	"11111111"; 
			GR	<=	"00000000"; 
			BL	<=	"00000000";
elsif ((contHS > 301 AND contHS < 313) AND (contVS > 348 AND contVS < 360)) then 
			RED	<=	"11111111"; 
			GR	<=	"00000000"; 
			BL	<=	"00000000";
end if;

if ((contHS > 366 AND contHS < 387) AND (contVS > 300 AND contVS < 360)) then 
			RED	<=	"11111111"; 
			GR	<=	"00000000"; 
			BL	<=	"00000000";
		end if;

if ((contHS > 527 AND contHS < 539) AND (contVS > 300 AND contVS < 312)) then 
			RED	<=	"11111111"; 
			GR	<=	"00000000"; 
			BL	<=	"00000000";
elsif ((contHS > 575 AND contHS < 587) AND (contVS > 300 AND contVS < 312)) then 
			RED	<=	"11111111"; 
			GR	<=	"00000000"; 
			BL	<=	"00000000";
elsif ((contHS > 527 AND contHS < 539) AND (contVS > 312 AND contVS < 324)) then 
			RED	<=	"11111111"; 
			GR	<=	"00000000"; 
			BL	<=	"00000000";
elsif ((contHS > 575 AND contHS < 587) AND (contVS > 312 AND contVS < 324)) then 
			RED	<=	"11111111"; 
			GR	<=	"00000000"; 
			BL	<=	"00000000";
elsif ((contHS > 527 AND contHS < 539) AND (contVS > 324 AND contVS < 336)) then 
			RED	<=	"11111111"; 
			GR	<=	"00000000"; 
			BL	<=	"00000000";
elsif ((contHS > 551 AND contHS < 563) AND (contVS > 324 AND contVS < 336)) then 
			RED	<=	"11111111"; 
			GR	<=	"00000000"; 
			BL	<=	"00000000";
elsif ((contHS > 575 AND contHS < 587) AND (contVS > 324 AND contVS < 336)) then 
			RED	<=	"11111111"; 
			GR	<=	"00000000"; 
			BL	<=	"00000000";
elsif ((contHS > 527 AND contHS < 539) AND (contVS > 336 AND contVS < 348)) then 
			RED	<=	"11111111"; 
			GR	<=	"00000000"; 
			BL	<=	"00000000";
elsif ((contHS > 551 AND contHS < 563) AND (contVS > 336 AND contVS < 348)) then 
			RED	<=	"11111111"; 
			GR	<=	"00000000"; 
			BL	<=	"00000000";
elsif ((contHS > 575 AND contHS < 587) AND (contVS > 336 AND contVS < 348)) then 
			RED	<=	"11111111"; 
			GR	<=	"00000000"; 
			BL	<=	"00000000";
elsif ((contHS > 527 AND contHS < 587) AND (contVS > 348 AND contVS < 360)) then 
			RED	<=	"11111111"; 
			GR	<=	"00000000"; 
			BL	<=	"00000000";
end if;

if ((contHS > 592 AND contHS < 652) AND (contVS > 300 AND contVS < 312)) then 
			RED	<=	"11111111"; 
			GR	<=	"00000000"; 
			BL	<=	"00000000";
		elsif ((contHS > 592 AND contHS < 612) AND (contVS > 312 AND contVS < 324)) then
			RED	<=	"11111111"; 
			GR	<=	"00000000"; 
			BL	<=	"00000000";
		elsif ((contHS > 632 AND contHS < 652) AND (contVS > 312 AND contVS < 324)) then
			RED	<=	"11111111"; 
			GR	<=	"00000000"; 
			BL	<=	"00000000";
		elsif ((contHS > 592 AND contHS < 612) AND (contVS > 324 AND contVS < 336)) then
			RED	<=	"11111111"; 
			GR	<=	"00000000"; 
			BL	<=	"00000000";
		elsif ((contHS > 632 AND contHS < 652) AND (contVS > 324 AND contVS < 336)) then
			RED	<=	"11111111"; 
			GR	<=	"00000000"; 
			BL	<=	"00000000";
		elsif ((contHS > 592 AND contHS < 612) AND (contVS > 336 AND contVS < 348)) then
			RED	<=	"11111111"; 
			GR	<=	"00000000"; 
			BL	<=	"00000000";
		elsif ((contHS > 632 AND contHS < 652) AND (contVS > 336 AND contVS < 348)) then
			RED	<=	"11111111"; 
			GR	<=	"00000000"; 
			BL	<=	"00000000";
		elsif ((contHS > 592 AND contHS < 652) AND (contVS > 348 AND contVS < 360)) then 
			RED	<=	"11111111"; 
			GR	<=	"00000000"; 
			BL	<=	"00000000";
		end if;

if ((contHS > 657 AND contHS < 717) AND (contVS > 300 AND contVS < 312)) then 
			RED	<=	"11111111"; 
			GR	<=	"00000000"; 
			BL	<=	"00000000";
		elsif ((contHS > 657 AND contHS < 677) AND (contVS > 312 AND contVS < 324)) then
			RED	<=	"11111111"; 
			GR	<=	"00000000"; 
			BL	<=	"00000000";
		elsif ((contHS > 697 AND contHS < 717) AND (contVS > 312 AND contVS < 324)) then
			RED	<=	"11111111"; 
			GR	<=	"00000000"; 
			BL	<=	"00000000";
		elsif ((contHS > 657 AND contHS < 677) AND (contVS > 324 AND contVS < 336)) then
			RED	<=	"11111111"; 
			GR	<=	"00000000"; 
			BL	<=	"00000000";
		elsif ((contHS > 697 AND contHS < 717) AND (contVS > 324 AND contVS < 336)) then
			RED	<=	"11111111"; 
			GR	<=	"00000000"; 
			BL	<=	"00000000";
		elsif ((contHS > 657 AND contHS < 677) AND (contVS > 336 AND contVS < 348)) then
			RED	<=	"11111111"; 
			GR	<=	"00000000"; 
			BL	<=	"00000000";
		elsif ((contHS > 697 AND contHS < 717) AND (contVS > 336 AND contVS < 348)) then
			RED	<=	"11111111"; 
			GR	<=	"00000000"; 
			BL	<=	"00000000";
		elsif ((contHS > 657 AND contHS < 677) AND (contVS > 348 AND contVS < 360)) then
			RED	<=	"11111111"; 
			GR	<=	"00000000"; 
			BL	<=	"00000000";
		elsif ((contHS > 697 AND contHS < 717) AND (contVS > 348 AND contVS < 360)) then
			RED	<=	"11111111"; 
			GR	<=	"00000000"; 
			BL	<=	"00000000";
		end if;
				elsif(marcadorp2 = 5) then
				if ((contHS > 301 AND contHS < 361) AND (contVS > 300 AND contVS < 312)) then 
			RED	<=	"00000000"; 
			GR	<=	"00000000"; 
			BL	<=	"11111111";
elsif ((contHS > 301 AND contHS < 313) AND (contVS > 312 AND contVS < 324)) then 
			RED	<=	"00000000"; 
			GR	<=	"00000000"; 
			BL	<=	"11111111";
elsif ((contHS > 349 AND contHS < 361) AND (contVS > 312 AND contVS < 324)) then 
			RED	<=	"00000000"; 
			GR	<=	"00000000"; 
			BL	<=	"11111111";
elsif ((contHS > 301 AND contHS < 361) AND (contVS > 324 AND contVS < 336)) then 
			RED	<=	"00000000"; 
			GR	<=	"00000000"; 
			BL	<=	"11111111";
elsif ((contHS > 301 AND contHS < 313) AND (contVS > 336 AND contVS < 348)) then 
			RED	<=	"00000000"; 
			GR	<=	"00000000"; 
			BL	<=	"11111111";
elsif ((contHS > 301 AND contHS < 313) AND (contVS > 348 AND contVS < 360)) then 
			RED	<=	"00000000"; 
			GR	<=	"00000000"; 
			BL	<=	"11111111";
end if;

if ((contHS > 366 AND contHS < 426) AND (contVS > 300 AND contVS < 312)) then 
			RED	<=	"00000000"; 
			GR	<=	"00000000"; 
			BL	<=	"11111111";
		elsif ((contHS > 406 AND contHS < 426) AND (contVS > 312 AND contVS < 324)) then
			RED	<=	"00000000"; 
			GR	<=	"00000000"; 
			BL	<=	"11111111";
		elsif ((contHS > 366 AND contHS < 426) AND (contVS > 324 AND contVS < 336)) then
			RED	<=	"00000000"; 
			GR	<=	"00000000"; 
			BL	<=	"11111111";
		elsif ((contHS > 366 AND contHS < 386) AND (contVS > 336 AND contVS < 348)) then
			RED	<=	"00000000"; 
			GR	<=	"00000000"; 
			BL	<=	"11111111";
		elsif ((contHS > 366 AND contHS < 426) AND (contVS > 348 AND contVS < 360)) then 
			RED	<=	"00000000"; 
			GR	<=	"00000000"; 
			BL	<=	"11111111";
		end if;

if ((contHS > 527 AND contHS < 539) AND (contVS > 300 AND contVS < 312)) then 
			RED	<=	"00000000"; 
			GR	<=	"00000000"; 
			BL	<=	"11111111";
elsif ((contHS > 575 AND contHS < 587) AND (contVS > 300 AND contVS < 312)) then 
			RED	<=	"00000000"; 
			GR	<=	"00000000"; 
			BL	<=	"11111111";
elsif ((contHS > 527 AND contHS < 539) AND (contVS > 312 AND contVS < 324)) then 
			RED	<=	"00000000"; 
			GR	<=	"00000000"; 
			BL	<=	"11111111";
elsif ((contHS > 575 AND contHS < 587) AND (contVS > 312 AND contVS < 324)) then 
			RED	<=	"00000000"; 
			GR	<=	"00000000"; 
			BL	<=	"11111111";
elsif ((contHS > 527 AND contHS < 539) AND (contVS > 324 AND contVS < 336)) then 
			RED	<=	"00000000"; 
			GR	<=	"00000000"; 
			BL	<=	"11111111";
elsif ((contHS > 551 AND contHS < 563) AND (contVS > 324 AND contVS < 336)) then 
			RED	<=	"00000000"; 
			GR	<=	"00000000"; 
			BL	<=	"11111111";
elsif ((contHS > 575 AND contHS < 587) AND (contVS > 324 AND contVS < 336)) then 
			RED	<=	"00000000"; 
			GR	<=	"00000000"; 
			BL	<=	"11111111";
elsif ((contHS > 527 AND contHS < 539) AND (contVS > 336 AND contVS < 348)) then 
			RED	<=	"00000000"; 
			GR	<=	"00000000"; 
			BL	<=	"11111111";
elsif ((contHS > 551 AND contHS < 563) AND (contVS > 336 AND contVS < 348)) then 
			RED	<=	"00000000"; 
			GR	<=	"00000000"; 
			BL	<=	"11111111";
elsif ((contHS > 575 AND contHS < 587) AND (contVS > 336 AND contVS < 348)) then 
			RED	<=	"00000000";
			GR	<=	"00000000";
			BL	<=	"11111111";
elsif ((contHS > 527 AND contHS < 587) AND (contVS > 348 AND contVS < 360)) then 
			RED	<=	"00000000"; 
			GR	<=	"00000000"; 
			BL	<=	"11111111";
end if;

if ((contHS > 592 AND contHS < 652) AND (contVS > 300 AND contVS < 312)) then 
			RED	<=	"00000000"; 
			GR	<=	"00000000"; 
			BL	<=	"11111111";
		elsif ((contHS > 592 AND contHS < 612) AND (contVS > 312 AND contVS < 324)) then
			RED	<=	"00000000"; 
			GR	<=	"00000000"; 
			BL	<=	"11111111";
		elsif ((contHS > 632 AND contHS < 652) AND (contVS > 312 AND contVS < 324)) then
			RED	<=	"00000000"; 
			GR	<=	"00000000"; 
			BL	<=	"11111111";
		elsif ((contHS > 592 AND contHS < 612) AND (contVS > 324 AND contVS < 336)) then
			RED	<=	"00000000"; 
			GR	<=	"00000000"; 
			BL	<=	"11111111";
		elsif ((contHS > 632 AND contHS < 652) AND (contVS > 324 AND contVS < 336)) then
			RED	<=	"00000000"; 
			GR	<=	"00000000"; 
			BL	<=	"11111111";
		elsif ((contHS > 592 AND contHS < 612) AND (contVS > 336 AND contVS < 348)) then
			RED	<=	"00000000"; 
			GR	<=	"00000000"; 
			BL	<=	"11111111";
		elsif ((contHS > 632 AND contHS < 652) AND (contVS > 336 AND contVS < 348)) then
			RED	<=	"00000000"; 
			GR	<=	"00000000"; 
			BL	<=	"11111111";
		elsif ((contHS > 592 AND contHS < 652) AND (contVS > 348 AND contVS < 360)) then 
			RED	<=	"00000000"; 
			GR	<=	"00000000"; 
			BL	<=	"11111111";
		end if;

if ((contHS > 657 AND contHS < 717) AND (contVS > 300 AND contVS < 312)) then 
			RED	<=	"00000000"; 
			GR	<=	"00000000"; 
			BL	<=	"11111111";
		elsif ((contHS > 657 AND contHS < 677) AND (contVS > 312 AND contVS < 324)) then
			RED	<=	"00000000"; 
			GR	<=	"00000000"; 
			BL	<=	"11111111";
		elsif ((contHS > 697 AND contHS < 717) AND (contVS > 312 AND contVS < 324)) then
			RED	<=	"00000000"; 
			GR	<=	"00000000"; 
			BL	<=	"11111111";
		elsif ((contHS > 657 AND contHS < 677) AND (contVS > 324 AND contVS < 336)) then
			RED	<=	"00000000"; 
			GR	<=	"00000000"; 
			BL	<=	"11111111";
		elsif ((contHS > 697 AND contHS < 717) AND (contVS > 324 AND contVS < 336)) then
			RED	<=	"00000000"; 
			GR	<=	"00000000"; 
			BL	<=	"11111111";
		elsif ((contHS > 657 AND contHS < 677) AND (contVS > 336 AND contVS < 348)) then
			RED	<=	"00000000"; 
			GR	<=	"00000000"; 
			BL	<=	"11111111";
		elsif ((contHS > 697 AND contHS < 717) AND (contVS > 336 AND contVS < 348)) then
			RED	<=	"00000000"; 
			GR	<=	"00000000"; 
			BL	<=	"11111111";
		elsif ((contHS > 657 AND contHS < 677) AND (contVS > 348 AND contVS < 360)) then
			RED	<=	"00000000"; 
			GR	<=	"00000000"; 
			BL	<=	"11111111";
		elsif ((contHS > 697 AND contHS < 717) AND (contVS > 348 AND contVS < 360)) then
			RED	<=	"00000000"; 
			GR	<=	"00000000"; 
			BL	<=	"11111111";
		end if;
				end if;
	
	
	end if;
	end process;
--MÁQUINA DE ESTADOS PARA MOVIMIENTO DE LA PELOTA--
		process(clk_div2, estado_pelota)
		variable CentroX : integer := 464;
		variable CentroY : integer := 250;
		variable signoX : STD_LOGIC := '0'; --0 será para positivo, 1 para negativo
		variable signoY : STD_LOGIC := '0';	--0 será para positivo, 1 para negativo		
		variable marp1 : integer := 0;
		variable marp2 : integer := 0;
			begin
				if( SW(1) = '1' AND marp1 < 5 AND marp2 < 5) then
				if(rising_edge(clk_div2)) then
				if( SW(0) = '1') then
					marp1 := 0;
					marp2 := 0;
				end if;
					case estado_pelota is 


						when Movimiento =>
								if(signoX = '0' AND signoY = '0') then --Se mueve hacia arriba y hacia la derecha
									CentroX := CentroX + 1;
									CentroY := CentroY - 1;
									if(LimSupBall = 44) then
										estado_pelota <= ReboteArriba;
									elsif(LimDerBall = LimIzqBarrD - 1 AND LimSupBall < LimSupBarrD AND LimInfBall > LimInfBarrD ) then
										estado_pelota <= ReboteDerecha;
									elsif(LimDerBall = 769) then
										estado_pelota <= ScoreP1;
									else
										estado_pelota <= estado_pelota;
									end if;
							elsif(signoX = '0' AND signoY = '1') then --Se mueve hacia derecha y hacia abajo
									CentroX := CentroX + 1;
									CentroY := CentroY + 1;
									if(LimSupBall = 44) then
										estado_pelota <= ReboteArriba;
									elsif(LimInfBall = 488) then
										estado_pelota <= ReboteAbajo;
									elsif(LimDerBall = LimIzqBarrD - 1 AND LimSupBall < LimSupBarrD AND LimInfBall > LimInfBarrD ) then
										estado_pelota <= ReboteDerecha;
									elsif(LimIzqBall = LimDerBarrI + 1 AND LimSupBall < LimSupBarrI AND LimInfBall > LimInfBarrI ) then
										estado_pelota <= ReboteIzquierda;
									elsif(LimDerBall = 769) then
										estado_pelota <= ScoreP1;
									elsif(LimIzqBall = 157) then
										estado_pelota <= ScoreP2;
									else
										estado_pelota <= estado_pelota;
									end if;
							elsif(signoX = '1' AND signoY = '0') then --Se mueve hacia arriba la izquierda
									CentroY := CentroY - 1;
									CentroX := CentroX - 1;
									if(LimSupBall = 44) then
										estado_pelota <= ReboteArriba;
									elsif(LimInfBall = 488) then
										estado_pelota <= ReboteAbajo;
									elsif(LimDerBall = LimIzqBarrD - 1 AND LimSupBall < LimSupBarrD AND LimInfBall > LimInfBarrD ) then
										estado_pelota <= ReboteDerecha;
									elsif(LimIzqBall = LimDerBarrI + 1 AND LimSupBall < LimSupBarrI AND LimInfBall > LimInfBarrI ) then
										estado_pelota <= ReboteIzquierda;
									elsif(LimDerBall = 769) then
										estado_pelota <= ScoreP1;
									elsif(LimIzqBall = 157) then
										estado_pelota <= ScoreP2;
									else
										estado_pelota <= estado_pelota;
									end if;
							elsif(signoX = '1' AND signoY = '1') then --Se mueve hacia abajo y hacia la izquierda
									CentroX := CentroX - 1;
									CentroY := CentroY + 1;
									if(LimSupBall = 44) then
										estado_pelota <= ReboteArriba;
									elsif(LimInfBall = 488) then
										estado_pelota <= ReboteAbajo;
									elsif(LimDerBall = LimIzqBarrD - 1 AND LimSupBall < LimSupBarrD AND LimInfBall > LimInfBarrD ) then
										estado_pelota <= ReboteDerecha;
									elsif(LimIzqBall = LimDerBarrI + 1 AND LimSupBall < LimSupBarrI AND LimInfBall > LimInfBarrI ) then
										estado_pelota <= ReboteIzquierda;
									elsif(LimDerBall = 769) then
										estado_pelota <= ScoreP1;
									elsif(LimIzqBall = 157) then
										estado_pelota <= ScoreP2;
									else
										estado_pelota <= estado_pelota;
									end if;
							end if;

							
						when ReboteArriba =>
							signoY := '1';
							estado_pelota <= Movimiento;
						when ReboteAbajo =>
							signoY := '0';
							estado_pelota <= Movimiento;
						when ReboteIzquierda =>
							signoX := '0';
							signoY := NOT(signoY);
							estado_pelota <= Movimiento;
						when ReboteDerecha =>
							signoX := '1';
							signoY := NOT(signoY);
							estado_pelota <= Movimiento;
						when ScoreP1 =>
							signoX := signoX;
							signoY := signoY;
							CentroX := 470;
							marp1 := marp1 + 1;
							estado_pelota <= Movimiento;
						when ScoreP2 =>
							signoX := signoX;
							signoY := signoY;
							CentroX := 458;
							marp2 := marp2 + 1;
							estado_pelota <= Movimiento;	
						when others =>
						estado_pelota <= Movimiento;
					end case;
				else
					estado_pelota <= estado_pelota;
				end if;
			end if;
		CoordenadaXCPelota <= CentroX;
		CoordenadaYCPelota <= CentroY;
		marcadorp1 <= marp1;
		marcadorp2 <= marp2;
		end process;
--MÁQUINA DE ESTADOS PARA MOVIMIENTO DE LA PELOTA--
	
	
		--MOVIMIENTO DE LAS BARRAS--	
 -- Movimiento de la barra BI_Abajo--
	process(clk_div2)
	variable CentroBarraIzquierda : integer := 270;
	begin
		if rising_edge(clk_div2) then --72 a 469
			if(BI_Abajo = '1' AND CentroBarraIzquierda < 473) then
				CentroBarraIzquierda := CentroBarraIzquierda + 1;
			end if;
			if(BI_Arriba = '1' AND CentroBarraIzquierda > 71) then
				CentroBarraIzquierda := CentroBarraIzquierda - 1;
			end if;
		end if;
	ContadorBI <= CentroBarraIzquierda;
	end process;
 -- Movimiento de la barra BI_Abajo--
 -- Movimiento de la barra BI_Arriba--
  	process(clk_div2)
	variable CentroBarraDerecha : integer := 270;
	begin
		if rising_edge(clk_div2) then
			if (BD_Abajo = '1' AND CentroBarraDerecha < 473) then
				CentroBarraDerecha := CentroBarraDerecha + 1;
			end if;
			if(BD_Arriba = '1' AND CentroBarraDerecha > 71) then
				CentroBarraDerecha := CentroBarraDerecha - 1;
			end if;
		end if;
	ContadorBD <= CentroBarraDerecha;
	end process;
  -- Movimiento de la barra BI_Arriba--
		--MOVIMIENTO DE LAS BARRAS--  
		

		
		
	VGA_R <= RED;
	VGA_G <= GR;
	VGA_B <= BL;
	VGA_CLK <= clk_div;
	VGA_HS <= HS_signal;
	VGA_VS <= VS_signal;

end beh;