// ******************
// File: TopUartAhbLite.sv
// Description : UART (RS232) with an AHB Lite interface
// Modification
// ----------------------------------------------------------
//     Date      Ver.         Author       Comments
// ----------------------------------------------------------
// 2020/06/10 :  1.0  : Benjamin Disson : First building
//
//
//
//
//



module TopUartAhbLite#(  
    parameter C_AhbAddrWidth = 32,   // Width of address bus
    parameter C_AhbDataWidth = 32,   // Width of data bus
    parameter C_BaudRate     = 434  // 2604 = 50Mhz/ 115200
)
( 
  // Standard AHB-Lite Slave Signals 
  // ______________________________ //
  // Language restriction
  // No BURSTtransaction:     HBURST[2:0] is always 3’b000
  // No locked transactions:  HMASTLOCK is always 1’b0
  // No sequential transfers: HTRANS[1:0] is either 2’b00 (IDLE) or 2’b10 (Non Sequential)
  //  
  //
  // Global Signals
  input  logic                      HCLK, 
  input  logic                      HRESETn, 
  // Address and control
  input  logic [C_AhbAddrWidth-1:0] HADDR,
  input  logic                      HWRITE,  
  input  logic                [2:0] HSIZE,     // To manage
  input  logic                [2:0] HBURST,    // To manage
  input  logic                [3:0] HPROT,     // To manage  
  input  logic                [1:0] HTRANS,  
  input  logic                      HMASTLOCK, // To manage
  input  logic                      HREADY,   
  // Transfer and response
  output logic                      HREADYOUT,
  output logic                      HRESP,     // To manage
  // Data
  input  logic [C_AhbDataWidth-1:0] HWDATA,
  output logic [C_AhbDataWidth-1:0] HRDATA, 
  // Select
  input  logic                      HSEL, 
   

  // RS232 Signals
  //_______________// 
  // External chip signals
  input  logic                      i_UartRx,  //Input from RS-232 
  output logic                      o_UartTx,  //Output to RS-232 
  // Internal Interrupt signals 
  output logic                      o_UartIrq  //Interrupt 
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

  // Baudrate generator
  logic [11:0] s_CountBaudRate; 
  logic        s_BaudRateClock;

 
  // |AHB-Lite|-->|FifoTx|
  logic  [7:0] s_AhbToFifoTxWData; 
  logic        s_AhbToFifoTxWR ;
  logic        s_FifoTxFull;  
 //  |FifoRx|-->|AHB-Lite| 
  logic  [7:0] s_FifoRxToAhbRData;  
  logic        s_FifoRxToAhbRD; 
   

  // |FifoTx|-->|UartTx|
  logic  [7:0] s_FifoTxToUartTxData;
  logic        s_UartTxDone;   
  logic        s_FifoTxEmpty;  
  // |FifoRx|<--|UartRx|
  logic  [7:0] s_UartRxToFifoRxData;
  logic        s_UartRxDone; 
   

   // |FifoRx|-->IRQ
  logic        s_FifoRxEmpty;

  // Not used
  logic        s_FifoRxFull; 



// ===========================================================================
// == Process - Set logic for AHB Address State
// ===========================================================================  
  always_ff @(posedge HCLK iff HRESETn or negedge HRESETn)
  begin
    if (!HRESETn)
      begin
        s_AhbToFifoTxWR = 1'b0;
        s_FifoRxToAhbRD = 1'b0;

      end
    else
      begin
        if(HREADY)
          begin
              //UART  write select 
              s_AhbToFifoTxWR = HTRANS[1] & HWRITE & HSEL;
                //UART read select 
              s_FifoRxToAhbRD = HTRANS[1] & ~HWRITE & HSEL;
          end 
        
      end
  end

// ===========================================================================
// == Process - RS232 clock generator
// ===========================================================================  
  always_ff @(posedge HCLK iff HRESETn or negedge HRESETn)
  begin
    if (!HRESETn)
      begin
        s_CountBaudRate = 0;
        s_BaudRateClock = 1'b0;

      end
    else
      begin
          s_CountBaudRate = ((s_CountBaudRate == C_BaudRate) ? 0 : s_CountBaudRate + 1'b1);         
          s_BaudRateClock = ((s_CountBaudRate == C_BaudRate) ? 1'b1 : 1'b0); 
      end
  end


// ===========================================================================
// == Assignment
// =========================================================================== 

  assign HREADYOUT = ~s_FifoTxFull;   //If Read and FIFO_RX is empty - wait. 
  assign s_AhbToFifoTxWData = HWDATA[7:0];   //Only write last 8 bits of Data 
  assign HRDATA = {24'h0000_00,s_FifoRxToAhbRData}; //Assign UART output to AHB RDATA 
  assign o_UartIrq = ~s_FifoRxEmpty;


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
// |         ||                 |
// |         \/                 |
// |---------                   |
// |AHB-Lite|                   |
// |---------                   |
// |         /\                 |
// |  IRQ    ||                 |
// |<------|FifoRx|<--|UartRx|<-|-- Input
// |                            |
// |-----------------------------


//DWIDTH=8, AWIDTH=4
  FifoOneClock InstUartFifoTx  
   (
    .aclr(HRESETn),
    .clock(HCLK),
    .data(s_AhbToFifoTxWData[7:0]),
    .rdreq(s_UartTxDone),
    .wrreq(s_AhbToFifoTxWR),
    .empty(s_FifoTxEmpty),
    .full(s_FifoTxFull),
    .q(s_FifoTxToUartTxData[7:0])
    );


  FifoOneClock InstUartFifoRx
  ( 
    .aclr(HRESETn),
    .clock(HCLK),
    .data(s_UartRxToFifoRxData[7:0]),
    .rdreq(s_FifoRxToAhbRD),
    .wrreq(s_UartRxDone),
    .empty(s_FifoRxEmpty),
    .full(s_FifoRxFull),
    .q(s_FifoRxToAhbRData[7:0])
    );
   
  UART_RX InstUartRx( 
    .clk(HCLK), 
    .resetn(HRESETn), 
    .s_BaudRateClock(s_BaudRateClock), 
    .rx(o_UartTx), 
    .s_UartRxDone(s_UartRxDone), 
    .dout(s_UartRxToFifoRxData[7:0]) 
  ); 
   
  UartTx InstUartTx( 
    .i_Clk(HCLK), 
    .i_ResetN(HRESETn), 
    .i_StartSending(!s_FifoTxEmpty), 
    .i_BaudRateClock(s_BaudRateClock), 
    .i_Data(s_FifoTxToUartTxData[7:0]), 
    .o_Done(s_UartTxDone), 
    .o_UartTx(o_UartTx) 
  ); 
   
 
endmodule 

