library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity muxB is
        generic(
                WordLen : positive = 128
                );
        port(
             RMN,
             y         :in  std_logic_vector(WordLen-1 downto 0);
             muxState  :in  std_logic_vector(2 downto 0);
             output    :out std_logic_vector(WordLen-1 downto 0)
             );
end entity;

architecture behavior of muxB is

begin

with muxState select output <=
              y   when muxState is "00",
              RMN when muxState is "10",
              std_logic_vector(to_unsigned(1,128))   when others;
end architecture;
                
