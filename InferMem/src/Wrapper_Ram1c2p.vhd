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

use work.InferMem_pkg.all;

entity Wrapper_Ram1c2p is
  generic(g_AsyncReset    : boolean := False;
          g_SyncReset     : boolean := False;
          g_AddrSize      : integer := 16 ;      
          g_DataSize      : integer := 8
          );       
  port(
        i_areset_n    : in std_logic  := '1'; -- Not used here
        i_sreset      : in std_logic  := '0'; -- Not used here 
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

  inst_InferRam1c2p : InferRam1c2p
    generic map(
        g_AddrSize  => g_AddrSize,
        g_DataSize  => g_DataSize
        )
    port map
    ( 
    i_clk       => i_clk,            
    i_WrAddress => i_WrAddress,      
    i_WrEn      => i_WrEn,           
    i_WrData    => i_WrData,         
    i_RdAddress => i_RdAddress,      
    i_RdEn      => i_RdEn,           
    o_RdData    => o_RdData             
    );


end Behavior;