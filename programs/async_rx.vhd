LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.MATH_REAL.ALL;

Entity Rec_Asinc is
	Port(
		clk		: in std_logic; --clock que va 16 veces más rápido que el de Tx
		nReset	: in std_logic;
		en 		: in std_logic;
		dataIn 	: in std_logic;
		dataOut	: out std_logic_vector(7 downto 0);
		status  : out std_logic
	);
End entity;

Architecture receiving of Rec_Asinc is
	Type FSM is (IDLE, START,DATA,STOPB);
	signal current_state, next_state: FSM;
	signal dataInReg: std_logic;
	signal dataOutReg: std_logic_vector(7 downto 0);
	signal statusReg: std_logic;
	signal counter: integer range 0 to 16:= 0;
	signal counterBits: integer range 0 to 8:= 0;
	
	Begin
		status <= statusReg; --Asignacion de señal interna a salida del componente
		
		Process(current_state)
		Begin
			if nReset='0' then
				dataOutReg<= (others =>'0');
				statusReg<= '0';
				counter <= 0;
				counterBits<=0;
				next_state <= IDLE;
				
			elsif rising_edge(clk) then
				case (current_state) is
					when IDLE =>
						statusReg <='0';
						dataOutReg <= (others =>'0');
						
						if en = '1' then
							if counter < 8 then
								counter <= counter + 1;
							else 
								next_state <= START;
								dataInReg <= dataIn;
								counter <= 0;
							end if;
						else
							next_state <= IDLE; 
							dataInReg <= '1';
						end if;
						
					when START =>
						if (dataInReg = '0') then
							next_state <= DATA;
							counter <= 0;
							counterBits <= 0;
							dataOutReg <= (others =>'0');
							statusReg <='0';
						else
							next_state <= IDLE;
							counter <= 0;
							dataOutReg <= (others =>'0');
							statusReg <='0';
						end if;
						
					when DATA =>
						statusReg <='0';
						if (counterBits < 8) then
							if (counter < 16) then
								counter <= counter + 1;
							else
								dataOutReg(counterBits) <= dataIn;
								counterBits <= counterBits + 1;							
							end if;
						else
							next_state <= STOPB;
							counter <= 0;
							counterBits <= 0;
						end if;
						
					when STOPB =>
						dataOut<= dataOutReg;
						statusReg<= '1';
						counter <= 0;
						counterBits<=0;
						next_state <= IDLE;
						
					when others =>
						dataOutReg <= (others =>'0');
						statusReg<= '0';
						counter <= 0;
						counterBits<=0;
						next_state <= IDLE;
				end case;
			else
				dataOutReg<= dataOutReg;
				statusReg<= statusReg;
				counter <= counter;
				counterBits<= counterBits;
				next_state <= next_state;
			end if;
		End process;
		
		
		--Proceso para cambio de estados
		Process(current_state,next_state,clk,nReset)
		Begin
			if nReset = '0' then
				current_state <= IDLE;
			elsif rising_edge(clk) then
				current_state <= next_state;
			else
				current_state <= current_state;
			end if;
		End process;
	
End receiving;