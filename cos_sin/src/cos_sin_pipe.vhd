--   ----------------------------------------------------------------------------------------------
--   Nom du fichier    	: cos_sin_pipe.vhd  
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

entity cos_sin_pipe is
	generic (
		G_PRECISION : integer := 16;
		G_ITERATION : integer := 16
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
end cos_sin_pipe;

architecture rtl of cos_sin_pipe is
-------------------------------------------------------------------------------
--  TYPE DECLARATION
-------------------------------------------------------------------------------
type T_ATAN is array (G_ITERATION-1 downto 0) of signed(G_PRECISION-1 downto 0);    -- Tableau de constantes pour Arctangante

-------------------------------------------------------------------------------
-- Fonction : F_ATAN
-- Description : 
-------------------------------------------------------------------------------
  function F_ATAN (constant C_ITERATION_ATAN : integer; C_PRECISION_ATAN : integer) return t_atan is
	  
	  variable v_I      : integer range 0 to C_ITERATION_ATAN-1;
      variable v_atan : t_atan;
	  
  begin
      if C_PRECISION_ATAN = C_SIMPLE_PRECISION then
          for v_I in 0 to C_ITERATION_ATAN-1 loop
              v_atan(v_I) := to_signed(integer(ROUND(ARCTAN( 2.0**(-(v_I)) ) / (2.0 * MATH_PI) *360.0 * (2.0**(C_PRECISION_ATAN-C_PART_ENT-1)))),C_PRECISION_ATAN);
          end loop;
      elsif C_PRECISION_ATAN = C_DOUBLE_PRECISION then
          for v_I in 0 to C_ITERATION_ATAN-1 loop
              v_atan(v_I) := to_signed(integer(ROUND(ARCTAN( 2.0**(-(v_I)) ) / MATH_PI * (2.0**(C_PRECISION_ATAN-C_PART_ENT-1)))),C_PRECISION_ATAN);
          end loop;
      else
          for v_I in 0 to C_ITERATION_ATAN-1 loop
              v_atan(v_I) := to_signed(0,C_PRECISION_ATAN);
          end loop;
      end if;
  	
      return v_atan;
  	
  end function f_atan;
  
	-- Function CATAN (constante arc-tangent).
	-- This is a lookup table containing pre-calculated arc-tangents.
	-- 'n' is the number of the pipe, returned is a 20bit arc-tangent value.
	-- The numbers are calculated as follows: Z(n) = atan(1/2^n)
	-- examples:
	-- 20bit values => 2^20 = 2pi(rad)
	--                 1(rad) = 2^20/2pi = 166886.053....
	-- n:0, atan(1/1) = 0.7853...(rad)
	--      0.7853... * 166886.053... = 131072(dec) = 20000(hex)
	-- n:1, atan(1/2) = 0.4636...(rad)
	--      0.4636... * 166886.053... = 77376.32(dec) = 12E40(hex)
	-- n:2, atan(1/4) = 0.2449...(rad)
	--      0.2449... * 166886.053... = 40883.52(dec) = 9FB3(hex)
	-- n:3, atan(1/8) = 0.1243...(rad)
	--      0.1243... * 166886.053... = 20753.11(dec) = 5111(hex)
	--
	-- function F_ATAN(n :natural) return integer is
	-- variable result	:integer;
	-- begin
		-- case n is
			-- when 0 => result := 16#020000#;
			-- when 1 => result := 16#012E40#;
			-- when 2 => result := 16#09FB4#;
			-- when 3 => result := 16#05111#;
			-- when 4 => result := 16#028B1#;
			-- when 5 => result := 16#0145D#;
			-- when 6 => result := 16#0A2F#;
			-- when 7 => result := 16#0518#;
			-- when 8 => result := 16#028C#;
			-- when 9 => result := 16#0146#;
			-- when 10 => result := 16#0A3#;
			-- when 11 => result := 16#051#;
			-- when 12 => result := 16#029#;
			-- when 13 => result := 16#014#;
			-- when 14 => result := 16#0A#;
			-- when 15 => result := 16#05#;
			-- when 16 => result := 16#03#;
			-- when 17 => result := 16#01#;
			-- when others => result := 16#0#;
		-- end case;
		-- return result;
	-- end F_ATAN;
	
begin
  COS_SIN_PROCESS: process(i_areset_n,i_clk)
  variable v_atan : t_atan;
  variable v_delta_X : signed(G_PRECISION-1 downto 0);
  variable v_delta_Y : signed(G_PRECISION-1 downto 0);
  
    begin
	  if i_areset_n = '0' then

        v_atan := F_ATAN(G_ITERATION,G_PRECISION);

		o_X <= (others =>'Z');
		o_Y <= (others =>'Z');
		o_Z <= (others =>'Z');

      elsif rising_edge(i_clk) then	
      
      -- Avec Arrondie (A controler)
      -- ***************************
		if i_NUM_ITER =0 then
			v_delta_X := i_X;
			v_delta_Y := i_Y;
		else
            if i_X(i_X'left) = '0' then --positif
                v_delta_X := i_X + shift_left(to_signed(1,G_PRECISION), i_NUM_ITER-1);
            else	
                v_delta_X := i_X - shift_left(to_signed(1,G_PRECISION), i_NUM_ITER-1);
            end if;
            
            if i_Y(i_Y'left) = '0' then --positif
                v_delta_Y := i_Y + shift_left(to_signed(1,G_PRECISION), i_NUM_ITER-1);
            else	
                v_delta_Y := i_Y - shift_left(to_signed(1,G_PRECISION), i_NUM_ITER-1);
            end if;			
		end if;
        
      -- Sans Arrondie (A controler)
      -- ***************************     
			-- v_delta_X := i_X;
			-- v_delta_Y := i_Y;
            
            
		if i_Z(i_Z'left) = '0' then --positif
            o_X <= i_X - shift_right(v_delta_Y, i_NUM_ITER);
			o_Y <= i_Y + shift_right(v_delta_X, i_NUM_ITER);	
			o_Z <= i_Z - v_atan(i_NUM_ITER);
            
		elsif i_Z(i_Z'left) = '1' then--negatif
			o_X <= i_X + shift_right(v_delta_Y, i_NUM_ITER);
			o_Y <= i_Y - shift_right(v_delta_X, i_NUM_ITER);
			o_Z <= i_Z + v_atan(i_NUM_ITER);
            
        else
            o_X <= (others =>'Z');
            o_Y <= (others =>'Z');
            o_Z <= (others =>'Z');
		end if;
		
-- a = angle;
-- for(i=0; i<=100; i++)
-- {
  -- d2/=2; // Multiple de 2-i
  -- dx=x*d2;
  -- dy=y*d2;
  -- da=atan(d2);
  -- da= 180*da/PI; // Pour une valeur en degré
  -- if(a<0)
  -- {
    -- x += dy;
    -- y -= dx;
    -- a += da;
  -- }
  -- else
  -- {
    -- x -= dy;
    -- y += dx;
    -- a -= da;
  -- }
-- }
				
      end if;
  end process COS_SIN_PROCESS ;
 end rtl;
 