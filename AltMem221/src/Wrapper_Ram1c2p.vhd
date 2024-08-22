--   ----------------------------------------------------------------------------------------------
--   File name     : Wrapper_Ram1c2p.vhd     
--   Description   : Wrapper made to standardize all kind of composant that   
--                 : can be instanciated or inferred     
--   ----------------------------------------------------------------------------------------------
--   Modifications    
--   ----------------------------------------------------------------------------------------------
--   Date       : Ver.  : Author           : Comments
--   ---------------------------------------------------------------------------------------------- 
--   01/01/2009 : 1.0   : Benjamin Disson  : Creation
--
--
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

use work.AltMem221_pkg.all;

entity Wrapper_Ram1c2p is
  generic(g_DataSize        : integer := 8 ;      
          g_AddrSize        : integer := 8 );      
  port(
        i_areset_n    : in std_logic  := '0'; 
        i_clk         : in std_logic;    
        i_WrAddress   : in std_logic_vector(g_AddrSize-1 downto 0); 
        i_WrEn        : in std_logic;                                                 
        i_WrData      : in std_logic_vector(g_DataSize-1 downto 0); 
        i_RdAddress   : in std_logic_vector(g_AddrSize-1 downto 0);                       
        i_RdEn        : in std_logic;
        o_RdData      : out std_logic_vector(g_DataSize-1 downto 0)
    );
end Wrapper_Ram1c2p;

architecture Behavior of Wrapper_Ram1c2p is
begin

  inst_AltMem221Ram1c2p : AltMem221Ram1c2p
    generic map
    (
        g_AddrSize => g_AddrSize,
        g_NbWords  => 2** g_AddrSize, -- It cans be change if g_NbWords < (2** g_AddrSize)
        g_DataSize => g_DataSize,
        g_Device   => "Cyclone IV GX"
        );
	port map
	(
		clock		 => i_clk,
		data		 => i_WrData,
		rdaddress	 => i_RdAddress,
		rden		 => i_RdEn,
		wraddress	 => i_WrAddress,
		wren		 => i_WrEn,  
		q		     => o_RdData 
	);
    

end Behavior;