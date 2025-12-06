--   ----------------------------------------------------------------------------------------------
--   Nom du fichier    	: tb.vhd  
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

entity FrameGeneratorGMII_tb is end FrameGeneratorGMII_tb;

architecture bench of FrameGeneratorGMII_tb is

-------------------------------------------------------------------------------
-- Declaration des composants
-------------------------------------------------------------------------------
component FrameTransmitterGMII_debug
	port (
    -- Horloges et Resets 
    i_sys_clk_tx   : in  std_logic;                        -- Horloge système              
    i_arst_n    : in  std_logic;                        -- Reset matériel  
    -- Données de sorties de la Prbs
	o_Tx        : out std_logic_vector(7 downto 0);     -- Données de sortie
	o_TxEn 		: out std_logic                         -- Signal valid
	);	
end component FrameTransmitterGMII_debug;

-------------------------------------------------------------------------------
-- Declaration des signaux
-------------------------------------------------------------------------------


-- inputs
-----------
signal i_arst_n : std_logic ;
signal i_sys_clk_tx      : std_logic ;


-- output
-----------
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
inst_FrameTransmitterGMII: FrameTransmitterGMII_debug 
port map (
  i_arst_n => i_arst_n,
  i_sys_clk_tx      => i_sys_clk_tx,
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



---- Read value
-------------------
--READ_DATA_PROCESS : process
--
--  -- For data_vit
--  file file_data      		: text open READ_MODE is "$PATH_BIBLI_HDL/cos_sin/fichiertest/t01/data.in";
--  variable line_data  		: line;
--  variable vi_X	            : std_logic_vector(G_PRECISION-1 downto 0);
--  variable vi_Y	            : std_logic_vector(G_PRECISION-1 downto 0);  
--  variable vi_Z  	        : std_logic_vector(G_PRECISION-1 downto 0);  
--  variable vi_channel  	    : std_logic_vector(G_CHANNEL_SIZE-1 downto 0);
--  
--begin
--
--  -- Initialise input
--  i_X        <= to_signed(0,G_PRECISION);
--  i_Y        <= to_signed(0,G_PRECISION);
--  i_Z        <= to_signed(0,G_PRECISION);
--  i_channel <= to_unsigned(0,G_CHANNEL_SIZE);
--
--  assert false report "Début de lecture du/des fichiers" severity note;
--
---- DEBUG 1 LIGNE  
--wait for (LATENCY+2)*CLK_PERIOD;
--
--  while (endfile(file_data)=FALSE) loop
--
--    readline(file_data,line_data);	-- lecture d'une ligne
--    read(line_data,vi_X);
--    read(line_data,vi_Y);	
--    read(line_data,vi_Z);	
--    read(line_data,vi_channel);
--    i_X       <= signed(vi_X);
--    i_Y       <= signed(vi_Y);
--    i_Z       <= signed(vi_Z);
--    i_channel <= unsigned(vi_channel);
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