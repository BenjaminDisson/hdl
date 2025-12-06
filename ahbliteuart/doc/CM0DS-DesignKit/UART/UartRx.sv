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

 
module UarTx#(  
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
  typedef enum{StIdle,StShiftRegister,StStop} state_t;
  state_t t_CurrentState;

// ===========================================================================
// == Signals declaration
// =========================================================================== 
  logic       s_DataCounter;
  logic       s_Countbyte;
  //logic [7:0] s_DataReg;



// ===========================================================================
// == Process - State Machine
// ===========================================================================    
//State Machine   
  always_ff @ (posedge i_Clk iff i_ResetN or negedge i_ResetN) 
  begin 
    if(!i_ResetN) 
      begin 
        s_DataCounter = 0; 
        s_Countbyte = 0;
       // s_DataReg = 8'b00000000;
        o_Data = 8'b00000000;
        o_Done = 1'b0; 
        t_CurrentState = StIdle;
      end 
    else 
      begin 
        case(t_CurrentState) 
          StIdle: 
            if(i_UartRx && s_DataCounter == 0) 
              begin 
                s_DataCounter = 0; 
                s_Countbyte = 0;
                o_Data = 8'b00000000;
                o_Done = 1'b0; 
                t_CurrentState = StIdle; 
              end 
            else if(~i_UartRx && s_DataCounter == 0) 
              begin 
                s_DataCounter = s_DataCounter + 1; 
                s_Countbyte = 0;
                o_Data = 8'b00000000;
                o_Done = 1'b0; 
                t_CurrentState = StIdle; 
              end 
            else if (s_DataCounter > 0 && s_DataCounter < C_MiddleRate) 
              begin
                s_DataCounter = s_DataCounter + 1; 
                s_Countbyte = 0;
                o_Data = 8'b00000000;
                o_Done = 1'b0; 
                t_CurrentState = StIdle; 
              end
            else
              begin
                s_DataCounter = 0; 
                s_Countbyte = 0;
                o_Data = 8'b00000000;
                o_Done = 1'b0; 
                t_CurrentState = StShiftRegister; 
              end
               
          StShiftRegister: 
            if(s_DataCounter == C_BaudRate) 
              begin 
                if(s_Countbyte == C_BitByByte-1)
                  begin
                    s_DataCounter = 0; 
                    s_Countbyte = 0;
                    o_Data[s_Countbyte] = i_UartRx; 
                    o_Done = 1'b0;        //-----------------
                    t_CurrentState = StStop; 
                  end
                else
                  begin
                    s_DataCounter = 0; 
                    s_Countbyte = s_Countbyte + 1;
                    o_Data[s_Countbyte] = i_UartRx;
                    o_Done = 1'b0;        //-----------------
                    t_CurrentState = StShiftRegister;                     
                  end
              end 
            else
              begin
                s_DataCounter = s_DataCounter + 1; 
                //s_Countbyte = 0;
                //o_Data = 1'b00000000; //-----------------
                //o_Done = 1'b0;        //-----------------
                t_CurrentState = StShiftRegister;                 
              end
                  
          StStop: 
            //s_DataCounter = s_DataCounter + 1; 
            //s_Countbyte = 0;
            //o_Data = 1'b00000000; //-----------------
            o_Done = 1'b1;        
            t_CurrentState = StIdle; 
        endcase 
      end 
  end      
endmodule 
