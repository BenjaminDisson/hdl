
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package AES256Top_pkg is

constant NO_ROUNDS : NATURAL := 14;-- number of rounds 10, 12 or 14, needed for looping
constant KEYLENGTH  : NATURAL := 128;  -- Size of keyblock (128, 192, 256 Bits)


	-- tiny 4 bit value
	constant NIBBLE_WIDTH : NATURAL := 4;
	subtype NIBBLE_RANGE is NATURAL range NIBBLE_WIDTH-1 downto 0;
	subtype NIBBLE is STD_LOGIC_VECTOR(NIBBLE_RANGE);
	
	-- type definition byte: 8 bit = byte (cell of the
	-- state)
	constant BYTE_WIDTH : NATURAL := 8;
	subtype	 BYTE_RANGE is NATURAL range BYTE_WIDTH-1 downto 0;
	subtype	 BYTE is STD_LOGIC_VECTOR(BYTE_RANGE);

	-- Type definition word: 16 bit = word 
	constant WORD_WIDTH : NATURAL := 16;
	subtype	 WORD_RANGE is NATURAL range WORD_WIDTH-1 downto 0;
	subtype	 WORD is STD_LOGIC_VECTOR(WORD_RANGE);	-- storage type "word"

	-- type definition Dword: 32 bit = dword 
	constant DWORD_WIDTH : NATURAL := 32;
	subtype	 DWORD_RANGE is NATURAL range DWORD_WIDTH-1 downto 0;
	subtype	 DWORD is STD_LOGIC_VECTOR(DWORD_RANGE);

	-- type definition Qword: 64 bit = qword 
	constant QWORD_WIDTH : NATURAL := 64;
	subtype	 QWORD_RANGE is NATURAL range QWORD_WIDTH-1 downto 0;
	subtype	 QWORD is STD_LOGIC_VECTOR(QWORD_RANGE);

-- array of 64 bit words
	type QWORDARRAY is array (NATURAL range <>) of QWORD;
	-- array of 32 bit words
	type DWORDARRAY is array (NATURAL range <>) of DWORD;
	-- array of 16 bit words
	type WORDARRAY is array (NATURAL range <>) of WORD;
	-- array of 8 bit words
	type BYTEARRAY is array (NATURAL range <>) of BYTE;
	-- array of NATURALS
	type NATURALARRAY is array (NATURAL range <>) of NATURAL;
	-- array of integers
	type INTEGERARRAY is array (NATURAL range <>) of INTEGER;

	-- Byte Matrix
	type BYTEMATRIX is array (NATURAL range <>, NATURAL range <>) of BYTE;


	-- The state type is the matrix unfolded into a linear representation
	-- the length of a column is always fixed so every 32 Bit of this vector
	-- represents a column of the state
	--
	-- once and for all: THE COLUMNS STAND WITH THE MSB (Bit 31) AT THE TOP!!
	--					=> cell0, cell4, cell8... are byte0 of the column
	-- 
	-- state:		==>		BYTEARRAY (0 to (BLOCKLENGTH/8)-1);
	--				cell0 cell4 ...
	--				cell1 cell5 ...	 ==> cell0,cell1,cell2,cell3,cell4,cell5.... 
	--				cell2 cell6 ...		 ^	   ^-bit[8]
	--				cell3  ...	...		 ^-bit[0] 
	subtype STATE is DWORDARRAY (0 to 3);
--	alias KEYBLOCK is STATE;
-- DUMB xilinx compiler does not know aliases for subtypes.....
	subtype KEYBLOCK is DWORDARRAY (0 to 3);


	-- Round constants for XOR in Keygenerator
	constant ROUNDCONSTANTS : BYTEARRAY(0 to 15) := (X"00", X"01", X"02", X"04", X"08", X"10", X"20", X"40",
													 X"80", X"1B", X"36", X"6C", X"D8", X"AB", X"4D", X"9A");

	end package AES256Top_pkg;