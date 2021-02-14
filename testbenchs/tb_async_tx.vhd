LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.MATH_REAL.ALL;

Entity Trans_Asinc_tb is
end entity;

Architecture tb of Trans_Asinc_tb is
--------------------------------------------------------------------------------Importación de Componente
component Trans_Asinc is
port(clk, enable, reset: in std_logic; -- enable activo en 1, reset activo en 0
	 data_in: in std_logic_vector (7 downto 0);
	 data_out: out std_logic
);
end component;

--- constants
   constant clk_T	: time :=20 ns;
---signals
   signal clk		: std_logic;
   signal stop_clk	: boolean;
   
   -- component signals
   signal enable, data_out, reset: std_logic;
	signal data_in: std_logic_vector (7 downto 0);
	
	-- user signals
	----------------------------------------------------------------------------Proceso  de estimulación
	
	begin
		TX: Trans_Asinc port map (clk, enable, reset, data_in, data_out);
		
		stimulus: process
		begin
			stop_clk <= false;

			reset <= '0';
			
			wait for 100 us;

			reset <= '1';
			
			wait for 100 us;
			
			reset <= '0';
			enable <= '0';
			data_in <= "01110001";	
				
			wait for 2 ms;
			
			enable <= '1';
			data_in <= "01110001";
				
			wait for 1.5 ms;
			
			data_in <= "01100010";
				
			wait for 2 ms;
			
			data_in <= "01100010";
			
			wait for 3 ms;
			
			stop_clk <= true;

		    wait;
		  end process; --stimulus
		------------------------------------------------------------------------------Proceso de clocking

		clocking: process
		begin
			while NOT stop_clk loop
			  clk <= '1', '0' after clk_T / 2;
			wait for clk_T;
			end loop;
			wait;
			end process; --clocking
  

end tb;
