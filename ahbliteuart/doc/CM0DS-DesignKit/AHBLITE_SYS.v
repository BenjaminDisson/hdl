<html><head><meta charset="GB2312"><title>CM0DS-DesignKit.zip AHBLITE_SYS.v</title>
<LINK href="/inc/read_style.css" type=text/css rel=stylesheet></head>
<body>
<p><a href=http://www.pudn.com>www.pudn.com</a> &gt; <a href="http://www.pudn.com/Download/item/id/2490414.html">CM0DS-DesignKit.zip</a> &gt AHBLITE_SYS.v, change:2012-05-14,size:7605b</p><!-- saved from http://www.pudn.com -->
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
 
 
module AHBLITE_SYS( 
	//CLOCKS & RESET 
	input		wire				CLK, 
	input		wire				RESETn,   
				 
	//BOARD LEVEL IOs  
				  
	//TOWARDS MEMORY 
	inout  	wire	[15:0] 	MemDB, 
	output 	wire	[26:1] 	MemAdr, 
	output 	wire				RamCS, 
	output 	wire				FlashCS, 
	output 	wire				MemWR, 
	output 	wire				MemOE, 
	output 	wire				RamUB, 
	output 	wire				RamLB, 
	output 	wire				RamCre, 
	output 	wire				RamAdv, 
	output 	wire				RamClk, 
	input 	wire				RamWait, 
	output 	wire				FlashRp, 
    
	//TO BOARD LEDs  
	output 	wire	[7:0] 	LED,  
	  
	//TO UART  
	input 	wire				RsRx,  
	output 	wire				RsTx  
  
); 
 
//AHB-LITE MASTER OUTPUT SIGNALS  
wire 				HCLK;  
wire 				HRESETn;  
wire [31:0]		HADDR;  
wire [31:0]		HWDATA; 
wire 				HWRITE; 
wire [1:0] 		HTRANS; 
wire [2:0] 		HBURST; 
wire 				HMASTLOCK; 
wire [3:0] 		HPROT; 
wire [2:0] 		HSIZE;  
  
wire 				LOCKUP;  
wire 				TXEV;  
wire 				SLEEPING; 
wire [15:0]		IRQ; 
  
//AHB-LITE MASTER INPUT SIGNALS 
wire [31:0] 	HRDATA;  
wire 				HRESP;  
wire 				HREADY;  
		  
//SELECT SIGNALS  
wire [3:0] 		MUX_SEL;  
 
wire 				HSEL_MEM; 
wire 				HSEL_LED;  
wire 				HSEL_UART;  
  
//SLAVE READ DATA  
wire [31:0] 	HRDATA_MEM;  
wire [31:0] 	HRDATA_LED;  
wire [31:0] 	HRDATA_UART;  
  
wire 				HREADYOUT_MEM;  
wire 				HREADYOUT_LED;  
wire 				HREADYOUT_UART;  
    
//SYSTEM GENERATES NO ERROR RESPONSE  
assign 			HRESP = 1'b0;  
  
//CM0-DS INTERRUPT SIGNALS    
assign 			IRQ = {15'b0000_0000_0000_000,UART_IRQ};  
assign 			LED[7] = LOCKUP;  
  
//CLOCK DIVIDER & RESET  
reg 	rCLK; 
always @(posedge CLK) 
		rCLK &lt;= ~rCLK;  
assign 			HCLK = rCLK;  
assign 			HRESETn = RESETn;  
                   
  
//AHBLite MASTER --> CM0-DS  
 
CORTEXM0DS u_cortexm0ds ( 
	.HCLK        (HCLK), 
	.HRESETn     (HRESETn), 
	.HADDR       (HADDR[31:0]), 
	.HBURST      (HBURST[2:0]), 
	.HMASTLOCK   (HMASTLOCK), 
	.HPROT       (HPROT[3:0]), 
	.HSIZE       (HSIZE[2:0]), 
	.HTRANS      (HTRANS[1:0]), 
	.HWDATA      (HWDATA[31:0]), 
	.HWRITE      (HWRITE), 
	.HRDATA      (HRDATA[31:0]),			 
	.HREADY      (HREADY),					 
	.HRESP       (HRESP),					  
   
	.NMI         (1'b0), 
	.IRQ         (IRQ[15:0]), 
	.TXEV        (), 
	.RXEV        (1'b0), 
	.LOCKUP      (LOCKUP), 
	.SYSRESETREQ (), 
	.SLEEPING    () 
);  
  
//Address Decoder   
 
AHBDCD uAHBDCD (  
	.HADDR(HADDR[31:0]),  
	   
	.HSEL_S0(HSEL_MEM),  
	.HSEL_S1(HSEL_LED),  
	.HSEL_S2(HSEL_UART),  
	.HSEL_S3(),  
	.HSEL_S4(),  
	.HSEL_S5(),  
	.HSEL_S6(),  
	.HSEL_S7(),  
	.HSEL_S8(),  
	.HSEL_S9(),  
	.HSEL_NOMAP(HSEL_NOMAP),  
	  
	.MUX_SEL(MUX_SEL[3:0])  
);  
  
//Slave to Master Mulitplexor  
  
AHBMUX uAHBMUX (  
	.HCLK(HCLK),  
	.HRESETn(HRESETn),  
	.MUX_SEL(MUX_SEL[3:0]),  
	  
	.HRDATA_S0(HRDATA_MEM),  
	.HRDATA_S1(HRDATA_LED),  
	.HRDATA_S2(HRDATA_UART),  
	.HRDATA_S3(),  
	.HRDATA_S4(),  
	.HRDATA_S5(),  
	.HRDATA_S6(),  
	.HRDATA_S7(),  
	.HRDATA_S8(),  
	.HRDATA_S9(),  
	.HRDATA_NOMAP(32'hDEADBEEF),  
	  
	.HREADYOUT_S0(HREADYOUT_MEM),  
	.HREADYOUT_S1(HREADYOUT_LED),  
	.HREADYOUT_S2(HREADYOUT_UART),  
	.HREADYOUT_S3(1'b1),  
	.HREADYOUT_S4(1'b1),  
	.HREADYOUT_S5(1'b1),  
	.HREADYOUT_S6(1'b1),  
	.HREADYOUT_S7(1'b1),  
	.HREADYOUT_S8(1'b1),  
	.HREADYOUT_S9(1'b1),  
	.HREADYOUT_NOMAP(1'b1),  
      
	.HRDATA(HRDATA[31:0]),  
	.HREADY(HREADY)  
); 
  
// AHBLite Peripherals  
  
// AHBLite Memory Controller    
AHB2SRAMFLSH uAHB2SRAMFLSH (  
	.HCLK(HCLK),  
	.HRESETn(HRESETn),   
	.HADDR(HADDR[31:0]),  
	.HSEL(HSEL_MEM),  
	.HREADY(HREADY), 
	.HSIZE(HSIZE[2:0]),  
	.HTRANS(HTRANS[1:0]),  
	.HWDATA(HWDATA[31:0]),  
	.HWRITE(HWRITE),  
	.HRDATA(HRDATA_MEM[31:0]),  
	.HREADYOUT(HREADYOUT_MEM),  
   
	.FlashAtZero(1'b0),  
  
	.MemDB(MemDB),  
	.MemAdr(MemAdr[26:1]),  
	.RamCS(RamCS),  
	.FlashCS(FlashCS),  
	.MemWR(MemWR),  
	.MemOE(MemOE),  
	.RamUB(RamUB),  
	.RamLB(RamLB),  
	.RamCre(RamCre),  
	.RamAdv(RamAdv),  
	.RamClk(RamClk),  
	.RamWait(RamWait),  
	.FlashRp(FlashRp)  
); 
   
  
//AHBLITE SLAVE LED DRIVER 
AHB2LED uAHB2LED (  
	.HCLK(HCLK),  
	.HRESETn(HRESETn),  
	.HSEL(HSEL_LED),  
	.HREADY(HREADY),      
	.HTRANS(HTRANS[1:0]),  
	.HWDATA(HWDATA[31:0]),  
	.HWRITE(HWRITE),  
	.HRDATA(HRDATA_LED),  
	.HREADYOUT(HREADYOUT_LED),  
	.LED(LED[6:0])  
);  
  
  
//AHBLITE SLAVE UART CONTROLLER  
wire	UART_IRQ;				// INTERRUPT FROM UART  
  
AHBUART uAHBUART(  
	.HCLK(HCLK),  
	.HRESETn(HRESETn),  
	.HADDR(HADDR[31:0]),  
	.HTRANS(HTRANS[1:0]),  
	.HWDATA(HWDATA[31:0]),  
	.HWRITE(HWRITE),  
	.HREADY(HREADY),  
	.HREADYOUT(HREADYOUT_UART),  
	.HRDATA(HRDATA_UART[31:0]),  
	.HSEL(HSEL_UART),  
	  
	.RsRx(RsRx),  
	.RsTx(RsTx),  
	.uart_irq(UART_IRQ)  
    );  
  
    
  
endmodule 
</pre>
<script src="/inc/gg_read2.js"></script><BR>
</body></html>
