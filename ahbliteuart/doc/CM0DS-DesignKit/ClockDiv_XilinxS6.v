<html><head><meta charset="GB2312"><title>CM0DS-DesignKit.zip ClockDiv_XilinxS6.v</title>
<LINK href="/inc/read_style.css" type=text/css rel=stylesheet></head>
<body>
<p><a href=http://www.pudn.com>www.pudn.com</a> &gt; <a href="http://www.pudn.com/Download/item/id/2490414.html">CM0DS-DesignKit.zip</a> &gt ClockDiv_XilinxS6.v, change:2012-04-09,size:855b</p><!-- saved from http://www.pudn.com -->
<script src="/inc/gg_read1.js"></script><BR>
<pre name="code" class="v">
//  --========================================================================-- 
//  Version and Release Control Information: 
// 
//  File Name           : ClockDiv.v 
//  File Revision       : 1.00 
// 
//  ---------------------------------------------------------------------------- 
//  Purpose             : Platform specific Clock Divider 
//                         
//  --========================================================================-- 
 
 
module ClockDiv( 
	//Clock Input 
			input wire 	CLK_I, 
	//Clock Output 
			output wire CLK_O 
 
    ); 
 
 
// Refer to Spartan 6 clocking resource guide for more info in BUFIO2 and BUFG 
 
wire ck; 
 
BUFIO2 # 
	(	.DIVIDE(2), 
		.DIVIDE_BYPASS(0) 
	) 
	uBUFIO2( 
	.I				(CLK_I), 
	.DIVCLK		(ck), 
	.IOCLK		(), 
	.SERDESSTROBE() 
	); 
 
BUFG uBUFG( 
	.I(ck), 
	.O(CLK_O) 
	); 
 
 
endmodule 
</pre>
<script src="/inc/gg_read2.js"></script><BR>
</body></html>
