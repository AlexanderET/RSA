library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.RSAconstants.all;

entity mux is
	generic(
                WordLen : positive := 128
            );
    port	(
            	A,
             	B,
             	C	      	:in  std_logic_vector(WordLen-1 downto 0);
             	muxState	:in  std_logic_vector(1 downto 0);
             	output		:out std_logic_vector(WordLen-1 downto 0)
             );
end entity;

architecture behaviour of mux is
begin
	with muxState select output <=
              A	when mux_A,
              B when mux_B,
              C when others;
end architecture;
                
