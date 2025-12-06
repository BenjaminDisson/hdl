// ******************
// File: UartTest.sv
// Description : Send data by AHLLite to uart
// Modification
// ----------------------------------------------------------
//     Date      Ver.         Author       Comments
// ----------------------------------------------------------
// 2020/08/27 :  1.0  : Benjamin Disson : First building
//
//
//
//
//
/*


module UartTest#(  
    parameter C_AhbAddrWidth = 32,   // Width of address bus
    parameter C_AhbDataWidth = 32    // Width of data bus
)
( 
  // Standard AHB-Lite Slave Signals 
  // ______________________________ //
  // Language restriction
  // No BURSTtransaction:     HBURST[2:0] is always 3’b000
  // No locked transactions:  HMASTLOCK is always 1’b0
  // No sequential transfers: HTRANS[1:0] is either 2’b00 (IDLE) or 2’b10 (Non Sequential)
  //  
  // Usage for UART
  // HSIZE = 001 (Byte) for Read and Write because of fifo
  // HADDR[1:0] = 00  // use of LSB only
  // HPROT // Cacheable - Bufferable - Privileged - Data/Opcode   ; read = 0000 Write 0001
   


  //TODO :
  //1 - on a considéré READY = 1 ; A gérer READY = 0
  //2 - HRESP a gérer

  // CLOCK AND RESETS ------------------
  input  wire        HCLK,              // Clock
  input  wire        HRESETn,           // Asynchronous reset

  // AHB-LITE MASTER PORT --------------
  output wire [C_AhbAddrWidth-1:0] HADDR,             // AHB transaction address
  output wire [ 2:0] HBURST,            // AHB burst: tied to single
  output wire        HMASTLOCK,         // AHB locked transfer (always zero)
  output wire [ 3:0] HPROT,             // AHB protection: priv; data or inst
  output wire [ 2:0] HSIZE,             // AHB size: byte, half-word or word
  output wire [ 1:0] HTRANS,            // AHB transfer: non-sequential only
  output wire [C_AhbDataWidth-1:0] HWDATA,            // AHB write-data
  output wire        HWRITE,            // AHB write control
  input  wire [C_AhbDataWidth-1:0] HRDATA,            // AHB read-data
  input  wire        HREADY,            // AHB stall signal
  input  wire        HRESP,             // AHB error response



  // RS232 Signals
  //_______________// 
  // Internal Interrupt signals from uart 
  input logic                      i_UartIrq  //Interrupt 
); 

// ===========================================================================
// == Constant declaration
// ===========================================================================
  timeunit 1ns;
  timeprecision 1ns;
  localparam C_AddrUart = 3;
  localparam C_ByteByWord = 4;
// Command (C) - 0x43
// Load (L) - 0x4C
// Read (R) - 0x52
// Init (I) - 0x49
// Start (S) - 0x53

// ===========================================================================
// == Type declaration
// ===========================================================================



// ===========================================================================
// == Signals declaration
// ===========================================================================
  shortint s_ByteCounterW; 
  logic  [C_AhbDataWidth-1:0] s_DataFromModule;


assign s_DataFromModule = 32'h43524953;

          STPostData:  // Write to Uart 
          begin
            HADDR          = {24'h0000_00,0'h03};
            HBURST         = 3'b000;
            HMASTLOCK      = 1'b0; 
            HPROT          = 4'b0000;  
            HSIZE          = 3'b000;  
            HTRANS         = 2'b10;         
            
            HWRITE         = 1'b1;    

            if (s_ByteCounterW = C_ByteByWord)
              begin
                HWDATA         = {24'h0000_00,8'h55}; // For Debug ; no impact
                HWRITE         = 1'b0;                
                s_ByteCounterW = 0;
                t_ExecuteAccess = StIdle 
              end
            else
              begin
                HWDATA         = s_DataFromModule[31-s_ByteCounterW*8:24-s_ByteCounterW*8:];
                HWRITE         = 1'b1;
                s_ByteCounterW = s_ByteCounterR + 1;
                t_ExecuteAccess  = STPostData;
              end





              */