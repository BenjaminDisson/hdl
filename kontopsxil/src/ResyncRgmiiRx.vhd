--   ----------------------------------------------------------------------------------------------
--   File    	          : ResyncRgmiiRx.vhd  
--   Auteur             : Benjamin DISSON
--   Date de creation	  : 14/01/2022
--   Version            : 1.0
--   Description        : RGMII rx signal resynchronization
--                        Description: The module takes the data and control latched on the rising
--                        and falling edge of the clock and "unfold" it to the standard 
--                        GMII interface.
--
--                      1. The module takes the following as inputs:
--                      RGMII_RX_CTL_RISING, RGMII_RX_CTL_FALLING, RGMII_RXD_RISING, 
--                      RGMII_RXD_FALLING where XXX_RISING is data latched on the 
--                      rising edge of the clock and XXX_FALLING is the data latched 
--                      on the falling edge of the clock.  These signals are outputs 
--                      of the FDDRRSE, an double data rate input register to be 
--                      instantiated at the top level.
--
--                      2. RXD of RGMII is a 4 bit bus which needs to be 
--                      unfolded into the 8 bit GMII bus.   RXD<3:0> are latched 
--                      on the rising edge of the clock while RXD<7:4> are latched 
--                      on the falling edge.  The resulting 8 bit is sent to GMII 
--                      at 125Mhz.
-- 
--   Sous module        : --
--   Modifications    
--   --------------------------------------------------------------------------
--   Date             	: Ver. 	 : Auteur       		: Commentaires
--   --------------------------------------------------------------------------
--   09/06/2021	        : 1.0    : Benjamin Disson  : Creation - Based on Xapp692 (Ting Kao)
--

--             
--           |----------------------------------------------------------|
--           |______                                                    |
--           |     | o_GmiiRxData  <---- |------------------------|     |
--           | MAC | o_GmiiRxEn    <---- | RGMII received signals |     |
--           |     | o_GmiiRxEr    <---- | RGMII i_Clk 125 Mhz|   |     |
--           |     |                      ------------------------|     |
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
entity ResyncRgmiiRx is

  port(
      -- Global Asynchronous Reset
      i_Reset                  : in std_logic; 
      -- RGMII i_Clk 125 Mhz
      i_Clk                    : in std_logic;  
	  
      -- RGMII transmit signals
      
      i_RxCtlRising           : in std_logic;                     -- Receive from ODDR rgmii_port_x_rx_ctl                       
      i_RxCtlFalling          : in std_logic;                     -- Receive from ODDR rgmii_port_x_rx_ctl                      
      i_RxDataRising          : in std_logic_vector(3 downto 0);  -- Receive from ODDR rgmii_port_x_rd       
      i_RxDataFalling         : in std_logic_vector(3 downto 0);  -- Receive from ODDR rgmii_port_x_rd
                     
      
      -- GMII transmit signals
      o_GmiiRxData            : out std_logic_vector(7 downto 0);    
      o_GmiiRxEn              : out std_logic;                       
      o_GmiiRxEr              : out std_logic
      );

end ResyncRgmiiRx;


architecture rtl of ResyncRgmiiRx is

-------------------------------------------------------------------------------
--  CONSTANT DECLARATION
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--  SIGNAL DECLARATION
-------------------------------------------------------------------------------   
  signal s_GmiiRxData            : std_logic_vector(7 downto 0);
  signal s_GmiiRxData_r          : std_logic_vector(7 downto 0);
  signal s_GmiiRxEn              : std_logic;
  signal s_GmiiRxEn_r            : std_logic;
  signal s_GmiiRxErr             : std_logic;
  signal s_GmiiRxErr_r           : std_logic;

-- =======================================================================
begin

--*******************************************
--*                                         *
--*           RGMII Data Reception          *                     
--*                                         *
--*******************************************
--------------------------------------------------------
-- Process
-- Desc: RxD Reclock inputs on the rising edge
--------------------------------------------------------
   ProcDataRising : process (i_Clk, i_Reset)
   begin

     if i_Reset = '1' then
       s_GmiiRxData(3 downto 0)         <= (others => '0');
     elsif i_Clk'event and i_Clk = '1' then
       s_GmiiRxData(3 downto 0)         <= i_RxDataRising(3 downto 0);
     end if;

   end process ProcDataRising;
   
--------------------------------------------------------
-- Process
-- Desc: RxD Reclock data on the falling edge.  
--------------------------------------------------------
   ProcDataFalling : process (i_Clk, i_Reset)
   begin

     if i_Reset = '1' then
       s_GmiiRxData(7 downto 4)       <= (others => '0');       
     elsif i_Clk'event and i_Clk = '0' then
       s_GmiiRxData(7 downto 4)        <= i_RxDataFalling(3 downto 0);       
     end if;

   end process ProcDataFalling;														


--------------------------------------------------------
-- Process
-- Desc: synchronize data on rising edge of clock.
--------------------------------------------------------
   ProcDataResync : process (i_Clk, i_Reset)
   begin

     if i_Reset = '1' then
       s_GmiiRxData_r(7 downto 0)       <= (others => '0');       
     elsif i_Clk'event and i_Clk = '0' then
       s_GmiiRxData_r(7 downto 0)        <= s_GmiiRxData(7 downto 0);       
     end if;

   end process ProcDataResync; 
-- =======================================================================



--*******************************************
--*                                         *
--*         RGMII Control Reception         *                     
--*                                         *
--*******************************************
--------------------------------------------------------
-- Process
-- Desc: Reclock control(Ctl) inputs on the rising edge.  
--------------------------------------------------------
   ProcCtlRising : process (i_Clk, i_Reset)
   begin

     if i_Reset = '1' then
       s_GmiiRxEn    <= '0';
     elsif i_Clk'event and i_Clk = '1' then
       s_GmiiRxEn    <= i_RxCtlRising;
     end if;																		
   end process ProcCtlRising;														

   
--------------------------------------------------------
-- Process
-- Desc: Reclock control (Err) on the falling edge.  
--------------------------------------------------------
   ProcErrFalling : process (i_Clk, i_Reset)
   begin

     if i_Reset = '1' then
       s_GmiiRxErr    <= '0';
     elsif i_Clk'event and i_Clk = '0' then
       s_GmiiRxErr    <= i_RxCtlFalling;
     end if;

   end process ProcErrFalling;		



--------------------------------------------------------
-- Process
-- Desc: Reclock control(Ctl and Err) inputs on the rising edge.  
--------------------------------------------------------
   ProcCtlAndErrRising : process (i_Clk, i_Reset)
   begin

     if i_Reset = '1' then
       s_GmiiRxEn_r    <= '0';
       s_GmiiRxErr_r    <= '0';
     elsif i_Clk'event and i_Clk = '1' then
       s_GmiiRxEn_r     <= s_GmiiRxEn;
       s_GmiiRxErr_r    <= s_GmiiRxErr;
     end if;                                    
   end process ProcCtlAndErrRising; 

--------------------------------------------------------
-- Process
-- Desc: Generate Err sigal and final resync through output GMII  
--------------------------------------------------------   
   ProcOutput : process (i_Clk, i_Reset)
   begin

     if i_Reset = '1' then
        o_GmiiRxData  <= (others => '0');
        o_GmiiRxEn    <= '0';
        o_GmiiRxEr    <= '0';

     elsif i_Clk'event and i_Clk = '1' then
        o_GmiiRxData  <= s_GmiiRxData_r;
        o_GmiiRxEn    <= s_GmiiRxEn_r;
        o_GmiiRxEr    <= s_GmiiRxErr_r xor s_GmiiRxEn_r;
     end if;                                    
   end process ProcOutput;

   
end rtl;

