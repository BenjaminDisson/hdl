--   ----------------------------------------------------------------------------------------------
--   Nom du fichier    	: FrameReceiverUdpIp.vhd  
--   Auteur             : Benjamin Disson
--   Date de creation	: 21/01/2022
--   Version            : 1.0
--   Description        : Reception of frame
--   Sous module        : Aucun
--   Modifications    
--   ----------------------------------------------------------------------------------------------
--   Date             	: Ver. 	: Auteur       		: Commentaires
--   ----------------------------------------------------------------------------------------------
--   21/01/2022	      : 1.0   : Benjamin Disson  	: Creation 


-------------------------------------------------------------------------------
--  Déclaration des bibliothèques
-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;   

-- ============================================================================

entity  FrameReceiverUdpIp  is
port ( 	
    -- Horloges et Resets 
    i_sys_clk_tx   : in  std_logic;                        -- Horloge système              
    i_arst_n       : in  std_logic;                        -- Reset matériel  

	-- Protocol launch
	o_Run       : out std_logic;
	
	i_Rxd          : in std_logic_vector(7 downto 0);     -- Données de sortie
	i_RxEn 		   : in std_logic                         -- Signal valid
	);	
end FrameReceiverUdpIp;

architecture  rtl  of  FrameReceiverUdpIp  is
-------------------------------------------------------------------------------
--  COMPONENT DECLARATION
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--  CONSTANT DECLARATION
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--  TYPE DECLARATION
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--  SIGNAL DECLARATION
-------------------------------------------------------------------------------
  signal s_Rxd_tmp          : std_logic_vector(7 downto 0);
  signal s_RxEn_tmp         : std_logic;
  signal s_DebugDataMov     : std_logic;

  attribute S:string;
  attribute S of s_DebugDataMov : signal is "TRUE";
  attribute keep : string;
  attribute keep of s_DebugDataMov : signal is "true";


begin
-------------------------------------------------------------------------------
--  COMPONENT INSTANTATION
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--  ARCHITECTURE DEFINITION
-------------------------------------------------------------------------------
    -------------------------------------
    -- PROCESS synchronous
    -- Desc: make a tamporisation
    --        
    ------------------------------------- 
    ProcTempo : process(i_arst_n , i_sys_clk_tx )
    begin
        if i_arst_n = '0' then
            s_Rxd_tmp  <= (others =>'0');
            s_RxEn_tmp <= '0';            
        elsif rising_edge (i_sys_clk_tx) then
            s_Rxd_tmp   <= i_Rxd;
            s_RxEn_tmp  <= i_RxEn;
        end if;
    end process ProcTempo;


    -------------------------------------
    -- PROCESS synchronous
    -- Desc: Synchronisation de la 
    --       machine à état   
    -------------------------------------        
    ProcLaunch : process (i_arst_n,i_sys_clk_tx)
    begin
        if (i_arst_n = '0') then
			o_Run        <= '0';
            s_DebugDataMov  <= '0';
        elsif rising_edge(i_sys_clk_tx) then
            -- rising front detection
            if s_RxEn_tmp = '0' and i_RxEn = '1' then
                o_Run <= '1';
            else
                o_Run <= '0';
            end if;
            
            --Debug
            if (i_RxEn = '1' ) then --and (s_Rxd_tmp(1) xor i_Rxd(1) = '1')  then
                s_DebugDataMov <= '1';
            else
                s_DebugDataMov <= '0';
            end if;
        end if;
    end process ProcLaunch;
    
end rtl;


