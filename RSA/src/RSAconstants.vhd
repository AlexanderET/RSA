library ieee;
use ieee.std_logic_1164.all;

package RSAconstants is
	constant	count			: std_logic_vector(1 downto 0) := "01";
	constant	resetCounter	: std_logic_vector(1 downto 0) := "10";
	constant	holdCounter		: std_logic_vector(1 downto 0) := "00";
	
	constant	mux_Y		: std_logic_vector(1 downto 0) := "00";
	constant	mux_M		: std_logic_vector(1 downto 0) := "01";
	constant	mux_RMN		: std_logic_vector(1 downto 0) := "10";
	constant	mux_One		: std_logic_vector(1 downto 0) := "01";
	
	constant	mux_A		: std_logic_vector(1 downto 0) := "00";
	constant	mux_B		: std_logic_vector(1 downto 0) := "10";
	constant	mux_C		: std_logic_vector(1 downto 0) := "01";
end package;