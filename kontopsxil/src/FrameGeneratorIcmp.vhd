--   ----------------------------------------------------------------------------------------------
--   Nom du fichier    	: FrameGeneratorIcmp.vhd  
--   Auteur             : Benjamin Disson
--   Date de creation	: 21/01/2021
--   Version            : 1.0
--   Description        : Génération de données ICMP
--   Sous module        : Aucun
--   Modifications    
--   ----------------------------------------------------------------------------------------------
--   Date             	: Ver. 	: Auteur       		: Commentaires
--   ----------------------------------------------------------------------------------------------
--   21/01/2021	        : 1.0   : Benjamin Disson  	: Creation 


-------------------------------------------------------------------------------
--  Déclaration des bibliothèques
-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;   

-- ============================================================================

entity  FrameGeneratorIcmp  is
port ( 	
    -- Clock et Reset
    i_sys_clk_tx    : in  std_logic;                        -- System Clock              
    i_arst_n        : in  std_logic;                        -- Asynchronous reset  
    
    i_Run           : in std_logic;        
    
    -- Data out
	o_Tx            : out std_logic_vector(7 downto 0);     -- Data
	o_TxEn 		    : out std_logic                         -- Valid signal
	);
end FrameGeneratorIcmp;

architecture  rtl  of  FrameGeneratorIcmp  is
-------------------------------------------------------------------------------
--  COMPONENT DECLARATION
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
--  CONSTANT DECLARATION
-------------------------------------------------------------------------------
CONSTANT C_FRAME_MAX_SIZE   : integer := 1000;
CONSTANT C_NB_REG_PRBS      : integer := 15;
CONSTANT C_SRC_MAC          : std_logic_vector(6*8-1 downto 0) := x"001234567890";
CONSTANT C_DST_MAC          : std_logic_vector(6*8-1 downto 0) := x"0010A47BEA80";
CONSTANT C_LENGHT           : std_logic_vector(2*8-1 downto 0) := x"0800";--128
-------------------------------------------------------------------------------
--  TYPE DECLARATION
-------------------------------------------------------------------------------
type   T_FRAME_SENDING is (WaitToBegin, SendPreamble, SendSof, SendDest, SendSrc, SendLenght, SendPayload, SendCRC, WaitForIFG); 
signal StateCurrent : T_FRAME_SENDING;

-------------------------------------------------------------------------------
--  SIGNAL DECLARATION
-------------------------------------------------------------------------------
signal s_BitCounter 		: natural range C_FRAME_MAX_SIZE downto 0;  -- Counter to pass through the different frame phases
signal s_prbs 				: std_logic_vector(C_NB_REG_PRBS downto 0); -- Generateur de polynome
signal s_ActivePrbs 		: std_logic; 					            -- Active la PRBS
signal s_InitCrc            : std_logic;                                -- Pour réinitialiser le CRC
signal s_RunCrc             : std_logic;                                -- Pour lancer le calcul du CRC sur les bits utiles
signal s_Crc8b              : std_logic_vector(31 downto 0);            -- Valeur du CRC
signal s_NotCrc8b           : std_logic_vector(31 downto 0);            -- Inversion du CRC
signal s_DataForCrc         : std_logic_vector(7 downto 0);             -- Données de sortie

-- PRE = 7 octets
-- SOF = 1 octet
-- DA  = 6 octets
-- SA  = 6 octets
-- TYP = 2 octets
-- PAY = 46 octes
-- CRC = 4 octets
-- IFG = 12 octets
-- = 72 + 12 (IFG) = 84
-- + 916 of separation 


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
            s_ActivePrbs <='0';        
            StateCurrent <= WaitToBegin;
                                        
        elsif rising_edge(i_sys_clk_tx) then
            case StateCurrent is
                when WaitToBegin =>
                    o_Tx    <= (others =>'0');
                    o_TxEn  <= '0';
                    s_InitCrc <= '1';
                    s_RunCrc  <= '0';
                    s_DataForCrc <= (others =>'0');
                    s_ActivePrbs <='0';
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
                    s_ActivePrbs <='0';                
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
                    s_ActivePrbs <='0';
                    StateCurrent <= SendDest;
       
                    
                when SendDest => -- 6 octets : bit_counter = 14 -- OLD : 6 octets = 48/4 = 12    + 16 = 28
                    --o_Tx    <= C_DST_MAC((s_BitCounter-9)*8+7 downto (s_BitCounter-9)*8);
                    o_Tx    <= C_DST_MAC((47-((s_BitCounter-9)*8)) downto (40-((s_BitCounter-9)*8)));
                    o_TxEn  <= '1';
                    s_InitCrc <= '0';
                    s_RunCrc  <= '1';
                    --s_DataForCrc <= C_DST_MAC((s_BitCounter-9)*8+7 downto (s_BitCounter-9)*8);
                    --s_DataForCrc <= C_DST_MAC((47-((s_BitCounter-9)*8)) downto (40-((s_BitCounter-9)*8)));
					s_DataForCrc(7) <= C_DST_MAC((40-((s_BitCounter-9)*8)));
					s_DataForCrc(6) <= C_DST_MAC((41-((s_BitCounter-9)*8)));
					s_DataForCrc(5) <= C_DST_MAC((42-((s_BitCounter-9)*8)));
					s_DataForCrc(4) <= C_DST_MAC((43-((s_BitCounter-9)*8)));
					s_DataForCrc(3) <= C_DST_MAC((44-((s_BitCounter-9)*8)));
					s_DataForCrc(2) <= C_DST_MAC((45-((s_BitCounter-9)*8)));
					s_DataForCrc(1) <= C_DST_MAC((46-((s_BitCounter-9)*8)));
					s_DataForCrc(0) <= C_DST_MAC((47-((s_BitCounter-9)*8)));
                    s_ActivePrbs <='0';
                    if s_BitCounter = 14 then --28 then
                        StateCurrent <= SendSrc;
                    else
                        StateCurrent <= SendDest;
                    end if;
               
                when SendSrc => -- 6 octets : bit_counter = 20 -- OLD : 6 octets = 48/4 = 12    + 28 = 40
                    --o_Tx    <= C_SRC_MAC((s_BitCounter-15)*8+7 downto (s_BitCounter-15)*8);
                    o_Tx    <= C_SRC_MAC((47-((s_BitCounter-15)*8)) downto (40-((s_BitCounter-15)*8)));
                    o_TxEn  <= '1';
                    s_InitCrc <= '0';
                    s_RunCrc  <= '1';
                    --s_DataForCrc <= C_SRC_MAC((s_BitCounter-15)*8+7 downto (s_BitCounter-15)*8);
					s_DataForCrc(7) <= C_SRC_MAC((40-((s_BitCounter-15)*8)));
					s_DataForCrc(6) <= C_SRC_MAC((41-((s_BitCounter-15)*8)));
					s_DataForCrc(5) <= C_SRC_MAC((42-((s_BitCounter-15)*8)));
					s_DataForCrc(4) <= C_SRC_MAC((43-((s_BitCounter-15)*8)));
					s_DataForCrc(3) <= C_SRC_MAC((44-((s_BitCounter-15)*8)));
					s_DataForCrc(2) <= C_SRC_MAC((45-((s_BitCounter-15)*8)));
					s_DataForCrc(1) <= C_SRC_MAC((46-((s_BitCounter-15)*8)));
					s_DataForCrc(0) <= C_SRC_MAC((47-((s_BitCounter-15)*8)));
                    s_ActivePrbs <='0';
                    if s_BitCounter = 20 then --40 then
                        StateCurrent <= SendLenght;
                    else
                        StateCurrent <= SendSrc;
                    end if;        
                    
                when SendLenght => -- 2 octets : bit_counter = 22 -- OLD 16/4 = 4    + 40 = 44
                    --o_Tx    <= C_LENGHT((s_BitCounter-21)*8+7 downto (s_BitCounter-21)*8);
                    o_Tx    <= C_LENGHT((15-((s_BitCounter-21)*8)) downto (8-((s_BitCounter-21)*8)));
                    o_TxEn  <= '1';
                    s_InitCrc <= '0';
                    s_RunCrc  <= '1';           
                    --s_DataForCrc <= C_LENGHT((s_BitCounter-21)*8+7 downto (s_BitCounter-21)*8);       
					s_DataForCrc(7) <= C_LENGHT((8-((s_BitCounter-21)*8)));
                    s_DataForCrc(6) <= C_LENGHT((9-((s_BitCounter-21)*8)));
					s_DataForCrc(5) <= C_LENGHT((10-((s_BitCounter-21)*8)));
					s_DataForCrc(4) <= C_LENGHT((11-((s_BitCounter-21)*8)));
					s_DataForCrc(3) <= C_LENGHT((12-((s_BitCounter-21)*8)));
					s_DataForCrc(2) <= C_LENGHT((13-((s_BitCounter-21)*8)));
					s_DataForCrc(1) <= C_LENGHT((14-((s_BitCounter-21)*8)));
					s_DataForCrc(0) <= C_LENGHT((15-((s_BitCounter-21)*8)));
                    
                    if s_BitCounter = 22 then
                        StateCurrent <= SendPayload;
                        s_ActivePrbs <='1';
                    else
                        StateCurrent <= SendLenght;
                        s_ActivePrbs <='0';
                    end if;            
                
                when SendPayload => -- 128 octets : bit_counter = 150 -- OLD 1024/4 = 256 + 44 = 300
                    o_Tx    <= s_prbs(15 downto 8);
                    o_TxEn  <= '1';
                    s_InitCrc <= '0';
                    s_RunCrc  <= '1'; 
                    --s_DataForCrc <= s_prbs(15 downto 8);
					s_DataForCrc(7) <= s_prbs(8);
					s_DataForCrc(6) <= s_prbs(9);
					s_DataForCrc(5) <= s_prbs(10);
					s_DataForCrc(4) <= s_prbs(11);
					s_DataForCrc(3) <= s_prbs(12);
					s_DataForCrc(2) <= s_prbs(13);
					s_DataForCrc(1) <= s_prbs(14);
					s_DataForCrc(0) <= s_prbs(15);      					
                    if s_BitCounter = 68 then
                        StateCurrent <= SendCRC;                 
                        s_ActivePrbs <='0';
                    else
                        StateCurrent <= SendPayload;
                        s_ActivePrbs <='1';
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
                    s_ActivePrbs <='0';
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
                    s_ActivePrbs <='0';
                    
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
    -- Desc: Formation de la trame   
    ------------------------------------- 
    --ProcFrameOrganiz : process(s_BitCounter) --<StateCurrent>, <s_prbs>, <s_Crc8b>, <s_NotCrc8b>
    -- ProcFrameOrganiz : process(s_BitCounter,StateCurrent, s_prbs, s_Crc8b, s_NotCrc8b)
    -- begin
        
            
            
    -- end process ProcFrameOrganiz;

    -------------------------------------
    -- PROCESS synchronous
    -- Desc: Generation de la PRBS 
    --       PRBS pattern 16-dits (65536 values)
    --       standart ITU-T O.150/O.151 = x15+x14+1 
    ------------------------------------- 

    ProcPrbs : process ( i_arst_n , i_sys_clk_tx )
        variable v_LfsrCpt  : natural range C_NB_REG_PRBS downto 0; -- Nombre de bascules necessaire pour une prbs-16 bits
    begin
        if i_arst_n = '0' then
            s_prbs <= (others => '1' );
        elsif rising_edge (i_sys_clk_tx) then
            if s_ActivePrbs='1' then
                s_prbs(0)<= s_prbs(15) XOR s_prbs(14);
                for v_LfsrCpt in C_NB_REG_PRBS downto 1 loop  
                    s_prbs(v_LfsrCpt) <= s_prbs(v_LfsrCpt-1); 
                end loop;
            else 
                s_prbs <= (others =>'1');
            end if;
        end if;
    end process ProcPrbs;

    -- ------------------------------------------
    -- PROCESS synchronous
    -- Desc: Compute the Crc8b
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


