// ******************
// File: AHBLite.sv
// Description : Manage the AHBLite communication system
// Modification
// ----------------------------------------------------------
//     Date      Ver.         Author       Comments
// ----------------------------------------------------------
// 2020/09/16 :  1.0  : Benjamin Disson : First building
//
//
//
//
//

 
module AHBLite#(  
    parameter C_SlaveNumber= 2
)
(
	//input  logic		i_Clk, 
	//input  logic		i_ResetN,   
	
    // Master to Slave
    input  logic 		HCLK, 
    input  logic 		HRESETn,  
    input  logic [31:0]	HADDR,  
    output logic        HSEL01, 
    output logic        HSEL02,
      
    //Slave To Master
    input  logic  [31:0]HRDATA01,  
    input  logic 		HRESP01,  
    input  logic 		HREADYOUT01, 
    
    input  logic  [31:0]HRDATA02,  
    input  logic 		HRESP02,  
    input  logic 		HREADYOUT02,
      
     
    output logic  [31:0]HRDATA,  
    output logic 		HRESP,  
    output logic 		HREADY	
  
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
  // Adress Decoder
  logic	      s_HSELOthers; // addres error (lead to irq)
  logic [1:0] s_Hsel; 
  logic [C_SlaveNumber-1:0] 		s_MuxSel;
  logic [C_SlaveNumber-1:0] 		s_MuxSel_r;  // to synchronize response et Rdata into data phases
 

 
/*    
//SYSTEM GENERATES NO ERROR RESPONSE  
assign 			HRESP = 1'b0;  
  
//CM0-DS INTERRUPT SIGNALS    
assign 			IRQ = {15'b0000_0000_0000_000,UART_IRQ};  
assign 			LED[7] = LOCKUP;  
  
//CLOCK DIVIDER & RESET  
reg 	rCLK; 
always @(posedge CLK) 
		rCLK = ~rCLK;  
assign 			HCLK = i_Clk;  
assign 			HRESETn = i_ResetN;  
*/                   
  

  
assign HSEL01 = s_Hsel[0];
assign HSEL02 = s_Hsel[1];
assign s_HSELOthers = s_Hsel[0] | s_Hsel[1] ;
assign s_MuxSel = {s_Hsel[1],s_Hsel[0]};
	 
// ===========================================================================
// == Process - Adress decoder
// =========================================================================== 
always_comb
begin  
  
  case(HADDR[31:0]) 
    32'h00000003: 	
      begin  
        s_Hsel = 2'b01;  
      end  
    32'h00000004: 						  
      begin  
        s_Hsel = 2'b10;    
      end  
    default:  
      begin   
        s_Hsel = 2'b00; 
      end  
  endcase  
end    



 
// ===========================================================================
// == Process - 1 clock register
// =========================================================================== 
// To synchronize response et Rdata into data phases
  always_ff @ (posedge HCLK or negedge HRESETn)  
  begin  
    if(!HRESETn)
	  begin	
        s_MuxSel_r = 2'b00; 
      end		
    else if(HREADY)						// NOTE: ALL THE CONTROL SIGNALS ARE VALID ONLY IF HREADY = 1'b1
      begin	
        s_MuxSel_r = s_MuxSel;  
		//s_MuxSel_r = s_Hsel;
	  end
  end 

  
// ===========================================================================
// == Process - Response multi-plexer
// =========================================================================== 
  always_comb
  begin  
    case(s_MuxSel_r)  
      3'b01: begin						
        HRDATA = HRDATA01;  
        HREADY = HREADYOUT01;  
		HRESP  = HRESP01;
      end  
      2'b10: begin  
        HRDATA = HRDATA02;  
        HREADY = HREADYOUT02; 
		HRESP  = HRESP02;	
      end  

      default: begin              
        HRDATA = 32'hDEADBEEF;
        HREADY = 1'b1;
		HRESP  = 1'b0;
      end  
    endcase  
      
  end    
  

  

endmodule 

