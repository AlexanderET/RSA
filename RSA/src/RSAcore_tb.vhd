library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.RSAconstants.all;

entity RSAcore_tb is
	generic	(
				inWordLen	: natural := 32;
				outWordLen	: natural := 128
			);
end entity;

architecture behaviour of RSAcore_tb is
signal	Clk				: std_logic := '0';
signal	Resetn,
		InitRsa,
		StartRsa,
		coreFinished	: std_logic;
signal	dataIn,
		dataOut			: std_logic_vector(inWordLen-1 downto 0);

signal		run				: std_logic := '1';
constant	clkPer			: time 		:= 40ns;
begin
	
	RSACore:	entity work.RSACore(behaviour)
				generic	map	(
								outWordLen	=> outWordLen,
								inWordLen	=> inWordLen
							)
					
		        port	map	(
					             Clk			=>	Clk,        
					             Resetn         =>	Resetn,     
					             InitRsa        =>	InitRsa,    
					             StartRsa       => 	StartRsa,   
					             DataIn         => 	dataIn,
					             DataOut        => 	DataOut,     
					             CoreFinished   => 	coreFinished		
		             		);
	
	Clk <= not Clk after clkPer/2 when run='1' else '0';						 
	process
	begin
		Resetn		<= '0';
		InitRSA 	<= '0';
		StartRSA	<= '0';
		wait for clkPer;
		
		Resetn	<='1';
		wait for clkPer;
		
		dataIn	<=x"AAAA_AAAA";
		InitRsa	<='1';
		wait for clkPer;
		
		dataIn	<=x"AAAA_AAAA";
		InitRsa	<='0';
		wait for clkPer;
		
		wait for 10*clkPer;
		
		run<='0';
		wait;
	end process;
end architecture;