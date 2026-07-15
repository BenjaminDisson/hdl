--   ----------------------------------------------------------------------------------------------
--   Nom du fichier    	: FtcMath.vhd  
--   Auteur             : Benjamin Disson
--   Date de creation	: 10/06/2014
--   Version            : 1.0
--   Description        : Ensemble de fonctions de type mathématiques

--   Sous module        : --
--   Modifications    
--   --------------------------------------------------------------------------
--   Date             	: Ver. 	: Auteur       		: Commentaires
--   --------------------------------------------------------------------------
--   10/06/2014	        : 1.0   : Benjamin Disson  	: Creation
--
--
-- Warning : sat, round, length
--
--

-------------------------------------------------------------------------------
--  Déclaration des bibliothèques
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package FtcMath is

	procedure SAT_ROUND(signal i_value : in signed; constant sat, round : integer; signal o_value : out signed; signal o_overflow : out std_logic);
	
end FtcMath;


package body FtcMath is

    procedure SAT_ROUND(signal value_in : in signed; constant sat, round : integer; signal value_out : out signed; signal overflow : out std_logic ) IS
		variable v_value_round : signed(i_value'high downto 0);
		variable v_value_sat   : signed(i_value'high-sat downto 0);
		constant C_ZEROS   : signed(sat-1 downto 0) := (others=>'0');
		constant C_ONES    : signed(sat-1 downto 0) := (others=>'1');
	begin
		-- ajout de 0.5 pour l'arrondi au rang (round-1)
		if round > 0 then
			v_value_round := i_value + (2**(round-1));
	    else
			v_value_round := i_value;
		end if;

		-- saturation
		if sat > 0 then
			if v_value_round(v_value_round'high) = '0' and v_value_round(v_value_round'high downto v_value_round'high-sat) /= C_ZEROS then
				v_value_sat :=(others=>'1'); -- max int
				v_value_sat(v_value_sat'high) := '0';
				o_overflow <= '1';
					
			elsif v_value_round(v_value_round'high) = '1' and v_value_round(v_value_round'high downto v_value_round'high-sat) /= C_ONES then
				v_value_sat := (others=>'0'); -- max int
				v_value_sat(v_value_sat'high) := '1';
				v_value_sat(v_value_sat'low) := '1';
				o_overflow <= '1';
			else
				v_value_sat := v_value_round(v_value_round'high-sat downto 0);
			end if;
		end if;

		-- troncature
		o_value <= v_value_sat(v_value_sat'high downto round);

	end procedure SAT_ROUND;


-------------------------------------------------------------------------------
-- Function log2 -- returns number of bits needed to encode x choices
--   x = 0  returns 0
--   x = 1  returns 0
--   x = 2  returns 1
--   x = 4  returns 2, etc.
--
--Boucle de  0 à 29 carc'est la valeur maximum pour un entier/natural : 2^30 = 1073741824 et 2^31 = 2147483648.
--type integer is range -2147483647 to 2147483647; 
--subtype natural is integer range 0 to integer’high; 
-- Oui le log2 est la fonction réciproque de la fonction puissance de 2. Il donne donc le repere du bit du MSB + 1 (valeur entière).
--Ex : x = 50 =b110010 -> 5.64 => 2^6 = 64
--ex : x = 45 = b101101 -> 5.49
-------------------------------------------------------------------------------
function log2(x : natural) return integer is
  variable i  : integer := 0;
  variable val: integer := 1;
begin
  if x = 0 then
    return 0;
  else
    for j in 0 to 29 loop -- for loop for XST
      if val >= x
        then null;
      else
        i := i+1;
        val := val*2;
      end if;
    end loop;

    return i;
  end if;
end function log2;



	
	
end package body FtcMath;	