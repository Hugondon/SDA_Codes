library ieee;
use ieee.std_logic_1164.all;

Entity Sumador4b is
Port(
x1, x2, x3, x4, y1, y2, y3, y4, Cin: in std_logic;
Salida1,Salida2,Salida3,Salida4,Cout: out std_logic
);
End Sumador4b;
Architecture struct of Sumador4b is
component fulladder is
port (X, Y, Cin: in std_logic;
Cout, S: out std_logic
);
end component;
signal C1, C2, C3: std_logic;
begin
u0: fulladder port map(x1, y1, Cin, C1, Salida1);
u1: fulladder port map(x2, y2, C1, C2, Salida2);
u2: fulladder port map(x3, y3, C2, C3, Salida3);
u3: fulladder port map(x4, y4, C3, Cout, Salida4);
end struct;