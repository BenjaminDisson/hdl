--   ----------------------------------------------------------------------------------------------
--   Nom du fichier    	: test_bench.vhd  
--   Auteur             : Benjamin Disson
--   Date de creation	: 31/12/2012
--   Version            : 1.0
--   Description        : 
--   Sous module        : --
--   Modifications    
--   --------------------------------------------------------------------------
--   Date             	: Ver. 	: Auteur       		: Commentaires
--   --------------------------------------------------------------------------
--   31/12/2012	        : 1.0   : Benjamin Disson  	: Creation
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

entity test_bench_16b is end test_bench_16b;

architecture bench of test_bench_16b is

-------------------------------------------------------------------------------
-- Declaration des composants
-------------------------------------------------------------------------------
component cos_sin
	generic (
		G_PRECISION 	: integer := 16;
		G_ITERATION 	: integer := 16;
		G_CHANNEL_SIZE  : integer := 1
	);
	port (
		i_areset_n   : in std_logic;
		i_clk        : in std_logic;
		-- entrées
		i_X         : in signed(G_PRECISION-1 downto 0); -- Kn
		i_Y         : in signed(G_PRECISION-1 downto 0); -- 0
		i_Z         : in signed(G_PRECISION-1 downto 0); -- angle
		i_channel	: in unsigned(G_CHANNEL_SIZE-1 downto 0); -- for custom data		

		-- sorties
		o_X         : out signed(G_PRECISION-1 downto 0); --cos?
		o_Y         : out signed(G_PRECISION-1 downto 0);--sin?
		o_Z         : out signed(G_PRECISION-1 downto 0);  -- ?? (contrôle de la correction)
		o_channel	: out unsigned(G_CHANNEL_SIZE-1 downto 0) -- Custom data with correct la
	);
end component cos_sin;

-------------------------------------------------------------------------------
-- Declaration des signaux
-------------------------------------------------------------------------------
constant G_PRECISION : natural :=16;
constant G_CHANNEL_SIZE : natural :=1;

-- inputs
-----------
signal i_areset_n : std_logic ;
signal i_clk      : std_logic ;

signal i_X     	  : signed(G_PRECISION-1 downto 0);
signal i_Y     	  : signed(G_PRECISION-1 downto 0);
signal i_Z	      : signed(G_PRECISION-1 downto 0);
signal i_channel  : unsigned(G_CHANNEL_SIZE-1 downto 0);

-- output
-----------
signal o_X     	  : signed(G_PRECISION-1 downto 0);
signal o_Y     	  : signed(G_PRECISION-1 downto 0);
signal o_Z	      : signed(G_PRECISION-1 downto 0);
signal o_channel  : unsigned(G_CHANNEL_SIZE-1 downto 0);

-------------------------------------------------------------------------------
-- Constant
-------------------------------------------------------------------------------
-- Clock
constant CLK_PERIOD : time := 10 ns;
constant LATENCY    : positive := 10;


begin

-- Instanciation
--******************
inst_cos_sin: cos_sin 
port map (
  i_areset_n => i_areset_n,
  i_clk      => i_clk,
  i_X        => i_X(G_PRECISION-1 downto 0),     
  i_Y        => i_Y(G_PRECISION-1 downto 0),
  i_Z        => i_Z(G_PRECISION-1 downto 0),
  i_channel  => i_channel(G_CHANNEL_SIZE-1 downto 0),
  o_X        => o_X(G_PRECISION-1 downto 0),
  o_Y        => o_Y(G_PRECISION-1 downto 0),
  o_Z        => o_Z(G_PRECISION-1 downto 0),
  o_channel  => o_channel(G_CHANNEL_SIZE-1 downto 0)
);

-- Begin of stimulus
--******************

-- System reset
-------------------
RESET_PROCESS : process
begin
  i_areset_n <= '0'; wait for LATENCY*CLK_PERIOD;
  i_areset_n <= '1'; wait;

end process RESET_PROCESS;

-- System clock
-------------------
CLOCK_PROCESS : process
begin

  i_clk <= '0'; wait for CLK_PERIOD;
  i_clk <= '1'; wait for CLK_PERIOD;

end process CLOCK_PROCESS;



-- Read value
-----------------
READ_DATA_PROCESS : process

  -- For data_vit
  file file_data      		: text open READ_MODE is "$PATH_BIBLI_HDL/cos_sin/tb/t01/data.in";
  variable line_data  		: line;
  variable vi_X	            : std_logic_vector(G_PRECISION-1 downto 0);
  variable vi_Y	            : std_logic_vector(G_PRECISION-1 downto 0);  
  variable vi_Z  	        : std_logic_vector(G_PRECISION-1 downto 0);  
  variable vi_channel  	    : std_logic_vector(G_CHANNEL_SIZE-1 downto 0);
  
begin

  -- Initialise input
  i_X        <= to_signed(0,G_PRECISION);
  i_Y        <= to_signed(0,G_PRECISION);
  i_Z        <= to_signed(0,G_PRECISION);
  i_channel <= to_unsigned(0,G_CHANNEL_SIZE);

  assert false report "Début de lecture du/des fichiers" severity note;

-- DEBUG 1 LIGNE  
wait for (LATENCY+2)*CLK_PERIOD;

  while (endfile(file_data)=FALSE) loop

    readline(file_data,line_data);	-- lecture d'une ligne
    read(line_data,vi_X);
    read(line_data,vi_Y);	
    read(line_data,vi_Z);	
    read(line_data,vi_channel);
    i_X       <= signed(vi_X);
    i_Y       <= signed(vi_Y);
    i_Z       <= signed(vi_Z);
    i_channel <= unsigned(vi_channel);
	
    wait until rising_edge(i_clk);
	
  end loop;

  assert false report "Fin de simulation" severity failure;

end process READ_DATA_PROCESS;

-- Write value
------------------
WRITE_DATA_PROCESS : process

  file file_data     : text open WRITE_MODE is "$PATH_BIBLI_HDL/cos_sin/tb/t01/data.out";
  variable line_data : line;

  begin
	
	wait until rising_edge(i_clk);
		
		while (true) loop 
		
			wait until rising_edge(i_clk);
			if o_channel = "1" then
                write(line_data,std_logic_vector(o_X));
                write(line_data, ' ');
                write(line_data,std_logic_vector(o_Y));
                --write(line_data, ' ');
                --write(line_data,std_logic_vector(o_Z));
                writeline(file_data,line_data);			
			end if;
		end loop;
 
end process WRITE_DATA_PROCESS;

end bench;