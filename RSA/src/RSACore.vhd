library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RSACore is
		generic	(
					outWordLen	: positive :=128;
					inWordLen	: positive :=32
				);
        port(
             Clk                :in  std_logic;
             Resetn             :in  std_logic;
             InitRsa            :in  std_logic;
             StartRsa           :in  std_logic;
             DataIn             :in  std_logic_vector(inWordLen-1 downto 0);
             DataOut            :out std_logic_vector(inWordLen-1 downto 0);
             CoreFinished       :out std_logic
             );
end entity;

architecture behaviour of RSACore is

signal	residueRdy,
		monProRdy,
		getResidue,
		getMonPro,                                                  
		coreWaiting,
		shiftDo		: std_logic;                                             
signal	muxAstate,
      	muxBstate   : std_logic_vector(1 downto 0);
signal	M,          
      	E,                                                          
      	N,                                                          
      	RMN,
      	mBar,
		Y,
      	muxAo,
       	muxBo		: std_logic_vector(outWordLen-1 downto 0);
                  
constant one		: std_logic_vector(outWordLen-1 downto 0):=((outWordLen-1) downto 1 => '0') & '1';

begin

control: entity work.control(behaviour)
        generic map(
                    inWordLen  => inWordLen, 
                    outWordLen => outWordLen
                    )
        
        port map(
                 clk           =>   Clk,    
                 reset         =>   Resetn,
                 initRSA       =>   InitRsa,
                 startRSA      =>   StartRsa,
                 residueRdy    =>   residueRdy,
                 monProRdy     =>   monProRdy,    
                 dataIn	       =>   DataIn,    
                 getResidue    =>   getResidue,
                 getMonPro     =>   getMonPro,
                 coreWaiting   =>   coreWaiting,
				 shiftDo	   =>	shiftDo,
                 muxAstate     =>   muxAstate,
                 muxBstate     =>   muxBstate,    
                 Mo            =>   M,
                 Eo            =>   E,
                 No            =>   N,
                 RMNo	       =>   RMN    
                 );

muxA: entity work.mux(behaviour)
       generic	map(
                	   WordLen  => outWordLen
                   )
       port		map(
	                C       	=> mBar,    
	                B			=> RMN, 
	                A           => y,          
	                muxState    => muxAstate,   
	                output      => muxAo
                );

muxB: entity work.mux(behaviour)
       generic 	map(
                   		WordLen  => outWordLen
                   )
       port 	map(
		                C       	=> one,     
		                B			=> RMN,        
		                A           => y,           
		                muxState    => muxBstate,
		                output      => muxBo
					);
                
monPro: entity work.monpro(behaviour)
        generic map(
                    	wordLen => outWordLen	
                    )
        port 	map(
                 clk     =>    Clk,
                 reset   =>    Resetn,	
                 start   =>    getMonPro,	
                 Ain     =>    muxAo,
                 B       =>    muxBo,
                 n       =>    N,	
                 output  =>    Y,	
                 finish  =>    monProRdy
                 );

residue: entity work.residue(behaviour)
        generic map(
                    wordLen => outWordLen	
                    )
        port map(
                 clk    => Clk, 
                 reset  => Resetn,
                 start  => getResidue, 
                 Ain    => RMN,
                 B      => M,
                 n      => N,     
                 c      => mBar,     
                 finish => residueRdy
                 );
				 
outReg:	entity work.outReg(behaviour)
	generic	map	(
					outWordLen	=> inWordLen,
					inWordLen	=> outWordLen
				)
	port	map	(
					clk		=> Clk,     
					reset	=> Resetn,  
					shift	=> shiftDo,	
					dataIn	=> Y,	
					dataOut	=> DataOut
				);
end architecture;
