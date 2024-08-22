--   ----------------------------------------------------------------------------------------------
--   File name     : Wrapper_Ram1c1p.vhd     
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

entity Wrapper_Ram1c1p is
  generic(g_DataSize        : integer := 8 ;      
          g_AddrSize        : integer := 8 );      
  port(
        i_areset_n    : in std_logic  := '0'; 
        i_clk         : in std_logic;    
        i_WrAddress   : in std_logic_vector(g_AddrSize-1 downto 0); 
        i_WrEn        : in std_logic;                                                 
        i_WrData      : in std_logic_vector(g_DataSize-1 downto 0); 
        o_RdData      : out std_logic_vector(g_DataSize-1 downto 0)
    );
end Wrapper_Ram1c1p;

architecture Behavior of Wrapper_Ram1c1p is
begin

  inst_InterRam1c1p : InterRam1c1p
    generic map(
        g_AddrSize  => g_AddrSize,
        g_DataSize  => g_DataSize
        )
    port map
    ( 
--    i_areset_n  => i_areset_n,    -- Care, this standard pin is not in the infer Ram
    i_clk       => i_clk,            
    i_WrAddress => i_WrAddress,      
    i_WrEn      => i_WrEn,           
    i_WrData    => i_WrData,                   
    o_RdData    => o_RdData             
    );


end Behavior;