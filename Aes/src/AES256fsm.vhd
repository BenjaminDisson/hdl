-- -------------------------------
-- AES256fsm.vhd
--
-- @Description
-- This is 
--
-- MODIFICATIONS
-- Date       | Author   | Comments
-- 2023/11/11 | B. Disson
--
--
--                ____________________________________________
--                |
--                |                 
-- Interfacing    |                
--   ___          |
-- -|   |         |    AES256fsmFSM
--  |   |>        |  
--  |   |<        |  
-- -|___|         |                
--                |                            
--                |                           
--                |                           
--                |                           
--                |                           
--                |______________________________________________
             


---------------------------------------------------------------------------
-- 
-- 1) LIBRARY DEFINITION
--
---------------------------------------------------------------------------
---------------------------------------------------------------------------
-- STANDART
---------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

---------------------------------------------------------------------------
-- CUSTOM
---------------------------------------------------------------------------
library AES256Top_lib;
use AES256Top_lib.AES256Top_pkg.all;


---------------------------------------------------------------------------
--
-- 2) ENTITY DEFINITION
--
---------------------------------------------------------------------------
entity AES256fsm is
	port(


	o_Irq 	: out std_logic -- Interruption (configurable)
	);

end entity AES256fsm;

architecture rtl of AES256fsm is

---------------------------------------------------------------------------
--
-- 3) DEFINITIONS
--
---------------------------------------------------------------------------
---------------------------------------------------------------------------
-- TYPES 
---------------------------------------------------------------------------

   type PrimeAESFsm is (
   	Initialization,
   	KeyExpansion,
   	CipherAES
   	);

-- Description : Finite state machine which manage the key expansion.
   type ExpandKeyFsm is (
    	Initialization, 	    -- Les 8 premiers mots (“word”) correspondant à des colonnes de 4 octets seront initialisées par les valeurs de la clé.
    	Mod8, 				    -- for i>7, if mod(8)=0, w[i] = w[i 􀀀 8]  SubWord(RotWordw[i 􀀀 1]))  Rcon[i=8].
    	Mod4, 				    -- for i>7, if mod(8)=4, w[i] = w[i 􀀀 8]  SubWord(w[i 􀀀 1]).
    	Filling);			    -- for i>7, if mod(8)!=0 and !=4, w[i] = w[i 􀀀 8]  w[i 􀀀 1].

   type CipherAESFsm is ( 
    	Initialization, 	  
    	FirstRoundKey, 	  -- FirstRoundKey			= AddRoundKey.
    	Mod4, 				  -- RoundTransformation	= SubBytes, ShiftRows, MixColumns, AddRoundKey.
    	Filling);		     -- LastRound					= SubBytes, ShiftRows, AddRoundKey


---------------------------------------------------------------------------
-- SIGNALS
---------------------------------------------------------------------------
  signal StateFsmAES			: PrimeAESFsm 	:= Initialization;     
  signal StateExpander		: ExpandKeyFsm := Initialization;
  signal StateCipherASE		: CipherAESFsm := Initialization;



---------------------------------------------------------------------------
-- CONSTANTS
---------------------------------------------------------------------------


begin

---------------------------------------------------------------------------
--
-- 4) ARCHITECTURE DEFINITION
--
---------------------------------------------------------------------------

---------------------------------------------------------------------------
-- COMPONENT INSTANCIATION: Registers
---------------------------------------------------------------------------

	---------------------------------------------------------------------------
	-- fsm 
	---------------------------------------------------------------------------
  PrimeAES_FSM: process (i_clk,i_rst_n)
    begin
      if i_rst_n = '0' then
      	StateFsmAES <= Initialization;

     	elsif rising_edge(i_clk) then
			case StateFsmAES is
		   	when Initialization =>
		   		StateFsmAES	<= KeyExpansion;

		   	when KeyExpansion =>
		   	 	StateFsmAES	<= CipherAES;

		   	when CipherAES =>
		   		StateFsmAES	<= Initialization;
		   		
				when others =>
            	StateFsmAES	<= Initialization;
        	end case;		   	 	
     end if;
end process PrimeAES_FSM;
	---------------------------------------------------------------------------
	-- Key generator for roundkeys 
	---------------------------------------------------------------------------

	---------------------------------------------------------------------------
	-- 4 SboxBlocks of 2 SboxM4K each for the single columns
	---------------------------------------------------------------------------

	---------------------------------------------------------------------------
	-- Shiftrow step (encryption datapath)
	---------------------------------------------------------------------------

	---------------------------------------------------------------------------
	-- mix column step
	---------------------------------------------------------------------------

	---------------------------------------------------------------------------
	-- Multiplexer for input to AddRoundKey, depending on round_type
	-- Initial round  "00":		directly feed data_in (data block)
	-- regular round  "01":		feed result from mix_column
	-- final round	  "10":		skip mixcolumn and feed result from shiftrow
	---------------------------------------------------------------------------

	---------------------------------------------------------------------------
	-- key addition (encrypt datapath)
	---------------------------------------------------------------------------


	---------------------------------------------------------------------------
	-- 4 SboxBlocks of 2 SboxM4K each for the single columns
	---------------------------------------------------------------------------

	---------------------------------------------------------------------------
	-- Shiftrow step (encryption datapath)
	---------------------------------------------------------------------------


---------------------------------------------------------------------------
-- PROCESS
---------------------------------------------------------------------------
AES256fsmFSM: process (i_clk,i_rst_n)
  begin
      
     	if i_rst_n = '0' then

     	elsif rising_edge(i_clk) then
			case StateExpander is
		   	when Initialization =>
		   		StateExpander	<= Mod8;
		   	when Mod8 =>
		   	 	StateExpander	<= Mod4;
		   	when Mod4 =>
		   	 	StateExpander	<= Filling;
		   	when Filling =>
		   		StateExpander	<= Initialization;
				when others =>
            	StateExpander	<= Initialization;
        	end case;		   	 	
     end if;
end process AES256fsmFSM;




CipherAESFSM: process (i_clk,i_rst_n)
  begin
      
     	if i_rst_n = '0' then

     	elsif rising_edge(i_clk) then
			case StateExpander is
		   	when Initialization =>
		   		StateExpander	<= FirstRoundKey;
		   	when FirstRoundKey =>
		   	 	StateExpander	<= Mod4;
		   	when Mod4 =>
		   	 	StateExpander	<= Filling;
		   	when Filling =>
		   		StateExpander	<= Initialization;
				when others =>
            	StateExpander	<= Initialization;
        	end case;		   	 	
     end if;
end process CipherAESFSM;

end rtl;