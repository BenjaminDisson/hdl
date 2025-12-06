// AMBA3 AHB-Lite (A terminer)
// AXI 3 & 4
// AXI 4 (default)
// AXI4-Lite
// AXI5-Lite (TBC)
// AXI4-Stream 


// ______________________________________________________________
// From AMBA® 3 AHB-Lite Protocol v1.0 Specification
// --------------------------------------------------------------


  // AHB-Lite Slave  
  // _______________
  // Language restriction
  // No BURSTtransaction:     HBURST[2:0] is always 3’b000
  // No locked transactions:  HMASTLOCK is always 1’b0
  // No sequential transfers: HTRANS[1:0] is either 2’b00 (IDLE) or 2’b10 (Non Sequential)
  //  
  // Usage
  // HSIZE = 10 // 1 Byte for Read and Write because of fifo ; use Word (32b) only for prevision
  // HADDR[1:0] = C_MyAddrAHBLite  // 
  // HPROT // Cacheable - Bufferable - Privileged - Data/Opcode   ; 0101 [3:0]
  // READY // Adding wait states by getting ready low not supported, don't care

  // Global Signals
  input  logic                      HCLK,       // The bus clock times all bus transfers. All signal timings are related to the rising edge of HCLK.
  input  logic                      HRESETn,    // The bus reset signal is active LOW and resets the system and the bus. This is the only active LOW AHB-Lite signal.
  // Address and control
  input  logic [C_AhbAddrWidth-1:0] HADDR,      // Restrained // The 32-bit system address bus.
  input  logic                      HWRITE,     // Indicates the transfer direction. When HIGH this signal indicates a write transfer and when LOW a read transfer. It has the same timing as the address signals, however, it must remain constant throughout a burst transfer. 
  input  logic                [2:0] HSIZE,      // Restrained //Indicates the size of the transfer, that is typically byte, halfword, or word. The protocol allows for larger transfer sizes up to a maximum of 1024 bits.
  input  logic                [2:0] HBURST,     // Not used // The burst type indicates if the transfer is a single transfer or forms part of a burst. Fixed length bursts of 4, 8, and 16 beats are supported. The burst can be incrementing or wrapping. Incrementing bursts of undefined length are also supported.
  input  logic                [3:0] HPROT,      // Restrained // The protection control signals provide additional information about a bus access and are primarily intended for use by any module that wants to implement some level of protection. The signals indicate if the transfer is an opcode fetch or data access, and if the transfer is a privileged mode access or user mode access. For masters with a memory management unit these signals also indicate whether the current access is cacheable or bufferable.
  input  logic                [1:0] HTRANS,     // Restrained // Indicates the transfer type of the current transfer. This can be: IDLE - BUSY - NONSEQUENTIAL - SEQUENTIAL.
  input  logic                      HMASTLOCK,  // Not used // When HIGH, this signal indicates that the current transfer is part of a locked sequence. It has the same timing as the address and control signals.
  input  logic                      HREADY,     // Not used
  // Transfer and response
  output logic                      HREADYOUT,  // When HIGH, the HREADYOUT signal indicates that a transfer has finished on the bus. This signal can be driven LOW to extend a transfer.
  output logic                      HRESP,      // Restrained // The transfer response, after passing through the multiplexor, provides the master with additional information on the status of a transfer. When LOW, the HRESP signal indicates that the transfer status is OKAY. When HIGH, the HRESP signal indicates that the transfer status is ERROR.
  // Data
  input  logic [C_AhbDataWidth-1:0] HWDATA,     // The write data bus transfers data from the master to the slaves during write operations. A minimum data bus width of 32 bits is recommended. However, this can be extended to enable higher bandwidth operation.
  output logic [C_AhbDataWidth-1:0] HRDATA,     // During read operations, the read data bus transfers data from the selected slave to the multiplexor. The multiplexor then transfers the data to the master. A minimum data bus width of 32 bits is recommended. However, this can be extended to enable higher bandwidth operation.
  // Select
  input  logic                      HSEL,       // Each AHB-Lite slave has its own slave select signal HSELx and this signal indicates that the current transfer is intended for the selected slave. When the slave is initially selected, it must also monitor the status of HREADY to ensure that the previous bus transfer has completed, before it responds to the current transfer. The HSELx signal is a combinatorial decode of the address bus.



// Master AHB-Lite
// ________________________
      HCLK            : in std_logic; 
    HRESETn         : in std_logic; 
    HADDR           : out std_logic_vector(C_AhbAddrWidth-1 downto 0);   
    HWRITE          : out std_logic;     --
    HSIZE           : out std_logic_vector(2 downto 0);   
    HBURST          : out std_logic_vector(2 downto 0);   
    HPROT           : out std_logic_vector(3 downto 0);   
    HTRANS          : out std_logic_vector(1 downto 0);   
    HMASTLOCK       : out std_logic;      
    HREADY          : in std_logic;          
    HRESP           : in std_logic;     
    HWDATA          : out std_logic_vector(C_AhbDataWidth-1 downto 0);
    HRDATA          : in std_logic_vector(C_AhbDataWidth-1 downto 0)



// ______________________________________________________________
// From AMBA® AXI and ACE Protocol Specification ARM IHI 0022H.c
// --------------------------------------------------------------
// ============
// AXI3 & AXI4  // Chapter A2 Signal Descriptions
// ============
// Manager interface (only)
// ________________________

input   logic          i_AClk,//Global clock signal. Synchronous signals are sampled on the rising edge of the global clock.
input   logic          i_AReset_n,//Global reset signal. This signal is active-LOW.

//Write address channel signals
output  logic [3:0]    o_Awid, //Identification tag for a write transaction.
output  logic [31:0]   o_Awaddr,//The address of the first transfer in a write transaction.
output  logic [7:0]    o_Awlen, //Length, the exact number of data transfers in a write transaction. This information determines the number of data transfers associated with the address. This changes between AXI3 and AXI4.
output  logic [2:0]    o_Awsize, //Size, the number of bytes in each data transfer in a write transaction.
output  logic [1:0]    o_Awburst, //Burst type, indicates how address changes between each transfer in a write
output  logic          o_Awlock,// Provides information about the atomic characteristics of a write transaction. This changes between AXI3 and AXI4.
output  logic [3:0]    o_Awcache, //Indicates how a write transaction is required to progress through a system.
output  logic [2:0]    o_Awprot,// Protection attributes of a write transaction: privilege, security level, and access type.
output  logic [3:0]    o_Awqos,//Quality of Service identifier for a write transaction. Not implemented in AXI3.
output  logic [3:0]    o_Awregion,//Region indicator for a write transaction. Not implemented in AXI3.
output  logic [3:0]    o_Awuser, //User-defined extension for the write address channel. Not implemented in AXI3.
output  logic          o_Awvalid, //Indicates that the write address channel signals are valid.
input   logic          i_Awready, //Indicates that a transfer on the write address channel can be accepted.
// Write data channel signals
//output  logic           o_Wid //The ID tag of the write data transfer. Implemented in AXI3 only.
output  logic [31:0]   o_Wdata, //Write data.
output  logic [3:0]    o_Wstrb, //Write strobes, indicate which byte lanes hold valid data.
output  logic          o_Wlast, //Indicates whether this is the last data transfer in a write transaction.
output  logic [3:0]    o_Wuser, //User-defined extension for the write data channel. Not implemented in AXI3.
output  logic          o_Wvalid, //Indicates that the write data channel signals are valid.
input   logic          i_Wready, //Indicates that a transfer on the write data channel can be accepted.
// Write response channel signals
input   logic [3:0]    i_Bid, //Identification tag for a write response.
input   logic [1:0]    i_Bresp, //Write response, indicates the status of a write transaction.
input   logic [3:0]    i_Buser, //User-defined extension for the write response channel. Not implemented in AXI3.
input   logic          i_Bvalid, //Indicates that the write response channel signals are valid.
output  logic          o_Bready, //Indicates that a transfer on the write response channel can be accepted.
//Read address channel signals
output  logic [3:0]    o_Arid, //Identification tag for a read transaction.
output  logic [31:0]   o_Araddr, //The address of the first transfer in a read transaction.
output  logic [7:0]    o_Arlen, //Length, the exact number of data transfers in a read transaction. This changes between AXI3 and AXI4.
output  logic [2:0]    o_Arsize, //Size, the number of bytes in each data transfer in a read transaction.
output  logic [1:0]    o_Arburst, //Burst type, indicates how address changes between each transfer in a read transaction.
output  logic          o_Arlock, //Provides information about the atomic characteristics of a read transaction. This changes between AXI3 and AXI4.
output  logic [3:0]    o_Arcache, //Indicates how a read transaction is required to progress through a system.
output  logic [2:0]    o_Arprot, //Protection attributes of a read transaction: privilege, security level, and access type.
output  logic [3:0]    o_Arqos, //Quality of Service identifier for a read transaction. Not implemented in AXI3.
output  logic [3:0]    o_Arregion, // Region indicator for a read transaction. Not implemented in AXI3.
output  logic [3:0]    o_Aruser, //User-defined extension for the read address channel. Not implemented in AXI3.
output  logic          o_Arvalid, //Indicates that the read address channel signals are valid.
input   logic          i_Arready, //Indicates that a transfer on the read address channel can be accepted.
// Read data channel signals
input   logic [3:0]    i_Rid, //Identification tag for read data and response.
input   logic [31:0]   i_Rdata, //Read data.
input   logic [1:0]    i_Rresp, //Read response, indicates the status of a read transfer.
input   logic          i_Rlast, //Indicates whether this is the last data transfer in a read transaction.
input   logic [3:0]    i_Ruser, //User-defined extension for the read data channel. Not implemented in AXI3.
input   logic          i_Rvalid, //Indicates that the read data channel signals are valid.
output  logic          o_Rready, //Indicates that a transfer on the read data channel can be accepted.


// ======
// AXI4  // A9.3 Default signal values
// ======
// AXI4 - Manager interface
// ________________________

// Write channel signals (address, data, response)
input   logic          i_AClk,
input   logic          i_AReset_n,
// output  logic [3:0]    o_Awid, // Optional
output  logic [31:0]   o_Awaddr,
// output  logic [3:0]    o_Awregion,  // Optional
// output  logic [7:0]    o_Awlen, // Optional
// output  logic [2:0]    o_Awsize, // Optional
// output  logic [1:0]    o_Awburst, // Optional
// output  logic          o_Awlock, // Optional
// output  logic [3:0]    o_Awcache, // Optional
output  logic [2:0]    o_Awprot,
// output  logic [3:0]    o_Awqos, // Optional 
output  logic          o_Awvalid,
input   logic          i_Awready,
// ====== // output  logic [3:0]    o_Awuser,
output  logic [31:0]   o_Wdata, 
// output  logic [3:0]    o_Wstrb, // Optional 
output  logic          o_Wlast, 
// ====== // output  logic [3:0]    o_Wuser, 
output  logic          o_Wvalid,
input   logic          i_Wready,
// input   logic [3:0]    i_Bid, // Optional 
// input   logic [1:0]    i_Bresp, // Optional 
// ====== // input   logic [3:0]    i_Buser,
input   logic          i_Bvalid,
output  logic          o_Bready,


// Read channel signals (address, data)
// output  logic [3:0]    o_Arid, // Optional 
output  logic [31:0]   o_Araddr,
// output  logic [3:0]    o_Arregion, // Optional
// output  logic [7:0]    o_Arlen, // Optional
// output  logic [2:0]    o_Arsize, // Optional
// output  logic [1:0]    o_Arburst, // Optional 
// output  logic          o_Arlock, // Optional
// output  logic [3:0]    o_Arcache, // Optional
output  logic [2:0]    o_Arprot,
// output  logic [3:0]    o_Arqos, // Optional
// ====== // output  logic [3:0]    o_Aruser, 
output  logic          o_Arvalid, 
input   logic          i_Arready, 
// input   logic [3:0]    i_Rid, // Optional
input   logic [31:0]   i_Rdata,
// input   logic [1:0]    i_Rresp, // Optional
// input   logic          i_Rlast, // Optional
// ====== // input   logic [3:0]    i_Ruser,
input   logic          i_Rvalid,
output  logic          o_Rready,




// ======
// AXI4  // A9.3 Default signal values
// ======
// AXI4 - Subordinate interface
// _____________________________

// Write channel signals (address, data, response)
input   logic          i_AClk,
input   logic          i_AReset_n,
input  logic [3:0]     i_Awid, 
input  logic [31:0]    i_Awaddr,
// input  logic [3:0]    i_Awregion, // Optional
input  logic [7:0]    i_Awlen,
input  logic [2:0]    i_Awsize,
input  logic [1:0]    i_Awburst,
// input  logic          i_Awlock, // Optional
// input  logic [3:0]    i_Awcache, // Optional
// input  logic [2:0]    i_Awprot, // Optional
// input  logic [3:0]    i_Awqos, // Optional 
input  logic           i_Awvalid,
output logic           o_Awready,
// ====== // input  logic [3:0]    i_Awuser,
input  logic [31:0]   i_Wdata, 
input  logic [3:0]    i_Wstrb,
// input  logic          i_Wlast, // Optional 
// ====== // input  logic [3:0]    i_Wuser, 
input  logic          i_Wvalid,
output logic          o_Wready,
output   logic [3:0]  o_Bid, 
// output   logic [1:0]    o_Bresp,// Optional 
// ====== // output   logic [3:0]    o_Buser,
output logic          o_Bvalid,
input  logic          i_Bready,


// Read channel signals (address, data)
input  logic [3:0]    i_Arid, 
input  logic [31:0]   i_Araddr,
// input  logic [3:0]    i_Arregion, // Optional
input  logic [7:0]    i_Arlen,
input  logic [2:0]    i_Arsize,
input  logic [1:0]    i_Arburst,
// input  logic          i_Arlock, // Optional
// input  logic [3:0]    i_Arcache, // Optional
// input  logic [2:0]    i_Arprot, // Optional
// input  logic [3:0]    i_Arqos, // Optional
// ====== // input  logic [3:0]    i_Aruser, 
input  logic          i_Arvalid, 
output   logic          o_Arready, 
output   logic [3:0]    o_Rid,
output   logic [31:0]   o_Rdata,
// output   logic [1:0]    o_Rresp, // Optional
output   logic          o_Rlast,
// ====== // output   logic [3:0]    o_Ruser,
output logic          o_Rvalid,
input logic          i_Rready,





// ==========
// AXI4-Lite  // B1.1.1 Signal list
// ==========
// AXI4 signals modified in AXI4-Lite
// RRESP, BRESP: The EXOKAY response is not supported on the read data and write response channels.

// AXI4 signals not supported in AXI4-Lite
// AWLEN, ARLEN The burst length is defined to be 1, equivalent to an AxLEN value of zero.
// AWSIZE, ARSIZE All accesses are defined to be the width of the data bus.

// AXI4-Lite requires a fixed data bus width of either 32-bit or 64-bit.

// AWBURST, ARBURST: The burst type has no meaning because the burst length is 1.
// AWLOCK, ARLOCK: All accesses are defined as Normal accesses, equivalent to an AxLOCK value of zero.
// AWCACHE, ARCACHE: All accesses are defined as Non-modifiable, Non-bufferable, equivalent to an AxCACHE value of 0b0000.
// WLAST, RLAST: All bursts are defined to be of length 1, equivalent to a WLAST or RLAST value of 1.

// Optional signaling
// AXI4-Lite supports multiple outstanding transactions, but a Subordinate can restrict this by the appropriate use of the handshake signals.
// AXI4-Lite does not support AXI IDs. This means that all transactions must be in order, and all accesses use a single fixed ID value.
// AXI4-Lite does not support data interleaving, the burst length is defined as 1.

input   logic           i_Clk,//Global clock signal. Synchronous signals are sampled on the rising edge of the global clock.
input   logic           i_AReset_n,//Global reset signal. This signal is active-LOW.

//Write address channel signals
output  logic          _Awvalid, //Indicates that the write address channel signals are valid.
input   logic          _Awready, //Indicates that a transfer on the write address channel can be accepted.
output  logic [31:0]   _Awaddr,//The address of the first transfer in a write transaction.
output  logic [2:0]    _Awprot,// Protection attributes of a write transaction: privilege, security level, and access type.
// Write data channel signals
output  logic          _Wvalid, //Indicates that the write data channel signals are valid.
input   logic          _Wready, //Indicates that a transfer on the write data channel can be accepted.
output  logic [31:0]   _Wdata, //Write data.
output  logic [3:0]    _Wstrb, //Write strobes, indicate which byte lanes hold valid data.
// Write response channel signals
input   logic          _Bvalid, //Indicates that the write response channel signals are valid.
output  logic          _Bready, //Indicates that a transfer on the write response channel can be accepted.
input   logic [1:0]    _Bresp, //Write response, indicates the status of a write transaction.
//Read address channel signals
output  logic          _Arvalid, //Indicates that the read address channel signals are valid.
input   logic          _Arready, //Indicates that a transfer on the read address channel can be accepted.
output  logic [31:0]   _Araddr, //The address of the first transfer in a read transaction.
output  logic [2:0]    _Arprot, //Protection attributes of a read transaction: privilege, security level, and access type.
// Read data channel signals
input   logic          _Rvalid, //Indicates that the read data channel signals are valid.
output  logic          _Rready, //Indicates that a transfer on the read data channel can be accepted.
input   logic [31:0]   _Rdata, //Read data.
input   logic [1:0]    _Rresp, //Read response, indicates the status of a read transfer.


// AXI4 - Lite - Manager interface
// _______________________________
input   logic           i_Clk,//Global clock signal. Synchronous signals are sampled on the rising edge of the global clock.
input   logic           i_AReset_n,//Global reset signal. This signal is active-LOW.

//Write address channel signals
output  logic          o_Awvalid, //Indicates that the write address channel signals are valid.
input   logic          i_Awready, //Indicates that a transfer on the write address channel can be accepted.
output  logic [31:0]   o_Awaddr,//The address of the first transfer in a write transaction.
output  logic [2:0]    o_Awprot,// Protection attributes of a write transaction: privilege, security level, and access type.
// Write data channel signals
output  logic          o_Wvalid, //Indicates that the write data channel signals are valid.
input   logic          i_Wready, //Indicates that a transfer on the write data channel can be accepted.
output  logic [31:0]   o_Wdata, //Write data.
//output  logic [3:0]    o_Wstrb, //Write strobes, indicate which byte lanes hold valid data.
// Write response channel signals
input   logic          i_Bvalid, //Indicates that the write response channel signals are valid.
output  logic          o_Bready, //Indicates that a transfer on the write response channel can be accepted.
//input   logic [1:0]    i_Bresp, //Write response, indicates the status of a write transaction.
//Read address channel signals
output  logic          o_Arvalid, //Indicates that the read address channel signals are valid.
input   logic          i_Arready, //Indicates that a transfer on the read address channel can be accepted.
output  logic [31:0]   o_Araddr, //The address of the first transfer in a read transaction.
output  logic [2:0]    o_Arprot, //Protection attributes of a read transaction: privilege, security level, and access type.
// Read data channel signals
input   logic          i_Rvalid, //Indicates that the read data channel signals are valid.
output  logic          o_Rready, //Indicates that a transfer on the read data channel can be accepted.
input   logic [31:0]   i_Rdata, //Read data.
//input   logic [1:0]    i_Rresp, //Read response, indicates the status of a read transfer.


// AXI4 - Lite - Subordinate interface
// ___________________________________
input   logic           i_Clk,//Global clock signal. Synchronous signals are sampled on the rising edge of the global clock.
input   logic           i_AReset_n,//Global reset signal. This signal is active-LOW.

//Write address channel signals
input  logic          i_Awvalid, //Indicates that the write address channel signals are valid.
output logic          o_Awready, //Indicates that a transfer on the write address channel can be accepted.
input  logic [31:0]   i_Awaddr,//The address of the first transfer in a write transaction.
// input  logic [2:0]    i_Awprot,// Protection attributes of a write transaction: privilege, security level, and access type.
// Write data channel signals
input  logic          i_Wvalid, //Indicates that the write data channel signals are valid.
output   logic        o_Wready, //Indicates that a transfer on the write data channel can be accepted.
input  logic [31:0]   i_Wdata, //Write data.
input  logic [3:0]    i_Wstrb, //Write strobes, indicate which byte lanes hold valid data.
// Write response channel signals
output   logic          o_Bvalid, //Indicates that the write response channel signals are valid.
input  logic          i_Bready, //Indicates that a transfer on the write response channel can be accepted.
//output   logic [1:0]    o_Bresp, //Write response, indicates the status of a write transaction.
//Read address channel signals
input  logic          i_Arvalid, //Indicates that the read address channel signals are valid.
output   logic          o_Arready, //Indicates that a transfer on the read address channel can be accepted.
input  logic [31:0]   i_Araddr, //The address of the first transfer in a read transaction.
//input  logic [2:0]    i_Arprot, //Protection attributes of a read transaction: privilege, security level, and access type.
// Read data channel signals
output   logic          o_Rvalid, //Indicates that the read data channel signals are valid.
input  logic          i_Rready, //Indicates that a transfer on the read data channel can be accepted.
output   logic [31:0]   o_Rdata, //Read data.
//output   logic [1:0]    o_Rresp, //Read response, indicates the status of a read transfer.



// ============================================
// Upgrading an AXI4-Lite Manager to AXI5-Lite // C2.2 AXI5-Lite compared with other interfaces
// ============================================
// If not already present, add ID signals. If the Manager supports only in-order responses, then use a single-bit ID and tie off ARID and AWID to 0b0.
// Add AWSIZE and ARSIZE outputs. An AXI4-Lite Manager only generates transactions that are full bus width, so these signals can be tied off to 0b010 for a 32-bit bus or 0b011 for a 64-bit bus.


// Upgrading an AXI4-Lite Subordinate to AXI5-Lite
// If not already present, add ID signals. The Subordinate must mirror ARID onto RID and AWID onto BID. Responses can continue to be provided in-order, or out-of-order capability can be added.
// Add the AWSIZE input. It can be decided whether to use this, or use WSTRB to determine which bytes to write.
// Modify the Subordinate to fully support WSTRB, if it does not already. The Subordinate must only write those bytes indicated by the relevant WSTRB bits. A write with no strobes asserted must be supported.
// Add the ARSIZE input. The Subordinate can choose to use this input to drive only the active bytes in the transfer, or it can continue to drive the full bus width of read data.
// TBC


// ==========
// AXI5-Lite  // C2.7 AXI5-Lite signal list
// ==========
// AXI5 - Manager interface
// ________________________
// TBC

// AXI5 - Subordinate interface
// _____________________________
// TBC



// ______________________________________________________________
// AMBA® 4 AXI4-Stream Protocol Version: 1.0 Specification
// --------------------------------------------------------------
// AXI4-Stream - Master
// ____________________
input  logic i_Clk,             // The global clock signal. All signals are sampled on the rising edge of ACLK.
input  logic i_AReset_n,        // The global reset signal. ARESETn is active-LOW.
output logic o_TVALID,          // TVALID indicates that the master is driving a valid transfer. A transfer takes place when both TVALID and TREADY are asserted.
// input  logic o_TREADY,       // Optional // TREADY indicates that the slave can accept a transfer in the current cycle.
output logic [31:0]  o_TDATA,   // TDATA is the primary payload that is used to provide the data that is passing across the interface. The width of the data payload is an integer number of bytes.
// output logic [7:0] o_TSTRB,  // Optional // TSTRB is the byte qualifier that indicates whether the content of the associated byte of TDATA is processed as a data byte or a position byte.
// output logic [3:0]o_TKEEP,   // Optional // TKEEP is the byte qualifier that indicates whether the content of the associated byte of TDATA is processed as part of the data stream. Associated bytes that have the TKEEP byte qualifier deasserted are null bytes and can be removed from the data stream.
// output logic o_TLAST,        // Optional // TLAST indicates the boundary of a packet.
// output logic [7:0] o_TID,    // Optional // TID is the data stream identifier that indicates different streams of data.
// output logic [3:0] o_TDEST,  // Optional // TDEST provides routing information for the data stream.
// output logic [3:0] o_TUSER,  // Optional // TUSER is user defined sideband information that can be transmitted alongside the data stream.
 
// AXI4-Stream - Slave
// ____________________
input  logic i_Clk,             // The global clock signal. All signals are sampled on the rising edge of ACLK.
input  logic i_AReset_n,        // The global reset signal. ARESETn is active-LOW.
input  logic o_TVALID,          // TVALID indicates that the master is driving a valid transfer. A transfer takes place when both TVALID and TREADY are asserted.
// output logic o_TREADY,       // Optional // TREADY indicates that the slave can accept a transfer in the current cycle.
input  logic [31:0]  o_TDATA,   // TDATA is the primary payload that is used to provide the data that is passing across the interface. The width of the data payload is an integer number of bytes.
// input  logic [7:0] o_TSTRB,  // Optional // TSTRB is the byte qualifier that indicates whether the content of the associated byte of TDATA is processed as a data byte or a position byte.
// input  logic [3:0]o_TKEEP,   // Optional // TKEEP is the byte qualifier that indicates whether the content of the associated byte of TDATA is processed as part of the data stream. Associated bytes that have the TKEEP byte qualifier deasserted are null bytes and can be removed from the data stream.
// input  logic o_TLAST,        // Optional // TLAST indicates the boundary of a packet.
// input  logic [7:0] o_TID,    // Optional // TID is the data stream identifier that indicates different streams of data.
// input  logic [3:0] o_TDEST,  // Optional // TDEST provides routing information for the data stream.
// input  logic [3:0] o_TUSER,  // Optional // TUSER is user defined sideband information that can be transmitted alongside the data stream.