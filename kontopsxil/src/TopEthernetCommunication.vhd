--   ----------------------------------------------------------------------------------------------
--   File    	        : TopEthernetCommunication.vhd  
--   Auteur             : Benjamin DISSON
--   Date de creation	: 09/06/2021
--   Version            : 1.0
--   Description        : The project test new communication controller concept on Ethernet with determinism mecanism adapted to launcher vehicule
--                      : Top of the module
--                      : Map the different high level module & buffer of the FPGA
--   Sous module        : RgmiiAdaptator + FrameTransmitterGMII
--   Modifications    
--   --------------------------------------------------------------------------
--   Date             	: Ver. 	: Auteur       		: Commentaires
--   --------------------------------------------------------------------------
--   09/06/2021	        : 1.0   : Benjamin Disson   : Creation - Based on Xapp692
--   13/01/2022         : 2.0   : Benjamin Disson   : RGMII - 4 transmissions

--             Top
--           |------------------------------------------------------------------
--   --rst-->|>BUF> ---(&)->>s_SysReset_n                                      |
--           |          /\                                                     |
--           |          ||                                                     |
--           |          ||                                                     |
--           |_____     ||                                                     |
--           |    |>pll_locked                                                 |
--   --clk-->|>PLL|>s_SysClk_5                                                 |
--           |    |>s_SysClk_25                                                |
--           |-----     ||                                                     |
--           |          \/                                                     |
--           |                          ------------     -----------           | 
--           |                          |config_phy| --> |bdir_buff|---------->|--> Phy control (mdc)
--           |                          ------------     -----------           |
--           | ---------------------     ------------------                    |
--           | | FrameGeneratorCte | --> | RgmiiAdaptator |------------------->|--> output(RGMII) port 0
--           | ---------------------     ------------------                    |
--           |                          ------------     -----------           | 
--           |                          |config_phy| --> |bdir_buff|---------->|--> Phy control (mdc)
--           |                          ------------     -----------           |
--           | ---------------------     ------------------                    |
--           | | FrameGeneratorPayloadCte | --> | RgmiiAdaptator |------------>|--> output(RGMII) port 1
--           | ---------------------     ------------------                    |
--           |                          ------------     -----------           | 
--           |                          |config_phy| --> |bdir_buff|---------->|--> Phy control (mdc)
--           |                          ------------     -----------           |
--           | ---------------------     ------------------                    |
--           | | FrameGeneratorPayloadPrbs | --> | RgmiiAdaptator |----------->|--> output(RGMII) port 2
--           | ---------------------     ------------------                    |
--           |                          ------------     -----------           | 
--           |                          |config_phy| --> |bdir_buff|---------->|--> Phy control (mdc)
--           |                          ------------     -----------           |
--           | ---------------------     ------------------                    |
--           | | FrameGeneratorUdpIp | --> | RgmiiAdaptator |----------------->|--> output(RGMII) port 3
--           | ---------------------     ------------------                    |
--           |-----------------------------------------------------------------|


--                       

											    		         
-------------------------------------------------------------------------------
--  Library declaration
-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;										 			           
library unisim;
use unisim.vcomponents.all;
-------------------------------------------------------------------------------
--  Entity declaration
-------------------------------------------------------------------------------        																					            
entity TopEthernetCommunication is	    														         
port(
  
   sys_rst_n              : in std_logic; --Reset from  DDR2
   --Master_Clock2          : in std_logic; --Master_Clock from the VX3830 board

   -- Port 0 
   mdio_io_port_0_mdio_io : inout std_logic;   
   mdio_io_port_0_mdc     : out std_logic; --LA
   
   reset_port_0           : out std_logic; --LA
   
   rgmii_port_0_td        : out std_logic_vector(3 downto 0);   -- Port 0 RGMII Transmit Data Bits
   rgmii_port_0_txc       : out std_logic;                      -- Port 0 RGMII Transmit clock (FPGA to PHY)
   rgmii_port_0_tx_ctl    : out std_logic;                      -- Port 0 transmitt control
   rgmii_port_0_rd        : in std_logic_vector(3 downto 0); 
   rgmii_port_0_rxc       : in std_logic; 
   rgmii_port_0_rx_ctl    : in std_logic;   
   
   -- PORT1
   mdio_io_port_1_mdio_io    : inout std_logic;                      --LA13_N, -- Port 1 MDC (FPGA to PHY)
   mdio_io_port_1_mdc      : out std_logic;                    --LA14_N, -- Port 1 MDIO (bidir)
   
   reset_port_1           : out std_logic;                      --LA15_N, -- Port 1 PHY reset (active low)
   
   rgmii_port_1_td        : out std_logic_vector(3 downto 0);   -- Port 1 RGMII Transmit Data Bits
   rgmii_port_1_txc       : out std_logic;                      -- Port 1 RGMII Transmit clock (FPGA to PHY)
   rgmii_port_1_tx_ctl    : out std_logic;                      -- Port 1 transmitt control
   rgmii_port_1_rd        : in std_logic_vector(3 downto 0); 
   rgmii_port_1_rxc       : in std_logic; 
   rgmii_port_1_rx_ctl    : in std_logic; 

   -- Port 2 
   mdio_io_port_2_mdio_io : inout std_logic;   
   mdio_io_port_2_mdc : inout std_logic; --LA
   
   reset_port_2           : out std_logic; --LA
   
   rgmii_port_2_td        : out std_logic_vector(3 downto 0);   -- Port 2 RGMII Transmit Data Bits
   rgmii_port_2_txc       : out std_logic;                      -- Port 2 RGMII Transmit clock (FPGA to PHY)
   rgmii_port_2_tx_ctl    : out std_logic;                      -- Port 2 transmitt control
   rgmii_port_2_rd        : in std_logic_vector(3 downto 0); 
   rgmii_port_2_rxc       : in std_logic; 
   rgmii_port_2_rx_ctl    : in std_logic;  


   -- Port 3
   mdio_io_port_3_mdio_io : inout std_logic;   
   mdio_io_port_3_mdc : inout std_logic; --LA
   
   reset_port_3           : out std_logic; --LA
   
   rgmii_port_3_td        : out std_logic_vector(3 downto 0);   -- Port 2 RGMII Transmit Data Bits
   rgmii_port_3_txc       : out std_logic;                      -- Port 2 RGMII Transmit clock (FPGA to PHY)
   rgmii_port_3_tx_ctl    : out std_logic;                      -- Port 2 transmitt control
   rgmii_port_3_rd        : in std_logic_vector(3 downto 0); 
   rgmii_port_3_rxc       : in std_logic; 
   rgmii_port_3_rx_ctl    : in std_logic;  

   
   GPIO_N1                : out std_logic; -- used for FPGA_LINK Led signal on VX3830
   GPIO_N0                : out std_logic; -- used for USER signal on VX3830
   VADJ_VID               : out std_logic_vector(2 downto 0); -- {GPIO, GPIO_N4, GPIO_P4}
   PWRON_VADJ             : out std_logic;

  
  
    ---------------------------------------------------------------------------
    -- Clock
    ---------------------------------------------------------------------------    
    ref_clk_p    : in  std_logic;  -- 125 MHz input differential clock from the mems of the OPSERO board
    ref_clk_n    : in  std_logic  -- 125 MHz input differential clock from the mems of the OPSERO board

    );	
        																					   
end TopEthernetCommunication; 

architecture RTL of TopEthernetCommunication is

-------------------------------------------------------------------------------
--  COMPONENT DECLARATION
------------------------------------------------------------------------------- 
  -- ______
  --/      \
  -- PORT 0
  --\______/
component FrameGeneratorCte  
port ( 	
    i_sys_clk_tx  : in  std_logic;                                     
    i_arst_n      : in  std_logic;     
    i_Run         : in std_logic;    
	o_Tx          : out std_logic_vector(7 downto 0);     
	o_TxEn 		  : out std_logic                        
	);	
end component;

component FrameReceiverCte
port ( 	 
    i_sys_clk_tx   : in  std_logic;                                   
    i_arst_n       : in  std_logic;                        
	o_Run          : out std_logic;
	i_Rxd          : in std_logic_vector(7 downto 0);    
	i_RxEn 		   : in std_logic                         
	);	
end component;
  -- ______
  --/      \
  -- PORT 1
  --\______/
--component FrameGeneratorPayloadCte  
--port ( 	
--    i_sys_clk_tx  : in  std_logic;                                     
--    i_arst_n      : in  std_logic;                        
--	o_Tx          : out std_logic_vector(7 downto 0);     
--	o_TxEn 		  : out std_logic                        
--	);	
--end component;

component FrameGeneratorArp 
port ( 	
    i_sys_clk_tx  : in  std_logic;                                   
    i_arst_n      : in  std_logic;                          
	i_MacSrc      : in std_logic_vector(6*8-1 downto 0);
	i_MacDst      : in std_logic_vector(6*8-1 downto 0);
	i_IpSender    : in std_logic_vector(31 downto 0);
	i_IpTarget    : in std_logic_vector(31 downto 0);
	i_RunArp      : in std_logic;	
	o_Tx          : out std_logic_vector(7 downto 0);     
	o_TxEn 		  : out std_logic                        
	);	
end component;

component FrameReceiverArp 
generic (
	G_MAC_ADDR : std_logic_vector(47 downto 0);
	G_IP_ADDR  : std_logic_vector(31 downto 0)
);
port ( 	
    i_sys_clk_tx   : in  std_logic;                                   
    i_arst_n       : in  std_logic;                        
	o_MacSrc       : out std_logic_vector(6*8-1 downto 0);
	o_MacDst       : out std_logic_vector(6*8-1 downto 0);
	o_IpSender     : out std_logic_vector(31 downto 0);
	o_IpTarget     : out std_logic_vector(31 downto 0);
	o_RunArp       : out std_logic;
	i_Rxd          : in std_logic_vector(7 downto 0);     
	i_RxEn 		   : in std_logic                         
	);	
end component;

  -- ______
  --/      \
  -- PORT 2
  --\______/
--component FrameGeneratorPayloadPrbs  
--port ( 	
--    i_sys_clk_tx  : in  std_logic;                                     
--    i_arst_n      : in  std_logic;                        
--	o_Tx          : out std_logic_vector(7 downto 0);     
--	o_TxEn 		  : out std_logic                        
--	);	
--end component;
component FrameGeneratorIcmp  
port ( 	
    i_sys_clk_tx  : in  std_logic;                                     
    i_arst_n      : in  std_logic;   
    i_Run         : in std_logic;     
	o_Tx          : out std_logic_vector(7 downto 0);     
	o_TxEn 		  : out std_logic                        
	);	
end component;

component FrameReceiverIcmp
port ( 	 
    i_sys_clk_tx   : in  std_logic;                                   
    i_arst_n       : in  std_logic;                        
	o_Run          : out std_logic;
	i_Rxd          : in std_logic_vector(7 downto 0);    
	i_RxEn 		   : in std_logic                         
	);	
end component;
  -- ______
  --/      \
  -- PORT 3
  --\______/
component FrameGeneratorUdpIp  
port ( 	
    i_sys_clk_tx  : in  std_logic;                                     
    i_arst_n      : in  std_logic;  
    i_Run         : in std_logic;
	o_Tx          : out std_logic_vector(7 downto 0);     
	o_TxEn 		  : out std_logic                        
	);	
end component;

component FrameReceiverUdpIp
port ( 	 
    i_sys_clk_tx   : in  std_logic;                                   
    i_arst_n       : in  std_logic;                        
	o_Run          : out std_logic;
	i_Rxd          : in std_logic_vector(7 downto 0);    
	i_RxEn 		   : in std_logic                         
	);	
end component;
  -- ______
  --/      \
  -- PORT x
  --\______/
component RgmiiAdaptator
  port (
    i_Reset            : in  std_logic;     
    i_Clk              : in  std_logic; 
    o_TxCtlRising    : out std_logic;               
    o_TxCtlFalling   : out std_logic;                      
    o_TxDataRising       : out std_logic_vector(3 downto 0);   
    o_TxDataFalling      : out std_logic_vector(3 downto 0);
    i_GmiiTxData   : in  std_logic_vector(7 downto 0);  
    i_GmiiTxEn : in  std_logic;      
    i_GmiiTxEr : in  std_logic;
    i_rgmii_port_xx_rxc     : in std_logic;  --rgmii_port_xx_rxc
    i_RxCtlRising           : in std_logic;                                       
    i_RxCtlFalling          : in std_logic;                                      
    i_RxDataRising          : in std_logic_vector(3 downto 0);  
    i_RxDataFalling         : in std_logic_vector(3 downto 0);  
    o_GmiiRxData            : out std_logic_vector(7 downto 0); 
    o_GmiiRxEn              : out std_logic;                    
    o_GmiiRxEr              : out std_logic    
    );
end component;  


component  ConfigPhy  
port	(	
		i_ClkMdc	: in std_logic; 
		i_Reset_n	: in std_logic ;
		--o_Mdc	    : out std_logic;			
		--i_MdioIn	: in std_logic;
		o_MdioOut	: out std_logic;
		o_MdioOE	: out std_logic
		);	
end component;

component bidir_buff 
  port (
         MDIO : inout std_logic;
         MDI : in std_logic;
         OE: in std_logic;
         MDO : out std_logic
        );
end component;

component MyPll 
   port ( CLKIN1_IN   : in    std_logic; 
          RST_IN      : in    std_logic; 
          CLKOUT0_OUT : out   std_logic; 
          --CLKOUT1_OUT : out   std_logic; 
		  --CLKOUT2_OUT : out   std_logic;
          LOCKED_OUT  : out   std_logic);
end component;

--component DCM 
--   port ( 
--	CLKFB_IN  : in    std_logic; 
--	CLKIN_IN        : in    std_logic; 
--          RST_IN          : in    std_logic; 
--          CLKDV_OUT       : out   std_logic; 
--          CLKFX_OUT       : out   std_logic; 
--          CLKFX180_OUT    : out   std_logic; 
--          CLKIN_IBUFG_OUT : out   std_logic; 
--          CLK0_OUT        : out   std_logic; 
--          CLK2X_OUT       : out   std_logic; 
--          CLK2X180_OUT    : out   std_logic; 
--          CLK90_OUT       : out   std_logic; 
--          CLK180_OUT      : out   std_logic; 
--          CLK270_OUT      : out   std_logic; 
--          LOCKED_OUT      : out   std_logic);
--end component;


-------------------------------------------------------------------------------
--  CONSTANT DECLARATION
-------------------------------------------------------------------------------
  CONSTANT C_FRAME_MAX_SIZE : integer := 67108863;
  
  
  -----------------------------------------------------------------------------
  -- SIGNAL DECLARATION 
  -----------------------------------------------------------------------------
  signal GND                	  : std_logic;                     -- Logic 0
  signal VCC                	  : std_logic;                     -- Logic 1
  
  signal s_SysClk_125       	  : std_logic;  
  signal s_SysClk_125_IBUFG       : std_logic;    
  signal s_lock_pll               : std_logic;
  signal s_SysClk_4               : std_logic;
  signal s_sys_rst_n              : std_logic; -- out of the input buffer
  signal s_PhyReset_n             : std_logic;
  signal s_PhyMaintain            : natural range C_FRAME_MAX_SIZE downto 0;--: std_logic_vector(25 downto 0);
  signal s_FrameTick              : std_logic;
  
  
  
  signal rgmii_port_0_rxc_BUF       : std_logic;
  signal rgmii_port_1_rxc_BUF       : std_logic;
  signal rgmii_port_2_rxc_BUF       : std_logic;
  signal rgmii_port_3_rxc_BUF       : std_logic;
  


  -- Port 0 DDR Buffer signal
  signal s_RGMII_TX_CTL_RISING_INT_P0   : std_logic;
  signal s_RGMII_TX_CTL_FALLING_INT_P0  : std_logic;
  signal s_RGMII_TXD_RISING_INT_P0      : std_logic_vector(3 downto 0);
  signal s_RGMII_TXD_FALLING_INT_P0     : std_logic_vector(3 downto 0);  
  signal s_RGMII_TX_CTL_OBUF_P0	        : std_logic;
  signal s_RGMII_TXD_OBUF_P0            : std_logic_vector(3 downto 0);
  signal s_RGMII_RX_CTL_RISING_INT_P0   : std_logic;
  signal s_RGMII_RX_CTL_FALLING_INT_P0  : std_logic;
  signal s_RGMII_RXD_RISING_INT_P0      : std_logic_vector(3 downto 0);
  signal s_RGMII_RXD_FALLING_INT_P0     : std_logic_vector(3 downto 0);  
  signal s_RGMII_RX_CTL_OBUF_P0         : std_logic;
  signal s_RGMII_RXD_OBUF_P0            : std_logic_vector(3 downto 0);  
  
  signal s_Txd_P0                       : std_logic_vector(7 downto 0);
  signal s_TxEn_P0        	            : std_logic; 
  signal s_mdio_in_P0	                : std_logic;
  signal s_mdio_out_P0                  : std_logic;
  signal s_mdio_oe_P0	                : std_logic;
  signal s_mdio_inout_int_P0            : std_logic; 
  signal s_Rxd_P0                       : std_logic_vector(7 downto 0);
  signal s_RxEn_P0        	            : std_logic; 
  
  signal s_Run_cte                      : std_logic;	  
  

  -- Port 1 DDR Buffer signal
  signal s_RGMII_TX_CTL_RISING_INT_P1   : std_logic;
  signal s_RGMII_TX_CTL_FALLING_INT_P1  : std_logic;
  signal s_RGMII_TXD_RISING_INT_P1      : std_logic_vector(3 downto 0);
  signal s_RGMII_TXD_FALLING_INT_P1     : std_logic_vector(3 downto 0);  
  signal s_RGMII_TX_CTL_OBUF_P1	        : std_logic;
  signal s_RGMII_TXD_OBUF_P1            : std_logic_vector(3 downto 0);
  signal s_RGMII_RX_CTL_RISING_INT_P1   : std_logic;
  signal s_RGMII_RX_CTL_FALLING_INT_P1  : std_logic;
  signal s_RGMII_RXD_RISING_INT_P1      : std_logic_vector(3 downto 0);
  signal s_RGMII_RXD_FALLING_INT_P1     : std_logic_vector(3 downto 0);  
  signal s_RGMII_RX_CTL_OBUF_P1         : std_logic;
  signal s_RGMII_RXD_OBUF_P1            : std_logic_vector(3 downto 0);

  signal s_Txd_P1                       : std_logic_vector(7 downto 0);
  signal s_TxEn_P1        	            : std_logic; 
  signal s_mdio_in_P1	                : std_logic;
  signal s_mdio_out_P1                  : std_logic;
  signal s_mdio_oe_P1	                : std_logic;
  signal s_mdio_inout_int_P1            : std_logic; 
  signal s_Rxd_P1                       : std_logic_vector(7 downto 0);
  signal s_RxEn_P1        	            : std_logic;
  
  signal s_MacSrc_arp                   : std_logic_vector(6*8-1 downto 0);
  signal s_MacDst_arp                   : std_logic_vector(6*8-1 downto 0);
  signal s_IpSender_arp                 : std_logic_vector(31 downto 0);
  signal s_IpTarget_arp                 : std_logic_vector(31 downto 0);
  signal s_RunArp_arp                   : std_logic;	
  
  
  
  
  -- Port 2 DDR Buffer signal
  signal s_RGMII_TX_CTL_RISING_INT_P2   : std_logic;
  signal s_RGMII_TX_CTL_FALLING_INT_P2  : std_logic;
  signal s_RGMII_TXD_RISING_INT_P2      : std_logic_vector(3 downto 0);
  signal s_RGMII_TXD_FALLING_INT_P2     : std_logic_vector(3 downto 0);  
  signal s_RGMII_TX_CTL_OBUF_P2	        : std_logic;
  signal s_RGMII_TXD_OBUF_P2            : std_logic_vector(3 downto 0);
  signal s_RGMII_RX_CTL_RISING_INT_P2   : std_logic;
  signal s_RGMII_RX_CTL_FALLING_INT_P2  : std_logic;
  signal s_RGMII_RXD_RISING_INT_P2      : std_logic_vector(3 downto 0);
  signal s_RGMII_RXD_FALLING_INT_P2     : std_logic_vector(3 downto 0);  
  signal s_RGMII_RX_CTL_OBUF_P2         : std_logic;
  signal s_RGMII_RXD_OBUF_P2            : std_logic_vector(3 downto 0);
  
  signal s_Txd_P2                       : std_logic_vector(7 downto 0);
  signal s_TxEn_P2        	            : std_logic; 
  signal s_mdio_in_P2	                : std_logic;
  signal s_mdio_out_P2                  : std_logic;
  signal s_mdio_oe_P2	                : std_logic;
  signal s_mdio_inout_int_P2            : std_logic; 
  signal s_Rxd_P2                       : std_logic_vector(7 downto 0);
  signal s_RxEn_P2        	            : std_logic;   
  signal s_Run_Icmp                     : std_logic;  
  

  -- Port 3 DDR Buffer signal
  signal s_RGMII_TX_CTL_RISING_INT_P3   : std_logic;
  signal s_RGMII_TX_CTL_FALLING_INT_P3  : std_logic;
  signal s_RGMII_TXD_RISING_INT_P3      : std_logic_vector(3 downto 0);
  signal s_RGMII_TXD_FALLING_INT_P3     : std_logic_vector(3 downto 0);  
  signal s_RGMII_TX_CTL_OBUF_P3	        : std_logic;
  signal s_RGMII_TXD_OBUF_P3            : std_logic_vector(3 downto 0);
  signal s_RGMII_RX_CTL_RISING_INT_P3   : std_logic;
  signal s_RGMII_RX_CTL_FALLING_INT_P3  : std_logic;
  signal s_RGMII_RXD_RISING_INT_P3      : std_logic_vector(3 downto 0);
  signal s_RGMII_RXD_FALLING_INT_P3     : std_logic_vector(3 downto 0);  
  signal s_RGMII_RX_CTL_OBUF_P3         : std_logic;
  signal s_RGMII_RXD_OBUF_P3            : std_logic_vector(3 downto 0);
    
  signal s_Txd_P3                       : std_logic_vector(7 downto 0);
  signal s_TxEn_P3        	            : std_logic; 
  signal s_mdio_in_P3	                : std_logic;
  signal s_mdio_out_P3                  : std_logic;
  signal s_mdio_oe_P3	                : std_logic;
  signal s_mdio_inout_int_P3            : std_logic;   
  signal s_Rxd_P3                       : std_logic_vector(7 downto 0);
  signal s_RxEn_P3        	            : std_logic;   
  signal s_Run_UdpIp                    : std_logic;

  
  -- Global MDIO  
  signal MDC_INT                        : std_logic;     
 
  
  -- For Debug : buffer
  --signal s_rxd_port1_ibuf: std_logic_vector(3 downto 0);
  
  
  --attribute S:string;
  --attribute S of s_mdio_in_P0 : signal is "TRUE";
  --attribute keep : string;
  --attribute keep of s_mdio_in_P0 : signal is "true";
  
  -- DCM
  -----------------------------------------------------------------------------
  -- ATTRIBUTE 
  -----------------------------------------------------------------------------
--  attribute DLL_FREQUENCY_MODE : string;
--  attribute CLKIN_PERIOD       : string;
  
--  -- DCM TX
--  attribute DLL_FREQUENCY_MODE of DCM_TX_CLK : label is "LOW";
--  attribute CLKIN_PERIOD of DCM_TX_CLK       : label is "10";

  
  
-- ==============================================================================================================================================
-- ==============================================================================================================================================
begin

  -- **************************************************************************
  -- *
  -- *                             DEBUG management                           *
  -- *
  -- **************************************************************************  
---- For DEBUG : check the reception of port1 by transfering data through port2
--    rgmii_port_2_td(3 downto 0)     <= s_rxd_port1_ibuf(3 downto 0);    
--    rgmii_port_2_txc    			<= rgmii_port_1_rxc;   
--    rgmii_port_2_tx_ctl 			<= rgmii_port_1_rx_ctl;
--   
--    DRIVE_RGMII_RXD0         : IBUF port map (I => rgmii_port_1_rd(0), O => s_rxd_port1_ibuf(0));
--    DRIVE_RGMII_RXD1         : IBUF port map (I => rgmii_port_1_rd(1), O => s_rxd_port1_ibuf(1));
--    DRIVE_RGMII_RXD2         : IBUF port map (I => rgmii_port_1_rd(2), O => s_rxd_port1_ibuf(2));
--    DRIVE_RGMII_RXD3         : IBUF port map (I => rgmii_port_1_rd(3), O => s_rxd_port1_ibuf(3));
--	
--	
--	
--	--Debug MDIO
--	mdio_io_port_0_mdio_io <= s_mdio_in_P0 and s_lock_pll;


-- ==============================================================================================================================================
  -- **************************************************************************
  -- *
  -- *                             RESET management                           *
  -- *
  -- **************************************************************************  
  -----------------------------------------------------------------------------
  -- Instantiation of IBUFs/OBUFs for Resetting 
  -----------------------------------------------------------------------------
    DdrResetIbuf : IBUF port map (I => sys_rst_n, O => s_sys_rst_n);
    
    PhyReset0Obuf : OBUF port map (I => s_PhyReset_n , O => reset_port_0);
    PhyReset1Obuf : OBUF port map (I => s_PhyReset_n , O => reset_port_1);
    PhyReset2Obuf : OBUF port map (I => s_PhyReset_n , O => reset_port_2);
    PhyReset3Obuf : OBUF port map (I => s_PhyReset_n , O => reset_port_3);

  --------------------------------------------------------
  -- Proc: RESET Hardware of the PHY 
  -- Desc: Maintain PHY hardware reset
  --       1. Hold the RESET_Nsignal Low for 10 ms
  --       2. Release the RESET_Nsignal High for 5 ms
  --------------------------------------------------------
  ProcResetPhy: process(s_sys_rst_n,s_SysClk_125)
  begin
    if s_sys_rst_n = '0' then
		s_PhyReset_n   <= '0';
	    s_PhyMaintain  <= 0;
	elsif rising_edge(s_SysClk_125) then
		if (s_PhyMaintain = C_FRAME_MAX_SIZE) then --and s_lock_pll = '1' then
			s_PhyReset_n        <= '1';
		else
			s_PhyMaintain <= s_PhyMaintain + 1;
			s_PhyReset_n    <= '0'; 
		end if;
	end if;
  end process ProcResetPhy;
  
  
	-- ==============================================================================================================================================
  -- **************************************************************************
  -- *
  -- *                             LED management                           *
  -- *
  -- **************************************************************************  	
  -----------------------------------------------------------------------------
  -- Instantiation of IBUFs/OBUFs for LEDs 
  -----------------------------------------------------------------------------
  LedOnObuf  : OBUF port map (I => s_FrameTick , O => GPIO_N1);
  LedOffObuf : OBUF port map (I => not s_FrameTick , O => GPIO_N0);

	
  --------------------------------------------------------
  -- Proc: Tick generator
  -- Desc: Generate tick to send new Ethernet frame and LEDs
  -- Use of s_PhyMaintain counter
  --------------------------------------------------------
  ProcTickGene: process(s_sys_rst_n,s_SysClk_125)
  begin
    if s_sys_rst_n = '0' then
      s_FrameTick          <= '0';
    elsif rising_edge(s_SysClk_125) then
		if (s_PhyMaintain = C_FRAME_MAX_SIZE) then
			s_FrameTick        <= not s_FrameTick;

		end if;
	end if;
  end process ProcTickGene;
  
  
-- ==============================================================================================================================================
  -- **************************************************************************
  -- *
  -- *                             POWER management                           *
  -- *
  -- **************************************************************************  	
  -----------------------------------------------------------------------------
  -- Instantiation of IBUFs/OBUFs for Power 
  -----------------------------------------------------------------------------	
  -- Power up OPSERO mezzanie card  
  -- Version : Robust, 2.5 Volt
  -- VADJ selection 
  -- VID 0 1 2  
  -- ---------------
  --     1 0 0    2.5V
  --     0 1 0    1.8V
  --     1 1 0    1.5V
  --     0 0 0    3.3V
  Vadj2Obuf      : OBUF port map (I => '0' , O => VADJ_VID(2));
  Vadj1Obuf      : OBUF port map (I => '0' , O => VADJ_VID(1));
  Vadj0Obuf      : OBUF port map (I => '1' , O => VADJ_VID(0));
  VadjpowerObuf  : OBUF port map (I => '1' , O => PWRON_VADJ);


-- ==============================================================================================================================================
  -- **************************************************************************
  -- *
  -- *                             CLOCK management                           *
  -- *
  -- **************************************************************************  
  ----------------------------------------------------------------------------------
  -- GTX_CLK Clock Management
  ----------------------------------------------------------------------------------   
  -- The clock used for GTX_CLK is a 125 MHz differential oscillator from the opsero board
  GtxClkIbufg : IBUFGDS_LVDS_25 
      port map (
		I  => ref_clk_p,
       	IB => ref_clk_n,
       	O  => s_SysClk_125_IBUFG
       	);
  
  GtxClkbufg  : BUFG  port map (I => s_SysClk_125_IBUFG,     O => s_SysClk_125); -- For the RGMII generator

    rgmii_port_0_txc <= s_SysClk_125;
    rgmii_port_1_txc <= s_SysClk_125;
    rgmii_port_2_txc <= s_SysClk_125;
    rgmii_port_3_txc <= s_SysClk_125;
   
   
   EthRxClkPort0: IBUFG port map( I => rgmii_port_0_rxc , O => rgmii_port_0_rxc_BUF);
   EthRxClkPort1: IBUFG port map( I => rgmii_port_1_rxc , O => rgmii_port_1_rxc_BUF);
   EthRxClkPort2: IBUFG port map( I => rgmii_port_2_rxc , O => rgmii_port_2_rxc_BUF);
   EthRxClkPort3: IBUFG port map( I => rgmii_port_3_rxc , O => rgmii_port_3_rxc_BUF);
   
  ----------------------------------------------------------------------------------
  -- RGMII Transmitter Clock Management:Use DCM to drive the s_RGMII_TX_CLK to the PHY
  ----------------------------------------------------------------------------------
 -- DCM_TX_CLK : DCM
 --   port map (CLK0     => s_RGMII_TX_CLK_OUT, 
 --             CLK180   => s_RGMII_TX_CLK180_OUT, 
 --             CLK270   => open, 
 --             CLK2X    => open, 
 --             CLK2X180 => open, 
 --             CLK90    => s_RGMII_TX_CLK90_OUT, 
 --             CLKDV    => open, 
 --             CLKFX    => open, 
 --             CLKFX180 => open, 
 --             LOCKED   => LOCKED, 
 --             PSDONE   => open, 
 --             STATUS   => open, 
 --             CLKFB    => s_RGMII_TX_CLK_BUFG, 
 --             CLKIN    => s_SysClk_125, 
 --             DSSEN    => '0', 
 --             PSCLK    => '0', 
 --             PSEN     => '0', 
 --             PSINCDEC => '0', 
 --             RST      => '0'
 --             ); 

				  
--	DCM_TX_CLK : DCM			  
--   port map( 
--		    CLKFB_IN        => s_RGMII_TX_CLK_BUFG,
--          CLKIN_IN        => s_SysClk_125, 
--          RST_IN          => '0', 
--          CLKDV_OUT       => open, 
--          CLKFX_OUT       => open,  
--          CLKFX180_OUT    => open, 
--          CLKIN_IBUFG_OUT => open, 
--          CLK0_OUT        => s_RGMII_TX_CLK_OUT, 
--          CLK2X_OUT       => open, 
--          CLK2X180_OUT    => open,
--          CLK90_OUT       => s_RGMII_TX_CLK90_OUT,  
--          CLK180_OUT      => s_RGMII_TX_CLK180_OUT, 
--          CLK270_OUT      => open,  
--          LOCKED_OUT      => LOCKED
--			 );





  --TxClkBufg : BUFG port map (I => s_RGMII_TX_CLK_OUT, O => s_RGMII_TX_CLK_BUFG);
  --TxClk180Bufg : BUFG port map (I => s_RGMII_TX_CLK180_OUT, O => s_RGMII_TX_CLK180_BUFG); 
  --TxClk90Bufg : BUFG port map (I => s_RGMII_TX_CLK90_OUT, O => s_RGMII_TX_CLK90_BUFG);
  
  -- Main clock of the DCM
  --s_RGMII_TX_CLK_INT <= s_SysClk_125;
  -- Use CLK180 of the DCM port to do the inversion clock that goes to 
  -- FDDRRSE.  
  -- NOT_s_SysClk_125 <= s_RGMII_TX_CLK180_BUFG;
  --NOT_s_SysClk_125 <= not s_SysClk_125;

  -- 2 ns delay between TXD and TX_CLK according to the HP RGMII v2.0 specifications
  --DRIVE_s_RGMII_TX_CLK: OBUF port map (I => s_RGMII_TX_CLK90_BUFG, O => rgmii_port_1_txc);
  
  
  --Witout 2 ns
  --DRIVE_s_RGMII_TX_CLK: OBUF port map (I => s_RGMII_TX_CLK_BUFG, O => rgmii_port_1_txc);

   
   
   
-- ==============================================================================================================================================
  -- *******************************************************************************
  -- *
  -- *                             DDR buffer management                           *
  -- *
  -- *******************************************************************************
  ----------------------------------------------------------------------------------
  -- RGMII Transmitter Logic:  Use DDR Flip-Flops to clock the TX data on both the
  -- positive edge and negative edge which is then transmitted to the PHY
  ----------------------------------------------------------------------------------  
  GND <= '0';              -- Logic 0.
  VCC <= '1';              -- Logic 1.
  
  -- ______
  --/      \
  -- PORT 0
  --\______/
  -- -------------
  -- Transmit
  -- -------------  
  GenTxDataDdrOut_P0:
  for I in 0 to 3 generate
    RgmiiTxDataDdr_P0 : ODDR
  	generic map (
		DDR_CLK_EDGE    => "SAME_EDGE",--"OPPOSITE_EDGE",
		INIT            => '0',
		SRTYPE          => "ASYNC"
        )
      port map (
	    Q       => s_RGMII_TXD_OBUF_P0(I),
	    C       => s_SysClk_125,
	    CE      => VCC,
	    D1      => s_RGMII_TXD_RISING_INT_P0(I),
        D2      => s_RGMII_TXD_FALLING_INT_P0(I),
        R       => not(s_PhyReset_n),
        S       => GND		
        );      
  end generate GenTxDataDdrOut_P0;


  RgmiiTxCtlDdr_P0: ODDR
  	generic map (
		DDR_CLK_EDGE    => "SAME_EDGE",--"OPPOSITE_EDGE",
		INIT            => '0',
		SRTYPE          => "ASYNC"
        )
    port map (
	    Q       => s_RGMII_TX_CTL_OBUF_P0,
	    C       => s_SysClk_125,
	    CE      => VCC,
	    D1      => s_RGMII_TX_CTL_RISING_INT_P0,
        D2      => s_RGMII_TX_CTL_FALLING_INT_P0,
        R       => not(s_PhyReset_n),
        S       => GND
        );

    rgmii_port_0_tx_ctl <= s_RGMII_TX_CTL_OBUF_P0;
    rgmii_port_0_td(0)  <=  s_RGMII_TXD_OBUF_P0(0);
    rgmii_port_0_td(1)  <=  s_RGMII_TXD_OBUF_P0(1);
    rgmii_port_0_td(2)  <=  s_RGMII_TXD_OBUF_P0(2);
    rgmii_port_0_td(3)  <=  s_RGMII_TXD_OBUF_P0(3);  
  
-- -------------
-- Receive
-- -------------
  GenRxDataDdrIn_P0:
  for I in 0 to 3 generate
    RgmiiRxDataDdr_P0 : IDDR
    generic map (
    DDR_CLK_EDGE    => "SAME_EDGE",--"OPPOSITE_EDGE",
  --  INIT            => '0',
    SRTYPE          => "ASYNC"
        )
      port map (
      Q1          => s_RGMII_RXD_RISING_INT_P0(I),
      Q2          => s_RGMII_RXD_FALLING_INT_P0(I),
      C           => rgmii_port_0_rxc_BUF,
      CE          => VCC,
      D           => s_RGMII_RXD_OBUF_P0(I),
      R           => not(s_PhyReset_n),
      S           => GND    
        );      
  end generate GenRxDataDdrIn_P0;


  RgmiiRxCtlDdr_P0: IDDR
    generic map (
    DDR_CLK_EDGE    => "SAME_EDGE",--"OPPOSITE_EDGE",
--    INIT            => '0',
    SRTYPE          => "ASYNC"
        )
    port map (
      Q1          => s_RGMII_RX_CTL_RISING_INT_P0,
      Q2          => s_RGMII_RX_CTL_FALLING_INT_P0,
      C           => rgmii_port_0_rxc_BUF,
      CE          => VCC,
      D           => s_RGMII_RX_CTL_OBUF_P0,
      R           => not(s_PhyReset_n),
      S           => GND 
        );
        
    s_RGMII_RX_CTL_OBUF_P0 <= rgmii_port_0_rx_ctl;
    s_RGMII_RXD_OBUF_P0(0) <= rgmii_port_0_rd(0);
    s_RGMII_RXD_OBUF_P0(1) <= rgmii_port_0_rd(1);
    s_RGMII_RXD_OBUF_P0(2) <= rgmii_port_0_rd(2);
    s_RGMII_RXD_OBUF_P0(3) <= rgmii_port_0_rd(3);
  
  
  
  -- ______
  --/      \
  -- PORT 1
  --\______/
  -- -------------
  -- Transmit
  -- -------------
  GenTxDataDdrOut_P1:
  for I in 0 to 3 generate
    RgmiiTxDataDdr_P1 : ODDR
  	generic map (
		DDR_CLK_EDGE    => "SAME_EDGE",--"OPPOSITE_EDGE",
		INIT            => '0',
		SRTYPE          => "ASYNC"
        )
      port map (
	    Q       => s_RGMII_TXD_OBUF_P1(I),
	    C       => s_SysClk_125,
	    CE      => VCC,
	    D1      => s_RGMII_TXD_RISING_INT_P1(I),
        D2      => s_RGMII_TXD_FALLING_INT_P1(I),
        R       => not(s_PhyReset_n),
        S       => GND		
        );      
  end generate GenTxDataDdrOut_P1;


  RgmiiTxCtlDdr_P1: ODDR
  	generic map (
		DDR_CLK_EDGE    => "SAME_EDGE",--"OPPOSITE_EDGE",
		INIT            => '0',
		SRTYPE          => "ASYNC"
        )
    port map (
	    Q       => s_RGMII_TX_CTL_OBUF_P1,
	    C       => s_SysClk_125,
	    CE      => VCC,
	    D1      => s_RGMII_TX_CTL_RISING_INT_P1,
        D2      => s_RGMII_TX_CTL_FALLING_INT_P1,
        R       => not(s_PhyReset_n),
        S       => GND
        );

    rgmii_port_1_tx_ctl <= s_RGMII_TX_CTL_OBUF_P1;
    rgmii_port_1_td(0)  <=  s_RGMII_TXD_OBUF_P1(0);
    rgmii_port_1_td(1)  <=  s_RGMII_TXD_OBUF_P1(1);
    rgmii_port_1_td(2)  <=  s_RGMII_TXD_OBUF_P1(2);
    rgmii_port_1_td(3)  <=  s_RGMII_TXD_OBUF_P1(3);  
    
-- -------------
-- Receive
-- -------------
  GenRxDataDdrIn_P1:
  for I in 0 to 3 generate
    RgmiiRxDataDdr_P1 : IDDR
    generic map (
    DDR_CLK_EDGE    => "SAME_EDGE",--"OPPOSITE_EDGE",
 --   INIT            => '0',
    SRTYPE          => "ASYNC"
        )
      port map (
      Q1          => s_RGMII_RXD_RISING_INT_P1(I),
      Q2          => s_RGMII_RXD_FALLING_INT_P1(I),
      C           => rgmii_port_1_rxc_BUF,
      CE          => VCC,
      D           => s_RGMII_RXD_OBUF_P1(I),
      R           => not(s_PhyReset_n),
      S           => GND    
        );      
  end generate GenRxDataDdrIn_P1;


  RgmiiRxCtlDdr_P1: IDDR
    generic map (
    DDR_CLK_EDGE    => "SAME_EDGE",--"OPPOSITE_EDGE",
--    INIT            => '0',
    SRTYPE          => "ASYNC"
        )
    port map (
      Q1          => s_RGMII_RX_CTL_RISING_INT_P1,
      Q2          => s_RGMII_RX_CTL_FALLING_INT_P1,
      C           => rgmii_port_1_rxc_BUF,
      CE          => VCC,
      D           => s_RGMII_RX_CTL_OBUF_P1,
      R           => not(s_PhyReset_n),
      S           => GND 
        );
        
    s_RGMII_RX_CTL_OBUF_P1 <= rgmii_port_1_rx_ctl;
    s_RGMII_RXD_OBUF_P1(0) <= rgmii_port_1_rd(0);
    s_RGMII_RXD_OBUF_P1(1) <= rgmii_port_1_rd(1);
    s_RGMII_RXD_OBUF_P1(2) <= rgmii_port_1_rd(2);
    s_RGMII_RXD_OBUF_P1(3) <= rgmii_port_1_rd(3);


  -- ______
  --/      \
  -- PORT 2
  --\______/
  -- -------------
  -- Transmit
  -- -------------  
  GenTxDataDdrOut_P2:
  for I in 0 to 3 generate
    RgmiiTxDataDdr_P2 : ODDR
  	generic map (
		DDR_CLK_EDGE    => "SAME_EDGE",--"OPPOSITE_EDGE",
		INIT            => '0',
		SRTYPE          => "ASYNC"
        )
      port map (
	    Q       => s_RGMII_TXD_OBUF_P2(I),
	    C       => s_SysClk_125,
	    CE      => VCC,
	    D1      => s_RGMII_TXD_RISING_INT_P2(I),
        D2      => s_RGMII_TXD_FALLING_INT_P2(I),
        R       => not(s_PhyReset_n),
        S       => GND		
        );      
  end generate GenTxDataDdrOut_P2;


  RgmiiTxCtlDdr_P2: ODDR
  	generic map (
		DDR_CLK_EDGE    => "SAME_EDGE",--"OPPOSITE_EDGE",
		INIT            => '0',
		SRTYPE          => "ASYNC"
        )
    port map (
	    Q       => s_RGMII_TX_CTL_OBUF_P2,
	    C       => s_SysClk_125,
	    CE      => VCC,
	    D1      => s_RGMII_TX_CTL_RISING_INT_P2,
        D2      => s_RGMII_TX_CTL_FALLING_INT_P2,
        R       => not(s_PhyReset_n),
        S       => GND
        );

    rgmii_port_2_tx_ctl <= s_RGMII_TX_CTL_OBUF_P2;
    rgmii_port_2_td(0)  <=  s_RGMII_TXD_OBUF_P2(0);
    rgmii_port_2_td(1)  <=  s_RGMII_TXD_OBUF_P2(1);
    rgmii_port_2_td(2)  <=  s_RGMII_TXD_OBUF_P2(2);
    rgmii_port_2_td(3)  <=  s_RGMII_TXD_OBUF_P2(3);  

-- -------------
-- Receive
-- -------------
  GenRxDataDdrIn_P2:
  for I in 0 to 3 generate
    RgmiiRxDataDdr_P2 : IDDR
    generic map (
    DDR_CLK_EDGE    => "SAME_EDGE",--"OPPOSITE_EDGE",
--    INIT            => '0',
    SRTYPE          => "ASYNC"
        )
      port map (
      Q1          => s_RGMII_RXD_RISING_INT_P2(I),
      Q2          => s_RGMII_RXD_FALLING_INT_P2(I),
      C           => rgmii_port_2_rxc_BUF,
      CE          => VCC,
      D           => s_RGMII_RXD_OBUF_P2(I),
      R           => not(s_PhyReset_n),
      S           => GND    
        );      
  end generate GenRxDataDdrIn_P2;


  RgmiiRxCtlDdr_P2: IDDR
    generic map (
    DDR_CLK_EDGE    => "SAME_EDGE",--"OPPOSITE_EDGE",
--    INIT            => '0',
    SRTYPE          => "ASYNC"
        )
    port map (
      Q1          => s_RGMII_RX_CTL_RISING_INT_P2,
      Q2          => s_RGMII_RX_CTL_FALLING_INT_P2,
      C           => rgmii_port_2_rxc_BUF,
      CE          => VCC,
      D           => s_RGMII_RX_CTL_OBUF_P2,
      R           => not(s_PhyReset_n),
      S           => GND 
        );
        
    s_RGMII_RX_CTL_OBUF_P2 <= rgmii_port_2_rx_ctl;
    s_RGMII_RXD_OBUF_P2(0) <= rgmii_port_2_rd(0);
    s_RGMII_RXD_OBUF_P2(1) <= rgmii_port_2_rd(1);
    s_RGMII_RXD_OBUF_P2(2) <= rgmii_port_2_rd(2);
    s_RGMII_RXD_OBUF_P2(3) <= rgmii_port_2_rd(3);

    
    
  -- ______
  --/      \
  -- PORT 3
  --\______/
  -- -------------
  -- Transmit
  -- -------------  
  GenTxDataDdrOut_P3:
  for I in 0 to 3 generate
    RgmiiTxDataDdr_P3 : ODDR
  	generic map (
		DDR_CLK_EDGE    => "SAME_EDGE",--"OPPOSITE_EDGE",
		INIT            => '0',
		SRTYPE          => "ASYNC"
        )
      port map (
	    Q       => s_RGMII_TXD_OBUF_P3(I),
	    C       => s_SysClk_125,
	    CE      => VCC,
	    D1      => s_RGMII_TXD_RISING_INT_P3(I),
        D2      => s_RGMII_TXD_FALLING_INT_P3(I),
        R       => not(s_PhyReset_n),
        S       => GND		
        );      
  end generate GenTxDataDdrOut_P3;


  RgmiiTxCtlDdr_P3: ODDR
  	generic map (
		DDR_CLK_EDGE    => "SAME_EDGE",--"OPPOSITE_EDGE",
		INIT            => '0',
		SRTYPE          => "ASYNC"
        )
    port map (
	    Q       => s_RGMII_TX_CTL_OBUF_P3,
	    C       => s_SysClk_125,
	    CE      => VCC,
	    D1      => s_RGMII_TX_CTL_RISING_INT_P3,
        D2      => s_RGMII_TX_CTL_FALLING_INT_P3,
        R       => not(s_PhyReset_n),
        S       => GND
        );

    rgmii_port_3_tx_ctl <= s_RGMII_TX_CTL_OBUF_P3;
    rgmii_port_3_td(0)  <=  s_RGMII_TXD_OBUF_P3(0);
    rgmii_port_3_td(1)  <=  s_RGMII_TXD_OBUF_P3(1);
    rgmii_port_3_td(2)  <=  s_RGMII_TXD_OBUF_P3(2);
    rgmii_port_3_td(3)  <=  s_RGMII_TXD_OBUF_P3(3);  
    
-- -------------
-- Receive
-- -------------
  GenRxDataDdrIn_P3:
  for I in 0 to 3 generate
    RgmiiRxDataDdr_P3 : IDDR
    generic map (
    DDR_CLK_EDGE    => "SAME_EDGE",--"OPPOSITE_EDGE",
--    INIT            => '0',
    SRTYPE          => "ASYNC"
        )
      port map (
      Q1          => s_RGMII_RXD_RISING_INT_P3(I),
      Q2          => s_RGMII_RXD_FALLING_INT_P3(I),
      C           => rgmii_port_3_rxc_BUF,
      CE          => VCC,
      D           => s_RGMII_RXD_OBUF_P3(I),
      R           => not(s_PhyReset_n),
      S           => GND    
        );      
  end generate GenRxDataDdrIn_P3;


  RgmiiRxCtlDdr_P3: IDDR
    generic map (
    DDR_CLK_EDGE    => "SAME_EDGE",--"OPPOSITE_EDGE",
--    INIT            => '0',
    SRTYPE          => "ASYNC"
        )
    port map (
      Q1          => s_RGMII_RX_CTL_RISING_INT_P3,
      Q2          => s_RGMII_RX_CTL_FALLING_INT_P3,
      C           => rgmii_port_3_rxc_BUF,
      CE          => VCC,
      D           => s_RGMII_RX_CTL_OBUF_P3,
      R           => not(s_PhyReset_n),
      S           => GND 
        );
        
    s_RGMII_RX_CTL_OBUF_P3 <= rgmii_port_3_rx_ctl;
    s_RGMII_RXD_OBUF_P3(0) <= rgmii_port_3_rd(0);
    s_RGMII_RXD_OBUF_P3(1) <= rgmii_port_3_rd(1);
    s_RGMII_RXD_OBUF_P3(2) <= rgmii_port_3_rd(2);
    s_RGMII_RXD_OBUF_P3(3) <= rgmii_port_3_rd(3);
    

  -- ==============================================================================================================================================
  -- *******************************************************************************
  -- *
  -- *                           COMPONENT instantiation                           *
  -- *
  -- *******************************************************************************
  ----------------------------------------------------------------------------------
  -- Instantiate 4 x FrameGenerator
  ----------------------------------------------------------------------------------
  -- ______
  --/      \
  -- PORT 0
  --\______/
  FrameGeneratorCte_inst: FrameGeneratorCte  
  port map ( 	
      i_sys_clk_tx  => s_SysClk_125,                                     
      i_arst_n      => s_PhyReset_n,
      i_Run         => s_Run_cte,      
  	  o_Tx          => s_Txd_P0,     
  	  o_TxEn 		=> s_TxEn_P0                        
  	);	
    
    FrameReceiverCte_inst: FrameReceiverCte
    port map( 	 
        i_sys_clk_tx   => s_SysClk_125,                  
        i_arst_n       => s_PhyReset_n,   
        o_Run          => s_Run_cte,       
        i_Rxd          => s_Rxd_P0,      
        i_RxEn 		   => s_RxEn_P0          
        );	

  -- ______
  --/      \
  -- PORT 1
  --\______/	

  FrameGeneratorArp_inst: FrameGeneratorArp 
  port map( 	
    i_sys_clk_tx  => s_SysClk_125,                                  
    i_arst_n      => s_PhyReset_n,                           
  	i_MacSrc      => s_MacSrc_arp,
  	i_MacDst      => s_MacDst_arp,
  	i_IpSender    => s_IpSender_arp,
  	i_IpTarget    => s_IpTarget_arp,
  	i_RunArp      => s_RunArp_arp,
  	o_Tx          => s_Txd_P1,     
  	o_TxEn 		  => s_TxEn_P1                        
  	);	
  
  FrameReceiverArp_inst : FrameReceiverArp 
  generic map(
	G_MAC_ADDR => x"0050bf998b36",
	G_IP_ADDR => x"c0a80001"
  )
  port map( 	
    i_sys_clk_tx   => s_SysClk_125,                                   
    i_arst_n       => s_PhyReset_n,                        
  	o_MacSrc       => s_MacSrc_arp,
  	o_MacDst       => s_MacDst_arp,
  	o_IpSender     => s_IpSender_arp,
  	o_IpTarget     => s_IpTarget_arp,
  	o_RunArp       => s_RunArp_arp,
  	i_Rxd          => s_Rxd_P1,      
  	i_RxEn 		   => s_RxEn_P1      
  	);	

  -- ______
  --/      \
  -- PORT 2
  --\______/
    
    FrameGeneratorIcmp_inst: FrameGeneratorIcmp 
    port map ( 	
        i_sys_clk_tx  => s_SysClk_125,                                     
        i_arst_n      => s_PhyReset_n,  
        i_Run         => s_Run_Icmp,         
        o_Tx          => s_Txd_P2,     
        o_TxEn 		  => s_TxEn_P2                        
  	);	
    
    FrameReceiverIcmp_inst: FrameReceiverIcmp
    port map( 	 
        i_sys_clk_tx   => s_SysClk_125,                  
        i_arst_n       => s_PhyReset_n,   
        o_Run          => s_Run_Icmp,       
        i_Rxd          => s_Rxd_P2,      
        i_RxEn 		   => s_RxEn_P2          
        );	    
    
  -- ______
  --/      \
  -- PORT 3
  --\______/    
  FrameGeneratorUdpIp_inst: FrameGeneratorUdpIp  
  port map ( 	
      i_sys_clk_tx  => s_SysClk_125,                                     
      i_arst_n      => s_PhyReset_n, 
      i_Run         => s_Run_UdpIp,
  	  o_Tx          => s_Txd_P3,     
  	  o_TxEn 		=> s_TxEn_P3                        
  	);	
    FrameReceiverUdpIp_inst: FrameReceiverUdpIp
    port map( 	 
        i_sys_clk_tx   => s_SysClk_125,                  
        i_arst_n       => s_PhyReset_n,   
        o_Run          => s_Run_UdpIp,       
        i_Rxd          => s_Rxd_P2,      
        i_RxEn 		   => s_RxEn_P2          
        );
        
        
  ----------------------------------------------------------------------------------
  -- Instantiate 4x RgmiiAdaptator
  ----------------------------------------------------------------------------------
RgmiiAdaptatorCte_inst: RgmiiAdaptator
port map (
    i_Reset               => not s_PhyReset_n,    
    i_Clk                 => s_SysClk_125,
    o_TxCtlRising         => s_RGMII_TX_CTL_RISING_INT_P0,               
    o_TxCtlFalling        => s_RGMII_TX_CTL_FALLING_INT_P0,                      
    o_TxDataRising        => s_RGMII_TXD_RISING_INT_P0,   
    o_TxDataFalling       => s_RGMII_TXD_FALLING_INT_P0,
    i_GmiiTxData          => s_Txd_P0,  
    i_GmiiTxEn            => s_TxEn_P0,      
    i_GmiiTxEr            => '0',
    i_rgmii_port_xx_rxc   => rgmii_port_0_rxc_BUF,
    i_RxCtlRising         => s_RGMII_RX_CTL_RISING_INT_P0,
    i_RxCtlFalling        => s_RGMII_RX_CTL_FALLING_INT_P0,
    i_RxDataRising        => s_RGMII_RXD_RISING_INT_P0,
    i_RxDataFalling       => s_RGMII_RXD_FALLING_INT_P0,
    o_GmiiRxData          => s_Rxd_P0,
    o_GmiiRxEn            => s_RxEn_P0,
    o_GmiiRxEr            => open
    );
    

    
    
    
RgmiiAdaptatorArp_inst: RgmiiAdaptator
port map (
    i_Reset            => not s_PhyReset_n,    
    i_Clk              => s_SysClk_125,
    o_TxCtlRising      => s_RGMII_TX_CTL_RISING_INT_P1,               
    o_TxCtlFalling     => s_RGMII_TX_CTL_FALLING_INT_P1,                      
    o_TxDataRising     => s_RGMII_TXD_RISING_INT_P1,   
    o_TxDataFalling    => s_RGMII_TXD_FALLING_INT_P1,
    i_GmiiTxData       => s_Txd_P1,  
    i_GmiiTxEn         => s_TxEn_P1,      
    i_GmiiTxEr         => '0',
    i_rgmii_port_xx_rxc   => rgmii_port_1_rxc_BUF,
    i_RxCtlRising         => s_RGMII_RX_CTL_RISING_INT_P1,
    i_RxCtlFalling        => s_RGMII_RX_CTL_FALLING_INT_P1,
    i_RxDataRising        => s_RGMII_RXD_RISING_INT_P1,
    i_RxDataFalling       => s_RGMII_RXD_FALLING_INT_P1,
    o_GmiiRxData          => s_Rxd_P1,
    o_GmiiRxEn            => s_RxEn_P1,
    o_GmiiRxEr            => open    
    );

    
    
RgmiiAdaptatorIcmp_inst: RgmiiAdaptator
port map (
    i_Reset            => not s_PhyReset_n,    
    i_Clk              => s_SysClk_125,
    o_TxCtlRising      => s_RGMII_TX_CTL_RISING_INT_P2,               
    o_TxCtlFalling     => s_RGMII_TX_CTL_FALLING_INT_P2,                      
    o_TxDataRising     => s_RGMII_TXD_RISING_INT_P2,   
    o_TxDataFalling    => s_RGMII_TXD_FALLING_INT_P2,
    i_GmiiTxData       => s_Txd_P2,  
    i_GmiiTxEn         => s_TxEn_P2,      
    i_GmiiTxEr         => '0',
    i_rgmii_port_xx_rxc   => rgmii_port_2_rxc_BUF,
    i_RxCtlRising         => s_RGMII_RX_CTL_RISING_INT_P2,
    i_RxCtlFalling        => s_RGMII_RX_CTL_FALLING_INT_P2,
    i_RxDataRising        => s_RGMII_RXD_RISING_INT_P2,
    i_RxDataFalling       => s_RGMII_RXD_FALLING_INT_P2,
    o_GmiiRxData          => s_Rxd_P2,
    o_GmiiRxEn            => s_RxEn_P2,
    o_GmiiRxEr            => open
    );
    
RgmiiAdaptatorUdpIp_inst: RgmiiAdaptator
port map (
    i_Reset            => not s_PhyReset_n,    
    i_Clk              => s_SysClk_125,
    o_TxCtlRising      => s_RGMII_TX_CTL_RISING_INT_P3,               
    o_TxCtlFalling     => s_RGMII_TX_CTL_FALLING_INT_P3,                      
    o_TxDataRising     => s_RGMII_TXD_RISING_INT_P3,   
    o_TxDataFalling    => s_RGMII_TXD_FALLING_INT_P3,
    i_GmiiTxData       => s_Txd_P3,  
    i_GmiiTxEn         => s_TxEn_P3,      
    i_GmiiTxEr         => '0',
    i_rgmii_port_xx_rxc   => rgmii_port_3_rxc_BUF,
    i_RxCtlRising         => s_RGMII_RX_CTL_RISING_INT_P3,
    i_RxCtlFalling        => s_RGMII_RX_CTL_FALLING_INT_P3,
    i_RxDataRising        => s_RGMII_RXD_RISING_INT_P3,
    i_RxDataFalling       => s_RGMII_RXD_FALLING_INT_P3,
    o_GmiiRxData          => s_Rxd_P3,
    o_GmiiRxEn            => s_RxEn_P3,
    o_GmiiRxEr            => open 
    );	
    
  ----------------------------------------------------------------------------------
  -- Configuration of the PHY x4
  ----------------------------------------------------------------------------------
  -- ______
  --/      \
  -- PORT 0
  --\______/
ConfigPhy_P0_inst: ConfigPhy   
port map (
	  i_ClkMdc => MDC_INT,--s_SysClk_4,
	  i_Reset_n  => s_PhyReset_n, 
	  --o_Mdc      => open,		
	  --i_MdioIn   => s_mdio_in_P0,		
	  o_MdioOut  => s_mdio_out_P0,
	  o_MdioOE   => s_mdio_oe_P0	
		);
MDC_P0 : OBUF port map (I => MDC_INT, O => mdio_io_port_0_mdc);

BufferBidir_P0_inst : bidir_buff  
port map (
      MDIO => s_mdio_inout_int_P0,               
      MDI  => s_mdio_out_P0, 
      OE   => s_mdio_oe_P0,	
      MDO  => s_mdio_in_P0
       );	
mdio_io_port_0_mdio_io <= s_mdio_inout_int_P0;



  -- ______
  --/      \
  -- PORT 1
  --\______/
ConfigPhy_P1_inst: ConfigPhy   
port map (
	  i_ClkMdc => MDC_INT,--s_SysClk_4,
	  i_Reset_n  => s_PhyReset_n, 
	  --o_Mdc      => open,		
	  --i_MdioIn   => s_mdio_in_P1,		
	  o_MdioOut  => s_mdio_out_P1,
	  o_MdioOE   => s_mdio_oe_P1	
		);
MDC_P1 : OBUF port map (I => MDC_INT, O => mdio_io_port_1_mdc);

BufferBidir_P1_inst : bidir_buff  
port map (
      MDIO => s_mdio_inout_int_P1,               
      MDI  => s_mdio_out_P1, 
      OE   => s_mdio_oe_P1,	
      MDO  => s_mdio_in_P1
       );	
mdio_io_port_1_mdio_io <= s_mdio_inout_int_P1;


  -- ______
  --/      \
  -- PORT 2
  --\______/
ConfigPhy_P2_inst: ConfigPhy   
port map (
	  i_ClkMdc => MDC_INT,--s_SysClk_4,
	  i_Reset_n  => s_PhyReset_n, 
	  --o_Mdc      => open,		
	  --i_MdioIn   => s_mdio_in_P2,		
	  o_MdioOut  => s_mdio_out_P2,
	  o_MdioOE   => s_mdio_oe_P2	
		);
MDC_P2 : OBUF port map (I => MDC_INT, O => mdio_io_port_2_mdc);

BufferBidir_P2_inst : bidir_buff  
port map (
      MDIO => s_mdio_inout_int_P2,               
      MDI  => s_mdio_out_P2, 
      OE   => s_mdio_oe_P2,	
      MDO  => s_mdio_in_P2
       );	
mdio_io_port_2_mdio_io <= s_mdio_inout_int_P2;



  -- ______
  --/      \
  -- PORT 3
  --\______/
ConfigPhy_P3_inst: ConfigPhy   
port map (
	  i_ClkMdc => MDC_INT,--s_SysClk_4,
	  i_Reset_n  => s_PhyReset_n, 
	  --o_Mdc      => open,		
	  --i_MdioIn   => s_mdio_in_P3,		
	  o_MdioOut  => s_mdio_out_P3,
	  o_MdioOE   => s_mdio_oe_P3	
		);
MDC_P3 : OBUF port map (I => MDC_INT, O => mdio_io_port_3_mdc);

BufferBidir_P3_inst : bidir_buff  
port map (
      MDIO => s_mdio_inout_int_P3,               
      MDI  => s_mdio_out_P3, 
      OE   => s_mdio_oe_P3,	
      MDO  => s_mdio_in_P3
       );	
mdio_io_port_3_mdio_io <= s_mdio_inout_int_P3;

   
   
   
  ----------------------------------------------------------------------------------
  -- Configuration of the PLL
  ----------------------------------------------------------------------------------
MyPll_inst :  MyPll 
port map( 
          CLKIN1_IN   => s_SysClk_125,
          RST_IN      => not s_PhyReset_n,  
          CLKOUT0_OUT => s_SysClk_4,
          --CLKOUT1_OUT => open, -- 250M
		  --CLKOUT2_OUT => open, -- 40M for debug mdio
          LOCKED_OUT  => s_lock_pll
         );	   
MdcBufG  : BUFG  port map (I => s_SysClk_4,     O => MDC_INT); -- For mdc
		 

		 

end RTL;
