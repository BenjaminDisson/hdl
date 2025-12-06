<html><head><meta charset="GB2312"><title>CM0DS-DesignKit.zip dual_port_ram_sync.v</title>
<LINK href="/inc/read_style.css" type=text/css rel=stylesheet></head>
<body>
<p><a href=http://www.pudn.com>www.pudn.com</a> &gt; <a href="http://www.pudn.com/Download/item/id/2490414.html">CM0DS-DesignKit.zip</a> &gt dual_port_ram_sync.v, change:2012-04-09,size:705b</p><!-- saved from http://www.pudn.com -->
<script src="/inc/gg_read1.js"></script><BR>
<pre name="code" class="v">
module dual_port_ram_sync 
  #( 
      parameter ADDR_WIDTH = 6, 
      parameter DATA_WIDTH = 8 
  ) 
  ( 
  input wire clk, 
  input wire we, 
  input wire [ADDR_WIDTH-1:0] addr_a, 
  input wire [ADDR_WIDTH-1:0] addr_b, 
  input wire [DATA_WIDTH-1:0] din_a, 
   
  output wire [DATA_WIDTH-1:0] dout_a, 
  output wire [DATA_WIDTH-1:0] dout_b 
  ); 
 
  reg [DATA_WIDTH-1:0] ram [2**ADDR_WIDTH-1:0]; 
  reg [ADDR_WIDTH-1:0] addr_a_reg; 
  reg [ADDR_WIDTH-1:0] addr_b_reg; 
   
  always @ (posedge clk) 
  begin 
    if(we) 
      ram[addr_a] &lt;= din_a; 
    addr_a_reg &lt;= addr_a; 
    addr_b_reg &lt;= addr_b; 
  end 
   
  assign dout_a = ram[addr_a_reg]; 
  assign dout_b = ram[addr_b_reg]; 
   
endmodule 
</pre>
<script src="/inc/gg_read2.js"></script><BR>
</body></html>
