// ******************
// File: UarTx.sv
// Description : Generate RS232 dataflow
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

 
module UartTx#(  
    parameter C_BaudRate     = 434 // 434 = 50Mhz/ 115200
)( 
  input logic       i_Clk, 
  input logic       i_ResetN, 
  input logic       i_StartSending,  // Flag indicating data available   
  input logic [7:0] i_Data,          // Input data 
  output logic      o_RequestData,          // Transfer finished 
  output logic      o_UartTx         // Output data to RS-232 
  ); 

// ===========================================================================
// == Constant declaration
// ===========================================================================
  timeunit 1ns;
  timeprecision 1ns;

// ===========================================================================
// == Type declaration
// ===========================================================================
  typedef enum{StIdle,StShiftRegister,StStop} state_t;
  state_t t_CurrentState;
// ===========================================================================
// == Signals declaration
// ===========================================================================
  shortint    s_DataCounter;
  logic       s_Done;

  // Baudrate generator
  logic [11:0] s_CountBaudRate; 




  assign o_RequestData = s_Done & i_StartSending; // i_StartSending = !empty -> for reliability



// ===========================================================================
// == Process - RS232 clock generator
// ===========================================================================  
//  always_ff @(posedge HCLK iff HRESETn or negedge HRESETn)
//  begin
//    if (!HRESETn)
//      begin
//        s_CountBaudRate = 0;
//        s_BaudRateClock = 1'b0;
//
//      end
//    else
//      begin
//          s_CountBaudRate = ((s_CountBaudRate == C_BaudRate) ? 0 : s_CountBaudRate + 1'b1);         
//          s_BaudRateClock = ((s_CountBaudRate == C_BaudRate) ? 1'b1 : 1'b0); 
//      end
//  end

// ===========================================================================
// == Process - State Machine
// =========================================================================== 
// RS232 Dataflow : 1'b1 & i_Data & 1'b0; // 0= start, Data, , 1 parity (option), 1 = stop 
  always_ff @ (posedge i_Clk or negedge i_ResetN) //always_ff @ (posedge i_Clk iff i_ResetN or negedge i_ResetN) 
  begin 
    if(!i_ResetN) 
      begin          
        s_CountBaudRate = 0;
        s_DataCounter = 0; 
        o_UartTx = 1'b1;
        s_Done = 1'b1; 
        t_CurrentState = StIdle;
      end 
    else 
      begin 
        case(t_CurrentState) 
          StIdle: 
          begin 
            if(!i_StartSending & s_CountBaudRate == 0) 
              begin 
                s_CountBaudRate = 0;
                s_DataCounter = 0; 
                o_UartTx = 1'b1;
                s_Done = 1'b0;                
                t_CurrentState = StIdle;
              end
            else if (i_StartSending & s_CountBaudRate == 0) // Run the start bit
              begin
                s_CountBaudRate = s_CountBaudRate + 1'b1;
                s_DataCounter = 0; 
                o_UartTx = 1'b0;
                s_Done = 1'b1;
                t_CurrentState = StIdle;  
              end 
            else if (s_CountBaudRate > 0 & s_CountBaudRate < C_BaudRate)  // continu the start bit 
              begin
                s_CountBaudRate = s_CountBaudRate + 1'b1;
                s_DataCounter = 0; 
                o_UartTx = 1'b0;
                s_Done = 1'b0;
                t_CurrentState = StIdle;  
              end 
            else if (s_CountBaudRate == C_BaudRate)  // Go through Data shift register
              begin
                s_CountBaudRate =  0;
                s_DataCounter = 0; 
                o_UartTx = i_Data[7-s_DataCounter];
                s_Done = 1'b0;
                t_CurrentState = StShiftRegister;  
              end 
          end 
           
          StShiftRegister: //send data bit 
          begin 
            if(s_CountBaudRate == C_BaudRate)
              begin
                if(s_DataCounter == 7)    //Go through stop bit
                  begin
                    s_CountBaudRate =  0;
                    s_DataCounter = 0;
                    o_UartTx = 1'b1;
                    s_Done = 1'b0;
                    t_CurrentState = StStop; 
                  end
                else if (s_DataCounter < 7) // Send on of the eight data bits
                  begin
                    s_CountBaudRate =  0;
                    s_DataCounter = s_DataCounter + 1;
                    o_UartTx = i_Data[7-s_DataCounter];
                    s_Done = 1'b0;
                    t_CurrentState = StShiftRegister;  
                  end              
              end
            else                          // increment to get the correct baudrate
              begin
                s_CountBaudRate =  s_CountBaudRate + 1'b1;
                s_DataCounter = s_DataCounter;
                o_UartTx = i_Data[7-s_DataCounter];
                s_Done = 1'b0;
                t_CurrentState = StShiftRegister; 
              end
          end

          StStop: //send stop bit 
          begin 
            if(s_CountBaudRate >= C_BaudRate)
              begin
                s_CountBaudRate = 0;
                s_DataCounter = 0;
                o_UartTx = 1'b1;
                s_Done = 1'b0;
                t_CurrentState = StIdle;
              end
            else if(s_CountBaudRate < C_BaudRate)
              begin
                s_CountBaudRate = s_CountBaudRate + 1'b1;
                s_DataCounter = 0;
                o_UartTx = 1'b1;
                s_Done = 1'b0;
                t_CurrentState = StStop;
              end              
          end          
        endcase 
      end 
  end  
endmodule 
