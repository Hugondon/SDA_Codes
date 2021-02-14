LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.MATH_REAL.ALL;

ENTITY template_tb IS
END ENTITY;

ARCHITECTURE tb OF template_tb IS

--- components DUTs
  component Deb_Mod
    port(
      clk, reset, btn_in: in std_logic;
      btn_out: out std_logic
    );
  end component;

--- constants
	constant 	clk_T			: 	time   :=20 ns;

---signals
	
	signal clock, clk, reset, btn_in, btn_out 	: std_logic;
	signal stop_clk	: boolean;

begin
C1: Deb_Mod port map (clock, reset, btn_in, btn_out);

-- instances DUTs

stimulus: process

  begin
    
  stop_clk  <= false;
    
    reset<='1';
  wait for 20ms;
    reset<='0';
    btn_in<='1';
  wait for 5ms;
    btn_in<='0';
  wait for 12ms;
    btn_in<='1';
  wait for 60ms;
    btn_in<='0';
  wait for 40ms;

	stop_clk <= true;

  wait;
  end process; --stimulus

clocking: process
  begin
    while NOT stop_clk loop
      clk <= '1', '0' after clk_T / 2;
      wait for clk_T;
    end loop;
    wait;
  end process; --clocking

end tb;