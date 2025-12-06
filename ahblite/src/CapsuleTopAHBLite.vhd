--   ----------------------------------------------------------------------------------------------
--   Nom du fichier    	: CapsuleTopAHBLite.vhd  
--   Auteur             : Benjamin Disson
--   Date de creation	: 16/09/2020
--   Version            : 1.0
--   Description        : 
--   Sous module        : --
--   Modifications    
--   --------------------------------------------------------------------------
--   Date             	: Ver. 	: Auteur       		: Commentaires
--   --------------------------------------------------------------------------
--   16/09/2020	      : 1.0    : Benjamin Disson      : Creation
--
-------------------------------------------------------------------------------
--  Déclaration des bibliothèques
-------------------------------------------------------------------------------
library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CapsuleTopAHBLite is
generic(   
    C_SlaveNumber : integer := 2    
);
port(
    -- clock and reset signals
    -- i_areset_n      : in std_logic;
    -- i_clk           : in std_logic; -- 50Mhz
    -- i_UartRx        : in std_logic;  --// Input from RS-232 
    -- o_UartTx        : out std_logic -- // Output to RS-232 
  
	

    HCLK:       in std_logic;
    HRESETn:    in std_logic;
    HADDR:      in std_logic_vector(31 downto 0);
    HSEL01:     out std_logic;
    HSEL02:     out std_logic;
    HRDATA01:   in std_logic_vector(31 downto 0);
    HRESP01:    in std_logic;
    HREADYOUT01:in std_logic; 
    HRDATA02:   in std_logic_vector(31 downto 0);
    HRESP02:    in std_logic;
    HREADYOUT02:in std_logic;
    HRDATA:     out std_logic_vector(31 downto 0);
    HRESP:      out std_logic;
    HREADY:		out std_logic
    );
end CapsuleTopAHBLite;

architecture rtl of CapsuleTopAHBLite is

-------------------------------------------------------------------------------
--  COMPONENT DECLARATION
-------------------------------------------------------------------------------
component AHBLite is
generic(   
    C_SlaveNumber : integer := 2    
);
port(
    -- clock and reset signals
    -- i_areset_n      : in std_logic;
    -- i_clk           : in std_logic; -- 50Mhz
    -- i_UartRx        : in std_logic;  --// Input from RS-232 
    -- o_UartTx        : out std_logic -- // Output to RS-232 
  
	

    HCLK:       in std_logic;
    HRESETn:    in std_logic;
    HADDR:      in std_logic_vector(31 downto 0);
    HSEL01:     out std_logic;
    HSEL02:     out std_logic;
    HRDATA01:   in std_logic_vector(31 downto 0);
    HRESP01:    in std_logic;
    HREADYOUT01:in std_logic; 
    HRDATA02:   in std_logic_vector(31 downto 0);
    HRESP02:    in std_logic;
    HREADYOUT02:in std_logic;
    HRDATA:     out std_logic_vector(31 downto 0);
    HRESP:      out std_logic;
    HREADY:     out std_logic
    );
end component AHBLite;


-- ===========================================================================
-- == Constant declaration
-- ===========================================================================


-- ===========================================================================
-- == Type declaration
-- ===========================================================================

-- ===========================================================================
-- == Signals declaration
-- =========================================================================== 

begin


-------------------------------------------------------------------------------
--  COMPONENT INSTANCIATION
-------------------------------------------------------------------------------
inst_AHBLite : AHBLite
generic map(C_SlaveNumber=> 2)
port map( 
  HCLK,       
  HRESETn,    
  HADDR,      
  HSEL01,     
  HSEL02,     
  HRDATA01,   
  HRESP01,    
  HREADYOUT01,
  HRDATA02,   
  HRESP02,    
  HREADYOUT02,
  HRDATA,     
  HRESP,      
  HREADY		
); 

  
-- ===========================================================================
-- == Process 
-- =========================================================================== 

  

end rtl; 

