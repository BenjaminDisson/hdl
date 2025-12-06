// ******************
// File: CtrlAhbLite.sv
// Description : Main AHB-Lite master controller
// Modification
// ----------------------------------------------------------
//     Date      Ver.         Author       Comments
// ----------------------------------------------------------
// 2020/07/23 :  1.0  : Benjamin Disson : First building
//
//
//
//
//



module CtrlAhbLite#(  
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

// ===========================================================================
// == Type declaration
// ===========================================================================
  typedef enum{StIdle,StWait,StCapture,StExecute} ReadTransaction_t;
  ReadTransaction_t t_ReadAccess;

  typedef enum{StIdle,StWait,StCapture, ,STPostData, STDone} ExecuteTransaction_t;
  ExecuteTransaction_t t_ExecuteAccess;


// ===========================================================================
// == Signals declaration
// ===========================================================================

  logic  [C_AhbDataWidth-1:0] s_DataFromUart; 
  shortint s_ByteCounterR; 
  shortint s_ByteCounterW; 
  logic  [C_AhbDataWidth-1:0] s_DataFromModule;

// ===========================================================================
// == Process - Manage Read access from AHB-Lite
// ===========================================================================  

  always_ff @(posedge HCLK iff HRESETn or negedge HRESETn)
  begin
    if (!HRESETn)
      begin
        HADDR          = 32'h00000000; 
        HBURST         = 3'b000;
        HMASTLOCK      = 1'b0; 
        HPROT          = 4'b0000;  
        HSIZE          = 3'b000;  
        HTRANS         = 2'b00;
     
        HWDATA         = {24'h0000_00,8'h55}; // For Debug ; no impact
        HWRITE         = 1'b0;        
        s_DataFromUart = s_DataFromUart;
        s_ByteCounterR  = 0;
        t_ReadAccess   = StIdle;
      end
    else
      begin
        case(t_ReadAccess)          
          StIdle:
          begin 
            if(i_UartIrq) // launch start
              begin 
                HADDR          = C_AddrUart;
                HBURST         = 3'b000;
                HMASTLOCK      = 1'b0; 
                HPROT          = 4'b0000;  
                HSIZE          = 3'b000;  
                HTRANS         = 2'b10;
     
                HWDATA         = {24'h0000_00,8'h55}; // For Debug ; no impact
                HWRITE         = 1'b0;  
                s_DataFromUart = s_DataFromUart; 
                s_ByteCounterR  = s_ByteCounterR;             
                t_ReadAccess   = StWait;
              end
            else                                                 
              begin
                HADDR          = 32'h00000000; 
                HBURST         = 3'b000;
                HMASTLOCK      = 1'b0; 
                HPROT          = 4'b0000;  
                HSIZE          = 3'b000;  
                HTRANS         = 2'b00;

                HWDATA         = {24'h0000_00,8'h55}; // For Debug ; no impact
                HWRITE         = 1'b0;
                s_DataFromUart = s_DataFromUart;
                s_ByteCounterR  = s_ByteCounterR;
                t_ReadAccess   = StIdle;
              end
          end

          StWait: 
          begin // Wait a cycle and close transaction
            HADDR          = 32'h00000000; 
            HBURST         = 3'b000;
            HMASTLOCK      = 1'b0; 
            HPROT          = 4'b0000;  
            HSIZE          = 3'b000;  
            HTRANS         = 2'b00;

            HWDATA         = {24'h0000_00,8'h55}; // For Debug ; no impact
            HWRITE         = 1'b0;
            s_DataFromUart = s_DataFromUart;
            s_ByteCounterR  = s_ByteCounterR;
            t_ReadAccess   = StCapture;

          StCapture: 
          begin // capture the data
            HADDR                = 32'h00000000; 
            HBURST               = 3'b000;
            HMASTLOCK            = 1'b0; 
            HPROT                = 4'b0000;  
            HSIZE                = 3'b000;  
            HTRANS               = 2'b00;
        
            HWDATA               = {24'h0000_00,8'h55}; // For Debug ; no impact
            HWRITE               = 1'b0;
            s_DataFromUart[31:8] = s_DataFromUart[24:0];
            s_DataFromUart[7:0]  = HRDATA[7:0];
            if (s_ByteCounterR = C_ByteByWord)
              begin
                s_ByteCounterR = 0;
                t_ReadAccess         = StExecute;
              end
            else
              begin
                s_ByteCounterR = s_ByteCounterR + 1;
                t_ReadAccess  = StIdle;
              end


          end

          StExecute:
            if (t_ExecuteAccess == StIdle) // Possible to get a new data
              begin
                t_ReadAccess  = StIdle;
              end
            else 
              begin // Bus is busy
                t_ReadAccess  = StExecute;
              end
            

          default:
          ;
          
        endcase 
      end 
  end    


/*

61 - 'a'
41 - 'A'
0D - CR
0A - LF

*/


// ===========================================================================
// == Process - Manage / Command - Load / Get - Read / Init - Start
// =========================================================================== 
// Word organization
// -----------------
// |Order|Module|Parameter1|Parameter2|
// 1) Order
// Command (C) - 0x43
// Load (L) - 0x4C
// Read (R) - 0x52
// Init (I) - 0x49
// Start (S) - 0x53
//
// 2) Module
// Timer - 0x01
// Loopback - 0x02
// 



always_ff @(posedge HCLK iff HRESETn or negedge HRESETn)
  begin
   if (!HRESETn)
      begin       
        t_ExecuteAccess   = StIdle;
        s_ByteCounterR  = 0;
      end
    else
      begin
        case(t_ExecuteAccess)          
          StIdle:
          begin 
            if(t_ReadAccess = StExecute) // launch start
              begin 
                if (s_DataFromUart[31:24] ==  2'h43 & HREADY = 1'b1) // Write access
                  begin
                    HADDR          = {24'h0000_00,s_DataFromUart[23:16]};
                    HBURST         = 3'b000;
                    HMASTLOCK      = 1'b0; 
                    HPROT          = 4'b0000;  
                    HSIZE          = 3'b000;  
                    HTRANS         = 2'b10;         
                    HWDATA         = {16'h0000,s_DataFromUart[15:0]};
                    HWRITE         = 1'b1;                     
                    t_ExecuteAccess = StIdle
                  end
                else if (s_DataFromUart[31:24] ==  2'h52) // Read access
                  begin
                    HADDR          = {24'h0000_00,s_DataFromUart[23:16]};
                    HBURST         = 3'b000;
                    HMASTLOCK      = 1'b0; 
                    HPROT          = 4'b0000;  
                    HSIZE          = 3'b000;  
                    HTRANS         = 2'b10;         
                    HWDATA         = {16'h0000,s_DataFromUart[15:0]};
                    HWRITE         = 1'b0;                     
                    t_ExecuteAccess = StWait
                  end
                else 
                  begin
                    HADDR          = 32'h00000000; 
                    HBURST         = 3'b000;
                    HMASTLOCK      = 1'b0; 
                    HPROT          = 4'b0000;  
                    HSIZE          = 3'b000;  
                    HTRANS         = 2'b00;
                 
                    HWDATA         = {24'h0000_00,8'h55}; // For Debug ; no impact
                    HWRITE         = 1'b0;                   
                    t_ExecuteAccess = StIdle
                  end 
              end
            else                                                 
              begin
                HADDR           = 32'h00000000; 
                HBURST          = 3'b000;
                HMASTLOCK       = 1'b0; 
                HPROT           = 4'b0000;  
                HSIZE           = 3'b000;  
                HTRANS          = 2'b00;
 
                HWDATA          = {24'h0000_00,8'h55}; // For Debug ; no impact
                HWRITE          = 1'b0;
                t_ExecuteAccess = StIdle
              end
          end


          StWait: 
          begin // Wait a cycle and close transaction
            HADDR           = 32'h00000000; 
            HBURST          = 3'b000;
            HMASTLOCK       = 1'b0; 
            HPROT           = 4'b0000;  
            HSIZE           = 3'b000;  
            HTRANS          = 2'b00;
 
            HWDATA          = {24'h0000_00,8'h55}; // For Debug ; no impact
            HWRITE          = 1'b0;
            t_ExecuteAccess = StCapture;


          StCapture: 
          begin // capture the data
            s_DataFromModule = HRDATA;
            t_ReadAccess     = StIdle;
          end      


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
          default:
          ;
          
        endcase 
      end            
  end



// ===========================================================================
// == Assignment
// =========================================================================== 
// Transfert Response
  assign HREADYOUT = !s_FifoTxFull & s_FifoRxEmpty;   //If Read and FIFO_RX is empty - wait.
                          // TODO manage error on response

// Address controle
// [2:0] HSIZE     // Byte - Halfword - Word - Doublewordread           ; read = Byte 
// [1:0] HADDR     //  00 - 01 - 10 - 11                                ; use of LSB only
// [2:0] HBURST    // SINGLE - INCR - WRAP[4|8|16] - INCR[4|8|16]       ; Single
// [3:0] HPROT     // Cacheable - Bufferable - Privileged - Data/Opcode ; read = 0000 Write 0001
// [1:0] HTRANS    // IDLE - BUSY - NON-SEQ - SEQ                       ; Only IDLE or NON-SEQ 
//       HMASTLOCK //UNLOCKED - LoCKED                                  ; is always 1’b0 (UNLOCKED)

//  assign HRESP = 1'b0; // Low = Okay, high = error 
  assign HRESP = HSIZE[0] | HSIZE[1] | HSIZE[2] | !HADDR[0] | !HADDR[1] | HBURST[0] | HBURST[1] | HBURST[2] | HPROT[1] | HPROT[2] | HPROT[3] | HTRANS[0] | HMASTLOCK;
      


// Data
  assign s_AhbToFifoTxWData = HWDATA[7:0];   //Only write last 8 bits of Data 
  assign HRDATA = {24'h0000_00,s_FifoRxToAhbRData}; //Assign UART output to AHB RDATA  // {>>xx{}}

// Rout the interrupt - If Fifo Rx dispose of data  
  assign o_UartIrq = !s_FifoRxEmpty;


// ===========================================================================
// == Component instantiation
// =========================================================================== 


   
 
endmodule 

