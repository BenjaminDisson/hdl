--   ----------------------------------------------------------------------------------------------
--   Nom du fichier    	: tb_ArpTransmitterGMII.vhd  
--   Auteur             : Benjamin Disson
--   Date de creation	: 03/09/2021
--   Version            : 1.0
--   Description        : 
--   Sous module        : --
--   Modifications    
--   --------------------------------------------------------------------------
--   Date             	: Ver. 	: Auteur       		: Commentaires
--   --------------------------------------------------------------------------
--   03/09/2021	        : 1.0   : Benjamin Disson  	: Creation
--
--

-------------------------------------------------------------------------------
--  Déclaration des bibliothèques
-------------------------------------------------------------------------------
library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;
use     ieee.std_logic_textio.all;

library std;
use     std.textio.all;

entity tb_ArpTransmitterGMII is end tb_ArpTransmitterGMII;

architecture bench of tb_ArpTransmitterGMII is

-------------------------------------------------------------------------------
-- Declaration des composants
-------------------------------------------------------------------------------
component ArpTransmitterGMII
	port (
    -- Horloges et Resets 
    i_sys_clk_tx   : in  std_logic;                     -- Horloge système              
    i_arst_n    : in  std_logic;                        -- Reset matériel  

	-- MAC
	i_MacSrc      : in std_logic_vector(6*8-1 downto 0);
	i_MacDst      : in std_logic_vector(6*8-1 downto 0);

	-- IP
	i_IpSender     : in std_logic_vector(31 downto 0);
	i_IpTarget     : in std_logic_vector(31 downto 0);
	
	-- Protocol launch
	i_RunArp       : in std_logic;	
	
	o_Tx        : out std_logic_vector(7 downto 0);     -- Données de sortie
	o_TxEn 		: out std_logic                         -- Signal valid
	);	
end component ArpTransmitterGMII;

-------------------------------------------------------------------------------
-- Declaration des signaux
-------------------------------------------------------------------------------



signal i_arst_n : std_logic ;
signal i_sys_clk_tx      : std_logic ;

signal i_MacSrc     : std_logic_vector(6*8-1 downto 0);  
signal i_MacDst     : std_logic_vector(6*8-1 downto 0); 
signal i_IpSender   : std_logic_vector(31 downto 0);  
signal i_IpTarget   : std_logic_vector(31 downto 0);  
signal i_RunArp     : std_logic;

signal o_Tx     	  : std_logic_vector(7 downto 0);
signal o_TxEn     	  : std_logic;


-------------------------------------------------------------------------------
-- Constant
-------------------------------------------------------------------------------
-- Clock
constant CLK_PERIOD : time := 10 ns;
constant LATENCY    : positive := 10;


begin

-- Instanciation
--******************
inst_ArpTransmitterGMII: ArpTransmitterGMII 
port map (
  i_arst_n => i_arst_n,
  i_sys_clk_tx      => i_sys_clk_tx,
  i_MacSrc     => i_MacSrc,    
  i_MacDst     => i_MacDst,    
  i_IpSender   => i_IpSender,  
  i_IpTarget   => i_IpTarget,  
  i_RunArp     => i_RunArp,    
  o_Tx        => o_Tx,     
  o_TxEn => o_TxEn
);

-- Begin of stimulus
--******************

-- System reset
-------------------
RESET_PROCESS : process
begin
  i_arst_n <= '0'; wait for LATENCY*CLK_PERIOD;
  i_arst_n <= '1'; wait;

end process RESET_PROCESS;

-- System clock
-------------------
CLOCK_PROCESS : process
begin

  i_sys_clk_tx <= '0'; wait for CLK_PERIOD;
  i_sys_clk_tx <= '1'; wait for CLK_PERIOD;

end process CLOCK_PROCESS;


i_MacSrc   <= x"0050bf998b36";
i_MacDst   <= x"0008540B2177";
i_IpSender <= x"c0a80001";
i_IpTarget <= x"c0a80003";


-- System clock
-------------------
RUN_ARP_PROCESS : process
begin
  i_RunArp <= '0'; wait for 2*LATENCY*CLK_PERIOD;
  i_RunArp <= '1'; wait for 2*CLK_PERIOD;
  i_RunArp <= '0'; wait;

end process RUN_ARP_PROCESS;


---- Read value
-------------------
--READ_DATA_PROCESS : process
----
----  -- For data_vit
--  file file_data      		: text open READ_MODE is "M:/workspace_xilinx/kontopsxil/tb/ArpTransmitterGMII.in";
--  variable line_data  		: line;
--  variable vi_o_Tx	        : std_logic_vector(7 downto 0);
--  variable vi_o_TxEn	    : std_logic;  
--
--  
--begin
--
--  -- Initialise input
--  o_Tx        <= (others =>'0');
--  o_TxEn       <= '0';
--
--
--  assert false report "Début de lecture du/des fichiers" severity note;
--
---- DEBUG 1 LIGNE  
--wait for (LATENCY+2)*CLK_PERIOD;
--
--  while (endfile(file_data)=FALSE) loop
--
--    readline(file_data,line_data);	-- lecture d'une ligne
--    hread(line_data,vi_o_Tx);
--    read(line_data,vi_o_TxEn);	
--    
--    o_Tx       <= vi_o_Tx;
--    o_TxEn      <= vi_o_TxEn;
--
--	
--    wait until rising_edge(i_sys_clk_tx);
--	
--  end loop;
--
--  assert false report "Fin de simulation" severity failure;
--
--end process READ_DATA_PROCESS;
--
---- Write value
--------------------
--WRITE_DATA_PROCESS : process
--
--  file file_data     : text open WRITE_MODE is "$PATH_BIBLI_HDL/cos_sin/fichiertest/t01/data.out";
--  variable line_data : line;
--
--  begin
--	
--	wait until rising_edge(i_sys_clk_tx);
--		
--		while (true) loop 
--		
--			wait until rising_edge(i_sys_clk_tx);
--			if o_channel = "1" then
--                write(line_data,std_logic_vector(o_X));
--                write(line_data, ' ');
--                write(line_data,std_logic_vector(o_Y));
--                --write(line_data, ' ');
--                --write(line_data,std_logic_vector(o_Z));
--                writeline(file_data,line_data);			
--			end if;
--		end loop;
-- 
--end process WRITE_DATA_PROCESS;

end bench;