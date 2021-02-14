library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
 
entity Conversor_Bin_BCD is
    PORT(
        num_bin: in  STD_LOGIC_VECTOR(8 downto 0);
        num_bcd: out STD_LOGIC_VECTOR(10 downto 0)
    );
end Conversor_Bin_BCD;
 
architecture CB2BCD of Conversor_Bin_BCD is
	begin
   process(num_bin)
    variable var: STD_LOGIC_VECTOR(19 downto 0);
    begin
        var := (others => '0');
        var(11 downto 3) := num_bin;
        for rep in 0 to 5 loop
            if var(12 downto 9) > 4 then
                var(12 downto 9) := var(12 downto 9) + 3;
            end if;
            if var(16 downto 13) > 4 then
                var(16 downto 13) := var(16 downto 13) + 3;
            end if;
            if var(19 downto 17) > 4 then
                var(19 downto 17) := var(19 downto 17) + 3;
            end if;
            var(19 downto 1) := var(18 downto 0);
        end loop;
        num_bcd <= var(19 downto 9);
    end process;
end CB2BCD;