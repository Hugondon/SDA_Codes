LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.MATH_REAL.ALL;

ENTITY SBCD_tb IS
END ENTITY;

ARCHITECTURE tb OF SBCD_tb IS

--- components
component SBCD is
    Port ( A: in std_logic_vector (3 downto 0);
        B: in std_logic_vector (3 downto 0);
        Cin: in std_logic;
        sbcd: out std_logic_vector (3 downto 0);
        Coutbcd,Coutbcdinutil: out  std_logic
);
end component;

--- constants
   constant clk_T : time :=20 ns;
---signals
   signal clk   : std_logic;
   signal stop_clk  : boolean;

---component signals
signal A:  std_logic_vector (3 downto 0);
signal B  : std_logic_vector(3 downto 0);
signal Cin  : std_logic;
signal sbcd : std_logic_vector(3 downto 0);
signal Coutbcd, Coutbcdinutil: std_logic;



---user signals


begin


-- instances

   SBCD : SBCD port map(A,B,Cin,sbcd,Coutbcd,Coutbcdinutil);

stimulus: process
  begin
    -- Put initialisation code here
    stop_clk  <= false;
    A<= "1110";
    B<= "0011";
    Cin<= '0';

    wait for 1 us;

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