library ieee;
use ieee.std_logic_1164.all;

Entity HalfAdd is
Port(
A,B: in std_logic;
SUM, CARRY: out std_logic
);
End HalfAdd;
Architecture dataflow of HalfAdd is
Begin 
SUM <= A xor B;
CARRY <= A and B;
End dataflow;