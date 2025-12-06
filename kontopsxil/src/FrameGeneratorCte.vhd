--   ----------------------------------------------------------------------------------------------
--   Nom du fichier    	: FrameGeneratorCte.vhd  
--   Auteur             : Benjamin Disson
--   Date de creation	: 21/09/2016
--   Version            : 1.0
--   Description        : Génération de données de remplissage pour une trame Ethernet utilisant une Constante
--   Sous module        : Aucun
--   Modifications    
--   ----------------------------------------------------------------------------------------------
--   Date             	: Ver. 	: Auteur       		: Commentaires
--   ----------------------------------------------------------------------------------------------
--   21/09/2016	        : 1.0   : Benjamin Disson  	: Creation 
--	 09/04/2018	        : 2.0   : Amrine Goulamaly 	: Tx data on 4 bits
--   05/06/2021         : 3.0   : Benjamin Disson  	: Different version MII, GMII
--   11/01/2022         : 4.0   : Benjamin Disson   : RGMII - use a Full constante frame from preambule to CRC 

-------------------------------------------------------------------------------
--  Déclaration des bibliothèques
-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;   

-- ============================================================================

entity  FrameGeneratorCte  is
port ( 	
    -- Clock et Reset
    i_sys_clk_tx    : in  std_logic;                        -- Susyem Clock              
    i_arst_n        : in  std_logic;                        -- Asynchronous reset  
    
    i_Run           : in std_logic;
    -- Data out
	o_Tx            : out std_logic_vector(7 downto 0);     -- Data
	o_TxEn 		    : out std_logic                         -- Valid signal
	);	
end FrameGeneratorCte;

architecture  rtl  of  FrameGeneratorCte  is
-------------------------------------------------------------------------------
--  COMPONENT DECLARATION
-------------------------------------------------------------------------------
-- None
-------------------------------------------------------------------------------
--  CONSTANT DECLARATION
-------------------------------------------------------------------------------
CONSTANT C_FRAME_MAX_SIZE : integer := 1000;
CONSTANT C_FULLFRAME : std_logic_vector(575 downto 0) := x"55555555555555D50010A47BEA8000123456789008004500002EB3FE000080110540C0A8002CC0A8000404000400001A2DE8000102030405060708090A0B0C0D0E0F1011B331881B";
--55555555555555D5
--0010A47BEA80
--001234567890
--0800
--4500002EB3FE000080
--11
--0540
--C0A8002C
--C0A80004
--0400
--0400
--001A
--2DE8
--000102030405060708090A0B0C0D0E0F1011
--B331881B
-------------------------------------------------------------------------------
--  TYPE DECLARATION
-------------------------------------------------------------------------------
type   T_FRAME_SENDING is (WaitToBegin, SendFullFrame, WaitForIFG); 
signal StateCurrent : T_FRAME_SENDING;

-------------------------------------------------------------------------------
--  SIGNAL DECLARATION
-------------------------------------------------------------------------------
signal s_BitCounter 		: natural range C_FRAME_MAX_SIZE downto 0;-- Counter to pass through the different frame phases

-- PRE = 7 octets
-- SOF = 1 octet
-- DA  = 6 octets
-- SA  = 6 octets
-- TYP = 2 octets
-- PAY = 46 octes
-- CRC = 4 octets
-- IFG = 12 octets
-- = 72 + 12 (IFG) = 84
-- + 916 of separation 


begin
-------------------------------------------------------------------------------
--  COMPONENT INSTANTATION
-------------------------------------------------------------------------------
-- None
-------------------------------------------------------------------------------
--  ARCHITECTURE DEFINITION
-------------------------------------------------------------------------------
    -------------------------------------
    -- PROCESS synchronous
    -- Desc: Incrementation de s_BitCounter 
    --       et remise a zero   
    ------------------------------------- 
    ProcCountIncr : process(i_arst_n , i_sys_clk_tx )
    begin
        if i_arst_n = '0' then
            s_BitCounter <= 0;
        elsif rising_edge (i_sys_clk_tx) then
            if s_BitCounter = C_FRAME_MAX_SIZE and i_Run = '1' then 
                s_BitCounter <= 0 ;
            elsif  s_BitCounter = C_FRAME_MAX_SIZE and i_Run = '0' then 
                s_BitCounter <= C_FRAME_MAX_SIZE ;
            else
                s_BitCounter <= s_BitCounter + 1;
            end if;
        end if;
    end process ProcCountIncr;


    -------------------------------------
    -- PROCESS synchronous
    -- Desc: Synchronisation de la 
    --       machine à état   
    -------------------------------------        
    ProcSendFSM : process (i_arst_n,i_sys_clk_tx)
    begin
        if (i_arst_n = '0') then
            o_Tx    <= (others =>'0');
            o_TxEn  <= '0';       
            StateCurrent <= WaitToBegin;
                                        
        elsif rising_edge(i_sys_clk_tx) then
            case StateCurrent is
                when WaitToBegin =>
                    o_Tx    <= (others =>'0');
                    o_TxEn  <= '0';
                    if i_Run = '1' then
                        StateCurrent <= SendFullFrame;
                    else
                        StateCurrent <= WaitToBegin;
                    end if;
                 
				when SendFullFrame =>
				    o_Tx    <= C_FULLFRAME((575-(s_BitCounter*8)) downto (568-(s_BitCounter*8)));
                    o_TxEn  <= '1';	

				if s_BitCounter = 71 then
				    StateCurrent <= WaitForIFG;
				else
				    StateCurrent <= SendFullFrame;
				end if;             
				
				
                when WaitForIFG => 
                    o_Tx    <= (others =>'0');
                    o_TxEn  <= '0';
                    if s_BitCounter = C_FRAME_MAX_SIZE and i_Run = '0' then 
                        StateCurrent <= WaitToBegin;
                    elsif s_BitCounter = C_FRAME_MAX_SIZE and i_Run = '1' then 
                        StateCurrent <= SendFullFrame;
                    else
                        StateCurrent <= WaitForIFG;
                    end if; 
                
                when others =>
                    StateCurrent <= WaitToBegin;
            
            end case;
        
        end if;
    end process ProcSendFSM;
end rtl;


