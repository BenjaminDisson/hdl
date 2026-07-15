--   ----------------------------------------------------------------------------------------------
--   Nom du fichier    	: mult_complex.vhd  
--   Auteur             : Benjamin Disson
--   Date de creation	: 01/12/2013
--   Version            : 1.0
--   Description        : Multiplication complexe

--   Sous module        : --
--   Modifications    
--   --------------------------------------------------------------------------
--   Date             	: Ver. 	: Auteur       		: Commentaires
--   --------------------------------------------------------------------------
--   01/13/2012	        : 1.0   : Benjamin Disson  	: Creation
--
--
-- Warning
-- -------
-- 1) This block doesn't take care about exponent and mantissa. User shall adapt data
-- before using this block. In case of non-conformous usage, hazardous error will occur.
-- TODO
-- 2) This block allows to rezise the output data with saturation and rounded. These 
-- function decrease the size of the data. Increasing the output data size (by shifting 
-- and adding bits) shall be done in external of this block

-------------------------------------------------------------------------------
--  Déclaration des bibliothèques
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity mult_complex is
	generic (
		G_DATA_A_SIZE  : integer := 16;
		G_DATA_B_SIZE  : integer := 16; 
		G_CHANNEL_SIZE : integer := 0;
		G_SATURATION   : integer := 8;  -- Number of bits (MSB) to deleted (overflow flag will be up if too much bits are saturated)
		G_ROUND        : integer := 8   -- Number of bits (LSB) to trunk (final result will be rounded)
	);
	port (
		-- Clock
		i_areset_n        : in std_logic;
		i_clk             : in std_logic;
		
		-- Input
		i_DATA_Ai         : in signed(G_DATA_A_SIZE-1 downto 0);
		i_DATA_Ar         : in signed(G_DATA_A_SIZE-1 downto 0);
		i_DATA_Bi         : in signed(G_DATA_B_SIZE-1 downto 0);
		i_DATA_Br         : in signed(G_DATA_B_SIZE-1 downto 0);
		i_channel         : in std_logic_vector(G_CHANNEL_SIZE downto 0); -- Other data that shall stay synchronous
		i_valid           : in std_logic;

		-- Output
		o_DATA_Ci         : out signed(G_DATA_A_SIZE+G_DATA_B_SIZE-G_SATURATION-G_ROUND-1 downto 0);
		o_DATA_Cq         : out signed(G_DATA_A_SIZE+G_DATA_B_SIZE-G_SATURATION-G_ROUND-1 downto 0);
		o_channel         : out std_logic_vector(G_CHANNEL_SIZE downto 0);
		o_valid           : out std_logic;
		o_overflow        : out std_logic  -- Flag if Saturation function has delete "too much" data
	);
end mult_complex;

architecture rtl of mult_complex is

signal s_AiBi, s_ArBr, s_ArBi, s_AiBr : signed(G_DATA_A_SIZE+G_DATA_B_SIZE-1 downto 0);
signal s_AiBi_m_ArBr, s_AiBr_p_ArBi   : signed(G_DATA_A_SIZE+G_DATA_B_SIZE downto 0);
signal s_channel_s1                   : std_logic_vector(G_CHANNEL_SIZE downto 0);
signal s_channel_s2                   : std_logic_vector(G_CHANNEL_SIZE downto 0);
signal s_channel_s3                   : std_logic_vector(G_CHANNEL_SIZE downto 0);
signal s_valid_s1                     : std_logic;
signal s_valid_s2                     : std_logic;
signal s_valid_s3                     : std_logic;


-- (Ai + j*Ar) * (Bi + j*Br) = [Ai.Bi - Ar.Br] + j*[Ar.Bi + Ai.Br]

begin

  SIMPLE_MULT: process(i_areset_n,i_clk)
		variable v_overflow_r : std_logic;
        variable v_overflow_i : std_logic;
    begin
	  if i_areset_n = '0' then
		s_AiBi     <= (others => '0');
		s_ArBr     <= (others => '0');
		s_ArBi     <= (others => '0');
		s_AiBr     <= (others => '0');
		s_channel  <= (others => '0');                  	  
		s_valid    <= '0';           	  
	  
	    o_DATA_Ci  <= (others => '0'); 
	    o_DATA_Cq  <= (others => '0');
	    o_channel  <= (others => '0');
	    o_valid    <= '0';
	    o_overflow <= '0';

      elsif rising_edge(i_clk) then	
		if i_valid = '1' then
			-- 1ère étape : multiplication 
			s_AiBi       <= i_DATA_Ai * i_DATA_Bi;  
			s_ArBr       <= i_DATA_Ar * i_DATA_Br;
			s_ArBi       <= i_DATA_Ar * i_DATA_Bi;   
			s_AiBr       <= i_DATA_Ai * i_DATA_Br;   
			s_channel_s1 <= i_channel;
			s_valid_s1   <= i_valid;

			-- 2ème étape : parties réelles et imaginaires en pleine résolution
			s_AiBi_m_ArBr <= s_AiBi - s_ArBr;
			s_AiBr_p_ArBi <= s_AiBr + s_ArBi;
			s_channel_s2  <= s_channel_s1;
			s_valid_s2    <= s_valid_s1;

			-- TODO
			-- 3ème étape : Saturation et arrondi 
			--SAT_ROUND(s_AiBi_m_ArBr,G_SATURATION,G_ROUND,o_DATA_Ci,v_overflow_r);
			--SAT_ROUND(s_AiBr_p_ArBi,G_SATURATION,G_ROUND,o_DATA_Cq,v_overflow_i)
			--o_overflow <= v_overflow_r & v_overflow_i;
			o_channel  <= s_channel_s2;
			o_valid    <= s_valid_s2;
		end if;
      end if;
  end process GEN_COS ;
 end rtl;