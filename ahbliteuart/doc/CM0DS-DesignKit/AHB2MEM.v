<html><head><meta charset="GB2312"><title>CM0DS-DesignKit.zip AHB2MEM.v</title>
<LINK href="/inc/read_style.css" type=text/css rel=stylesheet></head>
<body>
<p><a href=http://www.pudn.com>www.pudn.com</a> &gt; <a href="http://www.pudn.com/Download/item/id/2490414.html">CM0DS-DesignKit.zip</a> &gt AHB2MEM.v, change:2012-05-14,size:4240b</p><!-- saved from http://www.pudn.com -->
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
 
 
module AHB2MEM( 
	//AHBLITE INTERFACE 
		//Slave Select Signals 
			input wire HSEL, 
		//Global Signal 
			input wire HCLK, 
			input wire HRESETn, 
		//Address, Control & Write Data 
			input wire HREADY, 
			input wire [31:0] HADDR, 
			input wire [1:0] HTRANS, 
			input wire HWRITE, 
			input wire [2:0] HSIZE, 
			 
			input wire [31:0] HWDATA, 
		// Transfer Response & Read Data 
			output wire HREADYOUT, 
			output wire [31:0] HRDATA, 
	 
	//LED Output 
			output reg [7:0] LED 
); 
 
 
  assign HREADYOUT = 1'b1; // Always ready 
 
  reg APhase_HSEL; 
  reg APhase_HWRITE; 
  reg [1:0] APhase_HTRANS; 
  reg [31:0] APhase_HADDR; 
   
  reg [31:0] memory[0:1023]; 
  
  always @(posedge HCLK or negedge HRESETn) 
  begin 
	 if(!HRESETn) 
	 begin 
		APhase_HSEL &lt;= 1'b0; 
      APhase_HWRITE &lt;= 1'b0; 
      APhase_HTRANS &lt;= 2'b00; 
		APhase_HADDR &lt;= 32'h0; 
	 end 
    else if(HREADY) 
    begin 
      APhase_HSEL &lt;= HSEL; 
      APhase_HWRITE &lt;= HWRITE; 
      APhase_HTRANS &lt;= HTRANS; 
		APhase_HADDR &lt;= HADDR; 
    end 
  end 
 
  always @(posedge HCLK) 
  begin 
	 if(APhase_HSEL & APhase_HWRITE & APhase_HTRANS[1]) 
		memory[APhase_HADDR[12:2]] &lt;= HWDATA; 
  end 
  
  assign HRDATA = memory[APhase_HADDR[12:2]]; 
 
  assign LED = memory[APhase_HADDR[12:2]][7:0]; 
   
endmodule 
</pre>
<script src="/inc/gg_read2.js"></script><BR>
</body></html>
