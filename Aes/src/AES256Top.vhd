-- -------------------------------
-- AES256Top.vhd
--
-- @Description
-- This is the top level component 
-- The core is a capsule which includes a unique bus interface. It receives data and produce the result.
-- Only one AES version is available because non generic bloc are easier to check and other models are easy to create from this version
-- This module instanciate all sub-modules.
--
-- MODIFICATIONS
-- Date       | Author   | Comments
-- 2023/11/11 | B. Disson
--
--
-- AXI4-Stream    ______________________________________________
--    |_(option)  |                                             |
--      ||        |                                             | 
--      \/        |            ___________                      | 
--   AXI4-Lite    |           |           |                     | 
--  (Subordinate) |<----------| Registers |     KeyGeneratorFSM |    
--  <-----------> |---------->|___________|    /    Subword     | 
--                |                 |         /     Rotword     |    
--                |            Interfacing   /      Rcon        |   
--                |            _____|_____  /                   | 
--                |           |   Prime   |/                    |  
--                |           |____FSM____|\                    |  
--                |                         \       AddRoundKey |   
--                |                          \      MixColumns  |   
--                |                           \     ShiftRows   |   
--                |                            \    SubBytes    |   
--                |                             CipherFSM       |  
--                |                                             |  
--                |_____________________________________________|
             


---------------------------------------------------------------------------
-- 
-- 1) LIBRARY DEFINITION
--
---------------------------------------------------------------------------
---------------------------------------------------------------------------
-- STANDART
---------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

---------------------------------------------------------------------------
-- CUSTOM
---------------------------------------------------------------------------
library AES256Top_lib;
use AES256Top_lib.AES256Top_pkg.all;


---------------------------------------------------------------------------
--
-- 2) ENTITY DEFINITION
--
---------------------------------------------------------------------------
entity AES256Top is
	port(
	-- AXI4-Lite (Subordinate)
	-- Global
	i_Clk 		: in std_logic;--Global clock signal. Synchronous signals are sampled on the rising edge of the global clock.
	i_AReset_n 	: in std_logic;--Global reset signal. This signal is active-LOW.

	--Write address channel signals
	i_Awvalid 	: in std_logic; --Indicates that the write address channel signals are valid.
	o_Awready	: out std_logic; --Indicates that a transfer on the write address channel can be accepted.
	i_Awaddr	: in std_logic_vector(31 downto 0);--The address of the first transfer in a write transaction.
	-- input  logic [2:0]    i_Awprot,-- Protection attributes of a write transaction: privilege, security level, and access type.

	-- Write data channel signals
	i_Wvalid 	: in std_logic; --Indicates that the write data channel signals are valid.
	o_Wready 	: out std_logic; --Indicates that a transfer on the write data channel can be accepted.
	i_Wdata 	: in std_logic_vector(31 downto 0); --Write data.
	i_Wstrb 	: in std_logic_vector(3 downto 0); --Write strobes, indicate which byte lanes hold valid data.

	-- Write response channel signals
	o_Bvalid 	: out std_logic; --Indicates that the write response channel signals are valid.
	i_Bready 	: in	std_logic; --Indicates that a transfer on the write response channel can be accepted.
	--output   logic [1:0]    o_Bresp, --Write response, indicates the status of a write transaction.

	--Read address channel signals
	i_Arvalid 	: in std_logic; --Indicates that the read address channel signals are valid.
	o_Arready 	: out std_logic; --Indicates that a transfer on the read address channel can be accepted.
	i_Araddr	: in std_logic_vector(31 downto 0); --The address of the first transfer in a read transaction.
	--input  logic [2:0]    i_Arprot, --Protection attributes of a read transaction: privilege, security level, and access type.

	-- Read data channel signals
	o_Rvalid 	: out std_logic; --Indicates that the read data channel signals are valid.
	i_Rready 	: in std_logic; --Indicates that a transfer on the read data channel can be accepted.
	o_Rdata 	: out std_logic_vector(31 downto 0); --Read data.
	--output   logic [1:0]    o_Rresp, --Read response, indicates the status of a read transfer.

	o_Irq 	: out std_logic -- Interruption (configurable)
	);

end entity AES256Top;

architecture rtl of TopAES256 is

---------------------------------------------------------------------------
--
-- 3) DEFINITIONS
--
---------------------------------------------------------------------------
---------------------------------------------------------------------------
-- TYPES 
---------------------------------------------------------------------------

---------------------------------------------------------------------------
-- SIGNALS
---------------------------------------------------------------------------
	-- Connexion between AXI4-Lite interface and Registers
	signal s_Awvalid 	: std_logic; 
	signal s_Awready	: std_logic; 
	signal s_Awaddr		: std_logic_vector(31 downto 0);
	signal s_Wvalid 	: std_logic; 
	signal s_Wready 	: std_logic; 
	signal s_Wdata 		: std_logic_vector(31 downto 0); 
	signal s_Wstrb 		: std_logic_vector(3 downto 0); 
	signal s_Bvalid 	: std_logic; 
	signal s_Bready 	: std_logic; 
	signal s_Arvalid 	: std_logic; 
	signal s_Arready 	: std_logic; 
	signal s_Araddr		: std_logic_vector(31 downto 0); 
	signal s_Rvalid 	: std_logic; 
	signal s_Rready 	: std_logic;
	signal s_Rdata 		: std_logic_vector(31 downto 0);

---------------------------------------------------------------------------
-- CONSTANTS
---------------------------------------------------------------------------


begin

---------------------------------------------------------------------------
--
-- 4) ARCHITECTURE DEFINITION
--
---------------------------------------------------------------------------

---------------------------------------------------------------------------
-- COMPONENT INSTANCIATION: 
---------------------------------------------------------------------------

-- AES256 registers



---------------------------------------------------------------------------
-- PROCESS
---------------------------------------------------------------------------

   end rtl;
