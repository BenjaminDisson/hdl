--   ----------------------------------------------------------------------------------------------
--   Nom du fichier    	: tb_FrameReceiverGMII.vhd  
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

entity tb_FrameReceiverGMII is end tb_FrameReceiverGMII;

architecture bench of tb_FrameReceiverGMII is

-------------------------------------------------------------------------------
-- Declaration des composants
-------------------------------------------------------------------------------
component FrameReceiverGMII
generic (
	G_MAC_ADDR : std_logic_vector(47 downto 0) := x"0050bf998b36";
	G_IP_ADDR : std_logic_vector(31 downto 0) := x"c0a80001"
);
	port (
    -- Horloges et Resets 
    i_sys_clk_tx   : in  std_logic;                                 
    i_arst_n    : in  std_logic;                       


	o_MacSrc       : out std_logic_vector(6*8-1 downto 0);
	--o_MacDst     : out std_logic_vector(6*8-1 downto 0);
	--o_MacLenght  : out std_logic_vector(2*8-1 downto 0);

	o_IpSender     : out std_logic_vector(31 downto 0);
	o_IpTarget     : out std_logic_vector(31 downto 0);
	
	-- Protocol launch
	o_RunArp       : out std_logic;
	
	i_Rxd        : in std_logic_vector(7 downto 0);    
	i_RxEn 		: in std_logic 
	);	
end component FrameReceiverGMII;

-------------------------------------------------------------------------------
-- Declaration des signaux
-------------------------------------------------------------------------------


-- inputs
-----------
signal i_arst_n : std_logic ;
signal i_sys_clk_tx      : std_logic ;


-- output
-----------
signal i_Rxd     	  : std_logic_vector(7 downto 0);
signal i_RxEn     	  : std_logic;


-------------------------------------------------------------------------------
-- Constant
-------------------------------------------------------------------------------
-- Clock
constant CLK_PERIOD : time := 10 ns;
constant LATENCY    : positive := 10;


begin

-- Instanciation
--******************
inst_FrameReceiverGMII: FrameReceiverGMII 
port map (
  i_arst_n => i_arst_n,
  i_sys_clk_tx      => i_sys_clk_tx,
  i_Rxd        => i_Rxd,     
  i_RxEn => i_RxEn
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
READ_DATA_PROCESS : process
--
--  -- For data_vit
  file file_data      		: text open READ_MODE is "M:/workspace_xilinx/kontopsxil/tb/FrameReceiverGMII.in";
  variable line_data  		: line;
  variable vi_i_Rxd	        : std_logic_vector(7 downto 0);
  variable vi_i_RxEn	    : std_logic;  

  
begin

  -- Initialise input
  i_Rxd        <= (others =>'0');
  i_RxEn       <= '0';


  assert false report "Début de lecture du/des fichiers" severity note;

-- DEBUG 1 LIGNE  
wait for (LATENCY+2)*CLK_PERIOD;

  while (endfile(file_data)=FALSE) loop

    readline(file_data,line_data);	-- lecture d'une ligne
    hread(line_data,vi_i_Rxd);
    read(line_data,vi_i_RxEn);	
    
    i_Rxd       <= vi_i_Rxd;
    i_RxEn      <= vi_i_RxEn;

	
    wait until rising_edge(i_sys_clk_tx);
	
  end loop;

  assert false report "Fin de simulation" severity failure;

end process READ_DATA_PROCESS;
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