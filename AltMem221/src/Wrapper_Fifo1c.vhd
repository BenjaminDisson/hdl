--   ----------------------------------------------------------------------------------------------
--   File name     : Wrapper_Fifo1c.vhd     
--   Description   : Wrapper made to standardize all kind of composant that   
--                 : can be instanciated     
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

entity Wrapper_Fifo1c is
    generic 
    (
        g_AddrSize              : integer := 8;
        g_DataSize              : integer := 8;                           
        g_AlmostFullLevel       : natural  := 2**8-1-6;                    
        g_AlmostEmptyLevel      : natural:= 6;                             
    );
    port 
    ( 
        i_clk               : in  std_logic;                   
        i_areset_n          : in  std_logic;                   
        i_sclr              : in  std_logic;                   
        i_WrData            : in  std_logic_vector(g_DataSize-1 downto 0); 
        i_WrReq             : in  std_logic;                     
        i_RdReq             : in  std_logic;                  
        o_RdData            : out std_logic_vector(g_DataSize-1 downto 0); 
        o_StatusFull        : out std_logic;                  
        o_StatusEmpty       : out std_logic;                  
        o_StatusAlmostFull  : out std_logic;                  
        o_StatusAlmostEmpty : out std_logic;                  
        o_StatusWordCounter : out std_logic_vector(g_AddrSize-1 downto 0)  
    );
end Wrapper_Fifo1c;

architecture Behavior of Wrapper_Fifo1c is
begin

  inst_AltMem221Fifo1c : AltMem221Fifo1c
    generic map
    (
        g_AddrSize              => g_AddrSize,
        g_DataSize              => g_DataSize,                          
        g_AlmostFullLevel       => g_AlmostFullLevel,                    
        g_AlmostEmptyLevel      => g_AlmostEmptyLevel,
        g_NbWords               => 256,        
        g_Device                => "Cyclone IV GX"    
    );
	PORT map
	(
		aclr		    => not(i_areset_n),
		clock		    => i_clk,
		data		    => i_WrData,
		rdreq		    => i_RdReq,
		sclr		    => not(i_areset_n),
		wrreq		    => i_WrReq,
		almost_empty	=> o_StatusAlmostEmpty,
		almost_full		=> o_StatusAlmostFull,
		empty		    => o_StatusEmpty,
		full		    => o_StatusFull,
		q		        => o_RdData,
		usedw		    => o_StatusWordCounter
	);

end Behavior;