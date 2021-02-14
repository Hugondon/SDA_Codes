LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.MATH_REAL.ALL;

ENTITY Multiplicador_tb IS
END ENTITY;

ARCHITECTURE tb OF Multiplicador_tb IS

--- components
component Multiplicador is
    Port ( a  : in std_logic_vector(3 downto 0);
      b   : in std_logic_vector(3 downto 0);
      p   : out std_logic_vector(7 downto 0)
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
signal p : std_logic_vector(7 downto 0);




---user signals


begin


-- instances

   Multiplicador : Multiplicador port map(a,b,p);

stimulus: process
  begin
    -- Put initialisation code here
    stop_clk  <= false;
    A<= "1001";
    B<= "0011";

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