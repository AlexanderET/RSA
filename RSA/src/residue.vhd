library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity residue is
	generic	(
				wordLen	: positive:=128
			);
	port	(	        clk,
				reset,
				start	: in	std_logic;
				Ain,
				B,
				n		: in	std_logic_vector(wordLen-1 downto 0);
				c		: out	std_logic_vector(wordLen-1 downto 0);
				finish	: out	std_logic
			);
end entity;

architecture behaviour of residue is
signal go		: std_logic;
signal A		: std_logic_vector(wordLen-1 downto 0);
signal counter	: natural range 0 to wordLen-1;

begin
	process(clk)
	variable result	: std_logic_vector(wordLen+1 downto 0);
	begin
		if clk'event and clk='1' then
			finish<=not go and not start;
			if reset='0' then
				A		<= Ain;
				result	:= (others =>'0');
				go		<= '0';
			else 
				if go='0' then
					if start='1' then
						result	:= (others => '0');
						go		<= '1';
						A		<= Ain;
					end if;
				else
					result := result(wordLen downto 0) & '0';
					if A(wordLen-1)='1' then
						result := std_logic_vector(unsigned(result) + unsigned(B));
					end if;
					
					for i in 0 to 1 loop
						if unsigned(result) >= unsigned(n) then
							result := std_logic_vector(unsigned(result)-unsigned(n));
						end if;
					end loop;

					A	<= A(wordLen-2 downto 0) & '0';
					if counter < wordLen-1 then
						counter <= counter +1;
					else
						counter <= 0;
						go		<= '0';
					end if;
				end if;
			end if;
		end if;
		
		c <= result(wordLen-1 downto 0);
	end process;
end architecture;
