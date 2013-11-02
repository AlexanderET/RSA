library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity control is
	generic	(	
				inWordLen	: positive	:= 32;
				outWordLen	: positive	:= 128
			);
	port	(
				clk,
				reset,
	       		        initRSA,
				startRSA,
				residueRdy,
				monProRdy	: in	std_logic;
				dataIn		: in	std_logic_vector(inWordLen-1 downto 0);
				getResidue,
				getMonPro,
				coreWaiting	: out	std_logic;
				muxAstate,
				muxBstate	: out	std_logic_vector(1 downto 0);
				Mo,
				Eo,
				No,
				RMNo		: out	std_logic_vector(outWordLen-1 downto 0);
				outMuxState	: out	std_logic_vector(2 downto 0); -- Dette tallet må gjøres generisk...
			);
end entity;

architecture behaviour of control is
type state is(	fetchE,
				fetchN,
				fetchX,
				fetchY,
				fetchM,
				startResidue
				residue,
				startSqr,
				sqr,
				startMonPro,
				monPro,
				startConvert,
				convert,
				waiting,
                                txData  --endring
			);

signal	counter		: natural range 0 to outWordLen-1;
signal	counterCtrl	: std_logic_vector(1 downto 0);

signal 	prState,
		nxState		: state;

signal	M,
		E,
		N,
		RMN : std_logic_vector(outWordLen-1 downto 0);
		
constant	numPackages	: positive	:= outWordLen/inWordLen;
		
constant	count			: std_logic_vector(1 downto 0) := "01";
constant	resetCounter	        : std_logic_vector(1 downto 0) := "10";
constant	holdCounter		: std_logic_vector(1 downto 0) := "00";

constant	muxA_Y			: std_logic_vector(1 downto 0) := "00";
constant	muxA_M			: std_logic_vector(1 downto 0) := "01";
constant	muxA_RMN		: std_logic_vector(1 downto 0) := "10";

constant	muxB_Y			: std_logic_vector(1 downto 0) := "00";
constant	muxB_One		: std_logic_vector(1 downto 0) := "01";
constant	muxB_RMN		: std_logic_vector(1 downto 0) := "10";

begin
	
	getResidue	<= '1' when prState = startResidue else '0';
	getMonPro	<= '1' when prState = monPro else '0';
	coreWaiting	<= '1' when prState = waiting else '0';
	
	with prState select muxAstate<= --endring
                                muxA_Y 		WHEN convert|startConvert|sqr,
			 	muxA_M		WHEN monPro|startMonpro,
				muxA_RMn	WHEN
                                "1100"|"1010"|"1001"|"0110"|"0101"|"0011",--what?
				"11" 		WHEN others;
	
        with prState select muxBstate<=
                                muxB_Y 		WHEN sqr|monPro|startMonpro,
			 	muxB_one	WHEN convert|startConvert,
				muxB_RMn	WHEN "1100"|"1010"|"1001"|"0110"|"0101"|"0011",
	                        "11"            WHEN others;

	process(nxState,prState,startRSA,initRSA,residueRdy,monProRdy)
	begin		
		case prState is
			when waiting =>
				counterCtrl <= holdCounter;
				
				if initRSA = '1' then
					nxState <= fetchE;
				elsif startRSA = '1' then
					nxState <= fetchM;
				else
					nxState	<= waiting;
				end if;
			when fetchE =>
				if counter < numPackages then
					counterCtrl	<= count;
					nxState		<= fetchE;
				else
					counterCtrl <= resetCounter;
					nxState		<= fetchN;
				end if;
				
				E	<= dataIn & E(outWordLen -1 downto inWordLen);
			when fetchN =>
				if counter < numPackages then
					counterCtrl	<= count;
					nxState		<= fetchN;
				else
					counterCtrl <= resetCounter;
					nxState		<= fetchX;
				end if;
				
				N	<= dataIn & N(outWordLen -1 downto inWordLen);
			when fetchX =>
				if counter < numPackages then
					counterCtrl	<= count;
					nxState		<= fetchX;
				else
					counterCtrl <= resetCounter;
					nxState		<= fetchY;
				end if;
				
				RMN	<= dataIn & RMN(outWordLen -1 downto inWordLen);
			when fetchY =>
				if counter < numPackages then
					counterCtrl	<= count;
					nxState		<= fetchY;
				else
					counterCtrl <= resetCounter;
					nxState		<= waiting;
				end if;
			when fetchM =>
				if counter < numPackages then
					counterCtrl	<= count;
					nxState		<= fetchM;
				else
					counterCtrl <= resetCounter;
					nxState		<= startResidue;
				end if;
				
				M	<= dataIn & M(outWordLen -1 downto inWordLen);
			when startResidue =>
				counterCtrl	<= holdCounter;
				nxState		<= residue;
			when residue =>
				counterCtrl <= holdCounter;
				if residueRdy then
					nxState <= startSqr;
				else
					nxState <= residue;
				end if;
			when startSqr =>
				counterCtrl	<= count;
				if counter = 0 then
					--MuxA => rMod_n
					--MuxB => rMod_n
				else
					--MuxA	=> y
					--MuxB	=> y
				end if;
				nxState => sqr;
			when sqr =>
				counterCtrl => holdCounter;
				if monProRdy = '1' then
					if E(outWordLen-1) = '1' then
						nxState <= startMonPro;
					elsif counter = outWordLen-1 then
						nxState	<= startConvert;
					else
						nxState <= startSqr;
					end if;
				else
					nxState	<= sqr;
				end if;
			when startMonPro =>
				counterCtrl => holdCounter;
				--MuxA	=> M
				--MuxB	=> Y
				nxState	<= monPro;
			when monPro =>
				if monProRdy='1' then
					if counter = outWordLen-1 then
						nxState <= startConvert;
					else
						nxState <= startSqr;
					end if;
				else
					nxState <= monPro;
				end if;
			when startConvert =>
				counterCtrl => resetCounter;
				--MuxA	=> Y;
				--MuxB	=> one 
				nxState => convert;
			when convert =>
				counterCtrl => holdCounter;
				if monProRdy='1' then
					nxState => txData;
				else
					nxState => convert;
				end if;
			when txData =>
				--CoreFinished
				if counter < numPackages then
					counterCtrl => count;
					nxState		=> txData;
				else
					counterCtrl => resetCounter;
					nxState		=> waiting;
				end if;
			when others =>
				nxState	<= waiting;
				counterCtrl	<= holdCounter;
			
		end case;
	end process;
	
	process(clk)
	begin
		if clk'event and clk='1' then
			if reset='1' then
				prState <= waiting;
				counter <= 0;
				M		<= (others => '0');
				E		<= (others => '0');
				N		<= (others => '0');
				RMN		<= (others => '0');
			else
				prState	<= nxState;
				
				if prState = startSqr then
					E <= E(outWordLen-2 downto 0) & E(outWordLen-1);
				end if;
				
				if prState = txData then
					dataOut <= 
				
				if counterCtrl = "01" then
					counter <= counter+1;
				elsif counterCtrl = "10" then
					counter <= 0;
				end if;
			end if;
		end if;
	end process;
end architecture;
				
					
	
		
