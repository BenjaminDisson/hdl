--   ----------------------------------------------------------------------------------------------
--   File    	        : SyncReset.vhd  
--   Auteur             : Benjamin DISSON
--   Date de creation	: 09/06/2021
--   Description: This reset synchronizer was derived from:
--              http://www.xilinx.com/support/techxclusives/global-techX19.htm
--              It is used to generate a reset signal which has a falling edge
--              synchronous with i_Clk; this allows predictable reset recovery
--              even using the asynchronous reset pins of register primitives
--   Sous module        : --
--   Modifications    
--   --------------------------------------------------------------------------
--   Date             	: Ver. 	: Auteur       		: Commentaires
--   --------------------------------------------------------------------------
--   09/06/2021	      : 1.0    : Benjamin Disson      : Creation - Based on Xapp692


-------------------------------------------------------------------------------
--  Library declaration
-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;										 			           
	
-------------------------------------------------------------------------------
--  Entity declaration
------------------------------------------------------------------------------- 
entity SyncReset is
  
  port (
    i_Reset  : in  std_logic;          -- Active high asynchronous reset
    i_Clk       : in  std_logic;          -- clock to be sync'ed to
    o_Reset : out std_logic);         -- "Synchronised" reset signal

end SyncReset;


architecture rtl of SyncReset is

-------------------------------------------------------------------------------
--  CONSTANT DECLARATION
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--  SIGNAL DECLARATION
-------------------------------------------------------------------------------
signal s_ResetR, s_ResetRR, s_ResetRRR : std_logic;

-- =======================================================================
begin

  -- Synchroniser process. In this case, 4 registers should pack into 2 slices.
  ProcSyncReset : process (i_Clk, i_Reset)
  begin
    if i_Reset = '1' then
      s_ResetR <= '1';
      s_ResetRR <= '1';
      s_ResetRRR <= '1';
      o_Reset <= '1';
    elsif i_Clk'event and i_Clk = '1' then
      s_ResetR <= '0';
      s_ResetRR <= s_ResetR;
      s_ResetRRR <= s_ResetRR;
      o_Reset <= s_ResetRRR;
    end if;
  end process ProcSyncReset;


end rtl;
