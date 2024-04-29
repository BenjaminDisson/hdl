--   ----------------------------------------------------------------------------------------------
--   Nom du fichier    	: cos_sin.vhd  
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
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.cordic_pkg.all;

entity cos_sin is
	generic (
		G_PRECISION 	: integer := 32;
		G_ITERATION 	: integer := 32;
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
		o_X         : out signed(G_PRECISION-1 downto 0); -- cosinus
		o_Y         : out signed(G_PRECISION-1 downto 0); -- sinus
		o_Z         : out signed(G_PRECISION-1 downto 0);  -- ?? (contrôle de la correction)
		o_channel	: out unsigned(G_CHANNEL_SIZE-1 downto 0) -- Custom data with correct latency
	);
end cos_sin;

architecture rtl of cos_sin is

-------------------------------------------------------------------------------
--  COMPONENT DECLARATION
-------------------------------------------------------------------------------
component cos_sin_pipe
	generic (
		G_PRECISION     : integer;
		G_ITERATION     : integer
	);
	port (
		i_areset_n   : in std_logic;
		i_clk        : in std_logic;
		-- entrées
		i_X         : in signed(G_PRECISION-1 downto 0); -- Kn
		i_Y         : in signed(G_PRECISION-1 downto 0); -- 0
		i_Z         : in signed(G_PRECISION-1 downto 0); -- angle

		i_NUM_ITER  : in natural range G_ITERATION downto 0;
		
		-- sorties
		o_X         : out signed(G_PRECISION-1 downto 0); -- cosinus
		o_Y         : out signed(G_PRECISION-1 downto 0); -- sinus
		o_Z         : out signed(G_PRECISION-1 downto 0)  -- ?? (contrôle de la correction)

	);
end component cos_sin_pipe;

-------------------------------------------------------------------------------
--  CONSTANT DECLARATION
-------------------------------------------------------------------------------
constant KN     : signed(G_PRECISION-1 downto 0) := to_signed(integer(ROUND(0.60725293500888133000 * (2.0**(G_PRECISION-C_PART_ENT-1)))),G_PRECISION);
--constant KN     : signed := "0000000001001101";

-------------------------------------------------------------------------------
--  TYPE DECLARATION
-------------------------------------------------------------------------------
type T_ITERATION is array (G_ITERATION downto 0) of signed(G_PRECISION-1 downto 0); -- Tableau de signaux pour le Pipe
type T_POST is array (G_ITERATION downto 0) of std_logic_vector(1 downto 0); -- Tableau de signaux pour le Pipe
type T_CHANNEL is array (G_ITERATION downto 0) of unsigned(G_CHANNEL_SIZE-1 downto 0);

-------------------------------------------------------------------------------
--  SIGNAL DECLARATION
-------------------------------------------------------------------------------
signal s_X, s_Y, s_Z  : T_ITERATION;
signal s_post : T_POST;
signal s_channel : T_CHANNEL;

begin
-------------------------------------------------------------------------------
--  COMPONENT INSTANTATION
-------------------------------------------------------------------------------
	PIPE_CORDIC_P2R:	for n in 0 to G_ITERATION-1 generate
		CORDIC_P2R: cos_sin_pipe 
			generic map(G_PRECISION => G_PRECISION, G_ITERATION => G_ITERATION)
			port map ( i_areset_n, i_clk, s_X(n), s_Y(n), s_Z(n),n,s_X(n+1), s_Y(n+1), s_Z(n+1));
	end generate PIPE_CORDIC_P2R;

	
-------------------------------------------------------------------------------
--  PROCESS
-------------------------------------------------------------------------------	
  GEN_COS: process(i_areset_n,i_clk)
    
    variable v_init : natural range 0 to G_ITERATION;
    variable v_precision : natural;
    variable v_post : std_logic_vector(1 downto 0);
   
  begin
    if i_areset_n = '0' then
    
	    for v_init in 0 to G_ITERATION loop  
            s_post(v_init) <= (others =>'Z'); 
            s_channel(v_init) <= (others =>'Z');     
        end loop;
      
		v_precision := G_PRECISION;
        v_post      := "ZZ";
		
		s_X(0) <= KN;
		s_Y(0) <= to_signed(0,G_PRECISION);	
		s_Z(0) <= i_Z;
		
		s_post(0)    <= "ZZ";
		s_channel(0) <= i_channel;
		
		o_X <= (others =>'Z');
		o_Y <= (others =>'Z');
		o_Z <= (others =>'Z');
        o_channel <= (others =>'Z');
		
	elsif rising_edge(i_clk) then	
		s_X(0) <= KN;
		s_Y(0) <= to_signed(0,G_PRECISION);       
		P_CORDIC_PRE(i_Z,v_precision,s_Z(0),v_post);

        s_post(0) <= v_post;
        s_channel(0) <= i_channel;
        
		PIPE_CHANNEL_POST:	for n in 1 to G_ITERATION loop
			s_post(n) <= s_post(n-1);
			s_channel(n) <= s_channel(n-1);
		end loop PIPE_CHANNEL_POST;
		
		P_CORDIC_POST(s_X(G_ITERATION),s_Y(G_ITERATION),s_post(G_ITERATION),v_precision,o_X,o_Y);	
		
		o_channel      <= s_channel(G_ITERATION);
        	
	end if;
  end process GEN_COS ; 
 end rtl;
 
 