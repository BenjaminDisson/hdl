-- -------------------------------
-- AES256Registers.vhd
--
-- @Description
-- This is 
--
-- MODIFICATIONS
-- Date       | Author   | Comments
-- 2023/11/11 | B. Disson
--
--						    Write register
--            ____________________________________________
--      0x0  |              Control register              |
--           |____________________________________________|
--      0x1  |                 Unused                     |
--           |____________________________________________|
--      0x2  |                Initial Key                 |
--           |                                            |
--           |                                            |
--           |                                            |
--           |                                            |
--           |                                            |
--           |                                            |
--      0x9  |____________________________________________|
--      0xA  |                 Input data                 |
--      0xB  |                                            |
--      0xC  |                                            |
--      0xD  |____________________________________________|
--      0xE  |                   Unused                   |
--      0xF  |____________________________________________|
--
-- KEY_VALID
-- If asserted key data in the KEY memory range is regarded valid and will
-- be expanded to round keys. When deasserted all keys are invalidated
-- and the current operation of the core is aborted. It must be asserted
-- as long as the key shall be used for either encryption or decryption.
-- This bit must be cleared for one clock cycle to load a new key.
-- IRQ_ENA
-- Enable use of the interrupt request signal. If asserted the component
-- will set IRQ after completing an operation. If not set the component
-- operates in polling mode only.
-- IRQ_PERSISTENCE
-- CLEAR_IRQ
-- RESET_FSM
-- RESET_CIPHER
-- RESET_KEYENERATOR
--						     Read register
--            ____________________________________________
--      0x10 |              Status registers              |
--           |____________________________________________|
--      0x11 |                 Unused                     |
--           |____________________________________________|
--      0x12 |            Output data (result)            |
--      0x13 |                                            |
--      0x14 |                                            |
--      0x15 |____________________________________________|
--      0x16 |                 Unused                     |
--           |                                            |
--           |                                            |
--           |                                            |
--           |                                            |
--           |                                            |
--           |                                            |
--           |                                            |
--           |                                            |
--      0x1F |____________________________________________|
--
-- KEY_FINISHED (autoclear)
-- RESULT_AVAILABLE (polling)
-- IRQ_STATUS
--
-- AXI4-Lite
--
-- To prevent a deadlock situation, the dependency rules that exist between the handshake signals must be observed.
-- In any transaction:
-- • The VALID signal of the AXI interface sending information must not be dependent on the READY signal
-- of the AXI interface receiving that information.
-- • An AXI interface that is receiving information can wait until it detects a VALID signal before it asserts its
-- corresponding READY signal.
-- Note: It is acceptable to wait for VALID to be asserted before asserting READY. It is also acceptable to assert READY
-- before detecting the corresponding VALID. This can result in a more efficient design.

-- Read transaction dependencies
-- • The Manager must not wait for the Subordinate to assert ARREADY before asserting ARVALID.
-- • The Subordinate can wait for ARVALID to be asserted before it asserts ARREADY.
-- • The Subordinate can assert ARREADY before ARVALID is asserted.
-- • The Subordinate must wait for both ARVALID and ARREADY to be asserted before it asserts RVALID to
-- indicate that valid data is available.
-- • The Subordinate must not wait for the Manager to assert RREADY before asserting RVALID.
-- • The Manager can wait for RVALID to be asserted before it asserts RREADY.
-- • The Manager can assert RREADY before RVALID is asserted.

-- AXI4 and AXI5 write transaction dependencies
-- • The Manager must not wait for the Subordinate to assert AWREADY or WREADY before asserting
-- AWVALID or WVALID.
-- • The Subordinate can wait for AWVALID or WVALID, or both, before asserting AWREADY.
-- • The Subordinate can assert AWREADY before AWVALID or WVALID, or both, are asserted.
-- • The Subordinate can wait for AWVALID or WVALID, or both, before asserting WREADY.
-- • The Subordinate can assert WREADY before AWVALID or WVALID, or both, are asserted.
-- • The Subordinate must wait for AWVALID, AWREADY, WVALID, and WREADY to be asserted before
-- asserting BVALID.
-- The Subordinate must also wait for WLAST to be asserted before asserting BVALID. This wait is because
-- the write response, BRESP, must be signaled only after the last data transfer of a write transaction.
-- • The Subordinate must not wait for the Manager to assert BREADY before asserting BVALID.
-- • The Manager can wait for BVALID before asserting BREADY.
-- • The Manager can assert BREADY before BVALID is asserted.

-- 1) Each request starts with the AXI-lite master rising *_Valid + ReadAddress / ReadData / WriteAddress / WriteData / WriteAck
-- the master will also place the address of the desired read on the bus.
-- 2) The slave will answer by rising *_Ready
-- the slave can set *_Ready before or in response to *_Valid
-- 3) Outputs are not allowed to be dependent combinatorially on the inputs, but must instead be registered.
-- 4) the slave can stall the bus as required by the implementation.

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
--library TopAES256_lib;
--use TopAES256_lib.TopAES256_pkg.all;


---------------------------------------------------------------------------
--
-- 2) ENTITY DEFINITION
--
---------------------------------------------------------------------------
entity AES256Registers is
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
--	--output   logic [1:0]    o_Bresp, --Write response, indicates the status of a write transaction.

	--Read address channel signals
	i_Arvalid 	: in std_logic; --Indicates that the read address channel signals are valid.
	o_Arready 	: out std_logic; --Indicates that a transfer on the read address channel can be accepted.
	i_Araddr	: in std_logic_vector(31 downto 0); --The address of the first transfer in a read transaction.
	--input  logic [2:0]    i_Arprot, --Protection attributes of a read transaction: privilege, security level, and access type.

	-- Read data channel signals
	o_Rvalid 	: out std_logic; --Indicates that the read data channel signals are valid.
	i_Rready 	: in std_logic; --Indicates that a transfer on the read data channel can be accepted.
	o_Rdata 	: out std_logic_vector(31 downto 0); --Read data.
--	--output   logic [1:0]    o_Rresp, --Read response, indicates the status of a read transfer.

	o_Irq 	: out std_logic -- Interruption (configurable)
	);

end entity AES256Registers;

architecture rtl of AES256Registers is

---------------------------------------------------------------------------
--
-- 3) DEFINITIONS
--
---------------------------------------------------------------------------
---------------------------------------------------------------------------
-- TYPES 
---------------------------------------------------------------------------
type t_AxiFourLiteSubordonate is (s_idle, s_receiveaddr,
                             s_wait_wvalid, s_receivedata, s_sendresponse,
                             s_waitrready, s_read, s_readrunning, s_senddata);
  signal s_AxiFourLiteSubordonate : t_AxiFourLiteSubordonate;
---------------------------------------------------------------------------
-- SIGNALS
---------------------------
	signal s_Awaddr		: std_logic_vector(31 downto 0);


---------------------------------------------------------------------------
-- CONSTANTS
---------------------------------------------------------------------------


begin

---------------------------------------------------------------------------
--
-- 4) ARCHITECTURE DEFINITION
--
---------------------------------------------------------------------------
  axi_slave_process : process(i_nrst, i_clk)
  begin
    if i_nrst = '0' then
      s_AxiFourLiteSubordonate
    elsif rising_edge(i_clk) then
		case s_AxiFourLiteSubordonate is

        when WaitTransaction
         =>
          s_AxiFourLiteSubordonate <= s_receiveaddr;

        when s_receiveaddr =>

        when others =>
          s_AxiFourLiteSubordonate <= s_idle;    -- Error & return in the idle state
      end case;

    end if;
  end process;
---------------------------------------------------------------------------
-- PROCESS
---------------------------------------------------------------------------
