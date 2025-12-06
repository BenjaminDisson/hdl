--   ----------------------------------------------------------------------------------------------
--   File    	        : RgmiiAdaptator.vhd  
--   Auteur             : Benjamin DISSON
--   Date de creation	: 09/06/2021
--   Version            : 1.0
--   Description        : Map the different adaptator 
--                      : Why does this file exist : because it aim at group TX and RX and the different option (Collision, Mode half duplex, Throughput and other signal like led)
--                      : For now, we use 1 thoughput, full duplex -> only point are now RX and TX
--   Sous module        : RgmiiTx + SyncReset
--   Modifications    
--   --------------------------------------------------------------------------
--   Date             	: Ver. 	: Auteur       		: Commentaires
--   --------------------------------------------------------------------------
--   09/06/2021	      : 1.0    : Benjamin Disson      : Creation - Based on Xapp692
--   xx/06/2021       : 2.0    : Benjamin Disson      : Add RX
--

-------------------------------------------------------------------------------
--  Library declaration
-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;										 			           
	
-------------------------------------------------------------------------------
--  Entity declaration
------------------------------------------------------------------------------- 

entity RgmiiAdaptator is
  port (
    i_Reset            : in  std_logic; -- Global Asynchronous Reset     
    i_Clk              : in  std_logic; -- GMII clock 125Mhz
	
    -- --------------------
    -- Trnasmit interface -
    -- --------------------
    -- RGMII Interface   
    o_TxCtlRising     : out std_logic;               
    o_TxCtlFalling    : out std_logic;                      
    o_TxDataRising    : out std_logic_vector(3 downto 0);   
    o_TxDataFalling   : out std_logic_vector(3 downto 0);

    
	-- GMII Interface 
    i_GmiiTxData      : in  std_logic_vector(7 downto 0);  
    i_GmiiTxEn        : in  std_logic;      
    i_GmiiTxEr        : in  std_logic;


    -- -------------------
    -- Receive interface -
    -- -------------------

    i_rgmii_port_xx_rxc     : in std_logic;  --rgmii_port_xx_rxc
    i_RxCtlRising           : in std_logic;                                       
    i_RxCtlFalling          : in std_logic;                                      
    i_RxDataRising          : in std_logic_vector(3 downto 0);  
    i_RxDataFalling         : in std_logic_vector(3 downto 0);  
    o_GmiiRxData            : out std_logic_vector(7 downto 0); 
    o_GmiiRxEn              : out std_logic;                    
    o_GmiiRxEr              : out std_logic
    );
  
end RgmiiAdaptator;

architecture rtl of RgmiiAdaptator is
-------------------------------------------------------------------------------
--  CONSTANT DECLARATION
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--  COMPONENT DECLARATION
------------------------------------------------------------------------------- 
  component SyncReset
    port (
      i_Reset : in  std_logic;
      i_Clk   : in  std_logic;
      o_Reset : out std_logic
	  );
  end component;

component ResyncRgmiiTx
    port(
      i_Reset             : in  std_logic;                       
      i_Clk               : in  std_logic;     -- GMII i_Clk 125 Mhz  
      o_TxCtlRising       : out std_logic;                      
      o_TxCtlFalling      : out std_logic;                      
      o_TxDataRising      : out std_logic_vector(3 downto 0);   
      o_TxDataFalling     : out std_logic_vector(3 downto 0);      
      i_GmiiTxData        : in  std_logic_vector(7 downto 0);    
      i_GmiiTxEn          : in  std_logic;                       
      i_GmiiTxEr          : in  std_logic    
      );
  end component;  
  
component ResyncRgmiiRx 
  port(
      i_Reset                 : in std_logic; 
      i_Clk                   : in std_logic;  --rgmii_port_xx_rxc
      i_RxCtlRising           : in std_logic;                                       
      i_RxCtlFalling          : in std_logic;                                      
      i_RxDataRising          : in std_logic_vector(3 downto 0);  
      i_RxDataFalling         : in std_logic_vector(3 downto 0);  
      o_GmiiRxData            : out std_logic_vector(7 downto 0); 
      o_GmiiRxEn              : out std_logic;                    
      o_GmiiRxEr              : out std_logic
      );
end component;

  -----------------------------------------------------------------------------
  -- SIGNAL DECLARATION 
  -----------------------------------------------------------------------------
  signal s_GmiiTxRst        : std_logic; -- Resync Tx Reset
  signal s_GmiiRxRst        : std_logic; -- Resync Tx Reset    
  
begin
  -----------------------------------------------------------------------------
  -- COMPONENT INSTANCIATION
  -----------------------------------------------------------------------------
--*******************************************
--*                                         *
--*           RGMII Transmission            *                     
--*                                         *
--*******************************************
    SyncResetTx_inst: SyncReset
    port map (
      i_Reset   => i_Reset,
      i_Clk     => i_Clk,
      o_Reset   => s_GmiiTxRst
	  );

  
	  
  ResyncRgmiiTx_inst : ResyncRgmiiTx
    port map (
      i_Reset                     => s_GmiiTxRst,
      i_Clk                       => i_Clk,
      o_TxCtlRising               => o_TxCtlRising,
      o_TxCtlFalling              => o_TxCtlFalling,
      o_TxDataRising              => o_TxDataRising,
      o_TxDataFalling             => o_TxDataFalling,
      i_GmiiTxData                => i_GmiiTxData, 
      i_GmiiTxEn                  => i_GmiiTxEn,
      i_GmiiTxEr                  => i_GmiiTxEr
      );




--*******************************************
--*                                         *
--*           RGMII Recption                *                     
--*                                         *
--*******************************************
    SyncResetRx_inst: SyncReset
    port map (
      i_Reset   => i_Reset,
      i_Clk     => i_rgmii_port_xx_rxc,
      o_Reset   => s_GmiiRxRst
    );

  
    
  ResyncRgmiiRx_inst : ResyncRgmiiRx
    port map (
      i_Reset                     => s_GmiiRxRst,
      i_Clk                       => i_rgmii_port_xx_rxc,
      i_RxCtlRising               => i_RxCtlRising,
      i_RxCtlFalling              => i_RxCtlFalling,
      i_RxDataRising              => i_RxDataRising,
      i_RxDataFalling             => i_RxDataFalling,
      o_GmiiRxData                => o_GmiiRxData,  
      o_GmiiRxEn                  => o_GmiiRxEn,   
      o_GmiiRxEr                  => o_GmiiRxEr   
      );

end rtl;
