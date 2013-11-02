library ieee;
use ieee.std_logic_1164.all;

entity outReg is
	generic	(
				outWordLen	: natural:=32;
				inWordLen	: natural:=128
			);
	port	(
				clk,
				reset,
				shift	: in	std_logic;
				dataIn	: in	std_logic_vector(inWordLen-1 downto 0);
				dataOut	: out	std_logic_vector(outWordLen-1 downto 0)
		   );
end entity;

architecture behaviour of outReg is
signal word :	std_logic_vector(inWordLen-1 downto 0);
begin
	dataOut <= word(outWordLen-1 downto 0);
	process(clk)
	begin
		if clk'event and clk='1' then
			if reset='0' then
				word	<= (others=>'0');
			else
				if shift='1' then
					word <= (outWordLen=>'0') & word(inWordLen-1 downto outWordLen);
				else
					word <=	dataIn;
				end if;
			end if;
		end if;
	end process;
end architecture;