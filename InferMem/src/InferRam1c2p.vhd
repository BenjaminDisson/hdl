--   ----------------------------------------------------------------------------------------------
--   File name     : Ram1c2p.vhd     
--   Description   : Double port ram with one clock for both ports  
--                 : There is no reset as an init would signify write accesss to each address     
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

  entity InferRam1c2p is
  generic(g_AddrSize      :  integer := 16;        
          g_DataSize      :  integer := 8 );     
  port(
      i_clk       : in std_logic;      
      i_WrAddress : in std_logic_vector(g_AddrSize-1 downto 0);                            
      i_WrEn      : in std_logic;                                
      i_WrData    : in std_logic_vector(g_DataSize-1 downto 0);
      i_RdAddress : in std_logic_vector(g_AddrSize-1 downto 0);  
      i_RdEn      : in std_logic;
      o_RdData    : out std_logic_vector(g_DataSize-1 downto 0));
end InferRam1c2p;



architecture Behavior of InferRam1c2p is
-------------------------------------------------------------------------------
--
-- Type 
--
-------------------------------------------------------------------------------
  type TYPE_RAM is array (2**g_AddrSize-1 downto 0) of std_logic_vector(g_DataSize-1 downto 0); -- Ram block defined as a table

-------------------------------------------------------------------------------
--
-- Signal
--
-------------------------------------------------------------------------------
  signal s_Ram         : TYPE_RAM ;    -- Instance of RAM
  

begin

-------------------------------------------------------------------------------
--
-- Process        : STORAGE
-- Type           : Synchronous
-- Description    : Write to the RAM
--
-------------------------------------------------------------------------------
STORAGE: process(i_clk)
  begin
    if rising_edge(i_clk) then
		  if i_WrEn = '1' then
        s_Ram(to_integer(unsigned(i_WrAddress))) <= i_WrData;
      end if;
    end if;
end process STORAGE ;


-------------------------------------------------------------------------------
--
-- Process	      : EXTRACT
-- Type           : Synchronous and registered
-- Description    : Read in the Ram
--
-------------------------------------------------------------------------------
EXTRACT: process(i_clk)
  begin
    if rising_edge(i_clk) then
      if i_RdEn = '1' then
        o_RdData <= s_Ram(to_integer(unsigned(i_RdAddress)));
      end if;
    end if;
end process EXTRACT ;
	

end Behavior;