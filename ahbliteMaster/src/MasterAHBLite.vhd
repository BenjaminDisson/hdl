--   ----------------------------------------------------------------------------------------------
--   Nom du fichier    	: MasterAHBLite.vhd  
--   Auteur             : Benjamin Disson
--   Date de creation	: 16/09/2020
--   Version            : 1.0
--   Description        : 
--   Sous module        : --
--   Modifications    
--   --------------------------------------------------------------------------
--   Date             	: Ver. 	: Auteur       		: Commentaires
--   --------------------------------------------------------------------------
--   16/09/2020	        : 1.0    : Benjamin Disson      : Creation
--
-------------------------------------------------------------------------------
--  Déclaration des bibliothèques
-------------------------------------------------------------------------------
library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MasterAHBLite is
generic(
		C_AhbAddrWidth : integer := 32;   --/ Width of address bus
     	C_AhbDataWidth: integer := 32    -- Width of data bus
	);
port(
    -- clock and reset signals
    i_UartIrq       : in std_logic; 
    HCLK            : in std_logic; 
    HRESETn         : in std_logic; 
	HADDR           : out std_logic_vector(C_AhbAddrWidth-1 downto 0);   
    HWRITE          : out std_logic;     --
    HSIZE           : out std_logic_vector(2 downto 0);   
    HBURST          : out std_logic_vector(2 downto 0);   
    HPROT           : out std_logic_vector(3 downto 0);   
    HTRANS          : out std_logic_vector(1 downto 0);   
    HMASTLOCK       : out std_logic;      
    HREADY          : in std_logic;          
    HRESP           : in std_logic;     
    HWDATA          : out std_logic_vector(C_AhbDataWidth-1 downto 0);
    HRDATA          : in std_logic_vector(C_AhbDataWidth-1 downto 0)
    );
end MasterAHBLite;

architecture rtl of MasterAHBLite is


-------------------------------------------------------------------------------
--  COMPONENT DECLARATION
-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
--  CONSTANT DECLARATION
-------------------------------------------------------------------------------
-- Command (C) - 0x43
-- Load (L) - 0x4C
-- Read (R) - 0x52
-- Init (I) - 0x49
-- Start (S) - 0x53

-------------------------------------------------------------------------------
--  SIGNAL DECLARATION
-------------------------------------------------------------------------------
        


signal s_TempoData : std_logic_vector(31 downto 0); 
signal s_ByteCounter : natural range 0 to 8;

-------------------------------------------------------------------------------
--  TYPE DECLARATION
-------------------------------------------------------------------------------
type t_AhbAccess is (s_wait, s_RDataUart, s_RIntergapUart,s_RIntergapUart2, s_WDataUart, s_WIntergapUart, s_WDataSkew, s_WIntergapSkew);
--signal s_ReadAccess : t_AhbAccess := t_AhbAccess;
--signal s_WriteAccess : t_AhbAccess := t_AhbAccess;
signal s_AHBAccess : t_AhbAccess := s_wait;

-- =======================================================================
begin

-------------------------------------------------------------------------------
--  COMPONENT INSTANCIATION
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--  ASSIGNMENT
-------------------------------------------------------------------------------

-- ------------------------------------------
-- Process
-- 
-- ------------------------------------------
--     
AHBAccessProcess: process(HRESETn,HCLK)
  begin
    if HRESETn = '0' then
    	s_AHBAccess <= s_wait;
        s_TempoData <= (others =>'1');
		s_ByteCounter <= 0;		
	elsif rising_edge(HCLK) then
		case s_AHBAccess is
			when s_wait =>
				if i_UartIrq = '1' then
        			s_AHBAccess <= s_RDataUart;
        		else 
        			s_AHBAccess <= s_wait;     
        		end if;

        	when s_RDataUart =>
        	    HADDR     <= x"00000003";
    			HWRITE    <= '0';   
    			HTRANS    <= "10";
    			HSIZE     <= "000";
    			HBURST    <= "000";
    			HPROT     <= "0101";
    			HMASTLOCK <= '0'; 
				s_ByteCounter <= s_ByteCounter +1 ;	
        		s_AHBAccess <= s_RIntergapUart;  		

			when s_RIntergapUart =>
        	    HADDR     <= x"00000003";
    			HWRITE    <= '0';   
    			HTRANS    <= "00";
    			HSIZE     <= "000";
    			HBURST    <= "000";
    			HPROT     <= "0101";
    			HMASTLOCK <= '0'; 
				--s_TempoData(31 downto 8) <= s_TempoData(23 downto 0);
				--s_TempoData(7 downto 0) <= HRDATA(7 downto 0);
				
				s_AHBAccess <= s_RIntergapUart2;
				
				
							--AJOUT--	
			when s_RIntergapUart2 =>
        	    HADDR     <= x"00000003";
    			HWRITE    <= '0';   
    			HTRANS    <= "00";
    			HSIZE     <= "000";
    			HBURST    <= "000";
    			HPROT     <= "0101";
    			HMASTLOCK <= '0'; 			
				s_TempoData(31 downto 8) <= s_TempoData(23 downto 0);
				s_TempoData(7 downto 0) <= HRDATA(7 downto 0);
				s_AHBAccess <= s_WDataUart;				
			--AJOUT--

        	when s_WDataUart =>
        	    HADDR     <= x"00000003";
    			HWRITE    <= '1';   
    			HTRANS    <= "10";			
    			HWDATA    <= x"000000" & s_TempoData(7 downto 0);
				--HWDATA    <= x"000000" & x"AA";
    			HSIZE     <= "000";
    			HBURST    <= "000";
    			HPROT     <= "0101";
    			HMASTLOCK <= '0'; 
							
        		s_AHBAccess <= s_WIntergapUart;  		

			when s_WIntergapUart =>
        	    HADDR     <= x"00000003";
    			HWRITE    <= '0';   
    			HTRANS    <= "00";
    			HSIZE     <= "000";
    			HBURST    <= "000";
    			HPROT     <= "0101";
    			HMASTLOCK <= '0'; 

				if (s_ByteCounter > 3) then		
					s_AHBAccess <= s_WDataSkew;
				else
					s_AHBAccess <= s_wait;
				end if;				
				

        	when s_WDataSkew =>
        	    HADDR     <= x"00000004";
    			HWRITE    <= '1';   
    			HTRANS    <= "10";			
    			HWDATA    <= s_TempoData;
				--HWDATA    <= x"000000" & x"AA";
    			HSIZE     <= "000";
    			HBURST    <= "000";
    			HPROT     <= "0101";
    			HMASTLOCK <= '0'; 
				s_ByteCounter <= 0;
        		s_AHBAccess <= s_WIntergapSkew;  		

			when s_WIntergapSkew =>
        	    HADDR     <= x"00000004";
    			HWRITE    <= '0';   
    			HTRANS    <= "00";
    			HSIZE     <= "000";
    			HBURST    <= "000";
    			HPROT     <= "0101";
    			HMASTLOCK <= '0'; 			
				s_AHBAccess <= s_wait;
           
        	when others =>
				s_AHBAccess <= s_wait;

		end case;	

	end if;
  end process AHBAccessProcess;
end rtl;
