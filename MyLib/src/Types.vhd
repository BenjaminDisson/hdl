

	constant NIBBLE_WIDTH : NATURAL := 4;
	subtype NIBBLE_RANGE is NATURAL range NIBBLE_WIDTH-1 downto 0;
	subtype NIBBLE is STD_LOGIC_VECTOR(NIBBLE_RANGE);
	

	constant BYTE_WIDTH : NATURAL := 8;
	subtype	 BYTE_RANGE is NATURAL range BYTE_WIDTH-1 downto 0;
	subtype	 BYTE is STD_LOGIC_VECTOR(BYTE_RANGE);


	constant WORD_WIDTH : NATURAL := 16;
	subtype	 WORD_RANGE is NATURAL range WORD_WIDTH-1 downto 0;
	subtype	 WORD is STD_LOGIC_VECTOR(WORD_RANGE);	-- storage type "word"


	constant DWORD_WIDTH : NATURAL := 32;
	subtype	 DWORD_RANGE is NATURAL range DWORD_WIDTH-1 downto 0;
	subtype	 DWORD is STD_LOGIC_VECTOR(DWORD_RANGE);


	constant QWORD_WIDTH : NATURAL := 64;
	subtype	 QWORD_RANGE is NATURAL range QWORD_WIDTH-1 downto 0;
	subtype	 QWORD is STD_LOGIC_VECTOR(QWORD_RANGE);


	---------------------------------------------------------------------------
	-- aggregates of Signals
	---------------------------------------------------------------------------
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



	---------------------------------------------------------------------------
	-- types for signal mnemonics
	---------------------------------------------------------------------------
	type ACCESS_MODE is (W , R);		-- Modes how memory can be accessed
	type CRYPTODIRECTION is (encrypt, decrypt);	 -- Switch to encrypt or decrypt

	---------------------------------------------------------------------------
	-- constants for convienience
	---------------------------------------------------------------------------
	constant NULL_QWORD : QWORD := (others => '0');	 -- Qword to clear memory
	constant NULL_DWORD : DWORD := (others => '0');	 -- Dword to clear memory
	constant NULL_WORD	: WORD	:= (others => '0');	 -- word to clear memory
	constant NULL_BYTE	: BYTE	:= (others => '0');	 -- byte to clear memory





-- TYPE PART
type STDL8_ARRAY_TYPE is array (natural range <>) of std_logic_vector(7 downto 0);
subtype STDL8 is std_logic_vector(7 downto 0);


-- Translate hexadecimal number in ASCII value
constant INT4_TO_STRHEX_TABLE : STDL8_ARRAY_TYPE(0 to 15) :=
(
    0 => std_logic_vector(to_unsigned(48,8)),
    1 => std_logic_vector(to_unsigned(49,8)),
    2 => std_logic_vector(to_unsigned(50,8)),
    3 => std_logic_vector(to_unsigned(51,8)),
    4 => std_logic_vector(to_unsigned(52,8)),
    5 => std_logic_vector(to_unsigned(53,8)),
    6 => std_logic_vector(to_unsigned(54,8)),
    7 => std_logic_vector(to_unsigned(55,8)),
    8 => std_logic_vector(to_unsigned(56,8)),
    9 => std_logic_vector(to_unsigned(57,8)),
    10 => std_logic_vector(to_unsigned(65,8)),
    11 => std_logic_vector(to_unsigned(66,8)),
    12 => std_logic_vector(to_unsigned(67,8)),
    13 => std_logic_vector(to_unsigned(68,8)),
    14 => std_logic_vector(to_unsigned(69,8)),
    15 => std_logic_vector(to_unsigned(70,8))
);


-- FUNCTION PART


function CHAR_to_STDL8(DataIn : character) return STDL8;

function STR_to_STDL8_Rev(Data_In : string) return STDL8_ARRAY_TYPE;


-------------------------------------------------------------------------------
-- Function STR_to_STDL8_Rev
--
-- This function convert a string to an array of STDL8, in reverse order.
-------------------------------------------------------------------------------
function STR_to_STDL8_Rev(Data_In : string) return STDL8_ARRAY_TYPE is
    variable Str_Size : natural := Data_In'length;
    variable Data_Out : STDL8_ARRAY_TYPE(0 to Str_Size-1);
begin
    for idx in Data_In'range loop
        Data_Out(idx-1) := std_logic_vector(to_unsigned(character'pos(Data_In(idx)),8));
    end loop;
    return Data_Out;
end function;

-------------------------------------------------------------------------------
-- Function CHAR_to_STDL8
--
-- This function convert a character to an STDL8.
-------------------------------------------------------------------------------
function CHAR_to_STDL8(DataIn : character) return STDL8 is
begin
    return std_logic_vector(to_unsigned(character'pos(DataIn),8));
end function;

