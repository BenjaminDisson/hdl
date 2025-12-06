// ******************
// File: TopUartAhbLite.sv
// Description : UART (RS232) with an AHB Lite interface
// Modification
// ----------------------------------------------------------
//     Date      Ver.         Author       Comments
// ----------------------------------------------------------
// 2020/06/10 :  1.0  : Benjamin Disson : First building
//
// There is only one AHBLite interface for Tx and Rx uart flow
// because of the speed difference
//
//



module TopUartAhbLite#(  
    parameter C_MyAddrAHBLite= 3,
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
  // Usage
  // HSIZE = 10 // 1 Byte for Read and Write because of fifo ; use Word (32b) only for prevision
  // HADDR[1:0] = C_MyAddrAHBLite  // 
  // HPROT // Cacheable - Bufferable - Privileged - Data/Opcode   ; 0101 [3:0]
  // READY // Adding wait states by getting ready low not supported, don't care

  // Global Signals
  input  logic                      HCLK, 
  input  logic                      HRESETn, 
  // Address and control
  input  logic [C_AhbAddrWidth-1:0] HADDR,     // Restrained
  input  logic                      HWRITE,  
  input  logic                [2:0] HSIZE,     // Restrained
  input  logic                [2:0] HBURST,    // Not used
  input  logic                [3:0] HPROT,     // Restrained 
  input  logic                [1:0] HTRANS,    // Restrained
  input  logic                      HMASTLOCK, // Not used
  input  logic                      HREADY,    // Not used
  // Transfer and response
  output logic                      HREADYOUT,
  output logic                      HRESP,     // Restrained
  // Data
  input  logic [C_AhbDataWidth-1:0] HWDATA,
  output logic [C_AhbDataWidth-1:0] HRDATA, 
  // Select
  input  logic                      HSEL, 
   

  // RS232 Signals
  //_______________// 
  // External chip signals
  input  logic                      i_UartRx,  // Input from RS-232 
  output logic                      o_UartTx,  // Output to RS-232 
  // Internal Interrupt signals 
  output logic                      o_UartIrq  // Interrupt which signal data available
); 

// ===========================================================================
// == Constant declaration
// ===========================================================================
  timeunit 1ns;
  timeprecision 1ns;

// ===========================================================================
// == Type declaration
// ===========================================================================

// ===========================================================================
// == Signals declaration
// ===========================================================================



 
  // |AHB-Lite|-->|FifoTx|
  logic  [7:0] s_AhbToFifoTxWData; 
  logic        s_AhbToFifoTxWR ;
  logic        s_FifoTxFull;  
 //  |FifoRx|-->|AHB-Lite| 
  logic  [7:0] s_FifoRxToAhbRData;  
  logic        s_FifoRxToAhbRD; 
   

  // |FifoTx|-->|UartTx|
  logic  [7:0] s_FifoTxToUartTxData;
  logic        s_UartTxRqData;   
  logic        s_FifoTxEmpty;  
  // |FifoRx|<--|UartRx|
  logic  [7:0] s_UartRxToFifoRxData;
  logic        s_UartRxDone; 
   

   // |FifoRx|-->IRQ
  logic        s_FifoRxEmpty;

  // Not used
  logic        s_FifoRxFull; 



// ===========================================================================
// == Assignment
// =========================================================================== 
// Transfert Response
  assign HREADYOUT = !s_FifoTxFull ;   //If FIFO_TX is full (don't write)  - wait.
 
  //UART  write select 
  assign  s_AhbToFifoTxWR = HTRANS[1] & HWRITE & HSEL;
  //UART read select 
  assign s_FifoRxToAhbRD = HTRANS[1] & !HWRITE & HSEL;

// Address controle
// [2:0] HSIZE     // Byte - Halfword - Word - Doublewordread           ; read = Byte 
// [1:0] HADDR     //  00 - 01 - 10 - 11                                ; use of LSB only, so 00
// [2:0] HBURST    // SINGLE - INCR - WRAP[4|8|16] - INCR[4|8|16]       ; Single
// [3:0] HPROT     // Cacheable - Bufferable - Privileged - Data/Opcode ; 0101 [3:0]
// [1:0] HTRANS    // IDLE - BUSY - NON-SEQ - SEQ                       ; Only IDLE or NON-SEQ 
//       HMASTLOCK //UNLOCKED - LOCKED                                  ; is always 1’b0 (UNLOCKED)

// Master shall be ready

// HTRANS(00) = IDLE    Master does not wish to perform a transfer
// HTRANS(01) = BUSY    Bus Master is in the middle of a burst but cannot immediately continue with the next transfer
// HTRANS(10) = NON-SEQ Indicates the first transfer of a burst or a single transfer
// HTRANS(11) = SEQ     The remaining transfers in the burst are sequential address steps from the previous transfer. 
//                      Step size is that of data width of transfer (which is shown by HSIZE)
//  assign HRESP = 1'b0; // Low = Okay, high = error 
// !HADDR[0] | !HADDR[1] because of C_MyAddrAHBLite
//  assign HRESP = !HSEL & (HSIZE[0] | !HSIZE[1] | HSIZE[2] | !HADDR[0] | !HADDR[1] | HBURST[0] | HBURST[1] | HBURST[2] | !HPROT[0] | HPROT[1] | !HPROT[2] | HPROT[3] | HTRANS[0] | HMASTLOCK);
      


// Data
  assign s_AhbToFifoTxWData = HWDATA[7:0];   //Only write last 8 bits of Data 
  assign HRDATA = {24'h0000_00,s_FifoRxToAhbRData}; //Assign UART output to AHB RDATA  // {>>xx{}}

// Rout the interrupt - If Fifo Rx dispose of data  
  assign o_UartIrq = s_FifoRxEmpty;

// ===========================================================================
// == Process - 
// ===========================================================================  
  always_comb 
  begin
    case (HSEL)
      0: HRESP <= 1'b0;
      1: HRESP <= (HSIZE[0] | !HSIZE[1] | HSIZE[2] | !HADDR[0] | !HADDR[1] | HBURST[0] | HBURST[1] | HBURST[2] | !HPROT[0] | HPROT[1] | !HPROT[2] | HPROT[3] | !HTRANS[1] | HTRANS[0] | HMASTLOCK);
      default: HRESP <= 1'b0;
    endcase
  end


// ===========================================================================
// == Component instantiation
// =========================================================================== 
// =============
// == MAPPING ==
// =============
// 
//       TopUartAhbLite
// |-----------------------------
// |                            |
// |       |FifoTx|-->|UartTx|--|--> Output
// |         /\          /\     |
// |         ||          ||     |
// |---------            ||     |
// |AHB-Lite|-->s_BaudRateClock |
// |---------                   |
// |         /\                 |
// |  IRQ    ||                 |
// |<------|FifoRx|<--|UartRx|<-|-- Input
// |                            |
// |-----------------------------


//DWIDTH=8, AWIDTH=4
  FifoOneClock InstUartFifoTx  
   (
    .aclr(!HRESETn),
    .clock(HCLK),
    .data(s_AhbToFifoTxWData[7:0]),
    .rdreq(s_UartTxRqData),
    .wrreq(s_AhbToFifoTxWR),
    .empty(s_FifoTxEmpty),
    .full(s_FifoTxFull),
    .q(s_FifoTxToUartTxData[7:0])
    );

  UartTx InstUartTx( 
    .i_Clk(HCLK), 
    .i_ResetN(HRESETn), 
    .i_StartSending(!s_FifoTxEmpty),  
    .i_Data(s_FifoTxToUartTxData[7:0]), 
    .o_RequestData(s_UartTxRqData), 
    .o_UartTx(o_UartTx) 
  ); 

  UartRx InstUartRx( 
    .i_Clk(HCLK), 
    .i_ResetN(HRESETn), 
    .i_UartRx(i_UartRx), 
    .o_Done(s_UartRxDone), 
    .o_Data(s_UartRxToFifoRxData[7:0]) 
  ); 
   
  FifoOneClock InstUartFifoRx
  ( 
    .aclr(!HRESETn),
    .clock(HCLK),
    .data(s_UartRxToFifoRxData[7:0]),
    .rdreq(s_FifoRxToAhbRD),
    .wrreq(s_UartRxDone),
    .empty(s_FifoRxEmpty),
    .full(s_FifoRxFull),
    .q(s_FifoRxToAhbRData[7:0])
    );
   
 
endmodule 

