--   ----------------------------------------------------------------------------------------------
--   File name     : Ram1c1p.vhd     
--   Description   : Single port ram with one clock   
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

  entity InferRam1c1p is
  generic(g_AddrSize      :  integer := 16;        
          g_DataSize      :  integer := 8 );     
  port(
      i_clk       : in std_logic;      
      i_WrAddress : in std_logic_vector(g_AddrSize-1 downto 0);                            
      i_WrEn      : in std_logic;                                
      i_WrData    : in std_logic_vector(g_DataSize-1 downto 0);
      o_RdData    : out std_logic_vector(g_DataSize-1 downto 0));
end InferRam1c1p;



architecture Behavior of InferRam1c1p is
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
-- Description    : Read / Write from / to the RAM
--
-------------------------------------------------------------------------------
STORAGE: process(i_clk)
  begin
    if rising_edge(i_clk) then
		  if i_WrEn = '1' then
        s_Ram(to_integer(unsigned(i_WrAddress))) <= i_WrData;
      else
        o_RdData <= s_Ram(to_integer(unsigned(i_WrAddress)));
      end if;
    end if;
end process STORAGE ;



end Behavior;