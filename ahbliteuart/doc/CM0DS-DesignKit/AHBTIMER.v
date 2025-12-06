<html><head><meta charset="GB2312"><title>CM0DS-DesignKit.zip AHBTIMER.v</title>
<LINK href="/inc/read_style.css" type=text/css rel=stylesheet></head>
<body>
<p><a href=http://www.pudn.com>www.pudn.com</a> &gt; <a href="http://www.pudn.com/Download/item/id/2490414.html">CM0DS-DesignKit.zip</a> &gt AHBTIMER.v, change:2012-05-14,size:7018b</p><!-- saved from http://www.pudn.com -->
<script src="/inc/gg_read1.js"></script><BR>
<pre name="code" class="v">
////////////////////////////////////////////////////////////////////////////////// 
//END USER LICENCE AGREEMENT                                                    // 
//                                                                              // 
//Copyright (c) 2012, ARM All rights reserved.                                  // 
//                                                                              // 
//THIS END USER LICENCE AGREEMENT (揕ICENCE�) IS A LEGAL AGREEMENT BETWEEN      // 
//YOU AND ARM LIMITED ("ARM") FOR THE USE OF THE SOFTWARE EXAMPLE ACCOMPANYING  // 
//THIS LICENCE. ARM IS ONLY WILLING TO LICENSE THE SOFTWARE EXAMPLE TO YOU ON   // 
//CONDITION THAT YOU ACCEPT ALL OF THE TERMS IN THIS LICENCE. BY INSTALLING OR  // 
//OTHERWISE USING OR COPYING THE SOFTWARE EXAMPLE YOU INDICATE THAT YOU AGREE   // 
//TO BE BOUND BY ALL OF THE TERMS OF THIS LICENCE. IF YOU DO NOT AGREE TO THE   // 
//TERMS OF THIS LICENCE, ARM IS UNWILLING TO LICENSE THE SOFTWARE EXAMPLE TO    // 
//YOU AND YOU MAY NOT INSTALL, USE OR COPY THE SOFTWARE EXAMPLE.                // 
//                                                                              // 
//ARM hereby grants to you, subject to the terms and conditions of this Licence,// 
//a non-exclusive, worldwide, non-transferable, copyright licence only to       // 
//redistribute and use in source and binary forms, with or without modification,// 
//for academic purposes provided the following conditions are met:              // 
//a) Redistributions of source code must retain the above copyright notice, this// 
//list of conditions and the following disclaimer.                              // 
//b) Redistributions in binary form must reproduce the above copyright notice,  // 
//this list of conditions and the following disclaimer in the documentation     // 
//and/or other materials provided with the distribution.                        // 
//                                                                              // 
//THIS SOFTWARE EXAMPLE IS PROVIDED BY THE COPYRIGHT HOLDER "AS IS" AND ARM     // 
//EXPRESSLY DISCLAIMS ANY AND ALL WARRANTIES, EXPRESS OR IMPLIED, INCLUDING     // 
//WITHOUT LIMITATION WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR // 
//PURPOSE, WITH RESPECT TO THIS SOFTWARE EXAMPLE. IN NO EVENT SHALL ARM BE LIABLE/ 
//FOR ANY DIRECT, INDIRECT, INCIDENTAL, PUNITIVE, OR CONSEQUENTIAL DAMAGES OF ANY/ 
//KIND WHATSOEVER WITH RESPECT TO THE SOFTWARE EXAMPLE. ARM SHALL NOT BE LIABLE // 
//FOR ANY CLAIMS, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, // 
//TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE    // 
//EXAMPLE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE EXAMPLE. FOR THE AVOIDANCE/ 
// OF DOUBT, NO PATENT LICENSES ARE BEING LICENSED UNDER THIS LICENSE AGREEMENT.// 
////////////////////////////////////////////////////////////////////////////////// 
 
 
module AHBTIMER( 
	//Inputs 
	input wire HCLK, 
	input wire HRESETn, 
  input wire [31:0] HADDR, 
  input wire [31:0] HWDATA, 
  input wire [1:0] HTRANS, 
  input wire HWRITE, 
  input wire HSEL, 
  input wire HREADY, 
   
	//Output 
  output wire [31:0] HRDATA, 
	output wire HREADYOUT, 
  output reg timer_irq 
); 
 
  localparam [3:0] LDADDR = 4'h0;   //load register address 
  localparam [3:0] VALADDR = 4'h4;  //value register address 
  localparam [3:0] CTLADDR = 4'h8;  //control register address 
  localparam [3:0] CLRADDR = 4'hC;  //clear register address 
   
  localparam st_idle = 1'b0; 
  localparam st_count = 1'b1; 
   
  reg current_state; 
  reg next_state; 
   
  reg [31:0] value_next; 
  reg timer_irq_next; 
   
  //AHB Registers 
  reg last_HWRITE; 
  reg [31:0] last_HADDR; 
  reg last_HSEL; 
  reg [1:0] last_HTRANS; 
 
  //internal registers 
  reg [3:0] control; 
  reg [31:0] load; 
  reg clear; 
  reg [31:0] value; 
   
  wire enable; 
  wire mode; 
 
  //Prescaled clk signals 
  wire clk16;       // HCLK/16 
  wire clk256;      // HCLK/256 
  wire timerclk; 
 
  //Generate prescaled clk ticks 
  prescaler uprescaler16( 
    .inclk(HCLK), 
    .outclk(clk16) 
  ); 
 
  prescaler uprescaler256( 
    .inclk(clk16), 
    .outclk(clk256) 
  ); 
   
  assign HREADYOUT = 1'b1; //Always ready 
 
  always @(posedge HCLK) 
    if(HREADY) 
      begin 
        last_HWRITE &lt;= HWRITE; 
        last_HSEL &lt;= HSEL; 
        last_HADDR &lt;= HADDR; 
        last_HTRANS &lt;= HTRANS; 
      end 
 
  //Prescale clk based on control[3:2] 1x= 256 ; 01 = 16 ; 00 = 1; 
  assign timerclk = (control[3]) ? clk256 : 
                      ((control[2]) ? clk16 : 1'b1);  //1'b1 signifies HCLK 
                       
  assign enable = control[0]; 
  assign mode = control[1]; 
                       
 
  //Control signal 
  always @(posedge HCLK, negedge HRESETn) 
    if(!HRESETn) 
      control &lt;= 4'b0000; 
    else if(last_HWRITE & last_HSEL & last_HTRANS[1]) 
      if(last_HADDR[3:0] == CTLADDR) 
        control &lt;= HWDATA[3:0]; 
         
         
  //Load signal 
  always @(posedge HCLK, negedge HRESETn) 
    if(!HRESETn) 
      load &lt;= 32'h0000_0000; 
    else if(last_HWRITE & last_HSEL & last_HTRANS[1]) 
      if(last_HADDR[3:0] == LDADDR) 
        load &lt;= HWDATA; 
   
   //Clear signal       
  always @(posedge HCLK, negedge HRESETn) 
    if(!HRESETn) 
      clear &lt;= 1'b0; 
    else if(last_HWRITE & last_HSEL & last_HTRANS[1]) 
      if(last_HADDR[3:0] == CLRADDR) 
        clear &lt;= HWDATA[0]; 
 
   
  always @(posedge HCLK, negedge HRESETn) 
    if(!HRESETn) 
      timer_irq &lt;= 1'b0; 
    else 
      timer_irq &lt;= timer_irq_next; 
            
  //State Machine     
  always @(posedge HCLK, negedge HRESETn) 
    if(!HRESETn) 
      begin 
        current_state &lt;= st_idle; 
        value &lt;= 32'h0000_0000; 
      end 
    else 
      begin 
        value &lt;= value_next; 
        current_state &lt;= next_state; 
      end 
   
  //Timer Operation and Next State logic 
  always @* 
  begin 
    next_state = current_state; 
    value_next = value; 
    timer_irq_next = (clear) ? 0 : timer_irq; 
    case(current_state) 
      st_idle: 
        if(enable && timerclk) 
            begin 
              value_next = load; 
              next_state = st_count; 
            end 
      st_count: 
        if(enable && timerclk)      //if disabled timer stops 
            if(value == 32'h0000_0000) 
              begin 
                timer_irq_next = 1; 
                if(mode == 0)           //If mode=0 timer is free-running counter 
                  value_next = value-1; 
                else if(mode == 1)      //If mode=1 timer is periodic counter; 
                  value_next = load; 
              end 
            else 
              value_next = value-1; 
    endcase 
  end 
   
   
  assign HRDATA = (last_HADDR[3:0] == LDADDR) ? load : 
                  (last_HADDR[3:0] == VALADDR) ? value : 
                  (last_HADDR[3:0] == CTLADDR) ? control : 
                   32'h0000_0000; 
             
 
 
endmodule 
</pre>
<script src="/inc/gg_read2.js"></script><BR>
</body></html>
