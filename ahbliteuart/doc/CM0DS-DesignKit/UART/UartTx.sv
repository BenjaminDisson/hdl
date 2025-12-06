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

 
module UarTx( 
  input logic       i_Clk, 
  input logic       i_ResetN, 
  input logic       i_StartSending,  // Flag indicating data available   
  input logic       i_BaudRateClock, // Baud rate clock 
  input logic [7:0] i_Data,          // Input data 
  output logic      o_Done,          // Transfer finished 
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
  logic       s_DataCounter;


// ===========================================================================
// == Process - State Machine
// =========================================================================== 
// RS232 Dataflow : 1'b1 & i_Data & 1'b0; // 0= start, Data, , 1 parity (option), 1 = stop 
  always_ff @(posedge i_Clk iff i_ResetN or negedge i_ResetN) 
  begin 
    if(!i_ResetN) 
      begin          
        s_DataCounter = 0; 
        o_UartTx = 1'b1;
        o_Done = 1'b0; 
        t_CurrentState = StIdle;
      end 
    else 
      begin 
        case(t_CurrentState) 
          StIdle: 
          begin 
            if(i_StartSending) 
              begin 
                s_DataCounter = 0; 
                o_UartTx = 1'b0;
                o_Done = 1'b0;
                t_CurrentState = StShiftRegister;  
              end
            else
              begin
                s_DataCounter = 0; 
                o_UartTx = 1'b1;
                o_Done = 1'b0;                
                t_CurrentState = StIdle;
              end 
          end 
           
          StShiftRegister: //send start bit 
          begin 
            if(i_BaudRateClock)
              begin
                if(s_DataCounter == 7)    //8 data bits 
                  begin
                    s_DataCounter = 0;
                    o_UartTx = 1'b0;
                    o_Done = 1'b0;
                    t_CurrentState = StStop; 
                  end
                else 
                  begin
                    s_DataCounter = s_DataCounter + 1;
                    o_UartTx = i_Data[s_DataCounter];
                    o_Done = 1'b0;
                    t_CurrentState = StShiftRegister;  
                  end              
              end
          end

          StStop: //send stop bit 
          begin 
            if(i_BaudRateClock)
              begin
                s_DataCounter = 0;
                o_UartTx = 1'b1;
                o_Done = 1'b1;
                t_CurrentState = StIdle;
              end
          end          
        endcase 
      end 
  end  
endmodule 
