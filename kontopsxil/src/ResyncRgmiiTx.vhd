--   ----------------------------------------------------------------------------------------------
--   File    	          : ResyncRgmiiTx.vhd  
--   Auteur             : Benjamin DISSON
--   Date de creation	  : 09/06/2021
--   Version            : 1.0
--   Description        : RGMII tx signal resynchronization
--                        Instead of having ResyncRgmiiTx<3:0> and ResyncRgmiiTx_CTL as outputs, this module generates Tx_RISING<3:0>, Tx_FALLING<3:0>, Tx_CTL_RISING, and Tx_CTL_FALLING as outputs.
--   Sous module        : --
--   Modifications    
--   --------------------------------------------------------------------------
--   Date             	: Ver. 	 : Auteur       		: Commentaires
--   --------------------------------------------------------------------------
--   09/06/2021	        : 1.0    : Benjamin Disson  : Creation - Based on Xapp692
--

--             
--           |----------------------------------------------------------|
--           |______                                                    |
--           |     | GMII i_Clk 125 Mhz  ----> |------------------------|
--           | MAC | GMII transmit signals --> | RGMII transmit signals |
--           |     |                           |------------------------|
--           |------                                                    |
--           |----------------------------------------------------------|


-------------------------------------------------------------------------------
--  Library declaration
-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;										 			           
	
-------------------------------------------------------------------------------
--  Entity declaration
------------------------------------------------------------------------------- 
entity ResyncRgmiiTx is

  port(
      -- Global Asynchronous Reset
      i_Reset                  : in std_logic; 
      -- GMII i_Clk 125 Mhz
      i_Clk                    : in std_logic;  
	  
      -- RGMII transmit signals
      
      o_TxCtlRising    : out std_logic;     -- To pos clock reg of ODDR of TxCtl                       
      o_TxCtlFalling   : out std_logic;     -- To neg clock reg of ODDR of TxCtl                       
      o_TxDataRising       : out std_logic_vector(3 downto 0);  -- To pos clock reg of ODDR of Data       
      o_TxDataFalling      : out std_logic_vector(3 downto 0);   -- To neg clock reg of ODDR of Data

                     
      
      -- GMII transmit signals
      i_GmiiTxData               : in std_logic_vector(7 downto 0);    
      i_GmiiTxEn             : in std_logic;                       
      i_GmiiTxEr             : in std_logic
      );

end ResyncRgmiiTx;


architecture rtl of ResyncRgmiiTx is

-------------------------------------------------------------------------------
--  CONSTANT DECLARATION
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--  SIGNAL DECLARATION
-------------------------------------------------------------------------------   
   signal s_TxDataRising     : std_logic_vector(7 downto 0);    -- i_GmiiTxData<7:0> reclocked on rising edge
   --signal s_TxDataFalling   : std_logic_vector(7 downto 0);    -- s_TxDataRising<7:0> reclocked on falling edge 
   signal s_TxDataFalling   : std_logic_vector(3 downto 0); 
   signal s_TxEnRising   : std_logic;                -- TX_EN reclocked on rising edge         
   signal s_TxErRising   : std_logic;      -- TXERR Encoded TX_ERR reclocked on rising edge              
   signal s_TxErFalling  : std_logic;     -- TXERR Encoded TX_ERR on falling edge               

-- =======================================================================
begin

------------------------------------------------------------
--  RGMII Data Transmission                               --
------------------------------------------------------------
--------------------------------------------------------
-- Process
-- Desc: TXD Reclock inputs on the rising edge
--------------------------------------------------------
   ProcDataRising : process (i_Clk, i_Reset)
   begin

     if i_Reset = '1' then
       s_TxDataRising(7 downto 0)         <= (others => '0');
     elsif i_Clk'event and i_Clk = '1' then
       s_TxDataRising(7 downto 0)         <= i_GmiiTxData(7 downto 0);
     end if;

   end process ProcDataRising;
   
--------------------------------------------------------
-- Process
-- Desc: TXD Reclock data on the falling edge.  
--------------------------------------------------------
   ProcDataFalling : process (i_Clk, i_Reset)
   begin

     if i_Reset = '1' then
       --s_TxDataFalling(7 downto 0)       <= (others => '0');
       s_TxDataFalling(3 downto 0)       <= (others => '0');       
     elsif i_Clk'event and i_Clk = '0' then
       --s_TxDataFalling(7 downto 0)        <= s_TxDataRising(7 downto 0);
       s_TxDataFalling(3 downto 0)        <= s_TxDataRising(7 downto 4);       
     end if;

   end process ProcDataFalling;														

  
   o_TxDataRising(3 downto 0)         <= s_TxDataRising(3 downto 0);
   --o_TxDataFalling(3 downto 0)        <= s_TxDataFalling(7 downto 4);
   o_TxDataFalling(3 downto 0)        <= s_TxDataFalling(3 downto 0);

--------------------------------------------------------
-- Process
-- Desc: Reclock control inputs on the rising edge.  
--------------------------------------------------------
   ProcCtlRising : process (i_Clk, i_Reset)
   begin

     if i_Reset = '1' then
       s_TxEnRising    <= '0';
       s_TxErRising    <= '0';
     elsif i_Clk'event and i_Clk = '1' then
       s_TxEnRising    <= i_GmiiTxEn;
       s_TxErRising    <= i_GmiiTxEr XOR i_GmiiTxEn;
     end if;																		
   end process ProcCtlRising;														

   
--------------------------------------------------------
-- Process
-- Desc: Reclock control on the falling edge.  
--------------------------------------------------------
   ProcCtlFalling : process (i_Clk, i_Reset)
   begin

     if i_Reset = '1' then
       s_TxErFalling    <= '0';
     elsif i_Clk'event and i_Clk = '0' then
       s_TxErFalling    <= s_TxErRising;
     end if;

   end process ProcCtlFalling;		

--------------------------------------------------------
-- Assignation
-- Desc: GMII TX err & en => RGMII CTL  
--------------------------------------------------------   
   o_TxCtlRising          <= s_TxEnRising;
   o_TxCtlFalling         <= s_TxErFalling;

   
end rtl;

