// ******************
// File: Uari_UartRx.sv
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

 
module UartRx#(  
    parameter C_BaudRate     = 434, // 434 = 50Mhz/ 115200
    parameter C_MiddleRate   = 217, // 217 = 434/ 2
    parameter C_BitByByte    = 8
)
( 
  input logic        i_Clk, 
  input logic        i_ResetN, 
  input logic        i_UartRx,        // Input data from RS-232
  output logic       o_Done,          // Transfer finished 
  output logic [7:0] o_Data           // Output data 
  ); 

// ===========================================================================
// == Constant declaration
// ===========================================================================
  timeunit 1ns;
  timeprecision 1ns;

// ===========================================================================
// == Type declaration
// ===========================================================================
  typedef enum{StIdle,StStart,StShiftRegister,StStop} state_t;
  state_t t_CurrentState;

// ===========================================================================
// == Signals declaration
// =========================================================================== 
//  logic  [9:0]s_DataCounter;
//  logic  [3:0]s_Countbyte;
  shortint s_DataCounter;
  shortint s_Countbyte;  
  //logic [7:0] s_DataReg;



// ===========================================================================
// == Process - State Machine
// ===========================================================================    
// RS232 Dataflow : 1'b1 & Data & 1'b0; // 0= start, Data, , 1 parity (option), 1 = stop 
//State Machine   
  always_ff @ (posedge i_Clk or negedge i_ResetN) //always_ff @ (posedge i_Clk iff i_ResetN or negedge i_ResetN) 
  begin 
    if(!i_ResetN) 
      begin 
        s_DataCounter = C_BaudRate; 
        s_Countbyte = C_BitByByte-1;
       // s_DataReg = 8'b00000000;
        o_Data = 8'b00000000;
        o_Done = 1'b0; 
        t_CurrentState = StIdle;
      end 
    else 
      begin 
        case(t_CurrentState) 

          StIdle:
          begin 
            if(i_UartRx )//& s_DataCounter == 0) // idle mode 
              begin 
                s_DataCounter = C_BaudRate; 
                s_Countbyte = C_BitByByte-1;
                o_Data = 8'b00000000;
                o_Done = 1'b0; 
                t_CurrentState = StIdle; 
              end 
            else if(!i_UartRx & s_DataCounter == C_BaudRate) // start -> wait middle of the bit
              begin 
                s_DataCounter = s_DataCounter - 1; 
                s_Countbyte = C_BitByByte-1;
                o_Data = 8'b00000000;
                o_Done = 1'b0; 
                t_CurrentState = StIdle; 
              end 
            else if ( s_DataCounter > (C_MiddleRate)) // wait middle of the start bit
              begin
                s_DataCounter = s_DataCounter - 1; 
                s_Countbyte = C_BitByByte-1;
                o_Data = 8'b00000000;
                o_Done = 1'b0; 
                t_CurrentState = StIdle; 
              end
            else                                                  // launch start
              begin
                s_DataCounter = C_BaudRate; 
                s_Countbyte = C_BitByByte-1;
                o_Data = 8'b00000000;
                o_Done = 1'b0; 
                t_CurrentState = StStart; 
              end
          end
 
          StStart: 
          begin
            if(s_DataCounter == 0)                     // wait middle  of the first data bit
              begin 
                s_DataCounter = C_BaudRate; 
                s_Countbyte = C_BitByByte-1;
                o_Data = 8'b00000000;
                o_Done = 1'b0; 
                t_CurrentState = StShiftRegister;
              end
            else                                                // data bits
              begin
                s_DataCounter = s_DataCounter - 1; 
                s_Countbyte = C_BitByByte-1;
                o_Data = 8'b00000000;
                o_Done = 1'b0; 
                t_CurrentState = StStart;                   
              end
          end 


          StShiftRegister: 
          begin
            if(s_DataCounter == 0)                     
              begin 
                if(s_Countbyte == 0)
                  begin
                    s_DataCounter = C_BaudRate; 
                    //s_Countbyte = C_BitByByte-1;
                    //o_Data[s_Countbyte] = i_UartRx; 
                    o_Done = 1'b0;        //-----------------
                    t_CurrentState = StStop; 
                  end 
                else
                  begin
                    s_DataCounter = C_BaudRate; 
                    s_Countbyte = s_Countbyte - 1;
                    o_Data[s_Countbyte] = i_UartRx;
                    o_Done = 1'b0;        //-----------------
                    t_CurrentState = StShiftRegister;                     
                  end
              end 
            else if (s_DataCounter == C_BaudRate)
              begin
                s_DataCounter = s_DataCounter - 1; 
                //s_Countbyte = C_BitByByte-1;
                o_Data[s_Countbyte] = i_UartRx;
                if(s_Countbyte == 0)
                  begin
                    o_Done = 1'b1;
                  end
                else
                  begin
                    o_Done = 1'b0;
                  end        
                t_CurrentState = StShiftRegister; 
              end
            else
              begin
                s_DataCounter = s_DataCounter - 1; 
                //s_Countbyte = C_BitByByte-1;
                //o_Data = 1'b00000000; //-----------------
                o_Done = 1'b0;        //-----------------
                t_CurrentState = StShiftRegister;                 
              end
          end
                  
          StStop: 
          begin
            s_DataCounter = C_BaudRate; 
            //s_Countbyte = C_BitByByte-1;
            o_Data = 8'b00000000; //-----------------
            o_Done = 1'b0;        
            t_CurrentState = StIdle; 
          end

          default:
          ;
          
        endcase 
      end 
  end      
endmodule 
