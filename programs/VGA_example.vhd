library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

Entity VGA is
	Port(
		VGA_R,VGA_G,VGA_B : OUT std_logic_vector(7 downto 0);
		VGA_CLOCK, VGA_HS, VGA_VS : OUT std_logic;
		VGA_BLANK_N, VGA_SYNC_N : out std_logic;
		CLOCK_50 : IN std_logic;
		KEY : IN STD_LOGIC_VECTOR(1 DOWNTO 0)
	);
end VGA;


architecture ESTRU of VGA is

-- señales auxiliares, dentro del proceso se modifican y afuera se asignan a las señales de la entidad
-- las señales tDisp indican si estoy en el tiempo de display tanto en X como en Y
signal clk_aux, HS_aux, VS_aux, tDispX, tDispY: std_logic;
signal RO, GR, BL: std_logic_vector(7 downto 0);

begin

-- divisor de frecuencia
-- clk_aux es la señal a 25MHz / CLK es la señal de 50MHz
process(CLOCK_50) 
begin
	if rising_edge(CLOCK_50) then
		clk_aux <= not(clk_aux);
	else
		clk_aux <= clk_aux;
	end if;
end process;


process(clk_aux, KEY(0), KEY(1))
	variable contHS : integer:=0; --contador de pixeles en horizontal
	variable contVS : integer:=0; --contador de lineas
	variable poslv : integer:=444;
begin
	
	if rising_edge(clk_aux) then
		--Aqui hacemos HS
		if (contHS < 96) then -- aqui estoy en TPW
			HS_aux <= '0';
			tdispX <= '0';	-- este indica si puedo pintar o no (no puedo pintar)
			contHS := contHS + 1;
		elsif (contHS > 95 and contHS < 144) then --aqui estoy en back porch
			HS_aux <= '1';
			tdispX <= '0'; -- este indica si puedo pintar o no (no puedo pintar)
			contHS := contHS + 1;
		elsif (contHS > 143 and contHS < 784) then -- aqui estoy en Tdisp
			HS_aux <= '1';
			tdispX <= '1'; -- este indica si puedo pintar o no (ya puedo pintar)
			contHS := contHS + 1;
		elsif (contHS > 783 and contHS <800) then-- aqui estoy en front porch
			HS_aux <= '1';
			tdispX <= '0'; -- este indica si puedo pintar o no (no puedo pintar)
			contHS := contHS + 1;
		else	--aqui es que ya llegue a 800
			contHS := 0;
			contVS := contVS + 1;
		end if;
		--Aqui hacemos VS
		if (contVS < 2) then --aqui estoy en TPW
			VS_aux <= '0';
			tdispY <= '0'; -- este indica si puedo pintar o no (no puedo pintar)
		elsif (contVS > 1 and contVS < 31) then --aqui estoy en back porch
			VS_aux <= '1';
			tdispY <= '0'; -- este indica si puedo pintar o no (no puedo pintar)
		elsif (contVS > 30 and contVS < 511) then --aqui estoy Tdis
			VS_aux <= '1';
			tdispY <= '1'; -- este indica si puedo pintar o no (ya puedo pintar)
		elsif (contVS > 510 and contVS < 521) then --aqui estoy en front porch
			VS_aux <= '1';
			tdispY <= '0';
		else--llegue a 521
		 contVs:=0;
		end if;	
	end if;
	
	if(KEY(0)='1') then
		poslv:=poslv+10;
	elsif (KEY(1)='1') then
		poslv:=poslv-10;
	else
		poslv:=poslv;
	end if;
	
	-- si ambos tDisp estan en 1 significa que tanto en X como en Y estoy "dentro" de la pantalla y puedo pintar
	-- si alguno fuera 0 significa que estoy fuera de la pantalla y NO es necesario mandar alguna señal de color
	if (tdispX='1' and tdispY='1')then 
		-- este primer IF revisa si estoy entre las lineas 318 y 322 (recuerden que tenemos 480 lineas "pintables" en la pantalla)
		-- si esta dentro va a mandar unos en el canal azul, osea va a pintar una linea azul (de qué grosor????)
		if (contVS>348 and contVS<354)then --318+31 y 322+31
			RO<="00000000"; 
			GR<="00000000";
			BL<="11111111";
		-- aqui esta preguntando por una posicion en horizontal, especificamente el pixel 300.
		-- cada vez que pase por el pixel 300 en horizontal (tenemos 640 disponibles en pantalla) va a pintar un punto VERDE
		-- el efecto es una linea vertical verde cierto??
		elsif (contHS=poslv) then --300 + 144
			RO<="00000000"; 
			GR<="11111111"; 
			BL<="00000000";
		else
		--si no se cumple nada se manda blanco. el efecto?? pues una pantalla blanca con linea vertical verde y horizontal azul 
			RO<="11111111"; 
			GR<="11111111";
			BL<="11111111";
		end if;
		
	else 
		RO<="00000000"; 
		GR<="00000000"; 
		BL<="00000000";
	end if;
	
end process;

	VGA_HS <= HS_aux;
	VGA_VS <= VS_aux;
	VGA_CLOCK <= clk_aux;
	VGA_BLANK_N <='1';
	VGA_SYNC_N <='0';
	VGA_R <= RO;
	VGA_G <= GR;
	VGA_B <= BL;

end ESTRU;