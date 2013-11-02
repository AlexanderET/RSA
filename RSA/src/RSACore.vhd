library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RSACore is
        port(
             Clk                :in  std_logic;
             Resetn             :in  std_logic;
             InitRsa            :in  std_logic;
             StartRsa           :in  std_logic;
             DataIn             :in  std_logic_vector(32 downto 0);
             DataOut            :out std_logic_vector(32 downto 0);
             CoreFinished       :out std_logic;
             );
end entity;

architecture behavior of RSACore is

signal residueRdy
signal monProRdy    : std_logic; 
signal getResidue   : std_logic_vector(inWordLen-1 downto 0);
signal getMonPro                                                  
signal coreWaiting  : std_logic;                                             
signal muxAstate,
       muxBstate    : std_logic_vector(1 downto 0);
signal M,          
       E,                                                          
       N,                                                          
       RMN,
       mBar,         
       outputMuxA,
       outputMuxB   : std_logic_vector(outWordLen-1 downto 0);
signal outMuxState  : std_logic_vector(2 downto 0);
                  


begin

control: entity work.control(behavior)
        generic map(
                    inWordLen  => inWordLen, 
                    outWordLen => outWordLen
                    );
        
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
                 muxAstate     =>   muxAstate,
                 muxBstate     =>   muxBstate,    
                 Mo            =>   M,
                 Eo            =>   E,
                 No            =>   N,
                 RMNo	       =>   RMN,    
                 outMuxState   =>   outMuxState
                 );

muxA: entity work.muxA(behavior)
       generic map(
                   WordLen  => outWordLen
                   );
       port map(
                mBar       => mBar,    
                RMN        => RMN, 
                y          => y,          
                muxState   => muxAstate,   
                output     => fromMuxA
                );

muxB: entity work.muxB(behavior)
       generic map(
                   WordLen  => outWordLen
                   );
       port map(
                RMN        => RMN, 
                y          => y,          
                muxState   => muxBstate,   
                output     => fromMuxB
                );
                
monPro: work.monpro(behavior)
        generic map(
                    wordLen => outWordLen	
                    );
        port map(
                 clk     =>    Clk,  --se over koblingene herifra og ned,
                 --ingen signaler er laget!	
                 reset   =>    Resetn,	
                 start   =>    start,	
                 Ain     =>    Ain,
                 B       =>    B,
                 n       =>    n,	
                 output  =>    output,	
                 finish  =>    finish
                 );

residue: work.residue(behavior)
        generic map(
                    wordLen => outWordLen	
                    );
        port map(
                 clk    => clk, 
                 reset  => reset,
                 start  => start, 
                 Ain    => Ain,
                 B      => B,
                 n      => n,     
                 c      => c,     
                 finish => finish
                 );
end architecture;
