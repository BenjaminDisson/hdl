--   ---------------------------------------------------------------------------
-- File: ConfigPhy.vhd
-- Description: Configure the PHY Ethernet MARVELL 88E1111 through MDIO bus
-- Modification
-- ----------------------------------------------------------
--     Date      Ver.         Author       Comments
-- ----------------------------------------------------------
-- 2020/09/10 :  1.0  : Benjamin Disson : First building
-- 2021/01/25 :  2.0  : Benjamin Disson : for opsero - 88e1510 (Marvell)
-- 2021/06/11 :  3.0  : Benjamin Disson : for RGMII
-- 2022/01/11 :  4.0  : Benjamin Disson : for GigaEthernet, RGMII
--
-------------------------------------------------------------------------------
--  Déclaration des bibliothèques
-------------------------------------------------------------------------------
library ieee; 
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all; 


-------------------------------------------------------------------------------
--  Entity
-------------------------------------------------------------------------------
entity  ConfigPhy  is
port    (    
            i_ClkMdc        : in std_logic;         -- 4 mhz
            i_Reset_n       : in std_logic ;        -- reset     
            
            --o_Mdc         : out std_logic;    -- Top implement the PLL and send ClkMdc ; why sending back ClkMdc to the TOP ?    
            --i_MdioIn        : in std_logic;     -- For further need (get error counter)
            o_MdioOut       : out std_logic;
            o_MdioOE        : out std_logic
        );    
end ConfigPhy;


architecture  rtl  of  ConfigPhy  is

-------------------------------------------------------------------------------
--  COMPONENT DECLARATION
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--  CONSTANT DECLARATION
-------------------------------------------------------------------------------
CONSTANT C_PHY_PRE                              : std_logic_vector(31 downto 0) := "11111111111111111111111111111111";                      
CONSTANT C_PHY_START                            : std_logic_vector(1 downto 0) := "01";                      
CONSTANT C_PHY_OP_WR                            : std_logic_vector(1 downto 0) := "01";
CONSTANT C_PHY_OP_RD                            : std_logic_vector(1 downto 0) := "10";
CONSTANT C_PHY_MARVELL_ADDR                     : std_logic_vector(4 downto 0) := "00001";--1
                                          
-- Registers Address                      
CONSTANT C_PHY_MARVELL_ADRR_REG_PAGE_SELECTION  : std_logic_vector(4 downto 0) := "10110";--22 = h(16)
CONSTANT C_PHY_MARVELL_ADRR_REG_SPECIAL_DELAY   : std_logic_vector(4 downto 0) := "10101";--21 = h(15)
CONSTANT C_PHY_MARVELL_ADDR_REG_CTRL            : std_logic_vector(4 downto 0) := "00000";--(00)h
                                          
CONSTANT C_PHY_TA_WR                            : std_logic_vector(1 downto 0) := "10"; --10
CONSTANT C_PHY_TA_RD                            : std_logic_vector(1 downto 0) := "Z0"; --Z0

-- Registers values
CONSTANT C_PHY_MARVELL_DATA_GOPAGE2             : std_logic_vector(15 downto 0) := "0000000000000010";--02
CONSTANT C_PHY_MARVELL_DATA_GOPAGE0             : std_logic_vector(15 downto 0) := "0000000000000000";--0000
CONSTANT C_PHY_MARVELL_DATA_RGMII_TIM           : std_logic_vector(15 downto 0) := "0000000001110000";-- config reg 4 & 5 + 13&6 = 0070 = 1000Mbps bit6=1, bit13=0
CONSTANT C_PHY_MARVELL_DATA_CONFIGURECTRL       : std_logic_vector(15 downto 0) := "0000000101000000";--config 13(0) &6(1) + 8(1) for 1Gbps duplex
CONSTANT C_PHY_MARVELL_DATA_RESETSOFT           : std_logic_vector(15 downto 0) := "1000000101000000";--config 13(0) &6(1) + 8(1) for 1Gbps duplex + RESET (bit 15)

CONSTANT C_MDIO_FRAME_SIZE                      : NATURAL := 64;
-------------------------------------------------------------------------------
--  TYPE DECLARATION
-------------------------------------------------------------------------------
type   T_PHY_MARVELL_MANAGEMENT is (WaitInitial, PageTwo, WaitInterOne, ConfDelay, WaitInterTwo, PageZero, WaitInterThree, ConfSpeed, WaitInterFour,ResetSoftware,EndPhySequence); 
signal StateCurrent                             : T_PHY_MARVELL_MANAGEMENT;
-------------------------------------------------------------------------------
--  SIGNAL DECLARATION
-------------------------------------------------------------------------------
signal s_FrameCounter                           : natural RANGE 0 TO C_MDIO_FRAME_SIZE; -- Size of one MDIO frame
signal s_PhyParameters                          : std_logic_vector(C_MDIO_FRAME_SIZE-1 downto 0); -- MDIO frame vector

begin
-------------------------------------------------------------------------------
--  COMPONENT INSTANTATION
-------------------------------------------------------------------------------


-- ============================================================================
-------------------------------------------------------------------------------
--  ARCHITECTURE DEFINITION
-------------------------------------------------------------------------------
-- ==============
-- MDIO format ==
-- ==============
-- Pre = 32 x '1'                           => C_PHY_PRE 
-- Start =  "01"                            => C_PHY_START & C_PHY_OP_WR
-- OP = 10: Read ; 01:Write                 => C_PHY_OP_WR || C_PHY_OP_RD
-- PHY addr : 5 bits                        => C_PHY_MARVELL_ADDR_xxx
-- Reg adr: 5bits                           => C_PHY_MARVELL_DATA_yyy
-- TA= 10:write, nothing in read (or 01)    => C_PHY_TA
-- Data= 16 bits                            ==> Register Data (depend from the register to configure)    
-- Total = 32+2+2+5+5+2+16=64                    



-- ======================
-- PHY MARVELL 88e151x ==
-- ======================
-- Help -> https://www.fpgadeveloper.com/2018/05/board-bring-up-myir-myd-y7z010-dev-board.html
-- Help --> (xemacpsif_physpeed.c -> get_Marvell_phy_speed) (xaxiemacif_physpeed.c -> get_phy_speed_88E1116R
-- Help --> jjohnson@opsero.com
-- PHY_88E1111_RGMII_RX_CLOCK_DELAYED_MASK = 0x0080
-- IEEE_RGMII_TXRX_CLOCK_DELAYED_MASK = 0x0030
-- RGMII (10/100/1000) and not SGMII or MII


-------------------------------------------------------------------------------
--  ASSIGNMENT
-------------------------------------------------------------------------------
-- None


-------------------------------------
-- PROCESS synchronous
-- Functionnal Desc: Configuration for 1Gbps full duplex
--  a- go on page 2 (using registre 22)
--  b- Tx and Rx clock delay (using registre 21) -> (tx : bit 4 of reg 21 of page 2, rx : bit 5 of reg 21 of page 2)
--  c- go on page 0 (using registre 22)
--  d- Enable autoneg (registre 12)
--  e- Speed & duplex select (registre 13 - 8 - 6)
--  f- reset (registre 15)
----------------------------------------
-- Desc: Manage the parameters transmission through the MDIO bus for the Marvell PHY
--       STATE : 0000 : WAIT some initial time
--       STATE : 0001 : configure the page  
--       STATE : 0010 : WAIT some time
--       STATE : 0011 : configure TXRX delay + speed   
--       STATE : 0100 : WAIT some time
--       STATE : 0101 : configure the page
--       STATE : 0110 : WAIT some time
--       STATE : 0111 : configure speed + duplex + autoneg
--       STATE : 1000 : WAIT some time
--       STATE : 1001 : software reset
--       STATE : 1010 : End of the sequence
------------------------------------- 

SequencePhyConf : process(i_Reset_n,i_ClkMdc)
begin
    if i_Reset_n = '0' then
        o_MdioOE       <= '0';    
        o_MdioOut      <= 'Z';        
        s_FrameCounter <= C_MDIO_FRAME_SIZE-1;
        s_PhyParameters(C_MDIO_FRAME_SIZE-1 downto 0) <= (others =>'0');  
        StateCurrent <= WaitInitial;

    elsif rising_edge (i_ClkMdc) then   
        case StateCurrent is
            when WaitInitial =>
                o_MdioOE <= '0';
                o_MdioOut <= 'Z';
                if s_FrameCounter = 0 then 
                    s_FrameCounter <= C_MDIO_FRAME_SIZE-1;
                    s_PhyParameters <= C_PHY_PRE & C_PHY_START & C_PHY_OP_WR & C_PHY_MARVELL_ADDR & C_PHY_MARVELL_ADRR_REG_PAGE_SELECTION & C_PHY_TA_WR & C_PHY_MARVELL_DATA_GOPAGE2;
                    StateCurrent <= PageTwo;                    
                else
                    s_FrameCounter <= s_FrameCounter - 1;
                    StateCurrent <= WaitInitial;
                end if;
                
                
            when PageTwo =>
                o_MdioOE <= '1';
                o_MdioOut <= s_PhyParameters(s_FrameCounter);
                if s_FrameCounter = 0 then 
                    s_FrameCounter <= C_MDIO_FRAME_SIZE-1;
                    s_PhyParameters <= (others =>'0'); 
                    StateCurrent <= WaitInterOne;                    
                else
                    s_FrameCounter <= s_FrameCounter - 1;
                    StateCurrent <= PageTwo;
                end if;            
        
            
            when WaitInterOne =>
                o_MdioOE <= '0';
                o_MdioOut <= 'Z';
                if s_FrameCounter = 0 then 
                    s_FrameCounter <= C_MDIO_FRAME_SIZE-1;
                    s_PhyParameters <= C_PHY_PRE & C_PHY_START & C_PHY_OP_RD & C_PHY_MARVELL_ADDR & C_PHY_MARVELL_ADRR_REG_SPECIAL_DELAY & C_PHY_TA_WR & C_PHY_MARVELL_DATA_RGMII_TIM;
                    StateCurrent <= ConfDelay;                    
                else
                    s_FrameCounter <= s_FrameCounter - 1;
                    StateCurrent <= WaitInterOne;
                end if;            
                
                
            when ConfDelay =>
                if s_FrameCounter > 15 then
                    o_MdioOE <= '1';
                    o_MdioOut <= s_PhyParameters(s_FrameCounter);
                else 
                    o_MdioOE <= '0';
                    o_MdioOut <= 'Z';
                end if;
                if s_FrameCounter = 0 then 
                    s_FrameCounter <= C_MDIO_FRAME_SIZE-1;
                    s_PhyParameters <= (others =>'0'); 
                    StateCurrent <= WaitInterTwo;                    
                else
                    s_FrameCounter <= s_FrameCounter - 1;
                    StateCurrent <= ConfDelay;
                end if;                
            
            
            when WaitInterTwo =>
                o_MdioOE <= '0';
                o_MdioOut <= 'Z';
                if s_FrameCounter = 0 then 
                    s_FrameCounter <= C_MDIO_FRAME_SIZE-1;
                    s_PhyParameters <= C_PHY_PRE & C_PHY_START & C_PHY_OP_WR & C_PHY_MARVELL_ADDR & C_PHY_MARVELL_ADRR_REG_PAGE_SELECTION & C_PHY_TA_WR & C_PHY_MARVELL_DATA_GOPAGE0;
                    StateCurrent <= PageZero;                    
                else
                    s_FrameCounter <= s_FrameCounter - 1;
                    StateCurrent <= WaitInterTwo;
                end if;        

                
            when PageZero =>
                o_MdioOE <= '1';
                o_MdioOut <= s_PhyParameters(s_FrameCounter);
                if s_FrameCounter = 0 then 
                    s_FrameCounter <= C_MDIO_FRAME_SIZE-1;
                    s_PhyParameters <= (others =>'0'); 
                    StateCurrent <= WaitInterThree;                    
                else
                    s_FrameCounter <= s_FrameCounter - 1;
                    StateCurrent <= PageZero;
                end if;    
                
            
            when WaitInterThree =>
                o_MdioOE <= '0';
                o_MdioOut <= 'Z';
                if s_FrameCounter = 0 then 
                    s_FrameCounter <= C_MDIO_FRAME_SIZE-1;
                    s_PhyParameters <= C_PHY_PRE & C_PHY_START & C_PHY_OP_RD & C_PHY_MARVELL_ADDR & C_PHY_MARVELL_ADDR_REG_CTRL & C_PHY_TA_WR & C_PHY_MARVELL_DATA_CONFIGURECTRL;
                    StateCurrent <= ConfSpeed;                    
                else
                    s_FrameCounter <= s_FrameCounter - 1;
                    StateCurrent <= WaitInterThree;
                end if;    

                
            when ConfSpeed =>
                if s_FrameCounter > 15 then
                    o_MdioOE <= '1';
                    o_MdioOut <= s_PhyParameters(s_FrameCounter);
                else 
                    o_MdioOE <= '0';
                    o_MdioOut <= 'Z';
                end if;
                if s_FrameCounter = 0 then 
                    s_FrameCounter <= C_MDIO_FRAME_SIZE-1;
                    s_PhyParameters <= (others =>'0'); 
                    StateCurrent <= WaitInterFour;                    
                else
                    s_FrameCounter <= s_FrameCounter - 1;
                    StateCurrent <= ConfSpeed;
                end if;    

                
            when WaitInterFour =>
                o_MdioOE <= '0';
                o_MdioOut <= 'Z';
                if s_FrameCounter = 0 then 
                    s_FrameCounter <= C_MDIO_FRAME_SIZE-1;
                    s_PhyParameters <= C_PHY_PRE & C_PHY_START & C_PHY_OP_WR & C_PHY_MARVELL_ADDR & C_PHY_MARVELL_ADDR_REG_CTRL & C_PHY_TA_WR & C_PHY_MARVELL_DATA_RESETSOFT;
                    StateCurrent <= ResetSoftware;                    
                else
                    s_FrameCounter <= s_FrameCounter - 1;
                    StateCurrent <= WaitInterFour;
                end if;                
            
            when ResetSoftware =>
                o_MdioOE <= '1';
                o_MdioOut <= s_PhyParameters(s_FrameCounter);
                if s_FrameCounter = 0 then 
                    s_FrameCounter <= C_MDIO_FRAME_SIZE-1;
                    s_PhyParameters <= (others =>'0'); 
                    StateCurrent <= EndPhySequence;                    
                else
                    s_FrameCounter <= s_FrameCounter - 1;
                    StateCurrent <= ResetSoftware;
                end if;    

                
            when EndPhySequence =>
                o_MdioOE <= '0';
                o_MdioOut <= 'Z';
                s_FrameCounter <= C_MDIO_FRAME_SIZE-1;
                s_PhyParameters <= (others =>'0'); 
                StateCurrent <= EndPhySequence;                    
            
            
            when others =>
                StateCurrent <= WaitInitial;
      
            end case;
        
    end if;
end process SequencePhyConf;

end rtl;