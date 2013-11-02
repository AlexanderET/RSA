library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.RSAconstants.all;

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
				coreWaiting,
				shiftDo		: out	std_logic;
				muxAstate,
				muxBstate	: out	std_logic_vector(1 downto 0);
				Mo,
				Eo,
				No,
				RMNo		: out	std_logic_vector(outWordLen-1 downto 0)
			);
end entity;

architecture behaviour of control is
type state is(	fetchE,
				fetchN,
				fetchX,
				fetchY,
				fetchM,
				startResidue,
				residue,
				startSqr,
				sqr,
				startMonPro,
				monPro,
				startConvert,
				convert,
				waiting,
				txData
			);

signal	counter		: natural range 0 to outWordLen-1;
signal	counterCtrl	: std_logic_vector(1 downto 0);

signal 	prState,
		nxState		: state;

signal	M,
		E,
		N,
		RMN			: std_logic_vector(outWordLen-1 downto 0);
		
	constant	numPackages	: natural	:= outWordLen/inWordLen;

begin
	
	getResidue	<= '1' when prState = startResidue else '0';
	getMonPro	<= '1' when prState = monPro else '0';
	coreWaiting	<= '1' when prState = waiting else '0';

	process(nxState,prState,startRSA,initRSA,residueRdy,monProRdy,counter)
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
			when fetchN =>
				if counter < numPackages then
					counterCtrl	<= count;
					nxState		<= fetchN;
				else
					counterCtrl <= resetCounter;
					nxState		<= fetchX;
				end if;
			when fetchX =>
				if counter < numPackages then
					counterCtrl	<= count;
					nxState		<= fetchX;
				else
					counterCtrl <= resetCounter;
					nxState		<= fetchY;
				end if;
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
			when startResidue =>
				counterCtrl	<= holdCounter;
				nxState		<= residue;
			when residue =>
				counterCtrl <= holdCounter;
				if residueRdy='1' then
					nxState <= startSqr;
				else
					nxState <= residue;
				end if;
			when startSqr =>
				counterCtrl	<= count;
				nxState <= sqr;
			when sqr =>
				counterCtrl <= holdCounter;
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
				counterCtrl <= holdCounter;
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
				counterCtrl <= resetCounter;
				nxState <= convert;
			when convert =>
				counterCtrl <= holdCounter;
				if monProRdy='1' then
					nxState <= txData;
				else
					nxState <= convert;
				end if;
			when txData =>
				if counter < numPackages then
					counterCtrl <= count;
					nxState		<= txData;
				else
					counterCtrl <= resetCounter;
					nxState		<= waiting;
				end if;
			when others =>
				nxState	<= waiting;
				counterCtrl	<= holdCounter;
			
		end case;
	end process;
	
	process(clk)
	begin
		if clk'event and clk='1' then
			if reset='0' then
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
				
				if prState = fetchE then
					E	<= dataIn & E(outWordLen -1 downto inWordLen);
				end if;
				
				if prState = fetchN then
					N	<= dataIn & N(outWordLen -1 downto inWordLen);
				end if;
				
				if prState = fetchX then
					RMN	<= dataIn & RMN(outWordLen -1 downto inWordLen);
				end if;
				
				if prState = txData then
					shiftDo <= '1';
				else
					shiftDo <= '0';
				end if;
				
				if counterCtrl = "01" then
					counter <= counter+1;
				elsif counterCtrl = "10" then
					counter <= 0;
				end if;
			end if;
		end if;
	end process;
	
	process(counter,prState)
	begin
		if prState=waiting then
			coreWaiting	<= '1';
		else
			coreWaiting	<= '0';
		end if;
		
		if prState=sqr or prState=startSqr then
			if counter=0 then
				muxAstate	<= mux_RMN;
				muxBstate	<= mux_RMN;
			else
				muxAstate	<= mux_Y;
				muxBstate	<= mux_Y;
			end if;
		elsif prState=monPro or prState=startMonPro then
			muxAstate	<= mux_M;
			muxBstate	<= mux_Y;
		else
			muxAstate	<= mux_Y;
			muxBstate	<= mux_One;
		end if;
	end process;
end architecture;
				
					
	
		
