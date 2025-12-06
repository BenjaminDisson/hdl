--   ----------------------------------------------------------------------------------------------
--   Nom du fichier    	: FrameGeneratorUdpIp.vhd  
--   Auteur             : Benjamin Disson
--   Date de creation	: 21/09/2016
--   Version            : 1.0
--   Description        : Génération de données de remplissage pour une trame Ethernet utilisant une PRBS
--   Sous module        : Aucun
--   Modifications    
--   ----------------------------------------------------------------------------------------------
--   Date             	: Ver. 	: Auteur       		: Commentaires
--   ----------------------------------------------------------------------------------------------
--   21/09/2016	        : 1.0   : Benjamin Disson  	: Creation 
--	 09/04/2018	        : 2.0   : Amrine Goulamaly 	: Tx data on 4 bits
--   05/06/2021         : 3.0   : Benjamin Disson  	: Different version MII, GMII
--   13/01/2022         : 4.0   : Benjamin Disson   : RGMII - use an UdpIP payload

-------------------------------------------------------------------------------
--  Déclaration des bibliothèques
-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;   

-- ============================================================================

entity  FrameGeneratorUdpIp  is
port ( 	
    -- Clock et Reset
    i_sys_clk_tx    : in  std_logic;                        -- System Clock              
    i_arst_n        : in  std_logic;                        -- Asynchronous reset  
    
    i_Run           : in std_logic;    
    -- Data out
	o_Tx            : out std_logic_vector(7 downto 0);     -- Data
	o_TxEn 		    : out std_logic                         -- Valid signal
	);	
end FrameGeneratorUdpIp;

architecture  rtl  of  FrameGeneratorUdpIp  is
-------------------------------------------------------------------------------
--  COMPONENT DECLARATION
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--  CONSTANT DECLARATION
-------------------------------------------------------------------------------
CONSTANT C_FRAME_MAX_SIZE   : integer                           := 1000;
CONSTANT C_NB_REG_PRBS      : integer                           := 15;
CONSTANT C_SRC_MAC          : std_logic_vector(6*8-1 downto 0)  := x"001234567890";
CONSTANT C_DST_MAC          : std_logic_vector(6*8-1 downto 0)  := x"0010A47BEA80";
CONSTANT C_LENGHT           : std_logic_vector(2*8-1 downto 0)  := x"0800";--128
CONSTANT C_FULLFRAME        : std_logic_vector(367 downto 0)    := x"4500002EB3FE000080110540C0A8002CC0A8000404000400001A2DE8000102030405060708090A0B0C0D0E0F1011";
CONSTANT C_PAYLOAD          : std_logic_vector(207 downto 0)    := x"04000400001A2DE8000102030405060708090A0B0C0D0E0F1011";

-------------------------------------------------------------------------------
--  TYPE DECLARATION
-------------------------------------------------------------------------------
type   T_FRAME_SENDING is (WaitToBegin, SendPreamble, SendSof, SendDest, SendSrc, SendLenght, SendIp, SendUdp,SendPayload, SendCRC, WaitForIFG); 
signal StateCurrent : T_FRAME_SENDING;

-------------------------------------------------------------------------------
--  SIGNAL DECLARATION
-------------------------------------------------------------------------------
signal s_BitCounter 		: natural range C_FRAME_MAX_SIZE downto 0;  -- Counter to pass through the different frame phases
--signal s_prbs 				: std_logic_vector(C_NB_REG_PRBS downto 0); -- Generateur de polynome
--signal s_ActivePrbs 		: std_logic; 					            -- Active la PRBS
signal s_InitCrc            : std_logic;                                -- Pour réinitialiser le CRC
signal s_RunCrc             : std_logic;                                -- Pour lancer le calcul du CRC sur les bits utiles
signal s_Crc8b              : std_logic_vector(31 downto 0);            -- Valeur du CRC
signal s_NotCrc8b           : std_logic_vector(31 downto 0);            -- Inversion du CRC
signal s_DataForCrc         : std_logic_vector(7 downto 0);             -- Données de sortie



-- IP
signal s_IpHeader              : std_logic_vector(20*8-1 downto 0); 
signal s_IpCheckSum            : std_logic_vector(15 downto 0);
signal s_IpCheckSumTmp         : std_logic_vector(23 downto 0);
signal s_IpVersion_HeadLenght  : std_logic_vector(23 downto 0);
signal s_IpTotalLengh          : std_logic_vector(23 downto 0); 
signal s_IpIdentification      : std_logic_vector(23 downto 0);  
signal s_IpFlags_FragmentOff   : std_logic_vector(23 downto 0);
signal s_IpTTL_Protocol        : std_logic_vector(23 downto 0);      
signal s_IpSrcPart1            : std_logic_vector(23 downto 0);
signal s_IpSrcPart2            : std_logic_vector(23 downto 0);
signal s_IpDstPart1            : std_logic_vector(23 downto 0);
signal s_IpDstPart2            : std_logic_vector(23 downto 0);

-- UDP
signal s_UdpHeader            : std_logic_vector(8*8-1 downto 0); 
signal s_UdpCheckSum          : std_logic_vector(15 downto 0);
signal s_UdpCheckSumTmp       : std_logic_vector(23 downto 0);
signal s_UdpSrc               : std_logic_vector(23 downto 0);
signal s_UdpDst               : std_logic_vector(23 downto 0);
signal s_Udplenght            : std_logic_vector(23 downto 0);



-- PRE = 7 octets
-- SOF = 1 octet
-- DA  = 6 octets
-- SA  = 6 octets
-- TYP = 2 octets
-- PAY = 46 octes
-- CRC = 4 octets
-- IFG = 12 octets


--55555555555555D5                            => PRE+SOF
--0010A47BEA80                                => DA
--001234567890                                => SA
--0800                                        => TYP
--4500002EB3FE000080                          => Header length and Version (8) + Type of service(8) + Total lengh (16) + Identification(16) + Fragment offset fiel(16) + Time to live (8)
--11                                          => Protocol : UDP (=11)
--0540                                        => IP_Checksum
--C0A8002C                                    => ip_src(192.168.0.44)
--C0A80004                                    => ip_dst (192.168.0.4)
--0400                                        => udp_src_port
--0400                                        => udp_dst_port
--001A                                        => udp_len (46 - 20)
--2DE8                                        => udp_Checksum (
--000102030405060708090A0B0C0D0E0F1011        => PAYLOAD
--B331881B                                    => CRC

-- *****************
-- * IP - 20 bytes *
-- *****************
-- 0           4           8                       16    19                            31
-- -------------------------------------------------------------------------------------
-- |  Version  |Head Lenght|      Service Type      |    Total lenght(payload MAC)     |
-- |                   Identification               |Flags|      Fragment offset       |
-- |      Time To Live     |         Protocol       |        IP Header Checksum        |
-- |                                          ip_src                                   |
-- |                                          ip_dst                                   |
-- -------------------------------------------------------------------------------------
-- IP Header Checksum    =
-- NOT(
-- Version & Head Lenght +
-- Total lengh           +
-- Identification        +
-- Flags & Fragment off. +
-- TTL & Protocol        +
-- IP  Checksum (=0)     +   
-- ip_src (part. 1)      +
-- ip_src (part. 2)      +
-- ip_dst (part. 1)      +
-- ip_dst (part. 2)      +
-- CARRY
-- )


-- ****************
-- * IP - 4 bytes *
-- ****************
-- ---------------------
-- | Options | Padding |
-- ---------------------


-- *****************
-- * UDP - 8 bytes *
-- *****************
-- 0           4           8                       16    19                            31
-- -------------------------------------------------------------------------------------
-- |             UDP source port                   |        UDP destination port        |
-- |   Length of UDP packet (Payload MAC - IP)     |        UDP header Checksum         |
-- -------------------------------------------------------------------------------------

-- ****************************
-- * Pseudo header - 12 bytes *
-- ****************************
-- 0           4           8                       16    19                            31
-- -------------------------------------------------------------------------------------
-- |                                          ip_src                                   |
-- |                                          ip_dst                                   |
-- |        reserved       | Protocol (IP header)  |        Lenght (from UDP header)   |
-- -------------------------------------------------------------------------------------




begin
-------------------------------------------------------------------------------
--  COMPONENT INSTANTATION
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--  ARCHITECTURE DEFINITION
-------------------------------------------------------------------------------
    -------------------------------------
    -- PROCESS synchronous
    -- Desc: Incrementation de s_BitCounter 
    --       et remise a zero   
    ------------------------------------- 
    ProcCountIncr : process(i_arst_n , i_sys_clk_tx )
    begin
        if i_arst_n = '0' then
            s_BitCounter <= 0;
        elsif rising_edge (i_sys_clk_tx) then
            if s_BitCounter = C_FRAME_MAX_SIZE and i_Run = '1' then 
                s_BitCounter <= 0 ;
            elsif  s_BitCounter = C_FRAME_MAX_SIZE and i_Run = '0' then 
                s_BitCounter <= C_FRAME_MAX_SIZE ;
            else
                s_BitCounter <= s_BitCounter + 1;
            end if;
        end if;
    end process ProcCountIncr;


    -------------------------------------
    -- PROCESS synchronous
    -- Desc: Synchronisation de la 
    --       machine à état   
    -------------------------------------        
    ProcSendFSM : process (i_arst_n,i_sys_clk_tx)
    begin
        if (i_arst_n = '0') then
            o_Tx    <= (others =>'0');
            o_TxEn  <= '0';
            s_InitCrc <= '1';
            s_RunCrc  <= '0';
            s_DataForCrc <= (others =>'0');
            --s_ActivePrbs <='0';        
            StateCurrent <= WaitToBegin;
                                        
        elsif rising_edge(i_sys_clk_tx) then
            case StateCurrent is
                when WaitToBegin =>
                    o_Tx    <= (others =>'0');
                    o_TxEn  <= '0';
                    s_InitCrc <= '1';
                    s_RunCrc  <= '0';
                    s_DataForCrc <= (others =>'0');
                    --s_ActivePrbs <='0';
                    if i_Run = '1' then
                        StateCurrent <= SendPreamble;
                    else
                        StateCurrent <= WaitToBegin;
                    end if;                    
                    
                when SendPreamble => -- 7 octets -- OLD :8 octets moins 4 bits = 60 bits /4 = 15
                    o_Tx    <= x"55";
                    o_TxEn  <= '1';
                    s_InitCrc <= '0';
                    s_RunCrc  <= '0'; 
                    s_DataForCrc <= (others =>'0');
                    --s_ActivePrbs <='0';                
                    if s_BitCounter = 7 then -- 15 => 7
                        StateCurrent <= SendSof;
                    else
                        StateCurrent <= SendPreamble;
                    end if;
                    
                when SendSof => -- 1 octet ; bit_counter = 8 -- OLD : 4 bits => 16
                    o_Tx    <= x"D5";
                    o_TxEn  <= '1';
                    s_InitCrc <= '0';
                    s_RunCrc  <= '0';    
                    s_DataForCrc <= (others =>'0');
                    --s_ActivePrbs <='0';
                    StateCurrent <= SendDest;
       
                    
                when SendDest => -- 6 octets : bit_counter = 14 -- OLD : 6 octets = 48/4 = 12    + 16 = 28
                    o_Tx    <= C_DST_MAC((47-((s_BitCounter-9)*8)) downto (40-((s_BitCounter-9)*8)));
				
                    o_TxEn  <= '1';
                    s_InitCrc <= '0';
                    s_RunCrc  <= '1';
                    --s_DataForCrc <= C_DST_MAC((47-((s_BitCounter-9)*8)) downto (40-((s_BitCounter-9)*8)));
					s_DataForCrc(7) <= C_DST_MAC((40-((s_BitCounter-9)*8)));
					s_DataForCrc(6) <= C_DST_MAC((41-((s_BitCounter-9)*8)));
					s_DataForCrc(5) <= C_DST_MAC((42-((s_BitCounter-9)*8)));
					s_DataForCrc(4) <= C_DST_MAC((43-((s_BitCounter-9)*8)));
					s_DataForCrc(3) <= C_DST_MAC((44-((s_BitCounter-9)*8)));
					s_DataForCrc(2) <= C_DST_MAC((45-((s_BitCounter-9)*8)));
					s_DataForCrc(1) <= C_DST_MAC((46-((s_BitCounter-9)*8)));
					s_DataForCrc(0) <= C_DST_MAC((47-((s_BitCounter-9)*8)));
				
				
                    --s_ActivePrbs <='0';
                    if s_BitCounter = 14 then --28 then
                        StateCurrent <= SendSrc;
                    else
                        StateCurrent <= SendDest;
                    end if;
               
                when SendSrc => -- 6 octets : bit_counter = 20 -- OLD : 6 octets = 48/4 = 12    + 28 = 40
					o_Tx    <= C_SRC_MAC((47-((s_BitCounter-15)*8)) downto (40-((s_BitCounter-15)*8)));
                    o_TxEn  <= '1';
                    s_InitCrc <= '0';
                    s_RunCrc  <= '1';
                    --s_DataForCrc <= C_SRC_MAC((47-((s_BitCounter-15)*8)) downto (40-((s_BitCounter-15)*8)));
					s_DataForCrc(7) <= C_SRC_MAC((40-((s_BitCounter-15)*8)));
					s_DataForCrc(6) <= C_SRC_MAC((41-((s_BitCounter-15)*8)));
					s_DataForCrc(5) <= C_SRC_MAC((42-((s_BitCounter-15)*8)));
					s_DataForCrc(4) <= C_SRC_MAC((43-((s_BitCounter-15)*8)));
					s_DataForCrc(3) <= C_SRC_MAC((44-((s_BitCounter-15)*8)));
					s_DataForCrc(2) <= C_SRC_MAC((45-((s_BitCounter-15)*8)));
					s_DataForCrc(1) <= C_SRC_MAC((46-((s_BitCounter-15)*8)));
					s_DataForCrc(0) <= C_SRC_MAC((47-((s_BitCounter-15)*8)));
					
					
					
                    --s_ActivePrbs <='0';
                    if s_BitCounter = 20 then --40 then
                        StateCurrent <= SendLenght;
                    else
                        StateCurrent <= SendSrc;
                    end if;        
                    
                when SendLenght => -- 2 octets : bit_counter = 22 -- OLD 16/4 = 4    + 40 = 44
					o_Tx    <= C_LENGHT((15-((s_BitCounter-21)*8)) downto (8-((s_BitCounter-21)*8)));
                    o_TxEn  <= '1';
                    s_InitCrc <= '0';
                    s_RunCrc  <= '1'; 
                    --s_DataForCrc <= C_LENGHT((15-((s_BitCounter-21)*8)) downto (8-((s_BitCounter-21)*8)));       
					s_DataForCrc(7) <= C_LENGHT((8-((s_BitCounter-21)*8)));
					s_DataForCrc(6) <= C_LENGHT((9-((s_BitCounter-21)*8)));
					s_DataForCrc(5) <= C_LENGHT((10-((s_BitCounter-21)*8)));
					s_DataForCrc(4) <= C_LENGHT((11-((s_BitCounter-21)*8)));
					s_DataForCrc(3) <= C_LENGHT((12-((s_BitCounter-21)*8)));
					s_DataForCrc(2) <= C_LENGHT((13-((s_BitCounter-21)*8)));
					s_DataForCrc(1) <= C_LENGHT((14-((s_BitCounter-21)*8)));
					s_DataForCrc(0) <= C_LENGHT((15-((s_BitCounter-21)*8)));       
					
					
                    if s_BitCounter = 22 then
                        StateCurrent <= SendIp;
                        --s_ActivePrbs <='1';
                    else
                        StateCurrent <= SendLenght;
                        --s_ActivePrbs <='0';
                    end if;            
                              
				
				when SendIp =>
				    o_Tx    <= s_IpHeader(8*20-1-((s_BitCounter-23)*8) downto 8*20-8-((s_BitCounter-23)*8));
					o_TxEn  <= '1';
                    s_InitCrc <= '0';
                    s_RunCrc  <= '1'; 
					
					s_DataForCrc(7) <= s_IpHeader((152-((s_BitCounter-23)*8)));
					s_DataForCrc(6) <= s_IpHeader((153-((s_BitCounter-23)*8)));
					s_DataForCrc(5) <= s_IpHeader((154-((s_BitCounter-23)*8)));
					s_DataForCrc(4) <= s_IpHeader((155-((s_BitCounter-23)*8)));
					s_DataForCrc(3) <= s_IpHeader((156-((s_BitCounter-23)*8)));
					s_DataForCrc(2) <= s_IpHeader((157-((s_BitCounter-23)*8)));
					s_DataForCrc(1) <= s_IpHeader((158-((s_BitCounter-23)*8)));
					s_DataForCrc(0) <= s_IpHeader((159-((s_BitCounter-23)*8)));   
					
					
					if s_BitCounter = 42 then
                        StateCurrent <= SendUdp;                 
                        --s_ActivePrbs <='0';
                    else
                        StateCurrent <= SendIp;
                        --s_ActivePrbs <='1';
                    end if; 
					
					
				
				when SendUdp =>
				    o_Tx    <= s_UdpHeader(8*8-1-((s_BitCounter-43)*8) downto 8*8-8-((s_BitCounter-43)*8));
					o_TxEn  <= '1';
                    s_InitCrc <= '0';
                    s_RunCrc  <= '1'; 
					
					s_DataForCrc(7) <= s_UdpHeader((56-((s_BitCounter-43)*8)));
					s_DataForCrc(6) <= s_UdpHeader((57-((s_BitCounter-43)*8)));
					s_DataForCrc(5) <= s_UdpHeader((58-((s_BitCounter-43)*8)));
					s_DataForCrc(4) <= s_UdpHeader((59-((s_BitCounter-43)*8)));
					s_DataForCrc(3) <= s_UdpHeader((60-((s_BitCounter-43)*8)));
					s_DataForCrc(2) <= s_UdpHeader((61-((s_BitCounter-43)*8)));
					s_DataForCrc(1) <= s_UdpHeader((62-((s_BitCounter-43)*8)));
					s_DataForCrc(0) <= s_UdpHeader((63-((s_BitCounter-43)*8))); 				
				
				
				
				if s_BitCounter = 50 then
                        StateCurrent <= SendPayload;                 
                        --s_ActivePrbs <='0';
                    else
                        StateCurrent <= SendUdp;
                        --s_ActivePrbs <='1';
                    end if; 
				
				
				when SendPayload => -- 128 octets : bit_counter = 150 -- OLD 1024/4 = 256 + 44 = 300
                    --o_Tx    <= C_FULLFRAME((367-((s_BitCounter-51)*8)) downto (360-((s_BitCounter-51)*8)));
					o_Tx    <= C_FULLFRAME((143-((s_BitCounter-51)*8)) downto (136-((s_BitCounter-51)*8)));
                    o_TxEn  <= '1';
                    s_InitCrc <= '0';
                    s_RunCrc  <= '1'; 
                    --s_DataForCrc <= C_FULLFRAME((367-((s_BitCounter-23)*8)) downto (360-((s_BitCounter-23)*8)));
					s_DataForCrc(7) <= C_FULLFRAME((136-((s_BitCounter-51)*8)));
					s_DataForCrc(6) <= C_FULLFRAME((137-((s_BitCounter-51)*8)));
					s_DataForCrc(5) <= C_FULLFRAME((138-((s_BitCounter-51)*8)));
					s_DataForCrc(4) <= C_FULLFRAME((139-((s_BitCounter-51)*8)));
					s_DataForCrc(3) <= C_FULLFRAME((140-((s_BitCounter-51)*8)));
					s_DataForCrc(2) <= C_FULLFRAME((141-((s_BitCounter-51)*8)));
					s_DataForCrc(1) <= C_FULLFRAME((142-((s_BitCounter-51)*8)));
					s_DataForCrc(0) <= C_FULLFRAME((143-((s_BitCounter-51)*8)));      					

					
                    if s_BitCounter = 68 then -- = 51 + payload size (18)
                        StateCurrent <= SendCRC;                 
                        --s_ActivePrbs <='0';
                    else
                        StateCurrent <= SendPayload;
                        --s_ActivePrbs <='1';
                    end if;  

				
				
                when SendCRC => -- 4 octets : bit_counter = 154 -- OLD  32/4 = 8 + 300 = 308
                    if s_BitCounter = 69 then --151 then -- on anticipe car le clacul du crc est synchrone et fait perdre 1 coup d'horloge
						o_Tx(7) <= not(s_Crc8b(16) xor s_Crc8b(25) xor s_Crc8b(26) xor s_Crc8b(31) xor s_DataForCrc(1) xor s_DataForCrc(2) xor s_DataForCrc(7));
						o_Tx(6) <= not(s_Crc8b(17) xor s_Crc8b(26) xor s_Crc8b(27) xor s_DataForCrc(2) xor s_DataForCrc(3));
						o_Tx(5) <= not(s_Crc8b(18) xor s_Crc8b(24) xor s_Crc8b(27) xor s_Crc8b(28) xor s_Crc8b(30) xor s_DataForCrc(0) xor s_DataForCrc(3) xor s_DataForCrc(4) xor s_DataForCrc(6));
						o_Tx(4) <= not(s_Crc8b(19) xor s_Crc8b(25) xor s_Crc8b(28) xor s_Crc8b(29) xor s_Crc8b(31) xor s_DataForCrc(1) xor s_DataForCrc(4) xor s_DataForCrc(5) xor s_DataForCrc(7));
						o_Tx(3) <= not(s_Crc8b(20) xor s_Crc8b(26) xor s_Crc8b(29) xor s_Crc8b(30) xor s_DataForCrc(2) xor s_DataForCrc(5) xor s_DataForCrc(6));
						o_Tx(2) <= not(s_Crc8b(21) xor s_Crc8b(27) xor s_Crc8b(30) xor s_Crc8b(31) xor s_DataForCrc(3) xor s_DataForCrc(6) xor s_DataForCrc(7));
						o_Tx(1) <= not(s_Crc8b(22) xor s_Crc8b(28) xor s_Crc8b(31) xor s_DataForCrc(4) xor s_DataForCrc(7));
						o_Tx(0) <= not(s_Crc8b(23) xor s_Crc8b(29) xor s_DataForCrc(5));   			
                    else
                        --o_Tx    <= s_NotCrc8b(31+(151-s_BitCounter)*8 downto 31+(151-s_BitCounter)*8-7);
						--o_Tx    <= s_NotCrc8b(31+(69-s_BitCounter)*8 downto 31+(69-s_BitCounter)*8-7);
						o_Tx(7)   <= s_NotCrc8b(24-((s_BitCounter-69)*8));
						o_Tx(6)   <= s_NotCrc8b(25-((s_BitCounter-69)*8));
						o_Tx(5)   <= s_NotCrc8b(26-((s_BitCounter-69)*8));
						o_Tx(4)   <= s_NotCrc8b(27-((s_BitCounter-69)*8));
						o_Tx(3)   <= s_NotCrc8b(28-((s_BitCounter-69)*8));
						o_Tx(2)   <= s_NotCrc8b(29-((s_BitCounter-69)*8));
						o_Tx(1)   <= s_NotCrc8b(30-((s_BitCounter-69)*8));
						o_Tx(0)   <= s_NotCrc8b(31-((s_BitCounter-69)*8));
						
												
						
                    end if;
                    o_TxEn  <= '1';
                    s_InitCrc <= '0';
                    s_RunCrc  <= '0'; 
                    s_DataForCrc <= (others =>'0');
                    --s_ActivePrbs <='0';
                    if s_BitCounter = 72 then --154 then
                        StateCurrent <= WaitForIFG;
                    else
                        StateCurrent <= SendCRC;
                    end if;             
                
                when WaitForIFG => -- 12 octets : bit_counter = 166 -- OLD : 96/4 = 24    + 308 = 332
                    o_Tx    <= (others =>'0');
                    o_TxEn  <= '0';
                    s_InitCrc <= '1';
                    s_RunCrc  <= '0';
                    s_DataForCrc <= (others =>'0');
                    --s_ActivePrbs <='0';

                    if s_BitCounter = C_FRAME_MAX_SIZE and i_Run = '0' then 
                        StateCurrent <= WaitToBegin;
                    elsif s_BitCounter = C_FRAME_MAX_SIZE and i_Run = '1' then 
                        StateCurrent <= SendPreamble;
                    else
                        StateCurrent <= WaitForIFG;
                    end if;                     
                
                when others =>
                    StateCurrent <= WaitToBegin;
            
            end case;
        
        end if;
    end process ProcSendFSM;
    
    -------------------------------------
    -- PROCESS synchronous
    -- Desc: Compute IP checksum
    ------------------------------------- 
    -- IP Header Checksum    =
    -- NOT(
    -- Version & Head Lenght +
    -- Total lengh           +
    -- Identification        +
    -- Flags & Fragment off. +
    -- TTL & Protocol        +
    -- IP  Checksum (=0)     +   
    -- ip_src (part. 1)      +
    -- ip_src (part. 2)      +
    -- ip_dst (part. 1)      +
    -- ip_dst (part. 2)      +
    -- CARRY
    -- )
    IpCheckSumProcess : process ( i_arst_n , i_sys_clk_tx )        
    begin
        if i_arst_n = '0' then
			s_IpCheckSum         <= (others => '0' );
			s_IpCheckSumTmp      <= (others => '0' );
			s_IpVersion_HeadLenght <= x"00"& C_FULLFRAME(367 downto 352);
			s_IpTotalLengh         <= x"00"& C_FULLFRAME(351 downto 336);
			s_IpIdentification     <= x"00"& C_FULLFRAME(335 downto 320);
			s_IpFlags_FragmentOff  <= x"00"& C_FULLFRAME(319 downto 304);
			s_IpTTL_Protocol       <= x"00"& C_FULLFRAME(303 downto 288);
			
			s_IpSrcPart1         <= x"00"& C_FULLFRAME(271 downto 256);
			s_IpSrcPart2         <= x"00"& C_FULLFRAME(255 downto 240);
			s_IpDstPart1         <= x"00"& C_FULLFRAME(239 downto 224);
			s_IpDstPart2         <= x"00"& C_FULLFRAME(223 downto 208);						
			
        elsif rising_edge (i_sys_clk_tx) then
            if s_BitCounter = 1 then
				s_IpCheckSumTmp <= std_logic_vector(UNSIGNED(s_IpVersion_HeadLenght) + UNSIGNED(s_IpTotalLengh) + UNSIGNED(s_IpIdentification)) ;
			elsif s_BitCounter = 2 then
				s_IpCheckSumTmp <= std_logic_vector(UNSIGNED(s_IpCheckSumTmp) + UNSIGNED(s_IpFlags_FragmentOff) + UNSIGNED(s_IpTTL_Protocol) + UNSIGNED(s_IpSrcPart1));
			elsif s_BitCounter = 3 then
				s_IpCheckSumTmp <= std_logic_vector(UNSIGNED(s_IpCheckSumTmp) + UNSIGNED(s_IpSrcPart2) + UNSIGNED(s_IpDstPart1) + UNSIGNED(s_IpDstPart2));
			elsif s_BitCounter = 4 then				
				s_IpCheckSumTmp <= std_logic_vector(UNSIGNED(x"00" & s_IpCheckSumTmp(15 downto 0)) + UNSIGNED(x"0000" & s_IpCheckSumTmp(23 downto 16)));
			elsif s_BitCounter = 5 then				
				s_IpCheckSumTmp <= std_logic_vector(UNSIGNED(x"00" & s_IpCheckSumTmp(15 downto 0)) + UNSIGNED(x"0000" & s_IpCheckSumTmp(23 downto 16)));		   
		  	elsif s_BitCounter = 6 then				
				s_IpCheckSum <= not(s_IpCheckSumTmp(15 downto 0));               
            end if;
        end if;
    end process IpCheckSumProcess;
	
    -------------------------------------
    -- PROCESS asynchronous
    -- Desc: Make the ip header 
    ------------------------------------- 
	s_IpHeader <= s_IpVersion_HeadLenght(15 downto 0) & s_IpTotalLengh(15 downto 0) & s_IpIdentification(15 downto 0) & s_IpFlags_FragmentOff(15 downto 0) & s_IpTTL_Protocol(15 downto 0) & s_IpCheckSum(15 downto 0) & s_IpSrcPart1(15 downto 0) & s_IpSrcPart2(15 downto 0) & s_IpDstPart1(15 downto 0) & s_IpDstPart2(15 downto 0);

    -------------------------------------
    -- PROCESS synchronous
    -- Desc: Compute UDP checksum
    ------------------------------------- 
    -- UDP Header Checksum    =
    -- NOT(  
    -- ip_src (part. 1)      +
    -- ip_src (part. 2)      +
    -- ip_dst (part. 1)      +
    -- ip_dst (part. 2)      +
    -- "0" & Protocol        +
    -- UDP header lengh      +
    -- UDP source port       +
    -- UDP destination port  +
    -- Length of UDP packet  +
    -- UDP data (payload)    +
    -- CARRY
    -- )

    UDPCheckSumProcess : process ( i_arst_n , i_sys_clk_tx )        
    begin
        if i_arst_n = '0' then
			s_UdpCheckSum         <= (others => '0' );
			s_UdpCheckSumTmp      <= (others => '0' );
			
			s_UdpSrc    		<= x"00"& C_PAYLOAD(207 downto 192);
			s_UdpDst            <= x"00"& C_FULLFRAME(191 downto 176);
			s_Udplenght         <= x"00"& C_FULLFRAME(175 downto 160);
			
			
        elsif rising_edge (i_sys_clk_tx) then
            if s_BitCounter = 1 then
				s_UdpCheckSumTmp <= std_logic_vector(UNSIGNED(s_IpSrcPart1) + UNSIGNED(s_IpSrcPart2) + UNSIGNED(s_IpDstPart1) + UNSIGNED(s_IpDstPart2));
				--s_IpCheckSumTmp <= std_logic_vector(UNSIGNED(s_IpVersion_HeadLenght) + UNSIGNED(s_IpTotalLengh) + UNSIGNED(s_IpIdentification)) ;
			elsif s_BitCounter = 2 then
				s_UdpCheckSumTmp <= std_logic_vector(UNSIGNED(s_UdpCheckSumTmp) + UNSIGNED(x"00" & s_IpTTL_Protocol(8 downto 0)) + UNSIGNED(s_Udplenght) + UNSIGNED(s_UdpSrc)); 
				--s_IpCheckSumTmp <= std_logic_vector(UNSIGNED(s_IpCheckSumTmp) + UNSIGNED(s_IpFlags_FragmentOff) + UNSIGNED(s_IpTTL_Protocol) + UNSIGNED(s_IpSrcPart1));
			elsif s_BitCounter = 3 then
				--s_IpCheckSumTmp <= std_logic_vector(UNSIGNED(s_IpCheckSumTmp) + UNSIGNED(s_IpSrcPart2) + UNSIGNED(s_IpDstPart1) + UNSIGNED(s_IpDstPart2));
				s_UdpCheckSumTmp <= std_logic_vector(UNSIGNED(s_UdpCheckSumTmp) +UNSIGNED(s_UdpDst) + UNSIGNED(s_Udplenght) +  UNSIGNED(C_PAYLOAD(143 downto 128))); 
			elsif s_BitCounter = 4 then				
				--s_IpCheckSumTmp <= std_logic_vector(UNSIGNED(x"00" & s_IpCheckSumTmp(15 downto 0)) + UNSIGNED(x"0000" & s_IpCheckSumTmp(23 downto 16)));
				s_UdpCheckSumTmp <= std_logic_vector(UNSIGNED(s_UdpCheckSumTmp) + UNSIGNED(C_PAYLOAD(127 downto 112)) +UNSIGNED(C_PAYLOAD(111 downto 96)) + UNSIGNED(C_PAYLOAD(95 downto 80))); 
			elsif s_BitCounter = 5 then				
				--s_IpCheckSumTmp <= std_logic_vector(UNSIGNED(x"00" & s_IpCheckSumTmp(15 downto 0)) + UNSIGNED(x"0000" & s_IpCheckSumTmp(23 downto 16)));	
				s_UdpCheckSumTmp <= std_logic_vector(UNSIGNED(s_UdpCheckSumTmp)  + UNSIGNED(C_PAYLOAD(79 downto 64)) + UNSIGNED(C_PAYLOAD(63 downto 48)) + UNSIGNED(C_PAYLOAD(47 downto 32)));				
		  	elsif s_BitCounter = 6 then				
				--s_IpCheckSum <= not(s_IpCheckSumTmp(15 downto 0));     
				s_UdpCheckSumTmp <= std_logic_vector(UNSIGNED(s_UdpCheckSumTmp)  + UNSIGNED(C_PAYLOAD(31 downto 16)) + UNSIGNED(C_PAYLOAD(15 downto 0)));   
			elsif s_BitCounter = 7 then	
				s_UdpCheckSumTmp <= std_logic_vector(UNSIGNED(x"00" & s_UdpCheckSumTmp(15 downto 0)) + UNSIGNED(x"0000" & s_UdpCheckSumTmp(23 downto 16)));
			elsif s_BitCounter = 8 then	
				s_UdpCheckSumTmp <= std_logic_vector(UNSIGNED(x"00" & s_UdpCheckSumTmp(15 downto 0)) + UNSIGNED(x"0000" & s_UdpCheckSumTmp(23 downto 16)));
			elsif s_BitCounter = 9 then	
				s_UdpCheckSum <= not(s_UdpCheckSumTmp(15 downto 0));
            end if;
        end if;
    end process UDPCheckSumProcess;

    -------------------------------------
    -- PROCESS asynchronous
    -- Desc: Make the UDP header 
    -------------------------------------    
	s_UdpHeader <= s_UdpSrc(15 downto 0) & s_UdpDst(15 downto 0) & s_Udplenght(15 downto 0) & s_UdpCheckSum(15 downto 0);
	
	
	-- ------------------------------------------
    -- PROCESS synchronous
    -- Desc: Compute the MAC Crc8b
    -- ------------------------------------------
    Crc8bProcess: process(i_arst_n,i_sys_clk_tx)
      begin
        if i_arst_n = '0' then
            s_Crc8b <= (others =>'1');
        elsif rising_edge(i_sys_clk_tx) then
            if (s_InitCrc = '1') then
                s_Crc8b <= (others =>'1');
            elsif (s_InitCrc = '0') then
                if (s_RunCrc = '1') then
					s_Crc8b(0) <= s_Crc8b(24) xor s_Crc8b(30) xor s_DataForCrc(0) xor s_DataForCrc(6);
					s_Crc8b(1) <= s_Crc8b(24) xor s_Crc8b(25) xor s_Crc8b(30) xor s_Crc8b(31) xor s_DataForCrc(0) xor s_DataForCrc(1) xor s_DataForCrc(6) xor s_DataForCrc(7);
					s_Crc8b(2) <= s_Crc8b(24) xor s_Crc8b(25) xor s_Crc8b(26) xor s_Crc8b(30) xor s_Crc8b(31) xor s_DataForCrc(0) xor s_DataForCrc(1) xor s_DataForCrc(2) xor s_DataForCrc(6) xor s_DataForCrc(7);
					s_Crc8b(3) <= s_Crc8b(25) xor s_Crc8b(26) xor s_Crc8b(27) xor s_Crc8b(31) xor s_DataForCrc(1) xor s_DataForCrc(2) xor s_DataForCrc(3) xor s_DataForCrc(7);
					s_Crc8b(4) <= s_Crc8b(24) xor s_Crc8b(26) xor s_Crc8b(27) xor s_Crc8b(28) xor s_Crc8b(30) xor s_DataForCrc(0) xor s_DataForCrc(2) xor s_DataForCrc(3) xor s_DataForCrc(4) xor s_DataForCrc(6);
					s_Crc8b(5) <= s_Crc8b(24) xor s_Crc8b(25) xor s_Crc8b(27) xor s_Crc8b(28) xor s_Crc8b(29) xor s_Crc8b(30) xor s_Crc8b(31) xor s_DataForCrc(0) xor s_DataForCrc(1) xor s_DataForCrc(3) xor s_DataForCrc(4) xor s_DataForCrc(5) xor s_DataForCrc(6) xor s_DataForCrc(7);
					s_Crc8b(6) <= s_Crc8b(25) xor s_Crc8b(26) xor s_Crc8b(28) xor s_Crc8b(29) xor s_Crc8b(30) xor s_Crc8b(31) xor s_DataForCrc(1) xor s_DataForCrc(2) xor s_DataForCrc(4) xor s_DataForCrc(5) xor s_DataForCrc(6) xor s_DataForCrc(7);
					s_Crc8b(7) <= s_Crc8b(24) xor s_Crc8b(26) xor s_Crc8b(27) xor s_Crc8b(29) xor s_Crc8b(31) xor s_DataForCrc(0) xor s_DataForCrc(2) xor s_DataForCrc(3) xor s_DataForCrc(5) xor s_DataForCrc(7);
					s_Crc8b(8) <= s_Crc8b(0) xor s_Crc8b(24) xor s_Crc8b(25) xor s_Crc8b(27) xor s_Crc8b(28) xor s_DataForCrc(0) xor s_DataForCrc(1) xor s_DataForCrc(3) xor s_DataForCrc(4);
					s_Crc8b(9) <= s_Crc8b(1) xor s_Crc8b(25) xor s_Crc8b(26) xor s_Crc8b(28) xor s_Crc8b(29) xor s_DataForCrc(1) xor s_DataForCrc(2) xor s_DataForCrc(4) xor s_DataForCrc(5);
					s_Crc8b(10) <= s_Crc8b(2) xor s_Crc8b(24) xor s_Crc8b(26) xor s_Crc8b(27) xor s_Crc8b(29) xor s_DataForCrc(0) xor s_DataForCrc(2) xor s_DataForCrc(3) xor s_DataForCrc(5);
					s_Crc8b(11) <= s_Crc8b(3) xor s_Crc8b(24) xor s_Crc8b(25) xor s_Crc8b(27) xor s_Crc8b(28) xor s_DataForCrc(0) xor s_DataForCrc(1) xor s_DataForCrc(3) xor s_DataForCrc(4);
					s_Crc8b(12) <= s_Crc8b(4) xor s_Crc8b(24) xor s_Crc8b(25) xor s_Crc8b(26) xor s_Crc8b(28) xor s_Crc8b(29) xor s_Crc8b(30) xor s_DataForCrc(0) xor s_DataForCrc(1) xor s_DataForCrc(2) xor s_DataForCrc(4) xor s_DataForCrc(5) xor s_DataForCrc(6);
					s_Crc8b(13) <= s_Crc8b(5) xor s_Crc8b(25) xor s_Crc8b(26) xor s_Crc8b(27) xor s_Crc8b(29) xor s_Crc8b(30) xor s_Crc8b(31) xor s_DataForCrc(1) xor s_DataForCrc(2) xor s_DataForCrc(3) xor s_DataForCrc(5) xor s_DataForCrc(6) xor s_DataForCrc(7);
					s_Crc8b(14) <= s_Crc8b(6) xor s_Crc8b(26) xor s_Crc8b(27) xor s_Crc8b(28) xor s_Crc8b(30) xor s_Crc8b(31) xor s_DataForCrc(2) xor s_DataForCrc(3) xor s_DataForCrc(4) xor s_DataForCrc(6) xor s_DataForCrc(7);
					s_Crc8b(15) <= s_Crc8b(7) xor s_Crc8b(27) xor s_Crc8b(28) xor s_Crc8b(29) xor s_Crc8b(31) xor s_DataForCrc(3) xor s_DataForCrc(4) xor s_DataForCrc(5) xor s_DataForCrc(7);
					s_Crc8b(16) <= s_Crc8b(8) xor s_Crc8b(24) xor s_Crc8b(28) xor s_Crc8b(29) xor s_DataForCrc(0) xor s_DataForCrc(4) xor s_DataForCrc(5);
					s_Crc8b(17) <= s_Crc8b(9) xor s_Crc8b(25) xor s_Crc8b(29) xor s_Crc8b(30) xor s_DataForCrc(1) xor s_DataForCrc(5) xor s_DataForCrc(6);
					s_Crc8b(18) <= s_Crc8b(10) xor s_Crc8b(26) xor s_Crc8b(30) xor s_Crc8b(31) xor s_DataForCrc(2) xor s_DataForCrc(6) xor s_DataForCrc(7);
					s_Crc8b(19) <= s_Crc8b(11) xor s_Crc8b(27) xor s_Crc8b(31) xor s_DataForCrc(3) xor s_DataForCrc(7);
					s_Crc8b(20) <= s_Crc8b(12) xor s_Crc8b(28) xor s_DataForCrc(4);
					s_Crc8b(21) <= s_Crc8b(13) xor s_Crc8b(29) xor s_DataForCrc(5);
					s_Crc8b(22) <= s_Crc8b(14) xor s_Crc8b(24) xor s_DataForCrc(0);
					s_Crc8b(23) <= s_Crc8b(15) xor s_Crc8b(24) xor s_Crc8b(25) xor s_Crc8b(30) xor s_DataForCrc(0) xor s_DataForCrc(1) xor s_DataForCrc(6);
					s_Crc8b(24) <= s_Crc8b(16) xor s_Crc8b(25) xor s_Crc8b(26) xor s_Crc8b(31) xor s_DataForCrc(1) xor s_DataForCrc(2) xor s_DataForCrc(7);
					s_Crc8b(25) <= s_Crc8b(17) xor s_Crc8b(26) xor s_Crc8b(27) xor s_DataForCrc(2) xor s_DataForCrc(3);
					s_Crc8b(26) <= s_Crc8b(18) xor s_Crc8b(24) xor s_Crc8b(27) xor s_Crc8b(28) xor s_Crc8b(30) xor s_DataForCrc(0) xor s_DataForCrc(3) xor s_DataForCrc(4) xor s_DataForCrc(6);
					s_Crc8b(27) <= s_Crc8b(19) xor s_Crc8b(25) xor s_Crc8b(28) xor s_Crc8b(29) xor s_Crc8b(31) xor s_DataForCrc(1) xor s_DataForCrc(4) xor s_DataForCrc(5) xor s_DataForCrc(7);
					s_Crc8b(28) <= s_Crc8b(20) xor s_Crc8b(26) xor s_Crc8b(29) xor s_Crc8b(30) xor s_DataForCrc(2) xor s_DataForCrc(5) xor s_DataForCrc(6);
					s_Crc8b(29) <= s_Crc8b(21) xor s_Crc8b(27) xor s_Crc8b(30) xor s_Crc8b(31) xor s_DataForCrc(3) xor s_DataForCrc(6) xor s_DataForCrc(7);
					s_Crc8b(30) <= s_Crc8b(22) xor s_Crc8b(28) xor s_Crc8b(31) xor s_DataForCrc(4) xor s_DataForCrc(7);
					s_Crc8b(31) <= s_Crc8b(23) xor s_Crc8b(29) xor s_DataForCrc(5);   
                end if;            
            end if;
        end if;
    end process Crc8bProcess;
    
    -------------------------------------
    -- PROCESS Asynchronous
    -- Desc: Insertion du not pour terminer
    --       le calcul du CRC
    -------------------------------------
    s_NotCrc8b <= not(s_Crc8b);

    
end rtl;


