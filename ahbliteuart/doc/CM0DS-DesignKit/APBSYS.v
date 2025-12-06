<html><head><meta charset="GB2312"><title>CM0DS-DesignKit.zip APBSYS.v</title>
<LINK href="/inc/read_style.css" type=text/css rel=stylesheet></head>
<body>
<p><a href=http://www.pudn.com>www.pudn.com</a> &gt; <a href="http://www.pudn.com/Download/item/id/2490414.html">CM0DS-DesignKit.zip</a> &gt APBSYS.v, change:2012-05-14,size:4588b</p><!-- saved from http://www.pudn.com -->
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
 
 
module APBSYS( 
// Global signals -------------------------------------------------------------- 
  input wire          HCLK, 
  input wire          HRESETn, 
   
// AHB Slave inputs ------------------------------------------------------------   
  input wire  [31:0]  HADDR, 
  input wire  [1:0]   HTRANS, 
  input wire          HWRITE, 
  input wire  [31:0]  HWDATA, 
  input wire          HSEL, 
  input wire          HREADY, 
   
   
// AHB Slave outputs ----------------------------------------------------------- 
  output wire [31:0]  HRDATA, 
  output wire         HREADYOUT 
   
    ); 
 
 // APB Master Signals 
  wire PCLK; 
  wire PRESETn; 
  wire [31:0] PADDR; 
  wire PWRITE; 
  wire [31:0] PWDATA; 
  wire PENABLE; 
 
  //APB Select Signals 
  wire PSEL_DUMMY1; 
 
  // APB Slave Signals 
  wire PREADY; 
  wire [31:0] PRDATA; 
   
   
   AHB2APB uAHB2APB ( 
    .HCLK(HCLK),  
    .HRESETn(HRESETn),  
    .HADDR(HADDR[31:0]),  
    .HSEL(HSEL), 
    .HREADY(HREADY), 
    .HTRANS(HTRANS[1:0]),  
    .HWDATA(HWDATA[31:0]),  
    .HWRITE(HWRITE),  
    .HRDATA(HRDATA),  
    .HREADYOUT(HREADYOUT),  
    .PCLK(PCLK), 
    .PRESETn(PRESETn), 
    .PADDR(PADDR[31:0]), 
    .PWRITE(PWRITE), 
    .PWDATA(PWDATA[31:0]), 
    .PENABLE(PENABLE), 
    .PREADY(PREADY), 
    .PRDATA(PRDATA[31:0]) 
  ); 
 
  APBDUMMY1 uAPBDUMMY1( 
    .PCLK(PCLK), 
    .PRESETn(PRESETn), 
    .PWRITE(PWRITE), 
    .PWDATA(PWDATA[31:0]), 
    .PENABLE(PENABLE), 
    .PSEL(PSEL_DUMMY1), 
    .PREADY(PREADY), 
    .PRDATA(PRDATA[31:0]) 
  ); 
 
//Address for APBDUMMY1 = 0x5C00_0000 
  assign PSEL_DUMMY1 = (PADDR[23:20]== 4'h0); 
 
 
 
 
endmodule 
</pre>
<script src="/inc/gg_read2.js"></script><BR>
</body></html>
