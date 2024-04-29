--   ----------------------------------------------------------------------------------------------
--   Nom du fichier    	: cordic_pkg.vhd  
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
-------------------------------------------------------------------------------
--  Déclaration du pakage
-------------------------------------------------------------------------------
package cordic_pkg is

-------------------------------------------------------------------------------
--  Constantes
-------------------------------------------------------------------------------
constant C_SIMPLE_PRECISION : integer := 16;
constant C_DOUBLE_PRECISION : integer := 32;
constant C_PART_ENT  : integer := 8;
-- 16 bits
-- 1 signe + 8 entiere + 7 fractionnaire

-- 32 bits
-- 1 signe + 8 entiere + 23 fractionnaire

constant C_PI_DEG  : integer := 180;
constant C_MIPI_DEG  : integer := 90;

-------------------------------------------------------------------------------
--  Procedures
-------------------------------------------------------------------------------
--Détermine la position du vecteur et le réintroduit si besoin dans le premier Quadrant [0°;90]°.
procedure P_CORDIC_PRE(signal i_Z: in signed;variable C_PRECISION_PRE : natural;signal o_Z: out signed;variable v_post : out std_logic_vector(1 downto 0));

-- En fonction de l'angle réel, on corrige les valeurs de cos et sin
procedure P_CORDIC_POST(signal i_X,i_Y: in signed;signal s_post: in std_logic_vector(1 downto 0);variable C_PRECISION_POST : natural;signal o_X,o_Y: out signed);

end cordic_pkg;


package body cordic_pkg is


    
-------------------------------------------------------------------------------
-- Procedure : P_CORDIC_PRE
-- Description : 
-------------------------------------------------------------------------------    
  procedure P_CORDIC_PRE(signal i_Z: in signed;variable C_PRECISION_PRE : natural; signal o_Z: out signed; variable v_post : out std_logic_vector(1 downto 0)) is
  begin
    if i_Z(C_PRECISION_PRE-1 downto C_PRECISION_PRE-C_PART_ENT-1) > to_signed(C_MIPI_DEG,C_PART_ENT+1) then -- [90°;180°]
      o_Z <= shift_left(to_signed(C_PI_DEG,C_PRECISION_PRE),C_PRECISION_PRE-C_PART_ENT-1) - i_Z;
	  v_post:="01";
      
    elsif i_Z(C_PRECISION_PRE-1 downto C_PRECISION_PRE-C_PART_ENT-1) < to_signed(-C_MIPI_DEG,C_PART_ENT+1) then -- [-90°;-180°]
      o_Z <= shift_left(to_signed(C_PI_DEG,C_PRECISION_PRE),C_PRECISION_PRE-C_PART_ENT-1) + i_Z;
      v_post:="00";
  
    else
      o_Z <= i_Z;
      v_post:="11"; -- or v_post:="10";
    
    end if;
  end procedure;
  
-- if (angle1 > 90 )
-- {
-- angle = 180 - angle1 ;
-- }
-- else if (angle1 < - 90)
-- {
-- angle = 180 + angle1;
-- }
-- else
-- {
-- angle = angle1;
-- }


-------------------------------------------------------------------------------
-- Procedure : P_CORDIC_POST
-- Description : 
-------------------------------------------------------------------------------
  procedure P_CORDIC_POST(signal i_X,i_Y: in signed;signal s_post: in std_logic_vector(1 downto 0);variable C_PRECISION_POST : natural;signal o_X,o_Y: out signed) is
  begin
    if s_post = "01" then -- [90°;180°]
	  o_X <= -i_X;
	  o_Y <= i_Y;
	  
    elsif s_post = "00" then -- [-90°;-180°]
	  o_X <= -i_X;
	  o_Y <= -i_Y;
	  
    else --s_post = "11" or s_post = "10" 
	  o_X <= i_X;
	  o_Y <= i_Y;
    
    end if;
  end procedure;
-- if (angle1 > 90 )
-- {
-- x = -x;
-- }
-- if (angle1 < - 90)
-- {
-- x = -x;
-- y = -y;
-- }


end package body cordic_pkg;
