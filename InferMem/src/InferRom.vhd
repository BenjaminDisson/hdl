--   ----------------------------------------------------------------------------------------------
--   File name     : Rom.vhd     
--   Description   : Read only memory   
--                 :      
--   ----------------------------------------------------------------------------------------------
--   Modifications    
--   ----------------------------------------------------------------------------------------------
--   Date       : Ver.  : Author           : Comments
--   ---------------------------------------------------------------------------------------------- 
--   01/01/2009 : 1.0   : Benjamin Disson  : Creation
--
--
library ieee; 
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use work.InferMem_pkg.all;

  entity InferRom is
  generic (g_AddrSize     : positive := 8;													-- Address bus size
           g_DataSize 		: positive := 16);												-- Data bus size
   port (
		i_Address : in std_logic_vector(g_AddrSize -1 downto 0 );				-- Address bus
		i_Clk     : in std_logic;									  	   								-- Clock
		o_DataOut	: out std_logic_vector (g_DataSize -1 downto 0 ) 			-- Data out
		); 
  end InferRom;

architecture Behavior of InferRom is
-------------------------------------------------------------------------------
--
-- Type 
--
-------------------------------------------------------------------------------
  type t_Rom is array (0 to 2**g_AddrSize -1) of unsigned(g_DataSize -1  downto 0 );

-------------------------------------------------------------------------------
--
-- Signal
--
-------------------------------------------------------------------------------
  
  
-------------------------------------------------------------------------------
--
-- ROM definition with different kind of assignation
--
-------------------------------------------------------------------------------
  constant c_table: t_Rom :=
	(
	X"FFFF",
	X"AAAA",
	X"BBBB",
	X"CCCC",
	"1010101000000011",
	"1111111100000000",
	"1110111000001100",
	"1111111000111101",
	"1111111001100110",
	"1110011000000111",
	"1011011000010111",
	"1110111000101000",
	"1100011110001001",
	others => X"FFFF"
	);



begin

-------------------------------------------------------------------------------
--
-- Process        : READ
-- Type           : Synchronous, no reset
-- Description    : Get data from the ROM
--
-------------------------------------------------------------------------------
READ : process(i_Clk)
  begin
		if rising_edge(i_Clk) then
			o_DataOut <= std_logic_vector(c_table(to_integer(unsigned(i_Address))));
		end if;
end process READ ;


end Behavior;