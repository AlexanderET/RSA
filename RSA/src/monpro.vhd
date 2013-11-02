library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity monpro is
	generic	(
				wordLen	: positive:=128
			);
	port	(	
				clk		: in		std_logic;
				reset	: in		std_logic;
				start	: in		std_logic;
				Ain,
				B,
				n		: in		std_logic_vector(7 downto 0);
				output	: out 		std_logic_vector(7 downto 0);
				finish	: out		std_logic
			);
end entity;

architecture behaviour of monpro is
signal A		: std_logic_vector(wordLen-1 downto 0);
signal go		: std_logic;
signal counter	: natural range 0 to wordLen-1;
begin 
	process(clk)
	variable U: std_logic_vector(wordLen downto 0);
	begin
		output <= U(wordLen-1 downto 0);
		
		if clk'event and clk='1' then
			finish	<=not go and not start;
			if reset='1' then
				U		:=(others=>'0');
				go		<='0';
				counter <=0;
			else
				if go='0' then
					if start='1' then
						U:=(others=>'0');
						go<='1';
						A<=Ain;
					end if;
				else
					if A(0)='1' then
						U:=std_logic_vector(unsigned(U)+unsigned(B));
					end if;
					if U(0)='1' then
						U:=std_logic_vector(unsigned(U)+unsigned(n));
					end if;
					U:='0' & U(wordLen downto 1);
					A<='0' & A(wordLen-1 downto 1);

					if counter=wordLen-1 then
						go<='0';
						counter<=0;
					else
						counter<=counter+1;
					end if;
				end if;
			end if;
		end if;	
	end process;	
end architecture;